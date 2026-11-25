//! Webhook request authentication (`X-Telegram-Bot-Api-Secret-Token`), bounded
//! payload parsing, and inline webhook reply encoding.
//!
//! Uses constant-time SHA-256 digest comparison (`secret.verifyWebhookSecretConstantTime`)
//! to prevent timing side-channel extraction of the webhook secret token.

const std = @import("std");
const Allocator = std.mem.Allocator;
const secret_mod = @import("../secret.zig");
const json_mod = @import("../json.zig");
const multipart_mod = @import("../multipart.zig");
const err_mod = @import("../error.zig");
const types = @import("types.zig");

pub const Update = types.Update;
pub const TelegramError = err_mod.TelegramError;

/// Header name sent by Telegram servers when `secret_token` is configured on `setWebhook`.
pub const secret_token_header = "X-Telegram-Bot-Api-Secret-Token";

/// Default maximum webhook request body size (2 MiB).
pub const default_max_webhook_bytes: usize = 2 * 1024 * 1024;

/// Maximum JSON container nesting depth accepted by `parseWebhookUpdate`.
pub const max_webhook_json_depth: usize = 64;

pub const WebhookAuthError = error{
    MissingSecretHeader,
    InvalidSecretToken,
    DuplicateSecretHeader,
};

pub const WebhookReplyError = Allocator.Error || error{
    UnsupportedAttachment,
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
/// Rejects duplicate `X-Telegram-Bot-Api-Secret-Token` headers.
pub fn verifyHeaders(expected_secret: []const u8, headers: []const std.http.Header) WebhookAuthError!void {
    var matched: ?[]const u8 = null;
    for (headers) |h| {
        if (std.ascii.eqlIgnoreCase(h.name, secret_token_header)) {
            if (matched != null) return error.DuplicateSecretHeader;
            matched = h.value;
        }
    }
    return verifySecretToken(expected_secret, matched);
}

fn exceedsMaxJsonDepth(input: []const u8, max_depth: usize) bool {
    var depth: usize = 0;
    var in_string = false;
    var i: usize = 0;
    while (i < input.len) : (i += 1) {
        const c = input[i];
        if (in_string) {
            if (c == '\\') {
                i += 1;
                if (i >= input.len) break;
            } else if (c == '"') {
                in_string = false;
            }
        } else {
            switch (c) {
                '"' => in_string = true,
                '{', '[' => {
                    depth += 1;
                    if (depth > max_depth) return true;
                },
                '}', ']' => {
                    if (depth > 0) depth -= 1;
                },
                else => {},
            }
        }
    }
    return false;
}

/// Parses a bounded webhook request body into `std.json.Parsed(Update)`.
///
/// If `expected_secret` is non-null, verifies `provided_secret_header` in
/// constant time before touching the JSON parser. Enforces `max_bytes` and
/// `max_webhook_json_depth` (64).
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
    if (exceedsMaxJsonDepth(body, max_webhook_json_depth)) return error.MalformedJson;

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
/// Rejects structs containing binary runtime attachments (`.path` or `.bytes`),
/// which cannot be transmitted in an inline JSON webhook response.
pub fn encodeWebhookReply(allocator: Allocator, method_params: anytype) WebhookReplyError![]u8 {
    const M = @TypeOf(method_params);
    const info = @typeInfo(M);
    if (info != .@"struct" or !@hasDecl(M, "api_method_name")) {
        @compileError("encodeWebhookReply requires a generated bot.methods.<Method> struct");
    }
    if (comptime multipart_mod.containsAttachment(M)) {
        if (multipart_mod.hasRuntimeAttachment(method_params)) {
            return error.UnsupportedAttachment;
        }
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

test "verifyHeaders rejects duplicate X-Telegram-Bot-Api-Secret-Token headers" {
    const single = [_]std.http.Header{
        .{ .name = "Content-Type", .value = "application/json" },
        .{ .name = "x-telegram-bot-api-secret-token", .value = "good-secret" },
    };
    try verifyHeaders("good-secret", &single);

    const dup_same = [_]std.http.Header{
        .{ .name = "X-Telegram-Bot-Api-Secret-Token", .value = "good-secret" },
        .{ .name = "x-telegram-bot-api-secret-token", .value = "good-secret" },
    };
    try std.testing.expectError(error.DuplicateSecretHeader, verifyHeaders("good-secret", &dup_same));

    const dup_diff = [_]std.http.Header{
        .{ .name = "X-Telegram-Bot-Api-Secret-Token", .value = "good-secret" },
        .{ .name = "X-Telegram-Bot-Api-Secret-Token", .value = "bad-secret" },
    };
    try std.testing.expectError(error.DuplicateSecretHeader, verifyHeaders("good-secret", &dup_diff));
}

test "parseWebhookUpdate enforces max JSON nesting depth (64)" {
    const allocator = std.testing.allocator;
    // Construct JSON nested 65 levels deep inside an unknown field.
    const prefix = "{\"update_id\":1,\"deep\":";
    const depth = max_webhook_json_depth + 1;
    var buf = try allocator.alloc(u8, prefix.len + depth * 2 + 1);
    defer allocator.free(buf);
    @memcpy(buf[0..prefix.len], prefix);
    @memset(buf[prefix.len .. prefix.len + depth], '[');
    @memset(buf[prefix.len + depth .. prefix.len + depth * 2], ']');
    buf[buf.len - 1] = '}';

    try std.testing.expectError(
        error.MalformedJson,
        parseWebhookUpdate(allocator, buf, null, null, default_max_webhook_bytes),
    );

    // Brackets inside JSON string literals must not trigger depth rejection.
    const string_braces =
        \\{"update_id":2,"message":{"message_id":1,"date":1720000000,"chat":{"id":1,"type":"private"},"text":"{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{"}}
    ;
    var parsed = try parseWebhookUpdate(allocator, string_braces, null, null, default_max_webhook_bytes);
    defer parsed.deinit();
    try std.testing.expectEqual(@as(i64, 2), parsed.value.update_id);
}

test "encodeWebhookReply rejects binary runtime attachments but allows file_id/url" {
    const allocator = std.testing.allocator;
    const methods = @import("methods.zig");

    try std.testing.expectError(
        error.UnsupportedAttachment,
        encodeWebhookReply(allocator, methods.SendPhoto{
            .chat_id = .{ .id = 123 },
            .photo = .{ .path = "/etc/passwd" },
        }),
    );

    try std.testing.expectError(
        error.UnsupportedAttachment,
        encodeWebhookReply(allocator, methods.SendPhoto{
            .chat_id = .{ .id = 123 },
            .photo = .{ .bytes = .{ .filename = "a.png", .data = "PNG" } },
        }),
    );

    // file_id and url are valid in JSON webhook replies.
    const ok_reply = try encodeWebhookReply(allocator, methods.SendPhoto{
        .chat_id = .{ .id = 123 },
        .photo = .{ .file_id = "AgACAgIAAxkBA" },
    });
    defer allocator.free(ok_reply);
    try std.testing.expect(std.mem.indexOf(u8, ok_reply, "\"method\":\"sendPhoto\"") != null);
    try std.testing.expect(std.mem.indexOf(u8, ok_reply, "\"photo\":\"AgACAgIAAxkBA\"") != null);
}
