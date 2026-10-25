//! MTProto 2.0 Type Language (TL) binary serializer and bounded zero-copy decoder.
//!
//! Implements the canonical Telegram TL binary wire format:
//! - 32-bit little-endian constructor CRC32 tags (`#xxxxxxxx`)
//! - `int` (`i32`), `long` (`i64`), `int128` (`[16]u8`), `int256` (`[32]u8`), `double` (`f64`)
//! - Boxed booleans (`boolTrue#997275b5`, `boolFalse#bc799737`)
//! - 4-byte-aligned TL strings/bytes:
//!   - Short (`len < 254`): `[len_u8][bytes...][0..3 zero padding]`
//!   - Long (`254 <= len < 2^24`): `[0xfe][len_u24_le][bytes...][0..3 zero padding]`
//! - Generic `vector#1cb5c415` containers and optional flag bitmasks

const std = @import("std");
const Allocator = std.mem.Allocator;

pub const vector_constructor_id: u32 = 0x1cb5c415;
pub const bool_true_id: u32 = 0x997275b5;
pub const bool_false_id: u32 = 0xbc799737;
pub const rpc_result_id: u32 = 0xf35c6d01;
pub const rpc_error_id: u32 = 0x2144ca19;
pub const msg_container_id: u32 = 0x73f1f8dc;
pub const ping_id: u32 = 0x7abe77ec;
pub const pong_id: u32 = 0x347773c5;
pub const req_pq_multi_id: u32 = 0xbe7e8ef1;
pub const res_pq_id: u32 = 0x05162463;

pub const TlError = error{
    UnexpectedEof,
    UnalignedPadding,
    NonZeroPadding,
    InvalidBoolConstructor,
    InvalidVectorConstructor,
    StringTooLarge,
    VectorTooLarge,
    OutOfMemory,
};

/// Computes the standard IEEE 802.3 CRC32 of a canonical TL combinator declaration
/// (with `#hex` stripped and whitespace normalized), matching Telegram's TL constructor IDs.
pub fn computeConstructorId(combinator_decl: []const u8) u32 {
    return std.hash.Crc32.hash(combinator_decl);
}

/// Appends 4-byte-aligned TL primitives and byte strings to an `std.ArrayList(u8)`.
pub const TlWriter = struct {
    allocator: Allocator,
    buf: std.ArrayList(u8) = .empty,

    pub fn init(allocator: Allocator) TlWriter {
        return .{ .allocator = allocator };
    }

    pub fn deinit(self: *TlWriter) void {
        self.buf.deinit(self.allocator);
    }

    pub fn written(self: *const TlWriter) []const u8 {
        return self.buf.items;
    }

    pub fn toOwnedSlice(self: *TlWriter) Allocator.Error![]u8 {
        return self.buf.toOwnedSlice(self.allocator);
    }

    pub fn writeU32(self: *TlWriter, val: u32) Allocator.Error!void {
        var bytes: [4]u8 = undefined;
        std.mem.writeInt(u32, &bytes, val, .little);
        try self.buf.appendSlice(self.allocator, &bytes);
    }

    pub fn writeI32(self: *TlWriter, val: i32) Allocator.Error!void {
        var bytes: [4]u8 = undefined;
        std.mem.writeInt(i32, &bytes, val, .little);
        try self.buf.appendSlice(self.allocator, &bytes);
    }

    pub fn writeU64(self: *TlWriter, val: u64) Allocator.Error!void {
        var bytes: [8]u8 = undefined;
        std.mem.writeInt(u64, &bytes, val, .little);
        try self.buf.appendSlice(self.allocator, &bytes);
    }

    pub fn writeI64(self: *TlWriter, val: i64) Allocator.Error!void {
        var bytes: [8]u8 = undefined;
        std.mem.writeInt(i64, &bytes, val, .little);
        try self.buf.appendSlice(self.allocator, &bytes);
    }

    pub fn writeDouble(self: *TlWriter, val: f64) Allocator.Error!void {
        try self.writeU64(@bitCast(val));
    }

    pub fn writeInt128(self: *TlWriter, val: [16]u8) Allocator.Error!void {
        try self.buf.appendSlice(self.allocator, &val);
    }

    pub fn writeInt256(self: *TlWriter, val: [32]u8) Allocator.Error!void {
        try self.buf.appendSlice(self.allocator, &val);
    }

    pub fn writeBool(self: *TlWriter, val: bool) Allocator.Error!void {
        try self.writeU32(if (val) bool_true_id else bool_false_id);
    }

    /// Writes a 4-byte-aligned TL `bytes` / `string` value.
    pub fn writeBytes(self: *TlWriter, data: []const u8) TlError!void {
        if (data.len >= (1 << 24)) return error.StringTooLarge;

        var header_len: usize = 0;
        if (data.len < 254) {
            try self.buf.append(self.allocator, @intCast(data.len));
            header_len = 1;
        } else {
            var hdr: [4]u8 = .{
                0xfe,
                @intCast(data.len & 0xff),
                @intCast((data.len >> 8) & 0xff),
                @intCast((data.len >> 16) & 0xff),
            };
            try self.buf.appendSlice(self.allocator, &hdr);
            header_len = 4;
        }

        try self.buf.appendSlice(self.allocator, data);
        const total = header_len + data.len;
        const pad = (4 - (total % 4)) % 4;
        var zeros: [3]u8 = @splat(0);
        if (pad > 0) {
            try self.buf.appendSlice(self.allocator, zeros[0..pad]);
        }
    }

    /// Writes a boxed `vector#1cb5c415` header followed by `count`.
    pub fn beginVector(self: *TlWriter, count: u32) Allocator.Error!void {
        try self.writeU32(vector_constructor_id);
        try self.writeU32(count);
    }
};

/// Bounded zero-copy reader for TL binary payloads.
pub const TlReader = struct {
    buf: []const u8,
    pos: usize = 0,

    pub fn init(buf: []const u8) TlReader {
        return .{ .buf = buf };
    }

    pub fn remaining(self: *const TlReader) usize {
        return self.buf.len - self.pos;
    }

    pub fn readU32(self: *TlReader) TlError!u32 {
        if (self.remaining() < 4) return error.UnexpectedEof;
        const v = std.mem.readInt(u32, self.buf[self.pos..][0..4], .little);
        self.pos += 4;
        return v;
    }

    pub fn readI32(self: *TlReader) TlError!i32 {
        if (self.remaining() < 4) return error.UnexpectedEof;
        const v = std.mem.readInt(i32, self.buf[self.pos..][0..4], .little);
        self.pos += 4;
        return v;
    }

    pub fn readU64(self: *TlReader) TlError!u64 {
        if (self.remaining() < 8) return error.UnexpectedEof;
        const v = std.mem.readInt(u64, self.buf[self.pos..][0..8], .little);
        self.pos += 8;
        return v;
    }

    pub fn readI64(self: *TlReader) TlError!i64 {
        if (self.remaining() < 8) return error.UnexpectedEof;
        const v = std.mem.readInt(i64, self.buf[self.pos..][0..8], .little);
        self.pos += 8;
        return v;
    }

    pub fn readDouble(self: *TlReader) TlError!f64 {
        return @bitCast(try self.readU64());
    }

    pub fn readInt128(self: *TlReader) TlError![16]u8 {
        if (self.remaining() < 16) return error.UnexpectedEof;
        var out: [16]u8 = undefined;
        @memcpy(&out, self.buf[self.pos..][0..16]);
        self.pos += 16;
        return out;
    }

    pub fn readInt256(self: *TlReader) TlError![32]u8 {
        if (self.remaining() < 32) return error.UnexpectedEof;
        var out: [32]u8 = undefined;
        @memcpy(&out, self.buf[self.pos..][0..32]);
        self.pos += 32;
        return out;
    }

    pub fn readBool(self: *TlReader) TlError!bool {
        const tag = try self.readU32();
        return switch (tag) {
            bool_true_id => true,
            bool_false_id => false,
            else => error.InvalidBoolConstructor,
        };
    }

    /// Reads a 4-byte-aligned TL `bytes` / `string` slice directly from `self.buf`
    /// without allocating, verifying that padding bytes are zero.
    pub fn readBytes(self: *TlReader) TlError![]const u8 {
        if (self.remaining() < 1) return error.UnexpectedEof;
        const first = self.buf[self.pos];
        var len: usize = 0;
        var header_len: usize = 0;
        if (first < 254) {
            len = first;
            header_len = 1;
        } else if (first == 254) {
            if (self.remaining() < 4) return error.UnexpectedEof;
            len = @as(usize, self.buf[self.pos + 1]) |
                (@as(usize, self.buf[self.pos + 2]) << 8) |
                (@as(usize, self.buf[self.pos + 3]) << 16);
            header_len = 4;
        } else {
            return error.StringTooLarge;
        }

        const total = header_len + len;
        const pad = (4 - (total % 4)) % 4;
        const aligned_total = total + pad;
        if (self.remaining() < aligned_total) return error.UnexpectedEof;

        const slice = self.buf[self.pos + header_len .. self.pos + header_len + len];
        const pad_slice = self.buf[self.pos + total .. self.pos + aligned_total];
        for (pad_slice) |b| {
            if (b != 0) return error.NonZeroPadding;
        }

        self.pos += aligned_total;
        return slice;
    }

    pub fn beginVector(self: *TlReader) TlError!u32 {
        const tag = try self.readU32();
        if (tag != vector_constructor_id) return error.InvalidVectorConstructor;
        return self.readU32();
    }

    /// Like `beginVector`, but rejects counts whose elements could not fit in
    /// the remaining input given each element occupies at least
    /// `min_elem_size` bytes. Use before allocating `count` elements.
    pub fn readVectorLen(self: *TlReader, min_elem_size: usize) TlError!u32 {
        const count = try self.beginVector();
        const needed = std.math.mul(usize, count, min_elem_size) catch return error.VectorTooLarge;
        if (needed > self.remaining()) return error.VectorTooLarge;
        return count;
    }
};

test "TL binary short and long string alignment and primitives round-trip" {
    const allocator = std.testing.allocator;
    var w = TlWriter.init(allocator);
    defer w.deinit();

    try w.writeU32(ping_id);
    try w.writeI64(0x1122334455667788);
    try w.writeBool(true);
    try w.writeBytes("hello");

    var long_data: [300]u8 = undefined;
    for (&long_data, 0..) |*b, i| b.* = @truncate(i);
    try w.writeBytes(&long_data);

    var r = TlReader.init(w.written());
    try std.testing.expectEqual(ping_id, try r.readU32());
    try std.testing.expectEqual(@as(i64, 0x1122334455667788), try r.readI64());
    try std.testing.expectEqual(true, try r.readBool());
    try std.testing.expectEqualStrings("hello", try r.readBytes());
    try std.testing.expectEqualSlices(u8, &long_data, try r.readBytes());
    try std.testing.expectEqual(@as(usize, 0), r.remaining());
}

test "readVectorLen rejects counts larger than the remaining input" {
    const allocator = std.testing.allocator;
    var w = TlWriter.init(allocator);
    defer w.deinit();
    try w.beginVector(2);
    try w.writeI64(1);
    try w.writeI64(2);

    var ok = TlReader.init(w.written());
    try std.testing.expectEqual(@as(u32, 2), try ok.readVectorLen(8));

    var too_wide = TlReader.init(w.written());
    try std.testing.expectError(error.VectorTooLarge, too_wide.readVectorLen(9));

    var hdr = TlWriter.init(allocator);
    defer hdr.deinit();
    try hdr.beginVector(std.math.maxInt(u32));
    var huge = TlReader.init(hdr.written());
    try std.testing.expectError(error.VectorTooLarge, huge.readVectorLen(4));
}
