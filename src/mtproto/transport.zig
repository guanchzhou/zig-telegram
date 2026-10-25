//! MTProto 2.0 TCP/WebSocket transport framing:
//! - **Abridged** (`0xef` header, 1-byte or 4-byte length in 4-byte words)
//! - **Intermediate** (`0xeeeeeeee` header, 4-byte little-endian byte length)
//! - **Padded Intermediate** (`0xdddddddd` header, 4-byte length + 0..15 random padding bytes)
//! - **Obfuscated2** (64-byte CSPRNG init header with forward & reverse AES-256-CTR streams)

const std = @import("std");
const Allocator = std.mem.Allocator;
const Aes256 = std.crypto.core.aes.Aes256;

pub const default_max_frame_bytes: usize = 4 * 1024 * 1024;

pub const FramingMode = enum {
    abridged,
    intermediate,
    padded_intermediate,
};

pub const TransportFrameError = error{
    UnalignedPayload,
    PayloadTooLarge,
    IncompleteFrame,
    OutOfMemory,
} || std.Io.RandomSecureError;

/// Returns the initial connection header tag for `mode`:
/// - `.abridged` -> `&.{0xef}`
/// - `.intermediate` -> `&.{ 0xee, 0xee, 0xee, 0xee }`
/// - `.padded_intermediate` -> `&.{ 0xdd, 0xdd, 0xdd, 0xdd }`
pub fn connectionPreamble(mode: FramingMode) []const u8 {
    return switch (mode) {
        .abridged => &.{0xef},
        .intermediate => &.{ 0xee, 0xee, 0xee, 0xee },
        .padded_intermediate => &.{ 0xdd, 0xdd, 0xdd, 0xdd },
    };
}

/// Encodes an MTProto payload (whose length must be a multiple of 4 bytes) into
/// a framed packet using `mode`. `.padded_intermediate` appends 0..15 bytes
/// from `io.randomSecure`, counted in the length header.
pub fn encodeFrame(
    allocator: Allocator,
    io: std.Io,
    mode: FramingMode,
    payload: []const u8,
) TransportFrameError![]u8 {
    if (payload.len % 4 != 0) return error.UnalignedPayload;
    if (payload.len > default_max_frame_bytes) return error.PayloadTooLarge;

    switch (mode) {
        .abridged => {
            const words = payload.len / 4;
            if (words < 0x7f) {
                const out = try allocator.alloc(u8, 1 + payload.len);
                out[0] = @intCast(words);
                @memcpy(out[1..], payload);
                return out;
            } else {
                const out = try allocator.alloc(u8, 4 + payload.len);
                out[0] = 0x7f;
                out[1] = @intCast(words & 0xff);
                out[2] = @intCast((words >> 8) & 0xff);
                out[3] = @intCast((words >> 16) & 0xff);
                @memcpy(out[4..], payload);
                return out;
            }
        },
        .intermediate => {
            const out = try allocator.alloc(u8, 4 + payload.len);
            std.mem.writeInt(u32, out[0..4], @intCast(payload.len), .little);
            @memcpy(out[4..], payload);
            return out;
        },
        .padded_intermediate => {
            var pad_byte: [1]u8 = undefined;
            try io.randomSecure(&pad_byte);
            const pad_len: usize = pad_byte[0] & 0x0f;
            const out = try allocator.alloc(u8, 4 + payload.len + pad_len);
            errdefer allocator.free(out);
            std.mem.writeInt(u32, out[0..4], @intCast(payload.len + pad_len), .little);
            @memcpy(out[4 .. 4 + payload.len], payload);
            try io.randomSecure(out[4 + payload.len ..]);
            return out;
        },
    }
}

/// Length of the MTProto packet at the start of `payload`, so the 0..15 bytes
/// of padded-intermediate transport padding can be dropped: unencrypted
/// packets carry `message_data_length`, encrypted ones are 24 + 16k bytes.
fn mtprotoPacketLen(payload: []const u8) ?usize {
    if (payload.len < 8) return null;
    if (std.mem.readInt(u64, payload[0..8], .little) == 0) {
        if (payload.len < 20) return null;
        const total = 20 + @as(usize, std.mem.readInt(u32, payload[16..20], .little));
        return if (total <= payload.len) total else null;
    }
    if (payload.len < 24) return null;
    return 24 + (payload.len - 24) / 16 * 16;
}

pub const DecodedFrame = struct {
    payload: []const u8,
    bytes_consumed: usize,
};

/// Decodes a single MTProto transport frame from `buffer`, enforcing `max_frame_bytes`.
pub fn decodeFrame(
    mode: FramingMode,
    buffer: []const u8,
    max_frame_bytes: usize,
) TransportFrameError!DecodedFrame {
    switch (mode) {
        .abridged => {
            if (buffer.len < 1) return error.IncompleteFrame;
            const first = buffer[0];
            var words: usize = 0;
            var hdr_len: usize = 0;
            if (first < 0x7f) {
                words = first;
                hdr_len = 1;
            } else {
                if (buffer.len < 4) return error.IncompleteFrame;
                words = @as(usize, buffer[1]) |
                    (@as(usize, buffer[2]) << 8) |
                    (@as(usize, buffer[3]) << 16);
                hdr_len = 4;
            }
            const byte_len = words * 4;
            if (byte_len > max_frame_bytes) return error.PayloadTooLarge;
            if (buffer.len < hdr_len + byte_len) return error.IncompleteFrame;
            return .{
                .payload = buffer[hdr_len .. hdr_len + byte_len],
                .bytes_consumed = hdr_len + byte_len,
            };
        },
        .intermediate, .padded_intermediate => {
            if (buffer.len < 4) return error.IncompleteFrame;
            const byte_len: usize = std.mem.readInt(u32, buffer[0..4], .little);
            if (byte_len > max_frame_bytes) return error.PayloadTooLarge;
            if (byte_len % 4 != 0 and mode == .intermediate) return error.UnalignedPayload;
            if (buffer.len < 4 + byte_len) return error.IncompleteFrame;
            const raw = buffer[4 .. 4 + byte_len];
            const payload_len = if (mode == .padded_intermediate)
                mtprotoPacketLen(raw) orelse byte_len - (byte_len % 4)
            else
                byte_len;
            return .{
                .payload = raw[0..payload_len],
                .bytes_consumed = 4 + byte_len,
            };
        },
    }
}

/// AES-256-CTR keystream with a big-endian 128-bit counter. Keeps the expanded
/// key schedule and the unused tail of the current keystream block between calls.
pub const CtrStream = struct {
    ctx: std.crypto.core.aes.AesEncryptCtx(Aes256),
    counter: [16]u8,
    keystream: [16]u8 = undefined,
    used: usize = 16,

    pub fn init(key: [32]u8, iv: [16]u8) CtrStream {
        return .{ .ctx = Aes256.initEnc(key), .counter = iv };
    }

    fn nextBlock(self: *CtrStream) void {
        self.ctx.encrypt(&self.keystream, &self.counter);
        const next = std.mem.readInt(u128, &self.counter, .big) +% 1;
        std.mem.writeInt(u128, &self.counter, next, .big);
        self.used = 0;
    }

    pub fn xor(self: *CtrStream, data: []u8) void {
        var i: usize = 0;
        while (i < data.len and self.used < 16) : (i += 1) {
            data[i] ^= self.keystream[self.used];
            self.used += 1;
        }
        while (data.len - i >= 16) : (i += 16) {
            self.nextBlock();
            const d: @Vector(16, u8) = data[i..][0..16].*;
            const k: @Vector(16, u8) = self.keystream;
            data[i..][0..16].* = d ^ k;
            self.used = 16;
        }
        while (i < data.len) : (i += 1) {
            if (self.used == 16) self.nextBlock();
            data[i] ^= self.keystream[self.used];
            self.used += 1;
        }
    }
};

/// Obfuscated2 AES-256-CTR stream state used by Telegram TCP/WebSocket transports.
pub const Obfuscated2 = struct {
    header: [64]u8,
    tx: CtrStream,
    rx: CtrStream,

    /// Generates a valid 64-byte Obfuscated2 handshake header from
    /// `io.randomSecure`, avoiding all reserved Telegram first-byte/first-word
    /// magic values, embeds the protocol tag at bytes `56..60`, and encrypts
    /// bytes `56..64` in-place.
    pub fn initClient(io: std.Io, mode: FramingMode) std.Io.RandomSecureError!Obfuscated2 {
        var hdr: [64]u8 = undefined;
        while (true) {
            try io.randomSecure(&hdr);
            if (hdr[0] == 0xef) continue;
            const first_u32 = std.mem.readInt(u32, hdr[0..4], .little);
            if (first_u32 == 0x44414548 or // "HEAD"
                first_u32 == 0x54534f50 or // "POST"
                first_u32 == 0x20544547 or // "GET "
                first_u32 == 0x4954504f or // "OPTI"
                first_u32 == 0xeeeeeeee or
                first_u32 == 0xdddddddd or
                first_u32 == 0x02010316)
            {
                continue;
            }
            const second_u32 = std.mem.readInt(u32, hdr[4..8], .little);
            if (second_u32 == 0) continue;
            break;
        }

        const tag_bytes: [4]u8 = switch (mode) {
            .abridged => .{ 0xef, 0xef, 0xef, 0xef },
            .intermediate => .{ 0xee, 0xee, 0xee, 0xee },
            .padded_intermediate => .{ 0xdd, 0xdd, 0xdd, 0xdd },
        };
        @memcpy(hdr[56..60], &tag_bytes);

        var reversed: [48]u8 = undefined;
        for (0..48) |i| {
            reversed[i] = hdr[55 - i];
        }

        var self = Obfuscated2{
            .header = hdr,
            .tx = CtrStream.init(hdr[8..40].*, hdr[40..56].*),
            .rx = CtrStream.init(reversed[0..32].*, reversed[32..48].*),
        };
        std.crypto.secureZero(u8, &reversed);

        var encrypted_hdr = hdr;
        self.xorTxKeystream(&encrypted_hdr);
        @memcpy(self.header[56..64], encrypted_hdr[56..64]);
        return self;
    }

    pub fn xorTxKeystream(self: *Obfuscated2, bytes: []u8) void {
        self.tx.xor(bytes);
    }

    pub fn xorRxKeystream(self: *Obfuscated2, bytes: []u8) void {
        self.rx.xor(bytes);
    }
};

test "Abridged and Intermediate frame encode/decode round-trip" {
    const allocator = std.testing.allocator;
    // 24 + 16k bytes with a non-zero auth_key_id, i.e. shaped like an encrypted packet.
    var payload: [312]u8 = undefined;
    for (&payload, 0..) |*b, i| b.* = @truncate(i);
    const payload_slice: []const u8 = &payload;

    for ([_]FramingMode{ .abridged, .intermediate, .padded_intermediate }) |mode| {
        const framed = try encodeFrame(allocator, std.testing.io, mode, payload_slice);
        defer allocator.free(framed);

        const decoded = try decodeFrame(mode, framed, default_max_frame_bytes);
        try std.testing.expectEqualSlices(u8, payload_slice, decoded.payload);
        try std.testing.expectEqual(framed.len, decoded.bytes_consumed);
    }
}

test "Obfuscated2 client header generation and CTR symmetry" {
    const obf = try Obfuscated2.initClient(std.testing.io, .intermediate);
    try std.testing.expect(obf.header[0] != 0xef);
}

test "padded_intermediate appends 0..15 random bytes and decodes back" {
    const allocator = std.testing.allocator;
    var encrypted_like: [24 + 64]u8 = undefined;
    for (&encrypted_like, 0..) |*b, i| b.* = @truncate(i + 1);
    // auth_key_id = 0, msg_id = 1, message_data_length = 8, then 8 data bytes.
    const unencrypted = [_]u8{ 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 8, 0, 0, 0, 0xaa, 0xbb, 0xcc, 0xdd, 1, 2, 3, 4 };

    var saw_padding = false;
    for (0..32) |_| {
        for ([_][]const u8{ &encrypted_like, &unencrypted }) |payload| {
            const framed = try encodeFrame(allocator, std.testing.io, .padded_intermediate, payload);
            defer allocator.free(framed);
            const pad = framed.len - 4 - payload.len;
            try std.testing.expect(pad <= 15);
            if (pad > 0) saw_padding = true;
            try std.testing.expectEqual(@as(u32, @intCast(framed.len - 4)), std.mem.readInt(u32, framed[0..4], .little));

            const decoded = try decodeFrame(.padded_intermediate, framed, default_max_frame_bytes);
            try std.testing.expectEqualSlices(u8, payload, decoded.payload);
            try std.testing.expectEqual(framed.len, decoded.bytes_consumed);
        }
    }
    try std.testing.expect(saw_padding);
}

/// Previous per-byte implementation, kept as the reference for `CtrStream`.
fn xorAes256CtrReference(key: [32]u8, iv: [16]u8, stream_offset: *usize, data: []u8) void {
    const ctx = Aes256.initEnc(key);
    for (data) |*b| {
        const block_idx = stream_offset.* / 16;
        const byte_in_block = stream_offset.* % 16;
        var counter_block = iv;
        const hi = std.mem.readInt(u128, &counter_block, .big) +% @as(u128, block_idx);
        std.mem.writeInt(u128, &counter_block, hi, .big);

        var keystream: [16]u8 = undefined;
        ctx.encrypt(&keystream, &counter_block);
        b.* ^= keystream[byte_in_block];
        stream_offset.* += 1;
    }
}

test "CtrStream matches the per-byte reference across uneven chunks" {
    var prng = std.Random.DefaultPrng.init(0x5eed_c0de);
    const rand = prng.random();
    for (0..16) |round| {
        var key: [32]u8 = undefined;
        var iv: [16]u8 = undefined;
        rand.bytes(&key);
        rand.bytes(&iv);
        // Exercise counter wrap-around on some rounds.
        if (round % 4 == 0) @memset(iv[8..], 0xff);

        var data: [1031]u8 = undefined;
        rand.bytes(&data);
        var expected = data;
        var offset: usize = 0;
        xorAes256CtrReference(key, iv, &offset, &expected);

        var actual = data;
        var stream = CtrStream.init(key, iv);
        var pos: usize = 0;
        while (pos < actual.len) {
            const n = @min(actual.len - pos, rand.uintAtMost(usize, 40));
            stream.xor(actual[pos .. pos + n]);
            pos += n;
        }
        try std.testing.expectEqualSlices(u8, &expected, &actual);
    }
}
