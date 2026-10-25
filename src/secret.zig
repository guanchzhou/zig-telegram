//! Secret bot token and webhook secret handling with formatting redaction and
//! constant-time authentication verification.

const std = @import("std");

/// Wraps a raw Telegram Bot API token (`<bot_id>:<secret>`) and prevents
/// accidental leakage through `std.fmt`, logs, or error formatting.
pub const SecretToken = struct {
    raw: []const u8,

    pub const ValidationError = error{
        EmptyToken,
        MissingColonDelimiter,
        InvalidBotId,
        EmptySecretPart,
        ContainsControlOrWhitespace,
        InvalidSecretCharacter,
    };

    /// Wraps a raw token without validating its structure.
    pub fn init(raw: []const u8) SecretToken {
        return .{ .raw = raw };
    }

    /// Validates that `raw` has the structure `<positive_i64_bot_id>:<non_empty_secret>`,
    /// contains no whitespace or ASCII control characters, and that the secret
    /// is limited to `[A-Za-z0-9_-]` so it cannot alter the request URL.
    pub fn initValidated(raw: []const u8) ValidationError!SecretToken {
        if (raw.len == 0) return error.EmptyToken;
        for (raw) |b| {
            if (b <= 0x20 or b == 0x7f) return error.ContainsControlOrWhitespace;
        }
        const colon = std.mem.indexOfScalar(u8, raw, ':') orelse return error.MissingColonDelimiter;
        if (colon == 0) return error.InvalidBotId;
        const id_slice = raw[0..colon];
        const parsed_id = std.fmt.parseInt(i64, id_slice, 10) catch return error.InvalidBotId;
        if (parsed_id <= 0) return error.InvalidBotId;
        const secret_part = raw[colon + 1 ..];
        if (secret_part.len == 0) return error.EmptySecretPart;
        for (secret_part) |c| {
            if (!std.ascii.isAlphanumeric(c) and c != '_' and c != '-') return error.InvalidSecretCharacter;
        }
        return .{ .raw = raw };
    }

    /// Extracts the numeric bot user ID prefix before `:`, if valid.
    pub fn botId(self: SecretToken) ?i64 {
        const colon = std.mem.indexOfScalar(u8, self.raw, ':') orelse return null;
        if (colon == 0) return null;
        return std.fmt.parseInt(i64, self.raw[0..colon], 10) catch null;
    }

    /// Returns the raw token slice. Callers must only pass this to the TLS
    /// request path builder.
    pub fn expose(self: SecretToken) []const u8 {
        return self.raw;
    }

    /// Custom formatter for Zig 0.17 `std.Io.Writer`. Always redacts the secret
    /// portion of the token so `"{f}"` prints `bot<id>:[REDACTED]`.
    pub fn format(self: SecretToken, writer: *std.Io.Writer) std.Io.Writer.Error!void {
        if (std.mem.indexOfScalar(u8, self.raw, ':')) |colon| {
            if (colon > 0 and colon <= 24) {
                var all_digits = true;
                for (self.raw[0..colon]) |c| {
                    if (!std.ascii.isDigit(c)) {
                        all_digits = false;
                        break;
                    }
                }
                if (all_digits) {
                    try writer.print("bot{s}:[REDACTED]", .{self.raw[0..colon]});
                    return;
                }
            }
        }
        try writer.writeAll("bot:[REDACTED]");
    }
};

/// Verifies an incoming `X-Telegram-Bot-Api-Secret-Token` header against the
/// expected secret in constant time. Hashing both inputs with SHA-256 first
/// prevents leaking the expected secret's length via timing side channels.
pub fn verifyWebhookSecretConstantTime(expected: []const u8, candidate: []const u8) bool {
    if (expected.len == 0 or candidate.len == 0) return false;
    var expected_digest: [32]u8 = undefined;
    var candidate_digest: [32]u8 = undefined;
    std.crypto.hash.sha2.Sha256.hash(expected, &expected_digest, .{});
    std.crypto.hash.sha2.Sha256.hash(candidate, &candidate_digest, .{});
    const hashes_equal = std.crypto.timing_safe.eql([32]u8, expected_digest, candidate_digest);
    const lengths_equal = expected.len == candidate.len;
    return hashes_equal and lengths_equal;
}

test "SecretToken validation and redaction" {
    const valid = try SecretToken.initValidated("123456789:AAH_test_secret_token_value");
    try std.testing.expectEqual(@as(?i64, 123456789), valid.botId());

    var buf: [128]u8 = undefined;
    const formatted = try std.fmt.bufPrint(&buf, "{f}", .{valid});
    try std.testing.expectEqualStrings("bot123456789:[REDACTED]", formatted);
    try std.testing.expect(std.mem.indexOf(u8, formatted, "AAH_test") == null);

    try std.testing.expectError(error.EmptyToken, SecretToken.initValidated(""));
    try std.testing.expectError(error.MissingColonDelimiter, SecretToken.initValidated("123456789"));
    try std.testing.expectError(error.InvalidBotId, SecretToken.initValidated("abc:secret"));
    try std.testing.expectError(error.EmptySecretPart, SecretToken.initValidated("123456:"));
    try std.testing.expectError(error.ContainsControlOrWhitespace, SecretToken.initValidated("123:sec ret"));
    try std.testing.expectError(error.InvalidSecretCharacter, SecretToken.initValidated("123:abc/../getMe"));
    try std.testing.expectError(error.InvalidSecretCharacter, SecretToken.initValidated("123:abc?x=1"));
    try std.testing.expectError(error.InvalidSecretCharacter, SecretToken.initValidated("123:abc:def"));
    _ = try SecretToken.initValidated("123:AAH-x_9");
}

test "verifyWebhookSecretConstantTime" {
    try std.testing.expect(verifyWebhookSecretConstantTime("my-webhook-secret-99", "my-webhook-secret-99"));
    try std.testing.expect(!verifyWebhookSecretConstantTime("my-webhook-secret-99", "my-webhook-secret-98"));
    try std.testing.expect(!verifyWebhookSecretConstantTime("my-webhook-secret-99", "short"));
    try std.testing.expect(!verifyWebhookSecretConstantTime("", ""));
}
