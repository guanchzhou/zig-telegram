//! Single-pass JSON serialization, discriminated union decoding, and Bot API
//! response envelope parsing (`Response(T)`).
//!
//! Eliminates the double-allocation DOM pass found in older Zig Telegram
//! clients and supports bodiless empty-parameter serialization for
//! `telegram-bot-api --local` compatibility.

const std = @import("std");
const Allocator = std.mem.Allocator;
const err_mod = @import("error.zig");
const TelegramError = err_mod.TelegramError;
const ErrorDetail = err_mod.ErrorDetail;
const ErrorParameters = err_mod.ErrorParameters;

/// Represents a Telegram chat target (`Integer or String`), accepting either a
/// numeric chat/user ID (`i64`) or a channel/supergroup `@username` (`[]const u8`).
pub const ChatId = union(enum) {
    id: i64,
    username: []const u8,

    pub fn fromId(id: i64) ChatId {
        return .{ .id = id };
    }

    pub fn fromUsername(username: []const u8) ChatId {
        return .{ .username = username };
    }

    pub fn jsonStringify(self: ChatId, jw: anytype) !void {
        switch (self) {
            .id => |v| try jw.write(v),
            .username => |s| try jw.write(s),
        }
    }

    pub fn jsonParse(
        allocator: Allocator,
        source: anytype,
        options: std.json.ParseOptions,
    ) std.json.ParseError(@TypeOf(source.*))!ChatId {
        return switch (try source.peekNextTokenType()) {
            .number => .{ .id = try std.json.innerParse(i64, allocator, source, options) },
            .string => .{ .username = try std.json.innerParse([]const u8, allocator, source, options) },
            else => error.UnexpectedToken,
        };
    }

    pub fn jsonParseFromValue(
        allocator: Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) std.json.ParseFromValueError!ChatId {
        _ = allocator;
        _ = options;
        return switch (source) {
            .integer => |i| .{ .id = i },
            .string => |s| .{ .username = s },
            else => error.UnexpectedToken,
        };
    }
};

/// Represents a file parameter (`InputFile or String`) in Bot API methods and
/// nested media types (`InputMedia`, `InputPaidMedia`, `InputRichBlock`, etc.).
///
/// - `.file_id`: an existing file identifier on Telegram servers
/// - `.url`: an HTTP/HTTPS URL for Telegram to fetch, or `file://` on a local Bot API server
/// - `.path`: a local filesystem path to stream via `multipart/form-data`
/// - `.bytes`: an in-memory buffer with a filename and MIME type to stream via `multipart/form-data`
pub const InputFile = union(enum) {
    file_id: []const u8,
    url: []const u8,
    path: []const u8,
    bytes: BytesAttachment,

    pub const BytesAttachment = struct {
        filename: []const u8,
        data: []const u8,
        content_type: []const u8 = "application/octet-stream",
    };

    /// Returns `true` when this `InputFile` requires a `multipart/form-data`
    /// binary part (or `attach://<name>` reference when nested).
    pub fn isBinaryAttachment(self: InputFile) bool {
        return switch (self) {
            .path, .bytes => true,
            .file_id, .url => false,
        };
    }

    pub fn jsonStringify(self: InputFile, jw: anytype) !void {
        switch (self) {
            .file_id => |s| try jw.write(s),
            .url => |s| try jw.write(s),
            .path => |p| try jw.write(p),
            .bytes => |b| try jw.write(b.filename),
        }
    }

    pub fn jsonParse(
        allocator: Allocator,
        source: anytype,
        options: std.json.ParseOptions,
    ) std.json.ParseError(@TypeOf(source.*))!InputFile {
        const s = try std.json.innerParse([]const u8, allocator, source, options);
        if (std.mem.startsWith(u8, s, "http://") or std.mem.startsWith(u8, s, "https://") or std.mem.startsWith(u8, s, "file://")) {
            return .{ .url = s };
        }
        return .{ .file_id = s };
    }

    pub fn jsonParseFromValue(
        allocator: Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) std.json.ParseFromValueError!InputFile {
        _ = allocator;
        _ = options;
        return switch (source) {
            .string => |s| if (std.mem.startsWith(u8, s, "http://") or std.mem.startsWith(u8, s, "https://") or std.mem.startsWith(u8, s, "file://"))
                .{ .url = s }
            else
                .{ .file_id = s },
            else => error.UnexpectedToken,
        };
    }
};

/// Represents a method return type that can be either a `T` (such as `Message`)
/// or `bool` (e.g. `editMessageText`, `editMessageCaption`, `stopMessageLiveLocation`
/// when editing an inline message).
pub fn ObjectOrBool(comptime T: type) type {
    return union(enum) {
        object: T,
        boolean: bool,

        const Self = @This();

        pub fn jsonStringify(self: Self, jw: anytype) !void {
            switch (self) {
                .object => |v| try jw.write(v),
                .boolean => |b| try jw.write(b),
            }
        }

        pub fn jsonParse(
            allocator: Allocator,
            source: anytype,
            options: std.json.ParseOptions,
        ) std.json.ParseError(@TypeOf(source.*))!Self {
            return switch (try source.peekNextTokenType()) {
                .true, .false => .{ .boolean = try std.json.innerParse(bool, allocator, source, options) },
                .object_begin => .{ .object = try std.json.innerParse(T, allocator, source, options) },
                else => error.UnexpectedToken,
            };
        }

        pub fn jsonParseFromValue(
            allocator: Allocator,
            source: std.json.Value,
            options: std.json.ParseOptions,
        ) std.json.ParseFromValueError!Self {
            return switch (source) {
                .bool => |b| .{ .boolean = b },
                .object => .{ .object = try std.json.innerParseFromValue(T, allocator, source, options) },
                else => error.UnexpectedToken,
            };
        }
    };
}

/// Returns `true` if `params` is a struct where every field is `null` (or
/// `params` has zero fields). When this returns `true`, `BotClient` sends a
/// bodiless request so local `telegram-bot-api` servers do not reject empty
/// `{}` payloads on parameterless endpoints (`getMe`, `close`, `logOut`).
pub fn isEmptyParams(params: anytype) bool {
    const T = @TypeOf(params);
    const info = @typeInfo(T);
    if (info != .@"struct") return false;
    inline for (info.@"struct".field_names, info.@"struct".field_types) |fname, ftype| {
        const val = @field(params, fname);
        if (@typeInfo(ftype) == .optional) {
            if (val != null) return false;
        } else {
            return false;
        }
    }
    return true;
}

/// Serializes any Zig value to an allocated JSON byte slice with
/// `.emit_null_optional_fields = false`.
pub fn stringifyAlloc(allocator: Allocator, value: anytype) Allocator.Error![]u8 {
    var out: std.Io.Writer.Allocating = .init(allocator);
    errdefer out.deinit();
    var jw: std.json.Stringify = .{
        .writer = &out.writer,
        .options = .{ .emit_null_optional_fields = false },
    };
    jw.write(value) catch return error.OutOfMemory;
    return out.toOwnedSlice();
}

/// Captures a single JSON value from `source` into a slice without building a
/// heap DOM tree (`std.json.Value`), then parses `U` directly using `field_map`.
///
/// `field_map` is a tuple of `.{ "json_discriminator_value", "union_tag_name" }` pairs.
pub fn parseDiscriminatedUnion(
    comptime U: type,
    comptime discriminator_field: []const u8,
    comptime field_map: anytype,
    allocator: Allocator,
    source: anytype,
    options: std.json.ParseOptions,
) std.json.ParseError(@TypeOf(source.*))!U {
    const raw = try captureRawJsonValue(allocator, source);
    const disc_val = try extractTopLevelStringField(allocator, raw, discriminator_field) orelse return error.MissingField;

    inline for (field_map) |pair| {
        const wire_tag: []const u8 = pair[0];
        const union_field: []const u8 = pair[1];
        if (std.mem.eql(u8, disc_val, wire_tag)) {
            const SubType = @FieldType(U, union_field);
            var sub_scanner = std.json.Scanner.initCompleteInput(allocator, raw);
            defer sub_scanner.deinit();
            var parse_opts = options;
            parse_opts.ignore_unknown_fields = true;
            if (parse_opts.allocate == null) parse_opts.allocate = .alloc_if_needed;
            if (parse_opts.max_value_len == null) parse_opts.max_value_len = std.json.default_max_value_len;
            const payload = try std.json.innerParse(SubType, allocator, &sub_scanner, parse_opts);
            return @unionInit(U, union_field, payload);
        }
    }
    return error.InvalidEnumTag;
}

/// Parses `MaybeInaccessibleMessage` (`Message` vs `InaccessibleMessage`) in a
/// single pass over the captured object slice: per the Bot API specification,
/// `InaccessibleMessage` always has `date == 0`.
pub fn parseMaybeInaccessibleMessage(
    comptime U: type,
    allocator: Allocator,
    source: anytype,
    options: std.json.ParseOptions,
) std.json.ParseError(@TypeOf(source.*))!U {
    const raw = try captureRawJsonValue(allocator, source);
    const date_val = try extractTopLevelIntField(allocator, raw, "date") orelse return error.MissingField;
    var sub_scanner = std.json.Scanner.initCompleteInput(allocator, raw);
    defer sub_scanner.deinit();
    var parse_opts = options;
    parse_opts.ignore_unknown_fields = true;
    if (parse_opts.allocate == null) parse_opts.allocate = .alloc_if_needed;
    if (parse_opts.max_value_len == null) parse_opts.max_value_len = std.json.default_max_value_len;
    if (date_val == 0) {
        const SubType = @FieldType(U, "inaccessible_message");
        return @unionInit(U, "inaccessible_message", try std.json.innerParse(SubType, allocator, &sub_scanner, parse_opts));
    } else {
        const SubType = @FieldType(U, "message");
        return @unionInit(U, "message", try std.json.innerParse(SubType, allocator, &sub_scanner, parse_opts));
    }
}

/// Captures a balanced JSON value (object, array, string, number, bool, null)
/// from `source` as a valid JSON slice.
///
/// When `source` is backed by an in-memory `std.json.Scanner`, slices directly
/// from `source.input` with zero heap allocations using a single-pass brace
/// depth scan.
pub fn captureRawJsonValue(
    allocator: Allocator,
    source: anytype,
) std.json.ParseError(@TypeOf(source.*))![]const u8 {
    if (@TypeOf(source.*) == std.json.Scanner) {
        _ = try source.peekNextTokenType();
        const start = source.cursor;
        if (fastFindJsonValueEnd(source.input, start)) |end| {
            source.cursor = end;
            source.state = .post_value;
            return source.input[start..end];
        }
        try source.skipValue();
        const end = source.cursor;
        return source.input[start..end];
    }

    var out: std.Io.Writer.Allocating = .init(allocator);
    errdefer out.deinit();
    var jw: std.json.Stringify = .{ .writer = &out.writer };
    try copyNextJsonValue(allocator, source, &jw);
    return out.toOwnedSlice() catch return error.OutOfMemory;
}

/// Fast O(n) zero-allocation scanner that finds the byte offset immediately
/// after the balanced JSON object or array starting at `input[start]`.
fn fastFindJsonValueEnd(input: []const u8, start: usize) ?usize {
    if (start >= input.len) return null;
    const first = input[start];
    if (first != '{' and first != '[') return null;

    var i: usize = start;
    var depth: usize = 0;
    var in_string = false;
    while (i < input.len) : (i += 1) {
        const c = input[i];
        if (in_string) {
            if (c == '\\') {
                i += 1;
                if (i >= input.len) return null;
            } else if (c == '"') {
                in_string = false;
            }
        } else {
            switch (c) {
                '"' => in_string = true,
                '{', '[' => depth += 1,
                '}', ']' => {
                    if (depth == 0) return null;
                    depth -= 1;
                    if (depth == 0) return i + 1;
                },
                else => {},
            }
        }
    }
    return null;
}

fn copyNextJsonValue(
    allocator: Allocator,
    source: anytype,
    jw: *std.json.Stringify,
) std.json.ParseError(@TypeOf(source.*))!void {
    const tok = try source.nextAlloc(allocator, .alloc_if_needed);
    switch (tok) {
        .object_begin => {
            jw.beginObject() catch return error.OutOfMemory;
            while (true) {
                if (try source.peekNextTokenType() == .object_end) {
                    _ = try source.next();
                    break;
                }
                const key_tok = try source.nextAlloc(allocator, .alloc_if_needed);
                const key_str = switch (key_tok) {
                    .string, .allocated_string => |s| s,
                    else => return error.UnexpectedToken,
                };
                jw.objectField(key_str) catch return error.OutOfMemory;
                try copyNextJsonValue(allocator, source, jw);
            }
            jw.endObject() catch return error.OutOfMemory;
        },
        .array_begin => {
            jw.beginArray() catch return error.OutOfMemory;
            while (true) {
                if (try source.peekNextTokenType() == .array_end) {
                    _ = try source.next();
                    break;
                }
                try copyNextJsonValue(allocator, source, jw);
            }
            jw.endArray() catch return error.OutOfMemory;
        },
        .string, .allocated_string => |s| jw.write(s) catch return error.OutOfMemory,
        .number, .allocated_number => |n| {
            if (std.json.isNumberFormattedLikeAnInteger(n)) {
                const i = std.fmt.parseInt(i64, n, 10) catch {
                    const f = try std.fmt.parseFloat(f64, n);
                    jw.write(f) catch return error.OutOfMemory;
                    return;
                };
                jw.write(i) catch return error.OutOfMemory;
            } else {
                const f = try std.fmt.parseFloat(f64, n);
                jw.write(f) catch return error.OutOfMemory;
            }
        },
        .true => jw.write(true) catch return error.OutOfMemory,
        .false => jw.write(false) catch return error.OutOfMemory,
        .null => jw.write(null) catch return error.OutOfMemory,
        else => return error.UnexpectedToken,
    }
}

/// Scans only the top-level fields of `raw_json_object` (skipping nested
/// objects/arrays in O(n) without allocating a DOM) and returns the string
/// value of `field_name`.
pub fn extractTopLevelStringField(
    allocator: Allocator,
    raw_json_object: []const u8,
    field_name: []const u8,
) !?[]const u8 {
    if (fastExtractTopLevelUnescapedString(raw_json_object, field_name)) |val| {
        return val;
    }

    var scanner = std.json.Scanner.initCompleteInput(allocator, raw_json_object);
    defer scanner.deinit();

    if (try scanner.next() != .object_begin) return error.UnexpectedToken;
    while (true) {
        const peek = try scanner.peekNextTokenType();
        if (peek == .object_end) return null;
        const key_tok = try scanner.nextAlloc(allocator, .alloc_if_needed);
        const key = switch (key_tok) {
            .string, .allocated_string => |s| s,
            else => return error.UnexpectedToken,
        };
        if (std.mem.eql(u8, key, field_name)) {
            const val_tok = try scanner.nextAlloc(allocator, .alloc_if_needed);
            return switch (val_tok) {
                .string, .allocated_string => |s| s,
                else => null,
            };
        } else {
            try scanner.skipValue();
        }
    }
}

/// Zero-allocation fast path that extracts an unescaped top-level string field
/// at brace depth 1 (e.g. `"type":"..."` or `"status":"..."`). Returns `null`
/// if not found or if escapes are present (falling back to `std.json.Scanner`).
fn fastExtractTopLevelUnescapedString(raw: []const u8, field_name: []const u8) ?[]const u8 {
    var i: usize = 0;
    while (i < raw.len and (raw[i] == ' ' or raw[i] == '\t' or raw[i] == '\r' or raw[i] == '\n')) : (i += 1) {}
    if (i >= raw.len or raw[i] != '{') return null;
    i += 1;

    var depth: usize = 1;
    var expecting_key = true;
    while (i < raw.len) {
        const c = raw[i];
        switch (c) {
            ' ', '\t', '\r', '\n' => i += 1,
            '{', '[' => {
                depth += 1;
                expecting_key = (c == '{' and depth == 1);
                i += 1;
            },
            '}', ']' => {
                if (depth == 0) return null;
                depth -= 1;
                if (depth == 0) return null;
                i += 1;
            },
            ',' => {
                if (depth == 1) expecting_key = true;
                i += 1;
            },
            ':' => {
                if (depth == 1) expecting_key = false;
                i += 1;
            },
            '"' => {
                const str_start = i + 1;
                var j = str_start;
                while (j < raw.len) : (j += 1) {
                    if (raw[j] == '\\') return null;
                    if (raw[j] == '"') break;
                }
                if (j >= raw.len) return null;
                const s = raw[str_start..j];
                i = j + 1;

                if (depth == 1 and expecting_key) {
                    expecting_key = false;
                    if (std.mem.eql(u8, s, field_name)) {
                        while (i < raw.len and (raw[i] == ' ' or raw[i] == '\t' or raw[i] == '\r' or raw[i] == '\n')) : (i += 1) {}
                        if (i >= raw.len or raw[i] != ':') return null;
                        i += 1;
                        while (i < raw.len and (raw[i] == ' ' or raw[i] == '\t' or raw[i] == '\r' or raw[i] == '\n')) : (i += 1) {}
                        if (i >= raw.len or raw[i] != '"') return null;
                        const val_start = i + 1;
                        var k = val_start;
                        while (k < raw.len) : (k += 1) {
                            if (raw[k] == '\\') return null;
                            if (raw[k] == '"') return raw[val_start..k];
                        }
                        return null;
                    }
                }
            },
            else => i += 1,
        }
    }
    return null;
}

/// Scans only the top-level fields of `raw_json_object` and returns the `i64`
/// value of `field_name`.
pub fn extractTopLevelIntField(
    allocator: Allocator,
    raw_json_object: []const u8,
    field_name: []const u8,
) !?i64 {
    var scanner = std.json.Scanner.initCompleteInput(allocator, raw_json_object);
    defer scanner.deinit();

    if (try scanner.next() != .object_begin) return error.UnexpectedToken;
    while (true) {
        const peek = try scanner.peekNextTokenType();
        if (peek == .object_end) return null;
        const key_tok = try scanner.nextAlloc(allocator, .alloc_if_needed);
        const key = switch (key_tok) {
            .string, .allocated_string => |s| s,
            else => return error.UnexpectedToken,
        };
        if (std.mem.eql(u8, key, field_name)) {
            const val_tok = try scanner.nextAlloc(allocator, .alloc_if_needed);
            return switch (val_tok) {
                .number, .allocated_number => |n| try std.fmt.parseInt(i64, n, 10),
                else => null,
            };
        } else {
            try scanner.skipValue();
        }
    }
}

/// Checks if a top-level field exists in `raw_json_object`.
pub fn hasTopLevelField(
    allocator: Allocator,
    raw_json_object: []const u8,
    field_name: []const u8,
) !bool {
    var scanner = std.json.Scanner.initCompleteInput(allocator, raw_json_object);
    defer scanner.deinit();

    if (try scanner.next() != .object_begin) return error.UnexpectedToken;
    while (true) {
        const peek = try scanner.peekNextTokenType();
        if (peek == .object_end) return false;
        const key_tok = try scanner.nextAlloc(allocator, .alloc_if_needed);
        const key = switch (key_tok) {
            .string, .allocated_string => |s| s,
            else => return error.UnexpectedToken,
        };
        if (std.mem.eql(u8, key, field_name)) {
            return true;
        }
        try scanner.skipValue();
    }
}

/// Raw Bot API JSON envelope `{"ok": bool, "result": T, "error_code": u16, "description": "...", "parameters": {...}}`.
pub fn RawEnvelope(comptime T: type) type {
    return struct {
        ok: bool,
        result: ?T = null,
        error_code: ?u16 = null,
        description: ?[]const u8 = null,
        parameters: ?ErrorParameters = null,
    };
}

/// Parses a Telegram Bot API JSON envelope into `std.json.Parsed(T)`.
///
/// If `ok == false` or `http_status >= 400`, populates `err_out` (when
/// provided) with a caller-owned `ErrorDetail` (preserving `retry_after` and
/// `migrate_to_chat_id`) and returns the corresponding `TelegramError`.
pub fn parseResponseEnvelope(
    comptime T: type,
    allocator: Allocator,
    http_status: u16,
    body: []const u8,
    err_out: ?*?ErrorDetail,
) TelegramError!std.json.Parsed(T) {
    if (err_out) |slot| slot.* = null;

    var arena_ptr = try allocator.create(std.heap.ArenaAllocator);
    errdefer allocator.destroy(arena_ptr);
    arena_ptr.* = std.heap.ArenaAllocator.init(allocator);
    errdefer arena_ptr.deinit();

    const arena = arena_ptr.allocator();
    const env = std.json.parseFromSliceLeaky(RawEnvelope(T), arena, body, .{
        .ignore_unknown_fields = true,
        .allocate = .alloc_always,
    }) catch |parse_err| switch (parse_err) {
        error.OutOfMemory => return error.OutOfMemory,
        else => {
            if (http_status >= 400) {
                if (err_out) |slot| {
                    slot.* = try ErrorDetail.init(allocator, http_status, body, .{});
                }
                return err_mod.errorFromCode(http_status);
            }
            return error.MalformedJson;
        },
    };

    if (!env.ok or http_status >= 400) {
        const code: u16 = env.error_code orelse if (http_status >= 400) http_status else 400;
        const desc = env.description orelse "Telegram API error";
        const params = env.parameters orelse ErrorParameters{};
        if (err_out) |slot| {
            slot.* = try ErrorDetail.init(allocator, code, desc, params);
        }
        return err_mod.errorFromCode(code);
    }

    const result = env.result orelse return error.MalformedJson;
    return .{
        .arena = arena_ptr,
        .value = result,
    };
}

test "ChatId and ObjectOrBool JSON round-trip" {
    const allocator = std.testing.allocator;

    const id_json = try stringifyAlloc(allocator, ChatId.fromId(-100987654321));
    defer allocator.free(id_json);
    try std.testing.expectEqualStrings("-100987654321", id_json);

    var parsed_id = try std.json.parseFromSlice(ChatId, allocator, id_json, .{});
    defer parsed_id.deinit();
    try std.testing.expectEqual(@as(i64, -100987654321), parsed_id.value.id);

    const user_json = try stringifyAlloc(allocator, ChatId.fromUsername("@zig_telegram"));
    defer allocator.free(user_json);
    try std.testing.expectEqualStrings("\"@zig_telegram\"", user_json);

    var parsed_user = try std.json.parseFromSlice(ChatId, allocator, user_json, .{});
    defer parsed_user.deinit();
    try std.testing.expectEqualStrings("@zig_telegram", parsed_user.value.username);

    const Dummy = struct { id: i64 };
    var parsed_bool = try std.json.parseFromSlice(ObjectOrBool(Dummy), allocator, "true", .{});
    defer parsed_bool.deinit();
    try std.testing.expectEqual(true, parsed_bool.value.boolean);

    var parsed_obj = try std.json.parseFromSlice(ObjectOrBool(Dummy), allocator, "{\"id\":42}", .{});
    defer parsed_obj.deinit();
    try std.testing.expectEqual(@as(i64, 42), parsed_obj.value.object.id);
}

test "parseResponseEnvelope captures retry_after and migrate_to_chat_id" {
    const allocator = std.testing.allocator;
    const raw_429 =
        \\{"ok":false,"error_code":429,"description":"Too Many Requests: retry after 23","parameters":{"retry_after":23,"migrate_to_chat_id":-100555666777}}
    ;
    var detail: ?ErrorDetail = null;
    defer if (detail) |*d| d.deinit(allocator);

    const res = parseResponseEnvelope(bool, allocator, 429, raw_429, &detail);
    try std.testing.expectError(error.TooManyRequests, res);
    try std.testing.expect(detail != null);
    try std.testing.expectEqual(@as(u16, 429), detail.?.error_code);
    try std.testing.expectEqual(@as(?u32, 23), detail.?.retry_after);
    try std.testing.expectEqual(@as(?i64, -100555666777), detail.?.migrate_to_chat_id);
    try std.testing.expectEqualStrings("Too Many Requests: retry after 23", detail.?.description);
}
