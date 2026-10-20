//! Webhook request authentication (`X-Telegram-Bot-Api-Secret-Token`), bounded
//! payload parsing, and inline webhook reply encoding.
//!
//! Uses constant-time SHA-256 digest comparison (`secret.verifyWebhookSecretConstantTime`)
//! to prevent timing side-channel extraction of the webhook secret token.

const std = @import("std");
const Allocator = std.mem.Allocator;
const secret_mod = @import("../secret.zig");
const json_mod = @import("../json.zig");
const err_mod = @import("../error.zig");
const types = @import("types.zig");

pub const Update = types.Update;
pub const TelegramError = err_mod.TelegramError;

/// Header name sent by Telegram servers when `secret_token` is configured on `setWebhook`.
pub const secret_token_header = "X-Telegram-Bot-Api-Secret-Token";

/// Default maximum webhook request body size (2 MiB).
pub const default_max_webhook_bytes: usize = 2 * 1024 * 1024;

pub const WebhookAuthError = error{
    MissingSecretHeader,
    InvalidSecretToken,
};

/// Constant-time verification of `X-Telegram-Bot-Api-Secret-Token`.
pub fn verifySecretToken(expected_secret: []const u8, provided_header: ?[]const u8) WebhookAuthError!void {
    const candidate = provided_header orelse return error.MissingSecretHeader;
    if (!secret_mod.verifyWebhookSecretConstantTime(expected_secret, candidate)) {
        return error.InvalidSecretToken;
    }
}

/// Searches a list of HTTP headers (case-insensitively) for `X-Telegram-Bot-Api-Secret-Token`
/// and verifies it in constant time against `expected_secret`.
pub fn verifyHeaders(expected_secret: []const u8, headers: []const std.http.Header) WebhookAuthError!void {
    for (headers) |h| {
        if (std.ascii.eqlIgnoreCase(h.name, secret_token_header)) {
            return verifySecretToken(expected_secret, h.value);
        }
    }
    return error.MissingSecretHeader;
}

/// Parses a bounded webhook request body into `std.json.Parsed(Update)`.
///
/// If `expected_secret` is non-null, verifies `provided_secret_header` in
/// constant time before touching the JSON parser.
pub fn parseWebhookUpdate(
    allocator: Allocator,
    body: []const u8,
    expected_secret: ?[]const u8,
    provided_secret_header: ?[]const u8,
    max_bytes: usize,
) (WebhookAuthError || TelegramError)!std.json.Parsed(Update) {
    if (expected_secret) |expected| {
        try verifySecretToken(expected, provided_secret_header);
    }
    if (body.len > max_bytes) return error.ResponseTooLarge;

    return std.json.parseFromSlice(Update, allocator, body, .{
        .ignore_unknown_fields = true,
        .allocate = .alloc_always,
    }) catch |err| switch (err) {
        error.OutOfMemory => error.OutOfMemory,
        else => error.MalformedJson,
    };
}

/// Encodes a Bot API method struct (`methods.SendMessage`, `methods.AnswerCallbackQuery`, etc.)
/// as an inline JSON webhook response body with `"method": "<api_method_name>"`
/// injected at the top level.
///
/// Telegram's webhook server executes the returned JSON method immediately on
/// receipt of the HTTP 200 response without requiring a separate outbound HTTP request.
pub fn encodeWebhookReply(allocator: Allocator, method_params: anytype) Allocator.Error![]u8 {
    const M = @TypeOf(method_params);
    const info = @typeInfo(M);
    if (info != .@"struct" or !@hasDecl(M, "api_method_name")) {
        @compileError("encodeWebhookReply requires a generated bot.methods.<Method> struct");
    }

    var out: std.Io.Writer.Allocating = .init(allocator);
    errdefer out.deinit();
    var jw: std.json.Stringify = .{
        .writer = &out.writer,
        .options = .{ .emit_null_optional_fields = false },
    };

    jw.beginObject() catch return error.OutOfMemory;
    jw.objectField("method") catch return error.OutOfMemory;
    jw.write(M.api_method_name) catch return error.OutOfMemory;

    inline for (info.@"struct".field_names, info.@"struct".field_types) |fname, ftype| {
        const val = @field(method_params, fname);
        if (@typeInfo(ftype) == .optional) {
            if (val) |unwrapped| {
                jw.objectField(fname) catch return error.OutOfMemory;
                jw.write(unwrapped) catch return error.OutOfMemory;
            }
        } else {
            jw.objectField(fname) catch return error.OutOfMemory;
            jw.write(val) catch return error.OutOfMemory;
        }
    }
    jw.endObject() catch return error.OutOfMemory;
    return out.toOwnedSlice();
}

test "parseWebhookUpdate authenticates secret and parses Update" {
    const allocator = std.testing.allocator;
    const payload =
        \\{"update_id":9001,"message":{"message_id":77,"date":1720000000,"chat":{"id":123,"type":"private"},"text":"/start hello"}}
    ;

    try std.testing.expectError(
        error.InvalidSecretToken,
        parseWebhookUpdate(allocator, payload, "correct-secret", "wrong-secret", default_max_webhook_bytes),
    );
    try std.testing.expectError(
        error.MissingSecretHeader,
        parseWebhookUpdate(allocator, payload, "correct-secret", null, default_max_webhook_bytes),
    );

    var parsed = try parseWebhookUpdate(allocator, payload, "correct-secret", "correct-secret", default_max_webhook_bytes);
    defer parsed.deinit();
    try std.testing.expectEqual(@as(i64, 9001), parsed.value.update_id);
    try std.testing.expectEqualStrings("/start hello", parsed.value.message.?.text.?);
}

test "encodeWebhookReply injects method field" {
    const allocator = std.testing.allocator;
    const methods = @import("methods.zig");

    const reply_json = try encodeWebhookReply(allocator, methods.SendMessage{
        .chat_id = .{ .id = 123 },
        .text = "pong",
    });
    defer allocator.free(reply_json);

    try std.testing.expectEqualStrings(
        \\{"method":"sendMessage","chat_id":123,"text":"pong"}
    , reply_json);
}
