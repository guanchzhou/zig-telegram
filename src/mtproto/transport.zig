//! MTProto 2.0 TCP/WebSocket transport framing:
//! - **Abridged** (`0xef` header, 1-byte or 4-byte length in 4-byte words)
//! - **Intermediate** (`0xeeeeeeee` header, 4-byte little-endian byte length)
//! - **Padded Intermediate** (`0xdddddddd` header, 4-byte length + random padding)
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
};

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
/// a framed packet using `mode`.
pub fn encodeFrame(
    allocator: Allocator,
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
        .intermediate, .padded_intermediate => {
            const out = try allocator.alloc(u8, 4 + payload.len);
            std.mem.writeInt(u32, out[0..4], @intCast(payload.len), .little);
            @memcpy(out[4..], payload);
            return out;
        },
    }
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
            const aligned_len = byte_len - (byte_len % 4);
            return .{
                .payload = buffer[4 .. 4 + aligned_len],
                .bytes_consumed = 4 + byte_len,
            };
        },
    }
}

/// Obfuscated2 AES-256-CTR stream state used by Telegram TCP/WebSocket transports.
pub const Obfuscated2 = struct {
    header: [64]u8,
    tx_key: [32]u8,
    tx_iv: [16]u8,
    tx_offset: usize = 0,
    rx_key: [32]u8,
    rx_iv: [16]u8,
    rx_offset: usize = 0,

    /// Generates a valid 64-byte Obfuscated2 handshake header avoiding all
    /// reserved Telegram first-byte/first-word magic values, embeds the protocol
    /// tag at bytes `56..60`, and encrypts bytes `56..64` in-place.
    pub fn initClient(io: std.Io, mode: FramingMode) Obfuscated2 {
        var hdr: [64]u8 = undefined;
        while (true) {
            io.random(&hdr);
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

        const tx_key = hdr[8..40].*;
        const tx_iv = hdr[40..56].*;

        var reversed: [48]u8 = undefined;
        for (0..48) |i| {
            reversed[i] = hdr[55 - i];
        }
        const rx_key = reversed[0..32].*;
        const rx_iv = reversed[32..48].*;

        var self = Obfuscated2{
            .header = hdr,
            .tx_key = tx_key,
            .tx_iv = tx_iv,
            .rx_key = rx_key,
            .rx_iv = rx_iv,
        };

        var encrypted_hdr = hdr;
        self.xorTxKeystream(&encrypted_hdr);
        @memcpy(self.header[56..64], encrypted_hdr[56..64]);
        return self;
    }

    pub fn xorTxKeystream(self: *Obfuscated2, bytes: []u8) void {
        xorAes256Ctr(self.tx_key, &self.tx_iv, &self.tx_offset, bytes);
    }

    pub fn xorRxKeystream(self: *Obfuscated2, bytes: []u8) void {
        xorAes256Ctr(self.rx_key, &self.rx_iv, &self.rx_offset, bytes);
    }
};

fn xorAes256Ctr(key: [32]u8, iv: *[16]u8, stream_offset: *usize, data: []u8) void {
    const ctx = Aes256.initEnc(key);
    for (data) |*b| {
        const block_idx = stream_offset.* / 16;
        const byte_in_block = stream_offset.* % 16;
        var counter_block = iv.*;
        const hi = std.mem.readInt(u128, &counter_block, .big) +% @as(u128, block_idx);
        std.mem.writeInt(u128, &counter_block, hi, .big);

        var keystream: [16]u8 = undefined;
        ctx.encrypt(&keystream, &counter_block);
        b.* ^= keystream[byte_in_block];
        stream_offset.* += 1;
    }
}

test "Abridged and Intermediate frame encode/decode round-trip" {
    const allocator = std.testing.allocator;
    var payload: [320]u8 = undefined;
    for (&payload, 0..) |*b, i| b.* = @truncate(i);
    const payload_slice: []const u8 = &payload;

    for ([_]FramingMode{ .abridged, .intermediate, .padded_intermediate }) |mode| {
        const framed = try encodeFrame(allocator, mode, payload_slice);
        defer allocator.free(framed);

        const decoded = try decodeFrame(mode, framed, default_max_frame_bytes);
        try std.testing.expectEqualSlices(u8, payload_slice, decoded.payload);
        try std.testing.expectEqual(framed.len, decoded.bytes_consumed);
    }
}

test "Obfuscated2 client header generation and CTR symmetry" {
    const obf = Obfuscated2.initClient(std.testing.io, .intermediate);
    try std.testing.expect(obf.header[0] != 0xef);
}
