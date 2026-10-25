//! Long-polling update loop (`getUpdates`) with automatic `offset` advancement,
//! HTTP 429 `retry_after` compliance, jittered Fibonacci backoff on transient failures,
//! and per-batch arena memory management.

const std = @import("std");
const Allocator = std.mem.Allocator;
const client_mod = @import("client.zig");
const types = @import("types.zig");
const err_mod = @import("../error.zig");

pub const BotClient = client_mod.BotClient;
pub const Update = types.Update;
pub const TelegramError = err_mod.TelegramError;
pub const ErrorDetail = err_mod.ErrorDetail;

pub const PollerConfig = struct {
    /// Long-polling server-side wait timeout in seconds (`0` for short polling).
    timeout_seconds: i64 = 30,
    /// Maximum number of updates to fetch per batch (`1..100`).
    limit: i64 = 100,
    /// Optional filter of update types (`&.{ "message", "callback_query" }`).
    allowed_updates: ?[]const []const u8 = null,
    /// Initial backoff in milliseconds when a transient transport/server error occurs.
    initial_backoff_ms: u64 = 500,
    /// Maximum backoff in milliseconds.
    max_backoff_ms: u64 = 30_000,
};

pub const Poller = struct {
    client: *const BotClient,
    config: PollerConfig = .{},
    next_offset: ?i64 = null,
    consecutive_failures: u32 = 0,
    stopped: std.atomic.Value(bool) = .init(false),

    pub fn init(client: *const BotClient, config: PollerConfig) Poller {
        return .{
            .client = client,
            .config = config,
        };
    }

    /// Signals the poller to exit after completing the current iteration.
    pub fn stop(self: *Poller) void {
        self.stopped.store(true, .release);
    }

    /// Fetches a single batch of updates using `getUpdates` and advances
    /// `self.next_offset` to `max(update_id) + 1`.
    ///
    /// Caller owns the returned `std.json.Parsed([]const Update)` and must call
    /// `.deinit()` when done processing the batch.
    pub fn pollBatch(
        self: *Poller,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed([]const Update) {
        const parsed = try self.client.getUpdates(.{
            .offset = self.next_offset,
            .limit = self.config.limit,
            .timeout = self.config.timeout_seconds,
            .allowed_updates = self.config.allowed_updates,
        }, err_out);

        for (parsed.value) |upd| {
            const candidate = upd.update_id + 1;
            if (self.next_offset == null or candidate > self.next_offset.?) {
                self.next_offset = candidate;
            }
        }
        self.consecutive_failures = 0;
        return parsed;
    }

    /// Computes the next backoff duration in milliseconds for failure `attempt`
    /// (`0, 1, 2, ...`) using bounded Fibonacci progression.
    pub fn computeBackoffMs(self: *const Poller, attempt: u32) u64 {
        var a: u64 = self.config.initial_backoff_ms;
        var b: u64 = self.config.initial_backoff_ms;
        var i: u32 = 0;
        while (i < attempt and i < 32) : (i += 1) {
            const next = a +| b;
            a = b;
            b = @min(next, self.config.max_backoff_ms);
        }
        return @min(a, self.config.max_backoff_ms);
    }

    /// Spreads retries of many pollers: maps `delay_ms` to a value in
    /// `[delay_ms / 2, delay_ms]` chosen by `rand`.
    pub fn applyJitter(delay_ms: u64, rand: u64) u64 {
        const half = delay_ms / 2;
        return half + rand % (delay_ms - half + 1);
    }

    /// Runs the polling loop until `stop()` is called or `max_batches` is
    /// reached (when non-null).
    ///
    /// On `error.TooManyRequests` (HTTP 429), automatically sleeps for the
    /// server-provided `ErrorDetail.retry_after` seconds.
    pub fn run(
        self: *Poller,
        ctx: anytype,
        comptime handler: fn (ctx: @TypeOf(ctx), update: Update) anyerror!void,
        max_batches: ?usize,
    ) !void {
        var batches_done: usize = 0;
        while (!self.stopped.load(.acquire)) {
            if (max_batches) |limit| {
                if (batches_done >= limit) break;
            }
            batches_done += 1;

            var detail: ?ErrorDetail = null;
            defer if (detail) |*d| d.deinit(self.client.allocator);

            var batch = self.pollBatch(&detail) catch |err| switch (err) {
                error.Unauthorized, error.Conflict => return err,
                error.TooManyRequests => {
                    const retry_secs: u64 = if (detail) |d| (d.retry_after orelse 1) else 1;
                    self.sleepMs(retry_secs * 1000);
                    continue;
                },
                else => {
                    var rand: [8]u8 = undefined;
                    self.client.io.random(&rand);
                    const delay_ms = applyJitter(
                        self.computeBackoffMs(self.consecutive_failures),
                        std.mem.readInt(u64, &rand, .little),
                    );
                    self.consecutive_failures +|= 1;
                    self.sleepMs(delay_ms);
                    continue;
                },
            };
            defer batch.deinit();

            for (batch.value) |upd| {
                try handler(ctx, upd);
                if (self.stopped.load(.acquire)) break;
            }
        }
    }

    fn sleepMs(self: *const Poller, ms: u64) void {
        if (ms == 0) return;
        const ns: i96 = @as(i96, @intCast(ms)) * std.time.ns_per_ms;
        self.client.io.sleep(.{ .nanoseconds = ns }, .awake) catch {};
    }
};

test "Poller advances offset and honors 429 retry_after" {
    const allocator = std.testing.allocator;
    const io = std.testing.io;
    const transport_mod = @import("../transport.zig");
    const secret_mod = @import("../secret.zig");

    var mock = transport_mod.MockTransport.init(allocator);
    defer mock.deinit();

    try mock.pushResponse(200,
        \\{"ok":true,"result":[{"update_id":100,"message":{"message_id":1,"date":1700000000,"chat":{"id":42,"type":"private"},"text":"first"}},{"update_id":105,"message":{"message_id":2,"date":1700000001,"chat":{"id":42,"type":"private"},"text":"second"}}]}
    );
    try mock.pushResponse(429,
        \\{"ok":false,"error_code":429,"description":"Too Many Requests: retry after 0","parameters":{"retry_after":0}}
    );
    try mock.pushResponse(200,
        \\{"ok":true,"result":[]}
    );

    const token = try secret_mod.SecretToken.initValidated("123456:AAH_valid_token");
    const bot = BotClient.init(allocator, io, token, mock.transport(), .{});
    var poller = Poller.init(&bot, .{ .initial_backoff_ms = 0 });

    const Counter = struct {
        count: usize = 0,
        last_text: []const u8 = "",
        fn onUpdate(self: *@This(), upd: Update) !void {
            self.count += 1;
            if (upd.message) |m| {
                if (m.text) |t| self.last_text = t;
            }
        }
    };
    var state = Counter{};
    try poller.run(&state, Counter.onUpdate, 3);

    try std.testing.expectEqual(@as(usize, 2), state.count);
    try std.testing.expectEqual(@as(?i64, 106), poller.next_offset);
    // Verify second request sent `"offset":106`
    try std.testing.expect(std.mem.indexOf(u8, mock.recorded.items[1].body.?, "\"offset\":106") != null);
}

test "applyJitter stays within half to full delay" {
    try std.testing.expectEqual(@as(u64, 0), Poller.applyJitter(0, 12345));
    var r: u64 = 0;
    while (r < 5000) : (r += 37) {
        const d = Poller.applyJitter(1000, r *% 0x9E3779B97F4A7C15);
        try std.testing.expect(d >= 500 and d <= 1000);
    }
    try std.testing.expectEqual(@as(u64, 500), Poller.applyJitter(1000, 0));
    try std.testing.expectEqual(@as(u64, 1000), Poller.applyJitter(1000, 500));
}
