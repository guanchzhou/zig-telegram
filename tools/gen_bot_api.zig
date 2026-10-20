//! Deterministic Bot API 10.3 code generator for `zig-telegram`.
//!
//! Reads `spec/bot_api_10_3.json` (185 methods, 400 types/unions) and emits:
//! - `src/bot/enums.zig`
//! - `src/bot/types.zig`
//! - `src/bot/methods.zig`
//! - `src/bot/client.zig`
//!
//! Usage:
//! - `zig build gen-spec` writes the generated files.
//! - `zig build spec-check` runs with `--check` and fails if any file on disk
//!   differs from the freshly generated output.

const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn main(init: std.process.Init) !void {
    const arena = init.arena.allocator();
    const io = init.io;

    var check_only = false;
    var spec_path: []const u8 = "spec/bot_api_10_3.json";
    var out_dir: []const u8 = "src/bot";

    var args = try init.minimal.args.iterateAllocator(arena);
    _ = args.next();
    while (args.next()) |arg| {
        if (std.mem.eql(u8, arg, "--check")) {
            check_only = true;
        } else if (std.mem.eql(u8, arg, "--spec")) {
            spec_path = args.next() orelse return error.InvalidArgs;
        } else if (std.mem.eql(u8, arg, "--out-dir")) {
            out_dir = args.next() orelse return error.InvalidArgs;
        }
    }

    const raw_spec = try std.Io.Dir.cwd().readFileAlloc(io, spec_path, arena, .limited(32 * 1024 * 1024));
    const parsed_val = try std.json.parseFromSliceLeaky(std.json.Value, arena, raw_spec, .{});
    const root_obj = parsed_val.object;

    const version_str = root_obj.get("version").?.string;
    const release_date_str = root_obj.get("release_date").?.string;
    const methods_obj = root_obj.get("methods").?.object;
    const types_obj = root_obj.get("types").?.object;

    const enums_src = try generateEnumsFile(arena, version_str, release_date_str);
    const types_src = try generateTypesFile(arena, version_str, release_date_str, types_obj);
    const methods_src = try generateMethodsFile(arena, version_str, release_date_str, methods_obj);
    const client_src = try generateClientFile(arena, version_str, release_date_str, methods_obj);

    const targets = [_]struct { name: []const u8, content: []const u8 }{
        .{ .name = "enums.zig", .content = enums_src },
        .{ .name = "types.zig", .content = types_src },
        .{ .name = "methods.zig", .content = methods_src },
        .{ .name = "client.zig", .content = client_src },
    };

    for (targets) |t| {
        const z_src = try arena.allocSentinel(u8, t.content.len, 0);
        @memcpy(z_src, t.content);
        var tree = try std.zig.Ast.parse(arena, z_src, .{ .mode = .zig });
        defer tree.deinit(arena);
        if (tree.errors.len > 0) {
            std.debug.print("AST parse error in generated {s}\n", .{t.name});
            return error.GeneratedSyntaxError;
        }
        const formatted = try tree.renderAlloc(arena);

        const full_path = try std.fmt.allocPrint(arena, "{s}/{s}", .{ out_dir, t.name });
        if (check_only) {
            const disk = try std.Io.Dir.cwd().readFileAlloc(io, full_path, arena, .limited(32 * 1024 * 1024));
            if (!std.mem.eql(u8, disk, formatted)) {
                std.debug.print("spec-check mismatch in {s} (run `zig build gen-spec`)\n", .{full_path});
                return error.SpecOutOfSync;
            }
        } else {
            try std.Io.Dir.cwd().writeFile(io, .{
                .sub_path = full_path,
                .data = formatted,
            });
        }
    }
}

fn generateEnumsFile(arena: Allocator, version: []const u8, release_date: []const u8) ![]u8 {
    var out: std.Io.Writer.Allocating = .init(arena);
    const w = &out.writer;

    try w.print(
        \\//! Telegram {s} ({s}) strongly-typed enumerations.
        \\//!
        \\//! Generated deterministically from `spec/bot_api_10_3.json` by `tools/gen_bot_api.zig`.
        \\
        \\pub const ParseMode = enum {{
        \\    HTML,
        \\    Markdown,
        \\    MarkdownV2,
        \\}};
        \\
        \\pub const ChatType = enum {{
        \\    private,
        \\    group,
        \\    supergroup,
        \\    channel,
        \\}};
        \\
        \\pub const ChatAction = enum {{
        \\    typing,
        \\    upload_photo,
        \\    record_video,
        \\    upload_video,
        \\    record_voice,
        \\    upload_voice,
        \\    upload_document,
        \\    choose_sticker,
        \\    find_location,
        \\    record_video_note,
        \\    upload_video_note,
        \\}};
        \\
        \\pub const ChatMemberStatus = enum {{
        \\    creator,
        \\    administrator,
        \\    member,
        \\    restricted,
        \\    left,
        \\    kicked,
        \\}};
        \\
        \\pub const MessageEntityType = enum {{
        \\    mention,
        \\    hashtag,
        \\    cashtag,
        \\    bot_command,
        \\    url,
        \\    email,
        \\    phone_number,
        \\    bold,
        \\    italic,
        \\    underline,
        \\    strikethrough,
        \\    spoiler,
        \\    blockquote,
        \\    expandable_blockquote,
        \\    code,
        \\    pre,
        \\    text_link,
        \\    text_mention,
        \\    custom_emoji,
        \\    date_time,
        \\}};
        \\
        \\pub const PollType = enum {{
        \\    regular,
        \\    quiz,
        \\}};
        \\
        \\pub const DiceEmoji = enum {{
        \\    @"🎲",
        \\    @"🎯",
        \\    @"🏀",
        \\    @"⚽",
        \\    @"🎳",
        \\    @"🎰",
        \\}};
        \\
        \\pub const StickerFormat = enum {{
        \\    static,
        \\    animated,
        \\    video,
        \\}};
        \\
        \\pub const StickerType = enum {{
        \\    regular,
        \\    mask,
        \\    custom_emoji,
        \\}};
        \\
        \\pub const MaskPositionPoint = enum {{
        \\    forehead,
        \\    eyes,
        \\    mouth,
        \\    chin,
        \\}};
        \\
        \\pub const UpdateType = enum {{
        \\    message,
        \\    edited_message,
        \\    channel_post,
        \\    edited_channel_post,
        \\    business_connection,
        \\    business_message,
        \\    edited_business_message,
        \\    deleted_business_messages,
        \\    message_reaction,
        \\    message_reaction_count,
        \\    inline_query,
        \\    chosen_inline_result,
        \\    callback_query,
        \\    shipping_query,
        \\    pre_checkout_query,
        \\    purchased_paid_media,
        \\    poll,
        \\    poll_answer,
        \\    my_chat_member,
        \\    chat_member,
        \\    chat_join_request,
        \\    chat_boost,
        \\    removed_chat_boost,
        \\    managed_bot,
        \\}};
        \\
        \\pub const Currency = enum {{
        \\    XTR,
        \\    TON,
        \\}};
        \\
        \\pub const BotSubscriptionState = enum {{
        \\    canceled,
        \\    active,
        \\    failed,
        \\}};
        \\
        \\pub const ButtonsAlign = enum {{
        \\    left,
        \\    center,
        \\    right,
        \\}};
        \\
        \\pub const HorizontalAlignment = enum {{
        \\    left,
        \\    center,
        \\    right,
        \\}};
        \\
        \\pub const VerticalAlignment = enum {{
        \\    top,
        \\    middle,
        \\    bottom,
        \\}};
        \\
        \\pub const ChatJoinRequestQueryResult = enum {{
        \\    approve,
        \\    decline,
        \\    queue,
        \\}};
        \\
        \\pub const GiftRarity = enum {{
        \\    uncommon,
        \\    rare,
        \\    epic,
        \\    legendary,
        \\}};
        \\
        \\pub const InlineQueryChatType = enum {{
        \\    sender,
        \\    private,
        \\    group,
        \\    supergroup,
        \\    channel,
        \\}};
        \\
        \\pub const KeyboardButtonStyle = enum {{
        \\    primary,
        \\    secondary,
        \\    outline,
        \\}};
        \\
        \\pub const RefundReason = enum {{
        \\    post_deleted,
        \\    payment_refunded,
        \\}};
        \\
        \\pub const RichBlockListItemType = enum {{
        \\    a,
        \\    A,
        \\    i,
        \\    I,
        \\    @"1",
        \\}};
        \\
        \\pub const SuggestedPostState = enum {{
        \\    pending,
        \\    approved,
        \\    declined,
        \\}};
        \\
        \\pub const TransactionType = enum {{
        \\    invoice_payment,
        \\    paid_media_payment,
        \\    gift_purchase,
        \\    premium_purchase,
        \\    business_account_transfer,
        \\}};
        \\
        \\pub const UniqueGiftOrigin = enum {{
        \\    upgrade,
        \\    transfer,
        \\    resale,
        \\    gifted_upgrade,
        \\    offer,
        \\}};
        \\
    , .{ version, release_date });

    return out.toOwnedSlice();
}

fn generateTypesFile(
    arena: Allocator,
    version: []const u8,
    release_date: []const u8,
    types_obj: std.json.ObjectMap,
) ![]u8 {
    var out: std.Io.Writer.Allocating = .init(arena);
    const w = &out.writer;

    try w.print(
        \\//! Telegram {s} ({s}) data types and discriminated unions ({d} definitions).
        \\//!
        \\//! Generated deterministically from `spec/bot_api_10_3.json` by `tools/gen_bot_api.zig`.
        \\
        \\const std = @import("std");
        \\const Allocator = std.mem.Allocator;
        \\const json_mod = @import("../json.zig");
        \\const multipart_mod = @import("../multipart.zig");
        \\pub const ChatId = json_mod.ChatId;
        \\pub const InputFile = json_mod.InputFile;
        \\pub const ObjectOrBool = json_mod.ObjectOrBool;
        \\pub const enums = @import("enums.zig");
        \\
        \\/// Union of the 4 reply markup types accepted by message-sending methods.
        \\pub const ReplyMarkup = union(enum) {{
        \\    inline_keyboard_markup: InlineKeyboardMarkup,
        \\    reply_keyboard_markup: ReplyKeyboardMarkup,
        \\    reply_keyboard_remove: ReplyKeyboardRemove,
        \\    force_reply: ForceReply,
        \\
        \\    pub fn jsonStringify(self: ReplyMarkup, jw: anytype) !void {{
        \\        switch (self) {{
        \\            inline else => |payload| try jw.write(payload),
        \\        }}
        \\    }}
        \\
        \\    pub fn jsonParse(
        \\        allocator: Allocator,
        \\        source: anytype,
        \\        options: std.json.ParseOptions,
        \\    ) std.json.ParseError(@TypeOf(source.*))!ReplyMarkup {{
        \\        const raw = try json_mod.captureRawJsonValue(allocator, source);
        \\        var sub = std.json.Scanner.initCompleteInput(allocator, raw);
        \\        defer sub.deinit();
        \\        var opts = options;
        \\        opts.ignore_unknown_fields = true;
        \\        if (opts.allocate == null) opts.allocate = .alloc_if_needed;
        \\        if (opts.max_value_len == null) opts.max_value_len = std.json.default_max_value_len;
        \\        if (try json_mod.hasTopLevelField(allocator, raw, "inline_keyboard")) {{
        \\            return .{{ .inline_keyboard_markup = try std.json.innerParse(InlineKeyboardMarkup, allocator, &sub, opts) }};
        \\        }}
        \\        if (try json_mod.hasTopLevelField(allocator, raw, "keyboard")) {{
        \\            return .{{ .reply_keyboard_markup = try std.json.innerParse(ReplyKeyboardMarkup, allocator, &sub, opts) }};
        \\        }}
        \\        if (try json_mod.hasTopLevelField(allocator, raw, "remove_keyboard")) {{
        \\            return .{{ .reply_keyboard_remove = try std.json.innerParse(ReplyKeyboardRemove, allocator, &sub, opts) }};
        \\        }}
        \\        if (try json_mod.hasTopLevelField(allocator, raw, "force_reply")) {{
        \\            return .{{ .force_reply = try std.json.innerParse(ForceReply, allocator, &sub, opts) }};
        \\        }}
        \\        return error.UnexpectedToken;
        \\    }}
        \\}};
        \\
        \\/// Media item accepted by `sendMediaGroup` (`InputMediaAudio`, `InputMediaDocument`,
        \\/// `InputMediaLivePhoto`, `InputMediaPhoto`, or `InputMediaVideo`).
        \\pub const MediaGroupItem = InputMedia;
        \\
        \\
    , .{ version, release_date, types_obj.count() });

    const keys = try sortedKeys(arena, types_obj);
    for (keys) |type_name| {
        if (std.mem.eql(u8, type_name, "InputFile")) continue;
        const tval = types_obj.get(type_name).?.object;
        try emitDocComment(w, tval);

        if (tval.get("subtypes")) |subtypes_val| {
            try emitUnionType(arena, w, type_name, subtypes_val.array.items, types_obj);
        } else {
            const fields = if (tval.get("fields")) |f| f.array.items else &[_]std.json.Value{};
            try emitStructType(arena, w, type_name, fields, false);
        }
        try w.writeAll("\n");
    }

    return out.toOwnedSlice();
}

fn generateMethodsFile(
    arena: Allocator,
    version: []const u8,
    release_date: []const u8,
    methods_obj: std.json.ObjectMap,
) ![]u8 {
    var out: std.Io.Writer.Allocating = .init(arena);
    const w = &out.writer;

    try w.print(
        \\//! Telegram {s} ({s}) method parameter structs and metadata ({d} methods).
        \\//!
        \\//! Generated deterministically from `spec/bot_api_10_3.json` by `tools/gen_bot_api.zig`.
        \\
        \\const std = @import("std");
        \\pub const types = @import("types.zig");
        \\pub const ChatId = types.ChatId;
        \\pub const InputFile = types.InputFile;
        \\pub const ObjectOrBool = types.ObjectOrBool;
        \\pub const ReplyMarkup = types.ReplyMarkup;
        \\
        \\pub const spec_version = "{s}";
        \\pub const spec_release_date = "{s}";
        \\pub const method_count: usize = {d};
        \\
        \\
    , .{ version, release_date, methods_obj.count(), version, release_date, methods_obj.count() });

    const keys = try sortedKeys(arena, methods_obj);
    for (keys) |method_name| {
        const mval = methods_obj.get(method_name).?.object;
        try emitDocComment(w, mval);

        const struct_name = try capitalizeFirst(arena, method_name);
        const fields = if (mval.get("fields")) |f| f.array.items else &[_]std.json.Value{};
        const returns = mval.get("returns").?.array.items;
        const ret_zig = try mapZigType(arena, returns, true, true);

        try w.print("pub const {s} = struct {{\n", .{struct_name});
        try w.print("    pub const api_method_name = \"{s}\";\n", .{method_name});
        try w.print("    pub const ReturnType = {s};\n", .{ret_zig});
        if (fields.len > 0) try w.writeAll("\n");

        try emitStructFields(arena, w, method_name, fields, true);
        try w.writeAll("};\n\n");
    }

    try w.writeAll("pub const all_method_names = [_][]const u8{\n");
    for (keys) |method_name| {
        try w.print("    \"{s}\",\n", .{method_name});
    }
    try w.writeAll("};\n");

    return out.toOwnedSlice();
}

fn generateClientFile(
    arena: Allocator,
    version: []const u8,
    release_date: []const u8,
    methods_obj: std.json.ObjectMap,
) ![]u8 {
    var out: std.Io.Writer.Allocating = .init(arena);
    const w = &out.writer;

    try w.print(
        \\//! Typed Telegram {s} ({s}) client with all {d} Bot API methods, automatic
        \\//! JSON vs `multipart/form-data` (`attach://`) selection, bodiless empty-param
        \\//! requests, and caller-owned `ErrorDetail` diagnostics.
        \\//!
        \\//! Generated deterministically from `spec/bot_api_10_3.json` by `tools/gen_bot_api.zig`.
        \\
        \\const std = @import("std");
        \\const Allocator = std.mem.Allocator;
        \\const secret_mod = @import("../secret.zig");
        \\const err_mod = @import("../error.zig");
        \\const json_mod = @import("../json.zig");
        \\const multipart_mod = @import("../multipart.zig");
        \\const transport_mod = @import("../transport.zig");
        \\pub const types = @import("types.zig");
        \\pub const methods = @import("methods.zig");
        \\pub const enums = @import("enums.zig");
        \\
        \\pub const SecretToken = secret_mod.SecretToken;
        \\pub const TelegramError = err_mod.TelegramError;
        \\pub const ErrorDetail = err_mod.ErrorDetail;
        \\pub const Transport = transport_mod.Transport;
        \\pub const LocalServerConfig = transport_mod.LocalServerConfig;
        \\
        \\pub const ClientConfig = struct {{
        \\    /// Base URL for Bot API calls (`https://api.telegram.org` or local server URL).
        \\    base_url: []const u8 = transport_mod.default_api_base_url,
        \\    /// Maximum allowed response body size in bytes (defaults to 16 MiB).
        \\    max_response_bytes: usize = transport_mod.default_max_response_bytes,
        \\    /// Optional `--local` server path remapping configuration.
        \\    local_server: ?LocalServerConfig = null,
        \\}};
        \\
        \\pub const BotClient = struct {{
        \\    allocator: Allocator,
        \\    io: std.Io,
        \\    token: SecretToken,
        \\    transport: Transport,
        \\    config: ClientConfig = .{{}},
        \\
        \\    pub fn init(
        \\        allocator: Allocator,
        \\        io: std.Io,
        \\        token: SecretToken,
        \\        transport: Transport,
        \\        config: ClientConfig,
        \\    ) BotClient {{
        \\        var resolved_config = config;
        \\        if (config.local_server) |ls| {{
        \\            if (std.mem.eql(u8, config.base_url, transport_mod.default_api_base_url)) {{
        \\                resolved_config.base_url = ls.base_url;
        \\            }}
        \\        }}
        \\        return .{{
        \\            .allocator = allocator,
        \\            .io = io,
        \\            .token = token,
        \\            .transport = transport,
        \\            .config = resolved_config,
        \\        }};
        \\    }}
        \\
        \\    /// Builds the full request URL for `method_name`.
        \\    pub fn buildMethodUrl(self: *const BotClient, allocator: Allocator, method_name: []const u8) Allocator.Error![]u8 {{
        \\        const base = std.mem.trimEnd(u8, self.config.base_url, "/");
        \\        return std.fmt.allocPrint(allocator, "{{s}}/bot{{s}}/{{s}}", .{{
        \\            base,
        \\            self.token.expose(),
        \\            method_name,
        \\        }});
        \\    }}
        \\
        \\    /// Builds the download URL for a `File.file_path` returned by `getFile`.
        \\    pub fn buildFileDownloadUrl(self: *const BotClient, allocator: Allocator, file_path: []const u8) Allocator.Error![]u8 {{
        \\        const base = std.mem.trimEnd(u8, self.config.base_url, "/");
        \\        const trimmed_path = std.mem.trimStart(u8, file_path, "/");
        \\        return std.fmt.allocPrint(allocator, "{{s}}/file/bot{{s}}/{{s}}", .{{
        \\            base,
        \\            self.token.expose(),
        \\            trimmed_path,
        \\        }});
        \\    }}
        \\
        \\    /// Downloads a file by `file_path` (from `getFile`), or reads it directly
        \\    /// from disk when `config.local_server` is configured and `file_path` is an
        \\    /// absolute local path.
        \\    pub fn downloadFile(self: *const BotClient, allocator: Allocator, file_path: []const u8) TelegramError![]u8 {{
        \\        if (self.config.local_server) |ls| {{
        \\            if (std.fs.path.isAbsolute(file_path)) {{
        \\                const host_path = try ls.resolveLocalFilePath(allocator, file_path);
        \\                defer allocator.free(host_path);
        \\                return std.Io.Dir.cwd().readFileAlloc(
        \\                    self.io,
        \\                    host_path,
        \\                    allocator,
        \\                    .limited(self.config.max_response_bytes),
        \\                ) catch return error.FileReadError;
        \\            }}
        \\        }}
        \\        const url = try self.buildFileDownloadUrl(allocator, file_path);
        \\        defer allocator.free(url);
        \\        var raw = try self.transport.send(allocator, .{{
        \\            .url = url,
        \\            .body = null,
        \\            .max_response_bytes = self.config.max_response_bytes,
        \\        }});
        \\        errdefer raw.deinit(allocator);
        \\        if (raw.status >= 400) {{
        \\            const code = raw.status;
        \\            raw.deinit(allocator);
        \\            return err_mod.errorFromCode(code);
        \\        }}
        \\        return raw.body;
        \\    }}
        \\
        \\    /// Executes any `methods.<Method>` struct and decodes `Method.ReturnType`.
        \\    ///
        \\    /// Automatically selects between:
        \\    /// 1. Bodiless request when all parameters are unset/empty
        \\    /// 2. `multipart/form-data` with recursive `attach://part_<n>` rewriting when
        \\    ///    any top-level or nested `InputFile` is `.path` or `.bytes`
        \\    /// 3. Single-pass `application/json`
        \\    pub fn call(
        \\        self: *const BotClient,
        \\        comptime Method: type,
        \\        params: Method,
        \\        err_out: ?*?ErrorDetail,
        \\    ) TelegramError!std.json.Parsed(Method.ReturnType) {{
        \\        const url = try self.buildMethodUrl(self.allocator, Method.api_method_name);
        \\        defer self.allocator.free(url);
        \\
        \\        var raw_resp: transport_mod.RawResponse = undefined;
        \\        if (json_mod.isEmptyParams(params)) {{
        \\            raw_resp = try self.transport.send(self.allocator, .{{
        \\                .url = url,
        \\                .content_type = null,
        \\                .body = null,
        \\                .max_response_bytes = self.config.max_response_bytes,
        \\            }});
        \\        }} else if (comptime multipart_mod.containsAttachment(Method)) {{
        \\            if (multipart_mod.hasRuntimeAttachment(params)) {{
        \\                const boundary = multipart_mod.generateBoundary(self.io);
        \\                var mp = try multipart_mod.encodeMultipart(self.allocator, self.io, &boundary, params);
        \\                defer mp.deinit(self.allocator);
        \\                raw_resp = try self.transport.send(self.allocator, .{{
        \\                    .url = url,
        \\                    .content_type = mp.content_type,
        \\                    .body = mp.body,
        \\                    .max_response_bytes = self.config.max_response_bytes,
        \\                }});
        \\            }} else {{
        \\                const json_body = try json_mod.stringifyAlloc(self.allocator, params);
        \\                defer self.allocator.free(json_body);
        \\                raw_resp = try self.transport.send(self.allocator, .{{
        \\                    .url = url,
        \\                    .content_type = "application/json",
        \\                    .body = json_body,
        \\                    .max_response_bytes = self.config.max_response_bytes,
        \\                }});
        \\            }}
        \\        }} else {{
        \\            const json_body = try json_mod.stringifyAlloc(self.allocator, params);
        \\            defer self.allocator.free(json_body);
        \\            raw_resp = try self.transport.send(self.allocator, .{{
        \\                .url = url,
        \\                .content_type = "application/json",
        \\                .body = json_body,
        \\                .max_response_bytes = self.config.max_response_bytes,
        \\            }});
        \\        }}
        \\        defer raw_resp.deinit(self.allocator);
        \\
        \\        return json_mod.parseResponseEnvelope(
        \\            Method.ReturnType,
        \\            self.allocator,
        \\            raw_resp.status,
        \\            raw_resp.body,
        \\            err_out,
        \\        );
        \\    }}
        \\
        \\    /// Executes an arbitrary Bot API method by name with a raw JSON body (or `null`)
        \\    /// and returns the raw response JSON string. Useful for CLI `call` and debugging.
        \\    pub fn callRawJson(
        \\        self: *const BotClient,
        \\        allocator: Allocator,
        \\        method_name: []const u8,
        \\        json_body: ?[]const u8,
        \\    ) TelegramError!transport_mod.RawResponse {{
        \\        const url = try self.buildMethodUrl(allocator, method_name);
        \\        defer allocator.free(url);
        \\        const trimmed = if (json_body) |b| std.mem.trim(u8, b, " \t\r\n") else null;
        \\        const is_empty = trimmed == null or trimmed.?.len == 0 or std.mem.eql(u8, trimmed.?, "{{}}");
        \\        return self.transport.send(allocator, .{{
        \\            .url = url,
        \\            .content_type = if (is_empty) null else "application/json",
        \\            .body = if (is_empty) null else trimmed,
        \\            .max_response_bytes = self.config.max_response_bytes,
        \\        }});
        \\    }}
        \\
        \\
    , .{ version, release_date, methods_obj.count() });

    const keys = try sortedKeys(arena, methods_obj);
    for (keys) |method_name| {
        const mval = methods_obj.get(method_name).?.object;
        const struct_name = try capitalizeFirst(arena, method_name);
        const fields = if (mval.get("fields")) |f| f.array.items else &[_]std.json.Value{};

        var has_required = false;
        for (fields) |fld| {
            if (fld.object.get("required").?.bool) {
                has_required = true;
                break;
            }
        }

        if (!has_required) {
            try w.print(
                \\    pub fn {s}(
                \\        self: *const BotClient,
                \\        params: methods.{s},
                \\        err_out: ?*?ErrorDetail,
                \\    ) TelegramError!std.json.Parsed(methods.{s}.ReturnType) {{
                \\        return self.call(methods.{s}, params, err_out);
                \\    }}
                \\
                \\
            , .{ method_name, struct_name, struct_name, struct_name });
        } else {
            try w.print(
                \\    pub fn {s}(
                \\        self: *const BotClient,
                \\        params: methods.{s},
                \\        err_out: ?*?ErrorDetail,
                \\    ) TelegramError!std.json.Parsed(methods.{s}.ReturnType) {{
                \\        return self.call(methods.{s}, params, err_out);
                \\    }}
                \\
                \\
            , .{ method_name, struct_name, struct_name, struct_name });
        }
    }

    try w.writeAll("};\n");
    return out.toOwnedSlice();
}

fn emitDocComment(w: *std.Io.Writer, obj: std.json.ObjectMap) !void {
    if (obj.get("description")) |desc_val| {
        for (desc_val.array.items) |line| {
            try w.print("/// {s}\n", .{line.string});
        }
    }
    if (obj.get("href")) |href_val| {
        try w.print("/// Reference: {s}\n", .{href_val.string});
    }
}

fn emitStructType(
    arena: Allocator,
    w: *std.Io.Writer,
    type_name: []const u8,
    fields: []const std.json.Value,
    in_methods_file: bool,
) !void {
    try w.print("pub const {s} = struct {{\n", .{type_name});
    try emitStructFields(arena, w, type_name, fields, in_methods_file);
    try w.writeAll("};\n");
}

fn emitStructFields(
    arena: Allocator,
    w: *std.Io.Writer,
    owner_name: []const u8,
    fields: []const std.json.Value,
    in_methods_file: bool,
) !void {
    // Emit required fields first so callers can construct structs concisely,
    // while giving optional fields `= null` defaults and discriminator fields
    // their fixed literal default when specified.
    for ([_]bool{ true, false }) |want_required| {
        for (fields) |fld_val| {
            const fobj = fld_val.object;
            const req = fobj.get("required").?.bool;
            if (req != want_required) continue;

            const fname = fobj.get("name").?.string;
            const desc = fobj.get("description").?.string;
            const ftypes = fobj.get("types").?.array.items;

            const is_self_cycle_field = !in_methods_file and shouldBoxField(owner_name, ftypes);
            const zig_type = try mapFieldZigType(arena, owner_name, fname, desc, ftypes, in_methods_file, is_self_cycle_field);

            // Check if this is a constant discriminator field (e.g. `type: []const u8 = "photo"`).
            const const_tag = if (req and std.mem.eql(u8, zig_type, "[]const u8"))
                extractConstantTag(desc)
            else
                null;

            try w.print("    /// {s}\n", .{desc});
            const ident = try formatZigIdent(arena, fname);
            if (!req) {
                try w.print("    {s}: ?{s} = null,\n", .{ ident, zig_type });
            } else if (const_tag) |tag_val| {
                try w.print("    {s}: {s} = \"{s}\",\n", .{ ident, zig_type, tag_val });
            } else {
                try w.print("    {s}: {s},\n", .{ ident, zig_type });
            }
        }
    }
}

fn shouldBoxField(owner_name: []const u8, ftypes: []const std.json.Value) bool {
    _ = owner_name;
    if (ftypes.len != 1) return false;
    const t0 = ftypes[0].string;
    return std.mem.eql(u8, t0, "Message") or
        std.mem.eql(u8, t0, "MaybeInaccessibleMessage") or
        std.mem.eql(u8, t0, "RichText") or
        std.mem.eql(u8, t0, "Chat") or
        std.mem.eql(u8, t0, "ExternalReplyInfo") or
        std.mem.eql(u8, t0, "GiveawayCompleted") or
        std.mem.eql(u8, t0, "PollOptionAdded") or
        std.mem.eql(u8, t0, "PollOptionDeleted") or
        std.mem.eql(u8, t0, "ChecklistTasksDone") or
        std.mem.eql(u8, t0, "ChecklistTasksAdded") or
        std.mem.eql(u8, t0, "SuggestedPostApproved") or
        std.mem.eql(u8, t0, "SuggestedPostApprovalFailed") or
        std.mem.eql(u8, t0, "SuggestedPostDeclined") or
        std.mem.eql(u8, t0, "SuggestedPostPaid") or
        std.mem.eql(u8, t0, "SuggestedPostRefunded");
}

fn mapFieldZigType(
    arena: Allocator,
    owner_name: []const u8,
    field_name: []const u8,
    desc: []const u8,
    ftypes: []const std.json.Value,
    in_methods_file: bool,
    box_pointer: bool,
) ![]const u8 {
    // Strongly-typed enum overrides for well-known fields:
    if (std.mem.eql(u8, field_name, "parse_mode") and ftypes.len == 1 and std.mem.eql(u8, ftypes[0].string, "String")) {
        return if (in_methods_file) "types.enums.ParseMode" else "enums.ParseMode";
    }
    if (std.mem.eql(u8, owner_name, "sendChatAction") and std.mem.eql(u8, field_name, "action")) {
        return if (in_methods_file) "types.enums.ChatAction" else "enums.ChatAction";
    }
    // Nested InputFile fields where the specification lists `["String"]` and
    // describes `attach://<file_attach_name>` multipart uploads:
    if (ftypes.len == 1 and std.mem.eql(u8, ftypes[0].string, "String") and std.mem.indexOf(u8, desc, "attach://") != null) {
        return "InputFile";
    }

    const base = try mapZigType(arena, ftypes, in_methods_file, false);
    if (box_pointer) {
        return std.fmt.allocPrint(arena, "*const {s}", .{base});
    }
    return base;
}

fn mapZigType(
    arena: Allocator,
    ftypes: []const std.json.Value,
    in_methods_file: bool,
    is_return_type: bool,
) ![]const u8 {
    const prefix = if (in_methods_file) "types." else "";
    if (ftypes.len == 1) {
        return mapSingleType(arena, ftypes[0].string, prefix);
    }
    if (ftypes.len == 2) {
        const a = ftypes[0].string;
        const b = ftypes[1].string;
        if ((std.mem.eql(u8, a, "Integer") and std.mem.eql(u8, b, "String")) or
            (std.mem.eql(u8, a, "String") and std.mem.eql(u8, b, "Integer")))
        {
            return "ChatId";
        }
        if ((std.mem.eql(u8, a, "InputFile") and std.mem.eql(u8, b, "String")) or
            (std.mem.eql(u8, a, "String") and std.mem.eql(u8, b, "InputFile")))
        {
            return "InputFile";
        }
        if (is_return_type and ((std.mem.eql(u8, a, "Message") and std.mem.eql(u8, b, "Boolean")) or
            (std.mem.eql(u8, a, "Boolean") and std.mem.eql(u8, b, "Message"))))
        {
            return std.fmt.allocPrint(arena, "ObjectOrBool({s}Message)", .{prefix});
        }
    }
    if (ftypes.len == 4 and std.mem.eql(u8, ftypes[0].string, "InlineKeyboardMarkup")) {
        return "ReplyMarkup";
    }
    if (ftypes.len == 5 and std.mem.startsWith(u8, ftypes[0].string, "Array of InputMedia")) {
        return std.fmt.allocPrint(arena, "[]const {s}InputMedia", .{prefix});
    }
    if (ftypes.len == 6 and std.mem.startsWith(u8, ftypes[0].string, "InputMedia")) {
        return std.fmt.allocPrint(arena, "{s}InputMedia", .{prefix});
    }
    return mapSingleType(arena, ftypes[0].string, prefix);
}

fn mapSingleType(arena: Allocator, raw: []const u8, prefix: []const u8) ![]const u8 {
    if (std.mem.startsWith(u8, raw, "Array of ")) {
        const inner = try mapSingleType(arena, raw["Array of ".len..], prefix);
        return std.fmt.allocPrint(arena, "[]const {s}", .{inner});
    }
    if (std.mem.eql(u8, raw, "Integer")) return "i64";
    if (std.mem.eql(u8, raw, "Float")) return "f64";
    if (std.mem.eql(u8, raw, "Boolean")) return "bool";
    if (std.mem.eql(u8, raw, "String")) return "[]const u8";
    if (std.mem.eql(u8, raw, "InputFile")) return "InputFile";
    return std.fmt.allocPrint(arena, "{s}{s}", .{ prefix, raw });
}

fn emitUnionType(
    arena: Allocator,
    w: *std.Io.Writer,
    union_name: []const u8,
    subtypes: []const std.json.Value,
    types_obj: std.json.ObjectMap,
) !void {
    if (std.mem.eql(u8, union_name, "MaybeInaccessibleMessage")) {
        try w.writeAll(
            \\pub const MaybeInaccessibleMessage = union(enum) {
            \\    message: Message,
            \\    inaccessible_message: InaccessibleMessage,
            \\
            \\    pub fn jsonStringify(self: MaybeInaccessibleMessage, jw: anytype) !void {
            \\        switch (self) {
            \\            inline else => |payload| try jw.write(payload),
            \\        }
            \\    }
            \\
            \\    pub fn jsonParse(
            \\        allocator: Allocator,
            \\        source: anytype,
            \\        options: std.json.ParseOptions,
            \\    ) std.json.ParseError(@TypeOf(source.*))!MaybeInaccessibleMessage {
            \\        return json_mod.parseMaybeInaccessibleMessage(MaybeInaccessibleMessage, allocator, source, options);
            \\    }
            \\};
            \\
        );
        return;
    }

    if (std.mem.eql(u8, union_name, "InputMessageContent")) {
        try w.writeAll(
            \\pub const InputMessageContent = union(enum) {
            \\    input_text_message_content: InputTextMessageContent,
            \\    input_rich_message_content: InputRichMessageContent,
            \\    input_location_message_content: InputLocationMessageContent,
            \\    input_venue_message_content: InputVenueMessageContent,
            \\    input_contact_message_content: InputContactMessageContent,
            \\    input_invoice_message_content: InputInvoiceMessageContent,
            \\
            \\    pub fn jsonStringify(self: InputMessageContent, jw: anytype) !void {
            \\        switch (self) {
            \\            inline else => |payload| try jw.write(payload),
            \\        }
            \\    }
            \\
            \\    pub fn jsonParse(
            \\        allocator: Allocator,
            \\        source: anytype,
            \\        options: std.json.ParseOptions,
            \\    ) std.json.ParseError(@TypeOf(source.*))!InputMessageContent {
            \\        const raw = try json_mod.captureRawJsonValue(allocator, source);
            \\        var sub = std.json.Scanner.initCompleteInput(allocator, raw);
            \\        defer sub.deinit();
            \\        var opts = options;
            \\        opts.ignore_unknown_fields = true;
            \\        if (opts.allocate == null) opts.allocate = .alloc_if_needed;
            \\        if (opts.max_value_len == null) opts.max_value_len = std.json.default_max_value_len;
            \\        if (try json_mod.hasTopLevelField(allocator, raw, "message_text")) {
            \\            return .{ .input_text_message_content = try std.json.innerParse(InputTextMessageContent, allocator, &sub, opts) };
            \\        }
            \\        if (try json_mod.hasTopLevelField(allocator, raw, "rich_message")) {
            \\            return .{ .input_rich_message_content = try std.json.innerParse(InputRichMessageContent, allocator, &sub, opts) };
            \\        }
            \\        if (try json_mod.hasTopLevelField(allocator, raw, "address")) {
            \\            return .{ .input_venue_message_content = try std.json.innerParse(InputVenueMessageContent, allocator, &sub, opts) };
            \\        }
            \\        if (try json_mod.hasTopLevelField(allocator, raw, "latitude")) {
            \\            return .{ .input_location_message_content = try std.json.innerParse(InputLocationMessageContent, allocator, &sub, opts) };
            \\        }
            \\        if (try json_mod.hasTopLevelField(allocator, raw, "phone_number")) {
            \\            return .{ .input_contact_message_content = try std.json.innerParse(InputContactMessageContent, allocator, &sub, opts) };
            \\        }
            \\        if (try json_mod.hasTopLevelField(allocator, raw, "prices")) {
            \\            return .{ .input_invoice_message_content = try std.json.innerParse(InputInvoiceMessageContent, allocator, &sub, opts) };
            \\        }
            \\        return error.UnexpectedToken;
            \\    }
            \\};
            \\
        );
        return;
    }

    if (std.mem.eql(u8, union_name, "RichText")) {
        try emitRichTextUnion(arena, w, subtypes, types_obj);
        return;
    }

    // Standard discriminated union (e.g. InputMedia, ChatMember, MessageOrigin, ReactionType, etc.)
    try w.print("pub const {s} = union(enum) {{\n", .{union_name});

    const VariantMeta = struct {
        field_name: []const u8,
        sub_type: []const u8,
        disc_field: []const u8,
        disc_val: []const u8,
    };
    var variants: std.ArrayList(VariantMeta) = .empty;

    for (subtypes) |sub_val| {
        const sub_name = sub_val.string;
        const field_name = try unionVariantName(arena, union_name, sub_name);
        const sub_obj = types_obj.get(sub_name).?.object;
        const sub_fields = sub_obj.get("fields").?.array.items;
        const f0 = sub_fields[0].object;
        const disc_field = f0.get("name").?.string;
        const disc_val = extractConstantTag(f0.get("description").?.string) orelse field_name;

        try variants.append(arena, .{
            .field_name = field_name,
            .sub_type = sub_name,
            .disc_field = disc_field,
            .disc_val = disc_val,
        });
        try w.print("    {s}: {s},\n", .{ field_name, sub_name });
    }

    try w.print(
        \\
        \\    pub fn jsonStringify(self: {s}, jw: anytype) !void {{
        \\        switch (self) {{
        \\            inline else => |payload| try jw.write(payload),
        \\        }}
        \\    }}
        \\
        \\    pub fn writeMultipartJson(
        \\        self: {s},
        \\        arena: Allocator,
        \\        jw: *std.json.Stringify,
        \\        pending_parts: *std.ArrayList(multipart_mod.PendingPart),
        \\        comptime writeFn: anytype,
        \\    ) !void {{
        \\        switch (self) {{
        \\            inline else => |payload| try writeFn(arena, jw, payload, pending_parts),
        \\        }}
        \\    }}
        \\
        \\    pub fn jsonParse(
        \\        allocator: Allocator,
        \\        source: anytype,
        \\        options: std.json.ParseOptions,
        \\    ) std.json.ParseError(@TypeOf(source.*))!{s} {{
        \\        return json_mod.parseDiscriminatedUnion(
        \\            {s},
        \\            "{s}",
        \\            .{{
        \\
    , .{ union_name, union_name, union_name, union_name, variants.items[0].disc_field });

    var seen_tags = std.StringHashMap(void).init(arena);
    for (variants.items) |v| {
        if (seen_tags.contains(v.disc_val)) continue;
        try seen_tags.put(v.disc_val, {});
        try w.print("                .{{ \"{s}\", \"{s}\" }},\n", .{ v.disc_val, v.field_name });
    }

    try w.writeAll(
        \\            },
        \\            allocator,
        \\            source,
        \\            options,
        \\        );
        \\    }
        \\};
        \\
    );
}

fn emitRichTextUnion(
    arena: Allocator,
    w: *std.Io.Writer,
    subtypes: []const std.json.Value,
    types_obj: std.json.ObjectMap,
) !void {
    try w.writeAll(
        \\pub const RichText = union(enum) {
        \\    plain: []const u8,
        \\    array: []const RichText,
        \\
    );

    const VariantMeta = struct {
        field_name: []const u8,
        sub_type: []const u8,
        disc_val: []const u8,
    };
    var variants: std.ArrayList(VariantMeta) = .empty;

    for (subtypes) |sub_val| {
        const sub_name = sub_val.string;
        if (std.mem.eql(u8, sub_name, "String") or std.mem.eql(u8, sub_name, "Array of RichText")) continue;
        const field_name = try unionVariantName(arena, "RichText", sub_name);
        const sub_obj = types_obj.get(sub_name).?.object;
        const sub_fields = sub_obj.get("fields").?.array.items;
        const f0 = sub_fields[0].object;
        const disc_val = extractConstantTag(f0.get("description").?.string) orelse field_name;
        try variants.append(arena, .{
            .field_name = field_name,
            .sub_type = sub_name,
            .disc_val = disc_val,
        });
        try w.print("    {s}: {s},\n", .{ field_name, sub_name });
    }

    try w.writeAll(
        \\
        \\    pub fn jsonStringify(self: RichText, jw: anytype) !void {
        \\        switch (self) {
        \\            .plain => |s| try jw.write(s),
        \\            .array => |arr| try jw.write(arr),
        \\            inline else => |payload| try jw.write(payload),
        \\        }
        \\    }
        \\
        \\    pub fn jsonParse(
        \\        allocator: Allocator,
        \\        source: anytype,
        \\        options: std.json.ParseOptions,
        \\    ) std.json.ParseError(@TypeOf(source.*))!RichText {
        \\        return switch (try source.peekNextTokenType()) {
        \\            .string => .{ .plain = try std.json.innerParse([]const u8, allocator, source, options) },
        \\            .array_begin => .{ .array = try std.json.innerParse([]const RichText, allocator, source, options) },
        \\            .object_begin => json_mod.parseDiscriminatedUnion(
        \\                RichText,
        \\                "type",
        \\                .{
        \\
    );

    for (variants.items) |v| {
        try w.print("                    .{{ \"{s}\", \"{s}\" }},\n", .{ v.disc_val, v.field_name });
    }

    try w.writeAll(
        \\                },
        \\                allocator,
        \\                source,
        \\                options,
        \\            ),
        \\            else => error.UnexpectedToken,
        \\        };
        \\    }
        \\};
        \\
    );
}

fn unionVariantName(arena: Allocator, union_name: []const u8, sub_name: []const u8) ![]const u8 {
    var trimmed = sub_name;
    if (std.mem.startsWith(u8, sub_name, union_name) and sub_name.len > union_name.len) {
        trimmed = sub_name[union_name.len..];
    } else if (std.mem.startsWith(u8, sub_name, "InputMedia") and sub_name.len > "InputMedia".len) {
        trimmed = sub_name["InputMedia".len..];
    }
    return camelToSnake(arena, trimmed);
}

fn camelToSnake(arena: Allocator, s: []const u8) ![]u8 {
    var out: std.ArrayList(u8) = .empty;
    for (s, 0..) |c, i| {
        if (std.ascii.isUpper(c)) {
            if (i > 0) {
                const prev = s[i - 1];
                const next_is_lower = (i + 1 < s.len) and std.ascii.isLower(s[i + 1]);
                if (std.ascii.isLower(prev) or std.ascii.isDigit(prev) or (std.ascii.isUpper(prev) and next_is_lower)) {
                    try out.append(arena, '_');
                }
            }
            try out.append(arena, std.ascii.toLower(c));
        } else {
            try out.append(arena, c);
        }
    }
    return out.toOwnedSlice(arena);
}

fn capitalizeFirst(arena: Allocator, s: []const u8) ![]u8 {
    const duped = try arena.dupe(u8, s);
    if (duped.len > 0) {
        duped[0] = std.ascii.toUpper(duped[0]);
    }
    return duped;
}

fn formatZigIdent(arena: Allocator, name: []const u8) ![]const u8 {
    const keywords = [_][]const u8{
        "type", "error", "return", "var", "const", "fn", "struct", "enum", "union", "opaque", "align", "test", "inline", "export", "extern",
    };
    for (keywords) |kw| {
        if (std.mem.eql(u8, name, kw)) {
            return std.fmt.allocPrint(arena, "@\"{s}\"", .{name});
        }
    }
    return name;
}

fn extractConstantTag(desc: []const u8) ?[]const u8 {
    const needles = [_][]const u8{
        "always \"",
        "must be \"",
        "always “",
        "must be “",
        "must be *",
        "always *",
    };
    for (needles) |needle| {
        if (std.mem.indexOf(u8, desc, needle)) |idx| {
            const rest = desc[idx + needle.len ..];
            for (rest, 0..) |c, i| {
                if (c == '"' or c == '*' or c == 0xe2) {
                    if (i > 0) return rest[0..i];
                    break;
                }
            }
        }
    }
    for ([_][]const u8{ "must be ", "always " }) |needle| {
        if (std.mem.indexOf(u8, desc, needle)) |idx| {
            const rest = desc[idx + needle.len ..];
            var end: usize = 0;
            while (end < rest.len and (std.ascii.isAlphanumeric(rest[end]) or rest[end] == '_')) : (end += 1) {}
            if (end > 0) return rest[0..end];
        }
    }
    return null;
}

fn sortedKeys(arena: Allocator, map: std.json.ObjectMap) ![][]const u8 {
    const list = try arena.alloc([]const u8, map.count());
    var it = map.iterator();
    var i: usize = 0;
    while (it.next()) |entry| : (i += 1) {
        list[i] = entry.key_ptr.*;
    }
    std.mem.sort([]const u8, list, {}, struct {
        fn lessThan(_: void, a: []const u8, b: []const u8) bool {
            return std.mem.lessThan(u8, a, b);
        }
    }.lessThan);
    return list;
}
