//! Structured Telegram error taxonomy and caller-owned `ErrorDetail` sink.
//!
//! Passing `err_out: ?*?ErrorDetail` into any client call captures the HTTP
//! status code, Telegram `description` string, `retry_after` seconds (HTTP 429),
//! and `migrate_to_chat_id` supergroup migration target without mutating shared
//! client state.

const std = @import("std");
const Allocator = std.mem.Allocator;

/// Unified error set returned by Bot API, Transport, and JSON envelope decoding.
pub const TelegramError = error{
    /// HTTP 400 Bad Request
    BadRequest,
    /// HTTP 401 Unauthorized (invalid or revoked bot token)
    Unauthorized,
    /// HTTP 403 Forbidden (bot blocked by user or insufficient chat rights)
    Forbidden,
    /// HTTP 404 Not Found
    NotFound,
    /// HTTP 409 Conflict (e.g. `getUpdates` called while webhook is active, or duplicate poller)
    Conflict,
    /// HTTP 429 Too Many Requests (check `ErrorDetail.retry_after`)
    TooManyRequests,
    /// HTTP 5xx Server Error from Telegram or gateway
    ServerError,
    /// Other non-200 HTTP status or `ok: false` response
    ApiError,
    /// Response exceeded `max_response_bytes`
    ResponseTooLarge,
    /// Underlying network / TLS / connection failure
    TransportError,
    /// Response JSON did not match expected Bot API schema
    MalformedJson,
    /// Invalid multipart filename or field name (contains CR/LF)
    InvalidMultipartHeader,
    /// Requested local file could not be read
    FileReadError,
    /// Local server `file_path` contains `..` or lies outside the configured files directory
    InvalidFilePath,
    /// Bot API method name is not `[A-Za-z0-9]+`
    InvalidMethodName,
    /// Out of memory
    OutOfMemory,
};

/// Optional parameters returned inside a failed Bot API response (`ResponseParameters`).
pub const ErrorParameters = struct {
    /// The group has been migrated to a supergroup with the specified identifier.
    migrate_to_chat_id: ?i64 = null,
    /// In case of exceeding flood control, the number of seconds left to wait
    /// before the request can be repeated.
    retry_after: ?u32 = null,
};

/// Caller-owned diagnostic payload populated when a Bot API request returns
/// `ok: false` or a non-2xx HTTP status.
///
/// Always release `description` with `detail.deinit(allocator)` when non-null.
pub const ErrorDetail = struct {
    /// Telegram `error_code` or HTTP status code.
    error_code: u16,
    /// Duplicated human-readable description owned by the caller's allocator.
    description: []const u8,
    /// Seconds to wait before retrying (populated on HTTP 429 `TooManyRequests`).
    retry_after: ?u32 = null,
    /// Target supergroup chat ID if the group was upgraded.
    migrate_to_chat_id: ?i64 = null,

    pub fn init(
        allocator: Allocator,
        error_code: u16,
        description: []const u8,
        params: ErrorParameters,
    ) Allocator.Error!ErrorDetail {
        const owned_desc = try allocator.dupe(u8, description);
        return .{
            .error_code = error_code,
            .description = owned_desc,
            .retry_after = params.retry_after,
            .migrate_to_chat_id = params.migrate_to_chat_id,
        };
    }

    pub fn deinit(self: *ErrorDetail, allocator: Allocator) void {
        allocator.free(self.description);
        self.* = undefined;
    }

    pub fn format(self: ErrorDetail, writer: *std.Io.Writer) std.Io.Writer.Error!void {
        try writer.print("Telegram API error {d}: {s}", .{ self.error_code, self.description });
        if (self.retry_after) |secs| {
            try writer.print(" (retry_after={d}s)", .{secs});
        }
        if (self.migrate_to_chat_id) |chat_id| {
            try writer.print(" (migrate_to_chat_id={d})", .{chat_id});
        }
    }
};

/// Maps a numeric Telegram `error_code` / HTTP status code to a `TelegramError`.
pub fn errorFromCode(code: u16) TelegramError {
    return switch (code) {
        400 => error.BadRequest,
        401 => error.Unauthorized,
        403 => error.Forbidden,
        404 => error.NotFound,
        409 => error.Conflict,
        429 => error.TooManyRequests,
        500...599 => error.ServerError,
        else => error.ApiError,
    };
}

test "ErrorDetail lifecycle and status mapping" {
    const allocator = std.testing.allocator;
    var detail = try ErrorDetail.init(allocator, 429, "Too Many Requests: retry after 17", .{
        .retry_after = 17,
        .migrate_to_chat_id = -100123456789,
    });
    defer detail.deinit(allocator);

    try std.testing.expectEqual(@as(u16, 429), detail.error_code);
    try std.testing.expectEqual(@as(?u32, 17), detail.retry_after);
    try std.testing.expectEqual(@as(?i64, -100123456789), detail.migrate_to_chat_id);
    try std.testing.expectEqual(error.TooManyRequests, errorFromCode(detail.error_code));

    var buf: [256]u8 = undefined;
    const text = try std.fmt.bufPrint(&buf, "{f}", .{detail});
    try std.testing.expect(std.mem.indexOf(u8, text, "retry_after=17s") != null);
}
