//! MTProto 2.0 encrypted & unencrypted session packet framing (`auth_key_id`,
//! `msg_key`, `salt`, `session_id`, monotonic `msg_id`, `seq_no`, and 12..1024-byte
//! random padding).

const std = @import("std");
const Allocator = std.mem.Allocator;
const crypto = @import("crypto.zig");

pub const SessionError = crypto.CryptoError || std.Io.RandomSecureError || error{
    PacketTooShort,
    OutOfMemory,
    /// The body passed to `encryptMessage` is not a multiple of 4 bytes.
    UnalignedBody,
    /// `msg_key` mismatch or an inner length / padding violation. All
    /// authentication failures share this error so they cannot be told apart.
    DecryptionFailed,
    SessionIdMismatch,
    /// Wrong `msg_id` parity for the direction.
    InvalidMsgId,
    /// `msg_id` time is more than 30 s ahead of or 300 s behind server time.
    MsgIdOutOfWindow,
    DuplicateMsgId,
};

pub const DecryptedMessage = struct {
    salt: u64,
    session_id: u64,
    msg_id: i64,
    seq_no: i32,
    body: []u8,

    pub fn deinit(self: *DecryptedMessage, allocator: Allocator) void {
        std.crypto.secureZero(u8, self.body);
        allocator.free(self.body);
        self.* = undefined;
    }
};

/// Picks an MTProto 2.0 padding length in 12..1024 that makes
/// `unpadded_len + padding` a multiple of 16, selected by `rand`.
pub fn paddingLength(unpadded_len: usize, rand: u16) usize {
    const min_pad = 12 + (16 - (unpadded_len + 12) % 16) % 16;
    const choices = (1024 - min_pad) / 16 + 1;
    return min_pad + 16 * (rand % choices);
}

/// Stateful MTProto 2.0 session tracking `salt`, `session_id`, monotonic
/// `msg_id` (`unix_time * 2^32`), content-related `seq_no`, the server clock
/// offset, and recently accepted incoming `msg_id`s for replay rejection.
pub const Session = struct {
    auth_key: [256]u8,
    auth_key_id: u64,
    salt: u64,
    session_id: u64,
    last_msg_id: i64 = 0,
    content_related_sent: i32 = 0,
    /// Server time minus local time, in seconds (see `syncServerTime`).
    time_offset_s: i64 = 0,
    recent_msg_ids: [replay_window]i64 = @splat(0),
    recent_count: usize = 0,
    recent_next: usize = 0,

    pub const replay_window = 64;
    pub const max_future_skew_s: i64 = 30;
    pub const max_past_skew_s: i64 = 300;

    pub fn init(auth_key: [256]u8, salt: u64, session_id: u64) Session {
        return .{
            .auth_key = auth_key,
            .auth_key_id = crypto.computeAuthKeyId(&auth_key),
            .salt = salt,
            .session_id = session_id,
        };
    }

    /// Records the server clock (e.g. from a server `msg_id` or
    /// `bad_msg_notification`) relative to the local clock.
    pub fn syncServerTime(self: *Session, server_unix_s: i64, local_unix_s: i64) void {
        self.time_offset_s = server_unix_s - local_unix_s;
    }

    /// Generates a strictly increasing client `msg_id` divisible by 4, scaled
    /// to `(server_seconds << 32) | subsecond_ticks` using `time_offset_s`.
    pub fn nextMsgId(self: *Session, unix_time_ns: i96) i64 {
        const server_ns = unix_time_ns + @as(i96, self.time_offset_s) * std.time.ns_per_s;
        const secs: i64 = @intCast(@divFloor(server_ns, std.time.ns_per_s));
        const rem_ns: u64 = @intCast(@mod(server_ns, std.time.ns_per_s));
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
    /// The padding length and bytes come from `io.randomSecure`.
    pub fn encryptMessage(
        self: *Session,
        allocator: Allocator,
        io: std.Io,
        direction: crypto.Direction,
        msg_id: i64,
        seq_no: i32,
        tl_body: []const u8,
    ) SessionError![]u8 {
        if (tl_body.len % 4 != 0) return error.UnalignedBody;
        const inner_header_len = 32; // salt(8) + session_id(8) + msg_id(8) + seq_no(4) + length(4)
        const unpadded_len = inner_header_len + tl_body.len;
        var rand: [2]u8 = undefined;
        try io.randomSecure(&rand);
        const pad_len = paddingLength(unpadded_len, std.mem.readInt(u16, &rand, .little));

        const padded = try allocator.alloc(u8, unpadded_len + pad_len);
        defer {
            std.crypto.secureZero(u8, padded);
            allocator.free(padded);
        }

        std.mem.writeInt(u64, padded[0..8], self.salt, .little);
        std.mem.writeInt(u64, padded[8..16], self.session_id, .little);
        std.mem.writeInt(i64, padded[16..24], msg_id, .little);
        std.mem.writeInt(i32, padded[24..28], seq_no, .little);
        std.mem.writeInt(u32, padded[28..32], @intCast(tl_body.len), .little);
        @memcpy(padded[32 .. 32 + tl_body.len], tl_body);
        try io.randomSecure(padded[32 + tl_body.len ..]);

        return self.sealPadded(allocator, direction, padded);
    }

    /// Encrypts an already padded inner plaintext (length a multiple of 16).
    fn sealPadded(self: *const Session, allocator: Allocator, direction: crypto.Direction, padded: []const u8) SessionError![]u8 {
        const msg_key = crypto.computeMsgKey(&self.auth_key, direction, padded);
        const key_iv = crypto.deriveAesKeyIv(&self.auth_key, msg_key, direction);

        const packet = try allocator.alloc(u8, 24 + padded.len);
        errdefer allocator.free(packet);
        std.mem.writeInt(u64, packet[0..8], self.auth_key_id, .little);
        @memcpy(packet[8..24], &msg_key);
        try crypto.aes256IgeEncrypt(key_iv.key, key_iv.iv, padded, packet[24..]);
        return packet;
    }

    /// Decrypts and authenticates an MTProto 2.0 packet. Verifies `auth_key_id`,
    /// `msg_key` (constant time), body length alignment, the 12..1024-byte
    /// padding invariant, `session_id`, `msg_id` parity for `direction`, the
    /// `msg_id` time window against `now_unix_s + time_offset_s`, and rejects
    /// `msg_id`s seen in the last `replay_window` accepted messages.
    pub fn decryptMessage(
        self: *Session,
        allocator: Allocator,
        direction: crypto.Direction,
        packet: []const u8,
        now_unix_s: i64,
    ) SessionError!DecryptedMessage {
        if (packet.len < 24 + 32 + 12) return error.PacketTooShort;
        const cipher_len = packet.len - 24;
        if (cipher_len % 16 != 0) return error.UnalignedBlockLength;

        const wire_key_id = std.mem.readInt(u64, packet[0..8], .little);
        if (wire_key_id != self.auth_key_id) return error.AuthKeyIdMismatch;

        const wire_msg_key: [16]u8 = packet[8..24].*;
        const key_iv = crypto.deriveAesKeyIv(&self.auth_key, wire_msg_key, direction);

        const padded = try allocator.alloc(u8, cipher_len);
        defer {
            std.crypto.secureZero(u8, padded);
            allocator.free(padded);
        }

        crypto.aes256IgeDecrypt(key_iv.key, key_iv.iv, packet[24..], padded) catch return error.DecryptionFailed;
        crypto.verifyMsgKeyConstantTime(&self.auth_key, direction, padded, wire_msg_key) catch return error.DecryptionFailed;

        const salt = std.mem.readInt(u64, padded[0..8], .little);
        const session_id = std.mem.readInt(u64, padded[8..16], .little);
        const msg_id = std.mem.readInt(i64, padded[16..24], .little);
        const seq_no = std.mem.readInt(i32, padded[24..28], .little);
        const body_len: usize = std.mem.readInt(u32, padded[28..32], .little);

        if (body_len % 4 != 0 or body_len > cipher_len - 32) return error.DecryptionFailed;
        const pad_len = cipher_len - 32 - body_len;
        if (pad_len < 12 or pad_len > 1024) return error.DecryptionFailed;

        if (session_id != self.session_id) return error.SessionIdMismatch;
        try self.checkMsgId(direction, msg_id, now_unix_s);

        const owned_body = try allocator.dupe(u8, padded[32 .. 32 + body_len]);
        self.rememberMsgId(msg_id);
        return .{
            .salt = salt,
            .session_id = session_id,
            .msg_id = msg_id,
            .seq_no = seq_no,
            .body = owned_body,
        };
    }

    fn checkMsgId(self: *const Session, direction: crypto.Direction, msg_id: i64, now_unix_s: i64) SessionError!void {
        const parity = msg_id & 3;
        const parity_ok = switch (direction) {
            .server_to_client => parity == 1 or parity == 3,
            .client_to_server => parity == 0,
        };
        if (!parity_ok) return error.InvalidMsgId;

        const msg_s = msg_id >> 32;
        const server_now = now_unix_s +| self.time_offset_s;
        if (msg_s -| server_now > max_future_skew_s or server_now -| msg_s > max_past_skew_s) {
            return error.MsgIdOutOfWindow;
        }
        for (self.recent_msg_ids[0..self.recent_count]) |seen| {
            if (seen == msg_id) return error.DuplicateMsgId;
        }
    }

    fn rememberMsgId(self: *Session, msg_id: i64) void {
        self.recent_msg_ids[self.recent_next] = msg_id;
        self.recent_next = (self.recent_next + 1) % replay_window;
        if (self.recent_count < replay_window) self.recent_count += 1;
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

    var dec = try session.decryptMessage(allocator, .client_to_server, packet, 1_729_000_000);
    defer dec.deinit(allocator);

    try std.testing.expectEqual(@as(u64, 0xCAFEBABE11223344), dec.salt);
    try std.testing.expectEqual(@as(u64, 0x9988776655443322), dec.session_id);
    try std.testing.expectEqual(msg_id, dec.msg_id);
    try std.testing.expectEqual(seq_no, dec.seq_no);
    try std.testing.expectEqualSlices(u8, tl_body, dec.body);
}

const test_now: i64 = 1_729_000_000;

fn testAuthKey() [256]u8 {
    var auth_key: [256]u8 = undefined;
    for (&auth_key, 0..) |*b, i| b.* = @truncate(i *% 29 +% 7);
    return auth_key;
}

/// Builds an inner plaintext with explicit `body_len` and padding length.
fn craftPadded(allocator: Allocator, s: *const Session, msg_id: i64, body_len_field: u32, body: []const u8, pad_len: usize) ![]u8 {
    const padded = try allocator.alloc(u8, 32 + body.len + pad_len);
    std.mem.writeInt(u64, padded[0..8], s.salt, .little);
    std.mem.writeInt(u64, padded[8..16], s.session_id, .little);
    std.mem.writeInt(i64, padded[16..24], msg_id, .little);
    std.mem.writeInt(i32, padded[24..28], 1, .little);
    std.mem.writeInt(u32, padded[28..32], body_len_field, .little);
    @memcpy(padded[32 .. 32 + body.len], body);
    @memset(padded[32 + body.len ..], 0xAB);
    return padded;
}

test "decryptMessage rejects session_id mismatch" {
    const allocator = std.testing.allocator;
    var sender = Session.init(testAuthKey(), 1, 0x1111);
    var receiver = Session.init(testAuthKey(), 1, 0x2222);
    const msg_id = sender.nextMsgId(test_now * std.time.ns_per_s);
    const packet = try sender.encryptMessage(allocator, std.testing.io, .client_to_server, msg_id, 1, "abcd");
    defer allocator.free(packet);
    try std.testing.expectError(error.SessionIdMismatch, receiver.decryptMessage(allocator, .client_to_server, packet, test_now));
}

test "decryptMessage rejects misaligned body length" {
    const allocator = std.testing.allocator;
    var s = Session.init(testAuthKey(), 1, 2);
    const msg_id = s.nextMsgId(test_now * std.time.ns_per_s);
    // 32 + 16 + 16 = 64; body_len field 13 leaves 19 bytes of padding but is not 4-aligned.
    const padded = try craftPadded(allocator, &s, msg_id, 13, &(@as([16]u8, @splat(1))), 16);
    defer allocator.free(padded);
    const packet = try s.sealPadded(allocator, .client_to_server, padded);
    defer allocator.free(packet);
    try std.testing.expectError(error.DecryptionFailed, s.decryptMessage(allocator, .client_to_server, packet, test_now));
}

test "decryptMessage rejects padding longer than 1024 bytes" {
    const allocator = std.testing.allocator;
    var s = Session.init(testAuthKey(), 1, 2);
    const msg_id = s.nextMsgId(test_now * std.time.ns_per_s);
    // 32 + 16 + 1040 = 1088 = 68 blocks.
    const padded = try craftPadded(allocator, &s, msg_id, 16, &(@as([16]u8, @splat(1))), 1040);
    defer allocator.free(padded);
    const packet = try s.sealPadded(allocator, .client_to_server, padded);
    defer allocator.free(packet);
    try std.testing.expectError(error.DecryptionFailed, s.decryptMessage(allocator, .client_to_server, packet, test_now));
}

test "decryptMessage rejects a tampered msg_key with the same error" {
    const allocator = std.testing.allocator;
    var s = Session.init(testAuthKey(), 1, 2);
    const msg_id = s.nextMsgId(test_now * std.time.ns_per_s);
    const packet = try s.encryptMessage(allocator, std.testing.io, .client_to_server, msg_id, 1, "abcd");
    defer allocator.free(packet);
    packet[8] ^= 0x01;
    try std.testing.expectError(error.DecryptionFailed, s.decryptMessage(allocator, .client_to_server, packet, test_now));
}

test "decryptMessage rejects duplicate msg_id" {
    const allocator = std.testing.allocator;
    var s = Session.init(testAuthKey(), 1, 2);
    const msg_id = s.nextMsgId(test_now * std.time.ns_per_s);
    const first = try s.encryptMessage(allocator, std.testing.io, .client_to_server, msg_id, 1, "abcd");
    defer allocator.free(first);
    const replay = try s.encryptMessage(allocator, std.testing.io, .client_to_server, msg_id, 1, "abcd");
    defer allocator.free(replay);

    var dec = try s.decryptMessage(allocator, .client_to_server, first, test_now);
    dec.deinit(allocator);
    try std.testing.expectError(error.DuplicateMsgId, s.decryptMessage(allocator, .client_to_server, replay, test_now));
}

test "decryptMessage enforces server msg_id parity" {
    const allocator = std.testing.allocator;
    var s = Session.init(testAuthKey(), 1, 2);
    const base: i64 = test_now << 32;

    const even = try s.encryptMessage(allocator, std.testing.io, .server_to_client, base | 4, 1, "abcd");
    defer allocator.free(even);
    try std.testing.expectError(error.InvalidMsgId, s.decryptMessage(allocator, .server_to_client, even, test_now));

    const odd = try s.encryptMessage(allocator, std.testing.io, .server_to_client, base | 5, 1, "abcd");
    defer allocator.free(odd);
    var dec = try s.decryptMessage(allocator, .server_to_client, odd, test_now);
    dec.deinit(allocator);
}

test "decryptMessage enforces the msg_id time window with server offset" {
    const allocator = std.testing.allocator;
    var s = Session.init(testAuthKey(), 1, 2);

    const stale = try s.encryptMessage(allocator, std.testing.io, .server_to_client, ((test_now - 301) << 32) | 1, 1, "abcd");
    defer allocator.free(stale);
    try std.testing.expectError(error.MsgIdOutOfWindow, s.decryptMessage(allocator, .server_to_client, stale, test_now));

    const future = try s.encryptMessage(allocator, std.testing.io, .server_to_client, ((test_now + 31) << 32) | 1, 1, "abcd");
    defer allocator.free(future);
    try std.testing.expectError(error.MsgIdOutOfWindow, s.decryptMessage(allocator, .server_to_client, future, test_now));

    s.syncServerTime(test_now + 31, test_now);
    var dec = try s.decryptMessage(allocator, .server_to_client, future, test_now);
    dec.deinit(allocator);
}

test "paddingLength stays within 12..1024 and aligns to 16" {
    var unpadded: usize = 32;
    while (unpadded < 32 + 64) : (unpadded += 4) {
        var r: u32 = 0;
        while (r <= std.math.maxInt(u16)) : (r += 251) {
            const pad = paddingLength(unpadded, @intCast(r));
            try std.testing.expect(pad >= 12 and pad <= 1024);
            try std.testing.expectEqual(@as(usize, 0), (unpadded + pad) % 16);
        }
        try std.testing.expect(paddingLength(unpadded, std.math.maxInt(u16)) <= 1024);
    }
}

test "encryptMessage uses varying padding lengths" {
    const allocator = std.testing.allocator;
    var s = Session.init(testAuthKey(), 1, 2);
    var lengths: [8]usize = undefined;
    for (&lengths) |*len| {
        const packet = try s.encryptMessage(allocator, std.testing.io, .client_to_server, 4, 1, "abcd");
        defer allocator.free(packet);
        len.* = packet.len;
        try std.testing.expect(packet.len >= 24 + 32 + 4 + 12 and packet.len <= 24 + 32 + 4 + 1024 + 15);
    }
    var all_same = true;
    for (lengths[1..]) |len| all_same = all_same and len == lengths[0];
    try std.testing.expect(!all_same);
}

test "encryptMessage rejects a body that is not 4-byte aligned" {
    var s = Session.init(testAuthKey(), 1, 2);
    try std.testing.expectError(error.UnalignedBody, s.encryptMessage(std.testing.allocator, std.testing.io, .client_to_server, 4, 1, "abc"));
}
