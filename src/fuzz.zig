//! Fuzz targets for `zig-telegram`.
//!
//! `zig build test` replays every corpus seed in `src/fuzz-corpus/`;
//! `zig build test -Dllvm=true --fuzz=50K` explores further with coverage-guided
//! mutation across:
//! 1. Bot API JSON envelope & discriminated union parsing (`Update`, `MaybeInaccessibleMessage`, `ErrorDetail`)
//! 2. Multipart RFC 7578 header sanitization (`writeEscapedHeaderParam`)
//! 3. MTProto 2.0 Type Language (TL) binary alignment & bounds (`TlReader`)
//! 4. MTProto 2.0 Abridged / Intermediate transport frame decoding (`decodeFrame`)

const std = @import("std");
const Smith = std.testing.Smith;
const json_mod = @import("json.zig");
const multipart_mod = @import("multipart.zig");
const secret_mod = @import("secret.zig");
const bot = @import("bot/root.zig");
const mtproto = @import("mtproto/root.zig");

const json_corpus = [_][]const u8{
    @embedFile("fuzz-corpus/json/00"),
    @embedFile("fuzz-corpus/json/01"),
};

const tl_corpus = [_][]const u8{
    @embedFile("fuzz-corpus/tl/00"),
    @embedFile("fuzz-corpus/tl/01"),
};

const frame_corpus = [_][]const u8{
    @embedFile("fuzz-corpus/frame/00"),
    @embedFile("fuzz-corpus/frame/01"),
};

fn fuzzJsonEnvelope(_: void, smith: *Smith) anyerror!void {
    var buf: [512]u8 = undefined;
    const slice = buf[0..smith.slice(&buf)];

    var arena_state = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    var detail: ?@import("error.zig").ErrorDetail = null;
    defer if (detail) |*d| d.deinit(arena);

    if (json_mod.parseResponseEnvelope(bot.types.Update, arena, 200, slice, &detail)) |*parsed| {
        defer parsed.deinit();
        _ = parsed.value.update_id;
    } else |_| {}

    // Also fuzz SecretToken validator and command parser
    if (secret_mod.SecretToken.initValidated(slice)) |tok| {
        var fmt_buf: [128]u8 = undefined;
        const formatted = try std.fmt.bufPrint(&fmt_buf, "{f}", .{tok});
        try std.testing.expect(std.mem.indexOf(u8, formatted, "[REDACTED]") != null);
    } else |_| {}

    _ = bot.ParsedCommand.parse(slice, "zig_bot");
}

test "fuzz: Bot API JSON envelope, SecretToken redaction, and command parser" {
    try std.testing.fuzz({}, fuzzJsonEnvelope, .{ .corpus = &json_corpus });
}

fn fuzzTlAndMultipart(_: void, smith: *Smith) anyerror!void {
    var buf: [512]u8 = undefined;
    const slice = buf[0..smith.slice(&buf)];

    var reader = mtproto.TlReader.init(slice);
    if (reader.readU32()) |_| {
        _ = reader.readBytes() catch {};
    } else |_| {}

    var out: std.Io.Writer.Allocating = .init(std.testing.allocator);
    defer out.deinit();
    if (multipart_mod.writeEscapedHeaderParam(&out.writer, slice)) {
        for (out.written()) |b| {
            try std.testing.expect(b != '\r' and b != '\n' and b != 0);
        }
    } else |err| {
        try std.testing.expectEqual(error.InvalidMultipartHeader, err);
    }
}

test "fuzz: MTProto TL binary reader and RFC 7578 multipart header escaping" {
    try std.testing.fuzz({}, fuzzTlAndMultipart, .{ .corpus = &tl_corpus });
}

fn fuzzMtprotoFrame(_: void, smith: *Smith) anyerror!void {
    var buf: [512]u8 = undefined;
    const slice = buf[0..smith.slice(&buf)];

    for ([_]mtproto.FramingMode{ .abridged, .intermediate, .padded_intermediate }) |mode| {
        if (mtproto.transport.decodeFrame(mode, slice, 4096)) |dec| {
            try std.testing.expect(dec.bytes_consumed <= slice.len);
            try std.testing.expect(dec.payload.len % 4 == 0);
        } else |_| {}
    }
}

test "fuzz: MTProto transport framing decoder" {
    try std.testing.fuzz({}, fuzzMtprotoFrame, .{ .corpus = &frame_corpus });
}
