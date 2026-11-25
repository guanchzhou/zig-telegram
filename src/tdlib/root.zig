//! Optional zero-cost TDLib (`libtdjson`) dynamic bridge (`telegram.tdlib`).
//!
//! By default, `zig-telegram` compiles with zero C or `libc` dependencies.
//! Applications that wish to drive a full user-account or bot session via
//! Telegram's C++ `libtdjson` library can either:
//! 1. Load `libtdjson.dylib` / `libtdjson.so` / `tdjson.dll` at runtime via
//!    `TdjsonClient.openDynamic(library_path)`, or
//! 2. Inject a custom/mock `Binding` table in tests without installing TDLib.

const std = @import("std");

/// Function pointer table matching the official TDLib `td/telegram/td_json_client.h` C ABI.
pub const Binding = struct {
    td_create_client_id: *const fn () callconv(.c) c_int,
    td_send: *const fn (client_id: c_int, request: [*:0]const u8) callconv(.c) void,
    td_receive: *const fn (timeout: f64) callconv(.c) ?[*:0]const u8,
    td_execute: *const fn (request: [*:0]const u8) callconv(.c) ?[*:0]const u8,
};

pub const TdlibError = error{
    LibraryOpenFailed,
    MissingSymbol,
};

/// High-level wrapper over a `Binding` table (dynamically loaded or mocked).
pub const TdjsonClient = struct {
    binding: Binding,
    dyn_lib: ?std.DynLib = null,
    client_id: c_int,

    /// Initializes a `TdjsonClient` over an explicit `Binding` vtable.
    pub fn initWithBinding(binding: Binding) TdjsonClient {
        return .{
            .binding = binding,
            .dyn_lib = null,
            .client_id = binding.td_create_client_id(),
        };
    }

    /// Dynamically opens `libtdjson` at runtime via `std.DynLib` and resolves
    /// `td_create_client_id`, `td_send`, `td_receive`, and `td_execute`.
    pub fn openDynamic(lib_path: []const u8) TdlibError!TdjsonClient {
        var lib = std.DynLib.open(lib_path) catch return error.LibraryOpenFailed;
        errdefer lib.close();

        const create_fn = lib.lookup(*const fn () callconv(.c) c_int, "td_create_client_id") orelse return error.MissingSymbol;
        const send_fn = lib.lookup(*const fn (c_int, [*:0]const u8) callconv(.c) void, "td_send") orelse return error.MissingSymbol;
        const recv_fn = lib.lookup(*const fn (f64) callconv(.c) ?[*:0]const u8, "td_receive") orelse return error.MissingSymbol;
        const exec_fn = lib.lookup(*const fn ([*:0]const u8) callconv(.c) ?[*:0]const u8, "td_execute") orelse return error.MissingSymbol;

        const binding = Binding{
            .td_create_client_id = create_fn,
            .td_send = send_fn,
            .td_receive = recv_fn,
            .td_execute = exec_fn,
        };
        return .{
            .binding = binding,
            .dyn_lib = lib,
            .client_id = binding.td_create_client_id(),
        };
    }

    /// Releases the wrapper. The dynamically loaded library is deliberately
    /// never unloaded: TDLib keeps internal threads running after the last
    /// client is closed, and unmapping their code would crash the process.
    /// Send `{"@type":"close"}` and wait for `authorizationStateClosed` before
    /// dropping the client.
    pub fn deinit(self: *TdjsonClient) void {
        self.dyn_lib = null;
    }

    /// Asynchronously sends a null-terminated JSON TDLib request to `self.client_id`.
    pub fn send(self: *const TdjsonClient, request_json: [:0]const u8) void {
        self.binding.td_send(self.client_id, request_json.ptr);
    }

    /// Upper bound on `timeout_seconds` passed through to C `td_receive`.
    pub const max_receive_timeout_seconds: f64 = 86_400.0;

    /// Receives the next incoming TDLib JSON event or response, waiting up to
    /// `timeout_seconds`. Returns `null` on timeout.
    ///
    /// Rejects non-finite (`NaN`, `±inf`) or negative `timeout_seconds` without
    /// calling `td_receive`, and clamps finite values to `max_receive_timeout_seconds`.
    ///
    /// The returned slice is owned by TDLib and is valid only until the next
    /// `receive` or `execute` call on any thread; copy it to keep it.
    pub fn receive(self: *const TdjsonClient, timeout_seconds: f64) ?[]const u8 {
        if (!std.math.isFinite(timeout_seconds) or timeout_seconds < 0.0) return null;
        const clamped = if (timeout_seconds == 0.0) 0.0 else @min(timeout_seconds, max_receive_timeout_seconds);
        const ptr = self.binding.td_receive(clamped) orelse return null;
        return std.mem.span(ptr);
    }

    /// Synchronously executes a TDLib JSON method (such as `getTextEntities` or `setLogVerbosityLevel`).
    ///
    /// The returned slice is owned by TDLib and is valid only until the next
    /// `receive` or `execute` call on any thread; copy it to keep it.
    pub fn execute(self: *const TdjsonClient, request_json: [:0]const u8) ?[]const u8 {
        const ptr = self.binding.td_execute(request_json.ptr) orelse return null;
        return std.mem.span(ptr);
    }
};

test "TdjsonClient mock binding round-trip" {
    const MockC = struct {
        var last_sent_id: c_int = 0;

        fn createId() callconv(.c) c_int {
            return 7;
        }
        fn sendFn(id: c_int, _: [*:0]const u8) callconv(.c) void {
            last_sent_id = id;
        }
        fn recvFn(_: f64) callconv(.c) ?[*:0]const u8 {
            return "{\"@type\":\"updateAuthorizationState\"}";
        }
        fn execFn(_: [*:0]const u8) callconv(.c) ?[*:0]const u8 {
            return "{\"@type\":\"ok\"}";
        }
    };

    var client = TdjsonClient.initWithBinding(.{
        .td_create_client_id = MockC.createId,
        .td_send = MockC.sendFn,
        .td_receive = MockC.recvFn,
        .td_execute = MockC.execFn,
    });
    defer client.deinit();

    try std.testing.expectEqual(@as(c_int, 7), client.client_id);
    client.send("{\"@type\":\"getMe\"}");
    try std.testing.expectEqual(@as(c_int, 7), MockC.last_sent_id);
    try std.testing.expectEqualStrings("{\"@type\":\"ok\"}", client.execute("{\"@type\":\"setLogVerbosityLevel\"}").?);
    try std.testing.expectEqualStrings("{\"@type\":\"updateAuthorizationState\"}", client.receive(0.0).?);
}

test "TdjsonClient.receive rejects non-finite or negative timeouts and clamps huge values" {
    const SpyC = struct {
        var calls: usize = 0;
        var last_timeout: f64 = -1.0;

        fn createId() callconv(.c) c_int {
            return 1;
        }
        fn sendFn(_: c_int, _: [*:0]const u8) callconv(.c) void {}
        fn recvFn(t: f64) callconv(.c) ?[*:0]const u8 {
            calls += 1;
            last_timeout = t;
            return "{\"@type\":\"ok\"}";
        }
        fn execFn(_: [*:0]const u8) callconv(.c) ?[*:0]const u8 {
            return null;
        }
    };

    var client = TdjsonClient.initWithBinding(.{
        .td_create_client_id = SpyC.createId,
        .td_send = SpyC.sendFn,
        .td_receive = SpyC.recvFn,
        .td_execute = SpyC.execFn,
    });
    defer client.deinit();

    SpyC.calls = 0;
    try std.testing.expectEqual(@as(?[]const u8, null), client.receive(std.math.nan(f64)));
    try std.testing.expectEqual(@as(?[]const u8, null), client.receive(std.math.inf(f64)));
    try std.testing.expectEqual(@as(?[]const u8, null), client.receive(-std.math.inf(f64)));
    try std.testing.expectEqual(@as(?[]const u8, null), client.receive(-0.001));
    try std.testing.expectEqual(@as(usize, 0), SpyC.calls);

    // -0.0 normalizes to +0.0 and invokes td_receive.
    try std.testing.expect(client.receive(-0.0) != null);
    try std.testing.expectEqual(@as(usize, 1), SpyC.calls);
    try std.testing.expect(!std.math.signbit(SpyC.last_timeout));

    // Huge finite timeouts clamp to max_receive_timeout_seconds.
    try std.testing.expect(client.receive(1e300) != null);
    try std.testing.expectEqual(@as(usize, 2), SpyC.calls);
    try std.testing.expectEqual(TdjsonClient.max_receive_timeout_seconds, SpyC.last_timeout);
}
