//! Recursive comptime/runtime `attach://` multipart engine and RFC 7578
//! `multipart/form-data` encoder.
//!
//! Unlike existing Zig Telegram clients that only inspect top-level `Method`
//! fields for `InputFile` (silently dropping nested media in `sendMediaGroup`,
//! `sendPaidMedia`, `editMessageMedia`, `sendPoll`, and `sendRichMessage`),
//! `zig-telegram` walks structs, optionals, slices, and tagged unions both at
//! comptime (`containsAttachment`) and runtime (`hasRuntimeAttachment`).
//!
//! When any nested `InputFile` is `.path` or `.bytes`, the serializer emits
//! `"attach://part_<index>"` inside the JSON field and appends the binary file
//! part with matching `name="part_<index>"` to the multipart body.

const std = @import("std");
const Allocator = std.mem.Allocator;
const json_mod = @import("json.zig");
const InputFile = json_mod.InputFile;
const TelegramError = @import("error.zig").TelegramError;

/// Comptime check returning `true` if `T` or any nested field, slice element,
/// or union variant can hold an `InputFile`.
pub fn containsAttachment(comptime T: type) bool {
    @setEvalBranchQuota(100_000);
    return containsAttachmentVisited(T, &.{});
}

fn containsAttachmentVisited(comptime T: type, comptime visited: []const type) bool {
    if (T == InputFile) return true;
    if (T == []const u8 or T == []u8) return false;
    inline for (visited) |V| {
        if (V == T) return false;
    }
    const next_visited = visited ++ &[_]type{T};

    return switch (@typeInfo(T)) {
        .optional => |opt| containsAttachmentVisited(opt.child, next_visited),
        .pointer => |ptr| switch (ptr.size) {
            .one, .slice => containsAttachmentVisited(ptr.child, next_visited),
            else => false,
        },
        .array => |arr| containsAttachmentVisited(arr.child, next_visited),
        .@"struct" => |st| blk: {
            inline for (st.field_types) |ftype| {
                if (containsAttachmentVisited(ftype, next_visited)) break :blk true;
            }
            break :blk false;
        },
        .@"union" => |un| blk: {
            inline for (un.field_types) |ftype| {
                if (ftype != void and containsAttachmentVisited(ftype, next_visited)) break :blk true;
            }
            break :blk false;
        },
        else => false,
    };
}

/// Runtime check returning `true` if `value` currently holds at least one
/// `.path` or `.bytes` `InputFile` anywhere in its tree.
pub fn hasRuntimeAttachment(value: anytype) bool {
    const T = @TypeOf(value);
    if (!comptime containsAttachment(T)) return false;
    if (T == InputFile) return value.isBinaryAttachment();

    return switch (@typeInfo(T)) {
        .optional => if (value) |inner| hasRuntimeAttachment(inner) else false,
        .pointer => |ptr| switch (ptr.size) {
            .one => hasRuntimeAttachment(value.*),
            .slice => blk: {
                for (value) |item| {
                    if (hasRuntimeAttachment(item)) break :blk true;
                }
                break :blk false;
            },
            else => false,
        },
        .array => blk: {
            for (value) |item| {
                if (hasRuntimeAttachment(item)) break :blk true;
            }
            break :blk false;
        },
        .@"struct" => |st| blk: {
            inline for (st.field_names, st.field_types) |fname, ftype| {
                if (comptime containsAttachment(ftype)) {
                    if (hasRuntimeAttachment(@field(value, fname))) break :blk true;
                }
            }
            break :blk false;
        },
        .@"union" => switch (value) {
            inline else => |payload| hasRuntimeAttachment(payload),
        },
        else => false,
    };
}

/// Generates a 128-bit CSPRNG multipart boundary string (`"----ZigTelegramBoundary<32-hex>"`).
pub fn generateBoundary(io: std.Io) [55]u8 {
    var entropy: [16]u8 = undefined;
    io.random(&entropy);
    const hex = std.fmt.bytesToHex(entropy, .lower);
    var out: [55]u8 = undefined;
    const prefix = "----ZigTelegramBoundary";
    @memcpy(out[0..prefix.len], prefix);
    @memcpy(out[prefix.len..], &hex);
    return out;
}

/// Validates that a multipart field or filename contains no ASCII control
/// characters (`\r`, `\n`, `\0`) and writes it with `"` and `\` escaped per
/// RFC 7578.
pub fn writeEscapedHeaderParam(writer: *std.Io.Writer, value: []const u8) (error{InvalidMultipartHeader} || std.Io.Writer.Error)!void {
    for (value) |b| {
        if (b == '\r' or b == '\n' or b == 0) return error.InvalidMultipartHeader;
    }
    for (value) |b| {
        if (b == '"' or b == '\\') {
            try writer.writeByte('\\');
        }
        try writer.writeByte(b);
    }
}

/// Pending binary file attachment collected while serializing a method struct.
pub const PendingPart = struct {
    part_name: []const u8,
    file: InputFile,
};

/// Encoded multipart request payload ready for transmission.
pub const MultipartPayload = struct {
    content_type: []u8,
    body: []u8,

    pub fn deinit(self: *MultipartPayload, allocator: Allocator) void {
        allocator.free(self.content_type);
        allocator.free(self.body);
        self.* = undefined;
    }
};

/// Encodes `params` into a `multipart/form-data` payload with boundary `boundary`.
///
/// - Top-level scalar fields (`i64`, `bool`, `[]const u8`, enums, `ChatId`) are
///   emitted as plain text form fields.
/// - Top-level `InputFile` fields with `.path` or `.bytes` are emitted directly
///   as binary file parts under the field's own name.
/// - Top-level structs, slices, and unions (such as `media: []const InputMedia`
///   in `sendMediaGroup` or `media: InputMedia` in `editMessageMedia`) are
///   serialized as JSON, with any nested `.path` or `.bytes` `InputFile`
///   automatically replaced by `"attach://part_<n>"` and appended as a binary
///   part named `"part_<n>"`.
pub fn encodeMultipart(
    allocator: Allocator,
    io: std.Io,
    boundary: []const u8,
    params: anytype,
) TelegramError!MultipartPayload {
    const T = @TypeOf(params);
    const info = @typeInfo(T);
    if (info != .@"struct") return error.BadRequest;

    var arena_state = std.heap.ArenaAllocator.init(allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    var pending_parts: std.ArrayList(PendingPart) = .empty;
    var out: std.Io.Writer.Allocating = .init(allocator);
    errdefer out.deinit();

    inline for (info.@"struct".field_names, info.@"struct".field_types) |fname, ftype| {
        const raw_val = @field(params, fname);
        if (@typeInfo(ftype) == .optional) {
            if (raw_val) |unwrapped| {
                try encodeTopLevelField(arena, io, &out.writer, boundary, fname, unwrapped, &pending_parts);
            }
        } else {
            try encodeTopLevelField(arena, io, &out.writer, boundary, fname, raw_val, &pending_parts);
        }
    }

    // Emit all collected nested `attach://part_<n>` binary attachments.
    for (pending_parts.items) |part| {
        try writeBinaryFilePart(allocator, io, &out.writer, boundary, part.part_name, part.file);
    }

    // Closing boundary `--<boundary>--\r\n`
    writeClosingBoundary(&out.writer, boundary) catch return error.OutOfMemory;

    const content_type = try std.fmt.allocPrint(allocator, "multipart/form-data; boundary={s}", .{boundary});
    errdefer allocator.free(content_type);

    const body = out.toOwnedSlice() catch return error.OutOfMemory;
    return .{
        .content_type = content_type,
        .body = body,
    };
}

fn encodeTopLevelField(
    arena: Allocator,
    io: std.Io,
    writer: *std.Io.Writer,
    boundary: []const u8,
    field_name: []const u8,
    val: anytype,
    pending_parts: *std.ArrayList(PendingPart),
) TelegramError!void {
    const V = @TypeOf(val);
    if (V == InputFile) {
        switch (val) {
            .file_id, .url => |str| {
                try writeTextPart(writer, boundary, field_name, str);
            },
            .path, .bytes => {
                try writeBinaryFilePart(arena, io, writer, boundary, field_name, val);
            },
        }
        return;
    }

    if (V == json_mod.ChatId) {
        switch (val) {
            .id => |id_num| {
                var num_buf: [32]u8 = undefined;
                const s = std.fmt.bufPrint(&num_buf, "{d}", .{id_num}) catch unreachable;
                try writeTextPart(writer, boundary, field_name, s);
            },
            .username => |u| try writeTextPart(writer, boundary, field_name, u),
        }
        return;
    }

    if (V == []const u8 or V == []u8) {
        try writeTextPart(writer, boundary, field_name, val);
        return;
    }

    switch (@typeInfo(V)) {
        .int, .comptime_int => {
            var num_buf: [64]u8 = undefined;
            const s = std.fmt.bufPrint(&num_buf, "{d}", .{val}) catch unreachable;
            try writeTextPart(writer, boundary, field_name, s);
        },
        .float, .comptime_float => {
            var num_buf: [64]u8 = undefined;
            const s = std.fmt.bufPrint(&num_buf, "{d}", .{val}) catch unreachable;
            try writeTextPart(writer, boundary, field_name, s);
        },
        .bool => {
            try writeTextPart(writer, boundary, field_name, if (val) "true" else "false");
        },
        .@"enum" => {
            var json_out: std.Io.Writer.Allocating = .init(arena);
            var jw: std.json.Stringify = .{ .writer = &json_out.writer };
            jw.write(val) catch return error.OutOfMemory;
            const written = json_out.written();
            if (written.len >= 2 and written[0] == '"' and written[written.len - 1] == '"') {
                try writeTextPart(writer, boundary, field_name, written[1 .. written.len - 1]);
            } else {
                try writeTextPart(writer, boundary, field_name, written);
            }
        },
        else => {
            // Struct, slice, or union: serialize to JSON while rewriting any nested
            // binary `InputFile` into `"attach://part_<index>"`.
            var json_out: std.Io.Writer.Allocating = .init(arena);
            var jw: std.json.Stringify = .{
                .writer = &json_out.writer,
                .options = .{ .emit_null_optional_fields = false },
            };
            try writeJsonWithAttach(arena, &jw, val, pending_parts);
            try writeTextPart(writer, boundary, field_name, json_out.written());
        },
    }
}

fn writeJsonWithAttach(
    arena: Allocator,
    jw: *std.json.Stringify,
    val: anytype,
    pending_parts: *std.ArrayList(PendingPart),
) TelegramError!void {
    const V = @TypeOf(val);
    if (!comptime containsAttachment(V)) {
        jw.write(val) catch return error.OutOfMemory;
        return;
    }

    if (V == InputFile) {
        switch (val) {
            .file_id, .url => |s| jw.write(s) catch return error.OutOfMemory,
            .path, .bytes => {
                const idx = pending_parts.items.len;
                const part_name = try std.fmt.allocPrint(arena, "part_{d}", .{idx});
                const attach_uri = try std.fmt.allocPrint(arena, "attach://{s}", .{part_name});
                try pending_parts.append(arena, .{
                    .part_name = part_name,
                    .file = val,
                });
                jw.write(attach_uri) catch return error.OutOfMemory;
            },
        }
        return;
    }

    switch (@typeInfo(V)) {
        .optional => {
            if (val) |inner| {
                try writeJsonWithAttach(arena, jw, inner, pending_parts);
            } else {
                jw.write(null) catch return error.OutOfMemory;
            }
        },
        .pointer => |ptr| switch (ptr.size) {
            .one => try writeJsonWithAttach(arena, jw, val.*, pending_parts),
            .slice => {
                jw.beginArray() catch return error.OutOfMemory;
                for (val) |item| {
                    try writeJsonWithAttach(arena, jw, item, pending_parts);
                }
                jw.endArray() catch return error.OutOfMemory;
            },
            else => jw.write(val) catch return error.OutOfMemory,
        },
        .array => {
            jw.beginArray() catch return error.OutOfMemory;
            for (val) |item| {
                try writeJsonWithAttach(arena, jw, item, pending_parts);
            }
            jw.endArray() catch return error.OutOfMemory;
        },
        .@"struct" => |st| {
            jw.beginObject() catch return error.OutOfMemory;
            inline for (st.field_names, st.field_types) |fname, ftype| {
                const fval = @field(val, fname);
                if (@typeInfo(ftype) == .optional) {
                    if (fval) |unwrapped| {
                        jw.objectField(fname) catch return error.OutOfMemory;
                        try writeJsonWithAttach(arena, jw, unwrapped, pending_parts);
                    }
                } else {
                    jw.objectField(fname) catch return error.OutOfMemory;
                    try writeJsonWithAttach(arena, jw, fval, pending_parts);
                }
            }
            jw.endObject() catch return error.OutOfMemory;
        },
        .@"union" => {
            // If the union declares `discriminatorField` and `discriminatorValue` (generated
            // by `tools/gen_bot_api.zig` for Bot API tagged unions), emit its discriminator
            // tag alongside the active variant's fields while still rewriting nested `InputFile`s!
            if (@hasDecl(V, "writeMultipartJson")) {
                try val.writeMultipartJson(arena, jw, pending_parts, writeJsonWithAttach);
            } else {
                switch (val) {
                    inline else => |payload| try writeJsonWithAttach(arena, jw, payload, pending_parts),
                }
            }
        },
        else => jw.write(val) catch return error.OutOfMemory,
    }
}

fn writeTextPart(
    writer: *std.Io.Writer,
    boundary: []const u8,
    field_name: []const u8,
    value: []const u8,
) TelegramError!void {
    writer.writeAll("--") catch return error.OutOfMemory;
    writer.writeAll(boundary) catch return error.OutOfMemory;
    writer.writeAll("\r\nContent-Disposition: form-data; name=\"") catch return error.OutOfMemory;
    writeEscapedHeaderParam(writer, field_name) catch |err| return switch (err) {
        error.InvalidMultipartHeader => error.InvalidMultipartHeader,
        error.WriteFailed => error.OutOfMemory,
    };
    writer.writeAll("\"\r\n\r\n") catch return error.OutOfMemory;
    writer.writeAll(value) catch return error.OutOfMemory;
    writer.writeAll("\r\n") catch return error.OutOfMemory;
}

fn writeBinaryFilePart(
    allocator: Allocator,
    io: std.Io,
    writer: *std.Io.Writer,
    boundary: []const u8,
    part_name: []const u8,
    file: InputFile,
) TelegramError!void {
    switch (file) {
        .bytes => |b| {
            writer.writeAll("--") catch return error.OutOfMemory;
            writer.writeAll(boundary) catch return error.OutOfMemory;
            writer.writeAll("\r\nContent-Disposition: form-data; name=\"") catch return error.OutOfMemory;
            writeEscapedHeaderParam(writer, part_name) catch |err| return switch (err) {
                error.InvalidMultipartHeader => error.InvalidMultipartHeader,
                error.WriteFailed => error.OutOfMemory,
            };
            writer.writeAll("\"; filename=\"") catch return error.OutOfMemory;
            writeEscapedHeaderParam(writer, b.filename) catch |err| return switch (err) {
                error.InvalidMultipartHeader => error.InvalidMultipartHeader,
                error.WriteFailed => error.OutOfMemory,
            };
            writer.writeAll("\"\r\nContent-Type: ") catch return error.OutOfMemory;
            writeEscapedHeaderParam(writer, b.content_type) catch |err| return switch (err) {
                error.InvalidMultipartHeader => error.InvalidMultipartHeader,
                error.WriteFailed => error.OutOfMemory,
            };
            writer.writeAll("\r\n\r\n") catch return error.OutOfMemory;
            writer.writeAll(b.data) catch return error.OutOfMemory;
            writer.writeAll("\r\n") catch return error.OutOfMemory;
        },
        .path => |file_path| {
            const basename = std.fs.path.basename(file_path);
            const file_bytes = std.Io.Dir.cwd().readFileAlloc(io, file_path, allocator, .limited(64 * 1024 * 1024)) catch {
                return error.FileReadError;
            };
            defer allocator.free(file_bytes);

            writer.writeAll("--") catch return error.OutOfMemory;
            writer.writeAll(boundary) catch return error.OutOfMemory;
            writer.writeAll("\r\nContent-Disposition: form-data; name=\"") catch return error.OutOfMemory;
            writeEscapedHeaderParam(writer, part_name) catch |err| return switch (err) {
                error.InvalidMultipartHeader => error.InvalidMultipartHeader,
                error.WriteFailed => error.OutOfMemory,
            };
            writer.writeAll("\"; filename=\"") catch return error.OutOfMemory;
            writeEscapedHeaderParam(writer, basename) catch |err| return switch (err) {
                error.InvalidMultipartHeader => error.InvalidMultipartHeader,
                error.WriteFailed => error.OutOfMemory,
            };
            writer.writeAll("\"\r\nContent-Type: application/octet-stream\r\n\r\n") catch return error.OutOfMemory;
            writer.writeAll(file_bytes) catch return error.OutOfMemory;
            writer.writeAll("\r\n") catch return error.OutOfMemory;
        },
        .file_id, .url => unreachable,
    }
}

fn writeClosingBoundary(writer: *std.Io.Writer, boundary: []const u8) std.Io.Writer.Error!void {
    try writer.writeAll("--");
    try writer.writeAll(boundary);
    try writer.writeAll("--\r\n");
}

test "recursive containsAttachment and nested attach:// multipart encoding" {
    const allocator = std.testing.allocator;
    const io = std.testing.io;

    const NestedPhoto = struct {
        type: []const u8 = "photo",
        media: InputFile,
        caption: ?[]const u8 = null,
    };
    const SendGroupParams = struct {
        chat_id: json_mod.ChatId,
        media: []const NestedPhoto,
    };

    try std.testing.expect(comptime containsAttachment(SendGroupParams));

    const params_url_only = SendGroupParams{
        .chat_id = .{ .id = 12345 },
        .media = &.{
            .{ .media = .{ .url = "https://example.com/a.jpg" } },
        },
    };
    try std.testing.expect(!hasRuntimeAttachment(params_url_only));

    const params_with_bytes = SendGroupParams{
        .chat_id = .{ .id = 12345 },
        .media = &.{
            .{
                .media = .{
                    .bytes = .{
                        .filename = "chart\"1.png",
                        .data = "\x89PNG\r\n\x1a\n",
                        .content_type = "image/png",
                    },
                },
                .caption = "First chart",
            },
        },
    };
    try std.testing.expect(hasRuntimeAttachment(params_with_bytes));

    const boundary = generateBoundary(io);
    var encoded = try encodeMultipart(allocator, io, &boundary, params_with_bytes);
    defer encoded.deinit(allocator);

    try std.testing.expect(std.mem.indexOf(u8, encoded.body, "attach://part_0") != null);
    try std.testing.expect(std.mem.indexOf(u8, encoded.body, "name=\"part_0\"; filename=\"chart\\\"1.png\"") != null);
    try std.testing.expect(std.mem.indexOf(u8, encoded.body, "\x89PNG\r\n\x1a\n") != null);
}

test "writeEscapedHeaderParam rejects CRLF injection" {
    var out: std.Io.Writer.Allocating = .init(std.testing.allocator);
    defer out.deinit();

    try std.testing.expectError(
        error.InvalidMultipartHeader,
        writeEscapedHeaderParam(&out.writer, "evil\"\r\nX-Injected: 1"),
    );
}
