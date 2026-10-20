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

    pub fn deinit(self: *TdjsonClient) void {
        if (self.dyn_lib) |*lib| {
            lib.close();
            self.dyn_lib = null;
        }
    }

    /// Asynchronously sends a null-terminated JSON TDLib request to `self.client_id`.
    pub fn send(self: *const TdjsonClient, request_json: [:0]const u8) void {
        self.binding.td_send(self.client_id, request_json.ptr);
    }

    /// Receives the next incoming TDLib JSON event or response, waiting up to
    /// `timeout_seconds`. Returns `null` on timeout.
    pub fn receive(self: *const TdjsonClient, timeout_seconds: f64) ?[]const u8 {
        const ptr = self.binding.td_receive(timeout_seconds) orelse return null;
        return std.mem.span(ptr);
    }

    /// Synchronously executes a TDLib JSON method (such as `getTextEntities` or `setLogVerbosityLevel`).
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
