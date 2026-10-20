//! Telegram Bot API 10.3 (August 24, 2026) data types and discriminated unions (400 definitions).
//!
//! Generated deterministically from `spec/bot_api_10_3.json` by `tools/gen_bot_api.zig`.

const std = @import("std");
const Allocator = std.mem.Allocator;
const json_mod = @import("../json.zig");
const multipart_mod = @import("../multipart.zig");
pub const ChatId = json_mod.ChatId;
pub const InputFile = json_mod.InputFile;
pub const ObjectOrBool = json_mod.ObjectOrBool;
pub const enums = @import("enums.zig");

/// Union of the 4 reply markup types accepted by message-sending methods.
pub const ReplyMarkup = union(enum) {
    inline_keyboard_markup: InlineKeyboardMarkup,
    reply_keyboard_markup: ReplyKeyboardMarkup,
    reply_keyboard_remove: ReplyKeyboardRemove,
    force_reply: ForceReply,

    pub fn jsonStringify(self: ReplyMarkup, jw: anytype) !void {
        switch (self) {
            inline else => |payload| try jw.write(payload),
        }
    }

    pub fn jsonParse(
        allocator: Allocator,
        source: anytype,
        options: std.json.ParseOptions,
    ) std.json.ParseError(@TypeOf(source.*))!ReplyMarkup {
        const raw = try json_mod.captureRawJsonValue(allocator, source);
        var sub = std.json.Scanner.initCompleteInput(allocator, raw);
        defer sub.deinit();
        var opts = options;
        opts.ignore_unknown_fields = true;
        if (opts.allocate == null) opts.allocate = .alloc_if_needed;
        if (opts.max_value_len == null) opts.max_value_len = std.json.default_max_value_len;
        if (try json_mod.hasTopLevelField(allocator, raw, "inline_keyboard")) {
            return .{ .inline_keyboard_markup = try std.json.innerParse(InlineKeyboardMarkup, allocator, &sub, opts) };
        }
        if (try json_mod.hasTopLevelField(allocator, raw, "keyboard")) {
            return .{ .reply_keyboard_markup = try std.json.innerParse(ReplyKeyboardMarkup, allocator, &sub, opts) };
        }
        if (try json_mod.hasTopLevelField(allocator, raw, "remove_keyboard")) {
            return .{ .reply_keyboard_remove = try std.json.innerParse(ReplyKeyboardRemove, allocator, &sub, opts) };
        }
        if (try json_mod.hasTopLevelField(allocator, raw, "force_reply")) {
            return .{ .force_reply = try std.json.innerParse(ForceReply, allocator, &sub, opts) };
        }
        return error.UnexpectedToken;
    }
};

/// Media item accepted by `sendMediaGroup` (`InputMediaAudio`, `InputMediaDocument`,
/// `InputMediaLivePhoto`, `InputMediaPhoto`, or `InputMediaVideo`).
pub const MediaGroupItem = InputMedia;

/// This object describes the types of gifts that can be gifted to a user or a chat.
/// Reference: https://core.telegram.org/bots/api#acceptedgifttypes
pub const AcceptedGiftTypes = struct {
    /// True, if unlimited regular gifts are accepted
    unlimited_gifts: bool,
    /// True, if limited regular gifts are accepted
    limited_gifts: bool,
    /// True, if unique gifts or gifts that can be upgraded to unique for free are accepted
    unique_gifts: bool,
    /// True, if a Telegram Premium subscription is accepted
    premium_subscription: bool,
    /// True, if transfers of unique gifts from channels are accepted
    gifts_from_channels: bool,
};

/// Contains information about the affiliate that received a commission via this transaction.
/// Reference: https://core.telegram.org/bots/api#affiliateinfo
pub const AffiliateInfo = struct {
    /// The number of Telegram Stars received by the affiliate for each 1000 Telegram Stars received by the bot from referred users
    commission_per_mille: i64,
    /// Integer amount of Telegram Stars received by the affiliate from the transaction, rounded to 0; can be negative for refunds
    amount: i64,
    /// Optional. The bot or the user that received an affiliate commission if it was received by a bot or a user
    affiliate_user: ?User = null,
    /// Optional. The chat that received an affiliate commission if it was received by a chat
    affiliate_chat: ?*const Chat = null,
    /// Optional. The number of 1/1000000000 shares of Telegram Stars received by the affiliate; from -999999999 to 999999999; can be negative for refunds
    nanostar_amount: ?i64 = null,
};

/// This object represents an animation file (GIF or H.264/MPEG-4 AVC video without sound).
/// Reference: https://core.telegram.org/bots/api#animation
pub const Animation = struct {
    /// Identifier for this file, which can be used to download or reuse the file
    file_id: []const u8,
    /// Unique identifier for this file, which is supposed to be the same over time and for different bots. Can't be used to download or reuse the file.
    file_unique_id: []const u8,
    /// Video width as defined by the sender
    width: i64,
    /// Video height as defined by the sender
    height: i64,
    /// Duration of the video in seconds as defined by the sender
    duration: i64,
    /// Optional. Animation thumbnail as defined by the sender
    thumbnail: ?PhotoSize = null,
    /// Optional. Original animation filename as defined by the sender
    file_name: ?[]const u8 = null,
    /// Optional. MIME type of the file as defined by the sender
    mime_type: ?[]const u8 = null,
    /// Optional. File size in bytes. It can be bigger than 2^31 and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a signed 64-bit integer or double-precision float type are safe for storing this value.
    file_size: ?i64 = null,
};

/// This object represents an audio file to be treated as music by the Telegram clients.
/// Reference: https://core.telegram.org/bots/api#audio
pub const Audio = struct {
    /// Identifier for this file, which can be used to download or reuse the file
    file_id: []const u8,
    /// Unique identifier for this file, which is supposed to be the same over time and for different bots. Can't be used to download or reuse the file.
    file_unique_id: []const u8,
    /// Duration of the audio in seconds as defined by the sender
    duration: i64,
    /// Optional. Performer of the audio as defined by the sender or by audio tags
    performer: ?[]const u8 = null,
    /// Optional. Title of the audio as defined by the sender or by audio tags
    title: ?[]const u8 = null,
    /// Optional. Original filename as defined by the sender
    file_name: ?[]const u8 = null,
    /// Optional. MIME type of the file as defined by the sender
    mime_type: ?[]const u8 = null,
    /// Optional. File size in bytes. It can be bigger than 2^31 and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a signed 64-bit integer or double-precision float type are safe for storing this value.
    file_size: ?i64 = null,
    /// Optional. Thumbnail of the album cover to which the music file belongs
    thumbnail: ?PhotoSize = null,
};

/// This object describes the way a background is filled based on the selected colors. Currently, it can be one of
/// - BackgroundFillSolid
/// - BackgroundFillGradient
/// - BackgroundFillFreeformGradient
/// Reference: https://core.telegram.org/bots/api#backgroundfill
pub const BackgroundFill = union(enum) {
    solid: BackgroundFillSolid,
    gradient: BackgroundFillGradient,
    freeform_gradient: BackgroundFillFreeformGradient,

    pub fn jsonStringify(self: BackgroundFill, jw: anytype) !void {
        switch (self) {
            inline else => |payload| try jw.write(payload),
        }
    }

    pub fn writeMultipartJson(
        self: BackgroundFill,
        arena: Allocator,
        jw: *std.json.Stringify,
        pending_parts: *std.ArrayList(multipart_mod.PendingPart),
        comptime writeFn: anytype,
    ) !void {
        switch (self) {
            inline else => |payload| try writeFn(arena, jw, payload, pending_parts),
        }
    }

    pub fn jsonParse(
        allocator: Allocator,
        source: anytype,
        options: std.json.ParseOptions,
    ) std.json.ParseError(@TypeOf(source.*))!BackgroundFill {
        return json_mod.parseDiscriminatedUnion(
            BackgroundFill,
            "type",
            .{
                .{ "solid", "solid" },
                .{ "gradient", "gradient" },
                .{ "freeform_gradient", "freeform_gradient" },
            },
            allocator,
            source,
            options,
        );
    }
};

/// The background is a freeform gradient that rotates after every message in the chat.
/// Reference: https://core.telegram.org/bots/api#backgroundfillfreeformgradient
pub const BackgroundFillFreeformGradient = struct {
    /// Type of the background fill, always "freeform_gradient"
    type: []const u8 = "freeform_gradient",
    /// A list of the 3 or 4 base colors that are used to generate the freeform gradient in the RGB24 format
    colors: []const i64,
};

/// The background is a gradient fill.
/// Reference: https://core.telegram.org/bots/api#backgroundfillgradient
pub const BackgroundFillGradient = struct {
    /// Type of the background fill, always "gradient"
    type: []const u8 = "gradient",
    /// Top color of the gradient in the RGB24 format
    top_color: i64,
    /// Bottom color of the gradient in the RGB24 format
    bottom_color: i64,
    /// Clockwise rotation angle of the background fill in degrees; 0-359
    rotation_angle: i64,
};

/// The background is filled using the selected color.
/// Reference: https://core.telegram.org/bots/api#backgroundfillsolid
pub const BackgroundFillSolid = struct {
    /// Type of the background fill, always "solid"
    type: []const u8 = "solid",
    /// The color of the background fill in the RGB24 format
    color: i64,
};

/// This object describes the type of a background. Currently, it can be one of
/// - BackgroundTypeFill
/// - BackgroundTypeWallpaper
/// - BackgroundTypePattern
/// - BackgroundTypeChatTheme
/// Reference: https://core.telegram.org/bots/api#backgroundtype
pub const BackgroundType = union(enum) {
    fill: BackgroundTypeFill,
    wallpaper: BackgroundTypeWallpaper,
    pattern: BackgroundTypePattern,
    chat_theme: BackgroundTypeChatTheme,

    pub fn jsonStringify(self: BackgroundType, jw: anytype) !void {
        switch (self) {
            inline else => |payload| try jw.write(payload),
        }
    }

    pub fn writeMultipartJson(
        self: BackgroundType,
        arena: Allocator,
        jw: *std.json.Stringify,
        pending_parts: *std.ArrayList(multipart_mod.PendingPart),
        comptime writeFn: anytype,
    ) !void {
        switch (self) {
            inline else => |payload| try writeFn(arena, jw, payload, pending_parts),
        }
    }

    pub fn jsonParse(
        allocator: Allocator,
        source: anytype,
        options: std.json.ParseOptions,
    ) std.json.ParseError(@TypeOf(source.*))!BackgroundType {
        return json_mod.parseDiscriminatedUnion(
            BackgroundType,
            "type",
            .{
                .{ "fill", "fill" },
                .{ "wallpaper", "wallpaper" },
                .{ "pattern", "pattern" },
                .{ "chat_theme", "chat_theme" },
            },
            allocator,
            source,
            options,
        );
    }
};

/// The background is taken directly from a built-in chat theme.
/// Reference: https://core.telegram.org/bots/api#backgroundtypechattheme
pub const BackgroundTypeChatTheme = struct {
    /// Type of the background, always "chat_theme"
    type: []const u8 = "chat_theme",
    /// Name of the chat theme, which is usually an emoji
    theme_name: []const u8,
};

/// The background is automatically filled based on the selected colors.
/// Reference: https://core.telegram.org/bots/api#backgroundtypefill
pub const BackgroundTypeFill = struct {
    /// Type of the background, always "fill"
    type: []const u8 = "fill",
    /// The background fill
    fill: BackgroundFill,
    /// Dimming of the background in dark themes, as a percentage; 0-100
    dark_theme_dimming: i64,
};

/// The background is a .PNG or .TGV (gzipped subset of SVG with MIME type "application/x-tgwallpattern") pattern to be combined with the background fill chosen by the user.
/// Reference: https://core.telegram.org/bots/api#backgroundtypepattern
pub const BackgroundTypePattern = struct {
    /// Type of the background, always "pattern"
    type: []const u8 = "pattern",
    /// Document with the pattern
    document: Document,
    /// The background fill that is combined with the pattern
    fill: BackgroundFill,
    /// Intensity of the pattern when it is shown above the filled background; 0-100
    intensity: i64,
    /// Optional. True, if the background fill must be applied only to the pattern itself. All other pixels are black in this case. For dark themes only.
    is_inverted: ?bool = null,
    /// Optional. True, if the background moves slightly when the device is tilted
    is_moving: ?bool = null,
};

/// The background is a wallpaper in the JPEG format.
/// Reference: https://core.telegram.org/bots/api#backgroundtypewallpaper
pub const BackgroundTypeWallpaper = struct {
    /// Type of the background, always "wallpaper"
    type: []const u8 = "wallpaper",
    /// Document with the wallpaper
    document: Document,
    /// Dimming of the background in dark themes, as a percentage; 0-100
    dark_theme_dimming: i64,
    /// Optional. True, if the wallpaper is downscaled to fit in a 450x450 square and then box-blurred with radius 12
    is_blurred: ?bool = null,
    /// Optional. True, if the background moves slightly when the device is tilted
    is_moving: ?bool = null,
};

/// Describes the birthdate of a user.
/// Reference: https://core.telegram.org/bots/api#birthdate
pub const Birthdate = struct {
    /// Day of the user's birth; 1-31
    day: i64,
    /// Month of the user's birth; 1-12
    month: i64,
    /// Optional. Year of the user's birth
    year: ?i64 = null,
};

/// This object describes the access settings of a bot.
/// Reference: https://core.telegram.org/bots/api#botaccesssettings
pub const BotAccessSettings = struct {
    /// True, if only selected users can access the bot. The bot's owner can always access it.
    is_access_restricted: bool,
    /// Optional. The list of other users who have access to the bot if the access is restricted
    added_users: ?[]const User = null,
};

/// This object represents a bot command.
/// Reference: https://core.telegram.org/bots/api#botcommand
pub const BotCommand = struct {
    /// Text of the command; 1-32 characters. Can contain only lowercase English letters, digits and underscores.
    command: []const u8,
    /// Description of the command; 1-256 characters
    description: []const u8,
    /// Optional. True, if the command sends an ephemeral message, which can be seen only by the sender of the message and the bot
    is_ephemeral: ?bool = null,
};

/// This object represents the scope to which bot commands are applied. Currently, the following 7 scopes are supported:
/// - BotCommandScopeDefault
/// - BotCommandScopeAllPrivateChats
/// - BotCommandScopeAllGroupChats
/// - BotCommandScopeAllChatAdministrators
/// - BotCommandScopeChat
/// - BotCommandScopeChatAdministrators
/// - BotCommandScopeChatMember
/// Reference: https://core.telegram.org/bots/api#botcommandscope
pub const BotCommandScope = union(enum) {
    default: BotCommandScopeDefault,
    all_private_chats: BotCommandScopeAllPrivateChats,
    all_group_chats: BotCommandScopeAllGroupChats,
    all_chat_administrators: BotCommandScopeAllChatAdministrators,
    chat: BotCommandScopeChat,
    chat_administrators: BotCommandScopeChatAdministrators,
    chat_member: BotCommandScopeChatMember,

    pub fn jsonStringify(self: BotCommandScope, jw: anytype) !void {
        switch (self) {
            inline else => |payload| try jw.write(payload),
        }
    }

    pub fn writeMultipartJson(
        self: BotCommandScope,
        arena: Allocator,
        jw: *std.json.Stringify,
        pending_parts: *std.ArrayList(multipart_mod.PendingPart),
        comptime writeFn: anytype,
    ) !void {
        switch (self) {
            inline else => |payload| try writeFn(arena, jw, payload, pending_parts),
        }
    }

    pub fn jsonParse(
        allocator: Allocator,
        source: anytype,
        options: std.json.ParseOptions,
    ) std.json.ParseError(@TypeOf(source.*))!BotCommandScope {
        return json_mod.parseDiscriminatedUnion(
            BotCommandScope,
            "type",
            .{
                .{ "default", "default" },
                .{ "all_private_chats", "all_private_chats" },
                .{ "all_group_chats", "all_group_chats" },
                .{ "all_chat_administrators", "all_chat_administrators" },
                .{ "chat", "chat" },
                .{ "chat_administrators", "chat_administrators" },
                .{ "chat_member", "chat_member" },
            },
            allocator,
            source,
            options,
        );
    }
};

/// Represents the scope of bot commands, covering all group and supergroup chat administrators.
/// Reference: https://core.telegram.org/bots/api#botcommandscopeallchatadministrators
pub const BotCommandScopeAllChatAdministrators = struct {
    /// Scope type, must be all_chat_administrators
    type: []const u8 = "all_chat_administrators",
};

/// Represents the scope of bot commands, covering all group and supergroup chats.
/// Reference: https://core.telegram.org/bots/api#botcommandscopeallgroupchats
pub const BotCommandScopeAllGroupChats = struct {
    /// Scope type, must be all_group_chats
    type: []const u8 = "all_group_chats",
};

/// Represents the scope of bot commands, covering all private chats.
/// Reference: https://core.telegram.org/bots/api#botcommandscopeallprivatechats
pub const BotCommandScopeAllPrivateChats = struct {
    /// Scope type, must be all_private_chats
    type: []const u8 = "all_private_chats",
};

/// Represents the scope of bot commands, covering a specific chat.
/// Reference: https://core.telegram.org/bots/api#botcommandscopechat
pub const BotCommandScopeChat = struct {
    /// Scope type, must be chat
    type: []const u8 = "chat",
    /// Unique identifier for the target chat or username of the target supergroup in the format @username. Channel direct messages chats and channel chats aren't supported.
    chat_id: ChatId,
};

/// Represents the scope of bot commands, covering all administrators of a specific group or supergroup chat.
/// Reference: https://core.telegram.org/bots/api#botcommandscopechatadministrators
pub const BotCommandScopeChatAdministrators = struct {
    /// Scope type, must be chat_administrators
    type: []const u8 = "chat_administrators",
    /// Unique identifier for the target chat or username of the target supergroup in the format @username. Channel direct messages chats and channel chats aren't supported.
    chat_id: ChatId,
};

/// Represents the scope of bot commands, covering a specific member of a group or supergroup chat.
/// Reference: https://core.telegram.org/bots/api#botcommandscopechatmember
pub const BotCommandScopeChatMember = struct {
    /// Scope type, must be chat_member
    type: []const u8 = "chat_member",
    /// Unique identifier for the target chat or username of the target supergroup in the format @username. Channel direct messages chats and channel chats aren't supported.
    chat_id: ChatId,
    /// Unique identifier of the target user
    user_id: i64,
};

/// Represents the default scope of bot commands. Default commands are used if no commands with a narrower scope are specified for the user.
/// Reference: https://core.telegram.org/bots/api#botcommandscopedefault
pub const BotCommandScopeDefault = struct {
    /// Scope type, must be default
    type: []const u8 = "default",
};

/// This object represents the bot's description.
/// Reference: https://core.telegram.org/bots/api#botdescription
pub const BotDescription = struct {
    /// The bot's description
    description: []const u8,
};

/// This object represents the bot's name.
/// Reference: https://core.telegram.org/bots/api#botname
pub const BotName = struct {
    /// The bot's name
    name: []const u8,
};

/// This object represents the bot's short description.
/// Reference: https://core.telegram.org/bots/api#botshortdescription
pub const BotShortDescription = struct {
    /// The bot's short description
    short_description: []const u8,
};

/// This object contains information about changes to a user payment subscription toward the current bot.
/// Reference: https://core.telegram.org/bots/api#botsubscriptionupdated
pub const BotSubscriptionUpdated = struct {
    /// User who subscribed for payments toward the bot
    user: User,
    /// Bot-specified invoice payload
    invoice_payload: []const u8,
    /// The new state of the subscription. Currently, it can be one of "canceled" if the user canceled the subscription, "active" if the user re-enabled a previously canceled subscription, or "failed" if payment for the subscription failed.
    state: []const u8,
};

/// Represents the rights of a business bot.
/// Reference: https://core.telegram.org/bots/api#businessbotrights
pub const BusinessBotRights = struct {
    /// Optional. True, if the bot can send and edit messages in the private chats that had incoming messages in the last 24 hours
    can_reply: ?bool = null,
    /// Optional. True, if the bot can mark incoming private messages as read
    can_read_messages: ?bool = null,
    /// Optional. True, if the bot can delete messages sent by the bot
    can_delete_sent_messages: ?bool = null,
    /// Optional. True, if the bot can delete all private messages in managed chats
    can_delete_all_messages: ?bool = null,
    /// Optional. True, if the bot can edit the first and last name of the business account
    can_edit_name: ?bool = null,
    /// Optional. True, if the bot can edit the bio of the business account
    can_edit_bio: ?bool = null,
    /// Optional. True, if the bot can edit the profile photo of the business account
    can_edit_profile_photo: ?bool = null,
    /// Optional. True, if the bot can edit the username of the business account
    can_edit_username: ?bool = null,
    /// Optional. True, if the bot can change the privacy settings pertaining to gifts for the business account
    can_change_gift_settings: ?bool = null,
    /// Optional. True, if the bot can view gifts and the amount of Telegram Stars owned by the business account
    can_view_gifts_and_stars: ?bool = null,
    /// Optional. True, if the bot can convert regular gifts owned by the business account to Telegram Stars
    can_convert_gifts_to_stars: ?bool = null,
    /// Optional. True, if the bot can transfer and upgrade gifts owned by the business account
    can_transfer_and_upgrade_gifts: ?bool = null,
    /// Optional. True, if the bot can transfer Telegram Stars received by the business account to its own account, or use them to upgrade and transfer gifts
    can_transfer_stars: ?bool = null,
    /// Optional. True, if the bot can post, edit and delete stories on behalf of the business account
    can_manage_stories: ?bool = null,
};

/// Describes the connection of the bot with a business account.
/// Reference: https://core.telegram.org/bots/api#businessconnection
pub const BusinessConnection = struct {
    /// Unique identifier of the business connection
    id: []const u8,
    /// Business account user that created the business connection
    user: User,
    /// Identifier of a private chat with the user who created the business connection. This number may have more than 32 significant bits and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a 64-bit integer or double-precision float type are safe for storing this identifier.
    user_chat_id: i64,
    /// Date the connection was established in Unix time
    date: i64,
    /// True, if the connection is active
    is_enabled: bool,
    /// Optional. Rights of the business bot
    rights: ?BusinessBotRights = null,
};

/// Contains information about the start page settings of a Telegram Business account.
/// Reference: https://core.telegram.org/bots/api#businessintro
pub const BusinessIntro = struct {
    /// Optional. Title text of the business intro
    title: ?[]const u8 = null,
    /// Optional. Message text of the business intro
    message: ?[]const u8 = null,
    /// Optional. Sticker of the business intro
    sticker: ?Sticker = null,
};

/// Contains information about the location of a Telegram Business account.
/// Reference: https://core.telegram.org/bots/api#businesslocation
pub const BusinessLocation = struct {
    /// Address of the business
    address: []const u8,
    /// Optional. Location of the business
    location: ?Location = null,
};

/// This object is received when messages are deleted from a connected business account.
/// Reference: https://core.telegram.org/bots/api#businessmessagesdeleted
pub const BusinessMessagesDeleted = struct {
    /// Unique identifier of the business connection
    business_connection_id: []const u8,
    /// Information about a chat in the business account. The bot may not have access to the chat or the corresponding user.
    chat: *const Chat,
    /// The list of identifiers of deleted messages in the chat of the business account
    message_ids: []const i64,
};

/// Describes the opening hours of a business.
/// Reference: https://core.telegram.org/bots/api#businessopeninghours
pub const BusinessOpeningHours = struct {
    /// Unique name of the time zone for which the opening hours are defined
    time_zone_name: []const u8,
    /// List of time intervals describing business opening hours
    opening_hours: []const BusinessOpeningHoursInterval,
};

/// Describes an interval of time during which a business is open.
/// Reference: https://core.telegram.org/bots/api#businessopeninghoursinterval
pub const BusinessOpeningHoursInterval = struct {
    /// The minute's sequence number in a week, starting on Monday, marking the start of the time interval during which the business is open; 0 - 7 * 24 * 60
    opening_minute: i64,
    /// The minute's sequence number in a week, starting on Monday, marking the end of the time interval during which the business is open; 0 - 8 * 24 * 60
    closing_minute: i64,
};

/// A placeholder, currently holds no information. Use BotFather to set up your game.
/// Reference: https://core.telegram.org/bots/api#callbackgame
pub const CallbackGame = struct {};

/// This object represents an incoming callback query from a callback button in an inline keyboard. If the button that originated the query was attached to a message sent by the bot, the field message will be present. If the button was attached to a message sent via the bot (in inline mode), the field inline_message_id will be present. Exactly one of the fields data or game_short_name will be present.
/// Reference: https://core.telegram.org/bots/api#callbackquery
pub const CallbackQuery = struct {
    /// Unique identifier for this query
    id: []const u8,
    /// Sender
    from: User,
    /// Global identifier, uniquely corresponding to the chat to which the message with the callback button was sent. Useful for high scores in games.
    chat_instance: []const u8,
    /// Optional. Message sent by the bot with the callback button that originated the query
    message: ?*const MaybeInaccessibleMessage = null,
    /// Optional. Identifier of the message sent via the bot in inline mode, that originated the query
    inline_message_id: ?[]const u8 = null,
    /// Optional. Data associated with the callback button. Be aware that the message originated the query can contain no callback buttons with this data.
    data: ?[]const u8 = null,
    /// Optional. Short name of a Game to be returned, serves as the unique identifier for the game
    game_short_name: ?[]const u8 = null,
};

/// This object represents a chat.
/// Reference: https://core.telegram.org/bots/api#chat
pub const Chat = struct {
    /// Unique identifier for this chat. This number may have more than 32 significant bits and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a signed 64-bit integer or double-precision float type are safe for storing this identifier.
    id: i64,
    /// Type of the chat, can be either "private", "group", "supergroup" or "channel"
    type: []const u8,
    /// Optional. Title, for supergroups, channels and group chats
    title: ?[]const u8 = null,
    /// Optional. Username, for private chats, supergroups and channels if available
    username: ?[]const u8 = null,
    /// Optional. First name of the other party in a private chat
    first_name: ?[]const u8 = null,
    /// Optional. Last name of the other party in a private chat
    last_name: ?[]const u8 = null,
    /// Optional. True, if the supergroup chat is a forum (has topics enabled)
    is_forum: ?bool = null,
    /// Optional. True, if the chat is the direct messages chat of a channel
    is_direct_messages: ?bool = null,
};

/// Represents the rights of an administrator in a chat.
/// Reference: https://core.telegram.org/bots/api#chatadministratorrights
pub const ChatAdministratorRights = struct {
    /// True, if the user's presence in the chat is hidden
    is_anonymous: bool,
    /// True, if the administrator can access the chat event log, get boost list, see hidden supergroup and channel members, report spam messages, ignore slow mode, and send messages to the chat without paying Telegram Stars. Implied by any other administrator privilege.
    can_manage_chat: bool,
    /// True, if the administrator can delete messages of other users
    can_delete_messages: bool,
    /// True, if the administrator can manage video chats
    can_manage_video_chats: bool,
    /// True, if the administrator can restrict, ban or unban chat members, or access supergroup statistics
    can_restrict_members: bool,
    /// True, if the administrator can add new administrators with a subset of their own privileges or demote administrators that they have promoted, directly or indirectly (promoted by administrators that were appointed by the user)
    can_promote_members: bool,
    /// True, if the user is allowed to change the chat title, photo and other settings
    can_change_info: bool,
    /// True, if the user is allowed to invite new users to the chat
    can_invite_users: bool,
    /// True, if the administrator can post stories to the chat
    can_post_stories: bool,
    /// True, if the administrator can edit stories posted by other users, post stories to the chat page, pin chat stories, and access the chat's story archive
    can_edit_stories: bool,
    /// True, if the administrator can delete stories posted by other users
    can_delete_stories: bool,
    /// True, if the administrator can manage chat welcome messages or directly send them in the case of bots
    can_send_welcome_messages: bool,
    /// Optional. True, if the administrator can post messages in the channel, approve suggested posts, or access channel statistics; for channels only
    can_post_messages: ?bool = null,
    /// Optional. True, if the administrator can edit messages of other users and can pin messages; for channels only
    can_edit_messages: ?bool = null,
    /// Optional. True, if the user is allowed to pin messages; for groups and supergroups only
    can_pin_messages: ?bool = null,
    /// Optional. True, if the user is allowed to create, rename, close, and reopen forum topics; for supergroups only
    can_manage_topics: ?bool = null,
    /// Optional. True, if the administrator can manage direct messages of the channel and decline suggested posts; for channels only
    can_manage_direct_messages: ?bool = null,
    /// Optional. True, if the administrator can edit the tags of regular members; for groups and supergroups only
    can_manage_tags: ?bool = null,
};

/// This object represents a chat background.
/// Reference: https://core.telegram.org/bots/api#chatbackground
pub const ChatBackground = struct {
    /// Type of the background
    type: BackgroundType,
};

/// This object contains information about a chat boost.
/// Reference: https://core.telegram.org/bots/api#chatboost
pub const ChatBoost = struct {
    /// Unique identifier of the boost
    boost_id: []const u8,
    /// Point in time (Unix timestamp) when the chat was boosted
    add_date: i64,
    /// Point in time (Unix timestamp) when the boost will automatically expire, unless the booster's Telegram Premium subscription is prolonged
    expiration_date: i64,
    /// Source of the added boost
    source: ChatBoostSource,
};

/// This object represents a service message about a user boosting a chat.
/// Reference: https://core.telegram.org/bots/api#chatboostadded
pub const ChatBoostAdded = struct {
    /// Number of boosts added by the user
    boost_count: i64,
};

/// This object represents a boost removed from a chat.
/// Reference: https://core.telegram.org/bots/api#chatboostremoved
pub const ChatBoostRemoved = struct {
    /// Chat which was boosted
    chat: *const Chat,
    /// Unique identifier of the boost
    boost_id: []const u8,
    /// Point in time (Unix timestamp) when the boost was removed
    remove_date: i64,
    /// Source of the removed boost
    source: ChatBoostSource,
};

/// This object describes the source of a chat boost. It can be one of
/// - ChatBoostSourcePremium
/// - ChatBoostSourceGiftCode
/// - ChatBoostSourceGiveaway
/// Reference: https://core.telegram.org/bots/api#chatboostsource
pub const ChatBoostSource = union(enum) {
    premium: ChatBoostSourcePremium,
    gift_code: ChatBoostSourceGiftCode,
    giveaway: ChatBoostSourceGiveaway,

    pub fn jsonStringify(self: ChatBoostSource, jw: anytype) !void {
        switch (self) {
            inline else => |payload| try jw.write(payload),
        }
    }

    pub fn writeMultipartJson(
        self: ChatBoostSource,
        arena: Allocator,
        jw: *std.json.Stringify,
        pending_parts: *std.ArrayList(multipart_mod.PendingPart),
        comptime writeFn: anytype,
    ) !void {
        switch (self) {
            inline else => |payload| try writeFn(arena, jw, payload, pending_parts),
        }
    }

    pub fn jsonParse(
        allocator: Allocator,
        source: anytype,
        options: std.json.ParseOptions,
    ) std.json.ParseError(@TypeOf(source.*))!ChatBoostSource {
        return json_mod.parseDiscriminatedUnion(
            ChatBoostSource,
            "source",
            .{
                .{ "premium", "premium" },
                .{ "gift_code", "gift_code" },
                .{ "giveaway", "giveaway" },
            },
            allocator,
            source,
            options,
        );
    }
};

/// The boost was obtained by the creation of Telegram Premium gift codes to boost a chat. Each such code boosts the chat 4 times for the duration of the corresponding Telegram Premium subscription.
/// Reference: https://core.telegram.org/bots/api#chatboostsourcegiftcode
pub const ChatBoostSourceGiftCode = struct {
    /// Source of the boost, always "gift_code"
    source: []const u8 = "gift_code",
    /// User for which the gift code was created
    user: User,
};

/// The boost was obtained by the creation of a Telegram Premium or a Telegram Star giveaway. This boosts the chat 4 times for the duration of the corresponding Telegram Premium subscription for Telegram Premium giveaways and prize_star_count / 500 times for one year for Telegram Star giveaways.
/// Reference: https://core.telegram.org/bots/api#chatboostsourcegiveaway
pub const ChatBoostSourceGiveaway = struct {
    /// Source of the boost, always "giveaway"
    source: []const u8 = "giveaway",
    /// Identifier of a message in the chat with the giveaway; the message could have been deleted already. May be 0 if the message isn't sent yet.
    giveaway_message_id: i64,
    /// Optional. User that won the prize in the giveaway if any; for Telegram Premium giveaways only
    user: ?User = null,
    /// Optional. The number of Telegram Stars to be split between giveaway winners; for Telegram Star giveaways only
    prize_star_count: ?i64 = null,
    /// Optional. True, if the giveaway was completed, but there was no user to win the prize
    is_unclaimed: ?bool = null,
};

/// The boost was obtained by subscribing to Telegram Premium or by gifting a Telegram Premium subscription to another user.
/// Reference: https://core.telegram.org/bots/api#chatboostsourcepremium
pub const ChatBoostSourcePremium = struct {
    /// Source of the boost, always "premium"
    source: []const u8 = "premium",
    /// User that boosted the chat
    user: User,
};

/// This object represents a boost added to a chat or changed.
/// Reference: https://core.telegram.org/bots/api#chatboostupdated
pub const ChatBoostUpdated = struct {
    /// Chat which was boosted
    chat: *const Chat,
    /// Information about the chat boost
    boost: ChatBoost,
};

/// This object contains full information about a chat.
/// Reference: https://core.telegram.org/bots/api#chatfullinfo
pub const ChatFullInfo = struct {
    /// Unique identifier for this chat. This number may have more than 32 significant bits and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a signed 64-bit integer or double-precision float type are safe for storing this identifier.
    id: i64,
    /// Type of the chat, can be either "private", "group", "supergroup" or "channel"
    type: []const u8,
    /// Identifier of the accent color for the chat name and backgrounds of the chat photo, reply header, and link preview. See accent colors for more details.
    accent_color_id: i64,
    /// The maximum number of reactions that can be set on a message in the chat
    max_reaction_count: i64,
    /// Information about types of gifts that are accepted by the chat or by the corresponding user for private chats
    accepted_gift_types: AcceptedGiftTypes,
    /// Optional. Title, for supergroups, channels and group chats
    title: ?[]const u8 = null,
    /// Optional. Username, for private chats, supergroups and channels if available
    username: ?[]const u8 = null,
    /// Optional. First name of the other party in a private chat
    first_name: ?[]const u8 = null,
    /// Optional. Last name of the other party in a private chat
    last_name: ?[]const u8 = null,
    /// Optional. True, if the supergroup chat is a forum (has topics enabled)
    is_forum: ?bool = null,
    /// Optional. True, if the chat is the direct messages chat of a channel
    is_direct_messages: ?bool = null,
    /// Optional. Chat photo
    photo: ?ChatPhoto = null,
    /// Optional. If non-empty, the list of all active chat usernames; for private chats, supergroups and channels
    active_usernames: ?[]const []const u8 = null,
    /// Optional. For private chats, the date of birth of the user
    birthdate: ?Birthdate = null,
    /// Optional. For private chats with business accounts, the intro of the business
    business_intro: ?BusinessIntro = null,
    /// Optional. For private chats with business accounts, the location of the business
    business_location: ?BusinessLocation = null,
    /// Optional. For private chats with business accounts, the opening hours of the business
    business_opening_hours: ?BusinessOpeningHours = null,
    /// Optional. For private chats, the personal channel of the user
    personal_chat: ?*const Chat = null,
    /// Optional. Information about the corresponding channel chat; for direct messages chats only
    parent_chat: ?*const Chat = null,
    /// Optional. List of available reactions allowed in the chat. If omitted, then all emoji reactions are allowed.
    available_reactions: ?[]const ReactionType = null,
    /// Optional. Custom emoji identifier of the emoji chosen by the chat for the reply header and link preview background
    background_custom_emoji_id: ?[]const u8 = null,
    /// Optional. Identifier of the accent color for the chat's profile background. See profile accent colors for more details.
    profile_accent_color_id: ?i64 = null,
    /// Optional. Custom emoji identifier of the emoji chosen by the chat for its profile background
    profile_background_custom_emoji_id: ?[]const u8 = null,
    /// Optional. Custom emoji identifier of the emoji status of the chat or the other party in a private chat
    emoji_status_custom_emoji_id: ?[]const u8 = null,
    /// Optional. Expiration date of the emoji status of the chat or the other party in a private chat, in Unix time, if any
    emoji_status_expiration_date: ?i64 = null,
    /// Optional. Bio of the other party in a private chat
    bio: ?[]const u8 = null,
    /// Optional. True, if privacy settings of the other party in the private chat allows to use tg://user?id=<user_id> links only in chats with the user
    has_private_forwards: ?bool = null,
    /// Optional. True, if the privacy settings of the other party restrict sending voice and video note messages in the private chat
    has_restricted_voice_and_video_messages: ?bool = null,
    /// Optional. True, if users need to join the supergroup before they can send messages
    join_to_send_messages: ?bool = null,
    /// Optional. True, if all users directly joining the supergroup without using an invite link need to be approved by supergroup administrators
    join_by_request: ?bool = null,
    /// Optional. Description, for groups, supergroups and channel chats
    description: ?[]const u8 = null,
    /// Optional. Primary invite link, for groups, supergroups and channel chats
    invite_link: ?[]const u8 = null,
    /// Optional. The most recent pinned message (by sending date)
    pinned_message: ?*const Message = null,
    /// Optional. Default chat member permissions, for groups and supergroups
    permissions: ?ChatPermissions = null,
    /// Optional. True, if paid media messages can be sent or forwarded to the channel chat. The field is available only for channel chats.
    can_send_paid_media: ?bool = null,
    /// Optional. For supergroups, the minimum allowed delay between consecutive messages sent by each unprivileged user; in seconds
    slow_mode_delay: ?i64 = null,
    /// Optional. For supergroups, the minimum number of boosts that a non-administrator user needs to add in order to ignore slow mode and chat permissions
    unrestrict_boost_count: ?i64 = null,
    /// Optional. The time after which all messages sent to the chat will be automatically deleted; in seconds
    message_auto_delete_time: ?i64 = null,
    /// Optional. True, if aggressive anti-spam checks are enabled in the supergroup. The field is only available to chat administrators.
    has_aggressive_anti_spam_enabled: ?bool = null,
    /// Optional. True, if non-administrators can only get the list of bots and administrators in the chat
    has_hidden_members: ?bool = null,
    /// Optional. True, if messages from the chat can't be forwarded to other chats
    has_protected_content: ?bool = null,
    /// Optional. True, if new chat members will have access to old messages; available only to chat administrators
    has_visible_history: ?bool = null,
    /// Optional. For supergroups, name of the group sticker set
    sticker_set_name: ?[]const u8 = null,
    /// Optional. True, if the bot can change the group sticker set
    can_set_sticker_set: ?bool = null,
    /// Optional. For supergroups, the name of the group's custom emoji sticker set. Custom emoji from this set can be used by all users and bots in the group.
    custom_emoji_sticker_set_name: ?[]const u8 = null,
    /// Optional. Unique identifier for the linked chat, i.e. the discussion group identifier for a channel and vice versa; for supergroups and channel chats. This identifier may be greater than 32 bits and some programming languages may have difficulty/silent defects in interpreting it. But it is smaller than 52 bits, so a signed 64 bit integer or double-precision float type are safe for storing this identifier.
    linked_chat_id: ?i64 = null,
    /// Optional. For supergroups, the location to which the supergroup is connected
    location: ?ChatLocation = null,
    /// Optional. For private chats, the rating of the user if any
    rating: ?UserRating = null,
    /// Optional. For private chats, the first audio added to the profile of the user
    first_profile_audio: ?Audio = null,
    /// Optional. The color scheme based on a unique gift that must be used for the chat's name, message replies and link previews
    unique_gift_colors: ?UniqueGiftColors = null,
    /// Optional. The number of Telegram Stars a general user has to pay to send a message to the chat
    paid_message_star_count: ?i64 = null,
    /// Optional. The bot that processes join request queries in the chat. The field is only available to chat administrators.
    guard_bot: ?User = null,
    /// Optional. The Community to which the chat belongs
    community: ?Community = null,
};

/// Represents an invite link for a chat.
/// Reference: https://core.telegram.org/bots/api#chatinvitelink
pub const ChatInviteLink = struct {
    /// The invite link. If the link was created by another chat administrator, then the second part of the link will be replaced with "...".
    invite_link: []const u8,
    /// Creator of the link
    creator: User,
    /// True, if users joining the chat via the link need to be approved by chat administrators
    creates_join_request: bool,
    /// True, if the link is primary
    is_primary: bool,
    /// True, if the link is revoked
    is_revoked: bool,
    /// Optional. Invite link name
    name: ?[]const u8 = null,
    /// Optional. Point in time (Unix timestamp) when the link will expire or has been expired
    expire_date: ?i64 = null,
    /// Optional. The maximum number of users that can be members of the chat simultaneously after joining the chat via this invite link; 1-99999
    member_limit: ?i64 = null,
    /// Optional. Number of pending join requests created using this link
    pending_join_request_count: ?i64 = null,
    /// Optional. The number of seconds the subscription will be active for before the next payment
    subscription_period: ?i64 = null,
    /// Optional. The amount of Telegram Stars a user must pay initially and after each subsequent subscription period to be a member of the chat using the link
    subscription_price: ?i64 = null,
};

/// Represents a join request sent to a chat.
/// Reference: https://core.telegram.org/bots/api#chatjoinrequest
pub const ChatJoinRequest = struct {
    /// Chat to which the request was sent
    chat: *const Chat,
    /// User that sent the join request
    from: User,
    /// Identifier of a private chat with the user who sent the join request. This number may have more than 32 significant bits and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a 64-bit integer or double-precision float type are safe for storing this identifier. The bot can use this identifier for 5 minutes to send messages until the join request is processed, assuming no other administrator contacted the user.
    user_chat_id: i64,
    /// Date the request was sent in Unix time
    date: i64,
    /// Optional. Bio of the user
    bio: ?[]const u8 = null,
    /// Optional. Chat invite link that was used by the user to send the join request
    invite_link: ?ChatInviteLink = null,
    /// Optional. Identifier of the join request query; for bots assigned to process join requests only. If present, then the bot must call sendChatJoinRequestWebApp or directly call answerChatJoinRequestQuery within 10 seconds.
    query_id: ?[]const u8 = null,
};

/// Represents a location to which a chat is connected.
/// Reference: https://core.telegram.org/bots/api#chatlocation
pub const ChatLocation = struct {
    /// The location to which the supergroup is connected. Can't be a live location.
    location: Location,
    /// Location address; 1-64 characters, as defined by the chat owner
    address: []const u8,
};

/// This object contains information about one member of a chat. Currently, the following 6 types of chat members are supported:
/// - ChatMemberOwner
/// - ChatMemberAdministrator
/// - ChatMemberMember
/// - ChatMemberRestricted
/// - ChatMemberLeft
/// - ChatMemberBanned
/// Reference: https://core.telegram.org/bots/api#chatmember
pub const ChatMember = union(enum) {
    owner: ChatMemberOwner,
    administrator: ChatMemberAdministrator,
    member: ChatMemberMember,
    restricted: ChatMemberRestricted,
    left: ChatMemberLeft,
    banned: ChatMemberBanned,

    pub fn jsonStringify(self: ChatMember, jw: anytype) !void {
        switch (self) {
            inline else => |payload| try jw.write(payload),
        }
    }

    pub fn writeMultipartJson(
        self: ChatMember,
        arena: Allocator,
        jw: *std.json.Stringify,
        pending_parts: *std.ArrayList(multipart_mod.PendingPart),
        comptime writeFn: anytype,
    ) !void {
        switch (self) {
            inline else => |payload| try writeFn(arena, jw, payload, pending_parts),
        }
    }

    pub fn jsonParse(
        allocator: Allocator,
        source: anytype,
        options: std.json.ParseOptions,
    ) std.json.ParseError(@TypeOf(source.*))!ChatMember {
        return json_mod.parseDiscriminatedUnion(
            ChatMember,
            "status",
            .{
                .{ "creator", "owner" },
                .{ "administrator", "administrator" },
                .{ "member", "member" },
                .{ "restricted", "restricted" },
                .{ "left", "left" },
                .{ "kicked", "banned" },
            },
            allocator,
            source,
            options,
        );
    }
};

/// Represents a chat member that has some additional privileges.
/// Reference: https://core.telegram.org/bots/api#chatmemberadministrator
pub const ChatMemberAdministrator = struct {
    /// The member's status in the chat, always "administrator"
    status: []const u8 = "administrator",
    /// Information about the user
    user: User,
    /// True, if the bot is allowed to edit administrator privileges of that user
    can_be_edited: bool,
    /// True, if the user's presence in the chat is hidden
    is_anonymous: bool,
    /// True, if the administrator can access the chat event log, get boost list, see hidden supergroup and channel members, report spam messages, ignore slow mode, and send messages to the chat without paying Telegram Stars. Implied by any other administrator privilege.
    can_manage_chat: bool,
    /// True, if the administrator can delete messages of other users
    can_delete_messages: bool,
    /// True, if the administrator can manage video chats
    can_manage_video_chats: bool,
    /// True, if the administrator can restrict, ban or unban chat members, or access supergroup statistics
    can_restrict_members: bool,
    /// True, if the administrator can add new administrators with a subset of their own privileges or demote administrators that they have promoted, directly or indirectly (promoted by administrators that were appointed by the user)
    can_promote_members: bool,
    /// True, if the user is allowed to change the chat title, photo and other settings
    can_change_info: bool,
    /// True, if the user is allowed to invite new users to the chat
    can_invite_users: bool,
    /// True, if the administrator can post stories to the chat
    can_post_stories: bool,
    /// True, if the administrator can edit stories posted by other users, post stories to the chat page, pin chat stories, and access the chat's story archive
    can_edit_stories: bool,
    /// True, if the administrator can delete stories posted by other users
    can_delete_stories: bool,
    /// True, if the administrator can manage chat welcome messages or directly send them in the case of bots
    can_send_welcome_messages: bool,
    /// Optional. True, if the administrator can post messages in the channel, approve suggested posts, or access channel statistics; for channels only
    can_post_messages: ?bool = null,
    /// Optional. True, if the administrator can edit messages of other users and can pin messages; for channels only
    can_edit_messages: ?bool = null,
    /// Optional. True, if the user is allowed to pin messages; for groups and supergroups only
    can_pin_messages: ?bool = null,
    /// Optional. True, if the user is allowed to create, rename, close, and reopen forum topics; for supergroups only
    can_manage_topics: ?bool = null,
    /// Optional. True, if the administrator can manage direct messages of the channel and decline suggested posts; for channels only
    can_manage_direct_messages: ?bool = null,
    /// Optional. True, if the administrator can edit the tags of regular members; for groups and supergroups only
    can_manage_tags: ?bool = null,
    /// Optional. Custom title for this user
    custom_title: ?[]const u8 = null,
};

/// Represents a chat member that was banned in the chat and can't return to the chat or view chat messages.
/// Reference: https://core.telegram.org/bots/api#chatmemberbanned
pub const ChatMemberBanned = struct {
    /// The member's status in the chat, always "kicked"
    status: []const u8 = "kicked",
    /// Information about the user
    user: User,
    /// Date when restrictions will be lifted for this user; Unix time. If 0, then the user is banned forever.
    until_date: i64,
};

/// Represents a chat member that isn't currently a member of the chat, but may join it themselves.
/// Reference: https://core.telegram.org/bots/api#chatmemberleft
pub const ChatMemberLeft = struct {
    /// The member's status in the chat, always "left"
    status: []const u8 = "left",
    /// Information about the user
    user: User,
};

/// Represents a chat member that has no additional privileges or restrictions.
/// Reference: https://core.telegram.org/bots/api#chatmembermember
pub const ChatMemberMember = struct {
    /// The member's status in the chat, always "member"
    status: []const u8 = "member",
    /// Information about the user
    user: User,
    /// Optional. Tag of the member
    tag: ?[]const u8 = null,
    /// Optional. Date when the user's subscription will expire; Unix time
    until_date: ?i64 = null,
};

/// Represents a chat member that owns the chat and has all administrator privileges.
/// Reference: https://core.telegram.org/bots/api#chatmemberowner
pub const ChatMemberOwner = struct {
    /// The member's status in the chat, always "creator"
    status: []const u8 = "creator",
    /// Information about the user
    user: User,
    /// True, if the user's presence in the chat is hidden
    is_anonymous: bool,
    /// Optional. Custom title for this user
    custom_title: ?[]const u8 = null,
};

/// Represents a chat member that is under certain restrictions in the chat. Supergroups only.
/// Reference: https://core.telegram.org/bots/api#chatmemberrestricted
pub const ChatMemberRestricted = struct {
    /// The member's status in the chat, always "restricted"
    status: []const u8 = "restricted",
    /// Information about the user
    user: User,
    /// True, if the user is a member of the chat at the moment of the request
    is_member: bool,
    /// True, if the user is allowed to send text messages, rich messages, contacts, giveaways, giveaway winners, invoices, locations and venues
    can_send_messages: bool,
    /// True, if the user is allowed to send audios
    can_send_audios: bool,
    /// True, if the user is allowed to send documents
    can_send_documents: bool,
    /// True, if the user is allowed to send photos
    can_send_photos: bool,
    /// True, if the user is allowed to send videos
    can_send_videos: bool,
    /// True, if the user is allowed to send video notes
    can_send_video_notes: bool,
    /// True, if the user is allowed to send voice notes
    can_send_voice_notes: bool,
    /// True, if the user is allowed to send polls and checklists
    can_send_polls: bool,
    /// True, if the user is allowed to send animations, games, stickers and use inline bots
    can_send_other_messages: bool,
    /// True, if the user is allowed to add web page previews to their messages
    can_add_web_page_previews: bool,
    /// True, if the user is allowed to react to messages
    can_react_to_messages: bool,
    /// True, if the user is allowed to edit their own tag
    can_edit_tag: bool,
    /// True, if the user is allowed to change the chat title, photo and other settings
    can_change_info: bool,
    /// True, if the user is allowed to invite new users to the chat
    can_invite_users: bool,
    /// True, if the user is allowed to pin messages
    can_pin_messages: bool,
    /// True, if the user is allowed to create forum topics
    can_manage_topics: bool,
    /// Date when restrictions will be lifted for this user; Unix time. If 0, then the user is restricted forever.
    until_date: i64,
    /// Optional. Tag of the member
    tag: ?[]const u8 = null,
};

/// This object represents changes in the status of a chat member.
/// Reference: https://core.telegram.org/bots/api#chatmemberupdated
pub const ChatMemberUpdated = struct {
    /// Chat the user belongs to
    chat: *const Chat,
    /// Performer of the action, which resulted in the change
    from: User,
    /// Date the change was done in Unix time
    date: i64,
    /// Previous information about the chat member
    old_chat_member: ChatMember,
    /// New information about the chat member
    new_chat_member: ChatMember,
    /// Optional. Chat invite link, which was used by the user to join the chat; for joining by invite link events only
    invite_link: ?ChatInviteLink = null,
    /// Optional. True, if the user joined the chat after sending a direct join request without using an invite link and being approved by an administrator
    via_join_request: ?bool = null,
    /// Optional. True, if the user joined the chat via a chat folder invite link
    via_chat_folder_invite_link: ?bool = null,
};

/// Describes a service message about an ownership change in the chat.
/// Reference: https://core.telegram.org/bots/api#chatownerchanged
pub const ChatOwnerChanged = struct {
    /// The new owner of the chat
    new_owner: User,
};

/// Describes a service message about the chat owner leaving the chat.
/// Reference: https://core.telegram.org/bots/api#chatownerleft
pub const ChatOwnerLeft = struct {
    /// Optional. The user who will become the new owner of the chat if the previous owner does not return to the chat
    new_owner: ?User = null,
};

/// Describes actions that a non-administrator user is allowed to take in a chat.
/// Reference: https://core.telegram.org/bots/api#chatpermissions
pub const ChatPermissions = struct {
    /// Optional. True, if the user is allowed to send text messages, rich messages, contacts, giveaways, giveaway winners, invoices, locations and venues
    can_send_messages: ?bool = null,
    /// Optional. True, if the user is allowed to send audios
    can_send_audios: ?bool = null,
    /// Optional. True, if the user is allowed to send documents
    can_send_documents: ?bool = null,
    /// Optional. True, if the user is allowed to send photos
    can_send_photos: ?bool = null,
    /// Optional. True, if the user is allowed to send videos
    can_send_videos: ?bool = null,
    /// Optional. True, if the user is allowed to send video notes
    can_send_video_notes: ?bool = null,
    /// Optional. True, if the user is allowed to send voice notes
    can_send_voice_notes: ?bool = null,
    /// Optional. True, if the user is allowed to send polls and checklists
    can_send_polls: ?bool = null,
    /// Optional. True, if the user is allowed to send animations, games, stickers and use inline bots
    can_send_other_messages: ?bool = null,
    /// Optional. True, if the user is allowed to add web page previews to their messages
    can_add_web_page_previews: ?bool = null,
    /// Optional. True, if the user is allowed to react to messages. If omitted, defaults to the value of can_send_messages.
    can_react_to_messages: ?bool = null,
    /// Optional. True, if the user is allowed to edit their own tag. If omitted, defaults to the value of can_pin_messages.
    can_edit_tag: ?bool = null,
    /// Optional. True, if the user is allowed to change the chat title, photo and other settings. Ignored in public supergroups.
    can_change_info: ?bool = null,
    /// Optional. True, if the user is allowed to invite new users to the chat
    can_invite_users: ?bool = null,
    /// Optional. True, if the user is allowed to pin messages. Ignored in public supergroups.
    can_pin_messages: ?bool = null,
    /// Optional. True, if the user is allowed to create forum topics. If omitted, defaults to the value of can_pin_messages.
    can_manage_topics: ?bool = null,
};

/// This object represents a chat photo.
/// Reference: https://core.telegram.org/bots/api#chatphoto
pub const ChatPhoto = struct {
    /// File identifier of small (160x160) chat photo. This file_id can be used only for photo download and only for as long as the photo is not changed.
    small_file_id: []const u8,
    /// Unique file identifier of small (160x160) chat photo, which is supposed to be the same over time and for different bots. Can't be used to download or reuse the file.
    small_file_unique_id: []const u8,
    /// File identifier of big (640x640) chat photo. This file_id can be used only for photo download and only for as long as the photo is not changed.
    big_file_id: []const u8,
    /// Unique file identifier of big (640x640) chat photo, which is supposed to be the same over time and for different bots. Can't be used to download or reuse the file.
    big_file_unique_id: []const u8,
};

/// This object contains information about a chat that was shared with the bot using a KeyboardButtonRequestChat button.
/// Reference: https://core.telegram.org/bots/api#chatshared
pub const ChatShared = struct {
    /// Identifier of the request
    request_id: i64,
    /// Identifier of the shared chat. This number may have more than 32 significant bits and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a 64-bit integer or double-precision float type are safe for storing this identifier. The bot may not have access to the chat and could be unable to use this identifier, unless the chat is already known to the bot by some other means.
    chat_id: i64,
    /// Optional. Title of the chat, if the title was requested by the bot
    title: ?[]const u8 = null,
    /// Optional. Username of the chat, if the username was requested by the bot and available
    username: ?[]const u8 = null,
    /// Optional. Available sizes of the chat photo, if the photo was requested by the bot
    photo: ?[]const PhotoSize = null,
};

/// Describes a checklist.
/// Reference: https://core.telegram.org/bots/api#checklist
pub const Checklist = struct {
    /// Title of the checklist
    title: []const u8,
    /// List of tasks in the checklist
    tasks: []const ChecklistTask,
    /// Optional. Special entities that appear in the checklist title
    title_entities: ?[]const MessageEntity = null,
    /// Optional. True, if users other than the creator of the list can add tasks to the list
    others_can_add_tasks: ?bool = null,
    /// Optional. True, if users other than the creator of the list can mark tasks as done or not done
    others_can_mark_tasks_as_done: ?bool = null,
};

/// Describes a task in a checklist.
/// Reference: https://core.telegram.org/bots/api#checklisttask
pub const ChecklistTask = struct {
    /// Unique identifier of the task
    id: i64,
    /// Text of the task
    text: []const u8,
    /// Optional. Special entities that appear in the task text
    text_entities: ?[]const MessageEntity = null,
    /// Optional. User that completed the task; omitted if the task wasn't completed by a user
    completed_by_user: ?User = null,
    /// Optional. Chat that completed the task; omitted if the task wasn't completed by a chat
    completed_by_chat: ?*const Chat = null,
    /// Optional. Point in time (Unix timestamp) when the task was completed; 0 if the task wasn't completed
    completion_date: ?i64 = null,
};

/// Describes a service message about tasks added to a checklist.
/// Reference: https://core.telegram.org/bots/api#checklisttasksadded
pub const ChecklistTasksAdded = struct {
    /// List of tasks added to the checklist
    tasks: []const ChecklistTask,
    /// Optional. Message containing the checklist to which the tasks were added. Note that the Message object in this field will not contain the reply_to_message field even if it itself is a reply.
    checklist_message: ?*const Message = null,
};

/// Describes a service message about checklist tasks marked as done or not done.
/// Reference: https://core.telegram.org/bots/api#checklisttasksdone
pub const ChecklistTasksDone = struct {
    /// Optional. Message containing the checklist whose tasks were marked as done or not done. Note that the Message object in this field will not contain the reply_to_message field even if it itself is a reply.
    checklist_message: ?*const Message = null,
    /// Optional. Identifiers of the tasks that were marked as done
    marked_as_done_task_ids: ?[]const i64 = null,
    /// Optional. Identifiers of the tasks that were marked as not done
    marked_as_not_done_task_ids: ?[]const i64 = null,
};

/// Represents a result of an inline query that was chosen by the user and sent to their chat partner.
/// Note: It is necessary to enable inline feedback via @BotFather in order to receive these objects in updates.
/// Reference: https://core.telegram.org/bots/api#choseninlineresult
pub const ChosenInlineResult = struct {
    /// The unique identifier for the result that was chosen
    result_id: []const u8,
    /// The user that chose the result
    from: User,
    /// The query that was used to obtain the result
    query: []const u8,
    /// Optional. Sender location, only for bots that require user location
    location: ?Location = null,
    /// Optional. Identifier of the sent inline message. Available only if there is an inline keyboard attached to the message. Will be also received in callback queries and can be used to edit the message.
    inline_message_id: ?[]const u8 = null,
};

/// Represents a community (a group of chats).
/// Reference: https://core.telegram.org/bots/api#community
pub const Community = struct {
    /// Unique identifier for this community. This number may have more than 32 significant bits and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a signed 64-bit integer or double-precision float type are safe for storing this identifier.
    id: i64,
    /// Name of the community
    name: []const u8,
};

/// Describes a service message about a chat or a bot being added to a community.
/// Reference: https://core.telegram.org/bots/api#communitychatadded
pub const CommunityChatAdded = struct {
    /// The new community to which the chat or the bot belongs
    community: Community,
};

/// Describes a service message about a chat being joined by a user from a community.
/// Reference: https://core.telegram.org/bots/api#communitychatjoined
pub const CommunityChatJoined = struct {
    /// The community from which the chat was joined
    community: Community,
};

/// Describes a service message about a chat or a bot being removed from a community. Currently holds no information.
/// Reference: https://core.telegram.org/bots/api#communitychatremoved
pub const CommunityChatRemoved = struct {};

/// This object represents a phone contact.
/// Reference: https://core.telegram.org/bots/api#contact
pub const Contact = struct {
    /// Contact's phone number
    phone_number: []const u8,
    /// Contact's first name
    first_name: []const u8,
    /// Optional. Contact's last name
    last_name: ?[]const u8 = null,
    /// Optional. Contact's user identifier in Telegram. This number may have more than 32 significant bits and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a 64-bit integer or double-precision float type are safe for storing this identifier.
    user_id: ?i64 = null,
    /// Optional. Additional data about the contact in the form of a vCard
    vcard: ?[]const u8 = null,
};

/// This object represents an inline keyboard button that copies specified text to the clipboard.
/// Reference: https://core.telegram.org/bots/api#copytextbutton
pub const CopyTextButton = struct {
    /// The text to be copied to the clipboard; 1-256 characters
    text: []const u8,
};

/// This object represents an animated emoji that displays a random value.
/// Reference: https://core.telegram.org/bots/api#dice
pub const Dice = struct {
    /// Emoji on which the dice throw animation is based
    emoji: []const u8,
    /// Value of the dice, 1-6 for "🎲", "🎯" and "🎳" base emoji, 1-5 for "🏀" and "⚽" base emoji, 1-64 for "🎰" base emoji
    value: i64,
};

/// Describes a service message about a change in the price of direct messages sent to a channel chat.
/// Reference: https://core.telegram.org/bots/api#directmessagepricechanged
pub const DirectMessagePriceChanged = struct {
    /// True, if direct messages are enabled for the channel chat; False otherwise
    are_direct_messages_enabled: bool,
    /// Optional. The new number of Telegram Stars that must be paid by users for each direct message sent to the channel. Does not apply to users who have been exempted by administrators. Defaults to 0.
    direct_message_star_count: ?i64 = null,
};

/// Describes a topic of a direct messages chat.
/// Reference: https://core.telegram.org/bots/api#directmessagestopic
pub const DirectMessagesTopic = struct {
    /// Unique identifier of the topic. This number may have more than 32 significant bits and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a 64-bit integer or double-precision float type are safe for storing this identifier.
    topic_id: i64,
    /// Optional. Information about the user that created the topic. Currently, it is always present.
    user: ?User = null,
};

/// This object represents a disabled button which does nothing. Currently holds no information.
/// Reference: https://core.telegram.org/bots/api#disabledbutton
pub const DisabledButton = struct {};

/// This object represents a general file (as opposed to photos, voice messages and audio files).
/// Reference: https://core.telegram.org/bots/api#document
pub const Document = struct {
    /// Identifier for this file, which can be used to download or reuse the file
    file_id: []const u8,
    /// Unique identifier for this file, which is supposed to be the same over time and for different bots. Can't be used to download or reuse the file.
    file_unique_id: []const u8,
    /// Optional. Document thumbnail as defined by the sender
    thumbnail: ?PhotoSize = null,
    /// Optional. Original filename as defined by the sender
    file_name: ?[]const u8 = null,
    /// Optional. MIME type of the file as defined by the sender
    mime_type: ?[]const u8 = null,
    /// Optional. File size in bytes. It can be bigger than 2^31 and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a signed 64-bit integer or double-precision float type are safe for storing this value.
    file_size: ?i64 = null,
};

/// Describes data required for decrypting and authenticating EncryptedPassportElement. See the Telegram Passport Documentation for a complete description of the data decryption and authentication processes.
/// Reference: https://core.telegram.org/bots/api#encryptedcredentials
pub const EncryptedCredentials = struct {
    /// Base64-encoded encrypted JSON-serialized data with unique user's payload, data hashes and secrets required for EncryptedPassportElement decryption and authentication
    data: []const u8,
    /// Base64-encoded data hash for data authentication
    hash: []const u8,
    /// Base64-encoded secret, encrypted with the bot's public RSA key, required for data decryption
    secret: []const u8,
};

/// Describes documents or other Telegram Passport elements shared with the bot by the user.
/// Reference: https://core.telegram.org/bots/api#encryptedpassportelement
pub const EncryptedPassportElement = struct {
    /// Element type. One of "personal_details", "passport", "driver_license", "identity_card", "internal_passport", "address", "utility_bill", "bank_statement", "rental_agreement", "passport_registration", "temporary_registration", "phone_number", "email".
    type: []const u8,
    /// Base64-encoded element hash for using in PassportElementErrorUnspecified
    hash: []const u8,
    /// Optional. Base64-encoded encrypted Telegram Passport element data provided by the user; available only for "personal_details", "passport", "driver_license", "identity_card", "internal_passport" and "address" types. Can be decrypted and verified using the accompanying EncryptedCredentials.
    data: ?[]const u8 = null,
    /// Optional. User's verified phone number; available only for "phone_number" type
    phone_number: ?[]const u8 = null,
    /// Optional. User's verified email address; available only for "email" type
    email: ?[]const u8 = null,
    /// Optional. Array of encrypted files with documents provided by the user; available only for "utility_bill", "bank_statement", "rental_agreement", "passport_registration" and "temporary_registration" types. Files can be decrypted and verified using the accompanying EncryptedCredentials.
    files: ?[]const PassportFile = null,
    /// Optional. Encrypted file with the front side of the document, provided by the user; available only for "passport", "driver_license", "identity_card" and "internal_passport". The file can be decrypted and verified using the accompanying EncryptedCredentials.
    front_side: ?PassportFile = null,
    /// Optional. Encrypted file with the reverse side of the document, provided by the user; available only for "driver_license" and "identity_card". The file can be decrypted and verified using the accompanying EncryptedCredentials.
    reverse_side: ?PassportFile = null,
    /// Optional. Encrypted file with the selfie of the user holding a document, provided by the user; available if requested for "passport", "driver_license", "identity_card" and "internal_passport". The file can be decrypted and verified using the accompanying EncryptedCredentials.
    selfie: ?PassportFile = null,
    /// Optional. Array of encrypted files with translated versions of documents provided by the user; available if requested for "passport", "driver_license", "identity_card", "internal_passport", "utility_bill", "bank_statement", "rental_agreement", "passport_registration" and "temporary_registration" types. Files can be decrypted and verified using the accompanying EncryptedCredentials.
    translation: ?[]const PassportFile = null,
};

/// Reference: https://core.telegram.org/bots/api#ephemeralmessageparameters
pub const EphemeralMessageParameters = struct {
    /// Identifier of the user who will receive the message. It is not guaranteed that the user will receive the message, especially if they are offline. See here for more details.
    receiver_user_id: i64,
    /// Optional. Identifier of the callback query which triggered the message, if any
    callback_query_id: ?[]const u8 = null,
    /// Optional. Pass True if the ephemeral message must be shown in place of the original message. Must be False for callback queries from ephemeral messages, which must be edited using regular editEphemeralMessage... methods.
    replace_callback_query_message: ?bool = null,
};

/// This object contains information about a message that is being replied to, which may come from another chat or forum topic.
/// Reference: https://core.telegram.org/bots/api#externalreplyinfo
pub const ExternalReplyInfo = struct {
    /// Origin of the message replied to by the given message
    origin: MessageOrigin,
    /// Optional. Chat the original message belongs to. Available only if the chat is a supergroup or a channel.
    chat: ?*const Chat = null,
    /// Optional. Unique message identifier inside the original chat. Available only if the original chat is a supergroup or a channel.
    message_id: ?i64 = null,
    /// Optional. Options used for link preview generation for the original message, if it is a text message
    link_preview_options: ?LinkPreviewOptions = null,
    /// Optional. Message is an animation, information about the animation
    animation: ?Animation = null,
    /// Optional. Message is an audio file, information about the file
    audio: ?Audio = null,
    /// Optional. Message is a general file, information about the file
    document: ?Document = null,
    /// Optional. Message is a live photo, information about the live photo
    live_photo: ?LivePhoto = null,
    /// Optional. Message contains paid media; information about the paid media
    paid_media: ?PaidMediaInfo = null,
    /// Optional. Message is a photo, available sizes of the photo
    photo: ?[]const PhotoSize = null,
    /// Optional. Message is a sticker, information about the sticker
    sticker: ?Sticker = null,
    /// Optional. Message is a forwarded story
    story: ?Story = null,
    /// Optional. Message is a video, information about the video
    video: ?Video = null,
    /// Optional. Message is a video note, information about the video message
    video_note: ?VideoNote = null,
    /// Optional. Message is a voice message, information about the file
    voice: ?Voice = null,
    /// Optional. True, if the message media is covered by a spoiler animation
    has_media_spoiler: ?bool = null,
    /// Optional. Message is a checklist
    checklist: ?Checklist = null,
    /// Optional. Message is a shared contact, information about the contact
    contact: ?Contact = null,
    /// Optional. Message is a dice with random value
    dice: ?Dice = null,
    /// Optional. Message is a game, information about the game. More about games: https://core.telegram.org/bots/api#games
    game: ?Game = null,
    /// Optional. Message is a scheduled giveaway, information about the giveaway
    giveaway: ?Giveaway = null,
    /// Optional. A giveaway with public winners was completed
    giveaway_winners: ?GiveawayWinners = null,
    /// Optional. Message is an invoice for a payment, information about the invoice. More about payments: https://core.telegram.org/bots/api#payments
    invoice: ?Invoice = null,
    /// Optional. Message is a shared location, information about the location
    location: ?Location = null,
    /// Optional. Message is a native poll, information about the poll
    poll: ?Poll = null,
    /// Optional. Message is a venue, information about the venue
    venue: ?Venue = null,
};

/// This object represents a file ready to be downloaded. The file can be downloaded via the link https://api.telegram.org/file/bot<token>/<file_path>. It is guaranteed that the link will be valid for at least 1 hour. When the link expires, a new one can be requested by calling getFile.
/// Reference: https://core.telegram.org/bots/api#file
pub const File = struct {
    /// Identifier for this file, which can be used to download or reuse the file
    file_id: []const u8,
    /// Unique identifier for this file, which is supposed to be the same over time and for different bots. Can't be used to download or reuse the file.
    file_unique_id: []const u8,
    /// Optional. File size in bytes. It can be bigger than 2^31 and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a signed 64-bit integer or double-precision float type are safe for storing this value.
    file_size: ?i64 = null,
    /// Optional. File path. Use https://api.telegram.org/file/bot<token>/<file_path> to get the file.
    file_path: ?[]const u8 = null,
};

/// Upon receiving a message with this object, Telegram clients will display a reply interface to the user (act as if the user has selected the bot's message and tapped 'Reply'). This can be extremely useful if you want to create user-friendly step-by-step interfaces without having to sacrifice privacy mode. Not supported in channels and for messages sent on behalf of a user account.
/// Reference: https://core.telegram.org/bots/api#forcereply
pub const ForceReply = struct {
    /// Shows reply interface to the user, as if they had manually selected the bot's message and tapped 'Reply'
    force_reply: bool,
    /// Optional. The placeholder to be shown in the input field when the reply is active; 1-64 characters
    input_field_placeholder: ?[]const u8 = null,
    /// Optional. Use this parameter if you want to force reply from specific users only. Targets: 1) users that are @mentioned in the text of the Message object; 2) if the bot's message is a reply to a message in the same chat and forum topic, sender of the original message.
    selective: ?bool = null,
};

/// This object represents a forum topic.
/// Reference: https://core.telegram.org/bots/api#forumtopic
pub const ForumTopic = struct {
    /// Unique identifier of the forum topic
    message_thread_id: i64,
    /// Name of the topic
    name: []const u8,
    /// Color of the topic icon in RGB format
    icon_color: i64,
    /// Optional. Unique identifier of the custom emoji shown as the topic icon
    icon_custom_emoji_id: ?[]const u8 = null,
    /// Optional. True, if the name of the topic wasn't specified explicitly by its creator and likely needs to be changed by the bot
    is_name_implicit: ?bool = null,
};

/// This object represents a service message about a forum topic closed in the chat. Currently holds no information.
/// Reference: https://core.telegram.org/bots/api#forumtopicclosed
pub const ForumTopicClosed = struct {};

/// This object represents a service message about a new forum topic created in the chat.
/// Reference: https://core.telegram.org/bots/api#forumtopiccreated
pub const ForumTopicCreated = struct {
    /// Name of the topic
    name: []const u8,
    /// Color of the topic icon in RGB format
    icon_color: i64,
    /// Optional. Unique identifier of the custom emoji shown as the topic icon
    icon_custom_emoji_id: ?[]const u8 = null,
    /// Optional. True, if the name of the topic wasn't specified explicitly by its creator and likely needs to be changed by the bot
    is_name_implicit: ?bool = null,
};

/// This object represents a service message about an edited forum topic.
/// Reference: https://core.telegram.org/bots/api#forumtopicedited
pub const ForumTopicEdited = struct {
    /// Optional. New name of the topic, if it was edited
    name: ?[]const u8 = null,
    /// Optional. New identifier of the custom emoji shown as the topic icon, if it was edited; an empty string if the icon was removed
    icon_custom_emoji_id: ?[]const u8 = null,
};

/// This object represents a service message about a forum topic reopened in the chat. Currently holds no information.
/// Reference: https://core.telegram.org/bots/api#forumtopicreopened
pub const ForumTopicReopened = struct {};

/// This object represents a game. Use BotFather to create and edit games, their short names will act as unique identifiers.
/// Reference: https://core.telegram.org/bots/api#game
pub const Game = struct {
    /// Title of the game
    title: []const u8,
    /// Description of the game
    description: []const u8,
    /// Photo that will be displayed in the game message in chats
    photo: []const PhotoSize,
    /// Optional. Brief description of the game or high scores included in the game message. Can be automatically edited to include current high scores for the game when the bot calls setGameScore, or manually edited using editMessageText. 0-4096 characters.
    text: ?[]const u8 = null,
    /// Optional. Special entities that appear in text, such as usernames, URLs, bot commands, etc.
    text_entities: ?[]const MessageEntity = null,
    /// Optional. Animation that will be displayed in the game message in chats. Upload via BotFather.
    animation: ?Animation = null,
};

/// This object represents one row of the high scores table for a game.
/// Reference: https://core.telegram.org/bots/api#gamehighscore
pub const GameHighScore = struct {
    /// Position in high score table for the game
    position: i64,
    /// User
    user: User,
    /// Score
    score: i64,
};

/// This object represents a service message about General forum topic hidden in the chat. Currently holds no information.
/// Reference: https://core.telegram.org/bots/api#generalforumtopichidden
pub const GeneralForumTopicHidden = struct {};

/// This object represents a service message about General forum topic unhidden in the chat. Currently holds no information.
/// Reference: https://core.telegram.org/bots/api#generalforumtopicunhidden
pub const GeneralForumTopicUnhidden = struct {};

/// This object represents a gift that can be sent by the bot.
/// Reference: https://core.telegram.org/bots/api#gift
pub const Gift = struct {
    /// Unique identifier of the gift
    id: []const u8,
    /// The sticker that represents the gift
    sticker: Sticker,
    /// The number of Telegram Stars that must be paid to send the sticker
    star_count: i64,
    /// Optional. The number of Telegram Stars that must be paid to upgrade the gift to a unique one
    upgrade_star_count: ?i64 = null,
    /// Optional. True, if the gift can only be purchased by Telegram Premium subscribers
    is_premium: ?bool = null,
    /// Optional. True, if the gift can be used (after being upgraded) to customize a user's appearance
    has_colors: ?bool = null,
    /// Optional. The total number of gifts of this type that can be sent by all users; for limited gifts only
    total_count: ?i64 = null,
    /// Optional. The number of remaining gifts of this type that can be sent by all users; for limited gifts only
    remaining_count: ?i64 = null,
    /// Optional. The total number of gifts of this type that can be sent by the bot; for limited gifts only
    personal_total_count: ?i64 = null,
    /// Optional. The number of remaining gifts of this type that can be sent by the bot; for limited gifts only
    personal_remaining_count: ?i64 = null,
    /// Optional. Background of the gift
    background: ?GiftBackground = null,
    /// Optional. The total number of different unique gifts that can be obtained by upgrading the gift
    unique_gift_variant_count: ?i64 = null,
    /// Optional. Information about the chat that published the gift
    publisher_chat: ?*const Chat = null,
};

/// This object describes the background of a gift.
/// Reference: https://core.telegram.org/bots/api#giftbackground
pub const GiftBackground = struct {
    /// Center color of the background in RGB format
    center_color: i64,
    /// Edge color of the background in RGB format
    edge_color: i64,
    /// Text color of the background in RGB format
    text_color: i64,
};

/// Describes a service message about a regular gift that was sent or received.
/// Reference: https://core.telegram.org/bots/api#giftinfo
pub const GiftInfo = struct {
    /// Information about the gift
    gift: Gift,
    /// Optional. Unique identifier of the received gift for the bot; only present for gifts received on behalf of business accounts
    owned_gift_id: ?[]const u8 = null,
    /// Optional. Number of Telegram Stars that can be claimed by the receiver by converting the gift; omitted if conversion to Telegram Stars is impossible
    convert_star_count: ?i64 = null,
    /// Optional. Number of Telegram Stars that were prepaid for the ability to upgrade the gift
    prepaid_upgrade_star_count: ?i64 = null,
    /// Optional. True, if the gift's upgrade was purchased after the gift was sent
    is_upgrade_separate: ?bool = null,
    /// Optional. True, if the gift can be upgraded to a unique gift
    can_be_upgraded: ?bool = null,
    /// Optional. Text of the message that was added to the gift
    text: ?[]const u8 = null,
    /// Optional. Special entities that appear in the text
    entities: ?[]const MessageEntity = null,
    /// Optional. True, if the sender and gift text are shown only to the gift receiver; otherwise, everyone will be able to see them
    is_private: ?bool = null,
    /// Optional. Unique number reserved for this gift when upgraded. See the number field in UniqueGift.
    unique_gift_number: ?i64 = null,
};

/// This object represent a list of gifts.
/// Reference: https://core.telegram.org/bots/api#gifts
pub const Gifts = struct {
    /// The list of gifts
    gifts: []const Gift,
};

/// This object represents a message about a scheduled giveaway.
/// Reference: https://core.telegram.org/bots/api#giveaway
pub const Giveaway = struct {
    /// The list of chats which the user must join to participate in the giveaway
    chats: []const Chat,
    /// Point in time (Unix timestamp) when winners of the giveaway will be selected
    winners_selection_date: i64,
    /// The number of users which are supposed to be selected as winners of the giveaway
    winner_count: i64,
    /// Optional. True, if only users who join the chats after the giveaway started should be eligible to win
    only_new_members: ?bool = null,
    /// Optional. True, if the list of giveaway winners will be visible to everyone
    has_public_winners: ?bool = null,
    /// Optional. Description of additional giveaway prize
    prize_description: ?[]const u8 = null,
    /// Optional. A list of two-letter ISO 3166-1 alpha-2 country codes indicating the countries from which eligible users for the giveaway must come. If empty, then all users can participate in the giveaway. Users with a phone number that was bought on Fragment can always participate in giveaways.
    country_codes: ?[]const []const u8 = null,
    /// Optional. The number of Telegram Stars to be split between giveaway winners; for Telegram Star giveaways only
    prize_star_count: ?i64 = null,
    /// Optional. The number of months the Telegram Premium subscription won from the giveaway will be active for; for Telegram Premium giveaways only
    premium_subscription_month_count: ?i64 = null,
};

/// This object represents a service message about the completion of a giveaway without public winners.
/// Reference: https://core.telegram.org/bots/api#giveawaycompleted
pub const GiveawayCompleted = struct {
    /// Number of winners in the giveaway
    winner_count: i64,
    /// Optional. Number of undistributed prizes
    unclaimed_prize_count: ?i64 = null,
    /// Optional. Message with the giveaway that was completed, if it wasn't deleted
    giveaway_message: ?*const Message = null,
    /// Optional. True, if the giveaway is a Telegram Star giveaway. Otherwise, currently, the giveaway is a Telegram Premium giveaway.
    is_star_giveaway: ?bool = null,
};

/// This object represents a service message about the creation of a scheduled giveaway.
/// Reference: https://core.telegram.org/bots/api#giveawaycreated
pub const GiveawayCreated = struct {
    /// Optional. The number of Telegram Stars to be split between giveaway winners; for Telegram Star giveaways only
    prize_star_count: ?i64 = null,
};

/// This object represents a message about the completion of a giveaway with public winners.
/// Reference: https://core.telegram.org/bots/api#giveawaywinners
pub const GiveawayWinners = struct {
    /// The chat that created the giveaway
    chat: *const Chat,
    /// Identifier of the message with the giveaway in the chat
    giveaway_message_id: i64,
    /// Point in time (Unix timestamp) when winners of the giveaway were selected
    winners_selection_date: i64,
    /// Total number of winners in the giveaway
    winner_count: i64,
    /// List of up to 100 winners of the giveaway
    winners: []const User,
    /// Optional. The number of other chats the user had to join in order to be eligible for the giveaway
    additional_chat_count: ?i64 = null,
    /// Optional. The number of Telegram Stars that were split between giveaway winners; for Telegram Star giveaways only
    prize_star_count: ?i64 = null,
    /// Optional. The number of months the Telegram Premium subscription won from the giveaway will be active for; for Telegram Premium giveaways only
    premium_subscription_month_count: ?i64 = null,
    /// Optional. Number of undistributed prizes
    unclaimed_prize_count: ?i64 = null,
    /// Optional. True, if only users who had joined the chats after the giveaway started were eligible to win
    only_new_members: ?bool = null,
    /// Optional. True, if the giveaway was canceled because the payment for it was refunded
    was_refunded: ?bool = null,
    /// Optional. Description of additional giveaway prize
    prize_description: ?[]const u8 = null,
};

/// This object describes a message that was deleted or is otherwise inaccessible to the bot.
/// Reference: https://core.telegram.org/bots/api#inaccessiblemessage
pub const InaccessibleMessage = struct {
    /// Chat the message belonged to
    chat: *const Chat,
    /// Unique message identifier inside the chat
    message_id: i64,
    /// Always 0. The field can be used to differentiate regular and inaccessible messages.
    date: i64,
};

/// This object represents one button of an inline keyboard. Exactly one of the fields other than text, icon_custom_emoji_id, and style must be used to specify the type of the button.
/// Reference: https://core.telegram.org/bots/api#inlinekeyboardbutton
pub const InlineKeyboardButton = struct {
    /// Label text on the button
    text: []const u8,
    /// Optional. Unique identifier of the custom emoji shown before the text of the button. Can only be used by bots that purchased additional usernames on Fragment or in the messages directly sent by the bot to private, group and supergroup chats if the owner of the bot has a Telegram Premium subscription.
    icon_custom_emoji_id: ?[]const u8 = null,
    /// Optional. Style of the button. Must be one of "danger" (red), "success" (green) or "primary" (blue). If omitted, then an app-specific style is used.
    style: ?[]const u8 = null,
    /// Optional. HTTP or tg:// URL to be opened when the button is pressed. Links tg://user?id=<user_id> can be used to mention a user by their identifier without using a username, if this is allowed by their privacy settings.
    url: ?[]const u8 = null,
    /// Optional. Data to be sent in a callback query to the bot when the button is pressed, 1-64 bytes
    callback_data: ?[]const u8 = null,
    /// Optional. Description of the Web App that will be launched when the user presses the button. The Web App will be able to send an arbitrary message on behalf of the user using the method answerWebAppQuery. Available only in private chats between a user and the bot. Not supported for messages sent on behalf of a business account.
    web_app: ?WebAppInfo = null,
    /// Optional. An HTTPS URL used to automatically authorize the user. Can be used as a replacement for the Telegram Login Widget. Not supported for ephemeral messages.
    login_url: ?LoginUrl = null,
    /// Optional. If set, pressing the button will prompt the user to select one of their chats, open that chat and insert the bot's username and the specified inline query in the input field. May be empty, in which case just the bot's username will be inserted. Not supported for messages sent in channel direct messages chats and on behalf of a business account.
    switch_inline_query: ?[]const u8 = null,
    /// Optional. If set, pressing the button will insert the bot's username and the specified inline query in the current chat's input field. May be empty, in which case only the bot's username will be inserted. This offers a quick way for the user to open your bot in inline mode in the same chat - good for selecting something from multiple options. Not supported in channels and for messages sent in channel direct messages chats and on behalf of a business account.
    switch_inline_query_current_chat: ?[]const u8 = null,
    /// Optional. If set, pressing the button will prompt the user to select one of their chats of the specified type, open that chat and insert the bot's username and the specified inline query in the input field. Not supported for messages sent in channel direct messages chats and on behalf of a business account.
    switch_inline_query_chosen_chat: ?SwitchInlineQueryChosenChat = null,
    /// Optional. Description of the button that copies the specified text to the clipboard
    copy_text: ?CopyTextButton = null,
    /// Optional. Description of the game that will be launched when the user presses the button. NOTE: This type of button must always be the first button in the first row.
    callback_game: ?CallbackGame = null,
    /// Optional. Specify True, to send a Pay button. Substrings "⭐" and "XTR" in the buttons's text will be replaced with a Telegram Star icon. NOTE: This type of button must always be the first button in the first row and can only be used in invoice messages.
    pay: ?bool = null,
    /// Optional. If set, then the button is disabled and does nothing
    disabled: ?DisabledButton = null,
};

/// This object represents an inline keyboard that appears right next to the message it belongs to.
/// Reference: https://core.telegram.org/bots/api#inlinekeyboardmarkup
pub const InlineKeyboardMarkup = struct {
    /// Array of button rows, each represented by an Array of InlineKeyboardButton objects
    inline_keyboard: []const []const InlineKeyboardButton,
    /// Optional. Pass True if the reply interface must be shown to the user, as if they had manually selected the bot's message and tapped 'Reply'. The value of the field can't be changed when the inline keyboard is edited.
    force_reply: ?bool = null,
};

/// This object represents an incoming inline query. When the user sends an empty query, your bot could return some default or trending results.
/// Reference: https://core.telegram.org/bots/api#inlinequery
pub const InlineQuery = struct {
    /// Unique identifier for this query
    id: []const u8,
    /// Sender
    from: User,
    /// Text of the query (up to 256 characters)
    query: []const u8,
    /// Offset of the results to be returned, can be controlled by the bot
    offset: []const u8,
    /// Optional. Type of the chat from which the inline query was sent. Can be either "sender" for a private chat with the inline query sender, "private", "group", "supergroup", or "channel". The chat type should be always known for requests sent from official clients and most third-party clients, unless the request was sent from a secret chat.
    chat_type: ?[]const u8 = null,
    /// Optional. Sender location, only for bots that request user location
    location: ?Location = null,
};

/// This object represents one result of an inline query. Telegram clients currently support results of the following 20 types:
/// - InlineQueryResultCachedAudio
/// - InlineQueryResultCachedDocument
/// - InlineQueryResultCachedGif
/// - InlineQueryResultCachedMpeg4Gif
/// - InlineQueryResultCachedPhoto
/// - InlineQueryResultCachedSticker
/// - InlineQueryResultCachedVideo
/// - InlineQueryResultCachedVoice
/// - InlineQueryResultArticle
/// - InlineQueryResultAudio
/// - InlineQueryResultContact
/// - InlineQueryResultGame
/// - InlineQueryResultDocument
/// - InlineQueryResultGif
/// - InlineQueryResultLocation
/// - InlineQueryResultMpeg4Gif
/// - InlineQueryResultPhoto
/// - InlineQueryResultVenue
/// - InlineQueryResultVideo
/// - InlineQueryResultVoice
/// Note: All URLs passed in inline query results will be available to end users and therefore must be assumed to be public.
/// Reference: https://core.telegram.org/bots/api#inlinequeryresult
pub const InlineQueryResult = union(enum) {
    cached_audio: InlineQueryResultCachedAudio,
    cached_document: InlineQueryResultCachedDocument,
    cached_gif: InlineQueryResultCachedGif,
    cached_mpeg4_gif: InlineQueryResultCachedMpeg4Gif,
    cached_photo: InlineQueryResultCachedPhoto,
    cached_sticker: InlineQueryResultCachedSticker,
    cached_video: InlineQueryResultCachedVideo,
    cached_voice: InlineQueryResultCachedVoice,
    article: InlineQueryResultArticle,
    audio: InlineQueryResultAudio,
    contact: InlineQueryResultContact,
    game: InlineQueryResultGame,
    document: InlineQueryResultDocument,
    gif: InlineQueryResultGif,
    location: InlineQueryResultLocation,
    mpeg4_gif: InlineQueryResultMpeg4Gif,
    photo: InlineQueryResultPhoto,
    venue: InlineQueryResultVenue,
    video: InlineQueryResultVideo,
    voice: InlineQueryResultVoice,

    pub fn jsonStringify(self: InlineQueryResult, jw: anytype) !void {
        switch (self) {
            inline else => |payload| try jw.write(payload),
        }
    }

    pub fn writeMultipartJson(
        self: InlineQueryResult,
        arena: Allocator,
        jw: *std.json.Stringify,
        pending_parts: *std.ArrayList(multipart_mod.PendingPart),
        comptime writeFn: anytype,
    ) !void {
        switch (self) {
            inline else => |payload| try writeFn(arena, jw, payload, pending_parts),
        }
    }

    pub fn jsonParse(
        allocator: Allocator,
        source: anytype,
        options: std.json.ParseOptions,
    ) std.json.ParseError(@TypeOf(source.*))!InlineQueryResult {
        return json_mod.parseDiscriminatedUnion(
            InlineQueryResult,
            "type",
            .{
                .{ "audio", "cached_audio" },
                .{ "document", "cached_document" },
                .{ "gif", "cached_gif" },
                .{ "mpeg4_gif", "cached_mpeg4_gif" },
                .{ "photo", "cached_photo" },
                .{ "sticker", "cached_sticker" },
                .{ "video", "cached_video" },
                .{ "voice", "cached_voice" },
                .{ "article", "article" },
                .{ "contact", "contact" },
                .{ "game", "game" },
                .{ "location", "location" },
                .{ "venue", "venue" },
            },
            allocator,
            source,
            options,
        );
    }
};

/// Represents a link to an article or web page.
/// Reference: https://core.telegram.org/bots/api#inlinequeryresultarticle
pub const InlineQueryResultArticle = struct {
    /// Type of the result, must be article
    type: []const u8 = "article",
    /// Unique identifier for this result, 1-64 Bytes
    id: []const u8,
    /// Title of the result
    title: []const u8,
    /// Content of the message to be sent
    input_message_content: InputMessageContent,
    /// Optional. Inline keyboard attached to the message
    reply_markup: ?InlineKeyboardMarkup = null,
    /// Optional. URL of the result
    url: ?[]const u8 = null,
    /// Optional. Short description of the result
    description: ?[]const u8 = null,
    /// Optional. Url of the thumbnail for the result
    thumbnail_url: ?[]const u8 = null,
    /// Optional. Thumbnail width
    thumbnail_width: ?i64 = null,
    /// Optional. Thumbnail height
    thumbnail_height: ?i64 = null,
};

/// Represents a link to an MP3 audio file. By default, this audio file will be sent by the user. Alternatively, you can use input_message_content to send a message with the specified content instead of the audio.
/// Reference: https://core.telegram.org/bots/api#inlinequeryresultaudio
pub const InlineQueryResultAudio = struct {
    /// Type of the result, must be audio
    type: []const u8 = "audio",
    /// Unique identifier for this result, 1-64 bytes
    id: []const u8,
    /// A valid URL for the audio file
    audio_url: []const u8,
    /// Title
    title: []const u8,
    /// Optional. Caption, 0-1024 characters after entities parsing
    caption: ?[]const u8 = null,
    /// Optional. Mode for parsing entities in the audio caption. See formatting options for more details.
    parse_mode: ?enums.ParseMode = null,
    /// Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
    caption_entities: ?[]const MessageEntity = null,
    /// Optional. Performer
    performer: ?[]const u8 = null,
    /// Optional. Audio duration in seconds
    audio_duration: ?i64 = null,
    /// Optional. Inline keyboard attached to the message
    reply_markup: ?InlineKeyboardMarkup = null,
    /// Optional. Content of the message to be sent instead of the audio
    input_message_content: ?InputMessageContent = null,
};

/// Represents a link to an MP3 audio file stored on the Telegram servers. By default, this audio file will be sent by the user. Alternatively, you can use input_message_content to send a message with the specified content instead of the audio.
/// Reference: https://core.telegram.org/bots/api#inlinequeryresultcachedaudio
pub const InlineQueryResultCachedAudio = struct {
    /// Type of the result, must be audio
    type: []const u8 = "audio",
    /// Unique identifier for this result, 1-64 bytes
    id: []const u8,
    /// A valid file identifier for the audio file
    audio_file_id: []const u8,
    /// Optional. Caption, 0-1024 characters after entities parsing
    caption: ?[]const u8 = null,
    /// Optional. Mode for parsing entities in the audio caption. See formatting options for more details.
    parse_mode: ?enums.ParseMode = null,
    /// Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
    caption_entities: ?[]const MessageEntity = null,
    /// Optional. Inline keyboard attached to the message
    reply_markup: ?InlineKeyboardMarkup = null,
    /// Optional. Content of the message to be sent instead of the audio
    input_message_content: ?InputMessageContent = null,
};

/// Represents a link to a file stored on the Telegram servers. By default, this file will be sent by the user with an optional caption. Alternatively, you can use input_message_content to send a message with the specified content instead of the file.
/// Reference: https://core.telegram.org/bots/api#inlinequeryresultcacheddocument
pub const InlineQueryResultCachedDocument = struct {
    /// Type of the result, must be document
    type: []const u8 = "document",
    /// Unique identifier for this result, 1-64 bytes
    id: []const u8,
    /// Title for the result
    title: []const u8,
    /// A valid file identifier for the file
    document_file_id: []const u8,
    /// Optional. Short description of the result
    description: ?[]const u8 = null,
    /// Optional. Caption of the document to be sent, 0-1024 characters after entities parsing
    caption: ?[]const u8 = null,
    /// Optional. Mode for parsing entities in the document caption. See formatting options for more details.
    parse_mode: ?enums.ParseMode = null,
    /// Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
    caption_entities: ?[]const MessageEntity = null,
    /// Optional. Inline keyboard attached to the message
    reply_markup: ?InlineKeyboardMarkup = null,
    /// Optional. Content of the message to be sent instead of the file
    input_message_content: ?InputMessageContent = null,
};

/// Represents a link to an animated GIF file stored on the Telegram servers. By default, this animated GIF file will be sent by the user with an optional caption. Alternatively, you can use input_message_content to send a message with specified content instead of the animation.
/// Reference: https://core.telegram.org/bots/api#inlinequeryresultcachedgif
pub const InlineQueryResultCachedGif = struct {
    /// Type of the result, must be gif
    type: []const u8 = "gif",
    /// Unique identifier for this result, 1-64 bytes
    id: []const u8,
    /// A valid file identifier for the GIF file
    gif_file_id: []const u8,
    /// Optional. Title for the result
    title: ?[]const u8 = null,
    /// Optional. Caption of the GIF file to be sent, 0-1024 characters after entities parsing
    caption: ?[]const u8 = null,
    /// Optional. Mode for parsing entities in the caption. See formatting options for more details.
    parse_mode: ?enums.ParseMode = null,
    /// Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
    caption_entities: ?[]const MessageEntity = null,
    /// Optional. Pass True if the caption must be shown above the message media
    show_caption_above_media: ?bool = null,
    /// Optional. Inline keyboard attached to the message
    reply_markup: ?InlineKeyboardMarkup = null,
    /// Optional. Content of the message to be sent instead of the GIF animation
    input_message_content: ?InputMessageContent = null,
};

/// Represents a link to a video animation (H.264/MPEG-4 AVC video without sound) stored on the Telegram servers. By default, this animated MPEG-4 file will be sent by the user with an optional caption. Alternatively, you can use input_message_content to send a message with the specified content instead of the animation.
/// Reference: https://core.telegram.org/bots/api#inlinequeryresultcachedmpeg4gif
pub const InlineQueryResultCachedMpeg4Gif = struct {
    /// Type of the result, must be mpeg4_gif
    type: []const u8 = "mpeg4_gif",
    /// Unique identifier for this result, 1-64 bytes
    id: []const u8,
    /// A valid file identifier for the MPEG4 file
    mpeg4_file_id: []const u8,
    /// Optional. Title for the result
    title: ?[]const u8 = null,
    /// Optional. Caption of the MPEG-4 file to be sent, 0-1024 characters after entities parsing
    caption: ?[]const u8 = null,
    /// Optional. Mode for parsing entities in the caption. See formatting options for more details.
    parse_mode: ?enums.ParseMode = null,
    /// Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
    caption_entities: ?[]const MessageEntity = null,
    /// Optional. Pass True if the caption must be shown above the message media
    show_caption_above_media: ?bool = null,
    /// Optional. Inline keyboard attached to the message
    reply_markup: ?InlineKeyboardMarkup = null,
    /// Optional. Content of the message to be sent instead of the video animation
    input_message_content: ?InputMessageContent = null,
};

/// Represents a link to a photo stored on the Telegram servers. By default, this photo will be sent by the user with an optional caption. Alternatively, you can use input_message_content to send a message with the specified content instead of the photo.
/// Reference: https://core.telegram.org/bots/api#inlinequeryresultcachedphoto
pub const InlineQueryResultCachedPhoto = struct {
    /// Type of the result, must be photo
    type: []const u8 = "photo",
    /// Unique identifier for this result, 1-64 bytes
    id: []const u8,
    /// A valid file identifier of the photo
    photo_file_id: []const u8,
    /// Optional. Title for the result
    title: ?[]const u8 = null,
    /// Optional. Short description of the result
    description: ?[]const u8 = null,
    /// Optional. Caption of the photo to be sent, 0-1024 characters after entities parsing
    caption: ?[]const u8 = null,
    /// Optional. Mode for parsing entities in the photo caption. See formatting options for more details.
    parse_mode: ?enums.ParseMode = null,
    /// Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
    caption_entities: ?[]const MessageEntity = null,
    /// Optional. Pass True if the caption must be shown above the message media
    show_caption_above_media: ?bool = null,
    /// Optional. Inline keyboard attached to the message
    reply_markup: ?InlineKeyboardMarkup = null,
    /// Optional. Content of the message to be sent instead of the photo
    input_message_content: ?InputMessageContent = null,
};

/// Represents a link to a sticker stored on the Telegram servers. By default, this sticker will be sent by the user. Alternatively, you can use input_message_content to send a message with the specified content instead of the sticker.
/// Reference: https://core.telegram.org/bots/api#inlinequeryresultcachedsticker
pub const InlineQueryResultCachedSticker = struct {
    /// Type of the result, must be sticker
    type: []const u8 = "sticker",
    /// Unique identifier for this result, 1-64 bytes
    id: []const u8,
    /// A valid file identifier of the sticker
    sticker_file_id: []const u8,
    /// Optional. Inline keyboard attached to the message
    reply_markup: ?InlineKeyboardMarkup = null,
    /// Optional. Content of the message to be sent instead of the sticker
    input_message_content: ?InputMessageContent = null,
};

/// Represents a link to a video file stored on the Telegram servers. By default, this video file will be sent by the user with an optional caption. Alternatively, you can use input_message_content to send a message with the specified content instead of the video.
/// Reference: https://core.telegram.org/bots/api#inlinequeryresultcachedvideo
pub const InlineQueryResultCachedVideo = struct {
    /// Type of the result, must be video
    type: []const u8 = "video",
    /// Unique identifier for this result, 1-64 bytes
    id: []const u8,
    /// A valid file identifier for the video file
    video_file_id: []const u8,
    /// Title for the result
    title: []const u8,
    /// Optional. Short description of the result
    description: ?[]const u8 = null,
    /// Optional. Caption of the video to be sent, 0-1024 characters after entities parsing
    caption: ?[]const u8 = null,
    /// Optional. Mode for parsing entities in the video caption. See formatting options for more details.
    parse_mode: ?enums.ParseMode = null,
    /// Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
    caption_entities: ?[]const MessageEntity = null,
    /// Optional. Pass True if the caption must be shown above the message media
    show_caption_above_media: ?bool = null,
    /// Optional. Inline keyboard attached to the message
    reply_markup: ?InlineKeyboardMarkup = null,
    /// Optional. Content of the message to be sent instead of the video
    input_message_content: ?InputMessageContent = null,
};

/// Represents a link to a voice message stored on the Telegram servers. By default, this voice message will be sent by the user. Alternatively, you can use input_message_content to send a message with the specified content instead of the voice message.
/// Reference: https://core.telegram.org/bots/api#inlinequeryresultcachedvoice
pub const InlineQueryResultCachedVoice = struct {
    /// Type of the result, must be voice
    type: []const u8 = "voice",
    /// Unique identifier for this result, 1-64 bytes
    id: []const u8,
    /// A valid file identifier for the voice message
    voice_file_id: []const u8,
    /// Voice message title
    title: []const u8,
    /// Optional. Caption, 0-1024 characters after entities parsing
    caption: ?[]const u8 = null,
    /// Optional. Mode for parsing entities in the voice message caption. See formatting options for more details.
    parse_mode: ?enums.ParseMode = null,
    /// Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
    caption_entities: ?[]const MessageEntity = null,
    /// Optional. Inline keyboard attached to the message
    reply_markup: ?InlineKeyboardMarkup = null,
    /// Optional. Content of the message to be sent instead of the voice message
    input_message_content: ?InputMessageContent = null,
};

/// Represents a contact with a phone number. By default, this contact will be sent by the user. Alternatively, you can use input_message_content to send a message with the specified content instead of the contact.
/// Reference: https://core.telegram.org/bots/api#inlinequeryresultcontact
pub const InlineQueryResultContact = struct {
    /// Type of the result, must be contact
    type: []const u8 = "contact",
    /// Unique identifier for this result, 1-64 Bytes
    id: []const u8,
    /// Contact's phone number
    phone_number: []const u8,
    /// Contact's first name
    first_name: []const u8,
    /// Optional. Contact's last name
    last_name: ?[]const u8 = null,
    /// Optional. Additional data about the contact in the form of a vCard, 0-2048 bytes
    vcard: ?[]const u8 = null,
    /// Optional. Inline keyboard attached to the message
    reply_markup: ?InlineKeyboardMarkup = null,
    /// Optional. Content of the message to be sent instead of the contact
    input_message_content: ?InputMessageContent = null,
    /// Optional. Url of the thumbnail for the result
    thumbnail_url: ?[]const u8 = null,
    /// Optional. Thumbnail width
    thumbnail_width: ?i64 = null,
    /// Optional. Thumbnail height
    thumbnail_height: ?i64 = null,
};

/// Represents a link to a file. By default, this file will be sent by the user with an optional caption. Alternatively, you can use input_message_content to send a message with the specified content instead of the file. Currently, only .PDF and .ZIP files can be sent using this method.
/// Reference: https://core.telegram.org/bots/api#inlinequeryresultdocument
pub const InlineQueryResultDocument = struct {
    /// Type of the result, must be document
    type: []const u8 = "document",
    /// Unique identifier for this result, 1-64 bytes
    id: []const u8,
    /// Title for the result
    title: []const u8,
    /// A valid URL for the file
    document_url: []const u8,
    /// MIME type of the content of the file, either "application/pdf" or "application/zip"
    mime_type: []const u8,
    /// Optional. Caption of the document to be sent, 0-1024 characters after entities parsing
    caption: ?[]const u8 = null,
    /// Optional. Mode for parsing entities in the document caption. See formatting options for more details.
    parse_mode: ?enums.ParseMode = null,
    /// Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
    caption_entities: ?[]const MessageEntity = null,
    /// Optional. Short description of the result
    description: ?[]const u8 = null,
    /// Optional. Inline keyboard attached to the message
    reply_markup: ?InlineKeyboardMarkup = null,
    /// Optional. Content of the message to be sent instead of the file
    input_message_content: ?InputMessageContent = null,
    /// Optional. URL of the thumbnail (JPEG only) for the file
    thumbnail_url: ?[]const u8 = null,
    /// Optional. Thumbnail width
    thumbnail_width: ?i64 = null,
    /// Optional. Thumbnail height
    thumbnail_height: ?i64 = null,
};

/// Represents a Game.
/// Reference: https://core.telegram.org/bots/api#inlinequeryresultgame
pub const InlineQueryResultGame = struct {
    /// Type of the result, must be game
    type: []const u8 = "game",
    /// Unique identifier for this result, 1-64 bytes
    id: []const u8,
    /// Short name of the game
    game_short_name: []const u8,
    /// Optional. Inline keyboard attached to the message
    reply_markup: ?InlineKeyboardMarkup = null,
};

/// Represents a link to an animated GIF file. By default, this animated GIF file will be sent by the user with optional caption. Alternatively, you can use input_message_content to send a message with the specified content instead of the animation.
/// Reference: https://core.telegram.org/bots/api#inlinequeryresultgif
pub const InlineQueryResultGif = struct {
    /// Type of the result, must be gif
    type: []const u8 = "gif",
    /// Unique identifier for this result, 1-64 bytes
    id: []const u8,
    /// A valid URL for the GIF file
    gif_url: []const u8,
    /// URL of the static (JPEG or GIF) or animated (MPEG4) thumbnail for the result
    thumbnail_url: []const u8,
    /// Optional. Width of the GIF
    gif_width: ?i64 = null,
    /// Optional. Height of the GIF
    gif_height: ?i64 = null,
    /// Optional. Duration of the GIF in seconds
    gif_duration: ?i64 = null,
    /// Optional. MIME type of the thumbnail, must be one of "image/jpeg", "image/gif", or "video/mp4". Defaults to "image/jpeg".
    thumbnail_mime_type: ?[]const u8 = null,
    /// Optional. Title for the result
    title: ?[]const u8 = null,
    /// Optional. Caption of the GIF file to be sent, 0-1024 characters after entities parsing
    caption: ?[]const u8 = null,
    /// Optional. Mode for parsing entities in the caption. See formatting options for more details.
    parse_mode: ?enums.ParseMode = null,
    /// Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
    caption_entities: ?[]const MessageEntity = null,
    /// Optional. Pass True if the caption must be shown above the message media
    show_caption_above_media: ?bool = null,
    /// Optional. Inline keyboard attached to the message
    reply_markup: ?InlineKeyboardMarkup = null,
    /// Optional. Content of the message to be sent instead of the GIF animation
    input_message_content: ?InputMessageContent = null,
};

/// Represents a location on a map. By default, the location will be sent by the user. Alternatively, you can use input_message_content to send a message with the specified content instead of the location.
/// Reference: https://core.telegram.org/bots/api#inlinequeryresultlocation
pub const InlineQueryResultLocation = struct {
    /// Type of the result, must be location
    type: []const u8 = "location",
    /// Unique identifier for this result, 1-64 Bytes
    id: []const u8,
    /// Location latitude in degrees
    latitude: f64,
    /// Location longitude in degrees
    longitude: f64,
    /// Location title
    title: []const u8,
    /// Optional. The radius of uncertainty for the location, measured in meters; 0-1500
    horizontal_accuracy: ?f64 = null,
    /// Optional. Period in seconds during which the location can be updated, must be between 60 and 86400, or 0x7FFFFFFF for live locations that can be edited indefinitely
    live_period: ?i64 = null,
    /// Optional. For live locations, a direction in which the user is moving, in degrees. Must be between 1 and 360 if specified.
    heading: ?i64 = null,
    /// Optional. For live locations, a maximum distance for proximity alerts about approaching another chat member, in meters. Must be between 1 and 100000 if specified.
    proximity_alert_radius: ?i64 = null,
    /// Optional. Inline keyboard attached to the message
    reply_markup: ?InlineKeyboardMarkup = null,
    /// Optional. Content of the message to be sent instead of the location
    input_message_content: ?InputMessageContent = null,
    /// Optional. Url of the thumbnail for the result
    thumbnail_url: ?[]const u8 = null,
    /// Optional. Thumbnail width
    thumbnail_width: ?i64 = null,
    /// Optional. Thumbnail height
    thumbnail_height: ?i64 = null,
};

/// Represents a link to a video animation (H.264/MPEG-4 AVC video without sound). By default, this animated MPEG-4 file will be sent by the user with optional caption. Alternatively, you can use input_message_content to send a message with the specified content instead of the animation.
/// Reference: https://core.telegram.org/bots/api#inlinequeryresultmpeg4gif
pub const InlineQueryResultMpeg4Gif = struct {
    /// Type of the result, must be mpeg4_gif
    type: []const u8 = "mpeg4_gif",
    /// Unique identifier for this result, 1-64 bytes
    id: []const u8,
    /// A valid URL for the MPEG4 file
    mpeg4_url: []const u8,
    /// URL of the static (JPEG or GIF) or animated (MPEG4) thumbnail for the result
    thumbnail_url: []const u8,
    /// Optional. Video width
    mpeg4_width: ?i64 = null,
    /// Optional. Video height
    mpeg4_height: ?i64 = null,
    /// Optional. Video duration in seconds
    mpeg4_duration: ?i64 = null,
    /// Optional. MIME type of the thumbnail, must be one of "image/jpeg", "image/gif", or "video/mp4". Defaults to "image/jpeg".
    thumbnail_mime_type: ?[]const u8 = null,
    /// Optional. Title for the result
    title: ?[]const u8 = null,
    /// Optional. Caption of the MPEG-4 file to be sent, 0-1024 characters after entities parsing
    caption: ?[]const u8 = null,
    /// Optional. Mode for parsing entities in the caption. See formatting options for more details.
    parse_mode: ?enums.ParseMode = null,
    /// Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
    caption_entities: ?[]const MessageEntity = null,
    /// Optional. Pass True if the caption must be shown above the message media
    show_caption_above_media: ?bool = null,
    /// Optional. Inline keyboard attached to the message
    reply_markup: ?InlineKeyboardMarkup = null,
    /// Optional. Content of the message to be sent instead of the video animation
    input_message_content: ?InputMessageContent = null,
};

/// Represents a link to a photo. By default, this photo will be sent by the user with optional caption. Alternatively, you can use input_message_content to send a message with the specified content instead of the photo.
/// Reference: https://core.telegram.org/bots/api#inlinequeryresultphoto
pub const InlineQueryResultPhoto = struct {
    /// Type of the result, must be photo
    type: []const u8 = "photo",
    /// Unique identifier for this result, 1-64 bytes
    id: []const u8,
    /// A valid URL of the photo. Photo must be in JPEG format. Photo size must not exceed 5MB.
    photo_url: []const u8 = "in",
    /// URL of the thumbnail for the photo
    thumbnail_url: []const u8,
    /// Optional. Width of the photo
    photo_width: ?i64 = null,
    /// Optional. Height of the photo
    photo_height: ?i64 = null,
    /// Optional. Title for the result
    title: ?[]const u8 = null,
    /// Optional. Short description of the result
    description: ?[]const u8 = null,
    /// Optional. Caption of the photo to be sent, 0-1024 characters after entities parsing
    caption: ?[]const u8 = null,
    /// Optional. Mode for parsing entities in the photo caption. See formatting options for more details.
    parse_mode: ?enums.ParseMode = null,
    /// Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
    caption_entities: ?[]const MessageEntity = null,
    /// Optional. Pass True if the caption must be shown above the message media
    show_caption_above_media: ?bool = null,
    /// Optional. Inline keyboard attached to the message
    reply_markup: ?InlineKeyboardMarkup = null,
    /// Optional. Content of the message to be sent instead of the photo
    input_message_content: ?InputMessageContent = null,
};

/// Represents a venue. By default, the venue will be sent by the user. Alternatively, you can use input_message_content to send a message with the specified content instead of the venue.
/// Reference: https://core.telegram.org/bots/api#inlinequeryresultvenue
pub const InlineQueryResultVenue = struct {
    /// Type of the result, must be venue
    type: []const u8 = "venue",
    /// Unique identifier for this result, 1-64 Bytes
    id: []const u8,
    /// Latitude of the venue location in degrees
    latitude: f64,
    /// Longitude of the venue location in degrees
    longitude: f64,
    /// Title of the venue
    title: []const u8,
    /// Address of the venue
    address: []const u8,
    /// Optional. Foursquare identifier of the venue if known
    foursquare_id: ?[]const u8 = null,
    /// Optional. Foursquare type of the venue, if known. (For example, "arts_entertainment/default", "arts_entertainment/aquarium" or "food/icecream".)
    foursquare_type: ?[]const u8 = null,
    /// Optional. Google Places identifier of the venue
    google_place_id: ?[]const u8 = null,
    /// Optional. Google Places type of the venue. (See supported types.)
    google_place_type: ?[]const u8 = null,
    /// Optional. Inline keyboard attached to the message
    reply_markup: ?InlineKeyboardMarkup = null,
    /// Optional. Content of the message to be sent instead of the venue
    input_message_content: ?InputMessageContent = null,
    /// Optional. Url of the thumbnail for the result
    thumbnail_url: ?[]const u8 = null,
    /// Optional. Thumbnail width
    thumbnail_width: ?i64 = null,
    /// Optional. Thumbnail height
    thumbnail_height: ?i64 = null,
};

/// Represents a link to a page containing an embedded video player or a video file. By default, this video file will be sent by the user with an optional caption. Alternatively, you can use input_message_content to send a message with the specified content instead of the video.
/// Reference: https://core.telegram.org/bots/api#inlinequeryresultvideo
pub const InlineQueryResultVideo = struct {
    /// Type of the result, must be video
    type: []const u8 = "video",
    /// Unique identifier for this result, 1-64 bytes
    id: []const u8,
    /// A valid URL for the embedded video player or video file
    video_url: []const u8,
    /// MIME type of the content of the video URL, "text/html" or "video/mp4"
    mime_type: []const u8,
    /// URL of the thumbnail (JPEG only) for the video
    thumbnail_url: []const u8,
    /// Title for the result
    title: []const u8,
    /// Optional. Caption of the video to be sent, 0-1024 characters after entities parsing
    caption: ?[]const u8 = null,
    /// Optional. Mode for parsing entities in the video caption. See formatting options for more details.
    parse_mode: ?enums.ParseMode = null,
    /// Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
    caption_entities: ?[]const MessageEntity = null,
    /// Optional. Pass True if the caption must be shown above the message media
    show_caption_above_media: ?bool = null,
    /// Optional. Video width
    video_width: ?i64 = null,
    /// Optional. Video height
    video_height: ?i64 = null,
    /// Optional. Video duration in seconds
    video_duration: ?i64 = null,
    /// Optional. Short description of the result
    description: ?[]const u8 = null,
    /// Optional. Inline keyboard attached to the message
    reply_markup: ?InlineKeyboardMarkup = null,
    /// Optional. Content of the message to be sent instead of the video. This field is required if InlineQueryResultVideo is used to send an HTML-page as a result (e.g., a YouTube video).
    input_message_content: ?InputMessageContent = null,
};

/// Represents a link to a voice recording in an .OGG container encoded with OPUS. By default, this voice recording will be sent by the user. Alternatively, you can use input_message_content to send a message with the specified content instead of the the voice message.
/// Reference: https://core.telegram.org/bots/api#inlinequeryresultvoice
pub const InlineQueryResultVoice = struct {
    /// Type of the result, must be voice
    type: []const u8 = "voice",
    /// Unique identifier for this result, 1-64 bytes
    id: []const u8,
    /// A valid URL for the voice recording
    voice_url: []const u8,
    /// Recording title
    title: []const u8,
    /// Optional. Caption, 0-1024 characters after entities parsing
    caption: ?[]const u8 = null,
    /// Optional. Mode for parsing entities in the voice message caption. See formatting options for more details.
    parse_mode: ?enums.ParseMode = null,
    /// Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
    caption_entities: ?[]const MessageEntity = null,
    /// Optional. Recording duration in seconds
    voice_duration: ?i64 = null,
    /// Optional. Inline keyboard attached to the message
    reply_markup: ?InlineKeyboardMarkup = null,
    /// Optional. Content of the message to be sent instead of the voice recording
    input_message_content: ?InputMessageContent = null,
};

/// This object represents a button to be shown above inline query results. You must use exactly one of the optional fields.
/// Reference: https://core.telegram.org/bots/api#inlinequeryresultsbutton
pub const InlineQueryResultsButton = struct {
    /// Label text on the button
    text: []const u8,
    /// Optional. Description of the Web App that will be launched when the user presses the button. The Web App will be able to switch back to the inline mode using the method switchInlineQuery inside the Web App.
    web_app: ?WebAppInfo = null,
    /// Optional. Deep-linking parameter for the /start message sent to the bot when a user presses the button. 1-64 characters, only A-Z, a-z, 0-9, _ and - are allowed. Example: An inline bot that sends YouTube videos can ask the user to connect the bot to their YouTube account to adapt search results accordingly. To do this, it displays a 'Connect your YouTube account' button above the results, or even before showing any. The user presses the button, switches to a private chat with the bot and, in doing so, passes a start parameter that instructs the bot to return an OAuth link. Once done, the bot can offer a switch_inline button so that the user can easily return to the chat where they wanted to use the bot's inline capabilities.
    start_parameter: ?[]const u8 = null,
};

/// Describes a checklist to create.
/// Reference: https://core.telegram.org/bots/api#inputchecklist
pub const InputChecklist = struct {
    /// Title of the checklist; 1-255 characters after entities parsing
    title: []const u8,
    /// List of 1-30 tasks in the checklist
    tasks: []const InputChecklistTask,
    /// Optional. Mode for parsing entities in the title. See formatting options for more details.
    parse_mode: ?enums.ParseMode = null,
    /// Optional. List of special entities that appear in the title, which can be specified instead of parse_mode. Currently, only bold, italic, underline, strikethrough, spoiler, custom_emoji, and date_time entities are allowed.
    title_entities: ?[]const MessageEntity = null,
    /// Optional. Pass True if other users can add tasks to the checklist
    others_can_add_tasks: ?bool = null,
    /// Optional. Pass True if other users can mark tasks as done or not done in the checklist
    others_can_mark_tasks_as_done: ?bool = null,
};

/// Describes a task to add to a checklist.
/// Reference: https://core.telegram.org/bots/api#inputchecklisttask
pub const InputChecklistTask = struct {
    /// Unique identifier of the task; must be positive and unique among all task identifiers currently present in the checklist
    id: i64,
    /// Text of the task; 1-100 characters after entities parsing
    text: []const u8,
    /// Optional. Mode for parsing entities in the text. See formatting options for more details.
    parse_mode: ?enums.ParseMode = null,
    /// Optional. List of special entities that appear in the text, which can be specified instead of parse_mode. Currently, only bold, italic, underline, strikethrough, spoiler, custom_emoji, and date_time entities are allowed.
    text_entities: ?[]const MessageEntity = null,
};

/// Represents the content of a contact message to be sent as the result of an inline query.
/// Reference: https://core.telegram.org/bots/api#inputcontactmessagecontent
pub const InputContactMessageContent = struct {
    /// Contact's phone number
    phone_number: []const u8,
    /// Contact's first name
    first_name: []const u8,
    /// Optional. Contact's last name
    last_name: ?[]const u8 = null,
    /// Optional. Additional data about the contact in the form of a vCard, 0-2048 bytes
    vcard: ?[]const u8 = null,
};

/// Represents the content of an invoice message to be sent as the result of an inline query.
/// Reference: https://core.telegram.org/bots/api#inputinvoicemessagecontent
pub const InputInvoiceMessageContent = struct {
    /// Product name, 1-32 characters
    title: []const u8,
    /// Product description, 1-255 characters
    description: []const u8,
    /// Bot-defined invoice payload, 1-128 bytes. This will not be displayed to the user, use it for your internal processes.
    payload: []const u8,
    /// Three-letter ISO 4217 currency code, see more on currencies. Pass "XTR" for payments in Telegram Stars.
    currency: []const u8,
    /// Price breakdown, a JSON-serialized list of components (e.g. product price, tax, discount, delivery cost, delivery tax, bonus, etc.). Must contain exactly one item for payments in Telegram Stars.
    prices: []const LabeledPrice,
    /// Optional. Payment provider token, obtained via @BotFather. Pass an empty string for payments in Telegram Stars.
    provider_token: ?[]const u8 = null,
    /// Optional. The maximum accepted amount for tips in the smallest units of the currency (integer, not float/double). For example, for a maximum tip of US$ 1.45 pass max_tip_amount = 145. See the exp parameter in currencies.json, it shows the number of digits past the decimal point for each currency (2 for the majority of currencies). Defaults to 0. Not supported for payments in Telegram Stars.
    max_tip_amount: ?i64 = null,
    /// Optional. A JSON-serialized Array of suggested amounts of tip in the smallest units of the currency (integer, not float/double). At most 4 suggested tip amounts can be specified. The suggested tip amounts must be positive, passed in a strictly increased order and must not exceed max_tip_amount.
    suggested_tip_amounts: ?[]const i64 = null,
    /// Optional. A JSON-serialized object for data about the invoice, which will be shared with the payment provider. A detailed description of the required fields should be provided by the payment provider.
    provider_data: ?[]const u8 = null,
    /// Optional. URL of the product photo for the invoice. Can be a photo of the goods or a marketing image for a service.
    photo_url: ?[]const u8 = null,
    /// Optional. Photo size in bytes
    photo_size: ?i64 = null,
    /// Optional. Photo width
    photo_width: ?i64 = null,
    /// Optional. Photo height
    photo_height: ?i64 = null,
    /// Optional. Pass True if you require the user's full name to complete the order. Ignored for payments in Telegram Stars.
    need_name: ?bool = null,
    /// Optional. Pass True if you require the user's phone number to complete the order. Ignored for payments in Telegram Stars.
    need_phone_number: ?bool = null,
    /// Optional. Pass True if you require the user's email address to complete the order. Ignored for payments in Telegram Stars.
    need_email: ?bool = null,
    /// Optional. Pass True if you require the user's shipping address to complete the order. Ignored for payments in Telegram Stars.
    need_shipping_address: ?bool = null,
    /// Optional. Pass True if the user's phone number should be sent to the provider. Ignored for payments in Telegram Stars.
    send_phone_number_to_provider: ?bool = null,
    /// Optional. Pass True if the user's email address should be sent to the provider. Ignored for payments in Telegram Stars.
    send_email_to_provider: ?bool = null,
    /// Optional. Pass True if the final price depends on the shipping method. Ignored for payments in Telegram Stars.
    is_flexible: ?bool = null,
};

/// Represents the content of a location message to be sent as the result of an inline query.
/// Reference: https://core.telegram.org/bots/api#inputlocationmessagecontent
pub const InputLocationMessageContent = struct {
    /// Latitude of the location in degrees
    latitude: f64,
    /// Longitude of the location in degrees
    longitude: f64,
    /// Optional. The radius of uncertainty for the location, measured in meters; 0-1500
    horizontal_accuracy: ?f64 = null,
    /// Optional. Period in seconds during which the location can be updated, must be between 60 and 86400, or 0x7FFFFFFF for live locations that can be edited indefinitely
    live_period: ?i64 = null,
    /// Optional. For live locations, a direction in which the user is moving, in degrees. Must be between 1 and 360 if specified.
    heading: ?i64 = null,
    /// Optional. For live locations, a maximum distance for proximity alerts about approaching another chat member, in meters. Must be between 1 and 100000 if specified.
    proximity_alert_radius: ?i64 = null,
};

/// This object represents the content of a media message to be sent. It should be one of
/// - InputMediaAnimation
/// - InputMediaAudio
/// - InputMediaDocument
/// - InputMediaLivePhoto
/// - InputMediaPhoto
/// - InputMediaVideo
/// Reference: https://core.telegram.org/bots/api#inputmedia
pub const InputMedia = union(enum) {
    animation: InputMediaAnimation,
    audio: InputMediaAudio,
    document: InputMediaDocument,
    live_photo: InputMediaLivePhoto,
    photo: InputMediaPhoto,
    video: InputMediaVideo,

    pub fn jsonStringify(self: InputMedia, jw: anytype) !void {
        switch (self) {
            inline else => |payload| try jw.write(payload),
        }
    }

    pub fn writeMultipartJson(
        self: InputMedia,
        arena: Allocator,
        jw: *std.json.Stringify,
        pending_parts: *std.ArrayList(multipart_mod.PendingPart),
        comptime writeFn: anytype,
    ) !void {
        switch (self) {
            inline else => |payload| try writeFn(arena, jw, payload, pending_parts),
        }
    }

    pub fn jsonParse(
        allocator: Allocator,
        source: anytype,
        options: std.json.ParseOptions,
    ) std.json.ParseError(@TypeOf(source.*))!InputMedia {
        return json_mod.parseDiscriminatedUnion(
            InputMedia,
            "type",
            .{
                .{ "animation", "animation" },
                .{ "audio", "audio" },
                .{ "document", "document" },
                .{ "live_photo", "live_photo" },
                .{ "photo", "photo" },
                .{ "video", "video" },
            },
            allocator,
            source,
            options,
        );
    }
};

/// Represents an animation file (GIF or H.264/MPEG-4 AVC video without sound) to be sent.
/// Reference: https://core.telegram.org/bots/api#inputmediaanimation
pub const InputMediaAnimation = struct {
    /// Type of the media, must be animation
    type: []const u8 = "animation",
    /// File to send. Pass a file_id to send a file that exists on the Telegram servers (recommended), pass an HTTP URL for Telegram to get a file from the Internet, or pass "attach://<file_attach_name>" to upload a new one using multipart/form-data under <file_attach_name> name. More information on Sending Files: https://core.telegram.org/bots/api#sending-files
    media: InputFile,
    /// Optional. Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail's width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can't be reused and can be only uploaded as a new file, so you can pass "attach://<file_attach_name>" if the thumbnail was uploaded using multipart/form-data under <file_attach_name>. More information on Sending Files: https://core.telegram.org/bots/api#sending-files
    thumbnail: ?InputFile = null,
    /// Optional. Caption of the animation to be sent, 0-1024 characters after entities parsing
    caption: ?[]const u8 = null,
    /// Optional. Mode for parsing entities in the animation caption. See formatting options for more details.
    parse_mode: ?enums.ParseMode = null,
    /// Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
    caption_entities: ?[]const MessageEntity = null,
    /// Optional. Pass True if the caption must be shown above the message media
    show_caption_above_media: ?bool = null,
    /// Optional. Animation width
    width: ?i64 = null,
    /// Optional. Animation height
    height: ?i64 = null,
    /// Optional. Animation duration in seconds
    duration: ?i64 = null,
    /// Optional. Pass True if the animation needs to be covered with a spoiler animation
    has_spoiler: ?bool = null,
};

/// Represents an audio file to be treated as music to be sent.
/// Reference: https://core.telegram.org/bots/api#inputmediaaudio
pub const InputMediaAudio = struct {
    /// Type of the media, must be audio
    type: []const u8 = "audio",
    /// File to send. Pass a file_id to send a file that exists on the Telegram servers (recommended), pass an HTTP URL for Telegram to get a file from the Internet, or pass "attach://<file_attach_name>" to upload a new one using multipart/form-data under <file_attach_name> name. More information on Sending Files: https://core.telegram.org/bots/api#sending-files
    media: InputFile,
    /// Optional. Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail's width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can't be reused and can be only uploaded as a new file, so you can pass "attach://<file_attach_name>" if the thumbnail was uploaded using multipart/form-data under <file_attach_name>. More information on Sending Files: https://core.telegram.org/bots/api#sending-files
    thumbnail: ?InputFile = null,
    /// Optional. Caption of the audio to be sent, 0-1024 characters after entities parsing
    caption: ?[]const u8 = null,
    /// Optional. Mode for parsing entities in the audio caption. See formatting options for more details.
    parse_mode: ?enums.ParseMode = null,
    /// Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
    caption_entities: ?[]const MessageEntity = null,
    /// Optional. Duration of the audio in seconds
    duration: ?i64 = null,
    /// Optional. Performer of the audio
    performer: ?[]const u8 = null,
    /// Optional. Title of the audio
    title: ?[]const u8 = null,
};

/// Represents a general file to be sent.
/// Reference: https://core.telegram.org/bots/api#inputmediadocument
pub const InputMediaDocument = struct {
    /// Type of the media, must be document
    type: []const u8 = "document",
    /// File to send. Pass a file_id to send a file that exists on the Telegram servers (recommended), pass an HTTP URL for Telegram to get a file from the Internet, or pass "attach://<file_attach_name>" to upload a new one using multipart/form-data under <file_attach_name> name. More information on Sending Files: https://core.telegram.org/bots/api#sending-files
    media: InputFile,
    /// Optional. Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail's width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can't be reused and can be only uploaded as a new file, so you can pass "attach://<file_attach_name>" if the thumbnail was uploaded using multipart/form-data under <file_attach_name>. More information on Sending Files: https://core.telegram.org/bots/api#sending-files
    thumbnail: ?InputFile = null,
    /// Optional. Caption of the document to be sent, 0-1024 characters after entities parsing
    caption: ?[]const u8 = null,
    /// Optional. Mode for parsing entities in the document caption. See formatting options for more details.
    parse_mode: ?enums.ParseMode = null,
    /// Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
    caption_entities: ?[]const MessageEntity = null,
    /// Optional. Disables automatic server-side content type detection for files uploaded using multipart/form-data. Always True, if the document is sent as part of an album.
    disable_content_type_detection: ?bool = null,
};

/// Represents an HTTP link to be sent.
/// Reference: https://core.telegram.org/bots/api#inputmedialink
pub const InputMediaLink = struct {
    /// Type of the media, must be link
    type: []const u8 = "link",
    /// HTTP URL of the link
    url: []const u8,
};

/// Represents a live photo to be sent.
/// Reference: https://core.telegram.org/bots/api#inputmedialivephoto
pub const InputMediaLivePhoto = struct {
    /// Type of the media, must be live_photo
    type: []const u8 = "live_photo",
    /// Video of the live photo to send. Pass a file_id to send a file that exists on the Telegram servers (recommended) or pass "attach://<file_attach_name>" to upload a new one using multipart/form-data under <file_attach_name> name. More information on Sending Files: https://core.telegram.org/bots/api#sending-files. Sending live photos by a URL is currently unsupported.
    media: InputFile,
    /// The static photo to send. Pass a file_id to send a file that exists on the Telegram servers (recommended) or pass "attach://<file_attach_name>" to upload a new one using multipart/form-data under <file_attach_name> name. More information on Sending Files: https://core.telegram.org/bots/api#sending-files. Sending live photos by a URL is currently unsupported.
    photo: InputFile,
    /// Optional. Caption of the live photo to be sent, 0-1024 characters after entities parsing
    caption: ?[]const u8 = null,
    /// Optional. Mode for parsing entities in the live photo caption. See formatting options for more details.
    parse_mode: ?enums.ParseMode = null,
    /// Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
    caption_entities: ?[]const MessageEntity = null,
    /// Optional. Pass True if the caption must be shown above the message media
    show_caption_above_media: ?bool = null,
    /// Optional. Pass True if the live photo needs to be covered with a spoiler animation
    has_spoiler: ?bool = null,
};

/// Represents a location to be sent.
/// Reference: https://core.telegram.org/bots/api#inputmedialocation
pub const InputMediaLocation = struct {
    /// Type of the media, must be location
    type: []const u8 = "location",
    /// Latitude of the location
    latitude: f64,
    /// Longitude of the location
    longitude: f64,
    /// Optional. The radius of uncertainty for the location, measured in meters; 0-1500
    horizontal_accuracy: ?f64 = null,
};

/// Represents a photo to be sent.
/// Reference: https://core.telegram.org/bots/api#inputmediaphoto
pub const InputMediaPhoto = struct {
    /// Type of the media, must be photo
    type: []const u8 = "photo",
    /// File to send. Pass a file_id to send a file that exists on the Telegram servers (recommended), pass an HTTP URL for Telegram to get a file from the Internet, or pass "attach://<file_attach_name>" to upload a new one using multipart/form-data under <file_attach_name> name. More information on Sending Files: https://core.telegram.org/bots/api#sending-files
    media: InputFile,
    /// Optional. Caption of the photo to be sent, 0-1024 characters after entities parsing
    caption: ?[]const u8 = null,
    /// Optional. Mode for parsing entities in the photo caption. See formatting options for more details.
    parse_mode: ?enums.ParseMode = null,
    /// Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
    caption_entities: ?[]const MessageEntity = null,
    /// Optional. Pass True if the caption must be shown above the message media
    show_caption_above_media: ?bool = null,
    /// Optional. Pass True if the photo needs to be covered with a spoiler animation
    has_spoiler: ?bool = null,
};

/// Represents a sticker file to be sent.
/// Reference: https://core.telegram.org/bots/api#inputmediasticker
pub const InputMediaSticker = struct {
    /// Type of the media, must be sticker
    type: []const u8 = "sticker",
    /// File to send. Pass a file_id to send a file that exists on the Telegram servers (recommended), pass an HTTP URL for Telegram to get a .WEBP sticker from the Internet, or pass "attach://<file_attach_name>" to upload a new .WEBP, .TGS, or .WEBM sticker using multipart/form-data under <file_attach_name> name. More information on Sending Files: https://core.telegram.org/bots/api#sending-files
    media: InputFile,
    /// Optional. Emoji associated with the sticker; only for just uploaded stickers
    emoji: ?[]const u8 = null,
};

/// Represents a venue to be sent.
/// Reference: https://core.telegram.org/bots/api#inputmediavenue
pub const InputMediaVenue = struct {
    /// Type of the media, must be venue
    type: []const u8 = "venue",
    /// Latitude of the location
    latitude: f64,
    /// Longitude of the location
    longitude: f64,
    /// Name of the venue
    title: []const u8,
    /// Address of the venue
    address: []const u8,
    /// Optional. Foursquare identifier of the venue
    foursquare_id: ?[]const u8 = null,
    /// Optional. Foursquare type of the venue, if known. (For example, "arts_entertainment/default", "arts_entertainment/aquarium" or "food/icecream".)
    foursquare_type: ?[]const u8 = null,
    /// Optional. Google Places identifier of the venue
    google_place_id: ?[]const u8 = null,
    /// Optional. Google Places type of the venue. (See supported types.)
    google_place_type: ?[]const u8 = null,
};

/// Represents a video to be sent.
/// Reference: https://core.telegram.org/bots/api#inputmediavideo
pub const InputMediaVideo = struct {
    /// Type of the media, must be video
    type: []const u8 = "video",
    /// File to send. Pass a file_id to send a file that exists on the Telegram servers (recommended), pass an HTTP URL for Telegram to get a file from the Internet, or pass "attach://<file_attach_name>" to upload a new one using multipart/form-data under <file_attach_name> name. More information on Sending Files: https://core.telegram.org/bots/api#sending-files
    media: InputFile,
    /// Optional. Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail's width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can't be reused and can be only uploaded as a new file, so you can pass "attach://<file_attach_name>" if the thumbnail was uploaded using multipart/form-data under <file_attach_name>. More information on Sending Files: https://core.telegram.org/bots/api#sending-files
    thumbnail: ?InputFile = null,
    /// Optional. Cover for the video in the message. Pass a file_id to send a file that exists on the Telegram servers (recommended), pass an HTTP URL for Telegram to get a file from the Internet, or pass "attach://<file_attach_name>" to upload a new one using multipart/form-data under <file_attach_name> name. More information on Sending Files: https://core.telegram.org/bots/api#sending-files
    cover: ?InputFile = null,
    /// Optional. Start timestamp for the video in the message
    start_timestamp: ?i64 = null,
    /// Optional. Caption of the video to be sent, 0-1024 characters after entities parsing
    caption: ?[]const u8 = null,
    /// Optional. Mode for parsing entities in the video caption. See formatting options for more details.
    parse_mode: ?enums.ParseMode = null,
    /// Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
    caption_entities: ?[]const MessageEntity = null,
    /// Optional. Pass True if the caption must be shown above the message media
    show_caption_above_media: ?bool = null,
    /// Optional. Video width
    width: ?i64 = null,
    /// Optional. Video height
    height: ?i64 = null,
    /// Optional. Video duration in seconds
    duration: ?i64 = null,
    /// Optional. Pass True if the uploaded video is suitable for streaming
    supports_streaming: ?bool = null,
    /// Optional. Pass True if the video needs to be covered with a spoiler animation
    has_spoiler: ?bool = null,
};

/// Represents a voice message file to be sent.
/// Reference: https://core.telegram.org/bots/api#inputmediavoicenote
pub const InputMediaVoiceNote = struct {
    /// Type of the media, must be voice_note
    type: []const u8 = "voice_note",
    /// File to send. Pass a file_id to send a file that exists on the Telegram servers (recommended), pass an HTTP URL for Telegram to get a file from the Internet, or pass "attach://<file_attach_name>" to upload a new one using multipart/form-data under <file_attach_name> name. More information on Sending Files: https://core.telegram.org/bots/api#sending-files
    media: InputFile,
    /// Optional. Caption of the voice message to be sent, 0-1024 characters after entities parsing
    caption: ?[]const u8 = null,
    /// Optional. Mode for parsing entities in the voice message caption. See formatting options for more details.
    parse_mode: ?enums.ParseMode = null,
    /// Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
    caption_entities: ?[]const MessageEntity = null,
    /// Optional. Duration of the voice message in seconds
    duration: ?i64 = null,
};

/// This object represents the content of a message to be sent as a result of an inline query. Telegram clients currently support the following types:
/// - InputTextMessageContent
/// - InputRichMessageContent
/// - InputLocationMessageContent
/// - InputVenueMessageContent
/// - InputContactMessageContent
/// - InputInvoiceMessageContent
/// Reference: https://core.telegram.org/bots/api#inputmessagecontent
pub const InputMessageContent = union(enum) {
    input_text_message_content: InputTextMessageContent,
    input_rich_message_content: InputRichMessageContent,
    input_location_message_content: InputLocationMessageContent,
    input_venue_message_content: InputVenueMessageContent,
    input_contact_message_content: InputContactMessageContent,
    input_invoice_message_content: InputInvoiceMessageContent,

    pub fn jsonStringify(self: InputMessageContent, jw: anytype) !void {
        switch (self) {
            inline else => |payload| try jw.write(payload),
        }
    }

    pub fn jsonParse(
        allocator: Allocator,
        source: anytype,
        options: std.json.ParseOptions,
    ) std.json.ParseError(@TypeOf(source.*))!InputMessageContent {
        const raw = try json_mod.captureRawJsonValue(allocator, source);
        var sub = std.json.Scanner.initCompleteInput(allocator, raw);
        defer sub.deinit();
        var opts = options;
        opts.ignore_unknown_fields = true;
        if (opts.allocate == null) opts.allocate = .alloc_if_needed;
        if (opts.max_value_len == null) opts.max_value_len = std.json.default_max_value_len;
        if (try json_mod.hasTopLevelField(allocator, raw, "message_text")) {
            return .{ .input_text_message_content = try std.json.innerParse(InputTextMessageContent, allocator, &sub, opts) };
        }
        if (try json_mod.hasTopLevelField(allocator, raw, "rich_message")) {
            return .{ .input_rich_message_content = try std.json.innerParse(InputRichMessageContent, allocator, &sub, opts) };
        }
        if (try json_mod.hasTopLevelField(allocator, raw, "address")) {
            return .{ .input_venue_message_content = try std.json.innerParse(InputVenueMessageContent, allocator, &sub, opts) };
        }
        if (try json_mod.hasTopLevelField(allocator, raw, "latitude")) {
            return .{ .input_location_message_content = try std.json.innerParse(InputLocationMessageContent, allocator, &sub, opts) };
        }
        if (try json_mod.hasTopLevelField(allocator, raw, "phone_number")) {
            return .{ .input_contact_message_content = try std.json.innerParse(InputContactMessageContent, allocator, &sub, opts) };
        }
        if (try json_mod.hasTopLevelField(allocator, raw, "prices")) {
            return .{ .input_invoice_message_content = try std.json.innerParse(InputInvoiceMessageContent, allocator, &sub, opts) };
        }
        return error.UnexpectedToken;
    }
};

/// This object describes the paid media to be sent. Currently, it can be one of
/// - InputPaidMediaLivePhoto
/// - InputPaidMediaPhoto
/// - InputPaidMediaVideo
/// Reference: https://core.telegram.org/bots/api#inputpaidmedia
pub const InputPaidMedia = union(enum) {
    live_photo: InputPaidMediaLivePhoto,
    photo: InputPaidMediaPhoto,
    video: InputPaidMediaVideo,

    pub fn jsonStringify(self: InputPaidMedia, jw: anytype) !void {
        switch (self) {
            inline else => |payload| try jw.write(payload),
        }
    }

    pub fn writeMultipartJson(
        self: InputPaidMedia,
        arena: Allocator,
        jw: *std.json.Stringify,
        pending_parts: *std.ArrayList(multipart_mod.PendingPart),
        comptime writeFn: anytype,
    ) !void {
        switch (self) {
            inline else => |payload| try writeFn(arena, jw, payload, pending_parts),
        }
    }

    pub fn jsonParse(
        allocator: Allocator,
        source: anytype,
        options: std.json.ParseOptions,
    ) std.json.ParseError(@TypeOf(source.*))!InputPaidMedia {
        return json_mod.parseDiscriminatedUnion(
            InputPaidMedia,
            "type",
            .{
                .{ "live_photo", "live_photo" },
                .{ "photo", "photo" },
                .{ "video", "video" },
            },
            allocator,
            source,
            options,
        );
    }
};

/// The paid media to send is a live photo.
/// Reference: https://core.telegram.org/bots/api#inputpaidmedialivephoto
pub const InputPaidMediaLivePhoto = struct {
    /// Type of the media, must be live_photo
    type: []const u8 = "live_photo",
    /// Video of the live photo to send. Pass a file_id to send a file that exists on the Telegram servers (recommended) or pass "attach://<file_attach_name>" to upload a new one using multipart/form-data under <file_attach_name> name. More information on Sending Files: https://core.telegram.org/bots/api#sending-files. Sending live photos by a URL is currently unsupported.
    media: InputFile,
    /// The static photo to send. Pass a file_id to send a file that exists on the Telegram servers (recommended) or pass "attach://<file_attach_name>" to upload a new one using multipart/form-data under <file_attach_name> name. More information on Sending Files: https://core.telegram.org/bots/api#sending-files. Sending live photos by a URL is currently unsupported.
    photo: InputFile,
};

/// The paid media to send is a photo.
/// Reference: https://core.telegram.org/bots/api#inputpaidmediaphoto
pub const InputPaidMediaPhoto = struct {
    /// Type of the media, must be photo
    type: []const u8 = "photo",
    /// File to send. Pass a file_id to send a file that exists on the Telegram servers (recommended), pass an HTTP URL for Telegram to get a file from the Internet, or pass "attach://<file_attach_name>" to upload a new one using multipart/form-data under <file_attach_name> name. More information on Sending Files: https://core.telegram.org/bots/api#sending-files
    media: InputFile,
};

/// The paid media to send is a video.
/// Reference: https://core.telegram.org/bots/api#inputpaidmediavideo
pub const InputPaidMediaVideo = struct {
    /// Type of the media, must be video
    type: []const u8 = "video",
    /// File to send. Pass a file_id to send a file that exists on the Telegram servers (recommended), pass an HTTP URL for Telegram to get a file from the Internet, or pass "attach://<file_attach_name>" to upload a new one using multipart/form-data under <file_attach_name> name. More information on Sending Files: https://core.telegram.org/bots/api#sending-files
    media: InputFile,
    /// Optional. Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail's width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can't be reused and can be only uploaded as a new file, so you can pass "attach://<file_attach_name>" if the thumbnail was uploaded using multipart/form-data under <file_attach_name>. More information on Sending Files: https://core.telegram.org/bots/api#sending-files
    thumbnail: ?InputFile = null,
    /// Optional. Cover for the video in the message. Pass a file_id to send a file that exists on the Telegram servers (recommended), pass an HTTP URL for Telegram to get a file from the Internet, or pass "attach://<file_attach_name>" to upload a new one using multipart/form-data under <file_attach_name> name. More information on Sending Files: https://core.telegram.org/bots/api#sending-files
    cover: ?InputFile = null,
    /// Optional. Start timestamp for the video in the message
    start_timestamp: ?i64 = null,
    /// Optional. Video width
    width: ?i64 = null,
    /// Optional. Video height
    height: ?i64 = null,
    /// Optional. Video duration in seconds
    duration: ?i64 = null,
    /// Optional. Pass True if the uploaded video is suitable for streaming
    supports_streaming: ?bool = null,
};

/// This object represents the content of a poll description or a quiz explanation to be sent. It should be one of
/// - InputMediaAnimation
/// - InputMediaAudio
/// - InputMediaDocument
/// - InputMediaLivePhoto
/// - InputMediaLocation
/// - InputMediaPhoto
/// - InputMediaVenue
/// - InputMediaVideo
/// Reference: https://core.telegram.org/bots/api#inputpollmedia
pub const InputPollMedia = union(enum) {
    animation: InputMediaAnimation,
    audio: InputMediaAudio,
    document: InputMediaDocument,
    live_photo: InputMediaLivePhoto,
    location: InputMediaLocation,
    photo: InputMediaPhoto,
    venue: InputMediaVenue,
    video: InputMediaVideo,

    pub fn jsonStringify(self: InputPollMedia, jw: anytype) !void {
        switch (self) {
            inline else => |payload| try jw.write(payload),
        }
    }

    pub fn writeMultipartJson(
        self: InputPollMedia,
        arena: Allocator,
        jw: *std.json.Stringify,
        pending_parts: *std.ArrayList(multipart_mod.PendingPart),
        comptime writeFn: anytype,
    ) !void {
        switch (self) {
            inline else => |payload| try writeFn(arena, jw, payload, pending_parts),
        }
    }

    pub fn jsonParse(
        allocator: Allocator,
        source: anytype,
        options: std.json.ParseOptions,
    ) std.json.ParseError(@TypeOf(source.*))!InputPollMedia {
        return json_mod.parseDiscriminatedUnion(
            InputPollMedia,
            "type",
            .{
                .{ "animation", "animation" },
                .{ "audio", "audio" },
                .{ "document", "document" },
                .{ "live_photo", "live_photo" },
                .{ "location", "location" },
                .{ "photo", "photo" },
                .{ "venue", "venue" },
                .{ "video", "video" },
            },
            allocator,
            source,
            options,
        );
    }
};

/// This object contains information about one answer option in a poll to be sent.
/// Reference: https://core.telegram.org/bots/api#inputpolloption
pub const InputPollOption = struct {
    /// Option text, 1-100 characters
    text: []const u8,
    /// Optional. Mode for parsing entities in the text. See formatting options for more details. Currently, only custom emoji entities are allowed.
    text_parse_mode: ?[]const u8 = null,
    /// Optional. A JSON-serialized list of special entities that appear in the poll option text. It can be specified instead of text_parse_mode.
    text_entities: ?[]const MessageEntity = null,
    /// Optional. Media added to the poll option
    media: ?InputPollOptionMedia = null,
};

/// This object represents the content of a poll option to be sent. It should be one of
/// - InputMediaAnimation
/// - InputMediaLink
/// - InputMediaLivePhoto
/// - InputMediaLocation
/// - InputMediaPhoto
/// - InputMediaSticker
/// - InputMediaVenue
/// - InputMediaVideo
/// Reference: https://core.telegram.org/bots/api#inputpolloptionmedia
pub const InputPollOptionMedia = union(enum) {
    animation: InputMediaAnimation,
    link: InputMediaLink,
    live_photo: InputMediaLivePhoto,
    location: InputMediaLocation,
    photo: InputMediaPhoto,
    sticker: InputMediaSticker,
    venue: InputMediaVenue,
    video: InputMediaVideo,

    pub fn jsonStringify(self: InputPollOptionMedia, jw: anytype) !void {
        switch (self) {
            inline else => |payload| try jw.write(payload),
        }
    }

    pub fn writeMultipartJson(
        self: InputPollOptionMedia,
        arena: Allocator,
        jw: *std.json.Stringify,
        pending_parts: *std.ArrayList(multipart_mod.PendingPart),
        comptime writeFn: anytype,
    ) !void {
        switch (self) {
            inline else => |payload| try writeFn(arena, jw, payload, pending_parts),
        }
    }

    pub fn jsonParse(
        allocator: Allocator,
        source: anytype,
        options: std.json.ParseOptions,
    ) std.json.ParseError(@TypeOf(source.*))!InputPollOptionMedia {
        return json_mod.parseDiscriminatedUnion(
            InputPollOptionMedia,
            "type",
            .{
                .{ "animation", "animation" },
                .{ "link", "link" },
                .{ "live_photo", "live_photo" },
                .{ "location", "location" },
                .{ "photo", "photo" },
                .{ "sticker", "sticker" },
                .{ "venue", "venue" },
                .{ "video", "video" },
            },
            allocator,
            source,
            options,
        );
    }
};

/// This object describes a profile photo to set. Currently, it can be one of
/// - InputProfilePhotoStatic
/// - InputProfilePhotoAnimated
/// Reference: https://core.telegram.org/bots/api#inputprofilephoto
pub const InputProfilePhoto = union(enum) {
    static: InputProfilePhotoStatic,
    animated: InputProfilePhotoAnimated,

    pub fn jsonStringify(self: InputProfilePhoto, jw: anytype) !void {
        switch (self) {
            inline else => |payload| try jw.write(payload),
        }
    }

    pub fn writeMultipartJson(
        self: InputProfilePhoto,
        arena: Allocator,
        jw: *std.json.Stringify,
        pending_parts: *std.ArrayList(multipart_mod.PendingPart),
        comptime writeFn: anytype,
    ) !void {
        switch (self) {
            inline else => |payload| try writeFn(arena, jw, payload, pending_parts),
        }
    }

    pub fn jsonParse(
        allocator: Allocator,
        source: anytype,
        options: std.json.ParseOptions,
    ) std.json.ParseError(@TypeOf(source.*))!InputProfilePhoto {
        return json_mod.parseDiscriminatedUnion(
            InputProfilePhoto,
            "type",
            .{
                .{ "static", "static" },
                .{ "animated", "animated" },
            },
            allocator,
            source,
            options,
        );
    }
};

/// An animated profile photo in the MPEG4 format.
/// Reference: https://core.telegram.org/bots/api#inputprofilephotoanimated
pub const InputProfilePhotoAnimated = struct {
    /// Type of the profile photo, must be animated
    type: []const u8 = "animated",
    /// The animated profile photo. Profile photos can't be reused and can only be uploaded as a new file, so you can pass "attach://<file_attach_name>" if the photo was uploaded using multipart/form-data under <file_attach_name>. More information on Sending Files: https://core.telegram.org/bots/api#sending-files
    animation: InputFile,
    /// Optional. Timestamp in seconds of the frame that will be used as the static profile photo. Defaults to 0.0.
    main_frame_timestamp: ?f64 = null,
};

/// A static profile photo in the .JPG format.
/// Reference: https://core.telegram.org/bots/api#inputprofilephotostatic
pub const InputProfilePhotoStatic = struct {
    /// Type of the profile photo, must be static
    type: []const u8 = "static",
    /// The static profile photo. Profile photos can't be reused and can only be uploaded as a new file, so you can pass "attach://<file_attach_name>" if the photo was uploaded using multipart/form-data under <file_attach_name>. More information on Sending Files: https://core.telegram.org/bots/api#sending-files
    photo: InputFile,
};

/// This object represents a block in a rich formatted message to be sent. Currently, it can be any of the following types:
/// - InputRichBlockParagraph
/// - InputRichBlockSectionHeading
/// - InputRichBlockPreformatted
/// - InputRichBlockFooter
/// - InputRichBlockDivider
/// - InputRichBlockMathematicalExpression
/// - InputRichBlockAnchor
/// - InputRichBlockList
/// - InputRichBlockBlockQuotation
/// - InputRichBlockExpandableBlockQuotation
/// - InputRichBlockPullQuotation
/// - InputRichBlockCollage
/// - InputRichBlockSlideshow
/// - InputRichBlockTable
/// - InputRichBlockDetails
/// - InputRichBlockMap
/// - InputRichBlockButtons
/// - InputRichBlockAnimation
/// - InputRichBlockAudio
/// - InputRichBlockDocument
/// - InputRichBlockPhoto
/// - InputRichBlockVideo
/// - InputRichBlockVoiceNote
/// - InputRichBlockThinking
/// Reference: https://core.telegram.org/bots/api#inputrichblock
pub const InputRichBlock = union(enum) {
    paragraph: InputRichBlockParagraph,
    section_heading: InputRichBlockSectionHeading,
    preformatted: InputRichBlockPreformatted,
    footer: InputRichBlockFooter,
    divider: InputRichBlockDivider,
    mathematical_expression: InputRichBlockMathematicalExpression,
    anchor: InputRichBlockAnchor,
    list: InputRichBlockList,
    block_quotation: InputRichBlockBlockQuotation,
    expandable_block_quotation: InputRichBlockExpandableBlockQuotation,
    pull_quotation: InputRichBlockPullQuotation,
    collage: InputRichBlockCollage,
    slideshow: InputRichBlockSlideshow,
    table: InputRichBlockTable,
    details: InputRichBlockDetails,
    map: InputRichBlockMap,
    buttons: InputRichBlockButtons,
    animation: InputRichBlockAnimation,
    audio: InputRichBlockAudio,
    document: InputRichBlockDocument,
    photo: InputRichBlockPhoto,
    video: InputRichBlockVideo,
    voice_note: InputRichBlockVoiceNote,
    thinking: InputRichBlockThinking,

    pub fn jsonStringify(self: InputRichBlock, jw: anytype) !void {
        switch (self) {
            inline else => |payload| try jw.write(payload),
        }
    }

    pub fn writeMultipartJson(
        self: InputRichBlock,
        arena: Allocator,
        jw: *std.json.Stringify,
        pending_parts: *std.ArrayList(multipart_mod.PendingPart),
        comptime writeFn: anytype,
    ) !void {
        switch (self) {
            inline else => |payload| try writeFn(arena, jw, payload, pending_parts),
        }
    }

    pub fn jsonParse(
        allocator: Allocator,
        source: anytype,
        options: std.json.ParseOptions,
    ) std.json.ParseError(@TypeOf(source.*))!InputRichBlock {
        return json_mod.parseDiscriminatedUnion(
            InputRichBlock,
            "type",
            .{
                .{ "paragraph", "paragraph" },
                .{ "heading", "section_heading" },
                .{ "pre", "preformatted" },
                .{ "footer", "footer" },
                .{ "divider", "divider" },
                .{ "mathematical_expression", "mathematical_expression" },
                .{ "anchor", "anchor" },
                .{ "list", "list" },
                .{ "blockquote", "block_quotation" },
                .{ "expandable_blockquote", "expandable_block_quotation" },
                .{ "pullquote", "pull_quotation" },
                .{ "collage", "collage" },
                .{ "slideshow", "slideshow" },
                .{ "table", "table" },
                .{ "details", "details" },
                .{ "map", "map" },
                .{ "buttons", "buttons" },
                .{ "animation", "animation" },
                .{ "audio", "audio" },
                .{ "document", "document" },
                .{ "photo", "photo" },
                .{ "video", "video" },
                .{ "voice_note", "voice_note" },
                .{ "thinking", "thinking" },
            },
            allocator,
            source,
            options,
        );
    }
};

/// A block with an anchor, corresponding to the HTML tag <a> with the attribute name.
/// Reference: https://core.telegram.org/bots/api#inputrichblockanchor
pub const InputRichBlockAnchor = struct {
    /// Type of the block, always "anchor"
    type: []const u8 = "anchor",
    /// The name of the anchor
    name: []const u8,
};

/// A block with an animation, corresponding to the HTML tag <video>.
/// Reference: https://core.telegram.org/bots/api#inputrichblockanimation
pub const InputRichBlockAnimation = struct {
    /// Type of the block, always "animation"
    type: []const u8 = "animation",
    /// The animation. Caption is ignored.
    animation: InputMediaAnimation,
    /// Optional. Caption of the block
    caption: ?RichBlockCaption = null,
};

/// A block with a music file, corresponding to the HTML tag <audio>.
/// Reference: https://core.telegram.org/bots/api#inputrichblockaudio
pub const InputRichBlockAudio = struct {
    /// Type of the block, always "audio"
    type: []const u8 = "audio",
    /// The audio. Caption is ignored.
    audio: InputMediaAudio,
    /// Optional. Caption of the block
    caption: ?RichBlockCaption = null,
};

/// A block quotation, corresponding to the HTML tag <blockquote>.
/// Reference: https://core.telegram.org/bots/api#inputrichblockblockquotation
pub const InputRichBlockBlockQuotation = struct {
    /// Type of the block, always "blockquote"
    type: []const u8 = "blockquote",
    /// Content of the block
    blocks: []const InputRichBlock,
    /// Optional. Credit of the block
    credit: ?*const RichText = null,
};

/// A block containing a list of buttons that are shown in one row, corresponding to the custom HTML tag <tg-button-row>.
/// Reference: https://core.telegram.org/bots/api#inputrichblockbuttons
pub const InputRichBlockButtons = struct {
    /// Type of the block, always "buttons"
    type: []const u8 = "buttons",
    /// List of 1-8 buttons to send
    buttons: []const RichMessageButton,
    /// Optional. Horizontal alignment of the buttons. Currently, must be one of "left", "center", or "right".
    @"align": ?[]const u8 = null,
};

/// A collage, corresponding to the custom HTML tag <tg-collage>.
/// Reference: https://core.telegram.org/bots/api#inputrichblockcollage
pub const InputRichBlockCollage = struct {
    /// Type of the block, always "collage"
    type: []const u8 = "collage",
    /// Elements of the collage
    blocks: []const InputRichBlock,
    /// Optional. Caption of the block
    caption: ?RichBlockCaption = null,
};

/// An expandable block for details disclosure, corresponding to the HTML tag <details>.
/// Reference: https://core.telegram.org/bots/api#inputrichblockdetails
pub const InputRichBlockDetails = struct {
    /// Type of the block, always "details"
    type: []const u8 = "details",
    /// Always shown summary of the block
    summary: *const RichText,
    /// Content of the block
    blocks: []const InputRichBlock,
    /// Optional. Pass True if the content of the block is visible by default
    is_open: ?bool = null,
};

/// A divider, corresponding to the HTML tag <hr/>.
/// Reference: https://core.telegram.org/bots/api#inputrichblockdivider
pub const InputRichBlockDivider = struct {
    /// Type of the block, always "divider"
    type: []const u8 = "divider",
};

/// A block with a general file, corresponding to the custom HTML tag <tg-document>.
/// Reference: https://core.telegram.org/bots/api#inputrichblockdocument
pub const InputRichBlockDocument = struct {
    /// Type of the block, always "document"
    type: []const u8 = "document",
    /// The document. Caption is ignored.
    document: InputMediaDocument,
    /// Optional. Caption of the block
    caption: ?RichBlockCaption = null,
};

/// A block quotation, corresponding to the HTML tag <blockquote> with custom attribute "expandable".
/// Reference: https://core.telegram.org/bots/api#inputrichblockexpandableblockquotation
pub const InputRichBlockExpandableBlockQuotation = struct {
    /// Type of the block, always "expandable_blockquote"
    type: []const u8 = "expandable_blockquote",
    /// Content of the block
    text: *const RichText,
    /// Optional. Credit of the block
    credit: ?*const RichText = null,
};

/// A footer, corresponding to the HTML tag <footer>.
/// Reference: https://core.telegram.org/bots/api#inputrichblockfooter
pub const InputRichBlockFooter = struct {
    /// Type of the block, always "footer"
    type: []const u8 = "footer",
    /// Text of the block
    text: *const RichText,
};

/// A list of blocks, corresponding to the HTML tag <ul> or <ol> with multiple nested tags <li>.
/// Reference: https://core.telegram.org/bots/api#inputrichblocklist
pub const InputRichBlockList = struct {
    /// Type of the block, always "list"
    type: []const u8 = "list",
    /// Items of the list
    items: []const InputRichBlockListItem,
};

/// An item of a list to be sent.
/// Reference: https://core.telegram.org/bots/api#inputrichblocklistitem
pub const InputRichBlockListItem = struct {
    /// The content of the item
    blocks: []const InputRichBlock,
    /// Optional. Pass True if the item has a checkbox
    has_checkbox: ?bool = null,
    /// Optional. Pass True if the item has a checked checkbox
    is_checked: ?bool = null,
    /// Optional. For ordered lists, the numeric value of the item label
    value: ?i64 = null,
    /// Optional. For ordered lists, the type of the item label; must be one of "a" for lowercase letters, "A" for uppercase letters, "i" for lowercase Roman numerals, "I" for uppercase Roman numerals, or "1" for decimal numbers
    type: ?[]const u8 = null,
};

/// A block with a map, corresponding to the custom HTML tag <tg-map>. The map's width and height must not exceed 10000 in total. The width and height ratio must be at most 20.
/// Reference: https://core.telegram.org/bots/api#inputrichblockmap
pub const InputRichBlockMap = struct {
    /// Type of the block, always "map"
    type: []const u8 = "map",
    /// Location of the center of the map
    location: Location,
    /// Optional. Map zoom level; 0-24
    zoom: ?i64 = null,
    /// Optional. Map width; 0-10000
    width: ?i64 = null,
    /// Optional. Map height; 0-10000
    height: ?i64 = null,
    /// Optional. Caption of the block
    caption: ?RichBlockCaption = null,
};

/// A block with a mathematical expression in LaTeX format, corresponding to the custom HTML tag <tg-math-block>.
/// Reference: https://core.telegram.org/bots/api#inputrichblockmathematicalexpression
pub const InputRichBlockMathematicalExpression = struct {
    /// Type of the block, always "mathematical_expression"
    type: []const u8 = "mathematical_expression",
    /// The mathematical expression in LaTeX format
    expression: []const u8,
};

/// A text paragraph, corresponding to the HTML tag <p>.
/// Reference: https://core.telegram.org/bots/api#inputrichblockparagraph
pub const InputRichBlockParagraph = struct {
    /// Type of the block, always "paragraph"
    type: []const u8 = "paragraph",
    /// Text of the block
    text: *const RichText,
};

/// A block with a photo, corresponding to the HTML tag <img>.
/// Reference: https://core.telegram.org/bots/api#inputrichblockphoto
pub const InputRichBlockPhoto = struct {
    /// Type of the block, always "photo"
    type: []const u8 = "photo",
    /// The photo. Caption is ignored.
    photo: InputMediaPhoto,
    /// Optional. Caption of the block
    caption: ?RichBlockCaption = null,
};

/// A preformatted text block, corresponding to the nested HTML tags <pre> and <code>.
/// Reference: https://core.telegram.org/bots/api#inputrichblockpreformatted
pub const InputRichBlockPreformatted = struct {
    /// Type of the block, always "pre"
    type: []const u8 = "pre",
    /// Text of the block
    text: *const RichText,
    /// Optional. The programming language of the text
    language: ?[]const u8 = null,
};

/// A quotation with centered text, loosely corresponding to the HTML tag <aside>.
/// Reference: https://core.telegram.org/bots/api#inputrichblockpullquotation
pub const InputRichBlockPullQuotation = struct {
    /// Type of the block, always "pullquote"
    type: []const u8 = "pullquote",
    /// Text of the block
    text: *const RichText,
    /// Optional. Credit of the block
    credit: ?*const RichText = null,
};

/// A section heading, corresponding to the HTML tags <h1>, <h2>, <h3>, <h4>, <h5>, or <h6>.
/// Reference: https://core.telegram.org/bots/api#inputrichblocksectionheading
pub const InputRichBlockSectionHeading = struct {
    /// Type of the block, always "heading"
    type: []const u8 = "heading",
    /// Text of the block
    text: *const RichText,
    /// Relative size of the text font; 1-6, 1 is the largest, 6 is the smallest
    size: i64,
};

/// A slideshow, corresponding to the custom HTML tag <tg-slideshow>.
/// Reference: https://core.telegram.org/bots/api#inputrichblockslideshow
pub const InputRichBlockSlideshow = struct {
    /// Type of the block, always "slideshow"
    type: []const u8 = "slideshow",
    /// Elements of the slideshow
    blocks: []const InputRichBlock,
    /// Optional. Caption of the block
    caption: ?RichBlockCaption = null,
};

/// A table, corresponding to the HTML tag <table>.
/// Reference: https://core.telegram.org/bots/api#inputrichblocktable
pub const InputRichBlockTable = struct {
    /// Type of the block, always "table"
    type: []const u8 = "table",
    /// Cells of the table
    cells: []const []const RichBlockTableCell,
    /// Optional. Pass True if the table has borders
    is_bordered: ?bool = null,
    /// Optional. Pass True if the table is striped
    is_striped: ?bool = null,
    /// Optional. Pass True if table cells must have smaller indents
    is_compact: ?bool = null,
    /// Optional. Caption of the table
    caption: ?*const RichText = null,
};

/// A block with a "Thinking..." placeholder, corresponding to the custom HTML tag <tg-thinking>. The block may be used only in sendRichMessageDraft, therefore it can't be received in messages. See https://t.me/addemoji/AIActions for examples of custom emoji that are recommended for usage in the block.
/// Reference: https://core.telegram.org/bots/api#inputrichblockthinking
pub const InputRichBlockThinking = struct {
    /// Type of the block, always "thinking"
    type: []const u8 = "thinking",
    /// Text of the block. See https://t.me/addemoji/AIActions for examples of custom emoji that are recommended for usage in the block.
    text: *const RichText,
};

/// A block with a video, corresponding to the HTML tag <video>.
/// Reference: https://core.telegram.org/bots/api#inputrichblockvideo
pub const InputRichBlockVideo = struct {
    /// Type of the block, always "video"
    type: []const u8 = "video",
    /// The video. Caption is ignored.
    video: InputMediaVideo,
    /// Optional. Caption of the block
    caption: ?RichBlockCaption = null,
};

/// A block with a voice note, corresponding to the HTML tag <audio>.
/// Reference: https://core.telegram.org/bots/api#inputrichblockvoicenote
pub const InputRichBlockVoiceNote = struct {
    /// Type of the block, always "voice_note"
    type: []const u8 = "voice_note",
    /// The voice note. Caption is ignored.
    voice_note: InputMediaVoiceNote,
    /// Optional. Caption of the block
    caption: ?RichBlockCaption = null,
};

/// Describes a rich message to be sent. Exactly one of the fields html, markdown, or blocks must be used.
/// Reference: https://core.telegram.org/bots/api#inputrichmessage
pub const InputRichMessage = struct {
    /// Optional. Content of the rich message to send described as a list of blocks
    blocks: ?[]const InputRichBlock = null,
    /// Optional. Content of the rich message to send described using HTML formatting. See rich message formatting options for more details. Use media field to specify the media used in the message.
    html: ?[]const u8 = null,
    /// Optional. Content of the rich message to send described using Markdown formatting. See rich message formatting options for more details. Use media field to specify the media used in the message.
    markdown: ?[]const u8 = null,
    /// Optional. List of media that are specified in the markdown or html fields using tg://photo?id=, tg://video?id=, tg://document?id=, and tg://audio?id= links
    media: ?[]const InputRichMessageMedia = null,
    /// Optional. Pass True if the rich message must be shown right-to-left
    is_rtl: ?bool = null,
    /// Optional. Pass True to skip automatic detection of entities (e.g., URLs, email addresses, username mentions, hashtags, cashtags, bot commands, or phone numbers) in the text
    skip_entity_detection: ?bool = null,
};

/// Represents the content of a rich message to be sent as the result of an inline query.
/// Reference: https://core.telegram.org/bots/api#inputrichmessagecontent
pub const InputRichMessageContent = struct {
    /// The message to be sent. Only previously uploaded files may be used in the message.
    rich_message: InputRichMessage,
};

/// Describes a media element embedded in an outgoing rich message.
/// Reference: https://core.telegram.org/bots/api#inputrichmessagemedia
pub const InputRichMessageMedia = struct {
    /// Unique identifier of the media used in a tg://photo?id=, tg://video?id=, tg://document?id=, or tg://audio?id= link. 1-64 characters, only A-Z, a-z, 0-9, _ and - are allowed.
    id: []const u8,
    /// The media to be sent. Everything except the media itself and its properties is ignored.
    media: InputMedia,
};

/// This object describes a sticker to be added to a sticker set.
/// Reference: https://core.telegram.org/bots/api#inputsticker
pub const InputSticker = struct {
    /// The added sticker. Pass a file_id as a String to send a file that already exists on the Telegram servers, pass an HTTP URL as a String for Telegram to get a file from the Internet, or pass "attach://<file_attach_name>" to upload a new file using multipart/form-data under <file_attach_name> name. Animated and video stickers can't be uploaded via HTTP URL. More information on Sending Files: https://core.telegram.org/bots/api#sending-files
    sticker: InputFile,
    /// Format of the added sticker, must be one of "static" for a .WEBP or .PNG image, "animated" for a .TGS animation, "video" for a .WEBM video
    format: []const u8 = "one",
    /// List of 1-20 emoji associated with the sticker
    emoji_list: []const []const u8,
    /// Optional. Position where the mask should be placed on faces. For "mask" stickers only.
    mask_position: ?MaskPosition = null,
    /// Optional. List of 0-20 search keywords for the sticker with total length of up to 64 characters. For "regular" and "custom_emoji" stickers only.
    keywords: ?[]const []const u8 = null,
};

/// This object describes the content of a story to post. Currently, it can be one of
/// - InputStoryContentPhoto
/// - InputStoryContentVideo
/// Reference: https://core.telegram.org/bots/api#inputstorycontent
pub const InputStoryContent = union(enum) {
    photo: InputStoryContentPhoto,
    video: InputStoryContentVideo,

    pub fn jsonStringify(self: InputStoryContent, jw: anytype) !void {
        switch (self) {
            inline else => |payload| try jw.write(payload),
        }
    }

    pub fn writeMultipartJson(
        self: InputStoryContent,
        arena: Allocator,
        jw: *std.json.Stringify,
        pending_parts: *std.ArrayList(multipart_mod.PendingPart),
        comptime writeFn: anytype,
    ) !void {
        switch (self) {
            inline else => |payload| try writeFn(arena, jw, payload, pending_parts),
        }
    }

    pub fn jsonParse(
        allocator: Allocator,
        source: anytype,
        options: std.json.ParseOptions,
    ) std.json.ParseError(@TypeOf(source.*))!InputStoryContent {
        return json_mod.parseDiscriminatedUnion(
            InputStoryContent,
            "type",
            .{
                .{ "photo", "photo" },
                .{ "video", "video" },
            },
            allocator,
            source,
            options,
        );
    }
};

/// Describes a photo to post as a story.
/// Reference: https://core.telegram.org/bots/api#inputstorycontentphoto
pub const InputStoryContentPhoto = struct {
    /// Type of the content, must be photo
    type: []const u8 = "photo",
    /// The photo to post as a story. The photo must be of the size 1080x1920 and must not exceed 10 MB. The photo can't be reused and can only be uploaded as a new file, so you can pass "attach://<file_attach_name>" if the photo was uploaded using multipart/form-data under <file_attach_name>. More information on Sending Files: https://core.telegram.org/bots/api#sending-files
    photo: InputFile,
};

/// Describes a video to post as a story.
/// Reference: https://core.telegram.org/bots/api#inputstorycontentvideo
pub const InputStoryContentVideo = struct {
    /// Type of the content, must be video
    type: []const u8 = "video",
    /// The video to post as a story. The video must be of the size 720x1280, streamable, encoded with H.265 codec, with key frames added each second in the MPEG4 format, and must not exceed 30 MB. The video can't be reused and can only be uploaded as a new file, so you can pass "attach://<file_attach_name>" if the video was uploaded using multipart/form-data under <file_attach_name>. More information on Sending Files: https://core.telegram.org/bots/api#sending-files
    video: InputFile,
    /// Optional. Precise duration of the video in seconds; 0-60
    duration: ?f64 = null,
    /// Optional. Timestamp in seconds of the frame that will be used as the static cover for the story. Defaults to 0.0.
    cover_frame_timestamp: ?f64 = null,
    /// Optional. Pass True if the video has no sound
    is_animation: ?bool = null,
};

/// Represents the content of a text message to be sent as the result of an inline query.
/// Reference: https://core.telegram.org/bots/api#inputtextmessagecontent
pub const InputTextMessageContent = struct {
    /// Text of the message to be sent, 1-4096 characters
    message_text: []const u8,
    /// Optional. Mode for parsing entities in the message text. See formatting options for more details.
    parse_mode: ?enums.ParseMode = null,
    /// Optional. List of special entities that appear in message text, which can be specified instead of parse_mode
    entities: ?[]const MessageEntity = null,
    /// Optional. Link preview generation options for the message
    link_preview_options: ?LinkPreviewOptions = null,
};

/// Represents the content of a venue message to be sent as the result of an inline query.
/// Reference: https://core.telegram.org/bots/api#inputvenuemessagecontent
pub const InputVenueMessageContent = struct {
    /// Latitude of the venue in degrees
    latitude: f64,
    /// Longitude of the venue in degrees
    longitude: f64,
    /// Name of the venue
    title: []const u8,
    /// Address of the venue
    address: []const u8,
    /// Optional. Foursquare identifier of the venue, if known
    foursquare_id: ?[]const u8 = null,
    /// Optional. Foursquare type of the venue, if known. (For example, "arts_entertainment/default", "arts_entertainment/aquarium" or "food/icecream".)
    foursquare_type: ?[]const u8 = null,
    /// Optional. Google Places identifier of the venue
    google_place_id: ?[]const u8 = null,
    /// Optional. Google Places type of the venue. (See supported types.)
    google_place_type: ?[]const u8 = null,
};

/// This object contains basic information about an invoice.
/// Reference: https://core.telegram.org/bots/api#invoice
pub const Invoice = struct {
    /// Product name
    title: []const u8,
    /// Product description
    description: []const u8,
    /// Unique bot deep-linking parameter that can be used to generate this invoice
    start_parameter: []const u8,
    /// Three-letter ISO 4217 currency code, or "XTR" for payments in Telegram Stars
    currency: []const u8,
    /// Total price in the smallest units of the currency (integer, not float/double). For example, for a price of US$ 1.45 pass amount = 145. See the exp parameter in currencies.json, it shows the number of digits past the decimal point for each currency (2 for the majority of currencies).
    total_amount: i64,
};

/// This object represents one button of the reply keyboard. At most one of the fields other than text, icon_custom_emoji_id, and style must be used to specify the type of the button. For simple text buttons, String can be used instead of this object to specify the button text.
/// Reference: https://core.telegram.org/bots/api#keyboardbutton
pub const KeyboardButton = struct {
    /// Text of the button. If none of the fields other than text, icon_custom_emoji_id, and style are used, it will be sent as a message when the button is pressed.
    text: []const u8,
    /// Optional. Unique identifier of the custom emoji shown before the text of the button. Can only be used by bots that purchased additional usernames on Fragment or in the messages directly sent by the bot to private, group and supergroup chats if the owner of the bot has a Telegram Premium subscription.
    icon_custom_emoji_id: ?[]const u8 = null,
    /// Optional. Style of the button. Must be one of "danger" (red), "success" (green) or "primary" (blue). If omitted, then an app-specific style is used.
    style: ?[]const u8 = null,
    /// Optional. If specified, pressing the button will open a list of suitable users. Identifiers of selected users will be sent to the bot in a "users_shared" service message. Available in private chats only.
    request_users: ?KeyboardButtonRequestUsers = null,
    /// Optional. If specified, pressing the button will open a list of suitable chats. Tapping on a chat will send its identifier to the bot in a "chat_shared" service message. Available in private chats only.
    request_chat: ?KeyboardButtonRequestChat = null,
    /// Optional. If specified, pressing the button will ask the user to create and share a bot that will be managed by the current bot. Available for bots that enabled management of other bots in the @BotFather Mini App. Available in private chats only.
    request_managed_bot: ?KeyboardButtonRequestManagedBot = null,
    /// Optional. If True, the user's phone number will be sent as a contact when the button is pressed. Available in private chats only.
    request_contact: ?bool = null,
    /// Optional. If True, the user's current location will be sent when the button is pressed. Available in private chats only.
    request_location: ?bool = null,
    /// Optional. If specified, the user will be asked to create a poll and send it to the bot when the button is pressed. Available in private chats only.
    request_poll: ?KeyboardButtonPollType = null,
    /// Optional. If specified, the described Web App will be launched when the button is pressed. The Web App will be able to send a "web_app_data" service message. Available in private chats only.
    web_app: ?WebAppInfo = null,
};

/// This object represents type of a poll, which is allowed to be created and sent when the corresponding button is pressed.
/// Reference: https://core.telegram.org/bots/api#keyboardbuttonpolltype
pub const KeyboardButtonPollType = struct {
    /// Optional. If quiz is passed, the user will be allowed to create only polls in the quiz mode. If regular is passed, only regular polls will be allowed. Otherwise, the user will be allowed to create a poll of any type.
    type: ?[]const u8 = null,
};

/// This object defines the criteria used to request a suitable chat. Information about the selected chat will be shared with the bot when the corresponding button is pressed. The bot will be granted requested rights in the chat if appropriate. More about requesting chats: https://core.telegram.org/bots/features#chat-and-user-selection.
/// Reference: https://core.telegram.org/bots/api#keyboardbuttonrequestchat
pub const KeyboardButtonRequestChat = struct {
    /// Signed 32-bit identifier of the request, which will be received back in the ChatShared object. Must be unique within the message.
    request_id: i64,
    /// Pass True to request a channel chat, pass False to request a group or a supergroup chat
    chat_is_channel: bool,
    /// Optional. Pass True to request a forum supergroup, pass False to request a non-forum chat. If not specified, no additional restrictions are applied.
    chat_is_forum: ?bool = null,
    /// Optional. Pass True to request a supergroup or a channel with a username, pass False to request a chat without a username. If not specified, no additional restrictions are applied.
    chat_has_username: ?bool = null,
    /// Optional. Pass True to request a chat owned by the user. Otherwise, no additional restrictions are applied.
    chat_is_created: ?bool = null,
    /// Optional. A JSON-serialized object listing the required administrator rights of the user in the chat. The rights must be a superset of bot_administrator_rights. If not specified, no additional restrictions are applied.
    user_administrator_rights: ?ChatAdministratorRights = null,
    /// Optional. A JSON-serialized object listing the required administrator rights of the bot in the chat. The rights must be a subset of user_administrator_rights. If not specified, no additional restrictions are applied.
    bot_administrator_rights: ?ChatAdministratorRights = null,
    /// Optional. Pass True to request a chat with the bot as a member. Otherwise, no additional restrictions are applied.
    bot_is_member: ?bool = null,
    /// Optional. Pass True to request the chat's title
    request_title: ?bool = null,
    /// Optional. Pass True to request the chat's username
    request_username: ?bool = null,
    /// Optional. Pass True to request the chat's photo
    request_photo: ?bool = null,
};

/// This object defines the parameters for the creation of a managed bot. Information about the created bot will be shared with the bot using the update managed_bot and a Message with the field managed_bot_created.
/// Reference: https://core.telegram.org/bots/api#keyboardbuttonrequestmanagedbot
pub const KeyboardButtonRequestManagedBot = struct {
    /// Signed 32-bit identifier of the request. Must be unique within the message.
    request_id: i64,
    /// Optional. Suggested name for the bot
    suggested_name: ?[]const u8 = null,
    /// Optional. Suggested username for the bot
    suggested_username: ?[]const u8 = null,
};

/// This object defines the criteria used to request suitable users. Information about the selected users will be shared with the bot when the corresponding button is pressed. More about requesting users: https://core.telegram.org/bots/features#chat-and-user-selection
/// Reference: https://core.telegram.org/bots/api#keyboardbuttonrequestusers
pub const KeyboardButtonRequestUsers = struct {
    /// Signed 32-bit identifier of the request that will be received back in the UsersShared object. Must be unique within the message.
    request_id: i64,
    /// Optional. Pass True to request bots, pass False to request regular users. If not specified, no additional restrictions are applied.
    user_is_bot: ?bool = null,
    /// Optional. Pass True to request premium users, pass False to request non-premium users. If not specified, no additional restrictions are applied.
    user_is_premium: ?bool = null,
    /// Optional. The maximum number of users to be selected; 1-10. Defaults to 1.
    max_quantity: ?i64 = null,
    /// Optional. Pass True to request the users' first and last names
    request_name: ?bool = null,
    /// Optional. Pass True to request the users' usernames
    request_username: ?bool = null,
    /// Optional. Pass True to request the users' photos
    request_photo: ?bool = null,
};

/// This object represents a portion of the price for goods or services.
/// Reference: https://core.telegram.org/bots/api#labeledprice
pub const LabeledPrice = struct {
    /// Portion label
    label: []const u8,
    /// Price of the product in the smallest units of the currency (integer, not float/double). For example, for a price of US$ 1.45 pass amount = 145. See the exp parameter in currencies.json, it shows the number of digits past the decimal point for each currency (2 for the majority of currencies).
    amount: i64,
};

/// Represents an HTTP link.
/// Reference: https://core.telegram.org/bots/api#link
pub const Link = struct {
    /// URL of the link
    url: []const u8,
};

/// Describes the options used for link preview generation.
/// Reference: https://core.telegram.org/bots/api#linkpreviewoptions
pub const LinkPreviewOptions = struct {
    /// Optional. True, if the link preview is disabled
    is_disabled: ?bool = null,
    /// Optional. URL to use for the link preview. If empty, then the first URL found in the message text will be used.
    url: ?[]const u8 = null,
    /// Optional. True, if the media in the link preview is supposed to be shrunk; ignored if the URL isn't explicitly specified or media size change isn't supported for the preview
    prefer_small_media: ?bool = null,
    /// Optional. True, if the media in the link preview is supposed to be enlarged; ignored if the URL isn't explicitly specified or media size change isn't supported for the preview
    prefer_large_media: ?bool = null,
    /// Optional. True, if the link preview must be shown above the message text; otherwise, the link preview will be shown below the message text
    show_above_text: ?bool = null,
};

/// This object represents a live photo.
/// Reference: https://core.telegram.org/bots/api#livephoto
pub const LivePhoto = struct {
    /// Identifier for the video file which can be used to download or reuse the file
    file_id: []const u8,
    /// Unique identifier for the video file which is supposed to be the same over time and for different bots. Can't be used to download or reuse the file.
    file_unique_id: []const u8,
    /// Video width as defined by the sender
    width: i64,
    /// Video height as defined by the sender
    height: i64,
    /// Duration of the video in seconds as defined by the sender
    duration: i64,
    /// Optional. Available sizes of the corresponding static photo
    photo: ?[]const PhotoSize = null,
    /// Optional. MIME type of the file as defined by the sender
    mime_type: ?[]const u8 = null,
    /// Optional. File size in bytes. It can be bigger than 2^31 and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a signed 64-bit integer or double-precision float type are safe for storing this value.
    file_size: ?i64 = null,
};

/// This object represents a point on the map.
/// Reference: https://core.telegram.org/bots/api#location
pub const Location = struct {
    /// Latitude as defined by the sender
    latitude: f64,
    /// Longitude as defined by the sender
    longitude: f64,
    /// Optional. The radius of uncertainty for the location, measured in meters; 0-1500
    horizontal_accuracy: ?f64 = null,
    /// Optional. Time relative to the message sending date, during which the location can be updated; in seconds. For active live locations only.
    live_period: ?i64 = null,
    /// Optional. The direction in which user is moving, in degrees; 1-360. For active live locations only.
    heading: ?i64 = null,
    /// Optional. The maximum distance for proximity alerts about approaching another chat member, in meters. For sent live locations only.
    proximity_alert_radius: ?i64 = null,
};

/// Describes the physical address of a location.
/// Reference: https://core.telegram.org/bots/api#locationaddress
pub const LocationAddress = struct {
    /// The two-letter ISO 3166-1 alpha-2 country code of the country where the location is located
    country_code: []const u8,
    /// Optional. State of the location
    state: ?[]const u8 = null,
    /// Optional. City of the location
    city: ?[]const u8 = null,
    /// Optional. Street address of the location
    street: ?[]const u8 = null,
};

/// This object represents a parameter of the inline keyboard button used to automatically authorize a user. It serves as a great replacement for the Telegram Login Widget when the user is coming from Telegram. All the user needs to do is tap/click a button and confirm that they want to log in:
/// Reference: https://core.telegram.org/bots/api#loginurl
pub const LoginUrl = struct {
    /// An HTTPS URL to be opened with user authorization data added to the query string when the button is pressed. If the user refuses to provide authorization data, the original URL without information about the user will be opened. The data added is the same as described in Receiving authorization data. NOTE: You must always check the hash of the received data to verify the authentication and the integrity of the data as described in Checking authorization.
    url: []const u8 = "check",
    /// Optional. New text of the button in forwarded messages
    forward_text: ?[]const u8 = null,
    /// Optional. Username of a bot, which will be used for user authorization; not supported in RichMessageButton. See Setting up a bot for more details. If not specified, the current bot's username will be assumed. The url's domain must be the same as the domain linked with the bot. See Linking your domain to the bot for more details.
    bot_username: ?[]const u8 = null,
    /// Optional. Pass True to request the permission for your bot to send messages to the user
    request_write_access: ?bool = null,
};

/// This object contains information about the bot that was created to be managed by the current bot.
/// Reference: https://core.telegram.org/bots/api#managedbotcreated
pub const ManagedBotCreated = struct {
    /// Information about the bot. The bot's token can be fetched using the method getManagedBotToken.
    bot: User,
};

/// This object contains information about the creation, token update, or owner update of a bot that is managed by the current bot.
/// Reference: https://core.telegram.org/bots/api#managedbotupdated
pub const ManagedBotUpdated = struct {
    /// User that created the bot
    user: User,
    /// Information about the bot. Token of the bot can be fetched using the method getManagedBotToken.
    bot: User,
};

/// This object describes the position on faces where a mask should be placed by default.
/// Reference: https://core.telegram.org/bots/api#maskposition
pub const MaskPosition = struct {
    /// The part of the face relative to which the mask should be placed. One of "forehead", "eyes", "mouth", or "chin".
    point: []const u8,
    /// Shift by X-axis measured in widths of the mask scaled to the face size, from left to right. For example, choosing -1.0 will place mask just to the left of the default mask position.
    x_shift: f64,
    /// Shift by Y-axis measured in heights of the mask scaled to the face size, from top to bottom. For example, 1.0 will place the mask just below the default mask position.
    y_shift: f64,
    /// Mask scaling coefficient. For example, 2.0 means double size.
    scale: f64,
};

/// This object describes a message that can be inaccessible to the bot. It can be one of
/// - Message
/// - InaccessibleMessage
/// Reference: https://core.telegram.org/bots/api#maybeinaccessiblemessage
pub const MaybeInaccessibleMessage = union(enum) {
    message: Message,
    inaccessible_message: InaccessibleMessage,

    pub fn jsonStringify(self: MaybeInaccessibleMessage, jw: anytype) !void {
        switch (self) {
            inline else => |payload| try jw.write(payload),
        }
    }

    pub fn jsonParse(
        allocator: Allocator,
        source: anytype,
        options: std.json.ParseOptions,
    ) std.json.ParseError(@TypeOf(source.*))!MaybeInaccessibleMessage {
        return json_mod.parseMaybeInaccessibleMessage(MaybeInaccessibleMessage, allocator, source, options);
    }
};

/// This object describes the bot's menu button in a private chat. It should be one of
/// - MenuButtonCommands
/// - MenuButtonWebApp
/// - MenuButtonDefault
/// If a menu button other than MenuButtonDefault is set for a private chat, then it is applied in the chat. Otherwise the default menu button is applied. By default, the menu button opens the list of bot commands.
/// Reference: https://core.telegram.org/bots/api#menubutton
pub const MenuButton = union(enum) {
    commands: MenuButtonCommands,
    web_app: MenuButtonWebApp,
    default: MenuButtonDefault,

    pub fn jsonStringify(self: MenuButton, jw: anytype) !void {
        switch (self) {
            inline else => |payload| try jw.write(payload),
        }
    }

    pub fn writeMultipartJson(
        self: MenuButton,
        arena: Allocator,
        jw: *std.json.Stringify,
        pending_parts: *std.ArrayList(multipart_mod.PendingPart),
        comptime writeFn: anytype,
    ) !void {
        switch (self) {
            inline else => |payload| try writeFn(arena, jw, payload, pending_parts),
        }
    }

    pub fn jsonParse(
        allocator: Allocator,
        source: anytype,
        options: std.json.ParseOptions,
    ) std.json.ParseError(@TypeOf(source.*))!MenuButton {
        return json_mod.parseDiscriminatedUnion(
            MenuButton,
            "type",
            .{
                .{ "commands", "commands" },
                .{ "web_app", "web_app" },
                .{ "default", "default" },
            },
            allocator,
            source,
            options,
        );
    }
};

/// Represents a menu button, which opens the bot's list of commands.
/// Reference: https://core.telegram.org/bots/api#menubuttoncommands
pub const MenuButtonCommands = struct {
    /// Type of the button, must be commands
    type: []const u8 = "commands",
};

/// Describes that no specific value for the menu button was set.
/// Reference: https://core.telegram.org/bots/api#menubuttondefault
pub const MenuButtonDefault = struct {
    /// Type of the button, must be default
    type: []const u8 = "default",
};

/// Represents a menu button, which launches a Web App.
/// Reference: https://core.telegram.org/bots/api#menubuttonwebapp
pub const MenuButtonWebApp = struct {
    /// Type of the button, must be web_app
    type: []const u8 = "web_app",
    /// Text on the button
    text: []const u8,
    /// Description of the Web App that will be launched when the user presses the button. The Web App will be able to send an arbitrary message on behalf of the user using the method answerWebAppQuery. Alternatively, a t.me link to a Web App of the bot can be specified in the object instead of the Web App's URL, in which case the Web App will be opened as if the user pressed the link.
    web_app: WebAppInfo,
};

/// This object represents a message.
/// Reference: https://core.telegram.org/bots/api#message
pub const Message = struct {
    /// Unique message identifier inside this chat; 0 for ephemeral messages. In specific instances (e.g., a message containing a video sent to a big chat), the server might automatically schedule a message instead of sending it immediately. In such cases, this field will be 0 and the relevant message will be unusable until it is actually sent.
    message_id: i64,
    /// Date the message was sent in Unix time. It is always a positive number, representing a valid date.
    date: i64,
    /// Chat the message belongs to
    chat: *const Chat,
    /// Optional. Unique identifier of a message thread or forum topic to which the message belongs; for supergroups and private chats only
    message_thread_id: ?i64 = null,
    /// Optional. Information about the direct messages chat topic that contains the message
    direct_messages_topic: ?DirectMessagesTopic = null,
    /// Optional. Sender of the message; may be empty for messages sent to channels. For backward compatibility, if the message was sent on behalf of a chat, the field contains a fake sender user in non-channel chats.
    from: ?User = null,
    /// Optional. Sender of the message when sent on behalf of a chat. For example, the supergroup itself for messages sent by its anonymous administrators or a linked channel for messages automatically forwarded to the channel's discussion group. For backward compatibility, if the message was sent on behalf of a chat, the field from contains a fake sender user in non-channel chats.
    sender_chat: ?*const Chat = null,
    /// Optional. If the sender of the message boosted the chat, the number of boosts added by the user
    sender_boost_count: ?i64 = null,
    /// Optional. The bot that actually sent the message on behalf of the business account. Available only for outgoing messages sent on behalf of the connected business account.
    sender_business_bot: ?User = null,
    /// Optional. Tag or custom title of the sender of the message; for supergroups only
    sender_tag: ?[]const u8 = null,
    /// Optional. For ephemeral messages, the user who received the message
    receiver_user: ?User = null,
    /// Optional. For ephemeral messages, identifier of the ephemeral message inside this chat. The identifier may be reused for another ephemeral message after the message is deleted or expires.
    ephemeral_message_id: ?i64 = null,
    /// Optional. The unique identifier for the guest query. Use this identifier with the method answerGuestQuery to send a response message. If non-empty, the message belongs to the chat where the guest bot was summoned, which may not coincide with other existing bot chats sharing the same identifier.
    guest_query_id: ?[]const u8 = null,
    /// Optional. Unique identifier of the business connection from which the message was received. If non-empty, the message belongs to a chat of the corresponding business account that is independent from any potential bot chat which might share the same identifier.
    business_connection_id: ?[]const u8 = null,
    /// Optional. Information about the original message for forwarded messages
    forward_origin: ?MessageOrigin = null,
    /// Optional. True, if the message is sent to a topic in a forum supergroup or a private chat with the bot
    is_topic_message: ?bool = null,
    /// Optional. True, if the message is a channel post that was automatically forwarded to the connected discussion group
    is_automatic_forward: ?bool = null,
    /// Optional. For replies in the same chat and message thread, the original message. Note that the Message object in this field will not contain further reply_to_message fields even if it itself is a reply. If the message is a reply to an ephemeral message, then this field may be omitted.
    reply_to_message: ?*const Message = null,
    /// Optional. Information about the message that is being replied to, which may come from another chat or forum topic
    external_reply: ?*const ExternalReplyInfo = null,
    /// Optional. For replies that quote part of the original message, the quoted part of the message
    quote: ?TextQuote = null,
    /// Optional. For replies to a story, the original story
    reply_to_story: ?Story = null,
    /// Optional. Identifier of the specific checklist task that is being replied to
    reply_to_checklist_task_id: ?i64 = null,
    /// Optional. Persistent identifier of the specific poll option that is being replied to
    reply_to_poll_option_id: ?[]const u8 = null,
    /// Optional. Bot through which the message was sent
    via_bot: ?User = null,
    /// Optional. For a message sent by a guest bot, this is the user whose original message triggered the bot's response
    guest_bot_caller_user: ?User = null,
    /// Optional. For a message sent by a guest bot, this is the chat whose original message triggered the bot's response
    guest_bot_caller_chat: ?*const Chat = null,
    /// Optional. Date the message was last edited in Unix time
    edit_date: ?i64 = null,
    /// Optional. True, if the message can't be forwarded
    has_protected_content: ?bool = null,
    /// Optional. True, if the message was sent by an implicit action, for example, as an away or a greeting business message, or as a scheduled message
    is_from_offline: ?bool = null,
    /// Optional. True, if the message is a paid post. Note that such posts must not be deleted for 24 hours to receive the payment and can't be edited.
    is_paid_post: ?bool = null,
    /// Optional. The unique identifier inside this chat of a media message group this message belongs to
    media_group_id: ?[]const u8 = null,
    /// Optional. Signature of the post author for messages in channels, or the custom title of an anonymous group administrator
    author_signature: ?[]const u8 = null,
    /// Optional. The number of Telegram Stars that were paid by the sender of the message to send it
    paid_star_count: ?i64 = null,
    /// Optional. For text messages, the actual UTF-8 text of the message
    text: ?[]const u8 = null,
    /// Optional. For text messages, special entities like usernames, URLs, bot commands, etc. that appear in the text
    entities: ?[]const MessageEntity = null,
    /// Optional. Options used for link preview generation for the message, if it is a text message and link preview options were changed
    link_preview_options: ?LinkPreviewOptions = null,
    /// Optional. Information about suggested post parameters if the message is a suggested post in a channel direct messages chat. If the message is an approved or declined suggested post, then it can't be edited.
    suggested_post_info: ?SuggestedPostInfo = null,
    /// Optional. Unique identifier of the message effect added to the message
    effect_id: ?[]const u8 = null,
    /// Optional. Message is a rich formatted message
    rich_message: ?RichMessage = null,
    /// Optional. Message is an animation, information about the animation. For backward compatibility, when this field is set, the document field will also be set.
    animation: ?Animation = null,
    /// Optional. Message is an audio file, information about the file
    audio: ?Audio = null,
    /// Optional. Message is a general file, information about the file
    document: ?Document = null,
    /// Optional. Message is a live photo, information about the live photo. For backward compatibility, when this field is set, the photo field will also be set.
    live_photo: ?LivePhoto = null,
    /// Optional. Message contains paid media; information about the paid media
    paid_media: ?PaidMediaInfo = null,
    /// Optional. Message is a photo, available sizes of the photo
    photo: ?[]const PhotoSize = null,
    /// Optional. Message is a sticker, information about the sticker
    sticker: ?Sticker = null,
    /// Optional. Message is a forwarded story
    story: ?Story = null,
    /// Optional. Message is a video, information about the video
    video: ?Video = null,
    /// Optional. Message is a video note, information about the video message
    video_note: ?VideoNote = null,
    /// Optional. Message is a voice message, information about the file
    voice: ?Voice = null,
    /// Optional. Caption for the animation, audio, document, paid media, photo, video or voice
    caption: ?[]const u8 = null,
    /// Optional. For messages with a caption, special entities like usernames, URLs, bot commands, etc. that appear in the caption
    caption_entities: ?[]const MessageEntity = null,
    /// Optional. True, if the caption must be shown above the message media
    show_caption_above_media: ?bool = null,
    /// Optional. True, if the message media is covered by a spoiler animation
    has_media_spoiler: ?bool = null,
    /// Optional. Message is a checklist
    checklist: ?Checklist = null,
    /// Optional. Message is a shared contact, information about the contact
    contact: ?Contact = null,
    /// Optional. Message is a dice with random value
    dice: ?Dice = null,
    /// Optional. Message is a game, information about the game. More about games: https://core.telegram.org/bots/api#games
    game: ?Game = null,
    /// Optional. Message is a native poll, information about the poll
    poll: ?Poll = null,
    /// Optional. Message is a venue, information about the venue. For backward compatibility, when this field is set, the location field will also be set.
    venue: ?Venue = null,
    /// Optional. Message is a shared location, information about the location
    location: ?Location = null,
    /// Optional. New members that were added to the group or supergroup and information about them (the bot itself may be one of these members)
    new_chat_members: ?[]const User = null,
    /// Optional. A member was removed from the group, information about them (this member may be the bot itself)
    left_chat_member: ?User = null,
    /// Optional. Service message: chat owner has left
    chat_owner_left: ?ChatOwnerLeft = null,
    /// Optional. Service message: chat owner has changed
    chat_owner_changed: ?ChatOwnerChanged = null,
    /// Optional. A chat title was changed to this value
    new_chat_title: ?[]const u8 = null,
    /// Optional. A chat photo was change to this value
    new_chat_photo: ?[]const PhotoSize = null,
    /// Optional. Service message: the chat photo was deleted
    delete_chat_photo: ?bool = null,
    /// Optional. Service message: the group has been created
    group_chat_created: ?bool = null,
    /// Optional. Service message: the supergroup has been created. This field can't be received in a message coming through updates, because bot can't be a member of a supergroup when it is created. It can only be found in reply_to_message if someone replies to a very first message in a directly created supergroup.
    supergroup_chat_created: ?bool = null,
    /// Optional. Service message: the channel has been created. This field can't be received in a message coming through updates, because bot can't be a member of a channel when it is created. It can only be found in reply_to_message if someone replies to a very first message in a channel.
    channel_chat_created: ?bool = null,
    /// Optional. Service message: auto-delete timer settings changed in the chat
    message_auto_delete_timer_changed: ?MessageAutoDeleteTimerChanged = null,
    /// Optional. The group has been migrated to a supergroup with the specified identifier. This number may have more than 32 significant bits and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a signed 64-bit integer or double-precision float type are safe for storing this identifier.
    migrate_to_chat_id: ?i64 = null,
    /// Optional. The supergroup has been migrated from a group with the specified identifier. This number may have more than 32 significant bits and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a signed 64-bit integer or double-precision float type are safe for storing this identifier.
    migrate_from_chat_id: ?i64 = null,
    /// Optional. Specified message was pinned. Note that the Message object in this field will not contain further reply_to_message fields even if it itself is a reply.
    pinned_message: ?*const MaybeInaccessibleMessage = null,
    /// Optional. Message is an invoice for a payment, information about the invoice. More about payments: https://core.telegram.org/bots/api#payments
    invoice: ?Invoice = null,
    /// Optional. Message is a service message about a successful payment, information about the payment. More about payments: https://core.telegram.org/bots/api#payments
    successful_payment: ?SuccessfulPayment = null,
    /// Optional. Message is a service message about a refunded payment, information about the payment. More about payments: https://core.telegram.org/bots/api#payments
    refunded_payment: ?RefundedPayment = null,
    /// Optional. Service message: users were shared with the bot
    users_shared: ?UsersShared = null,
    /// Optional. Service message: a chat was shared with the bot
    chat_shared: ?ChatShared = null,
    /// Optional. Service message: a regular gift was sent or received
    gift: ?GiftInfo = null,
    /// Optional. Service message: a unique gift was sent or received
    unique_gift: ?UniqueGiftInfo = null,
    /// Optional. Service message: upgrade of a gift was purchased after the gift was sent
    gift_upgrade_sent: ?GiftInfo = null,
    /// Optional. The domain name of the website on which the user has logged in. More about Telegram Login: https://core.telegram.org/widgets/login
    connected_website: ?[]const u8 = null,
    /// Optional. Service message: the user allowed the bot to write messages after adding it to the attachment or side menu, launching a Web App from a link, or accepting an explicit request from a Web App sent by the method requestWriteAccess
    write_access_allowed: ?WriteAccessAllowed = null,
    /// Optional. Telegram Passport data
    passport_data: ?PassportData = null,
    /// Optional. Service message: a user in the chat triggered another user's proximity alert while sharing Live Location
    proximity_alert_triggered: ?ProximityAlertTriggered = null,
    /// Optional. Service message: user boosted the chat
    boost_added: ?ChatBoostAdded = null,
    /// Optional. Service message: chat background set
    chat_background_set: ?ChatBackground = null,
    /// Optional. Service message: some tasks in a checklist were marked as done or not done
    checklist_tasks_done: ?*const ChecklistTasksDone = null,
    /// Optional. Service message: tasks were added to a checklist
    checklist_tasks_added: ?*const ChecklistTasksAdded = null,
    /// Optional. Service message: chat or bot added to a Community
    community_chat_added: ?CommunityChatAdded = null,
    /// Optional. Service message: chat was joined by a user from a Community
    community_chat_joined: ?CommunityChatJoined = null,
    /// Optional. Service message: chat or bot removed from a Community
    community_chat_removed: ?CommunityChatRemoved = null,
    /// Optional. Service message: the price for paid messages in the corresponding direct messages chat of a channel has changed
    direct_message_price_changed: ?DirectMessagePriceChanged = null,
    /// Optional. Service message: forum topic created
    forum_topic_created: ?ForumTopicCreated = null,
    /// Optional. Service message: forum topic edited
    forum_topic_edited: ?ForumTopicEdited = null,
    /// Optional. Service message: forum topic closed
    forum_topic_closed: ?ForumTopicClosed = null,
    /// Optional. Service message: forum topic reopened
    forum_topic_reopened: ?ForumTopicReopened = null,
    /// Optional. Service message: the 'General' forum topic hidden
    general_forum_topic_hidden: ?GeneralForumTopicHidden = null,
    /// Optional. Service message: the 'General' forum topic unhidden
    general_forum_topic_unhidden: ?GeneralForumTopicUnhidden = null,
    /// Optional. Service message: a scheduled giveaway was created
    giveaway_created: ?GiveawayCreated = null,
    /// Optional. The message is a scheduled giveaway message
    giveaway: ?Giveaway = null,
    /// Optional. A giveaway with public winners was completed
    giveaway_winners: ?GiveawayWinners = null,
    /// Optional. Service message: a giveaway without public winners was completed
    giveaway_completed: ?*const GiveawayCompleted = null,
    /// Optional. Service message: user created a bot that will be managed by the current bot
    managed_bot_created: ?ManagedBotCreated = null,
    /// Optional. Service message: the price for paid messages has changed in the chat
    paid_message_price_changed: ?PaidMessagePriceChanged = null,
    /// Optional. Service message: answer option was added to a poll
    poll_option_added: ?*const PollOptionAdded = null,
    /// Optional. Service message: answer option was deleted from a poll
    poll_option_deleted: ?*const PollOptionDeleted = null,
    /// Optional. Service message: a suggested post was approved
    suggested_post_approved: ?*const SuggestedPostApproved = null,
    /// Optional. Service message: approval of a suggested post has failed
    suggested_post_approval_failed: ?*const SuggestedPostApprovalFailed = null,
    /// Optional. Service message: a suggested post was declined
    suggested_post_declined: ?*const SuggestedPostDeclined = null,
    /// Optional. Service message: payment for a suggested post was received
    suggested_post_paid: ?*const SuggestedPostPaid = null,
    /// Optional. Service message: payment for a suggested post was refunded
    suggested_post_refunded: ?*const SuggestedPostRefunded = null,
    /// Optional. Service message: video chat scheduled
    video_chat_scheduled: ?VideoChatScheduled = null,
    /// Optional. Service message: video chat started
    video_chat_started: ?VideoChatStarted = null,
    /// Optional. Service message: video chat ended
    video_chat_ended: ?VideoChatEnded = null,
    /// Optional. Service message: new participants invited to a video chat
    video_chat_participants_invited: ?VideoChatParticipantsInvited = null,
    /// Optional. Service message: data sent by a Web App
    web_app_data: ?WebAppData = null,
    /// Optional. Inline keyboard attached to the message. login_url buttons are represented as ordinary url buttons.
    reply_markup: ?InlineKeyboardMarkup = null,
};

/// This object represents a service message about a change in auto-delete timer settings.
/// Reference: https://core.telegram.org/bots/api#messageautodeletetimerchanged
pub const MessageAutoDeleteTimerChanged = struct {
    /// New auto-delete time for messages in the chat; in seconds
    message_auto_delete_time: i64,
};

/// This object represents one special entity in a text message. For example, hashtags, usernames, URLs, etc.
/// Reference: https://core.telegram.org/bots/api#messageentity
pub const MessageEntity = struct {
    /// Type of the entity. Currently, can be "mention" (@username), "hashtag" (#hashtag or #hashtag@chatusername), "cashtag" ($USD or $USD@chatusername), "bot_command" (/start@jobs_bot), "url" (https://telegram.org), "email" (do-not-reply@telegram.org), "phone_number" (+1-212-555-0123), "bold" (bold text), "italic" (italic text), "underline" (underlined text), "strikethrough" (strikethrough text), "spoiler" (spoiler message), "blockquote" (block quotation), "expandable_blockquote" (collapsed-by-default block quotation), "code" (monowidth string), "pre" (monowidth block), "text_link" (for clickable text URLs), "text_mention" (for users without usernames), "custom_emoji" (for inline custom emoji stickers), or "date_time" (for formatted date and time).
    type: []const u8,
    /// Offset in UTF-16 code units to the start of the entity
    offset: i64,
    /// Length of the entity in UTF-16 code units
    length: i64,
    /// Optional. For "text_link" only, URL that will be opened after user taps on the text
    url: ?[]const u8 = null,
    /// Optional. For "text_mention" only, the mentioned user
    user: ?User = null,
    /// Optional. For "pre" only, the programming language of the entity text
    language: ?[]const u8 = null,
    /// Optional. For "custom_emoji" only, unique identifier of the custom emoji. Use getCustomEmojiStickers to get full information about the sticker.
    custom_emoji_id: ?[]const u8 = null,
    /// Optional. For "date_time" only, the Unix time associated with the entity
    unix_time: ?i64 = null,
    /// Optional. For "date_time" only, the string that defines the formatting of the date and time. See date-time entity formatting for more details.
    date_time_format: ?[]const u8 = null,
};

/// This object describes an update about a user stopping message generation.
/// Reference: https://core.telegram.org/bots/api#messagegenerationstopped
pub const MessageGenerationStopped = struct {
    /// Chat in which the message is generated
    chat: *const Chat,
    /// Unique identifier of the message draft which was stopped
    draft_id: i64,
    /// Optional. Unique identifier of the message thread in which the message is generated
    message_thread_id: ?i64 = null,
};

/// This object represents a unique message identifier.
/// Reference: https://core.telegram.org/bots/api#messageid
pub const MessageId = struct {
    /// Unique message identifier. In specific instances (e.g., message containing a video sent to a big chat), the server might automatically schedule a message instead of sending it immediately. In such cases, this field will be 0 and the relevant message will be unusable until it is actually sent.
    message_id: i64,
};

/// This object describes the origin of a message. It can be one of
/// - MessageOriginUser
/// - MessageOriginHiddenUser
/// - MessageOriginChat
/// - MessageOriginChannel
/// Reference: https://core.telegram.org/bots/api#messageorigin
pub const MessageOrigin = union(enum) {
    user: MessageOriginUser,
    hidden_user: MessageOriginHiddenUser,
    chat: MessageOriginChat,
    channel: MessageOriginChannel,

    pub fn jsonStringify(self: MessageOrigin, jw: anytype) !void {
        switch (self) {
            inline else => |payload| try jw.write(payload),
        }
    }

    pub fn writeMultipartJson(
        self: MessageOrigin,
        arena: Allocator,
        jw: *std.json.Stringify,
        pending_parts: *std.ArrayList(multipart_mod.PendingPart),
        comptime writeFn: anytype,
    ) !void {
        switch (self) {
            inline else => |payload| try writeFn(arena, jw, payload, pending_parts),
        }
    }

    pub fn jsonParse(
        allocator: Allocator,
        source: anytype,
        options: std.json.ParseOptions,
    ) std.json.ParseError(@TypeOf(source.*))!MessageOrigin {
        return json_mod.parseDiscriminatedUnion(
            MessageOrigin,
            "type",
            .{
                .{ "user", "user" },
                .{ "hidden_user", "hidden_user" },
                .{ "chat", "chat" },
                .{ "channel", "channel" },
            },
            allocator,
            source,
            options,
        );
    }
};

/// The message was originally sent to a channel chat.
/// Reference: https://core.telegram.org/bots/api#messageoriginchannel
pub const MessageOriginChannel = struct {
    /// Type of the message origin, always "channel"
    type: []const u8 = "channel",
    /// Date the message was sent originally in Unix time
    date: i64,
    /// Channel chat to which the message was originally sent
    chat: *const Chat,
    /// Unique message identifier inside the chat
    message_id: i64,
    /// Optional. Signature of the original post author
    author_signature: ?[]const u8 = null,
};

/// The message was originally sent on behalf of a chat to a group chat.
/// Reference: https://core.telegram.org/bots/api#messageoriginchat
pub const MessageOriginChat = struct {
    /// Type of the message origin, always "chat"
    type: []const u8 = "chat",
    /// Date the message was sent originally in Unix time
    date: i64,
    /// Chat that sent the message originally
    sender_chat: *const Chat,
    /// Optional. For messages originally sent by an anonymous chat administrator, original message author signature
    author_signature: ?[]const u8 = null,
};

/// The message was originally sent by an unknown user.
/// Reference: https://core.telegram.org/bots/api#messageoriginhiddenuser
pub const MessageOriginHiddenUser = struct {
    /// Type of the message origin, always "hidden_user"
    type: []const u8 = "hidden_user",
    /// Date the message was sent originally in Unix time
    date: i64,
    /// Name of the user that sent the message originally
    sender_user_name: []const u8,
};

/// The message was originally sent by a known user.
/// Reference: https://core.telegram.org/bots/api#messageoriginuser
pub const MessageOriginUser = struct {
    /// Type of the message origin, always "user"
    type: []const u8 = "user",
    /// Date the message was sent originally in Unix time
    date: i64,
    /// User that sent the message originally
    sender_user: User,
};

/// This object represents reaction changes on a message with anonymous reactions.
/// Reference: https://core.telegram.org/bots/api#messagereactioncountupdated
pub const MessageReactionCountUpdated = struct {
    /// The chat containing the message
    chat: *const Chat,
    /// Unique message identifier inside the chat
    message_id: i64,
    /// Date of the change in Unix time
    date: i64,
    /// List of reactions that are present on the message
    reactions: []const ReactionCount,
};

/// This object represents a change of a reaction on a message performed by a user.
/// Reference: https://core.telegram.org/bots/api#messagereactionupdated
pub const MessageReactionUpdated = struct {
    /// The chat containing the message the user reacted to
    chat: *const Chat,
    /// Unique identifier of the message inside the chat
    message_id: i64,
    /// Date of the change in Unix time
    date: i64,
    /// Previous list of reaction types that were set by the user
    old_reaction: []const ReactionType,
    /// New list of reaction types that have been set by the user
    new_reaction: []const ReactionType,
    /// Optional. The user that changed the reaction, if the user isn't anonymous
    user: ?User = null,
    /// Optional. The chat on behalf of which the reaction was changed, if the user is anonymous
    actor_chat: ?*const Chat = null,
};

/// This object represents information about an order.
/// Reference: https://core.telegram.org/bots/api#orderinfo
pub const OrderInfo = struct {
    /// Optional. User name
    name: ?[]const u8 = null,
    /// Optional. User's phone number
    phone_number: ?[]const u8 = null,
    /// Optional. User email
    email: ?[]const u8 = null,
    /// Optional. User shipping address
    shipping_address: ?ShippingAddress = null,
};

/// This object describes a gift received and owned by a user or a chat. Currently, it can be one of
/// - OwnedGiftRegular
/// - OwnedGiftUnique
/// Reference: https://core.telegram.org/bots/api#ownedgift
pub const OwnedGift = union(enum) {
    regular: OwnedGiftRegular,
    unique: OwnedGiftUnique,

    pub fn jsonStringify(self: OwnedGift, jw: anytype) !void {
        switch (self) {
            inline else => |payload| try jw.write(payload),
        }
    }

    pub fn writeMultipartJson(
        self: OwnedGift,
        arena: Allocator,
        jw: *std.json.Stringify,
        pending_parts: *std.ArrayList(multipart_mod.PendingPart),
        comptime writeFn: anytype,
    ) !void {
        switch (self) {
            inline else => |payload| try writeFn(arena, jw, payload, pending_parts),
        }
    }

    pub fn jsonParse(
        allocator: Allocator,
        source: anytype,
        options: std.json.ParseOptions,
    ) std.json.ParseError(@TypeOf(source.*))!OwnedGift {
        return json_mod.parseDiscriminatedUnion(
            OwnedGift,
            "type",
            .{
                .{ "regular", "regular" },
                .{ "unique", "unique" },
            },
            allocator,
            source,
            options,
        );
    }
};

/// Describes a regular gift owned by a user or a chat.
/// Reference: https://core.telegram.org/bots/api#ownedgiftregular
pub const OwnedGiftRegular = struct {
    /// Type of the gift, always "regular"
    type: []const u8 = "regular",
    /// Information about the regular gift
    gift: Gift,
    /// Date the gift was sent in Unix time
    send_date: i64,
    /// Optional. Unique identifier of the gift for the bot; for gifts received on behalf of business accounts only
    owned_gift_id: ?[]const u8 = null,
    /// Optional. Sender of the gift if it is a known user
    sender_user: ?User = null,
    /// Optional. Text of the message that was added to the gift
    text: ?[]const u8 = null,
    /// Optional. Special entities that appear in the text
    entities: ?[]const MessageEntity = null,
    /// Optional. True, if the sender and gift text are shown only to the gift receiver; otherwise, everyone will be able to see them
    is_private: ?bool = null,
    /// Optional. True, if the gift is displayed on the account's profile page; for gifts received on behalf of business accounts only
    is_saved: ?bool = null,
    /// Optional. True, if the gift can be upgraded to a unique gift; for gifts received on behalf of business accounts only
    can_be_upgraded: ?bool = null,
    /// Optional. True, if the gift was refunded and isn't available anymore
    was_refunded: ?bool = null,
    /// Optional. Number of Telegram Stars that can be claimed by the receiver instead of the gift; omitted if the gift cannot be converted to Telegram Stars; for gifts received on behalf of business accounts only
    convert_star_count: ?i64 = null,
    /// Optional. Number of Telegram Stars that were paid for the ability to upgrade the gift
    prepaid_upgrade_star_count: ?i64 = null,
    /// Optional. True, if the gift's upgrade was purchased after the gift was sent; for gifts received on behalf of business accounts only
    is_upgrade_separate: ?bool = null,
    /// Optional. Unique number reserved for this gift when upgraded. See the number field in UniqueGift.
    unique_gift_number: ?i64 = null,
};

/// Describes a unique gift received and owned by a user or a chat.
/// Reference: https://core.telegram.org/bots/api#ownedgiftunique
pub const OwnedGiftUnique = struct {
    /// Type of the gift, always "unique"
    type: []const u8 = "unique",
    /// Information about the unique gift
    gift: UniqueGift,
    /// Date the gift was sent in Unix time
    send_date: i64,
    /// Optional. Unique identifier of the received gift for the bot; for gifts received on behalf of business accounts only
    owned_gift_id: ?[]const u8 = null,
    /// Optional. Sender of the gift if it is a known user
    sender_user: ?User = null,
    /// Optional. True, if the gift is displayed on the account's profile page; for gifts received on behalf of business accounts only
    is_saved: ?bool = null,
    /// Optional. True, if the gift can be transferred to another owner; for gifts received on behalf of business accounts only
    can_be_transferred: ?bool = null,
    /// Optional. Number of Telegram Stars that must be paid to transfer the gift; omitted if the bot cannot transfer the gift
    transfer_star_count: ?i64 = null,
    /// Optional. Point in time (Unix timestamp) when the gift can be transferred. If it is in the past, then the gift can be transferred now.
    next_transfer_date: ?i64 = null,
};

/// Contains the list of gifts received and owned by a user or a chat.
/// Reference: https://core.telegram.org/bots/api#ownedgifts
pub const OwnedGifts = struct {
    /// The total number of gifts owned by the user or the chat
    total_count: i64,
    /// The list of gifts
    gifts: []const OwnedGift,
    /// Optional. Offset for the next request. If empty, then there are no more results.
    next_offset: ?[]const u8 = null,
};

/// This object describes paid media. Currently, it can be one of
/// - PaidMediaLivePhoto
/// - PaidMediaPhoto
/// - PaidMediaPreview
/// - PaidMediaVideo
/// Reference: https://core.telegram.org/bots/api#paidmedia
pub const PaidMedia = union(enum) {
    live_photo: PaidMediaLivePhoto,
    photo: PaidMediaPhoto,
    preview: PaidMediaPreview,
    video: PaidMediaVideo,

    pub fn jsonStringify(self: PaidMedia, jw: anytype) !void {
        switch (self) {
            inline else => |payload| try jw.write(payload),
        }
    }

    pub fn writeMultipartJson(
        self: PaidMedia,
        arena: Allocator,
        jw: *std.json.Stringify,
        pending_parts: *std.ArrayList(multipart_mod.PendingPart),
        comptime writeFn: anytype,
    ) !void {
        switch (self) {
            inline else => |payload| try writeFn(arena, jw, payload, pending_parts),
        }
    }

    pub fn jsonParse(
        allocator: Allocator,
        source: anytype,
        options: std.json.ParseOptions,
    ) std.json.ParseError(@TypeOf(source.*))!PaidMedia {
        return json_mod.parseDiscriminatedUnion(
            PaidMedia,
            "type",
            .{
                .{ "live_photo", "live_photo" },
                .{ "photo", "photo" },
                .{ "preview", "preview" },
                .{ "video", "video" },
            },
            allocator,
            source,
            options,
        );
    }
};

/// Describes the paid media added to a message.
/// Reference: https://core.telegram.org/bots/api#paidmediainfo
pub const PaidMediaInfo = struct {
    /// The number of Telegram Stars that must be paid to buy access to the media
    star_count: i64,
    /// Information about the paid media
    paid_media: []const PaidMedia,
};

/// The paid media is a live photo.
/// Reference: https://core.telegram.org/bots/api#paidmedialivephoto
pub const PaidMediaLivePhoto = struct {
    /// Type of the paid media, always "live_photo"
    type: []const u8 = "live_photo",
    /// The photo
    live_photo: LivePhoto,
};

/// The paid media is a photo.
/// Reference: https://core.telegram.org/bots/api#paidmediaphoto
pub const PaidMediaPhoto = struct {
    /// Type of the paid media, always "photo"
    type: []const u8 = "photo",
    /// The photo
    photo: []const PhotoSize,
};

/// The paid media isn't available before the payment.
/// Reference: https://core.telegram.org/bots/api#paidmediapreview
pub const PaidMediaPreview = struct {
    /// Type of the paid media, always "preview"
    type: []const u8 = "preview",
    /// Optional. Media width as defined by the sender
    width: ?i64 = null,
    /// Optional. Media height as defined by the sender
    height: ?i64 = null,
    /// Optional. Duration of the media in seconds as defined by the sender
    duration: ?i64 = null,
};

/// This object contains information about a paid media purchase.
/// Reference: https://core.telegram.org/bots/api#paidmediapurchased
pub const PaidMediaPurchased = struct {
    /// User who purchased the media
    from: User,
    /// Bot-specified paid media payload
    paid_media_payload: []const u8,
};

/// The paid media is a video.
/// Reference: https://core.telegram.org/bots/api#paidmediavideo
pub const PaidMediaVideo = struct {
    /// Type of the paid media, always "video"
    type: []const u8 = "video",
    /// The video
    video: Video,
};

/// Describes a service message about a change in the price of paid messages within a chat.
/// Reference: https://core.telegram.org/bots/api#paidmessagepricechanged
pub const PaidMessagePriceChanged = struct {
    /// The new number of Telegram Stars that must be paid by non-administrator users of the supergroup chat for each sent message
    paid_message_star_count: i64,
};

/// Describes Telegram Passport data shared with the bot by the user.
/// Reference: https://core.telegram.org/bots/api#passportdata
pub const PassportData = struct {
    /// Array with information about documents and other Telegram Passport elements that was shared with the bot
    data: []const EncryptedPassportElement,
    /// Encrypted credentials required to decrypt the data
    credentials: EncryptedCredentials,
};

/// This object represents an error in the Telegram Passport element which was submitted that should be resolved by the user. It should be one of:
/// - PassportElementErrorDataField
/// - PassportElementErrorFrontSide
/// - PassportElementErrorReverseSide
/// - PassportElementErrorSelfie
/// - PassportElementErrorFile
/// - PassportElementErrorFiles
/// - PassportElementErrorTranslationFile
/// - PassportElementErrorTranslationFiles
/// - PassportElementErrorUnspecified
/// Reference: https://core.telegram.org/bots/api#passportelementerror
pub const PassportElementError = union(enum) {
    data_field: PassportElementErrorDataField,
    front_side: PassportElementErrorFrontSide,
    reverse_side: PassportElementErrorReverseSide,
    selfie: PassportElementErrorSelfie,
    file: PassportElementErrorFile,
    files: PassportElementErrorFiles,
    translation_file: PassportElementErrorTranslationFile,
    translation_files: PassportElementErrorTranslationFiles,
    unspecified: PassportElementErrorUnspecified,

    pub fn jsonStringify(self: PassportElementError, jw: anytype) !void {
        switch (self) {
            inline else => |payload| try jw.write(payload),
        }
    }

    pub fn writeMultipartJson(
        self: PassportElementError,
        arena: Allocator,
        jw: *std.json.Stringify,
        pending_parts: *std.ArrayList(multipart_mod.PendingPart),
        comptime writeFn: anytype,
    ) !void {
        switch (self) {
            inline else => |payload| try writeFn(arena, jw, payload, pending_parts),
        }
    }

    pub fn jsonParse(
        allocator: Allocator,
        source: anytype,
        options: std.json.ParseOptions,
    ) std.json.ParseError(@TypeOf(source.*))!PassportElementError {
        return json_mod.parseDiscriminatedUnion(
            PassportElementError,
            "source",
            .{
                .{ "data", "data_field" },
                .{ "front_side", "front_side" },
                .{ "reverse_side", "reverse_side" },
                .{ "selfie", "selfie" },
                .{ "file", "file" },
                .{ "files", "files" },
                .{ "translation_file", "translation_file" },
                .{ "translation_files", "translation_files" },
                .{ "unspecified", "unspecified" },
            },
            allocator,
            source,
            options,
        );
    }
};

/// Represents an issue in one of the data fields that was provided by the user. The error is considered resolved when the field's value changes.
/// Reference: https://core.telegram.org/bots/api#passportelementerrordatafield
pub const PassportElementErrorDataField = struct {
    /// Error source, must be data
    source: []const u8 = "data",
    /// The section of the user's Telegram Passport which has the error, one of "personal_details", "passport", "driver_license", "identity_card", "internal_passport", "address"
    type: []const u8,
    /// Name of the data field which has the error
    field_name: []const u8,
    /// Base64-encoded data hash
    data_hash: []const u8,
    /// Error message
    message: []const u8,
};

/// Represents an issue with a document scan. The error is considered resolved when the file with the document scan changes.
/// Reference: https://core.telegram.org/bots/api#passportelementerrorfile
pub const PassportElementErrorFile = struct {
    /// Error source, must be file
    source: []const u8 = "file",
    /// The section of the user's Telegram Passport which has the issue, one of "utility_bill", "bank_statement", "rental_agreement", "passport_registration", "temporary_registration"
    type: []const u8,
    /// Base64-encoded file hash
    file_hash: []const u8,
    /// Error message
    message: []const u8,
};

/// Represents an issue with a list of scans. The error is considered resolved when the list of files containing the scans changes.
/// Reference: https://core.telegram.org/bots/api#passportelementerrorfiles
pub const PassportElementErrorFiles = struct {
    /// Error source, must be files
    source: []const u8 = "files",
    /// The section of the user's Telegram Passport which has the issue, one of "utility_bill", "bank_statement", "rental_agreement", "passport_registration", "temporary_registration"
    type: []const u8,
    /// List of base64-encoded file hashes
    file_hashes: []const []const u8,
    /// Error message
    message: []const u8,
};

/// Represents an issue with the front side of a document. The error is considered resolved when the file with the front side of the document changes.
/// Reference: https://core.telegram.org/bots/api#passportelementerrorfrontside
pub const PassportElementErrorFrontSide = struct {
    /// Error source, must be front_side
    source: []const u8 = "front_side",
    /// The section of the user's Telegram Passport which has the issue, one of "passport", "driver_license", "identity_card", "internal_passport"
    type: []const u8,
    /// Base64-encoded hash of the file with the front side of the document
    file_hash: []const u8,
    /// Error message
    message: []const u8,
};

/// Represents an issue with the reverse side of a document. The error is considered resolved when the file with reverse side of the document changes.
/// Reference: https://core.telegram.org/bots/api#passportelementerrorreverseside
pub const PassportElementErrorReverseSide = struct {
    /// Error source, must be reverse_side
    source: []const u8 = "reverse_side",
    /// The section of the user's Telegram Passport which has the issue, one of "driver_license", "identity_card"
    type: []const u8,
    /// Base64-encoded hash of the file with the reverse side of the document
    file_hash: []const u8,
    /// Error message
    message: []const u8,
};

/// Represents an issue with the selfie with a document. The error is considered resolved when the file with the selfie changes.
/// Reference: https://core.telegram.org/bots/api#passportelementerrorselfie
pub const PassportElementErrorSelfie = struct {
    /// Error source, must be selfie
    source: []const u8 = "selfie",
    /// The section of the user's Telegram Passport which has the issue, one of "passport", "driver_license", "identity_card", "internal_passport"
    type: []const u8,
    /// Base64-encoded hash of the file with the selfie
    file_hash: []const u8,
    /// Error message
    message: []const u8,
};

/// Represents an issue with one of the files that constitute the translation of a document. The error is considered resolved when the file changes.
/// Reference: https://core.telegram.org/bots/api#passportelementerrortranslationfile
pub const PassportElementErrorTranslationFile = struct {
    /// Error source, must be translation_file
    source: []const u8 = "translation_file",
    /// Type of element of the user's Telegram Passport which has the issue, one of "passport", "driver_license", "identity_card", "internal_passport", "utility_bill", "bank_statement", "rental_agreement", "passport_registration", "temporary_registration"
    type: []const u8,
    /// Base64-encoded file hash
    file_hash: []const u8,
    /// Error message
    message: []const u8,
};

/// Represents an issue with the translated version of a document. The error is considered resolved when a file with the document translation change.
/// Reference: https://core.telegram.org/bots/api#passportelementerrortranslationfiles
pub const PassportElementErrorTranslationFiles = struct {
    /// Error source, must be translation_files
    source: []const u8 = "translation_files",
    /// Type of element of the user's Telegram Passport which has the issue, one of "passport", "driver_license", "identity_card", "internal_passport", "utility_bill", "bank_statement", "rental_agreement", "passport_registration", "temporary_registration"
    type: []const u8,
    /// List of base64-encoded file hashes
    file_hashes: []const []const u8,
    /// Error message
    message: []const u8,
};

/// Represents an issue in an unspecified place. The error is considered resolved when new data is added.
/// Reference: https://core.telegram.org/bots/api#passportelementerrorunspecified
pub const PassportElementErrorUnspecified = struct {
    /// Error source, must be unspecified
    source: []const u8 = "unspecified",
    /// Type of element of the user's Telegram Passport which has the issue
    type: []const u8,
    /// Base64-encoded element hash
    element_hash: []const u8,
    /// Error message
    message: []const u8,
};

/// This object represents a file uploaded to Telegram Passport. Currently all Telegram Passport files are in JPEG format when decrypted and don't exceed 10MB.
/// Reference: https://core.telegram.org/bots/api#passportfile
pub const PassportFile = struct {
    /// Identifier for this file, which can be used to download or reuse the file
    file_id: []const u8,
    /// Unique identifier for this file, which is supposed to be the same over time and for different bots. Can't be used to download or reuse the file.
    file_unique_id: []const u8,
    /// File size in bytes
    file_size: i64,
    /// Unix time when the file was uploaded
    file_date: i64,
};

/// This object represents one size of a photo or a file / sticker thumbnail.
/// Reference: https://core.telegram.org/bots/api#photosize
pub const PhotoSize = struct {
    /// Identifier for this file, which can be used to download or reuse the file
    file_id: []const u8,
    /// Unique identifier for this file, which is supposed to be the same over time and for different bots. Can't be used to download or reuse the file.
    file_unique_id: []const u8,
    /// Photo width
    width: i64,
    /// Photo height
    height: i64,
    /// Optional. File size in bytes
    file_size: ?i64 = null,
};

/// This object contains information about a poll.
/// Reference: https://core.telegram.org/bots/api#poll
pub const Poll = struct {
    /// Unique poll identifier
    id: []const u8,
    /// Poll question, 1-300 characters
    question: []const u8,
    /// List of poll options
    options: []const PollOption,
    /// Total number of users that voted in the poll
    total_voter_count: i64,
    /// True, if the poll is closed
    is_closed: bool,
    /// True, if the poll is anonymous
    is_anonymous: bool,
    /// Poll type, currently can be "regular" or "quiz"
    type: []const u8,
    /// True, if the poll allows multiple answers
    allows_multiple_answers: bool,
    /// True, if the poll allows to change the chosen answer options
    allows_revoting: bool,
    /// True if voting is limited to users who have been members of the chat where the poll was originally sent for more than 24 hours
    members_only: bool,
    /// Optional. Special entities that appear in the question. Currently, only custom emoji entities are allowed in poll questions
    question_entities: ?[]const MessageEntity = null,
    /// Optional. A list of two-letter ISO 3166-1 alpha-2 country codes indicating the countries from which users can vote in the poll. The country code "FT" is used for users with anonymous numbers. If omitted, then users from any country can participate in the poll.
    country_codes: ?[]const []const u8 = null,
    /// Optional. Array of 0-based identifiers of the correct answer options. Available only for polls in quiz mode which are closed or were sent (not forwarded) by the bot or to the private chat with the bot.
    correct_option_ids: ?[]const i64 = null,
    /// Optional. Text that is shown when a user chooses an incorrect answer or taps on the lamp icon in a quiz-style poll, 0-200 characters
    explanation: ?[]const u8 = null,
    /// Optional. Special entities like usernames, URLs, bot commands, etc. that appear in the explanation
    explanation_entities: ?[]const MessageEntity = null,
    /// Optional. Media added to the quiz explanation
    explanation_media: ?PollMedia = null,
    /// Optional. Amount of time in seconds the poll will be active after creation
    open_period: ?i64 = null,
    /// Optional. Point in time (Unix timestamp) when the poll will be automatically closed
    close_date: ?i64 = null,
    /// Optional. Description of the poll; for polls inside the Message object only
    description: ?[]const u8 = null,
    /// Optional. Special entities like usernames, URLs, bot commands, etc. that appear in the description
    description_entities: ?[]const MessageEntity = null,
    /// Optional. Media added to the poll description; for polls inside the Message object only
    media: ?PollMedia = null,
};

/// This object represents an answer of a user in a non-anonymous poll.
/// Reference: https://core.telegram.org/bots/api#pollanswer
pub const PollAnswer = struct {
    /// Unique poll identifier
    poll_id: []const u8,
    /// 0-based identifiers of chosen answer options. May be empty if the vote was retracted.
    option_ids: []const i64,
    /// Persistent identifiers of the chosen answer options. May be empty if the vote was retracted.
    option_persistent_ids: []const []const u8,
    /// Optional. The chat that changed the answer to the poll, if the voter is anonymous
    voter_chat: ?*const Chat = null,
    /// Optional. The user that changed the answer to the poll, if the voter isn't anonymous
    user: ?User = null,
};

/// At most one of the optional fields can be present in any given object.
/// Reference: https://core.telegram.org/bots/api#pollmedia
pub const PollMedia = struct {
    /// Optional. Media is an animation, information about the animation
    animation: ?Animation = null,
    /// Optional. Media is an audio file, information about the file; currently, can't be received in a poll option
    audio: ?Audio = null,
    /// Optional. Media is a general file, information about the file; currently, can't be received in a poll option
    document: ?Document = null,
    /// Optional. The HTTP link attached to the poll option
    link: ?Link = null,
    /// Optional. Media is a live photo, information about the live photo
    live_photo: ?LivePhoto = null,
    /// Optional. Media is a shared location, information about the location
    location: ?Location = null,
    /// Optional. Media is a photo, available sizes of the photo
    photo: ?[]const PhotoSize = null,
    /// Optional. Media is a sticker, information about the sticker; currently, for poll options only
    sticker: ?Sticker = null,
    /// Optional. Media is a venue, information about the venue
    venue: ?Venue = null,
    /// Optional. Media is a video, information about the video
    video: ?Video = null,
};

/// This object contains information about one answer option in a poll.
/// Reference: https://core.telegram.org/bots/api#polloption
pub const PollOption = struct {
    /// Unique identifier of the option, persistent on option addition and deletion
    persistent_id: []const u8,
    /// Option text, 1-100 characters
    text: []const u8,
    /// Number of users who voted for this option; may be 0 if unknown
    voter_count: i64,
    /// Optional. Special entities that appear in the option text. Currently, only custom emoji entities are allowed in poll option texts
    text_entities: ?[]const MessageEntity = null,
    /// Optional. Media added to the poll option
    media: ?PollMedia = null,
    /// Optional. User who added the option; omitted if the option wasn't added by a user after poll creation
    added_by_user: ?User = null,
    /// Optional. Chat that added the option; omitted if the option wasn't added by a chat after poll creation
    added_by_chat: ?*const Chat = null,
    /// Optional. Point in time (Unix timestamp) when the option was added; omitted if the option existed in the original poll
    addition_date: ?i64 = null,
};

/// Describes a service message about an option added to a poll.
/// Reference: https://core.telegram.org/bots/api#polloptionadded
pub const PollOptionAdded = struct {
    /// Unique identifier of the added option
    option_persistent_id: []const u8,
    /// Option text
    option_text: []const u8,
    /// Optional. Message containing the poll to which the option was added, if known. Note that the Message object in this field will not contain the reply_to_message field even if it itself is a reply.
    poll_message: ?*const MaybeInaccessibleMessage = null,
    /// Optional. Special entities that appear in the option_text
    option_text_entities: ?[]const MessageEntity = null,
};

/// Describes a service message about an option deleted from a poll.
/// Reference: https://core.telegram.org/bots/api#polloptiondeleted
pub const PollOptionDeleted = struct {
    /// Unique identifier of the deleted option
    option_persistent_id: []const u8,
    /// Option text
    option_text: []const u8,
    /// Optional. Message containing the poll from which the option was deleted, if known. Note that the Message object in this field will not contain the reply_to_message field even if it itself is a reply.
    poll_message: ?*const MaybeInaccessibleMessage = null,
    /// Optional. Special entities that appear in the option_text
    option_text_entities: ?[]const MessageEntity = null,
};

/// This object contains information about an incoming pre-checkout query.
/// Reference: https://core.telegram.org/bots/api#precheckoutquery
pub const PreCheckoutQuery = struct {
    /// Unique query identifier
    id: []const u8,
    /// User who sent the query
    from: User,
    /// Three-letter ISO 4217 currency code, or "XTR" for payments in Telegram Stars
    currency: []const u8,
    /// Total price in the smallest units of the currency (integer, not float/double). For example, for a price of US$ 1.45 pass amount = 145. See the exp parameter in currencies.json, it shows the number of digits past the decimal point for each currency (2 for the majority of currencies).
    total_amount: i64,
    /// Bot-specified invoice payload
    invoice_payload: []const u8,
    /// Optional. Identifier of the shipping option chosen by the user
    shipping_option_id: ?[]const u8 = null,
    /// Optional. Order information provided by the user
    order_info: ?OrderInfo = null,
};

/// Describes an inline message to be sent by a user of a Mini App.
/// Reference: https://core.telegram.org/bots/api#preparedinlinemessage
pub const PreparedInlineMessage = struct {
    /// Unique identifier of the prepared message
    id: []const u8,
    /// Expiration date of the prepared message, in Unix time. Expired prepared messages can no longer be used.
    expiration_date: i64,
};

/// Describes a keyboard button to be used by a user of a Mini App.
/// Reference: https://core.telegram.org/bots/api#preparedkeyboardbutton
pub const PreparedKeyboardButton = struct {
    /// Unique identifier of the keyboard button
    id: []const u8,
};

/// This object represents the content of a service message, sent whenever a user in the chat triggers a proximity alert set by another user.
/// Reference: https://core.telegram.org/bots/api#proximityalerttriggered
pub const ProximityAlertTriggered = struct {
    /// User that triggered the alert
    traveler: User,
    /// User that set the alert
    watcher: User,
    /// The distance between the users
    distance: i64,
};

/// Represents a reaction added to a message along with the number of times it was added.
/// Reference: https://core.telegram.org/bots/api#reactioncount
pub const ReactionCount = struct {
    /// Type of the reaction
    type: ReactionType,
    /// Number of times the reaction was added
    total_count: i64,
};

/// This object describes the type of a reaction. Currently, it can be one of
/// - ReactionTypeEmoji
/// - ReactionTypeCustomEmoji
/// - ReactionTypePaid
/// Reference: https://core.telegram.org/bots/api#reactiontype
pub const ReactionType = union(enum) {
    emoji: ReactionTypeEmoji,
    custom_emoji: ReactionTypeCustomEmoji,
    paid: ReactionTypePaid,

    pub fn jsonStringify(self: ReactionType, jw: anytype) !void {
        switch (self) {
            inline else => |payload| try jw.write(payload),
        }
    }

    pub fn writeMultipartJson(
        self: ReactionType,
        arena: Allocator,
        jw: *std.json.Stringify,
        pending_parts: *std.ArrayList(multipart_mod.PendingPart),
        comptime writeFn: anytype,
    ) !void {
        switch (self) {
            inline else => |payload| try writeFn(arena, jw, payload, pending_parts),
        }
    }

    pub fn jsonParse(
        allocator: Allocator,
        source: anytype,
        options: std.json.ParseOptions,
    ) std.json.ParseError(@TypeOf(source.*))!ReactionType {
        return json_mod.parseDiscriminatedUnion(
            ReactionType,
            "type",
            .{
                .{ "emoji", "emoji" },
                .{ "custom_emoji", "custom_emoji" },
                .{ "paid", "paid" },
            },
            allocator,
            source,
            options,
        );
    }
};

/// The reaction is based on a custom emoji.
/// Reference: https://core.telegram.org/bots/api#reactiontypecustomemoji
pub const ReactionTypeCustomEmoji = struct {
    /// Type of the reaction, always "custom_emoji"
    type: []const u8 = "custom_emoji",
    /// Custom emoji identifier
    custom_emoji_id: []const u8,
};

/// The reaction is based on an emoji.
/// Reference: https://core.telegram.org/bots/api#reactiontypeemoji
pub const ReactionTypeEmoji = struct {
    /// Type of the reaction, always "emoji"
    type: []const u8 = "emoji",
    /// Reaction emoji. Currently, it can be one of "❤", "👍", "👎", "🔥", "🥰", "👏", "😁", "🤔", "🤯", "😱", "🤬", "😢", "🎉", "🤩", "🤮", "💩", "🙏", "👌", "🕊", "🤡", "🥱", "🥴", "😍", "🐳", "❤‍🔥", "🌚", "🌭", "💯", "🤣", "⚡", "🍌", "🏆", "💔", "🤨", "😐", "🍓", "🍾", "💋", "🖕", "😈", "😴", "😭", "🤓", "👻", "👨‍💻", "👀", "🎃", "🙈", "😇", "😨", "🤝", "✍", "🤗", "🫡", "🎅", "🎄", "☃", "💅", "🤪", "🗿", "🆒", "💘", "🙉", "🦄", "😘", "💊", "🙊", "😎", "👾", "🤷‍♂", "🤷", "🤷‍♀", "😡".
    emoji: []const u8,
};

/// The reaction is paid.
/// Reference: https://core.telegram.org/bots/api#reactiontypepaid
pub const ReactionTypePaid = struct {
    /// Type of the reaction, always "paid"
    type: []const u8 = "paid",
};

/// This object contains basic information about a refunded payment.
/// Reference: https://core.telegram.org/bots/api#refundedpayment
pub const RefundedPayment = struct {
    /// Three-letter ISO 4217 currency code, or "XTR" for payments in Telegram Stars. Currently, always "XTR".
    currency: []const u8 = "XTR",
    /// Total refunded price in the smallest units of the currency (integer, not float/double). For example, for a price of US$ 1.45, total_amount = 145. See the exp parameter in currencies.json, it shows the number of digits past the decimal point for each currency (2 for the majority of currencies).
    total_amount: i64,
    /// Bot-specified invoice payload
    invoice_payload: []const u8,
    /// Telegram payment identifier
    telegram_payment_charge_id: []const u8,
    /// Optional. Provider payment identifier
    provider_payment_charge_id: ?[]const u8 = null,
};

/// This object represents a custom keyboard with reply options (see Introduction to bots for details and examples). Not supported in channels and for messages sent on behalf of a business account.
/// Reference: https://core.telegram.org/bots/api#replykeyboardmarkup
pub const ReplyKeyboardMarkup = struct {
    /// Array of button rows, each represented by an Array of KeyboardButton objects
    keyboard: []const []const KeyboardButton,
    /// Optional. Requests clients to always show the keyboard when the regular keyboard is hidden. Defaults to False, in which case the custom keyboard can be hidden and opened with a keyboard icon.
    is_persistent: ?bool = null,
    /// Optional. Requests clients to resize the keyboard vertically for optimal fit (e.g., make the keyboard smaller if there are just two rows of buttons). Defaults to False, in which case the custom keyboard is always of the same height as the app's standard keyboard.
    resize_keyboard: ?bool = null,
    /// Optional. Requests clients to hide the keyboard as soon as it's been used. The keyboard will still be available, but clients will automatically display the usual letter-keyboard in the chat - the user can press a special button in the input field to see the custom keyboard again. Defaults to False.
    one_time_keyboard: ?bool = null,
    /// Optional. The placeholder to be shown in the input field when the keyboard is active; 1-64 characters
    input_field_placeholder: ?[]const u8 = null,
    /// Optional. Use this parameter if you want to show the keyboard to specific users only. Targets: 1) users that are @mentioned in the text of the Message object; 2) if the bot's message is a reply to a message in the same chat and forum topic, sender of the original message. Example: A user requests to change the bot's language, bot replies to the request with a keyboard to select the new language. Other users in the group don't see the keyboard.
    selective: ?bool = null,
    /// Optional. Pass True if the reply interface must be shown to the user, as if they had manually selected the bot's message and tapped 'Reply'
    force_reply: ?bool = null,
};

/// Upon receiving a message with this object, Telegram clients will remove the current custom keyboard and display the default letter-keyboard. By default, custom keyboards are displayed until a new keyboard is sent by a bot. An exception is made for one-time keyboards that are hidden immediately after the user presses a button (see ReplyKeyboardMarkup). Not supported in channels and for messages sent on behalf of a business account.
/// Reference: https://core.telegram.org/bots/api#replykeyboardremove
pub const ReplyKeyboardRemove = struct {
    /// Requests clients to remove the custom keyboard (user will not be able to summon this keyboard; if you want to hide the keyboard from sight but keep it accessible, use one_time_keyboard in ReplyKeyboardMarkup)
    remove_keyboard: bool,
    /// Optional. Use this parameter if you want to remove the keyboard for specific users only. Targets: 1) users that are @mentioned in the text of the Message object; 2) if the bot's message is a reply to a message in the same chat and forum topic, sender of the original message. Example: A user votes in a poll, bot returns confirmation message in reply to the vote and removes the keyboard for that user, while still showing the keyboard with poll options to users who haven't voted yet.
    selective: ?bool = null,
};

/// Describes reply parameters for the message that is being sent.
/// Reference: https://core.telegram.org/bots/api#replyparameters
pub const ReplyParameters = struct {
    /// Optional. Identifier of the message that will be replied to in the current chat, or in the chat chat_id if it is specified. Required if ephemeral_message_id isn't specified.
    message_id: ?i64 = null,
    /// Optional. If the message to be replied to is from a different chat, unique identifier for the chat or username of the bot, supergroup or channel in the format @username. Not supported for messages sent on behalf of a business account, messages from channel direct messages chats and ephemeral messages.
    chat_id: ?ChatId = null,
    /// Optional. Identifier of the incoming ephemeral message that will be replied to in the current chat. A reply to an ephemeral message must itself be an ephemeral message. An ephemeral message may only be replied to within 15 seconds of being sent. Required if message_id isn't specified.
    ephemeral_message_id: ?i64 = null,
    /// Optional. Pass True if the message should be sent even if the specified message to be replied to is not found. Always False for replies in another chat or forum topic, and sent ephemeral messages. Always True for messages sent on behalf of a business account.
    allow_sending_without_reply: ?bool = null,
    /// Optional. Quoted part of the message to be replied to; 0-1024 characters after entities parsing. The quote must be an exact substring of the message to be replied to, including bold, italic, underline, strikethrough, spoiler, custom_emoji, and date_time entities. The message will fail to send if the quote isn't found in the original message. Ignored for ephemeral messages.
    quote: ?[]const u8 = null,
    /// Optional. Mode for parsing entities in the quote. See formatting options for more details.
    quote_parse_mode: ?[]const u8 = null,
    /// Optional. A JSON-serialized list of special entities that appear in the quote. It can be specified instead of quote_parse_mode.
    quote_entities: ?[]const MessageEntity = null,
    /// Optional. Position of the quote in the original message in UTF-16 code units
    quote_position: ?i64 = null,
    /// Optional. Identifier of the specific checklist task to be replied to
    checklist_task_id: ?i64 = null,
    /// Optional. Persistent identifier of the specific poll option to be replied to
    poll_option_id: ?[]const u8 = null,
};

/// Describes why a request was unsuccessful.
/// Reference: https://core.telegram.org/bots/api#responseparameters
pub const ResponseParameters = struct {
    /// Optional. The group has been migrated to a supergroup with the specified identifier. This number may have more than 32 significant bits and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a signed 64-bit integer or double-precision float type are safe for storing this identifier.
    migrate_to_chat_id: ?i64 = null,
    /// Optional. In case of exceeding flood control, the number of seconds left to wait before the request can be repeated
    retry_after: ?i64 = null,
};

/// This object describes the state of a revenue withdrawal operation. Currently, it can be one of
/// - RevenueWithdrawalStatePending
/// - RevenueWithdrawalStateSucceeded
/// - RevenueWithdrawalStateFailed
/// Reference: https://core.telegram.org/bots/api#revenuewithdrawalstate
pub const RevenueWithdrawalState = union(enum) {
    pending: RevenueWithdrawalStatePending,
    succeeded: RevenueWithdrawalStateSucceeded,
    failed: RevenueWithdrawalStateFailed,

    pub fn jsonStringify(self: RevenueWithdrawalState, jw: anytype) !void {
        switch (self) {
            inline else => |payload| try jw.write(payload),
        }
    }

    pub fn writeMultipartJson(
        self: RevenueWithdrawalState,
        arena: Allocator,
        jw: *std.json.Stringify,
        pending_parts: *std.ArrayList(multipart_mod.PendingPart),
        comptime writeFn: anytype,
    ) !void {
        switch (self) {
            inline else => |payload| try writeFn(arena, jw, payload, pending_parts),
        }
    }

    pub fn jsonParse(
        allocator: Allocator,
        source: anytype,
        options: std.json.ParseOptions,
    ) std.json.ParseError(@TypeOf(source.*))!RevenueWithdrawalState {
        return json_mod.parseDiscriminatedUnion(
            RevenueWithdrawalState,
            "type",
            .{
                .{ "pending", "pending" },
                .{ "succeeded", "succeeded" },
                .{ "failed", "failed" },
            },
            allocator,
            source,
            options,
        );
    }
};

/// The withdrawal failed and the transaction was refunded.
/// Reference: https://core.telegram.org/bots/api#revenuewithdrawalstatefailed
pub const RevenueWithdrawalStateFailed = struct {
    /// Type of the state, always "failed"
    type: []const u8 = "failed",
};

/// The withdrawal is in progress.
/// Reference: https://core.telegram.org/bots/api#revenuewithdrawalstatepending
pub const RevenueWithdrawalStatePending = struct {
    /// Type of the state, always "pending"
    type: []const u8 = "pending",
};

/// The withdrawal succeeded.
/// Reference: https://core.telegram.org/bots/api#revenuewithdrawalstatesucceeded
pub const RevenueWithdrawalStateSucceeded = struct {
    /// Type of the state, always "succeeded"
    type: []const u8 = "succeeded",
    /// Date the withdrawal was completed in Unix time
    date: i64,
    /// An HTTPS URL that can be used to see transaction details
    url: []const u8,
};

/// This object represents a block in a rich formatted message. Currently, it can be any of the following types:
/// - RichBlockParagraph
/// - RichBlockSectionHeading
/// - RichBlockPreformatted
/// - RichBlockFooter
/// - RichBlockDivider
/// - RichBlockMathematicalExpression
/// - RichBlockAnchor
/// - RichBlockList
/// - RichBlockBlockQuotation
/// - RichBlockExpandableBlockQuotation
/// - RichBlockPullQuotation
/// - RichBlockCollage
/// - RichBlockSlideshow
/// - RichBlockTable
/// - RichBlockDetails
/// - RichBlockMap
/// - RichBlockButtons
/// - RichBlockAnimation
/// - RichBlockAudio
/// - RichBlockDocument
/// - RichBlockPhoto
/// - RichBlockVideo
/// - RichBlockVoiceNote
/// - RichBlockThinking
/// Reference: https://core.telegram.org/bots/api#richblock
pub const RichBlock = union(enum) {
    paragraph: RichBlockParagraph,
    section_heading: RichBlockSectionHeading,
    preformatted: RichBlockPreformatted,
    footer: RichBlockFooter,
    divider: RichBlockDivider,
    mathematical_expression: RichBlockMathematicalExpression,
    anchor: RichBlockAnchor,
    list: RichBlockList,
    block_quotation: RichBlockBlockQuotation,
    expandable_block_quotation: RichBlockExpandableBlockQuotation,
    pull_quotation: RichBlockPullQuotation,
    collage: RichBlockCollage,
    slideshow: RichBlockSlideshow,
    table: RichBlockTable,
    details: RichBlockDetails,
    map: RichBlockMap,
    buttons: RichBlockButtons,
    animation: RichBlockAnimation,
    audio: RichBlockAudio,
    document: RichBlockDocument,
    photo: RichBlockPhoto,
    video: RichBlockVideo,
    voice_note: RichBlockVoiceNote,
    thinking: RichBlockThinking,

    pub fn jsonStringify(self: RichBlock, jw: anytype) !void {
        switch (self) {
            inline else => |payload| try jw.write(payload),
        }
    }

    pub fn writeMultipartJson(
        self: RichBlock,
        arena: Allocator,
        jw: *std.json.Stringify,
        pending_parts: *std.ArrayList(multipart_mod.PendingPart),
        comptime writeFn: anytype,
    ) !void {
        switch (self) {
            inline else => |payload| try writeFn(arena, jw, payload, pending_parts),
        }
    }

    pub fn jsonParse(
        allocator: Allocator,
        source: anytype,
        options: std.json.ParseOptions,
    ) std.json.ParseError(@TypeOf(source.*))!RichBlock {
        return json_mod.parseDiscriminatedUnion(
            RichBlock,
            "type",
            .{
                .{ "paragraph", "paragraph" },
                .{ "heading", "section_heading" },
                .{ "pre", "preformatted" },
                .{ "footer", "footer" },
                .{ "divider", "divider" },
                .{ "mathematical_expression", "mathematical_expression" },
                .{ "anchor", "anchor" },
                .{ "list", "list" },
                .{ "blockquote", "block_quotation" },
                .{ "expandable_blockquote", "expandable_block_quotation" },
                .{ "pullquote", "pull_quotation" },
                .{ "collage", "collage" },
                .{ "slideshow", "slideshow" },
                .{ "table", "table" },
                .{ "details", "details" },
                .{ "map", "map" },
                .{ "buttons", "buttons" },
                .{ "animation", "animation" },
                .{ "audio", "audio" },
                .{ "document", "document" },
                .{ "photo", "photo" },
                .{ "video", "video" },
                .{ "voice_note", "voice_note" },
                .{ "thinking", "thinking" },
            },
            allocator,
            source,
            options,
        );
    }
};

/// A block with an anchor, corresponding to the HTML tag <a> with the attribute name.
/// Reference: https://core.telegram.org/bots/api#richblockanchor
pub const RichBlockAnchor = struct {
    /// Type of the block, always "anchor"
    type: []const u8 = "anchor",
    /// The name of the anchor
    name: []const u8,
};

/// A block with an animation, corresponding to the HTML tag <video>.
/// Reference: https://core.telegram.org/bots/api#richblockanimation
pub const RichBlockAnimation = struct {
    /// Type of the block, always "animation"
    type: []const u8 = "animation",
    /// The animation
    animation: Animation,
    /// Optional. True, if the media preview is covered by a spoiler animation
    has_spoiler: ?bool = null,
    /// Optional. Caption of the block
    caption: ?RichBlockCaption = null,
};

/// A block with a music file, corresponding to the HTML tag <audio>.
/// Reference: https://core.telegram.org/bots/api#richblockaudio
pub const RichBlockAudio = struct {
    /// Type of the block, always "audio"
    type: []const u8 = "audio",
    /// The audio
    audio: Audio,
    /// Optional. Caption of the block
    caption: ?RichBlockCaption = null,
};

/// A block quotation, corresponding to the HTML tag <blockquote>.
/// Reference: https://core.telegram.org/bots/api#richblockblockquotation
pub const RichBlockBlockQuotation = struct {
    /// Type of the block, always "blockquote"
    type: []const u8 = "blockquote",
    /// Content of the block
    blocks: []const RichBlock,
    /// Optional. Credit of the block
    credit: ?*const RichText = null,
};

/// A block containing a list of buttons that are shown in one row, corresponding to the custom HTML tag <tg-button-row>.
/// Reference: https://core.telegram.org/bots/api#richblockbuttons
pub const RichBlockButtons = struct {
    /// Type of the block, always "buttons"
    type: []const u8 = "buttons",
    /// The buttons
    buttons: []const RichMessageButton,
    /// Optional. Horizontal alignment of the buttons. Currently, must be one of "left", "center", or "right".
    @"align": ?[]const u8 = null,
};

/// Caption of a rich formatted block.
/// Reference: https://core.telegram.org/bots/api#richblockcaption
pub const RichBlockCaption = struct {
    /// Block caption
    text: *const RichText,
    /// Optional. Block credit which corresponds to the HTML tag <cite>
    credit: ?*const RichText = null,
};

/// A collage, corresponding to the custom HTML tag <tg-collage>.
/// Reference: https://core.telegram.org/bots/api#richblockcollage
pub const RichBlockCollage = struct {
    /// Type of the block, always "collage"
    type: []const u8 = "collage",
    /// Elements of the collage
    blocks: []const RichBlock,
    /// Optional. Caption of the block
    caption: ?RichBlockCaption = null,
};

/// An expandable block for details disclosure, corresponding to the HTML tag <details>.
/// Reference: https://core.telegram.org/bots/api#richblockdetails
pub const RichBlockDetails = struct {
    /// Type of the block, always "details"
    type: []const u8 = "details",
    /// Always shown summary of the block
    summary: *const RichText,
    /// Content of the block
    blocks: []const RichBlock,
    /// Optional. True, if the content of the block is visible by default
    is_open: ?bool = null,
};

/// A divider, corresponding to the HTML tag <hr/>.
/// Reference: https://core.telegram.org/bots/api#richblockdivider
pub const RichBlockDivider = struct {
    /// Type of the block, always "divider"
    type: []const u8 = "divider",
};

/// A block with a general file, corresponding to the custom HTML tag <tg-document>.
/// Reference: https://core.telegram.org/bots/api#richblockdocument
pub const RichBlockDocument = struct {
    /// Type of the block, always "document"
    type: []const u8 = "document",
    /// The document
    document: Document,
    /// Optional. Caption of the block
    caption: ?RichBlockCaption = null,
};

/// A block quotation, corresponding to the HTML tag <blockquote> with custom attribute "expandable".
/// Reference: https://core.telegram.org/bots/api#richblockexpandableblockquotation
pub const RichBlockExpandableBlockQuotation = struct {
    /// Type of the block, always "expandable_blockquote"
    type: []const u8 = "expandable_blockquote",
    /// Content of the block
    text: *const RichText,
    /// Optional. Credit of the block
    credit: ?*const RichText = null,
};

/// A footer, corresponding to the HTML tag <footer>.
/// Reference: https://core.telegram.org/bots/api#richblockfooter
pub const RichBlockFooter = struct {
    /// Type of the block, always "footer"
    type: []const u8 = "footer",
    /// Text of the block
    text: *const RichText,
};

/// A list of blocks, corresponding to the HTML tag <ul> or <ol> with multiple nested tags <li>.
/// Reference: https://core.telegram.org/bots/api#richblocklist
pub const RichBlockList = struct {
    /// Type of the block, always "list"
    type: []const u8 = "list",
    /// Items of the list
    items: []const RichBlockListItem,
};

/// An item of a list.
/// Reference: https://core.telegram.org/bots/api#richblocklistitem
pub const RichBlockListItem = struct {
    /// Label of the item
    label: []const u8,
    /// The content of the item
    blocks: []const RichBlock,
    /// Optional. True, if the item has a checkbox
    has_checkbox: ?bool = null,
    /// Optional. True, if the item has a checked checkbox
    is_checked: ?bool = null,
    /// Optional. For ordered lists, the numeric value of the item label
    value: ?i64 = null,
    /// Optional. For ordered lists, the type of the item label; must be one of "a" for lowercase letters, "A" for uppercase letters, "i" for lowercase Roman numerals, "I" for uppercase Roman numerals, or "1" for decimal numbers
    type: ?[]const u8 = null,
};

/// A block with a map, corresponding to the custom HTML tag <tg-map>.
/// Reference: https://core.telegram.org/bots/api#richblockmap
pub const RichBlockMap = struct {
    /// Type of the block, always "map"
    type: []const u8 = "map",
    /// Location of the center of the map
    location: Location,
    /// Map zoom level
    zoom: i64,
    /// Expected width of the map
    width: i64,
    /// Expected height of the map
    height: i64,
    /// Optional. Caption of the block
    caption: ?RichBlockCaption = null,
};

/// A block with a mathematical expression in LaTeX format, corresponding to the custom HTML tag <tg-math-block>.
/// Reference: https://core.telegram.org/bots/api#richblockmathematicalexpression
pub const RichBlockMathematicalExpression = struct {
    /// Type of the block, always "mathematical_expression"
    type: []const u8 = "mathematical_expression",
    /// The mathematical expression in LaTeX format
    expression: []const u8,
};

/// A text paragraph, corresponding to the HTML tag <p>.
/// Reference: https://core.telegram.org/bots/api#richblockparagraph
pub const RichBlockParagraph = struct {
    /// Type of the block, always "paragraph"
    type: []const u8 = "paragraph",
    /// Text of the block
    text: *const RichText,
};

/// A block with a photo, corresponding to the HTML tag <img>.
/// Reference: https://core.telegram.org/bots/api#richblockphoto
pub const RichBlockPhoto = struct {
    /// Type of the block, always "photo"
    type: []const u8 = "photo",
    /// Available sizes of the photo
    photo: []const PhotoSize,
    /// Optional. True, if the media preview is covered by a spoiler animation
    has_spoiler: ?bool = null,
    /// Optional. Caption of the block
    caption: ?RichBlockCaption = null,
};

/// A preformatted text block, corresponding to the nested HTML tags <pre> and <code>.
/// Reference: https://core.telegram.org/bots/api#richblockpreformatted
pub const RichBlockPreformatted = struct {
    /// Type of the block, always "pre"
    type: []const u8 = "pre",
    /// Text of the block
    text: *const RichText,
    /// Optional. The programming language of the text
    language: ?[]const u8 = null,
};

/// A quotation with centered text, loosely corresponding to the HTML tag <aside>.
/// Reference: https://core.telegram.org/bots/api#richblockpullquotation
pub const RichBlockPullQuotation = struct {
    /// Type of the block, always "pullquote"
    type: []const u8 = "pullquote",
    /// Text of the block
    text: *const RichText,
    /// Optional. Credit of the block
    credit: ?*const RichText = null,
};

/// A section heading, corresponding to the HTML tags <h1>, <h2>, <h3>, <h4>, <h5>, or <h6>.
/// Reference: https://core.telegram.org/bots/api#richblocksectionheading
pub const RichBlockSectionHeading = struct {
    /// Type of the block, always "heading"
    type: []const u8 = "heading",
    /// Text of the block
    text: *const RichText,
    /// Relative size of the text font; 1-6, 1 is the largest, 6 is the smallest
    size: i64,
};

/// A slideshow, corresponding to the custom HTML tag <tg-slideshow>.
/// Reference: https://core.telegram.org/bots/api#richblockslideshow
pub const RichBlockSlideshow = struct {
    /// Type of the block, always "slideshow"
    type: []const u8 = "slideshow",
    /// Elements of the slideshow
    blocks: []const RichBlock,
    /// Optional. Caption of the block
    caption: ?RichBlockCaption = null,
};

/// A table, corresponding to the HTML tag <table>.
/// Reference: https://core.telegram.org/bots/api#richblocktable
pub const RichBlockTable = struct {
    /// Type of the block, always "table"
    type: []const u8 = "table",
    /// Cells of the table
    cells: []const []const RichBlockTableCell,
    /// Optional. True, if the table has borders
    is_bordered: ?bool = null,
    /// Optional. True, if the table is striped
    is_striped: ?bool = null,
    /// Optional. True, if table cells have smaller indents
    is_compact: ?bool = null,
    /// Optional. Caption of the table
    caption: ?*const RichText = null,
};

/// Cell in a table.
/// Reference: https://core.telegram.org/bots/api#richblocktablecell
pub const RichBlockTableCell = struct {
    /// Horizontal cell content alignment. Currently, must be one of "left", "center", or "right".
    @"align": []const u8 = "one",
    /// Vertical cell content alignment. Currently, must be one of "top", "middle", or "bottom".
    valign: []const u8 = "one",
    /// Optional. Text in the cell. If omitted, then the cell is invisible.
    text: ?*const RichText = null,
    /// Optional. True, if the cell is a header cell
    is_header: ?bool = null,
    /// Optional. The number of columns the cell spans if it is bigger than 1
    colspan: ?i64 = null,
    /// Optional. The number of rows the cell spans if it is bigger than 1
    rowspan: ?i64 = null,
};

/// A block with a "Thinking..." placeholder, corresponding to the custom HTML tag <tg-thinking>. The block may be used only in sendRichMessageDraft, therefore it can't be received in messages. See https://t.me/addemoji/AIActions for examples of custom emoji that are recommended for usage in the block.
/// Reference: https://core.telegram.org/bots/api#richblockthinking
pub const RichBlockThinking = struct {
    /// Type of the block, always "thinking"
    type: []const u8 = "thinking",
    /// Text of the block. See https://t.me/addemoji/AIActions for examples of custom emoji that are recommended for usage in the block.
    text: *const RichText,
};

/// A block with a video, corresponding to the HTML tag <video>.
/// Reference: https://core.telegram.org/bots/api#richblockvideo
pub const RichBlockVideo = struct {
    /// Type of the block, always "video"
    type: []const u8 = "video",
    /// The video
    video: Video,
    /// Optional. True, if the media preview is covered by a spoiler animation
    has_spoiler: ?bool = null,
    /// Optional. Caption of the block
    caption: ?RichBlockCaption = null,
};

/// A block with a voice note, corresponding to the HTML tag <audio>.
/// Reference: https://core.telegram.org/bots/api#richblockvoicenote
pub const RichBlockVoiceNote = struct {
    /// Type of the block, always "voice_note"
    type: []const u8 = "voice_note",
    /// The voice note
    voice_note: Voice,
    /// Optional. Caption of the block
    caption: ?RichBlockCaption = null,
};

/// Rich formatted message.
/// Reference: https://core.telegram.org/bots/api#richmessage
pub const RichMessage = struct {
    /// Content of the message
    blocks: []const RichBlock,
    /// Optional. True, if the rich message must be shown right-to-left
    is_rtl: ?bool = null,
};

/// This object represents a button in a RichMessage. Exactly one of the fields other than text and style must be used to specify the type of the button.
/// Reference: https://core.telegram.org/bots/api#richmessagebutton
pub const RichMessageButton = struct {
    /// Text of the button. May contain only plain text, RichTextCustomEmoji and RichTextDateTime entities.
    text: *const RichText,
    /// Optional. Style of the button. Must be one of "danger", "success", "primary", or "link" (the button is shown as a regular link without borders). Apps may use theme-specific colors for the button background and text based on the style. The style "link" is allowed only for callback buttons.
    style: ?[]const u8 = null,
    /// Optional. HTTP or tg:// URL to be opened when the button is pressed. Links tg://user?id=<user_id> can be used to mention a user by their identifier without using a username, if this is allowed by their privacy settings.
    url: ?[]const u8 = null,
    /// Optional. Data to be sent in a callback query to the bot when the button is pressed, 1-64 bytes
    callback_data: ?[]const u8 = null,
    /// Optional. Description of the Web App that will be launched when the user presses the button. The Web App will be able to send an arbitrary message on behalf of the user using the method answerWebAppQuery. Available only in private chats between a user and the bot. Not supported for messages sent on behalf of a business account.
    web_app: ?WebAppInfo = null,
    /// Optional. An HTTPS URL used to automatically authorize the user. Can be used as a replacement for the Telegram Login Widget. Not supported for ephemeral messages.
    login_url: ?LoginUrl = null,
    /// Optional. If set, pressing the button will prompt the user to select one of their chats, open that chat and insert the bot's username and the specified inline query in the input field. May be empty, in which case just the bot's username will be inserted. Not supported for messages sent in channel direct messages chats and on behalf of a business account.
    switch_inline_query: ?[]const u8 = null,
    /// Optional. If set, pressing the button will insert the bot's username and the specified inline query in the current chat's input field. May be empty, in which case only the bot's username will be inserted. Not supported in channels and for messages sent in channel direct messages chats and on behalf of a business account.
    switch_inline_query_current_chat: ?[]const u8 = null,
    /// Optional. If set, pressing the button will prompt the user to select one of their chats of the specified type, open that chat and insert the bot's username and the specified inline query in the input field. Not supported for messages sent in channel direct messages chats and on behalf of a business account.
    switch_inline_query_chosen_chat: ?SwitchInlineQueryChosenChat = null,
    /// Optional. A button that copies the specified text to the clipboard
    copy_text: ?CopyTextButton = null,
    /// Optional. If set, then the button is disabled and does nothing
    disabled: ?DisabledButton = null,
};

/// This object represents a rich formatted text. Currently, it can be either a String for plain text, an Array of RichText, or any of the following types:
/// - RichTextBold
/// - RichTextItalic
/// - RichTextUnderline
/// - RichTextStrikethrough
/// - RichTextSpoiler
/// - RichTextDateTime
/// - RichTextTextMention
/// - RichTextSubscript
/// - RichTextSuperscript
/// - RichTextMarked
/// - RichTextCode
/// - RichTextCustomEmoji
/// - RichTextMathematicalExpression
/// - RichTextUrl
/// - RichTextEmailAddress
/// - RichTextPhoneNumber
/// - RichTextBankCardNumber
/// - RichTextMention
/// - RichTextHashtag
/// - RichTextCashtag
/// - RichTextBotCommand
/// - RichTextButton
/// - RichTextAnchor
/// - RichTextAnchorLink
/// - RichTextReference
/// - RichTextReferenceLink
/// Reference: https://core.telegram.org/bots/api#richtext
pub const RichText = union(enum) {
    plain: []const u8,
    array: []const RichText,
    bold: RichTextBold,
    italic: RichTextItalic,
    underline: RichTextUnderline,
    strikethrough: RichTextStrikethrough,
    spoiler: RichTextSpoiler,
    date_time: RichTextDateTime,
    text_mention: RichTextTextMention,
    subscript: RichTextSubscript,
    superscript: RichTextSuperscript,
    marked: RichTextMarked,
    code: RichTextCode,
    custom_emoji: RichTextCustomEmoji,
    mathematical_expression: RichTextMathematicalExpression,
    url: RichTextUrl,
    email_address: RichTextEmailAddress,
    phone_number: RichTextPhoneNumber,
    bank_card_number: RichTextBankCardNumber,
    mention: RichTextMention,
    hashtag: RichTextHashtag,
    cashtag: RichTextCashtag,
    bot_command: RichTextBotCommand,
    button: RichTextButton,
    anchor: RichTextAnchor,
    anchor_link: RichTextAnchorLink,
    reference: RichTextReference,
    reference_link: RichTextReferenceLink,

    pub fn jsonStringify(self: RichText, jw: anytype) !void {
        switch (self) {
            .plain => |s| try jw.write(s),
            .array => |arr| try jw.write(arr),
            inline else => |payload| try jw.write(payload),
        }
    }

    pub fn jsonParse(
        allocator: Allocator,
        source: anytype,
        options: std.json.ParseOptions,
    ) std.json.ParseError(@TypeOf(source.*))!RichText {
        return switch (try source.peekNextTokenType()) {
            .string => .{ .plain = try std.json.innerParse([]const u8, allocator, source, options) },
            .array_begin => .{ .array = try std.json.innerParse([]const RichText, allocator, source, options) },
            .object_begin => json_mod.parseDiscriminatedUnion(
                RichText,
                "type",
                .{
                    .{ "bold", "bold" },
                    .{ "italic", "italic" },
                    .{ "underline", "underline" },
                    .{ "strikethrough", "strikethrough" },
                    .{ "spoiler", "spoiler" },
                    .{ "date_time", "date_time" },
                    .{ "text_mention", "text_mention" },
                    .{ "subscript", "subscript" },
                    .{ "superscript", "superscript" },
                    .{ "marked", "marked" },
                    .{ "code", "code" },
                    .{ "custom_emoji", "custom_emoji" },
                    .{ "mathematical_expression", "mathematical_expression" },
                    .{ "url", "url" },
                    .{ "email_address", "email_address" },
                    .{ "phone_number", "phone_number" },
                    .{ "bank_card_number", "bank_card_number" },
                    .{ "mention", "mention" },
                    .{ "hashtag", "hashtag" },
                    .{ "cashtag", "cashtag" },
                    .{ "bot_command", "bot_command" },
                    .{ "button", "button" },
                    .{ "anchor", "anchor" },
                    .{ "anchor_link", "anchor_link" },
                    .{ "reference", "reference" },
                    .{ "reference_link", "reference_link" },
                },
                allocator,
                source,
                options,
            ),
            else => error.UnexpectedToken,
        };
    }
};

/// An anchor.
/// Reference: https://core.telegram.org/bots/api#richtextanchor
pub const RichTextAnchor = struct {
    /// Type of the rich text, always "anchor"
    type: []const u8 = "anchor",
    /// The name of the anchor
    name: []const u8,
};

/// A link to an anchor.
/// Reference: https://core.telegram.org/bots/api#richtextanchorlink
pub const RichTextAnchorLink = struct {
    /// Type of the rich text, always "anchor_link"
    type: []const u8 = "anchor_link",
    /// The link text
    text: *const RichText,
    /// The name of the anchor. If the name is empty, then the link brings back to the top of the message.
    anchor_name: []const u8,
};

/// A text with a bank card number.
/// Reference: https://core.telegram.org/bots/api#richtextbankcardnumber
pub const RichTextBankCardNumber = struct {
    /// Type of the rich text, always "bank_card_number"
    type: []const u8 = "bank_card_number",
    /// The text
    text: *const RichText,
    /// The bank card number
    bank_card_number: []const u8,
};

/// A bold text.
/// Reference: https://core.telegram.org/bots/api#richtextbold
pub const RichTextBold = struct {
    /// Type of the rich text, always "bold"
    type: []const u8 = "bold",
    /// The text
    text: *const RichText,
};

/// A bot command.
/// Reference: https://core.telegram.org/bots/api#richtextbotcommand
pub const RichTextBotCommand = struct {
    /// Type of the rich text, always "bot_command"
    type: []const u8 = "bot_command",
    /// The text
    text: *const RichText,
    /// The bot command
    bot_command: []const u8,
};

/// A button.
/// Reference: https://core.telegram.org/bots/api#richtextbutton
pub const RichTextButton = struct {
    /// Type of the rich text, always "button"
    type: []const u8 = "button",
    /// The button
    button: RichMessageButton,
};

/// A cashtag.
/// Reference: https://core.telegram.org/bots/api#richtextcashtag
pub const RichTextCashtag = struct {
    /// Type of the rich text, always "cashtag"
    type: []const u8 = "cashtag",
    /// The text
    text: *const RichText,
    /// The cashtag
    cashtag: []const u8,
};

/// A monowidth text.
/// Reference: https://core.telegram.org/bots/api#richtextcode
pub const RichTextCode = struct {
    /// Type of the rich text, always "code"
    type: []const u8 = "code",
    /// The text
    text: *const RichText,
};

/// A custom emoji.
/// Reference: https://core.telegram.org/bots/api#richtextcustomemoji
pub const RichTextCustomEmoji = struct {
    /// Type of the rich text, always "custom_emoji"
    type: []const u8 = "custom_emoji",
    /// Unique identifier of the custom emoji. Use getCustomEmojiStickers to get full information about the sticker.
    custom_emoji_id: []const u8,
    /// Alternative emoji for the custom emoji
    alternative_text: []const u8,
};

/// Formatted date and time.
/// Reference: https://core.telegram.org/bots/api#richtextdatetime
pub const RichTextDateTime = struct {
    /// Type of the rich text, always "date_time"
    type: []const u8 = "date_time",
    /// The text
    text: *const RichText,
    /// The Unix time associated with the entity
    unix_time: i64,
    /// The string that defines the formatting of the date and time. See date-time entity formatting for more details.
    date_time_format: []const u8,
};

/// A text with an email address.
/// Reference: https://core.telegram.org/bots/api#richtextemailaddress
pub const RichTextEmailAddress = struct {
    /// Type of the rich text, always "email_address"
    type: []const u8 = "email_address",
    /// The text
    text: *const RichText,
    /// The email address
    email_address: []const u8,
};

/// A hashtag.
/// Reference: https://core.telegram.org/bots/api#richtexthashtag
pub const RichTextHashtag = struct {
    /// Type of the rich text, always "hashtag"
    type: []const u8 = "hashtag",
    /// The text
    text: *const RichText,
    /// The hashtag
    hashtag: []const u8,
};

/// An italicized text.
/// Reference: https://core.telegram.org/bots/api#richtextitalic
pub const RichTextItalic = struct {
    /// Type of the rich text, always "italic"
    type: []const u8 = "italic",
    /// The text
    text: *const RichText,
};

/// A marked text.
/// Reference: https://core.telegram.org/bots/api#richtextmarked
pub const RichTextMarked = struct {
    /// Type of the rich text, always "marked"
    type: []const u8 = "marked",
    /// The text
    text: *const RichText,
};

/// A mathematical expression.
/// Reference: https://core.telegram.org/bots/api#richtextmathematicalexpression
pub const RichTextMathematicalExpression = struct {
    /// Type of the rich text, always "mathematical_expression"
    type: []const u8 = "mathematical_expression",
    /// The expression in LaTeX format
    expression: []const u8,
};

/// A mention by a username.
/// Reference: https://core.telegram.org/bots/api#richtextmention
pub const RichTextMention = struct {
    /// Type of the rich text, always "mention"
    type: []const u8 = "mention",
    /// The text
    text: *const RichText,
    /// The username
    username: []const u8,
};

/// A text with a phone number.
/// Reference: https://core.telegram.org/bots/api#richtextphonenumber
pub const RichTextPhoneNumber = struct {
    /// Type of the rich text, always "phone_number"
    type: []const u8 = "phone_number",
    /// The text
    text: *const RichText,
    /// The phone number
    phone_number: []const u8,
};

/// A reference.
/// Reference: https://core.telegram.org/bots/api#richtextreference
pub const RichTextReference = struct {
    /// Type of the rich text, always "reference"
    type: []const u8 = "reference",
    /// Text of the reference
    text: *const RichText,
    /// The name of the reference
    name: []const u8,
};

/// A link to a reference.
/// Reference: https://core.telegram.org/bots/api#richtextreferencelink
pub const RichTextReferenceLink = struct {
    /// Type of the rich text, always "reference_link"
    type: []const u8 = "reference_link",
    /// The link text
    text: *const RichText,
    /// The name of the reference
    reference_name: []const u8,
};

/// A text covered by a spoiler.
/// Reference: https://core.telegram.org/bots/api#richtextspoiler
pub const RichTextSpoiler = struct {
    /// Type of the rich text, always "spoiler"
    type: []const u8 = "spoiler",
    /// The text
    text: *const RichText,
};

/// A strikethrough text.
/// Reference: https://core.telegram.org/bots/api#richtextstrikethrough
pub const RichTextStrikethrough = struct {
    /// Type of the rich text, always "strikethrough"
    type: []const u8 = "strikethrough",
    /// The text
    text: *const RichText,
};

/// A subscript text.
/// Reference: https://core.telegram.org/bots/api#richtextsubscript
pub const RichTextSubscript = struct {
    /// Type of the rich text, always "subscript"
    type: []const u8 = "subscript",
    /// The text
    text: *const RichText,
};

/// A superscript text.
/// Reference: https://core.telegram.org/bots/api#richtextsuperscript
pub const RichTextSuperscript = struct {
    /// Type of the rich text, always "superscript"
    type: []const u8 = "superscript",
    /// The text
    text: *const RichText,
};

/// A mention of a Telegram user by their identifier.
/// Reference: https://core.telegram.org/bots/api#richtexttextmention
pub const RichTextTextMention = struct {
    /// Type of the rich text, always "text_mention"
    type: []const u8 = "text_mention",
    /// The text
    text: *const RichText,
    /// The mentioned user
    user: User,
};

/// An underlined text.
/// Reference: https://core.telegram.org/bots/api#richtextunderline
pub const RichTextUnderline = struct {
    /// Type of the rich text, always "underline"
    type: []const u8 = "underline",
    /// The text
    text: *const RichText,
};

/// A text with a link.
/// Reference: https://core.telegram.org/bots/api#richtexturl
pub const RichTextUrl = struct {
    /// Type of the rich text, always "url"
    type: []const u8 = "url",
    /// The text
    text: *const RichText,
    /// URL of the link
    url: []const u8,
};

/// Describes an inline message sent by a guest bot.
/// Reference: https://core.telegram.org/bots/api#sentguestmessage
pub const SentGuestMessage = struct {
    /// Identifier of the sent inline message
    inline_message_id: []const u8,
};

/// Describes an inline message sent by a Web App on behalf of a user.
/// Reference: https://core.telegram.org/bots/api#sentwebappmessage
pub const SentWebAppMessage = struct {
    /// Optional. Identifier of the sent inline message. Available only if there is an inline keyboard attached to the message.
    inline_message_id: ?[]const u8 = null,
};

/// This object contains information about a user that was shared with the bot using a KeyboardButtonRequestUsers button.
/// Reference: https://core.telegram.org/bots/api#shareduser
pub const SharedUser = struct {
    /// Identifier of the shared user. This number may have more than 32 significant bits and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so 64-bit integers or double-precision float types are safe for storing these identifiers. The bot may not have access to the user and could be unable to use this identifier, unless the user is already known to the bot by some other means.
    user_id: i64,
    /// Optional. First name of the user, if the name was requested by the bot
    first_name: ?[]const u8 = null,
    /// Optional. Last name of the user, if the name was requested by the bot
    last_name: ?[]const u8 = null,
    /// Optional. Username of the user, if the username was requested by the bot
    username: ?[]const u8 = null,
    /// Optional. Available sizes of the chat photo, if the photo was requested by the bot
    photo: ?[]const PhotoSize = null,
};

/// This object represents a shipping address.
/// Reference: https://core.telegram.org/bots/api#shippingaddress
pub const ShippingAddress = struct {
    /// Two-letter ISO 3166-1 alpha-2 country code
    country_code: []const u8,
    /// State, if applicable
    state: []const u8,
    /// City
    city: []const u8,
    /// First line for the address
    street_line1: []const u8,
    /// Second line for the address
    street_line2: []const u8,
    /// Address post code
    post_code: []const u8,
};

/// This object represents one shipping option.
/// Reference: https://core.telegram.org/bots/api#shippingoption
pub const ShippingOption = struct {
    /// Shipping option identifier
    id: []const u8,
    /// Option title
    title: []const u8,
    /// List of price portions
    prices: []const LabeledPrice,
};

/// This object contains information about an incoming shipping query.
/// Reference: https://core.telegram.org/bots/api#shippingquery
pub const ShippingQuery = struct {
    /// Unique query identifier
    id: []const u8,
    /// User who sent the query
    from: User,
    /// Bot-specified invoice payload
    invoice_payload: []const u8,
    /// User specified shipping address
    shipping_address: ShippingAddress,
};

/// Describes an amount of Telegram Stars.
/// Reference: https://core.telegram.org/bots/api#staramount
pub const StarAmount = struct {
    /// Integer amount of Telegram Stars, rounded to 0; can be negative
    amount: i64,
    /// Optional. The number of 1/1000000000 shares of Telegram Stars; from -999999999 to 999999999; can be negative if and only if amount is non-positive
    nanostar_amount: ?i64 = null,
};

/// Describes a Telegram Star transaction. Note that if the buyer initiates a chargeback with the payment provider from whom they acquired Stars (e.g., Apple, Google) following this transaction, the refunded Stars will be deducted from the bot's balance. This is outside of Telegram's control.
/// Reference: https://core.telegram.org/bots/api#startransaction
pub const StarTransaction = struct {
    /// Unique identifier of the transaction. Coincides with the identifier of the original transaction for refund transactions. Coincides with SuccessfulPayment.telegram_payment_charge_id for successful incoming payments from users.
    id: []const u8,
    /// Integer amount of Telegram Stars transferred by the transaction
    amount: i64,
    /// Date the transaction was created in Unix time
    date: i64,
    /// Optional. The number of 1/1000000000 shares of Telegram Stars transferred by the transaction; from 0 to 999999999
    nanostar_amount: ?i64 = null,
    /// Optional. Source of an incoming transaction (e.g., a user purchasing goods or services, Fragment refunding a failed withdrawal). Only for incoming transactions.
    source: ?TransactionPartner = null,
    /// Optional. Receiver of an outgoing transaction (e.g., a user for a purchase refund, Fragment for a withdrawal). Only for outgoing transactions.
    receiver: ?TransactionPartner = null,
};

/// Contains a list of Telegram Star transactions.
/// Reference: https://core.telegram.org/bots/api#startransactions
pub const StarTransactions = struct {
    /// The list of transactions
    transactions: []const StarTransaction,
};

/// This object represents a sticker.
/// Reference: https://core.telegram.org/bots/api#sticker
pub const Sticker = struct {
    /// Identifier for this file, which can be used to download or reuse the file
    file_id: []const u8,
    /// Unique identifier for this file, which is supposed to be the same over time and for different bots. Can't be used to download or reuse the file.
    file_unique_id: []const u8,
    /// Type of the sticker, currently one of "regular", "mask", "custom_emoji". The type of the sticker is independent from its format, which is determined by the fields is_animated and is_video.
    type: []const u8,
    /// Sticker width
    width: i64,
    /// Sticker height
    height: i64,
    /// True, if the sticker is animated
    is_animated: bool,
    /// True, if the sticker is a video sticker
    is_video: bool,
    /// Optional. Sticker thumbnail in the .WEBP or .JPG format
    thumbnail: ?PhotoSize = null,
    /// Optional. Emoji associated with the sticker
    emoji: ?[]const u8 = null,
    /// Optional. Name of the sticker set to which the sticker belongs
    set_name: ?[]const u8 = null,
    /// Optional. For premium regular stickers, premium animation for the sticker
    premium_animation: ?File = null,
    /// Optional. For mask stickers, the position where the mask should be placed
    mask_position: ?MaskPosition = null,
    /// Optional. For custom emoji stickers, unique identifier of the custom emoji
    custom_emoji_id: ?[]const u8 = null,
    /// Optional. True, if the sticker must be repainted to a text color in messages, the color of the Telegram Premium badge in emoji status, white color on chat photos, or another appropriate color in other places
    needs_repainting: ?bool = null,
    /// Optional. File size in bytes
    file_size: ?i64 = null,
};

/// This object represents a sticker set.
/// Reference: https://core.telegram.org/bots/api#stickerset
pub const StickerSet = struct {
    /// Sticker set name
    name: []const u8,
    /// Sticker set title
    title: []const u8,
    /// Type of stickers in the set, currently one of "regular", "mask", "custom_emoji"
    sticker_type: []const u8,
    /// List of all set stickers
    stickers: []const Sticker,
    /// Optional. Sticker set thumbnail in the .WEBP, .TGS, or .WEBM format
    thumbnail: ?PhotoSize = null,
};

/// This object represents a story.
/// Reference: https://core.telegram.org/bots/api#story
pub const Story = struct {
    /// Chat that posted the story
    chat: *const Chat,
    /// Unique identifier for the story in the chat
    id: i64,
};

/// Describes a clickable area on a story media.
/// Reference: https://core.telegram.org/bots/api#storyarea
pub const StoryArea = struct {
    /// Position of the area
    position: StoryAreaPosition,
    /// Type of the area
    type: StoryAreaType,
};

/// Describes the position of a clickable area within a story.
/// Reference: https://core.telegram.org/bots/api#storyareaposition
pub const StoryAreaPosition = struct {
    /// The abscissa of the area's center, as a percentage of the media width
    x_percentage: f64,
    /// The ordinate of the area's center, as a percentage of the media height
    y_percentage: f64,
    /// The width of the area's rectangle, as a percentage of the media width
    width_percentage: f64,
    /// The height of the area's rectangle, as a percentage of the media height
    height_percentage: f64,
    /// The clockwise rotation angle of the rectangle, in degrees; 0-360
    rotation_angle: f64,
    /// The radius of the rectangle corner rounding, as a percentage of the media width
    corner_radius_percentage: f64,
};

/// Describes the type of a clickable area on a story. Currently, it can be one of
/// - StoryAreaTypeLocation
/// - StoryAreaTypeSuggestedReaction
/// - StoryAreaTypeLink
/// - StoryAreaTypeWeather
/// - StoryAreaTypeUniqueGift
/// Reference: https://core.telegram.org/bots/api#storyareatype
pub const StoryAreaType = union(enum) {
    location: StoryAreaTypeLocation,
    suggested_reaction: StoryAreaTypeSuggestedReaction,
    link: StoryAreaTypeLink,
    weather: StoryAreaTypeWeather,
    unique_gift: StoryAreaTypeUniqueGift,

    pub fn jsonStringify(self: StoryAreaType, jw: anytype) !void {
        switch (self) {
            inline else => |payload| try jw.write(payload),
        }
    }

    pub fn writeMultipartJson(
        self: StoryAreaType,
        arena: Allocator,
        jw: *std.json.Stringify,
        pending_parts: *std.ArrayList(multipart_mod.PendingPart),
        comptime writeFn: anytype,
    ) !void {
        switch (self) {
            inline else => |payload| try writeFn(arena, jw, payload, pending_parts),
        }
    }

    pub fn jsonParse(
        allocator: Allocator,
        source: anytype,
        options: std.json.ParseOptions,
    ) std.json.ParseError(@TypeOf(source.*))!StoryAreaType {
        return json_mod.parseDiscriminatedUnion(
            StoryAreaType,
            "type",
            .{
                .{ "location", "location" },
                .{ "suggested_reaction", "suggested_reaction" },
                .{ "link", "link" },
                .{ "weather", "weather" },
                .{ "unique_gift", "unique_gift" },
            },
            allocator,
            source,
            options,
        );
    }
};

/// Describes a story area pointing to an HTTP or tg:// link. Currently, a story can have up to 3 link areas.
/// Reference: https://core.telegram.org/bots/api#storyareatypelink
pub const StoryAreaTypeLink = struct {
    /// Type of the area, always "link"
    type: []const u8 = "link",
    /// HTTP or tg:// URL to be opened when the area is clicked
    url: []const u8,
};

/// Describes a story area pointing to a location. Currently, a story can have up to 10 location areas.
/// Reference: https://core.telegram.org/bots/api#storyareatypelocation
pub const StoryAreaTypeLocation = struct {
    /// Type of the area, always "location"
    type: []const u8 = "location",
    /// Location latitude in degrees
    latitude: f64,
    /// Location longitude in degrees
    longitude: f64,
    /// Optional. Address of the location
    address: ?LocationAddress = null,
};

/// Describes a story area pointing to a suggested reaction. Currently, a story can have up to 5 suggested reaction areas.
/// Reference: https://core.telegram.org/bots/api#storyareatypesuggestedreaction
pub const StoryAreaTypeSuggestedReaction = struct {
    /// Type of the area, always "suggested_reaction"
    type: []const u8 = "suggested_reaction",
    /// Type of the reaction
    reaction_type: ReactionType,
    /// Optional. Pass True if the reaction area has a dark background
    is_dark: ?bool = null,
    /// Optional. Pass True if reaction area corner is flipped
    is_flipped: ?bool = null,
};

/// Describes a story area pointing to a unique gift. Currently, a story can have at most 1 unique gift area.
/// Reference: https://core.telegram.org/bots/api#storyareatypeuniquegift
pub const StoryAreaTypeUniqueGift = struct {
    /// Type of the area, always "unique_gift"
    type: []const u8 = "unique_gift",
    /// Unique name of the gift
    name: []const u8,
};

/// Describes a story area containing weather information. Currently, a story can have up to 3 weather areas.
/// Reference: https://core.telegram.org/bots/api#storyareatypeweather
pub const StoryAreaTypeWeather = struct {
    /// Type of the area, always "weather"
    type: []const u8 = "weather",
    /// Temperature, in degree Celsius
    temperature: f64,
    /// Emoji representing the weather
    emoji: []const u8,
    /// A color of the area background in the ARGB format
    background_color: i64,
};

/// This object contains basic information about a successful payment. Note that if the buyer initiates a chargeback with the relevant payment provider following this transaction, the funds may be debited from your balance. This is outside of Telegram's control.
/// Reference: https://core.telegram.org/bots/api#successfulpayment
pub const SuccessfulPayment = struct {
    /// Three-letter ISO 4217 currency code, or "XTR" for payments in Telegram Stars
    currency: []const u8,
    /// Total price in the smallest units of the currency (integer, not float/double). For example, for a price of US$ 1.45 pass amount = 145. See the exp parameter in currencies.json, it shows the number of digits past the decimal point for each currency (2 for the majority of currencies).
    total_amount: i64,
    /// Bot-specified invoice payload
    invoice_payload: []const u8,
    /// Telegram payment identifier
    telegram_payment_charge_id: []const u8,
    /// Provider payment identifier
    provider_payment_charge_id: []const u8,
    /// Optional. Expiration date of the subscription, in Unix time; for recurring payments only
    subscription_expiration_date: ?i64 = null,
    /// Optional. True, if the payment is a recurring payment for a subscription
    is_recurring: ?bool = null,
    /// Optional. True, if the payment is the first payment for a subscription
    is_first_recurring: ?bool = null,
    /// Optional. Identifier of the shipping option chosen by the user
    shipping_option_id: ?[]const u8 = null,
    /// Optional. Order information provided by the user
    order_info: ?OrderInfo = null,
};

/// Describes a service message about the failed approval of a suggested post. Currently, only caused by insufficient user funds at the time of approval.
/// Reference: https://core.telegram.org/bots/api#suggestedpostapprovalfailed
pub const SuggestedPostApprovalFailed = struct {
    /// Expected price of the post
    price: SuggestedPostPrice,
    /// Optional. Message containing the suggested post whose approval has failed. Note that the Message object in this field will not contain the reply_to_message field even if it itself is a reply.
    suggested_post_message: ?*const Message = null,
};

/// Describes a service message about the approval of a suggested post.
/// Reference: https://core.telegram.org/bots/api#suggestedpostapproved
pub const SuggestedPostApproved = struct {
    /// Date when the post will be published
    send_date: i64,
    /// Optional. Message containing the suggested post. Note that the Message object in this field will not contain the reply_to_message field even if it itself is a reply.
    suggested_post_message: ?*const Message = null,
    /// Optional. Amount paid for the post
    price: ?SuggestedPostPrice = null,
};

/// Describes a service message about the rejection of a suggested post.
/// Reference: https://core.telegram.org/bots/api#suggestedpostdeclined
pub const SuggestedPostDeclined = struct {
    /// Optional. Message containing the suggested post. Note that the Message object in this field will not contain the reply_to_message field even if it itself is a reply.
    suggested_post_message: ?*const Message = null,
    /// Optional. Comment with which the post was declined
    comment: ?[]const u8 = null,
};

/// Contains information about a suggested post.
/// Reference: https://core.telegram.org/bots/api#suggestedpostinfo
pub const SuggestedPostInfo = struct {
    /// State of the suggested post. Currently, it can be one of "pending", "approved", "declined".
    state: []const u8,
    /// Optional. Proposed price of the post. If the field is omitted, then the post is unpaid.
    price: ?SuggestedPostPrice = null,
    /// Optional. Proposed send date of the post. If the field is omitted, then the post can be published at any time within 30 days at the sole discretion of the user or administrator who approves it.
    send_date: ?i64 = null,
};

/// Describes a service message about a successful payment for a suggested post.
/// Reference: https://core.telegram.org/bots/api#suggestedpostpaid
pub const SuggestedPostPaid = struct {
    /// Currency in which the payment was made. Currently, one of "XTR" for Telegram Stars or "TON" for TON grams.
    currency: []const u8,
    /// Optional. Message containing the suggested post. Note that the Message object in this field will not contain the reply_to_message field even if it itself is a reply.
    suggested_post_message: ?*const Message = null,
    /// Optional. The amount of the currency that was received by the channel in nanograms; for payments in TON grams only
    amount: ?i64 = null,
    /// Optional. The amount of Telegram Stars that was received by the channel; for payments in Telegram Stars only
    star_amount: ?StarAmount = null,
};

/// Contains parameters of a post that is being suggested by the bot.
/// Reference: https://core.telegram.org/bots/api#suggestedpostparameters
pub const SuggestedPostParameters = struct {
    /// Optional. Proposed price for the post. If the field is omitted, then the post is unpaid.
    price: ?SuggestedPostPrice = null,
    /// Optional. Proposed send date of the post. If specified, then the date must be between 300 second and 2678400 seconds (30 days) in the future. If the field is omitted, then the post can be published at any time within 30 days at the sole discretion of the user who approves it.
    send_date: ?i64 = null,
};

/// Describes the price of a suggested post.
/// Reference: https://core.telegram.org/bots/api#suggestedpostprice
pub const SuggestedPostPrice = struct {
    /// Currency in which the post will be paid. Currently, must be one of "XTR" for Telegram Stars or "TON" for TON grams.
    currency: []const u8 = "one",
    /// The amount of the currency that will be paid for the post in the smallest units of the currency, i.e. Telegram Stars or nanograms. Currently, price in Telegram Stars must be between 5 and 100000, and price in nanograms must be between 10000000 and 10000000000000.
    amount: i64,
};

/// Describes a service message about a payment refund for a suggested post.
/// Reference: https://core.telegram.org/bots/api#suggestedpostrefunded
pub const SuggestedPostRefunded = struct {
    /// Reason for the refund. Currently, one of "post_deleted" if the post was deleted within 24 hours of being posted or removed from scheduled messages without being posted, or "payment_refunded" if the payer refunded their payment.
    reason: []const u8,
    /// Optional. Message containing the suggested post. Note that the Message object in this field will not contain the reply_to_message field even if it itself is a reply.
    suggested_post_message: ?*const Message = null,
};

/// This object represents an inline button that switches the current user to inline mode in a chosen chat, with an optional default inline query.
/// Reference: https://core.telegram.org/bots/api#switchinlinequerychosenchat
pub const SwitchInlineQueryChosenChat = struct {
    /// Optional. The default inline query to be inserted in the input field. If left empty, only the bot's username will be inserted.
    query: ?[]const u8 = null,
    /// Optional. True, if private chats with users can be chosen
    allow_user_chats: ?bool = null,
    /// Optional. True, if private chats with bots can be chosen
    allow_bot_chats: ?bool = null,
    /// Optional. True, if group and supergroup chats can be chosen
    allow_group_chats: ?bool = null,
    /// Optional. True, if channel chats can be chosen
    allow_channel_chats: ?bool = null,
};

/// This object contains information about the quoted part of a message that is replied to by the given message.
/// Reference: https://core.telegram.org/bots/api#textquote
pub const TextQuote = struct {
    /// Text of the quoted part of a message that is replied to by the given message
    text: []const u8,
    /// Approximate quote position in the original message in UTF-16 code units as specified by the sender
    position: i64,
    /// Optional. Special entities that appear in the quote. Currently, only bold, italic, underline, strikethrough, spoiler, custom_emoji, and date_time entities are kept in quotes.
    entities: ?[]const MessageEntity = null,
    /// Optional. True, if the quote was chosen manually by the message sender. Otherwise, the quote was added automatically by the server.
    is_manual: ?bool = null,
};

/// This object describes the source of a transaction, or its recipient for outgoing transactions. Currently, it can be one of
/// - TransactionPartnerUser
/// - TransactionPartnerChat
/// - TransactionPartnerAffiliateProgram
/// - TransactionPartnerFragment
/// - TransactionPartnerTelegramAds
/// - TransactionPartnerTelegramApi
/// - TransactionPartnerOther
/// Reference: https://core.telegram.org/bots/api#transactionpartner
pub const TransactionPartner = union(enum) {
    user: TransactionPartnerUser,
    chat: TransactionPartnerChat,
    affiliate_program: TransactionPartnerAffiliateProgram,
    fragment: TransactionPartnerFragment,
    telegram_ads: TransactionPartnerTelegramAds,
    telegram_api: TransactionPartnerTelegramApi,
    other: TransactionPartnerOther,

    pub fn jsonStringify(self: TransactionPartner, jw: anytype) !void {
        switch (self) {
            inline else => |payload| try jw.write(payload),
        }
    }

    pub fn writeMultipartJson(
        self: TransactionPartner,
        arena: Allocator,
        jw: *std.json.Stringify,
        pending_parts: *std.ArrayList(multipart_mod.PendingPart),
        comptime writeFn: anytype,
    ) !void {
        switch (self) {
            inline else => |payload| try writeFn(arena, jw, payload, pending_parts),
        }
    }

    pub fn jsonParse(
        allocator: Allocator,
        source: anytype,
        options: std.json.ParseOptions,
    ) std.json.ParseError(@TypeOf(source.*))!TransactionPartner {
        return json_mod.parseDiscriminatedUnion(
            TransactionPartner,
            "type",
            .{
                .{ "user", "user" },
                .{ "chat", "chat" },
                .{ "affiliate_program", "affiliate_program" },
                .{ "fragment", "fragment" },
                .{ "telegram_ads", "telegram_ads" },
                .{ "telegram_api", "telegram_api" },
                .{ "other", "other" },
            },
            allocator,
            source,
            options,
        );
    }
};

/// Describes the affiliate program that issued the affiliate commission received via this transaction.
/// Reference: https://core.telegram.org/bots/api#transactionpartneraffiliateprogram
pub const TransactionPartnerAffiliateProgram = struct {
    /// Type of the transaction partner, always "affiliate_program"
    type: []const u8 = "affiliate_program",
    /// The number of Telegram Stars received by the bot for each 1000 Telegram Stars received by the affiliate program sponsor from referred users
    commission_per_mille: i64,
    /// Optional. Information about the bot that sponsored the affiliate program
    sponsor_user: ?User = null,
};

/// Describes a transaction with a chat.
/// Reference: https://core.telegram.org/bots/api#transactionpartnerchat
pub const TransactionPartnerChat = struct {
    /// Type of the transaction partner, always "chat"
    type: []const u8 = "chat",
    /// Information about the chat
    chat: *const Chat,
    /// Optional. The gift sent to the chat by the bot
    gift: ?Gift = null,
};

/// Describes a withdrawal transaction with Fragment.
/// Reference: https://core.telegram.org/bots/api#transactionpartnerfragment
pub const TransactionPartnerFragment = struct {
    /// Type of the transaction partner, always "fragment"
    type: []const u8 = "fragment",
    /// Optional. State of the transaction if the transaction is outgoing
    withdrawal_state: ?RevenueWithdrawalState = null,
};

/// Describes a transaction with an unknown source or recipient.
/// Reference: https://core.telegram.org/bots/api#transactionpartnerother
pub const TransactionPartnerOther = struct {
    /// Type of the transaction partner, always "other"
    type: []const u8 = "other",
};

/// Describes a withdrawal transaction to the Telegram Ads platform.
/// Reference: https://core.telegram.org/bots/api#transactionpartnertelegramads
pub const TransactionPartnerTelegramAds = struct {
    /// Type of the transaction partner, always "telegram_ads"
    type: []const u8 = "telegram_ads",
};

/// Describes a transaction with payment for paid broadcasting.
/// Reference: https://core.telegram.org/bots/api#transactionpartnertelegramapi
pub const TransactionPartnerTelegramApi = struct {
    /// Type of the transaction partner, always "telegram_api"
    type: []const u8 = "telegram_api",
    /// The number of successful requests that exceeded regular limits and were therefore billed
    request_count: i64,
};

/// Describes a transaction with a user.
/// Reference: https://core.telegram.org/bots/api#transactionpartneruser
pub const TransactionPartnerUser = struct {
    /// Type of the transaction partner, always "user"
    type: []const u8 = "user",
    /// Type of the transaction, currently one of "invoice_payment" for payments via invoices, "paid_media_payment" for payments for paid media, "gift_purchase" for gifts sent by the bot, "premium_purchase" for Telegram Premium subscriptions gifted by the bot, "business_account_transfer" for direct transfers from managed business accounts
    transaction_type: []const u8,
    /// Information about the user
    user: User,
    /// Optional. Information about the affiliate that received a commission via this transaction. Can be available only for "invoice_payment" and "paid_media_payment" transactions.
    affiliate: ?AffiliateInfo = null,
    /// Optional. Bot-specified invoice payload. Can be available only for "invoice_payment" transactions.
    invoice_payload: ?[]const u8 = null,
    /// Optional. The duration of the paid subscription. Can be available only for "invoice_payment" transactions.
    subscription_period: ?i64 = null,
    /// Optional. Information about the paid media bought by the user; for "paid_media_payment" transactions only
    paid_media: ?[]const PaidMedia = null,
    /// Optional. Bot-specified paid media payload. Can be available only for "paid_media_payment" transactions.
    paid_media_payload: ?[]const u8 = null,
    /// Optional. The gift sent to the user by the bot; for "gift_purchase" transactions only
    gift: ?Gift = null,
    /// Optional. Number of months the gifted Telegram Premium subscription will be active for; for "premium_purchase" transactions only
    premium_subscription_duration: ?i64 = null,
};

/// This object describes a unique gift that was upgraded from a regular gift.
/// Reference: https://core.telegram.org/bots/api#uniquegift
pub const UniqueGift = struct {
    /// Identifier of the regular gift from which the gift was upgraded
    gift_id: []const u8,
    /// Human-readable name of the regular gift from which this unique gift was upgraded
    base_name: []const u8,
    /// Unique name of the gift. This name can be used in https://t.me/nft/... links and story areas.
    name: []const u8,
    /// Unique number of the upgraded gift among gifts upgraded from the same regular gift
    number: i64,
    /// Model of the gift
    model: UniqueGiftModel,
    /// Symbol of the gift
    symbol: UniqueGiftSymbol,
    /// Backdrop of the gift
    backdrop: UniqueGiftBackdrop,
    /// Optional. True, if the original regular gift was exclusively purchaseable by Telegram Premium subscribers
    is_premium: ?bool = null,
    /// Optional. True, if the gift was used to craft another gift and isn't available anymore
    is_burned: ?bool = null,
    /// Optional. True, if the gift is assigned from the TON blockchain and can't be resold or transferred in Telegram
    is_from_blockchain: ?bool = null,
    /// Optional. The color scheme that can be used by the gift's owner for the chat's name, replies to messages and link previews; for business account gifts and gifts that are currently on sale only
    colors: ?UniqueGiftColors = null,
    /// Optional. Information about the chat that published the gift
    publisher_chat: ?*const Chat = null,
};

/// This object describes the backdrop of a unique gift.
/// Reference: https://core.telegram.org/bots/api#uniquegiftbackdrop
pub const UniqueGiftBackdrop = struct {
    /// Name of the backdrop
    name: []const u8,
    /// Colors of the backdrop
    colors: UniqueGiftBackdropColors,
    /// The number of unique gifts that receive this backdrop for every 1000 gifts upgraded
    rarity_per_mille: i64,
};

/// This object describes the colors of the backdrop of a unique gift.
/// Reference: https://core.telegram.org/bots/api#uniquegiftbackdropcolors
pub const UniqueGiftBackdropColors = struct {
    /// The color in the center of the backdrop in RGB format
    center_color: i64,
    /// The color on the edges of the backdrop in RGB format
    edge_color: i64,
    /// The color to be applied to the symbol in RGB format
    symbol_color: i64,
    /// The color for the text on the backdrop in RGB format
    text_color: i64,
};

/// This object contains information about the color scheme for a user's name, message replies and link previews based on a unique gift.
/// Reference: https://core.telegram.org/bots/api#uniquegiftcolors
pub const UniqueGiftColors = struct {
    /// Custom emoji identifier of the unique gift's model
    model_custom_emoji_id: []const u8,
    /// Custom emoji identifier of the unique gift's symbol
    symbol_custom_emoji_id: []const u8,
    /// Main color used in light themes; RGB format
    light_theme_main_color: i64,
    /// List of 1-3 additional colors used in light themes; RGB format
    light_theme_other_colors: []const i64,
    /// Main color used in dark themes; RGB format
    dark_theme_main_color: i64,
    /// List of 1-3 additional colors used in dark themes; RGB format
    dark_theme_other_colors: []const i64,
};

/// Describes a service message about a unique gift that was sent or received.
/// Reference: https://core.telegram.org/bots/api#uniquegiftinfo
pub const UniqueGiftInfo = struct {
    /// Information about the gift
    gift: UniqueGift,
    /// Origin of the gift. Currently, either "upgrade" for gifts upgraded from regular gifts, "transfer" for gifts transferred from other users or channels, "resale" for gifts bought from other users, "gifted_upgrade" for upgrades purchased after the gift was sent, or "offer" for gifts bought or sold through gift purchase offers.
    origin: []const u8,
    /// Optional. Text of the message that was added to the gift
    text: ?[]const u8 = null,
    /// Optional. Special entities that appear in the text
    entities: ?[]const MessageEntity = null,
    /// Optional. True, if the sender and gift text are shown only to the gift receiver; otherwise, everyone will be able to see them
    is_private: ?bool = null,
    /// Optional. For gifts bought from other users, the currency in which the payment for the gift was done. Currently, one of "XTR" for Telegram Stars or "TON" for TON grams.
    last_resale_currency: ?[]const u8 = null,
    /// Optional. For gifts bought from other users, the price paid for the gift in either Telegram Stars or nanograms
    last_resale_amount: ?i64 = null,
    /// Optional. Unique identifier of the received gift for the bot; only present for gifts received on behalf of business accounts
    owned_gift_id: ?[]const u8 = null,
    /// Optional. Number of Telegram Stars that must be paid to transfer the gift; omitted if the bot cannot transfer the gift
    transfer_star_count: ?i64 = null,
    /// Optional. Point in time (Unix timestamp) when the gift can be transferred. If it is in the past, then the gift can be transferred now.
    next_transfer_date: ?i64 = null,
};

/// This object describes the model of a unique gift.
/// Reference: https://core.telegram.org/bots/api#uniquegiftmodel
pub const UniqueGiftModel = struct {
    /// Name of the model
    name: []const u8,
    /// The sticker that represents the unique gift
    sticker: Sticker,
    /// The number of unique gifts that receive this model for every 1000 gift upgrades. Always 0 for crafted gifts.
    rarity_per_mille: i64,
    /// Optional. Rarity of the model if it is a crafted model. Currently, can be "uncommon", "rare", "epic", or "legendary".
    rarity: ?[]const u8 = null,
};

/// This object describes the symbol shown on the pattern of a unique gift.
/// Reference: https://core.telegram.org/bots/api#uniquegiftsymbol
pub const UniqueGiftSymbol = struct {
    /// Name of the symbol
    name: []const u8,
    /// The sticker that represents the unique gift
    sticker: Sticker,
    /// The number of unique gifts that receive this model for every 1000 gifts upgraded
    rarity_per_mille: i64,
};

/// This object represents an incoming update.
/// At most one of the optional fields can be present in any given update.
/// Reference: https://core.telegram.org/bots/api#update
pub const Update = struct {
    /// The update's unique identifier. Update identifiers start from a certain positive number and increase sequentially. This identifier becomes especially handy if you're using webhooks, since it allows you to ignore repeated updates or to restore the correct update sequence, should they get out of order. If there are no new updates for at least a week, then identifier of the next update will be chosen randomly instead of sequentially.
    update_id: i64,
    /// Optional. New incoming message of any kind - text, photo, sticker, etc.
    message: ?*const Message = null,
    /// Optional. New version of a message that is known to the bot and was edited. This update may at times be triggered by changes to message fields that are either unavailable or not actively used by your bot.
    edited_message: ?*const Message = null,
    /// Optional. New incoming channel post of any kind - text, photo, sticker, etc.
    channel_post: ?*const Message = null,
    /// Optional. New version of a channel post that is known to the bot and was edited. This update may at times be triggered by changes to message fields that are either unavailable or not actively used by your bot.
    edited_channel_post: ?*const Message = null,
    /// Optional. The bot was connected to or disconnected from a business account, or a user edited an existing connection with the bot
    business_connection: ?BusinessConnection = null,
    /// Optional. New message from a connected business account
    business_message: ?*const Message = null,
    /// Optional. New version of a message from a connected business account
    edited_business_message: ?*const Message = null,
    /// Optional. Messages were deleted from a connected business account
    deleted_business_messages: ?BusinessMessagesDeleted = null,
    /// Optional. New guest message. The bot can use the field Message.guest_query_id and the method answerGuestQuery to send a message in response.
    guest_message: ?*const Message = null,
    /// Optional. A reaction to a message was changed by a user. The bot must be an administrator in the chat and must explicitly specify "message_reaction" in the list of allowed_updates to receive these updates. The update isn't received for reactions set by bots.
    message_reaction: ?MessageReactionUpdated = null,
    /// Optional. Reactions to a message with anonymous reactions were changed. The bot must be an administrator in the chat and must explicitly specify "message_reaction_count" in the list of allowed_updates to receive these updates. The updates are grouped and can be sent with delay up to a few minutes.
    message_reaction_count: ?MessageReactionCountUpdated = null,
    /// Optional. New incoming inline query
    inline_query: ?InlineQuery = null,
    /// Optional. The result of an inline query that was chosen by a user and sent to their chat partner. Please see our documentation on the feedback collecting for details on how to enable these updates for your bot.
    chosen_inline_result: ?ChosenInlineResult = null,
    /// Optional. New incoming callback query
    callback_query: ?CallbackQuery = null,
    /// Optional. New incoming shipping query. Only for invoices with flexible price.
    shipping_query: ?ShippingQuery = null,
    /// Optional. New incoming pre-checkout query. Contains full information about checkout.
    pre_checkout_query: ?PreCheckoutQuery = null,
    /// Optional. A user purchased paid media with a non-empty payload sent by the bot in a non-channel chat
    purchased_paid_media: ?PaidMediaPurchased = null,
    /// Optional. New poll state. Bots receive only updates about manually stopped polls and polls, which are sent by the bot.
    poll: ?Poll = null,
    /// Optional. A user changed their answer in a non-anonymous poll. Bots receive new votes only in polls that were sent by the bot itself.
    poll_answer: ?PollAnswer = null,
    /// Optional. The bot's chat member status was updated in a chat. For private chats, this update is received only when the bot is blocked or unblocked by the user.
    my_chat_member: ?ChatMemberUpdated = null,
    /// Optional. A chat member's status was updated in a chat. The bot must be an administrator in the chat and must explicitly specify "chat_member" in the list of allowed_updates to receive these updates.
    chat_member: ?ChatMemberUpdated = null,
    /// Optional. A request to join the chat has been sent. The bot must have the can_invite_users administrator right in the chat to receive these updates.
    chat_join_request: ?ChatJoinRequest = null,
    /// Optional. A chat boost was added or changed. The bot must be an administrator in the chat to receive these updates.
    chat_boost: ?ChatBoostUpdated = null,
    /// Optional. A boost was removed from a chat. The bot must be an administrator in the chat to receive these updates.
    removed_chat_boost: ?ChatBoostRemoved = null,
    /// Optional. A new bot was created to be managed by the bot, or token or owner of a managed bot was changed
    managed_bot: ?ManagedBotUpdated = null,
    /// Optional. User payment subscription has changed
    subscription: ?BotSubscriptionUpdated = null,
    /// Optional. A user asked the bot to stop the generation of a message
    stopped_message_generation: ?MessageGenerationStopped = null,
};

/// This object represents a Telegram user or bot.
/// Reference: https://core.telegram.org/bots/api#user
pub const User = struct {
    /// Unique identifier for this user or bot. This number may have more than 32 significant bits and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a 64-bit integer or double-precision float type are safe for storing this identifier.
    id: i64,
    /// True, if this user is a bot
    is_bot: bool,
    /// User's or bot's first name
    first_name: []const u8,
    /// Optional. User's or bot's last name
    last_name: ?[]const u8 = null,
    /// Optional. User's or bot's username
    username: ?[]const u8 = null,
    /// Optional. IETF language tag of the user's language
    language_code: ?[]const u8 = null,
    /// Optional. True, if this user is a Telegram Premium user
    is_premium: ?bool = null,
    /// Optional. True, if this user added the bot to the attachment menu
    added_to_attachment_menu: ?bool = null,
    /// Optional. True, if the bot can be invited to groups. Returned only in getMe.
    can_join_groups: ?bool = null,
    /// Optional. True, if privacy mode is disabled for the bot. Returned only in getMe.
    can_read_all_group_messages: ?bool = null,
    /// Optional. True, if the bot supports guest queries from chats it is not a member of. Returned only in getMe.
    supports_guest_queries: ?bool = null,
    /// Optional. True, if the bot supports inline queries. Returned only in getMe.
    supports_inline_queries: ?bool = null,
    /// Optional. True, if the bot can be connected to a user account to manage it. Returned only in getMe.
    can_connect_to_business: ?bool = null,
    /// Optional. True, if the bot has a main Web App. Returned only in getMe.
    has_main_web_app: ?bool = null,
    /// Optional. True, if the bot has forum topic mode enabled in private chats. Returned only in getMe.
    has_topics_enabled: ?bool = null,
    /// Optional. True, if the bot allows users to create and delete topics in private chats. Returned only in getMe.
    allows_users_to_create_topics: ?bool = null,
    /// Optional. True, if other bots can be created to be controlled by the bot. Returned only in getMe.
    can_manage_bots: ?bool = null,
    /// Optional. True, if the bot supports join request queries and can be assigned to process them. Returned only in getMe.
    supports_join_request_queries: ?bool = null,
};

/// This object represents a list of boosts added to a chat by a user.
/// Reference: https://core.telegram.org/bots/api#userchatboosts
pub const UserChatBoosts = struct {
    /// The list of boosts added to the chat by the user
    boosts: []const ChatBoost,
};

/// This object represents the audios displayed on a user's profile.
/// Reference: https://core.telegram.org/bots/api#userprofileaudios
pub const UserProfileAudios = struct {
    /// Total number of profile audios for the target user
    total_count: i64,
    /// Requested profile audios
    audios: []const Audio,
};

/// This object represent a user's profile pictures.
/// Reference: https://core.telegram.org/bots/api#userprofilephotos
pub const UserProfilePhotos = struct {
    /// Total number of profile pictures the target user has
    total_count: i64,
    /// Requested profile pictures (in up to 4 sizes each)
    photos: []const []const PhotoSize,
};

/// This object describes the rating of a user based on their Telegram Star spendings.
/// Reference: https://core.telegram.org/bots/api#userrating
pub const UserRating = struct {
    /// Current level of the user, indicating their reliability when purchasing digital goods and services. A higher level suggests a more trustworthy customer; a negative level is likely reason for concern.
    level: i64,
    /// Numerical value of the user's rating; the higher the rating, the better
    rating: i64,
    /// The rating value required to get the current level
    current_level_rating: i64,
    /// Optional. The rating value required to get to the next level; omitted if the maximum level was reached
    next_level_rating: ?i64 = null,
};

/// This object contains information about the users whose identifiers were shared with the bot using a KeyboardButtonRequestUsers button.
/// Reference: https://core.telegram.org/bots/api#usersshared
pub const UsersShared = struct {
    /// Identifier of the request
    request_id: i64,
    /// Information about users shared with the bot
    users: []const SharedUser,
};

/// This object represents a venue.
/// Reference: https://core.telegram.org/bots/api#venue
pub const Venue = struct {
    /// Venue location. Can't be a live location.
    location: Location,
    /// Name of the venue
    title: []const u8,
    /// Address of the venue
    address: []const u8,
    /// Optional. Foursquare identifier of the venue
    foursquare_id: ?[]const u8 = null,
    /// Optional. Foursquare type of the venue. (For example, "arts_entertainment/default", "arts_entertainment/aquarium" or "food/icecream".)
    foursquare_type: ?[]const u8 = null,
    /// Optional. Google Places identifier of the venue
    google_place_id: ?[]const u8 = null,
    /// Optional. Google Places type of the venue. (See supported types.)
    google_place_type: ?[]const u8 = null,
};

/// This object represents a video file.
/// Reference: https://core.telegram.org/bots/api#video
pub const Video = struct {
    /// Identifier for this file, which can be used to download or reuse the file
    file_id: []const u8,
    /// Unique identifier for this file, which is supposed to be the same over time and for different bots. Can't be used to download or reuse the file.
    file_unique_id: []const u8,
    /// Video width as defined by the sender
    width: i64,
    /// Video height as defined by the sender
    height: i64,
    /// Duration of the video in seconds as defined by the sender
    duration: i64,
    /// Optional. Video thumbnail
    thumbnail: ?PhotoSize = null,
    /// Optional. Available sizes of the cover of the video in the message
    cover: ?[]const PhotoSize = null,
    /// Optional. Timestamp in seconds from which the video will play in the message
    start_timestamp: ?i64 = null,
    /// Optional. List of available qualities of the video
    qualities: ?[]const VideoQuality = null,
    /// Optional. Original filename as defined by the sender
    file_name: ?[]const u8 = null,
    /// Optional. MIME type of the file as defined by the sender
    mime_type: ?[]const u8 = null,
    /// Optional. File size in bytes. It can be bigger than 2^31 and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a signed 64-bit integer or double-precision float type are safe for storing this value.
    file_size: ?i64 = null,
};

/// This object represents a service message about a video chat ended in the chat.
/// Reference: https://core.telegram.org/bots/api#videochatended
pub const VideoChatEnded = struct {
    /// Video chat duration in seconds
    duration: i64,
};

/// This object represents a service message about new members invited to a video chat.
/// Reference: https://core.telegram.org/bots/api#videochatparticipantsinvited
pub const VideoChatParticipantsInvited = struct {
    /// New members that were invited to the video chat
    users: []const User,
};

/// This object represents a service message about a video chat scheduled in the chat.
/// Reference: https://core.telegram.org/bots/api#videochatscheduled
pub const VideoChatScheduled = struct {
    /// Point in time (Unix timestamp) when the video chat is supposed to be started by a chat administrator
    start_date: i64,
};

/// This object represents a service message about a video chat started in the chat. Currently holds no information.
/// Reference: https://core.telegram.org/bots/api#videochatstarted
pub const VideoChatStarted = struct {};

/// This object represents a video message.
/// Reference: https://core.telegram.org/bots/api#videonote
pub const VideoNote = struct {
    /// Identifier for this file, which can be used to download or reuse the file
    file_id: []const u8,
    /// Unique identifier for this file, which is supposed to be the same over time and for different bots. Can't be used to download or reuse the file.
    file_unique_id: []const u8,
    /// Video width and height (diameter of the video message) as defined by the sender
    length: i64,
    /// Duration of the video in seconds as defined by the sender
    duration: i64,
    /// Optional. Video thumbnail
    thumbnail: ?PhotoSize = null,
    /// Optional. File size in bytes
    file_size: ?i64 = null,
};

/// This object represents a video file of a specific quality.
/// Reference: https://core.telegram.org/bots/api#videoquality
pub const VideoQuality = struct {
    /// Identifier for this file, which can be used to download or reuse the file
    file_id: []const u8,
    /// Unique identifier for this file, which is supposed to be the same over time and for different bots. Can't be used to download or reuse the file.
    file_unique_id: []const u8,
    /// Video width
    width: i64,
    /// Video height
    height: i64,
    /// Codec that was used to encode the video, for example, "h264", "h265", or "av01"
    codec: []const u8,
    /// Optional. File size in bytes. It can be bigger than 2^31 and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a signed 64-bit integer or double-precision float type are safe for storing this value.
    file_size: ?i64 = null,
};

/// This object represents a voice note.
/// Reference: https://core.telegram.org/bots/api#voice
pub const Voice = struct {
    /// Identifier for this file, which can be used to download or reuse the file
    file_id: []const u8,
    /// Unique identifier for this file, which is supposed to be the same over time and for different bots. Can't be used to download or reuse the file.
    file_unique_id: []const u8,
    /// Duration of the audio in seconds as defined by the sender
    duration: i64,
    /// Optional. MIME type of the file as defined by the sender
    mime_type: ?[]const u8 = null,
    /// Optional. File size in bytes. It can be bigger than 2^31 and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a signed 64-bit integer or double-precision float type are safe for storing this value.
    file_size: ?i64 = null,
};

/// Describes data sent from a Web App to the bot.
/// Reference: https://core.telegram.org/bots/api#webappdata
pub const WebAppData = struct {
    /// The data. Be aware that a bad client can send arbitrary data in this field.
    data: []const u8,
    /// Text of the web_app keyboard button from which the Web App was opened. Be aware that a bad client can send arbitrary data in this field.
    button_text: []const u8,
};

/// Describes a Web App.
/// Reference: https://core.telegram.org/bots/api#webappinfo
pub const WebAppInfo = struct {
    /// An HTTPS URL of a Web App to be opened with additional data as specified in Initializing Web Apps
    url: []const u8,
};

/// Describes the current status of a webhook.
/// Reference: https://core.telegram.org/bots/api#webhookinfo
pub const WebhookInfo = struct {
    /// Webhook URL, may be empty if webhook is not set up
    url: []const u8,
    /// True, if a custom certificate was provided for webhook certificate checks
    has_custom_certificate: bool,
    /// Number of updates awaiting delivery
    pending_update_count: i64,
    /// Optional. Currently used webhook IP address
    ip_address: ?[]const u8 = null,
    /// Optional. Unix time for the most recent error that happened when trying to deliver an update via webhook
    last_error_date: ?i64 = null,
    /// Optional. Error message in human-readable format for the most recent error that happened when trying to deliver an update via webhook
    last_error_message: ?[]const u8 = null,
    /// Optional. Unix time of the most recent error that happened when trying to synchronize available updates with Telegram datacenters
    last_synchronization_error_date: ?i64 = null,
    /// Optional. The maximum allowed number of simultaneous HTTPS connections to the webhook for update delivery
    max_connections: ?i64 = null,
    /// Optional. A list of update types the bot is subscribed to. Defaults to all update types except chat_member, message_reaction, and message_reaction_count.
    allowed_updates: ?[]const []const u8 = null,
};

/// This object represents a service message about a user allowing a bot to write messages after adding it to the attachment menu, launching a Web App from a link, or accepting an explicit request from a Web App sent by the method requestWriteAccess.
/// Reference: https://core.telegram.org/bots/api#writeaccessallowed
pub const WriteAccessAllowed = struct {
    /// Optional. True, if the access was granted after the user accepted an explicit request from a Web App sent by the method requestWriteAccess
    from_request: ?bool = null,
    /// Optional. Name of the Web App, if the access was granted when the Web App was launched from a link
    web_app_name: ?[]const u8 = null,
    /// Optional. True, if the access was granted when the bot was added to the attachment or side menu
    from_attachment_menu: ?bool = null,
};
