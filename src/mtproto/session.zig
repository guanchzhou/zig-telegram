//! MTProto 2.0 encrypted & unencrypted session packet framing (`auth_key_id`,
//! `msg_key`, `salt`, `session_id`, monotonic `msg_id`, `seq_no`, and 12..1024-byte
//! random padding).

const std = @import("std");
const Allocator = std.mem.Allocator;
const crypto = @import("crypto.zig");

pub const SessionError = crypto.CryptoError || error{
    PacketTooShort,
    OutOfMemory,
};

pub const DecryptedMessage = struct {
    salt: u64,
    session_id: u64,
    msg_id: i64,
    seq_no: i32,
    body: []u8,

    pub fn deinit(self: *DecryptedMessage, allocator: Allocator) void {
        allocator.free(self.body);
        self.* = undefined;
    }
};

/// Stateful MTProto 2.0 session tracking `salt`, `session_id`, monotonic
/// `msg_id` (`unix_time * 2^32`), and content-related `seq_no`.
pub const Session = struct {
    auth_key: [256]u8,
    auth_key_id: u64,
    salt: u64,
    session_id: u64,
    last_msg_id: i64 = 0,
    content_related_sent: i32 = 0,

    pub fn init(auth_key: [256]u8, salt: u64, session_id: u64) Session {
        return .{
            .auth_key = auth_key,
            .auth_key_id = crypto.computeAuthKeyId(&auth_key),
            .salt = salt,
            .session_id = session_id,
        };
    }

    /// Generates a strictly increasing client `msg_id` divisible by 4, scaled
    /// to `(unix_seconds << 32) | subsecond_ticks`.
    pub fn nextMsgId(self: *Session, unix_time_ns: i96) i64 {
        const secs: i64 = @intCast(@divFloor(unix_time_ns, std.time.ns_per_s));
        const rem_ns: u64 = @intCast(@mod(unix_time_ns, std.time.ns_per_s));
        const frac: i64 = @intCast((rem_ns << 32) / std.time.ns_per_s);
        var candidate = (secs << 32) | (frac & ~@as(i64, 3));
        if (candidate <= self.last_msg_id) {
            candidate = self.last_msg_id + 4;
        }
        self.last_msg_id = candidate;
        return candidate;
    }

    /// Computes the next `seq_no` (`content_related_sent * 2 + 1` for content-related
    /// messages, or `content_related_sent * 2` for service messages like `msgs_ack`/`ping`).
    pub fn nextSeqNo(self: *Session, is_content_related: bool) i32 {
        const seq = self.content_related_sent * 2 + @as(i32, if (is_content_related) 1 else 0);
        if (is_content_related) {
            self.content_related_sent += 1;
        }
        return seq;
    }

    /// Wraps an unencrypted handshake TL payload (`auth_key_id == 0`):
    /// `[auth_key_id: u64 = 0][msg_id: i64][message_data_length: u32][payload...]`
    pub fn packUnencrypted(
        allocator: Allocator,
        msg_id: i64,
        tl_payload: []const u8,
    ) Allocator.Error![]u8 {
        const out = try allocator.alloc(u8, 20 + tl_payload.len);
        std.mem.writeInt(u64, out[0..8], 0, .little);
        std.mem.writeInt(i64, out[8..16], msg_id, .little);
        std.mem.writeInt(u32, out[16..20], @intCast(tl_payload.len), .little);
        @memcpy(out[20..], tl_payload);
        return out;
    }

    /// Encrypts a TL message body into an MTProto 2.0 packet:
    /// `[auth_key_id: 8B][msg_key: 16B][AES-256-IGE(salt || session_id || msg_id || seq_no || len || body || padding[12..1024])]`
    pub fn encryptMessage(
        self: *Session,
        allocator: Allocator,
        io: std.Io,
        direction: crypto.Direction,
        msg_id: i64,
        seq_no: i32,
        tl_body: []const u8,
    ) SessionError![]u8 {
        const inner_header_len = 32; // salt(8) + session_id(8) + msg_id(8) + seq_no(4) + length(4)
        const unpadded_len = inner_header_len + tl_body.len;
        // MTProto 2.0 requires 12..1024 bytes of random padding and 16-byte alignment.
        var pad_len: usize = 12;
        const rem = (unpadded_len + pad_len) % 16;
        if (rem != 0) {
            pad_len += 16 - rem;
        }

        const padded_len = unpadded_len + pad_len;
        const padded = try allocator.alloc(u8, padded_len);
        defer allocator.free(padded);

        std.mem.writeInt(u64, padded[0..8], self.salt, .little);
        std.mem.writeInt(u64, padded[8..16], self.session_id, .little);
        std.mem.writeInt(i64, padded[16..24], msg_id, .little);
        std.mem.writeInt(i32, padded[24..28], seq_no, .little);
        std.mem.writeInt(u32, padded[28..32], @intCast(tl_body.len), .little);
        @memcpy(padded[32 .. 32 + tl_body.len], tl_body);
        io.random(padded[32 + tl_body.len ..]);

        const msg_key = crypto.computeMsgKey(&self.auth_key, direction, padded);
        const key_iv = crypto.deriveAesKeyIv(&self.auth_key, msg_key, direction);

        const packet = try allocator.alloc(u8, 24 + padded_len);
        errdefer allocator.free(packet);
        std.mem.writeInt(u64, packet[0..8], self.auth_key_id, .little);
        @memcpy(packet[8..24], &msg_key);
        try crypto.aes256IgeEncrypt(key_iv.key, key_iv.iv, padded, packet[24..]);
        return packet;
    }

    /// Decrypts and authenticates an MTProto 2.0 packet in constant time,
    /// validating `auth_key_id`, `msg_key`, and the 12..1024-byte padding invariant.
    pub fn decryptMessage(
        self: *const Session,
        allocator: Allocator,
        direction: crypto.Direction,
        packet: []const u8,
    ) SessionError!DecryptedMessage {
        if (packet.len < 24 + 32 + 12) return error.PacketTooShort;
        const cipher_len = packet.len - 24;
        if (cipher_len % 16 != 0) return error.UnalignedBlockLength;

        const wire_key_id = std.mem.readInt(u64, packet[0..8], .little);
        if (wire_key_id != self.auth_key_id) return error.AuthKeyIdMismatch;

        const wire_msg_key: [16]u8 = packet[8..24].*;
        const key_iv = crypto.deriveAesKeyIv(&self.auth_key, wire_msg_key, direction);

        const padded = try allocator.alloc(u8, cipher_len);
        defer allocator.free(padded);

        try crypto.aes256IgeDecrypt(key_iv.key, key_iv.iv, packet[24..], padded);
        try crypto.verifyMsgKeyConstantTime(&self.auth_key, direction, padded, wire_msg_key);

        const salt = std.mem.readInt(u64, padded[0..8], .little);
        const session_id = std.mem.readInt(u64, padded[8..16], .little);
        const msg_id = std.mem.readInt(i64, padded[16..24], .little);
        const seq_no = std.mem.readInt(i32, padded[24..28], .little);
        const body_len: usize = std.mem.readInt(u32, padded[28..32], .little);

        if (body_len > cipher_len - 32) return error.InvalidPaddingLength;
        const pad_len = cipher_len - 32 - body_len;
        if (pad_len < 12 or pad_len > 1024) return error.InvalidPaddingLength;

        const owned_body = try allocator.dupe(u8, padded[32 .. 32 + body_len]);
        return .{
            .salt = salt,
            .session_id = session_id,
            .msg_id = msg_id,
            .seq_no = seq_no,
            .body = owned_body,
        };
    }
};

test "MTProto 2.0 Session encryptMessage and decryptMessage round-trip" {
    const allocator = std.testing.allocator;
    const io = std.testing.io;

    var auth_key: [256]u8 = undefined;
    for (&auth_key, 0..) |*b, i| b.* = @truncate(i *% 29 +% 7);

    var session = Session.init(auth_key, 0xCAFEBABE11223344, 0x9988776655443322);
    const msg_id = session.nextMsgId(1_729_000_000 * std.time.ns_per_s);
    const seq_no = session.nextSeqNo(true);

    const tl_body = "ping#7abe77ec\x01\x02\x03";
    const packet = try session.encryptMessage(allocator, io, .client_to_server, msg_id, seq_no, tl_body);
    defer allocator.free(packet);

    var dec = try session.decryptMessage(allocator, .client_to_server, packet);
    defer dec.deinit(allocator);

    try std.testing.expectEqual(@as(u64, 0xCAFEBABE11223344), dec.salt);
    try std.testing.expectEqual(@as(u64, 0x9988776655443322), dec.session_id);
    try std.testing.expectEqual(msg_id, dec.msg_id);
    try std.testing.expectEqual(seq_no, dec.seq_no);
    try std.testing.expectEqualSlices(u8, tl_body, dec.body);
}
