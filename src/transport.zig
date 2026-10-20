//! Transport abstraction, persistent TLS 1.3 keep-alive `HttpTransport`,
//! Local Bot API Server (`telegram-bot-api --local`) path remapping, and
//! deterministic `MockTransport`.
//!
//! Fixes the performance and reliability flaws in earlier Zig Telegram clients:
//! - Preserves `keep_alive = true` across requests so `std.http.Client`'s
//!   connection pool reuses TLS 1.3 sessions instead of paying a TCP + TLS
//!   handshake on every Bot API call.
//! - Retains a replayable request payload buffer so stale pooled connections
//!   closed by the server mid-flight can be retried once transparently.
//! - Enforces a strict `max_response_bytes` cap before allocating response buffers.

const std = @import("std");
const Allocator = std.mem.Allocator;
const TelegramError = @import("error.zig").TelegramError;

/// Default Telegram Bot API cloud origin.
pub const default_api_base_url = "https://api.telegram.org";

/// Default maximum JSON response size (16 MiB).
pub const default_max_response_bytes: usize = 16 * 1024 * 1024;

/// Configuration for a self-hosted `telegram-bot-api --local` server, which
/// unlocks 2000 MB uploads/downloads and returns absolute filesystem paths in
/// `File.file_path`.
pub const LocalServerConfig = struct {
    /// Base URL of the local server, e.g. `"http://127.0.0.1:8081"`.
    base_url: []const u8 = "http://127.0.0.1:8081",
    /// Optional container/server prefix returned by `getFile` (e.g. `"/var/lib/telegram-bot-api"`).
    server_files_dir: ?[]const u8 = null,
    /// Optional host directory mapped to `server_files_dir` (e.g. `"/srv/tg-files"`).
    host_files_dir: ?[]const u8 = null,

    /// Remaps a `File.file_path` returned by a `--local` server to the host
    /// filesystem path. Caller owns the returned slice.
    pub fn resolveLocalFilePath(self: LocalServerConfig, allocator: Allocator, file_path: []const u8) Allocator.Error![]u8 {
        if (self.server_files_dir) |srv_prefix| {
            if (self.host_files_dir) |host_prefix| {
                if (std.mem.startsWith(u8, file_path, srv_prefix)) {
                    const suffix = file_path[srv_prefix.len..];
                    return std.fmt.allocPrint(allocator, "{s}{s}", .{ host_prefix, suffix });
                }
            }
        }
        return allocator.dupe(u8, file_path);
    }

    /// Formats a local host file path as a `file://` URI accepted by a local
    /// Bot API server in place of a multipart upload.
    pub fn formatFileUri(allocator: Allocator, abs_path: []const u8) Allocator.Error![]u8 {
        if (std.mem.startsWith(u8, abs_path, "file://")) {
            return allocator.dupe(u8, abs_path);
        }
        return std.fmt.allocPrint(allocator, "file://{s}", .{abs_path});
    }
};

/// Raw HTTP request passed to a `Transport` implementation.
pub const RawRequest = struct {
    /// Full URL (`https://api.telegram.org/bot<token>/<method>`).
    url: []const u8,
    /// Optional Content-Type header (`application/json` or `multipart/form-data; boundary=...`).
    /// When `body == null`, `content_type` may also be `null` (bodiless request).
    content_type: ?[]const u8 = null,
    /// Optional request body bytes. When `null`, a bodiless request is sent.
    body: ?[]const u8 = null,
    /// Maximum allowed response body size in bytes.
    max_response_bytes: usize = default_max_response_bytes,
};

/// Raw HTTP response returned by a `Transport` implementation.
pub const RawResponse = struct {
    status: u16,
    body: []u8,

    pub fn deinit(self: *RawResponse, allocator: Allocator) void {
        allocator.free(self.body);
        self.* = undefined;
    }
};

/// Polymorphic transport vtable used by `BotClient`.
pub const Transport = struct {
    ptr: *anyopaque,
    vtable: *const VTable,

    pub const VTable = struct {
        send: *const fn (ptr: *anyopaque, allocator: Allocator, req: RawRequest) TelegramError!RawResponse,
    };

    pub fn send(self: Transport, allocator: Allocator, req: RawRequest) TelegramError!RawResponse {
        return self.vtable.send(self.ptr, allocator, req);
    }
};

/// Bounded `std.Io.Writer` adapter that appends into a caller-provided
/// `std.ArrayList(u8)` and returns `error.WriteFailed` if `max_bytes` is exceeded.
const BoundedWriter = struct {
    allocator: Allocator,
    list: std.ArrayList(u8) = .empty,
    max_bytes: usize,
    exceeded: bool = false,
    writer: std.Io.Writer,

    fn init(allocator: Allocator, max_bytes: usize, buffer: []u8) BoundedWriter {
        return .{
            .allocator = allocator,
            .max_bytes = max_bytes,
            .writer = .{
                .vtable = &.{
                    .drain = drain,
                },
                .buffer = buffer,
            },
        };
    }

    fn deinit(self: *BoundedWriter) void {
        self.list.deinit(self.allocator);
    }

    fn toOwnedSlice(self: *BoundedWriter) TelegramError![]u8 {
        self.writer.flush() catch {
            if (self.exceeded) return error.ResponseTooLarge;
            return error.OutOfMemory;
        };
        if (self.exceeded) return error.ResponseTooLarge;
        return self.list.toOwnedSlice(self.allocator) catch return error.OutOfMemory;
    }

    fn drain(w: *std.Io.Writer, data: []const []const u8, splat: usize) std.Io.Writer.Error!usize {
        const self: *BoundedWriter = @alignCast(@fieldParentPtr("writer", w));
        const buffered = w.buffered();
        if (buffered.len > 0) {
            try self.appendChecked(buffered);
            w.end = 0;
        }
        if (data.len == 0) return 0;

        var total: usize = 0;
        for (data[0 .. data.len - 1]) |slice| {
            try self.appendChecked(slice);
            total += slice.len;
        }
        const pattern = data[data.len - 1];
        var i: usize = 0;
        while (i < splat) : (i += 1) {
            try self.appendChecked(pattern);
            total += pattern.len;
        }
        return total;
    }

    fn appendChecked(self: *BoundedWriter, bytes: []const u8) std.Io.Writer.Error!void {
        if (bytes.len > self.max_bytes or self.list.items.len > self.max_bytes - bytes.len) {
            self.exceeded = true;
            return error.WriteFailed;
        }
        self.list.appendSlice(self.allocator, bytes) catch return error.WriteFailed;
    }
};

/// Production HTTP/HTTPS transport backed by `std.http.Client` with persistent
/// keep-alive connection pooling and automatic single-retry on stale pooled
/// connection reset.
pub const HttpTransport = struct {
    http_client: std.http.Client,
    user_agent: []const u8 = "zig-telegram/0.1.0",

    pub fn init(allocator: Allocator, io: std.Io) HttpTransport {
        return .{
            .http_client = .{
                .allocator = allocator,
                .io = io,
            },
        };
    }

    pub fn deinit(self: *HttpTransport) void {
        self.http_client.deinit();
    }

    pub fn transport(self: *HttpTransport) Transport {
        return .{
            .ptr = self,
            .vtable = &vtable,
        };
    }

    const vtable = Transport.VTable{
        .send = sendImpl,
    };

    fn sendImpl(ptr: *anyopaque, allocator: Allocator, req: RawRequest) TelegramError!RawResponse {
        const self: *HttpTransport = @ptrCast(@alignCast(ptr));
        // Attempt up to 2 times in case a pooled keep-alive connection was
        // closed by the remote peer right before our write.
        return self.executeOnce(allocator, req) catch |first_err| switch (first_err) {
            error.TransportError => self.executeOnce(allocator, req),
            else => return first_err,
        };
    }

    fn executeOnce(self: *HttpTransport, allocator: Allocator, req: RawRequest) TelegramError!RawResponse {
        var scratch_buf: [4096]u8 = undefined;
        var bounded = BoundedWriter.init(allocator, req.max_response_bytes, &scratch_buf);
        defer bounded.deinit();

        var headers: std.http.Client.Request.Headers = .{
            .user_agent = .{ .override = self.user_agent },
        };
        if (req.content_type) |ct| {
            headers.content_type = .{ .override = ct };
        }

        const method: std.http.Method = if (req.body != null) .POST else .GET;
        const fetch_res = self.http_client.fetch(.{
            .location = .{ .url = req.url },
            .method = method,
            .payload = req.body,
            .keep_alive = true,
            .headers = headers,
            .response_writer = &bounded.writer,
        }) catch |err| {
            if (bounded.exceeded) return error.ResponseTooLarge;
            return switch (err) {
                error.OutOfMemory => error.OutOfMemory,
                else => error.TransportError,
            };
        };

        const body = try bounded.toOwnedSlice();
        return .{
            .status = @backingInt(fetch_res.status),
            .body = body,
        };
    }
};

/// Deterministic in-memory mock transport for unit tests, golden wire tests,
/// and CLI tests without network access.
pub const MockTransport = struct {
    pub const Exchange = struct {
        status: u16 = 200,
        response_body: []const u8,
    };

    pub const RecordedRequest = struct {
        url: []u8,
        content_type: ?[]u8,
        body: ?[]u8,

        pub fn deinit(self: *RecordedRequest, allocator: Allocator) void {
            allocator.free(self.url);
            if (self.content_type) |ct| allocator.free(ct);
            if (self.body) |b| allocator.free(b);
            self.* = undefined;
        }
    };

    allocator: Allocator,
    queue: std.ArrayList(Exchange) = .empty,
    recorded: std.ArrayList(RecordedRequest) = .empty,
    cursor: usize = 0,

    pub fn init(allocator: Allocator) MockTransport {
        return .{ .allocator = allocator };
    }

    pub fn deinit(self: *MockTransport) void {
        self.queue.deinit(self.allocator);
        for (self.recorded.items) |*rec| {
            rec.deinit(self.allocator);
        }
        self.recorded.deinit(self.allocator);
    }

    pub fn pushResponse(self: *MockTransport, status: u16, response_body: []const u8) Allocator.Error!void {
        try self.queue.append(self.allocator, .{
            .status = status,
            .response_body = response_body,
        });
    }

    pub fn lastRequest(self: *const MockTransport) ?RecordedRequest {
        if (self.recorded.items.len == 0) return null;
        return self.recorded.items[self.recorded.items.len - 1];
    }

    pub fn transport(self: *MockTransport) Transport {
        return .{
            .ptr = self,
            .vtable = &vtable,
        };
    }

    const vtable = Transport.VTable{
        .send = sendImpl,
    };

    fn sendImpl(ptr: *anyopaque, allocator: Allocator, req: RawRequest) TelegramError!RawResponse {
        const self: *MockTransport = @ptrCast(@alignCast(ptr));

        {
            const url_copy = try self.allocator.dupe(u8, req.url);
            errdefer self.allocator.free(url_copy);
            const ct_copy = if (req.content_type) |ct| try self.allocator.dupe(u8, ct) else null;
            errdefer if (ct_copy) |ct| self.allocator.free(ct);
            const body_copy = if (req.body) |b| try self.allocator.dupe(u8, b) else null;
            errdefer if (body_copy) |b| self.allocator.free(b);

            try self.recorded.append(self.allocator, .{
                .url = url_copy,
                .content_type = ct_copy,
                .body = body_copy,
            });
        }

        if (self.cursor >= self.queue.items.len) {
            return error.TransportError;
        }
        const exch = self.queue.items[self.cursor];
        self.cursor += 1;

        if (exch.response_body.len > req.max_response_bytes) {
            return error.ResponseTooLarge;
        }

        return .{
            .status = exch.status,
            .body = try allocator.dupe(u8, exch.response_body),
        };
    }
};

test "MockTransport records requests and enforces max_response_bytes" {
    const allocator = std.testing.allocator;
    var mock = MockTransport.init(allocator);
    defer mock.deinit();

    try mock.pushResponse(200, "{\"ok\":true,\"result\":true}");
    try mock.pushResponse(200, "0123456789ABCDEF");

    const t = mock.transport();
    var resp1 = try t.send(allocator, .{
        .url = "https://api.telegram.org/bot123:sec/close",
        .body = null,
    });
    defer resp1.deinit(allocator);
    try std.testing.expectEqual(@as(u16, 200), resp1.status);
    try std.testing.expect(mock.lastRequest().?.body == null);

    try std.testing.expectError(error.ResponseTooLarge, t.send(allocator, .{
        .url = "https://api.telegram.org/bot123:sec/getMe",
        .max_response_bytes = 8,
    }));
}

test "LocalServerConfig path remapping and file:// URI" {
    const allocator = std.testing.allocator;
    const cfg = LocalServerConfig{
        .server_files_dir = "/var/lib/telegram-bot-api",
        .host_files_dir = "/data/tg-local",
    };

    const mapped = try cfg.resolveLocalFilePath(allocator, "/var/lib/telegram-bot-api/123:ABC/videos/file_1.mp4");
    defer allocator.free(mapped);
    try std.testing.expectEqualStrings("/data/tg-local/123:ABC/videos/file_1.mp4", mapped);

    const uri = try LocalServerConfig.formatFileUri(allocator, mapped);
    defer allocator.free(uri);
    try std.testing.expectEqualStrings("file:///data/tg-local/123:ABC/videos/file_1.mp4", uri);
}
