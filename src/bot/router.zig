//! Zero-allocation command, callback query, inline query, and update router.
//!
//! Parses bot commands (`/start`, `/start@my_bot arg1 arg2`) in-place by slicing
//! the incoming `Message.text` without heap allocations.

const std = @import("std");
const types = @import("types.zig");

pub const Update = types.Update;
pub const Message = types.Message;
pub const CallbackQuery = types.CallbackQuery;
pub const InlineQuery = types.InlineQuery;

/// Zero-allocation parsed representation of a Telegram bot command (`/command@bot args`).
pub const ParsedCommand = struct {
    /// Command name without the leading `/` or `@bot_username` suffix (e.g. `"start"`).
    command: []const u8,
    /// Optional target bot username if addressed as `/cmd@bot_username`.
    bot_username: ?[]const u8 = null,
    /// Trimmed argument tail following the command token (`""` when no arguments).
    args: []const u8 = "",

    /// Parses `text` as a bot command if it begins with `/`.
    /// If `expected_bot_username` is provided, commands explicitly addressed to
    /// a *different* bot (`/start@other_bot`) return `null`.
    pub fn parse(text: []const u8, expected_bot_username: ?[]const u8) ?ParsedCommand {
        if (text.len < 2 or text[0] != '/') return null;
        const space_idx = std.mem.indexOfAny(u8, text, " \t\r\n") orelse text.len;
        const head = text[1..space_idx];
        if (head.len == 0) return null;

        var cmd_name = head;
        var target_bot: ?[]const u8 = null;
        if (std.mem.indexOfScalar(u8, head, '@')) |at_idx| {
            cmd_name = head[0..at_idx];
            target_bot = head[at_idx + 1 ..];
            if (cmd_name.len == 0 or target_bot.?.len == 0) return null;
            if (expected_bot_username) |expected| {
                const clean_expected = if (expected.len > 0 and expected[0] == '@') expected[1..] else expected;
                if (!std.ascii.eqlIgnoreCase(target_bot.?, clean_expected)) {
                    return null;
                }
            }
        }

        const tail = if (space_idx < text.len)
            std.mem.trim(u8, text[space_idx + 1 ..], " \t\r\n")
        else
            "";

        return .{
            .command = cmd_name,
            .bot_username = target_bot,
            .args = tail,
        };
    }
};

/// Comptime-parameterized update router over an application `Context` type.
pub fn Router(comptime Context: type) type {
    return struct {
        const Self = @This();

        pub const CommandRoute = struct {
            command: []const u8,
            handler: *const fn (ctx: Context, msg: Message, cmd: ParsedCommand) anyerror!void,
        };

        pub const CallbackPrefixRoute = struct {
            prefix: []const u8,
            handler: *const fn (ctx: Context, query: CallbackQuery, rest: []const u8) anyerror!void,
        };

        bot_username: ?[]const u8 = null,
        commands: []const CommandRoute = &.{},
        callback_prefixes: []const CallbackPrefixRoute = &.{},
        on_message: ?*const fn (ctx: Context, msg: Message) anyerror!void = null,
        on_callback_query: ?*const fn (ctx: Context, query: CallbackQuery) anyerror!void = null,
        on_inline_query: ?*const fn (ctx: Context, query: InlineQuery) anyerror!void = null,
        on_fallback: ?*const fn (ctx: Context, update: Update) anyerror!void = null,

        /// Dispatches `update` to the first matching command, callback prefix,
        /// message, callback query, inline query, or fallback handler.
        /// Returns `true` if a handler matched and executed.
        pub fn dispatch(self: Self, ctx: Context, update: Update) !bool {
            if (update.message) |msg_ptr| {
                const msg = msg_ptr.*;
                if (msg.text) |text| {
                    if (ParsedCommand.parse(text, self.bot_username)) |parsed_cmd| {
                        for (self.commands) |route| {
                            if (std.mem.eql(u8, route.command, parsed_cmd.command)) {
                                try route.handler(ctx, msg, parsed_cmd);
                                return true;
                            }
                        }
                    }
                }
                if (self.on_message) |msg_fn| {
                    try msg_fn(ctx, msg);
                    return true;
                }
            }

            if (update.callback_query) |cb| {
                if (cb.data) |data| {
                    for (self.callback_prefixes) |route| {
                        if (std.mem.startsWith(u8, data, route.prefix)) {
                            try route.handler(ctx, cb, data[route.prefix.len..]);
                            return true;
                        }
                    }
                }
                if (self.on_callback_query) |cb_fn| {
                    try cb_fn(ctx, cb);
                    return true;
                }
            }

            if (update.inline_query) |iq| {
                if (self.on_inline_query) |iq_fn| {
                    try iq_fn(ctx, iq);
                    return true;
                }
            }

            if (self.on_fallback) |fb_fn| {
                try fb_fn(ctx, update);
                return true;
            }

            return false;
        }
    };
}

test "ParsedCommand and Router dispatch" {
    const cmd1 = ParsedCommand.parse("/deploy@zig_bot production --force", "zig_bot").?;
    try std.testing.expectEqualStrings("deploy", cmd1.command);
    try std.testing.expectEqualStrings("zig_bot", cmd1.bot_username.?);
    try std.testing.expectEqualStrings("production --force", cmd1.args);

    try std.testing.expect(ParsedCommand.parse("/deploy@other_bot", "zig_bot") == null);

    const State = struct {
        matched_args: []const u8 = "",
        matched_cb: []const u8 = "",

        fn handleStart(self: *@This(), _: Message, cmd: ParsedCommand) !void {
            self.matched_args = cmd.args;
        }

        fn handleAction(self: *@This(), _: CallbackQuery, rest: []const u8) !void {
            self.matched_cb = rest;
        }
    };

    const AppRouter = Router(*State);
    const router = AppRouter{
        .bot_username = "zig_bot",
        .commands = &.{
            .{ .command = "start", .handler = State.handleStart },
        },
        .callback_prefixes = &.{
            .{ .prefix = "act:", .handler = State.handleAction },
        },
    };

    var state = State{};
    const upd_msg = Update{
        .update_id = 1,
        .message = &.{
            .message_id = 10,
            .date = 1700000000,
            .chat = &.{ .id = 1, .type = "private" },
            .text = "/start@zig_bot deep_link_42",
        },
    };
    try std.testing.expect(try router.dispatch(&state, upd_msg));
    try std.testing.expectEqualStrings("deep_link_42", state.matched_args);
}
