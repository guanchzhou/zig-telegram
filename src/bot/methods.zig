//! Telegram Bot API 10.3 (August 24, 2026) method parameter structs and metadata (185 methods).
//!
//! Generated deterministically from `spec/bot_api_10_3.json` by `tools/gen_bot_api.zig`.

const std = @import("std");
pub const types = @import("types.zig");
pub const ChatId = types.ChatId;
pub const InputFile = types.InputFile;
pub const ObjectOrBool = types.ObjectOrBool;
pub const ReplyMarkup = types.ReplyMarkup;

pub const spec_version = "Bot API 10.3";
pub const spec_release_date = "August 24, 2026";
pub const method_count: usize = 185;

/// Use this method to add a new sticker to a set created by the bot. Emoji sticker sets can have up to 200 stickers. Other sticker sets can have up to 120 stickers. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#addstickertoset
pub const AddStickerToSet = struct {
    pub const api_method_name = "addStickerToSet";
    pub const ReturnType = bool;

    /// User identifier of sticker set owner
    user_id: i64,
    /// Sticker set name
    name: []const u8,
    /// A JSON-serialized object with information about the added sticker. If exactly the same sticker had already been added to the set, then the set isn't changed.
    sticker: types.InputSticker,
};

/// Use this method to send answers to callback queries sent from inline keyboards. The answer will be displayed to the user as a notification at the top of the chat screen or as an alert. On success, True is returned.
/// Reference: https://core.telegram.org/bots/api#answercallbackquery
pub const AnswerCallbackQuery = struct {
    pub const api_method_name = "answerCallbackQuery";
    pub const ReturnType = bool;

    /// Unique identifier for the query to be answered
    callback_query_id: []const u8,
    /// Text of the notification. If not specified, nothing will be shown to the user, 0-200 characters.
    text: ?[]const u8 = null,
    /// If True, an alert will be shown by the client instead of a notification at the top of the chat screen. Defaults to False.
    show_alert: ?bool = null,
    /// URL that will be opened by the user's client. If you have created a Game and accepted the conditions via @BotFather, specify the URL that opens your game - note that this will only work if the query comes from a callback_game button. Otherwise, you may use links like t.me/your_bot?start=XXXX that open your bot with a parameter.
    url: ?[]const u8 = null,
    /// The maximum amount of time in seconds that the result of the callback query may be cached client-side. Defaults to 0.
    cache_time: ?i64 = null,
};

/// Use this method to process a received chat join request query. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#answerchatjoinrequestquery
pub const AnswerChatJoinRequestQuery = struct {
    pub const api_method_name = "answerChatJoinRequestQuery";
    pub const ReturnType = bool;

    /// Unique identifier of the join request query
    chat_join_request_query_id: []const u8,
    /// Result of the query. Must be either "approve" to allow the user to join the chat, "decline" to disallow the user to join the chat, or "queue" to leave the decision to other administrators.
    result: []const u8,
};

/// Use this method to reply to a received guest message. On success, a SentGuestMessage object is returned.
/// Reference: https://core.telegram.org/bots/api#answerguestquery
pub const AnswerGuestQuery = struct {
    pub const api_method_name = "answerGuestQuery";
    pub const ReturnType = types.SentGuestMessage;

    /// Unique identifier for the query to be answered
    guest_query_id: []const u8,
    /// A JSON-serialized object describing the message to be sent
    result: types.InlineQueryResult,
};

/// Use this method to send answers to an inline query. On success, True is returned.
/// No more than 50 results per query are allowed.
/// Reference: https://core.telegram.org/bots/api#answerinlinequery
pub const AnswerInlineQuery = struct {
    pub const api_method_name = "answerInlineQuery";
    pub const ReturnType = bool;

    /// Unique identifier for the answered query
    inline_query_id: []const u8,
    /// A JSON-serialized Array of results for the inline query
    results: []const types.InlineQueryResult,
    /// The maximum amount of time in seconds that the result of the inline query may be cached on the server. Defaults to 300.
    cache_time: ?i64 = null,
    /// Pass True if results may be cached on the server side only for the user that sent the query. By default, results may be returned to any user who sends the same query.
    is_personal: ?bool = null,
    /// Pass the offset that a client should send in the next query with the same text to receive more results. Pass an empty string if there are no more results or if you don't support pagination. Offset length can't exceed 64 bytes.
    next_offset: ?[]const u8 = null,
    /// A JSON-serialized object describing a button to be shown above inline query results
    button: ?types.InlineQueryResultsButton = null,
};

/// Once the user has confirmed their payment and shipping details, the Bot API sends the final confirmation in the form of an Update with the field pre_checkout_query. Use this method to respond to such pre-checkout queries. On success, True is returned. Note: The Bot API must receive an answer within 10 seconds after the pre-checkout query was sent.
/// Reference: https://core.telegram.org/bots/api#answerprecheckoutquery
pub const AnswerPreCheckoutQuery = struct {
    pub const api_method_name = "answerPreCheckoutQuery";
    pub const ReturnType = bool;

    /// Unique identifier for the query to be answered
    pre_checkout_query_id: []const u8,
    /// Specify True if everything is alright (goods are available, etc.) and the bot is ready to proceed with the order. Use False if there are any problems.
    ok: bool,
    /// Required if ok is False. Error message in human readable form that explains the reason for failure to proceed with the checkout (e.g. "Sorry, somebody just bought the last of our amazing black T-shirts while you were busy filling out your payment details. Please choose a different color or garment!"). Telegram will display this message to the user.
    error_message: ?[]const u8 = null,
};

/// If you sent an invoice requesting a shipping address and the parameter is_flexible was specified, the Bot API will send an Update with a shipping_query field to the bot. Use this method to reply to shipping queries. On success, True is returned.
/// Reference: https://core.telegram.org/bots/api#answershippingquery
pub const AnswerShippingQuery = struct {
    pub const api_method_name = "answerShippingQuery";
    pub const ReturnType = bool;

    /// Unique identifier for the query to be answered
    shipping_query_id: []const u8,
    /// Pass True if delivery to the specified address is possible and False if there are any problems (for example, if delivery to the specified address is not possible)
    ok: bool,
    /// Required if ok is True. A JSON-serialized Array of available shipping options.
    shipping_options: ?[]const types.ShippingOption = null,
    /// Required if ok is False. Error message in human readable form that explains why it is impossible to complete the order (e.g. "Sorry, delivery to your desired address is unavailable"). Telegram will display this message to the user.
    error_message: ?[]const u8 = null,
};

/// Use this method to set the result of an interaction with a Web App and send a corresponding message on behalf of the user to the chat from which the query originated. On success, a SentWebAppMessage object is returned.
/// Reference: https://core.telegram.org/bots/api#answerwebappquery
pub const AnswerWebAppQuery = struct {
    pub const api_method_name = "answerWebAppQuery";
    pub const ReturnType = types.SentWebAppMessage;

    /// Unique identifier for the query to be answered
    web_app_query_id: []const u8,
    /// A JSON-serialized object describing the message to be sent
    result: types.InlineQueryResult,
};

/// Use this method to approve a chat join request. The bot must be an administrator in the chat for this to work and must have the can_invite_users administrator right. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#approvechatjoinrequest
pub const ApproveChatJoinRequest = struct {
    pub const api_method_name = "approveChatJoinRequest";
    pub const ReturnType = bool;

    /// Unique identifier for the target chat or username of the target channel in the format @username
    chat_id: ChatId,
    /// Unique identifier of the target user
    user_id: i64,
};

/// Use this method to approve a suggested post in a direct messages chat. The bot must have the 'can_post_messages' administrator right in the corresponding channel chat. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#approvesuggestedpost
pub const ApproveSuggestedPost = struct {
    pub const api_method_name = "approveSuggestedPost";
    pub const ReturnType = bool;

    /// Unique identifier for the target direct messages chat
    chat_id: i64,
    /// Identifier of a suggested post message to approve
    message_id: i64,
    /// Point in time (Unix timestamp) when the post is expected to be published; omit if the date has already been specified when the suggested post was created. If specified, then the date must be not more than 2678400 seconds (30 days) in the future.
    send_date: ?i64 = null,
};

/// Use this method to ban a user in a group, a supergroup or a channel. In the case of supergroups and channels, the user will not be able to return to the chat on their own using invite links, etc., unless unbanned first. The bot must be an administrator in the chat for this to work and must have the appropriate administrator rights. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#banchatmember
pub const BanChatMember = struct {
    pub const api_method_name = "banChatMember";
    pub const ReturnType = bool;

    /// Unique identifier for the target group or username of the target supergroup or channel in the format @username
    chat_id: ChatId,
    /// Unique identifier of the target user
    user_id: i64,
    /// Date when the user will be unbanned; Unix time. If user is banned for more than 366 days or less than 30 seconds from the current time they are considered to be banned forever. Applied for supergroups and channels only.
    until_date: ?i64 = null,
    /// Pass True to delete all messages from the chat for the user that is being removed. If False, the user will be able to see messages in the group that were sent before the user was removed. Always True for supergroups and channels.
    revoke_messages: ?bool = null,
};

/// Use this method to ban a channel chat in a supergroup or a channel. Until the chat is unbanned, the owner of the banned chat won't be able to send messages on behalf of any of their channels. The bot must be an administrator in the supergroup or channel for this to work and must have the appropriate administrator rights. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#banchatsenderchat
pub const BanChatSenderChat = struct {
    pub const api_method_name = "banChatSenderChat";
    pub const ReturnType = bool;

    /// Unique identifier for the target chat or username of the target channel in the format @username
    chat_id: ChatId,
    /// Unique identifier of the target sender chat
    sender_chat_id: i64,
};

/// Use this method to close the bot instance before moving it from one local server to another. You need to delete the webhook before calling this method to ensure that the bot isn't launched again after server restart. The method will return error 429 in the first 10 minutes after the bot is launched. Returns True on success. Requires no parameters.
/// Reference: https://core.telegram.org/bots/api#close
pub const Close = struct {
    pub const api_method_name = "close";
    pub const ReturnType = bool;
};

/// Use this method to close an open topic in a forum supergroup chat. The bot must be an administrator in the chat for this to work and must have the can_manage_topics administrator rights, unless it is the creator of the topic. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#closeforumtopic
pub const CloseForumTopic = struct {
    pub const api_method_name = "closeForumTopic";
    pub const ReturnType = bool;

    /// Unique identifier for the target chat or username of the target supergroup in the format @username
    chat_id: ChatId,
    /// Unique identifier for the target message thread of the forum topic
    message_thread_id: i64,
};

/// Use this method to close an open 'General' topic in a forum supergroup chat. The bot must be an administrator in the chat for this to work and must have the can_manage_topics administrator rights. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#closegeneralforumtopic
pub const CloseGeneralForumTopic = struct {
    pub const api_method_name = "closeGeneralForumTopic";
    pub const ReturnType = bool;

    /// Unique identifier for the target chat or username of the target supergroup in the format @username
    chat_id: ChatId,
};

/// Converts a given regular gift to Telegram Stars. Requires the can_convert_gifts_to_stars business bot right. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#convertgifttostars
pub const ConvertGiftToStars = struct {
    pub const api_method_name = "convertGiftToStars";
    pub const ReturnType = bool;

    /// Unique identifier of the business connection
    business_connection_id: []const u8,
    /// Unique identifier of the regular gift that should be converted to Telegram Stars
    owned_gift_id: []const u8,
};

/// Use this method to copy messages of any kind. Service messages, paid media messages, giveaway messages, giveaway winners messages, and invoice messages can't be copied. A quiz poll can be copied only if the value of the field correct_option_ids is known to the bot. The method is analogous to the method forwardMessage, but the copied message doesn't have a link to the original message. Returns the MessageId of the sent message on success.
/// Reference: https://core.telegram.org/bots/api#copymessage
pub const CopyMessage = struct {
    pub const api_method_name = "copyMessage";
    pub const ReturnType = types.MessageId;

    /// Unique identifier for the target chat or username of the target bot, supergroup or channel in the format @username
    chat_id: ChatId,
    /// Unique identifier for the chat where the original message was sent (or username of the target bot, supergroup or channel in the format @username)
    from_chat_id: ChatId,
    /// Message identifier in the chat specified in from_chat_id
    message_id: i64,
    /// Unique identifier for the target message thread (topic) of a forum; for forum supergroups and private chats of bots with forum topic mode enabled only
    message_thread_id: ?i64 = null,
    /// Identifier of the direct messages topic to which the message will be sent; required if the message is sent to a direct messages chat
    direct_messages_topic_id: ?i64 = null,
    /// New start timestamp for the copied video in the message
    video_start_timestamp: ?i64 = null,
    /// New caption for media, 0-1024 characters after entities parsing. If not specified, the original caption is kept.
    caption: ?[]const u8 = null,
    /// Mode for parsing entities in the new caption. See formatting options for more details.
    parse_mode: ?types.enums.ParseMode = null,
    /// A JSON-serialized list of special entities that appear in the new caption, which can be specified instead of parse_mode
    caption_entities: ?[]const types.MessageEntity = null,
    /// Pass True if the caption must be shown above the message media. Ignored if a new caption isn't specified.
    show_caption_above_media: ?bool = null,
    /// Sends the message silently. Users will receive a notification with no sound.
    disable_notification: ?bool = null,
    /// Protects the contents of the sent message from forwarding and saving
    protect_content: ?bool = null,
    /// Pass True to allow up to 1000 messages per second, ignoring broadcasting limits for a fee of 0.1 Telegram Stars per message. The relevant Stars will be withdrawn from the bot's balance.
    allow_paid_broadcast: ?bool = null,
    /// Unique identifier of the message effect to be added to the message; only available when copying to private chats
    message_effect_id: ?[]const u8 = null,
    /// A JSON-serialized object containing the parameters of the suggested post to send; for direct messages chats only. If the message is sent as a reply to another suggested post, then that suggested post is automatically declined.
    suggested_post_parameters: ?types.SuggestedPostParameters = null,
    /// Description of the message to reply to
    reply_parameters: ?types.ReplyParameters = null,
    /// Additional interface options. A JSON-serialized object for an inline keyboard, custom reply keyboard, instructions to remove a reply keyboard or to force a reply from the user.
    reply_markup: ?ReplyMarkup = null,
};

/// Use this method to copy messages of any kind. If some of the specified messages can't be found or copied, they are skipped. Service messages, paid media messages, giveaway messages, giveaway winners messages, and invoice messages can't be copied. A quiz poll can be copied only if the value of the field correct_option_ids is known to the bot. The method is analogous to the method forwardMessages, but the copied messages don't have a link to the original message. Album grouping is kept for copied messages. On success, an Array of MessageId of the sent messages is returned.
/// Reference: https://core.telegram.org/bots/api#copymessages
pub const CopyMessages = struct {
    pub const api_method_name = "copyMessages";
    pub const ReturnType = []const types.MessageId;

    /// Unique identifier for the target chat or username of the target bot, supergroup or channel in the format @username
    chat_id: ChatId,
    /// Unique identifier for the chat where the original messages were sent (or username of the target bot, supergroup or channel in the format @username)
    from_chat_id: ChatId,
    /// A JSON-serialized list of 1-100 identifiers of messages in the chat from_chat_id to copy. The identifiers must be specified in a strictly increasing order.
    message_ids: []const i64,
    /// Unique identifier for the target message thread (topic) of a forum; for forum supergroups and private chats of bots with forum topic mode enabled only
    message_thread_id: ?i64 = null,
    /// Identifier of the direct messages topic to which the messages will be sent; required if the messages are sent to a direct messages chat
    direct_messages_topic_id: ?i64 = null,
    /// Sends the messages silently. Users will receive a notification with no sound.
    disable_notification: ?bool = null,
    /// Protects the contents of the sent messages from forwarding and saving
    protect_content: ?bool = null,
    /// Pass True to copy the messages without their captions
    remove_caption: ?bool = null,
};

/// Use this method to create an additional invite link for a chat. The bot must be an administrator in the chat for this to work and must have the appropriate administrator rights. The link can be revoked using the method revokeChatInviteLink. Returns the new invite link as ChatInviteLink object.
/// Reference: https://core.telegram.org/bots/api#createchatinvitelink
pub const CreateChatInviteLink = struct {
    pub const api_method_name = "createChatInviteLink";
    pub const ReturnType = types.ChatInviteLink;

    /// Unique identifier for the target chat or username of the target channel in the format @username
    chat_id: ChatId,
    /// Invite link name; 0-32 characters
    name: ?[]const u8 = null,
    /// Point in time (Unix timestamp) when the link will expire
    expire_date: ?i64 = null,
    /// The maximum number of users that can be members of the chat simultaneously after joining the chat via this invite link; 1-99999
    member_limit: ?i64 = null,
    /// True, if users joining the chat via the link need to be approved by chat administrators. If True, member_limit can't be specified.
    creates_join_request: ?bool = null,
};

/// Use this method to create a subscription invite link for a channel chat. The bot must have the can_invite_users administrator rights. The link can be edited using the method editChatSubscriptionInviteLink or revoked using the method revokeChatInviteLink. Returns the new invite link as a ChatInviteLink object.
/// Reference: https://core.telegram.org/bots/api#createchatsubscriptioninvitelink
pub const CreateChatSubscriptionInviteLink = struct {
    pub const api_method_name = "createChatSubscriptionInviteLink";
    pub const ReturnType = types.ChatInviteLink;

    /// Unique identifier for the target channel chat or username of the target channel in the format @username
    chat_id: ChatId,
    /// The number of seconds the subscription will be active for before the next payment. Currently, it must always be 2592000 (30 days).
    subscription_period: i64,
    /// The amount of Telegram Stars a user must pay initially and after each subsequent subscription period to be a member of the chat; 1-10000
    subscription_price: i64,
    /// Invite link name; 0-32 characters
    name: ?[]const u8 = null,
};

/// Use this method to create a topic in a forum supergroup chat or a private chat with a user. In the case of a supergroup chat the bot must be an administrator in the chat for this to work and must have the can_manage_topics administrator right. Returns information about the created topic as a ForumTopic object.
/// Reference: https://core.telegram.org/bots/api#createforumtopic
pub const CreateForumTopic = struct {
    pub const api_method_name = "createForumTopic";
    pub const ReturnType = types.ForumTopic;

    /// Unique identifier for the target chat or username of the target supergroup in the format @username
    chat_id: ChatId,
    /// Topic name, 1-128 characters
    name: []const u8,
    /// Color of the topic icon in RGB format. Currently, must be one of 7322096 (0x6FB9F0), 16766590 (0xFFD67E), 13338331 (0xCB86DB), 9367192 (0x8EEE98), 16749490 (0xFF93B2), or 16478047 (0xFB6F5F).
    icon_color: ?i64 = null,
    /// Unique identifier of the custom emoji shown as the topic icon. Use getForumTopicIconStickers to get all allowed custom emoji identifiers.
    icon_custom_emoji_id: ?[]const u8 = null,
};

/// Use this method to create a link for an invoice. Returns the created invoice link as String on success.
/// Reference: https://core.telegram.org/bots/api#createinvoicelink
pub const CreateInvoiceLink = struct {
    pub const api_method_name = "createInvoiceLink";
    pub const ReturnType = []const u8;

    /// Product name, 1-32 characters
    title: []const u8,
    /// Product description, 1-255 characters
    description: []const u8,
    /// Bot-defined invoice payload, 1-128 bytes. This will not be displayed to the user, use it for your internal processes.
    payload: []const u8,
    /// Three-letter ISO 4217 currency code, see more on currencies. Pass "XTR" for payments in Telegram Stars.
    currency: []const u8,
    /// Price breakdown, a JSON-serialized list of components (e.g. product price, tax, discount, delivery cost, delivery tax, bonus, etc.). Must contain exactly one item for payments in Telegram Stars.
    prices: []const types.LabeledPrice,
    /// Unique identifier of the business connection on behalf of which the link will be created. For payments in Telegram Stars only.
    business_connection_id: ?[]const u8 = null,
    /// Payment provider token, obtained via @BotFather. Pass an empty string for payments in Telegram Stars.
    provider_token: ?[]const u8 = null,
    /// The number of seconds the subscription will be active for before the next payment. The currency must be set to "XTR" (Telegram Stars) if the parameter is used. Currently, it must always be 2592000 (30 days) if specified. Any number of subscriptions can be active for a given bot at the same time, including multiple concurrent subscriptions from the same user. Subscription price must no exceed 10000 Telegram Stars.
    subscription_period: ?i64 = null,
    /// The maximum accepted amount for tips in the smallest units of the currency (integer, not float/double). For example, for a maximum tip of US$ 1.45 pass max_tip_amount = 145. See the exp parameter in currencies.json, it shows the number of digits past the decimal point for each currency (2 for the majority of currencies). Defaults to 0. Not supported for payments in Telegram Stars.
    max_tip_amount: ?i64 = null,
    /// A JSON-serialized Array of suggested amounts of tips in the smallest units of the currency (integer, not float/double). At most 4 suggested tip amounts can be specified. The suggested tip amounts must be positive, passed in a strictly increased order and must not exceed max_tip_amount.
    suggested_tip_amounts: ?[]const i64 = null,
    /// JSON-serialized data about the invoice, which will be shared with the payment provider. A detailed description of required fields should be provided by the payment provider.
    provider_data: ?[]const u8 = null,
    /// URL of the product photo for the invoice. Can be a photo of the goods or a marketing image for a service.
    photo_url: ?[]const u8 = null,
    /// Photo size in bytes
    photo_size: ?i64 = null,
    /// Photo width
    photo_width: ?i64 = null,
    /// Photo height
    photo_height: ?i64 = null,
    /// Pass True if you require the user's full name to complete the order. Ignored for payments in Telegram Stars.
    need_name: ?bool = null,
    /// Pass True if you require the user's phone number to complete the order. Ignored for payments in Telegram Stars.
    need_phone_number: ?bool = null,
    /// Pass True if you require the user's email address to complete the order. Ignored for payments in Telegram Stars.
    need_email: ?bool = null,
    /// Pass True if you require the user's shipping address to complete the order. Ignored for payments in Telegram Stars.
    need_shipping_address: ?bool = null,
    /// Pass True if the user's phone number should be sent to the provider. Ignored for payments in Telegram Stars.
    send_phone_number_to_provider: ?bool = null,
    /// Pass True if the user's email address should be sent to the provider. Ignored for payments in Telegram Stars.
    send_email_to_provider: ?bool = null,
    /// Pass True if the final price depends on the shipping method. Ignored for payments in Telegram Stars.
    is_flexible: ?bool = null,
};

/// Use this method to create a new sticker set owned by a user. The bot will be able to edit the sticker set thus created. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#createnewstickerset
pub const CreateNewStickerSet = struct {
    pub const api_method_name = "createNewStickerSet";
    pub const ReturnType = bool;

    /// User identifier of created sticker set owner
    user_id: i64,
    /// Short name of sticker set, to be used in t.me/addstickers/ URLs (e.g., animals). Can contain only English letters, digits and underscores. Must begin with a letter, can't contain consecutive underscores and must end in "_by_<bot_username>". <bot_username> is case insensitive. 1-64 characters.
    name: []const u8,
    /// Sticker set title, 1-64 characters
    title: []const u8,
    /// A JSON-serialized list of 1-50 initial stickers to be added to the sticker set
    stickers: []const types.InputSticker,
    /// Type of stickers in the set, pass "regular", "mask", or "custom_emoji". By default, a regular sticker set is created.
    sticker_type: ?[]const u8 = null,
    /// Pass True if stickers in the sticker set must be repainted to the color of text when used in messages, the accent color if used as emoji status, white on chat photos, or another appropriate color based on context; for custom emoji sticker sets only
    needs_repainting: ?bool = null,
};

/// Use this method to decline a chat join request. The bot must be an administrator in the chat for this to work and must have the can_invite_users administrator right. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#declinechatjoinrequest
pub const DeclineChatJoinRequest = struct {
    pub const api_method_name = "declineChatJoinRequest";
    pub const ReturnType = bool;

    /// Unique identifier for the target chat or username of the target channel in the format @username
    chat_id: ChatId,
    /// Unique identifier of the target user
    user_id: i64,
};

/// Use this method to decline a suggested post in a direct messages chat. The bot must have the 'can_manage_direct_messages' administrator right in the corresponding channel chat. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#declinesuggestedpost
pub const DeclineSuggestedPost = struct {
    pub const api_method_name = "declineSuggestedPost";
    pub const ReturnType = bool;

    /// Unique identifier for the target direct messages chat
    chat_id: i64,
    /// Identifier of a suggested post message to decline
    message_id: i64,
    /// Comment for the creator of the suggested post; 0-128 characters
    comment: ?[]const u8 = null,
};

/// Use this method to remove up to 10000 recent reactions in a group or a supergroup chat added by a given user or chat. The bot must have the 'can_delete_messages' administrator right in the chat. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#deleteallmessagereactions
pub const DeleteAllMessageReactions = struct {
    pub const api_method_name = "deleteAllMessageReactions";
    pub const ReturnType = bool;

    /// Unique identifier for the target chat or username of the target supergroup in the format @username
    chat_id: ChatId,
    /// Identifier of the user whose reactions will be removed, if the reactions were added by a user
    user_id: ?i64 = null,
    /// Identifier of the chat whose reactions will be removed, if the reactions were added by a chat
    actor_chat_id: ?i64 = null,
};

/// Delete messages on behalf of a business account. Requires the can_delete_sent_messages business bot right to delete messages sent by the bot itself, or the can_delete_all_messages business bot right to delete any message. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#deletebusinessmessages
pub const DeleteBusinessMessages = struct {
    pub const api_method_name = "deleteBusinessMessages";
    pub const ReturnType = bool;

    /// Unique identifier of the business connection on behalf of which to delete the messages
    business_connection_id: []const u8,
    /// A JSON-serialized list of 1-100 identifiers of messages to delete. All messages must be from the same chat. See deleteMessage for limitations on which messages can be deleted.
    message_ids: []const i64,
};

/// Use this method to delete a chat photo. Photos can't be changed for private chats. The bot must be an administrator in the chat for this to work and must have the appropriate administrator rights. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#deletechatphoto
pub const DeleteChatPhoto = struct {
    pub const api_method_name = "deleteChatPhoto";
    pub const ReturnType = bool;

    /// Unique identifier for the target chat or username of the target channel in the format @username
    chat_id: ChatId,
};

/// Use this method to delete a group sticker set from a supergroup. The bot must be an administrator in the chat for this to work and must have the appropriate administrator rights. Use the field can_set_sticker_set optionally returned in getChat requests to check if the bot can use this method. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#deletechatstickerset
pub const DeleteChatStickerSet = struct {
    pub const api_method_name = "deleteChatStickerSet";
    pub const ReturnType = bool;

    /// Unique identifier for the target chat or username of the target supergroup in the format @username
    chat_id: ChatId,
};

/// Use this method to delete an ephemeral message. Note that it is not guaranteed that the user will receive the message deletion event, especially if they are offline. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#deleteephemeralmessage
pub const DeleteEphemeralMessage = struct {
    pub const api_method_name = "deleteEphemeralMessage";
    pub const ReturnType = bool;

    /// Unique identifier for the target chat or username of the target supergroup in the format @username
    chat_id: ChatId,
    /// Identifier of the user who received the message
    receiver_user_id: i64,
    /// Identifier of the ephemeral message to delete
    ephemeral_message_id: i64,
};

/// Use this method to delete a forum topic along with all its messages in a forum supergroup chat or a private chat with a user. In the case of a supergroup chat the bot must be an administrator in the chat for this to work and must have the can_delete_messages administrator rights. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#deleteforumtopic
pub const DeleteForumTopic = struct {
    pub const api_method_name = "deleteForumTopic";
    pub const ReturnType = bool;

    /// Unique identifier for the target chat or username of the target supergroup in the format @username
    chat_id: ChatId,
    /// Unique identifier for the target message thread of the forum topic
    message_thread_id: i64,
};

/// Use this method to delete a message, including service messages, with the following limitations:
/// - A message can only be deleted if it was sent less than 48 hours ago.
/// - Service messages about a supergroup, channel, or forum topic creation can't be deleted.
/// - A dice message in a private chat can only be deleted if it was sent more than 24 hours ago.
/// - Bots can delete outgoing messages in private chats, groups, and supergroups.
/// - Bots can delete incoming messages in private chats.
/// - Bots granted can_post_messages permissions can delete outgoing messages in channels.
/// - If the bot is an administrator of a group, it can delete any message there.
/// - If the bot has can_delete_messages administrator right in a supergroup or a channel, it can delete any message there.
/// - If the bot has can_manage_direct_messages administrator right in a channel, it can delete any message in the corresponding direct messages chat.
/// Returns True on success.
/// Reference: https://core.telegram.org/bots/api#deletemessage
pub const DeleteMessage = struct {
    pub const api_method_name = "deleteMessage";
    pub const ReturnType = bool;

    /// Unique identifier for the target chat or username of the target bot, supergroup or channel in the format @username
    chat_id: ChatId,
    /// Identifier of the message to delete
    message_id: i64,
};

/// Use this method to remove a reaction from a message in a group or a supergroup chat. The bot must have the 'can_delete_messages' administrator right in the chat. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#deletemessagereaction
pub const DeleteMessageReaction = struct {
    pub const api_method_name = "deleteMessageReaction";
    pub const ReturnType = bool;

    /// Unique identifier for the target chat or username of the target supergroup in the format @username
    chat_id: ChatId,
    /// Identifier of the target message
    message_id: i64,
    /// Identifier of the user whose reaction will be removed, if the reaction was added by a user
    user_id: ?i64 = null,
    /// Identifier of the chat whose reaction will be removed, if the reaction was added by a chat
    actor_chat_id: ?i64 = null,
};

/// Use this method to delete multiple messages simultaneously. If some of the specified messages can't be found, they are skipped. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#deletemessages
pub const DeleteMessages = struct {
    pub const api_method_name = "deleteMessages";
    pub const ReturnType = bool;

    /// Unique identifier for the target chat or username of the target bot, supergroup or channel in the format @username
    chat_id: ChatId,
    /// A JSON-serialized list of 1-100 identifiers of messages to delete. See deleteMessage for limitations on which messages can be deleted.
    message_ids: []const i64,
};

/// Use this method to delete the list of the bot's commands for the given scope and user language. After deletion, higher level commands will be shown to affected users. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#deletemycommands
pub const DeleteMyCommands = struct {
    pub const api_method_name = "deleteMyCommands";
    pub const ReturnType = bool;

    /// A JSON-serialized object, describing scope of users for which the commands are relevant. Defaults to BotCommandScopeDefault.
    scope: ?types.BotCommandScope = null,
    /// A two-letter ISO 639-1 language code. If empty, commands will be applied to all users from the given scope, for whose language there are no dedicated commands.
    language_code: ?[]const u8 = null,
};

/// Use this method to delete a sticker from a set created by the bot. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#deletestickerfromset
pub const DeleteStickerFromSet = struct {
    pub const api_method_name = "deleteStickerFromSet";
    pub const ReturnType = bool;

    /// File identifier of the sticker
    sticker: []const u8,
};

/// Use this method to delete a sticker set that was created by the bot. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#deletestickerset
pub const DeleteStickerSet = struct {
    pub const api_method_name = "deleteStickerSet";
    pub const ReturnType = bool;

    /// Sticker set name
    name: []const u8,
};

/// Deletes a story previously posted by the bot on behalf of a managed business account. Requires the can_manage_stories business bot right. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#deletestory
pub const DeleteStory = struct {
    pub const api_method_name = "deleteStory";
    pub const ReturnType = bool;

    /// Unique identifier of the business connection
    business_connection_id: []const u8,
    /// Unique identifier of the story to delete
    story_id: i64,
};

/// Use this method to remove webhook integration if you decide to switch back to getUpdates. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#deletewebhook
pub const DeleteWebhook = struct {
    pub const api_method_name = "deleteWebhook";
    pub const ReturnType = bool;

    /// Pass True to drop all pending updates
    drop_pending_updates: ?bool = null,
};

/// Use this method to edit a non-primary invite link created by the bot. The bot must be an administrator in the chat for this to work and must have the appropriate administrator rights. Returns the edited invite link as a ChatInviteLink object.
/// Reference: https://core.telegram.org/bots/api#editchatinvitelink
pub const EditChatInviteLink = struct {
    pub const api_method_name = "editChatInviteLink";
    pub const ReturnType = types.ChatInviteLink;

    /// Unique identifier for the target chat or username of the target channel in the format @username
    chat_id: ChatId,
    /// The invite link to edit
    invite_link: []const u8,
    /// Invite link name; 0-32 characters
    name: ?[]const u8 = null,
    /// Point in time (Unix timestamp) when the link will expire
    expire_date: ?i64 = null,
    /// The maximum number of users that can be members of the chat simultaneously after joining the chat via this invite link; 1-99999
    member_limit: ?i64 = null,
    /// True, if users joining the chat via the link need to be approved by chat administrators. If True, member_limit can't be specified.
    creates_join_request: ?bool = null,
};

/// Use this method to edit a subscription invite link created by the bot. The bot must have the can_invite_users administrator rights. Returns the edited invite link as a ChatInviteLink object.
/// Reference: https://core.telegram.org/bots/api#editchatsubscriptioninvitelink
pub const EditChatSubscriptionInviteLink = struct {
    pub const api_method_name = "editChatSubscriptionInviteLink";
    pub const ReturnType = types.ChatInviteLink;

    /// Unique identifier for the target chat or username of the target channel in the format @username
    chat_id: ChatId,
    /// The invite link to edit
    invite_link: []const u8,
    /// Invite link name; 0-32 characters
    name: ?[]const u8 = null,
};

/// Use this method to edit the caption of an ephemeral message. Note that it is not guaranteed that the user will receive the message edit event, especially if they are offline. On success, True is returned.
/// Reference: https://core.telegram.org/bots/api#editephemeralmessagecaption
pub const EditEphemeralMessageCaption = struct {
    pub const api_method_name = "editEphemeralMessageCaption";
    pub const ReturnType = bool;

    /// Unique identifier for the target chat or username of the target supergroup in the format @username
    chat_id: ChatId,
    /// Identifier of the user who received the message
    receiver_user_id: i64,
    /// Identifier of the ephemeral message to edit
    ephemeral_message_id: i64,
    /// New caption of the message, 0-1024 characters after entities parsing
    caption: ?[]const u8 = null,
    /// Mode for parsing entities in the message caption. See formatting options for more details.
    parse_mode: ?types.enums.ParseMode = null,
    /// A JSON-serialized list of special entities that appear in the caption, which can be specified instead of parse_mode
    caption_entities: ?[]const types.MessageEntity = null,
    /// Pass True if the caption must be shown above the message media. Supported only for animation, photo and video messages.
    show_caption_above_media: ?bool = null,
    /// A JSON-serialized object for an inline keyboard
    reply_markup: ?types.InlineKeyboardMarkup = null,
};

/// Use this method to edit the media of an ephemeral message. Note that it is not guaranteed that the user will receive the message edit event, especially if they are offline. On success, True is returned.
/// Reference: https://core.telegram.org/bots/api#editephemeralmessagemedia
pub const EditEphemeralMessageMedia = struct {
    pub const api_method_name = "editEphemeralMessageMedia";
    pub const ReturnType = bool;

    /// Unique identifier for the target chat or username of the target supergroup in the format @username
    chat_id: ChatId,
    /// Identifier of the user who received the message
    receiver_user_id: i64,
    /// Identifier of the ephemeral message to edit
    ephemeral_message_id: i64,
    /// A JSON-serialized object for the new media content of the message
    media: types.InputMedia,
    /// A JSON-serialized object for an inline keyboard
    reply_markup: ?types.InlineKeyboardMarkup = null,
};

/// Use this method to edit only the reply markup of an ephemeral message. Note that it is not guaranteed that the user will receive the message edit event, especially if they are offline. On success, True is returned.
/// Reference: https://core.telegram.org/bots/api#editephemeralmessagereplymarkup
pub const EditEphemeralMessageReplyMarkup = struct {
    pub const api_method_name = "editEphemeralMessageReplyMarkup";
    pub const ReturnType = bool;

    /// Unique identifier for the target chat or username of the target supergroup in the format @username
    chat_id: ChatId,
    /// Identifier of the user who received the message
    receiver_user_id: i64,
    /// Identifier of the ephemeral message to edit
    ephemeral_message_id: i64,
    /// A JSON-serialized object for an inline keyboard
    reply_markup: ?types.InlineKeyboardMarkup = null,
};

/// Use this method to edit an ephemeral text or rich message. Note that it is not guaranteed that the user will receive the message edit event, especially if they are offline. On success, True is returned.
/// Reference: https://core.telegram.org/bots/api#editephemeralmessagetext
pub const EditEphemeralMessageText = struct {
    pub const api_method_name = "editEphemeralMessageText";
    pub const ReturnType = bool;

    /// Unique identifier for the target chat or username of the target supergroup in the format @username
    chat_id: ChatId,
    /// Identifier of the user who received the message
    receiver_user_id: i64,
    /// Identifier of the ephemeral message to edit
    ephemeral_message_id: i64,
    /// New text of the message, 1-4096 characters after entity parsing; required if rich_message isn't specified
    text: ?[]const u8 = null,
    /// Mode for parsing entities in the message text. See formatting options for more details.
    parse_mode: ?types.enums.ParseMode = null,
    /// A JSON-serialized list of special entities that appear in message text, which can be specified instead of parse_mode
    entities: ?[]const types.MessageEntity = null,
    /// New rich content of the message; required if text isn't specified
    rich_message: ?types.InputRichMessage = null,
    /// Link preview generation options for the message
    link_preview_options: ?types.LinkPreviewOptions = null,
    /// A JSON-serialized object for an inline keyboard
    reply_markup: ?types.InlineKeyboardMarkup = null,
};

/// Use this method to edit name and icon of a topic in a forum supergroup chat or a private chat with a user. In the case of a supergroup chat the bot must be an administrator in the chat for this to work and must have the can_manage_topics administrator rights, unless it is the creator of the topic. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#editforumtopic
pub const EditForumTopic = struct {
    pub const api_method_name = "editForumTopic";
    pub const ReturnType = bool;

    /// Unique identifier for the target chat or username of the target supergroup in the format @username
    chat_id: ChatId,
    /// Unique identifier for the target message thread of the forum topic
    message_thread_id: i64,
    /// New topic name, 0-128 characters. If not specified or empty, the current name of the topic will be kept.
    name: ?[]const u8 = null,
    /// New unique identifier of the custom emoji shown as the topic icon. Use getForumTopicIconStickers to get all allowed custom emoji identifiers. Pass an empty string to remove the icon. If not specified, the current icon will be kept.
    icon_custom_emoji_id: ?[]const u8 = null,
};

/// Use this method to edit the name of the 'General' topic in a forum supergroup chat. The bot must be an administrator in the chat for this to work and must have the can_manage_topics administrator rights. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#editgeneralforumtopic
pub const EditGeneralForumTopic = struct {
    pub const api_method_name = "editGeneralForumTopic";
    pub const ReturnType = bool;

    /// Unique identifier for the target chat or username of the target supergroup in the format @username
    chat_id: ChatId,
    /// New topic name, 1-128 characters
    name: []const u8,
};

/// Use this method to edit captions of messages. On success, if the edited message is not an inline message, the edited Message is returned, otherwise True is returned. Note that business messages that were not sent by the bot and do not contain an inline keyboard can only be edited within 48 hours from the time they were sent.
/// Reference: https://core.telegram.org/bots/api#editmessagecaption
pub const EditMessageCaption = struct {
    pub const api_method_name = "editMessageCaption";
    pub const ReturnType = ObjectOrBool(types.Message);

    /// Unique identifier of the business connection on behalf of which the message to be edited was sent
    business_connection_id: ?[]const u8 = null,
    /// Required if inline_message_id is not specified. Unique identifier for the target chat or username of the target bot, supergroup or channel in the format @username.
    chat_id: ?ChatId = null,
    /// Required if inline_message_id is not specified. Identifier of the message to edit.
    message_id: ?i64 = null,
    /// Required if chat_id and message_id are not specified. Identifier of the inline message.
    inline_message_id: ?[]const u8 = null,
    /// New caption of the message, 0-1024 characters after entities parsing
    caption: ?[]const u8 = null,
    /// Mode for parsing entities in the message caption. See formatting options for more details.
    parse_mode: ?types.enums.ParseMode = null,
    /// A JSON-serialized list of special entities that appear in the caption, which can be specified instead of parse_mode
    caption_entities: ?[]const types.MessageEntity = null,
    /// Pass True if the caption must be shown above the message media. Supported only for animation, photo and video messages.
    show_caption_above_media: ?bool = null,
    /// A JSON-serialized object for an inline keyboard
    reply_markup: ?types.InlineKeyboardMarkup = null,
};

/// Use this method to edit a checklist on behalf of a connected business account. On success, the edited Message is returned.
/// Reference: https://core.telegram.org/bots/api#editmessagechecklist
pub const EditMessageChecklist = struct {
    pub const api_method_name = "editMessageChecklist";
    pub const ReturnType = types.Message;

    /// Unique identifier of the business connection on behalf of which the message will be sent
    business_connection_id: []const u8,
    /// Unique identifier for the target chat or username of the target bot in the format @username
    chat_id: ChatId,
    /// Unique identifier for the target message
    message_id: i64,
    /// A JSON-serialized object for the new checklist
    checklist: types.InputChecklist,
    /// A JSON-serialized object for the new inline keyboard for the message
    reply_markup: ?types.InlineKeyboardMarkup = null,
};

/// Use this method to edit live location messages. A location can be edited until its live_period expires or editing is explicitly disabled by a call to stopMessageLiveLocation. On success, if the edited message is not an inline message, the edited Message is returned, otherwise True is returned.
/// Reference: https://core.telegram.org/bots/api#editmessagelivelocation
pub const EditMessageLiveLocation = struct {
    pub const api_method_name = "editMessageLiveLocation";
    pub const ReturnType = ObjectOrBool(types.Message);

    /// Latitude of new location
    latitude: f64,
    /// Longitude of new location
    longitude: f64,
    /// Unique identifier of the business connection on behalf of which the message to be edited was sent
    business_connection_id: ?[]const u8 = null,
    /// Required if inline_message_id is not specified. Unique identifier for the target chat or username of the target bot, supergroup or channel in the format @username.
    chat_id: ?ChatId = null,
    /// Required if inline_message_id is not specified. Identifier of the message to edit.
    message_id: ?i64 = null,
    /// Required if chat_id and message_id are not specified. Identifier of the inline message.
    inline_message_id: ?[]const u8 = null,
    /// New period in seconds during which the location can be updated, starting from the message send date. If 0x7FFFFFFF is specified, then the location can be updated forever. Otherwise, the new value must not exceed the current live_period by more than a day, and the live location expiration date must remain within the next 90 days. If not specified, then live_period remains unchanged.
    live_period: ?i64 = null,
    /// The radius of uncertainty for the location, measured in meters; 0-1500
    horizontal_accuracy: ?f64 = null,
    /// Direction in which the user is moving, in degrees. Must be between 1 and 360 if specified.
    heading: ?i64 = null,
    /// The maximum distance for proximity alerts about approaching another chat member, in meters. Must be between 1 and 100000 if specified.
    proximity_alert_radius: ?i64 = null,
    /// A JSON-serialized object for a new inline keyboard
    reply_markup: ?types.InlineKeyboardMarkup = null,
};

/// Use this method to edit animation, audio, document, live photo, photo, or video messages, or to replace a text or a rich message with a media. If a message is part of a message album, then it can be edited only to an audio for audio albums, only to a document for document albums and to a photo, a live photo, or a video otherwise. When an inline message is edited, a new file can't be uploaded; use a previously uploaded file via its file_id or specify a URL. On success, if the edited message is not an inline message, the edited Message is returned, otherwise True is returned. Note that business messages that were not sent by the bot and do not contain an inline keyboard can only be edited within 48 hours from the time they were sent.
/// Reference: https://core.telegram.org/bots/api#editmessagemedia
pub const EditMessageMedia = struct {
    pub const api_method_name = "editMessageMedia";
    pub const ReturnType = ObjectOrBool(types.Message);

    /// A JSON-serialized object for the new media content of the message
    media: types.InputMedia,
    /// Unique identifier of the business connection on behalf of which the message to be edited was sent
    business_connection_id: ?[]const u8 = null,
    /// Required if inline_message_id is not specified. Unique identifier for the target chat or username of the target bot, supergroup or channel in the format @username.
    chat_id: ?ChatId = null,
    /// Required if inline_message_id is not specified. Identifier of the message to edit.
    message_id: ?i64 = null,
    /// Required if chat_id and message_id are not specified. Identifier of the inline message.
    inline_message_id: ?[]const u8 = null,
    /// A JSON-serialized object for a new inline keyboard
    reply_markup: ?types.InlineKeyboardMarkup = null,
};

/// Use this method to edit only the reply markup of messages. On success, if the edited message is not an inline message, the edited Message is returned, otherwise True is returned. Note that business messages that were not sent by the bot and do not contain an inline keyboard can only be edited within 48 hours from the time they were sent.
/// Reference: https://core.telegram.org/bots/api#editmessagereplymarkup
pub const EditMessageReplyMarkup = struct {
    pub const api_method_name = "editMessageReplyMarkup";
    pub const ReturnType = ObjectOrBool(types.Message);

    /// Unique identifier of the business connection on behalf of which the message to be edited was sent
    business_connection_id: ?[]const u8 = null,
    /// Required if inline_message_id is not specified. Unique identifier for the target chat or username of the target bot, supergroup or channel in the format @username.
    chat_id: ?ChatId = null,
    /// Required if inline_message_id is not specified. Identifier of the message to edit.
    message_id: ?i64 = null,
    /// Required if chat_id and message_id are not specified. Identifier of the inline message.
    inline_message_id: ?[]const u8 = null,
    /// A JSON-serialized object for an inline keyboard
    reply_markup: ?types.InlineKeyboardMarkup = null,
};

/// Use this method to edit text, rich and game messages. On success, if the edited message is not an inline message, the edited Message is returned, otherwise True is returned. Note that business messages that were not sent by the bot and do not contain an inline keyboard can only be edited within 48 hours from the time they were sent.
/// Reference: https://core.telegram.org/bots/api#editmessagetext
pub const EditMessageText = struct {
    pub const api_method_name = "editMessageText";
    pub const ReturnType = ObjectOrBool(types.Message);

    /// Unique identifier of the business connection on behalf of which the message to be edited was sent
    business_connection_id: ?[]const u8 = null,
    /// Required if inline_message_id is not specified. Unique identifier for the target chat or username of the target bot, supergroup or channel in the format @username.
    chat_id: ?ChatId = null,
    /// Required if inline_message_id is not specified. Identifier of the message to edit.
    message_id: ?i64 = null,
    /// Required if chat_id and message_id are not specified. Identifier of the inline message.
    inline_message_id: ?[]const u8 = null,
    /// New text of the message, 1-4096 characters after entity parsing; required if rich_message isn't specified
    text: ?[]const u8 = null,
    /// Mode for parsing entities in the message text. See formatting options for more details.
    parse_mode: ?types.enums.ParseMode = null,
    /// A JSON-serialized list of special entities that appear in message text, which can be specified instead of parse_mode
    entities: ?[]const types.MessageEntity = null,
    /// Link preview generation options for the message
    link_preview_options: ?types.LinkPreviewOptions = null,
    /// New rich content of the message; required if text isn't specified. Direct upload of new files and explicit upload of files by a URL isn't supported when an inline message is edited.
    rich_message: ?types.InputRichMessage = null,
    /// A JSON-serialized object for an inline keyboard
    reply_markup: ?types.InlineKeyboardMarkup = null,
};

/// Edits a story previously posted by the bot on behalf of a managed business account. Requires the can_manage_stories business bot right. Returns Story on success.
/// Reference: https://core.telegram.org/bots/api#editstory
pub const EditStory = struct {
    pub const api_method_name = "editStory";
    pub const ReturnType = types.Story;

    /// Unique identifier of the business connection
    business_connection_id: []const u8,
    /// Unique identifier of the story to edit
    story_id: i64,
    /// Content of the story
    content: types.InputStoryContent,
    /// Caption of the story, 0-2048 characters after entities parsing
    caption: ?[]const u8 = null,
    /// Mode for parsing entities in the story caption. See formatting options for more details.
    parse_mode: ?types.enums.ParseMode = null,
    /// A JSON-serialized list of special entities that appear in the caption, which can be specified instead of parse_mode
    caption_entities: ?[]const types.MessageEntity = null,
    /// A JSON-serialized list of clickable areas to be shown on the story
    areas: ?[]const types.StoryArea = null,
};

/// Allows the bot to cancel or re-enable extension of a subscription paid in Telegram Stars. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#edituserstarsubscription
pub const EditUserStarSubscription = struct {
    pub const api_method_name = "editUserStarSubscription";
    pub const ReturnType = bool;

    /// Identifier of the user whose subscription will be edited
    user_id: i64,
    /// Telegram payment identifier for the subscription
    telegram_payment_charge_id: []const u8,
    /// Pass True to cancel extension of the user subscription; the subscription must be active up to the end of the current subscription period. Pass False to allow the user to re-enable a subscription that was previously canceled by the bot.
    is_canceled: bool,
};

/// Use this method to generate a new primary invite link for a chat; any previously generated primary link is revoked. The bot must be an administrator in the chat for this to work and must have the appropriate administrator rights. Returns the new invite link as String on success.
/// Reference: https://core.telegram.org/bots/api#exportchatinvitelink
pub const ExportChatInviteLink = struct {
    pub const api_method_name = "exportChatInviteLink";
    pub const ReturnType = []const u8;

    /// Unique identifier for the target chat or username of the target channel in the format @username
    chat_id: ChatId,
};

/// Use this method to forward messages of any kind. Service messages and messages with protected content can't be forwarded. On success, the sent Message is returned.
/// Reference: https://core.telegram.org/bots/api#forwardmessage
pub const ForwardMessage = struct {
    pub const api_method_name = "forwardMessage";
    pub const ReturnType = types.Message;

    /// Unique identifier for the target chat or username of the target bot, supergroup or channel in the format @username
    chat_id: ChatId,
    /// Unique identifier for the chat where the original message was sent (or username of the target bot, supergroup or channel in the format @username)
    from_chat_id: ChatId,
    /// Message identifier in the chat specified in from_chat_id
    message_id: i64,
    /// Unique identifier for the target message thread (topic) of a forum; for forum supergroups and private chats of bots with forum topic mode enabled only
    message_thread_id: ?i64 = null,
    /// Identifier of the direct messages topic to which the message will be forwarded; required if the message is forwarded to a direct messages chat
    direct_messages_topic_id: ?i64 = null,
    /// New start timestamp for the forwarded video in the message
    video_start_timestamp: ?i64 = null,
    /// Sends the message silently. Users will receive a notification with no sound.
    disable_notification: ?bool = null,
    /// Protects the contents of the forwarded message from forwarding and saving
    protect_content: ?bool = null,
    /// Unique identifier of the message effect to be added to the message; only available when forwarding to private chats
    message_effect_id: ?[]const u8 = null,
    /// A JSON-serialized object containing the parameters of the suggested post to send; for direct messages chats only
    suggested_post_parameters: ?types.SuggestedPostParameters = null,
};

/// Use this method to forward multiple messages of any kind. If some of the specified messages can't be found or forwarded, they are skipped. Service messages and messages with protected content can't be forwarded. Album grouping is kept for forwarded messages. On success, an Array of MessageId of the sent messages is returned.
/// Reference: https://core.telegram.org/bots/api#forwardmessages
pub const ForwardMessages = struct {
    pub const api_method_name = "forwardMessages";
    pub const ReturnType = []const types.MessageId;

    /// Unique identifier for the target chat or username of the target bot, supergroup or channel in the format @username
    chat_id: ChatId,
    /// Unique identifier for the chat where the original messages were sent (or username of the target bot, supergroup or channel in the format @username)
    from_chat_id: ChatId,
    /// A JSON-serialized list of 1-100 identifiers of messages in the chat from_chat_id to forward. The identifiers must be specified in a strictly increasing order.
    message_ids: []const i64,
    /// Unique identifier for the target message thread (topic) of a forum; for forum supergroups and private chats of bots with forum topic mode enabled only
    message_thread_id: ?i64 = null,
    /// Identifier of the direct messages topic to which the messages will be forwarded; required if the messages are forwarded to a direct messages chat
    direct_messages_topic_id: ?i64 = null,
    /// Sends the messages silently. Users will receive a notification with no sound.
    disable_notification: ?bool = null,
    /// Protects the contents of the forwarded messages from forwarding and saving
    protect_content: ?bool = null,
};

/// Returns the list of gifts that can be sent by the bot to users and channel chats. Requires no parameters. Returns a Gifts object.
/// Reference: https://core.telegram.org/bots/api#getavailablegifts
pub const GetAvailableGifts = struct {
    pub const api_method_name = "getAvailableGifts";
    pub const ReturnType = types.Gifts;
};

/// Returns the gifts received and owned by a managed business account. Requires the can_view_gifts_and_stars business bot right. Returns OwnedGifts on success.
/// Reference: https://core.telegram.org/bots/api#getbusinessaccountgifts
pub const GetBusinessAccountGifts = struct {
    pub const api_method_name = "getBusinessAccountGifts";
    pub const ReturnType = types.OwnedGifts;

    /// Unique identifier of the business connection
    business_connection_id: []const u8,
    /// Pass True to exclude gifts that aren't saved to the account's profile page
    exclude_unsaved: ?bool = null,
    /// Pass True to exclude gifts that are saved to the account's profile page
    exclude_saved: ?bool = null,
    /// Pass True to exclude gifts that can be purchased an unlimited number of times
    exclude_unlimited: ?bool = null,
    /// Pass True to exclude gifts that can be purchased a limited number of times and can be upgraded to unique
    exclude_limited_upgradable: ?bool = null,
    /// Pass True to exclude gifts that can be purchased a limited number of times and can't be upgraded to unique
    exclude_limited_non_upgradable: ?bool = null,
    /// Pass True to exclude unique gifts
    exclude_unique: ?bool = null,
    /// Pass True to exclude gifts that were assigned from the TON blockchain and can't be resold or transferred in Telegram
    exclude_from_blockchain: ?bool = null,
    /// Pass True to sort results by gift price instead of send date. Sorting is applied before pagination.
    sort_by_price: ?bool = null,
    /// Offset of the first entry to return as received from the previous request; use empty string to get the first chunk of results
    offset: ?[]const u8 = null,
    /// The maximum number of gifts to be returned; 1-100. Defaults to 100.
    limit: ?i64 = null,
};

/// Returns the amount of Telegram Stars owned by a managed business account. Requires the can_view_gifts_and_stars business bot right. Returns StarAmount on success.
/// Reference: https://core.telegram.org/bots/api#getbusinessaccountstarbalance
pub const GetBusinessAccountStarBalance = struct {
    pub const api_method_name = "getBusinessAccountStarBalance";
    pub const ReturnType = types.StarAmount;

    /// Unique identifier of the business connection
    business_connection_id: []const u8,
};

/// Use this method to get information about the connection of the bot with a business account. Returns a BusinessConnection object on success.
/// Reference: https://core.telegram.org/bots/api#getbusinessconnection
pub const GetBusinessConnection = struct {
    pub const api_method_name = "getBusinessConnection";
    pub const ReturnType = types.BusinessConnection;

    /// Unique identifier of the business connection
    business_connection_id: []const u8,
};

/// Use this method to get up-to-date information about the chat. Returns a ChatFullInfo object on success.
/// Reference: https://core.telegram.org/bots/api#getchat
pub const GetChat = struct {
    pub const api_method_name = "getChat";
    pub const ReturnType = types.ChatFullInfo;

    /// Unique identifier for the target chat or username of the target supergroup or channel in the format @username
    chat_id: ChatId,
};

/// Use this method to get a list of administrators in a chat. Returns an Array of ChatMember objects.
/// Reference: https://core.telegram.org/bots/api#getchatadministrators
pub const GetChatAdministrators = struct {
    pub const api_method_name = "getChatAdministrators";
    pub const ReturnType = []const types.ChatMember;

    /// Unique identifier for the target chat or username of the target supergroup or channel in the format @username
    chat_id: ChatId,
    /// Pass True to additionally receive all bots that are administrators of the chat. By default, bots other than the current bot are omitted.
    return_bots: ?bool = null,
};

/// Returns the gifts owned by a chat. Returns OwnedGifts on success.
/// Reference: https://core.telegram.org/bots/api#getchatgifts
pub const GetChatGifts = struct {
    pub const api_method_name = "getChatGifts";
    pub const ReturnType = types.OwnedGifts;

    /// Unique identifier for the target chat or username of the target channel in the format @username
    chat_id: ChatId,
    /// Pass True to exclude gifts that aren't saved to the chat's profile page. Always True, unless the bot has the can_post_messages administrator right in the channel.
    exclude_unsaved: ?bool = null,
    /// Pass True to exclude gifts that are saved to the chat's profile page. Always False, unless the bot has the can_post_messages administrator right in the channel.
    exclude_saved: ?bool = null,
    /// Pass True to exclude gifts that can be purchased an unlimited number of times
    exclude_unlimited: ?bool = null,
    /// Pass True to exclude gifts that can be purchased a limited number of times and can be upgraded to unique
    exclude_limited_upgradable: ?bool = null,
    /// Pass True to exclude gifts that can be purchased a limited number of times and can't be upgraded to unique
    exclude_limited_non_upgradable: ?bool = null,
    /// Pass True to exclude gifts that were assigned from the TON blockchain and can't be resold or transferred in Telegram
    exclude_from_blockchain: ?bool = null,
    /// Pass True to exclude unique gifts
    exclude_unique: ?bool = null,
    /// Pass True to sort results by gift price instead of send date. Sorting is applied before pagination.
    sort_by_price: ?bool = null,
    /// Offset of the first entry to return as received from the previous request; use an empty string to get the first chunk of results
    offset: ?[]const u8 = null,
    /// The maximum number of gifts to be returned; 1-100. Defaults to 100.
    limit: ?i64 = null,
};

/// Use this method to get information about a member of a chat. The method is only guaranteed to work for other users if the bot is an administrator in the chat. Returns a ChatMember object on success.
/// Reference: https://core.telegram.org/bots/api#getchatmember
pub const GetChatMember = struct {
    pub const api_method_name = "getChatMember";
    pub const ReturnType = types.ChatMember;

    /// Unique identifier for the target chat or username of the target supergroup or channel in the format @username
    chat_id: ChatId,
    /// Unique identifier of the target user
    user_id: i64,
};

/// Use this method to get the number of members in a chat. Returns Integer on success.
/// Reference: https://core.telegram.org/bots/api#getchatmembercount
pub const GetChatMemberCount = struct {
    pub const api_method_name = "getChatMemberCount";
    pub const ReturnType = i64;

    /// Unique identifier for the target chat or username of the target supergroup or channel in the format @username
    chat_id: ChatId,
};

/// Use this method to get the current value of the bot's menu button in a private chat, or the default menu button. Returns MenuButton on success.
/// Reference: https://core.telegram.org/bots/api#getchatmenubutton
pub const GetChatMenuButton = struct {
    pub const api_method_name = "getChatMenuButton";
    pub const ReturnType = types.MenuButton;

    /// Unique identifier for the target private chat. If not specified, the bot's default menu button will be returned.
    chat_id: ?i64 = null,
};

/// Use this method to get information about custom emoji stickers by their identifiers. Returns an Array of Sticker objects.
/// Reference: https://core.telegram.org/bots/api#getcustomemojistickers
pub const GetCustomEmojiStickers = struct {
    pub const api_method_name = "getCustomEmojiStickers";
    pub const ReturnType = []const types.Sticker;

    /// A JSON-serialized list of custom emoji identifiers. At most 200 custom emoji identifiers can be specified.
    custom_emoji_ids: []const []const u8,
};

/// Use this method to get basic information about a file and prepare it for downloading. For the moment, bots can download files of up to 20MB in size. On success, a File object is returned. The file can then be downloaded via the link https://api.telegram.org/file/bot<token>/<file_path>, where <file_path> is taken from the response. It is guaranteed that the link will be valid for at least 1 hour. When the link expires, a new one can be requested by calling getFile again.
/// Note: This function may not preserve the original file name and MIME type. You should save the file's MIME type and name (if available) when the File object is received.
/// Reference: https://core.telegram.org/bots/api#getfile
pub const GetFile = struct {
    pub const api_method_name = "getFile";
    pub const ReturnType = types.File;

    /// File identifier to get information about
    file_id: []const u8,
};

/// Use this method to get custom emoji stickers, which can be used as a forum topic icon by any user. Requires no parameters. Returns an Array of Sticker objects.
/// Reference: https://core.telegram.org/bots/api#getforumtopiciconstickers
pub const GetForumTopicIconStickers = struct {
    pub const api_method_name = "getForumTopicIconStickers";
    pub const ReturnType = []const types.Sticker;
};

/// Use this method to get data for high score tables. Will return the score of the specified user and several of their neighbors in a game. Returns an Array of GameHighScore objects.
/// Reference: https://core.telegram.org/bots/api#getgamehighscores
pub const GetGameHighScores = struct {
    pub const api_method_name = "getGameHighScores";
    pub const ReturnType = []const types.GameHighScore;

    /// Target user id
    user_id: i64,
    /// Required if inline_message_id is not specified. Unique identifier for the target chat.
    chat_id: ?i64 = null,
    /// Required if inline_message_id is not specified. Identifier of the sent message.
    message_id: ?i64 = null,
    /// Required if chat_id and message_id are not specified. Identifier of the inline message.
    inline_message_id: ?[]const u8 = null,
};

/// Use this method to get the access settings of a managed bot. Returns a BotAccessSettings object on success.
/// Reference: https://core.telegram.org/bots/api#getmanagedbotaccesssettings
pub const GetManagedBotAccessSettings = struct {
    pub const api_method_name = "getManagedBotAccessSettings";
    pub const ReturnType = types.BotAccessSettings;

    /// User identifier of the managed bot whose access settings will be returned
    user_id: i64,
};

/// Use this method to get the token of a managed bot. Returns the token as String on success.
/// Reference: https://core.telegram.org/bots/api#getmanagedbottoken
pub const GetManagedBotToken = struct {
    pub const api_method_name = "getManagedBotToken";
    pub const ReturnType = []const u8;

    /// User identifier of the managed bot whose token will be returned
    user_id: i64,
};

/// A simple method for testing your bot's authentication token. Requires no parameters. Returns basic information about the bot in form of a User object.
/// Reference: https://core.telegram.org/bots/api#getme
pub const GetMe = struct {
    pub const api_method_name = "getMe";
    pub const ReturnType = types.User;
};

/// Use this method to get the current list of the bot's commands for the given scope and user language. Returns an Array of BotCommand objects. If commands aren't set, an empty list is returned.
/// Reference: https://core.telegram.org/bots/api#getmycommands
pub const GetMyCommands = struct {
    pub const api_method_name = "getMyCommands";
    pub const ReturnType = []const types.BotCommand;

    /// A JSON-serialized object, describing scope of users. Defaults to BotCommandScopeDefault.
    scope: ?types.BotCommandScope = null,
    /// A two-letter ISO 639-1 language code or an empty string
    language_code: ?[]const u8 = null,
};

/// Use this method to get the current default administrator rights of the bot. Returns ChatAdministratorRights on success.
/// Reference: https://core.telegram.org/bots/api#getmydefaultadministratorrights
pub const GetMyDefaultAdministratorRights = struct {
    pub const api_method_name = "getMyDefaultAdministratorRights";
    pub const ReturnType = types.ChatAdministratorRights;

    /// Pass True to get default administrator rights of the bot in channels. Otherwise, default administrator rights of the bot for groups and supergroups will be returned.
    for_channels: ?bool = null,
};

/// Use this method to get the current bot description for the given user language. Returns BotDescription on success.
/// Reference: https://core.telegram.org/bots/api#getmydescription
pub const GetMyDescription = struct {
    pub const api_method_name = "getMyDescription";
    pub const ReturnType = types.BotDescription;

    /// A two-letter ISO 639-1 language code or an empty string
    language_code: ?[]const u8 = null,
};

/// Use this method to get the current bot name for the given user language. Returns BotName on success.
/// Reference: https://core.telegram.org/bots/api#getmyname
pub const GetMyName = struct {
    pub const api_method_name = "getMyName";
    pub const ReturnType = types.BotName;

    /// A two-letter ISO 639-1 language code or an empty string
    language_code: ?[]const u8 = null,
};

/// Use this method to get the current bot short description for the given user language. Returns BotShortDescription on success.
/// Reference: https://core.telegram.org/bots/api#getmyshortdescription
pub const GetMyShortDescription = struct {
    pub const api_method_name = "getMyShortDescription";
    pub const ReturnType = types.BotShortDescription;

    /// A two-letter ISO 639-1 language code or an empty string
    language_code: ?[]const u8 = null,
};

/// A method to get the current Telegram Stars balance of the bot. Requires no parameters. On success, returns a StarAmount object.
/// Reference: https://core.telegram.org/bots/api#getmystarbalance
pub const GetMyStarBalance = struct {
    pub const api_method_name = "getMyStarBalance";
    pub const ReturnType = types.StarAmount;
};

/// Returns the bot's Telegram Star transactions in chronological order. On success, returns a StarTransactions object.
/// Reference: https://core.telegram.org/bots/api#getstartransactions
pub const GetStarTransactions = struct {
    pub const api_method_name = "getStarTransactions";
    pub const ReturnType = types.StarTransactions;

    /// Number of transactions to skip in the response
    offset: ?i64 = null,
    /// The maximum number of transactions to be retrieved. Values between 1-100 are accepted. Defaults to 100.
    limit: ?i64 = null,
};

/// Use this method to get a sticker set. On success, a StickerSet object is returned.
/// Reference: https://core.telegram.org/bots/api#getstickerset
pub const GetStickerSet = struct {
    pub const api_method_name = "getStickerSet";
    pub const ReturnType = types.StickerSet;

    /// Name of the sticker set
    name: []const u8,
};

/// Use this method to receive incoming updates using long polling (wiki). Returns an Array of Update objects.
/// Reference: https://core.telegram.org/bots/api#getupdates
pub const GetUpdates = struct {
    pub const api_method_name = "getUpdates";
    pub const ReturnType = []const types.Update;

    /// Identifier of the first update to be returned. Must be greater by one than the highest among the identifiers of previously received updates. By default, updates starting with the earliest unconfirmed update are returned. An update is considered confirmed as soon as getUpdates is called with an offset higher than its update_id. The negative offset can be specified to retrieve updates starting from -offset update from the end of the updates queue. All previous updates will be forgotten.
    offset: ?i64 = null,
    /// Limits the number of updates to be retrieved. Values between 1-100 are accepted. Defaults to 100.
    limit: ?i64 = null,
    /// Timeout in seconds for long polling. Defaults to 0, i.e. usual short polling. Should be positive, short polling should be used for testing purposes only.
    timeout: ?i64 = null,
    /// A JSON-serialized list of the update types you want your bot to receive. For example, specify ["message", "edited_channel_post", "callback_query"] to only receive updates of these types. See Update for a complete list of available update types. Specify an empty list to receive all update types except chat_member, message_reaction, and message_reaction_count (default). If not specified, the previous setting will be used. Please note that this parameter doesn't affect updates created before the call to getUpdates, so unwanted updates may be received for a short period of time.
    allowed_updates: ?[]const []const u8 = null,
};

/// Use this method to get the list of boosts added to a chat by a user. Requires administrator rights in the chat. Returns a UserChatBoosts object.
/// Reference: https://core.telegram.org/bots/api#getuserchatboosts
pub const GetUserChatBoosts = struct {
    pub const api_method_name = "getUserChatBoosts";
    pub const ReturnType = types.UserChatBoosts;

    /// Unique identifier for the chat or username of the channel in the format @username
    chat_id: ChatId,
    /// Unique identifier of the target user
    user_id: i64,
};

/// Returns the gifts owned and hosted by a user. Returns OwnedGifts on success.
/// Reference: https://core.telegram.org/bots/api#getusergifts
pub const GetUserGifts = struct {
    pub const api_method_name = "getUserGifts";
    pub const ReturnType = types.OwnedGifts;

    /// Unique identifier of the user
    user_id: i64,
    /// Pass True to exclude gifts that can be purchased an unlimited number of times
    exclude_unlimited: ?bool = null,
    /// Pass True to exclude gifts that can be purchased a limited number of times and can be upgraded to unique
    exclude_limited_upgradable: ?bool = null,
    /// Pass True to exclude gifts that can be purchased a limited number of times and can't be upgraded to unique
    exclude_limited_non_upgradable: ?bool = null,
    /// Pass True to exclude gifts that were assigned from the TON blockchain and can't be resold or transferred in Telegram
    exclude_from_blockchain: ?bool = null,
    /// Pass True to exclude unique gifts
    exclude_unique: ?bool = null,
    /// Pass True to sort results by gift price instead of send date. Sorting is applied before pagination.
    sort_by_price: ?bool = null,
    /// Offset of the first entry to return as received from the previous request; use an empty string to get the first chunk of results
    offset: ?[]const u8 = null,
    /// The maximum number of gifts to be returned; 1-100. Defaults to 100.
    limit: ?i64 = null,
};

/// Use this method to get the last messages from the personal chat (i.e., the chat currently added to their profile) of a given user. On success, an Array of Message objects is returned.
/// Reference: https://core.telegram.org/bots/api#getuserpersonalchatmessages
pub const GetUserPersonalChatMessages = struct {
    pub const api_method_name = "getUserPersonalChatMessages";
    pub const ReturnType = []const types.Message;

    /// Unique identifier for the target user
    user_id: i64,
    /// The maximum number of messages to return; 1-20
    limit: i64,
};

/// Use this method to get a list of profile audios for a user. Returns a UserProfileAudios object.
/// Reference: https://core.telegram.org/bots/api#getuserprofileaudios
pub const GetUserProfileAudios = struct {
    pub const api_method_name = "getUserProfileAudios";
    pub const ReturnType = types.UserProfileAudios;

    /// Unique identifier of the target user
    user_id: i64,
    /// Sequential number of the first audio to be returned. By default, all audios are returned.
    offset: ?i64 = null,
    /// Limits the number of audios to be retrieved. Values between 1-100 are accepted. Defaults to 100.
    limit: ?i64 = null,
};

/// Use this method to get a list of profile pictures for a user. Returns a UserProfilePhotos object.
/// Reference: https://core.telegram.org/bots/api#getuserprofilephotos
pub const GetUserProfilePhotos = struct {
    pub const api_method_name = "getUserProfilePhotos";
    pub const ReturnType = types.UserProfilePhotos;

    /// Unique identifier of the target user
    user_id: i64,
    /// Sequential number of the first photo to be returned. By default, all photos are returned.
    offset: ?i64 = null,
    /// Limits the number of photos to be retrieved. Values between 1-100 are accepted. Defaults to 100.
    limit: ?i64 = null,
};

/// Use this method to get current webhook status. Requires no parameters. On success, returns a WebhookInfo object. If the bot is using getUpdates, will return an object with the url field empty.
/// Reference: https://core.telegram.org/bots/api#getwebhookinfo
pub const GetWebhookInfo = struct {
    pub const api_method_name = "getWebhookInfo";
    pub const ReturnType = types.WebhookInfo;
};

/// Gifts a Telegram Premium subscription to the given user. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#giftpremiumsubscription
pub const GiftPremiumSubscription = struct {
    pub const api_method_name = "giftPremiumSubscription";
    pub const ReturnType = bool;

    /// Unique identifier of the target user who will receive a Telegram Premium subscription
    user_id: i64,
    /// Number of months the Telegram Premium subscription will be active for the user; must be one of 3, 6, or 12
    month_count: i64,
    /// Number of Telegram Stars to pay for the Telegram Premium subscription; must be 1000 for 3 months, 1500 for 6 months, and 2500 for 12 months
    star_count: i64,
    /// Text that will be shown along with the service message about the subscription; 0-128 characters
    text: ?[]const u8 = null,
    /// Mode for parsing entities in the text. See formatting options for more details. Entities other than "bold", "italic", "underline", "strikethrough", "spoiler", "custom_emoji", and "date_time" are ignored.
    text_parse_mode: ?[]const u8 = null,
    /// A JSON-serialized list of special entities that appear in the gift text. It can be specified instead of text_parse_mode. Entities other than "bold", "italic", "underline", "strikethrough", "spoiler", "custom_emoji", and "date_time" are ignored.
    text_entities: ?[]const types.MessageEntity = null,
};

/// Use this method to hide the 'General' topic in a forum supergroup chat. The bot must be an administrator in the chat for this to work and must have the can_manage_topics administrator rights. The topic will be automatically closed if it was open. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#hidegeneralforumtopic
pub const HideGeneralForumTopic = struct {
    pub const api_method_name = "hideGeneralForumTopic";
    pub const ReturnType = bool;

    /// Unique identifier for the target chat or username of the target supergroup in the format @username
    chat_id: ChatId,
};

/// Use this method for your bot to leave a group, supergroup or channel. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#leavechat
pub const LeaveChat = struct {
    pub const api_method_name = "leaveChat";
    pub const ReturnType = bool;

    /// Unique identifier for the target chat or username of the target supergroup or channel in the format @username. Channel direct messages chats aren't supported; leave the corresponding channel instead.
    chat_id: ChatId,
};

/// Use this method to log out from the cloud Bot API server before launching the bot locally. You must log out the bot before running it locally, otherwise there is no guarantee that the bot will receive updates. After a successful call, you can immediately log in on a local server, but will not be able to log in back to the cloud Bot API server for 10 minutes. Returns True on success. Requires no parameters.
/// Reference: https://core.telegram.org/bots/api#logout
pub const LogOut = struct {
    pub const api_method_name = "logOut";
    pub const ReturnType = bool;
};

/// Use this method to add a message to the list of pinned messages in a chat. In private chats and channel direct messages chats, all non-service messages can be pinned. Conversely, the bot must be an administrator with the 'can_pin_messages' right or the 'can_edit_messages' right to pin messages in groups and channels respectively. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#pinchatmessage
pub const PinChatMessage = struct {
    pub const api_method_name = "pinChatMessage";
    pub const ReturnType = bool;

    /// Unique identifier for the target chat or username of the target channel in the format @username
    chat_id: ChatId,
    /// Identifier of a message to pin
    message_id: i64,
    /// Unique identifier of the business connection on behalf of which the message will be pinned
    business_connection_id: ?[]const u8 = null,
    /// Pass True if it is not necessary to send a notification to all chat members about the new pinned message. Notifications are always disabled in channels and private chats.
    disable_notification: ?bool = null,
};

/// Posts a story on behalf of a managed business account. Requires the can_manage_stories business bot right. Returns Story on success.
/// Reference: https://core.telegram.org/bots/api#poststory
pub const PostStory = struct {
    pub const api_method_name = "postStory";
    pub const ReturnType = types.Story;

    /// Unique identifier of the business connection
    business_connection_id: []const u8,
    /// Content of the story
    content: types.InputStoryContent,
    /// Period after which the story is moved to the archive, in seconds; must be one of 6 * 3600, 12 * 3600, 86400, or 2 * 86400
    active_period: i64,
    /// Caption of the story, 0-2048 characters after entities parsing
    caption: ?[]const u8 = null,
    /// Mode for parsing entities in the story caption. See formatting options for more details.
    parse_mode: ?types.enums.ParseMode = null,
    /// A JSON-serialized list of special entities that appear in the caption, which can be specified instead of parse_mode
    caption_entities: ?[]const types.MessageEntity = null,
    /// A JSON-serialized list of clickable areas to be shown on the story
    areas: ?[]const types.StoryArea = null,
    /// Pass True to keep the story accessible after it expires
    post_to_chat_page: ?bool = null,
    /// Pass True if the content of the story must be protected from forwarding and screenshotting
    protect_content: ?bool = null,
};

/// Use this method to promote or demote a user in a supergroup or a channel. The bot must be an administrator in the chat for this to work and must have the appropriate administrator rights. Pass False for all boolean parameters to demote a user. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#promotechatmember
pub const PromoteChatMember = struct {
    pub const api_method_name = "promoteChatMember";
    pub const ReturnType = bool;

    /// Unique identifier for the target chat or username of the target channel in the format @username
    chat_id: ChatId,
    /// Unique identifier of the target user
    user_id: i64,
    /// Pass True if the administrator's presence in the chat is hidden
    is_anonymous: ?bool = null,
    /// Pass True if the administrator can access the chat event log, get boost list, see hidden supergroup and channel members, report spam messages, ignore slow mode, and send messages to the chat without paying Telegram Stars. Implied by any other administrator privilege.
    can_manage_chat: ?bool = null,
    /// Pass True if the administrator can delete messages of other users
    can_delete_messages: ?bool = null,
    /// Pass True if the administrator can manage video chats
    can_manage_video_chats: ?bool = null,
    /// Pass True if the administrator can restrict, ban or unban chat members, or access supergroup statistics. For backward compatibility, defaults to True for promotions of channel administrators.
    can_restrict_members: ?bool = null,
    /// Pass True if the administrator can add new administrators with a subset of their own privileges or demote administrators that they have promoted, directly or indirectly (promoted by administrators that were appointed by him)
    can_promote_members: ?bool = null,
    /// Pass True if the administrator can change chat title, photo and other settings
    can_change_info: ?bool = null,
    /// Pass True if the administrator can invite new users to the chat
    can_invite_users: ?bool = null,
    /// Pass True if the administrator can post stories to the chat
    can_post_stories: ?bool = null,
    /// Pass True if the administrator can edit stories posted by other users, post stories to the chat page, pin chat stories, and access the chat's story archive
    can_edit_stories: ?bool = null,
    /// Pass True if the administrator can delete stories posted by other users
    can_delete_stories: ?bool = null,
    /// Pass True if the administrator can post messages in the channel, approve suggested posts, or access channel statistics; for channels only
    can_post_messages: ?bool = null,
    /// Pass True if the administrator can edit messages of other users and can pin messages; for channels only
    can_edit_messages: ?bool = null,
    /// Pass True if the administrator can pin messages; for supergroups only
    can_pin_messages: ?bool = null,
    /// Pass True if the user is allowed to create, rename, close, and reopen forum topics; for supergroups only
    can_manage_topics: ?bool = null,
    /// Pass True if the administrator can manage direct messages within the channel and decline suggested posts; for channels only
    can_manage_direct_messages: ?bool = null,
    /// Pass True if the administrator can edit the tags of regular members; for groups and supergroups only
    can_manage_tags: ?bool = null,
    /// Pass True if the administrator can manage chat welcome messages or directly send them in the case of bots
    can_send_welcome_messages: ?bool = null,
};

/// Marks incoming message as read on behalf of a business account. Requires the can_read_messages business bot right. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#readbusinessmessage
pub const ReadBusinessMessage = struct {
    pub const api_method_name = "readBusinessMessage";
    pub const ReturnType = bool;

    /// Unique identifier of the business connection on behalf of which to read the message
    business_connection_id: []const u8,
    /// Unique identifier of the chat in which the message was received. The chat must have been active in the last 24 hours.
    chat_id: i64,
    /// Unique identifier of the message to mark as read
    message_id: i64,
};

/// Refunds a successful payment in Telegram Stars. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#refundstarpayment
pub const RefundStarPayment = struct {
    pub const api_method_name = "refundStarPayment";
    pub const ReturnType = bool;

    /// Identifier of the user whose payment will be refunded
    user_id: i64,
    /// Telegram payment identifier
    telegram_payment_charge_id: []const u8,
};

/// Removes the current profile photo of a managed business account. Requires the can_edit_profile_photo business bot right. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#removebusinessaccountprofilephoto
pub const RemoveBusinessAccountProfilePhoto = struct {
    pub const api_method_name = "removeBusinessAccountProfilePhoto";
    pub const ReturnType = bool;

    /// Unique identifier of the business connection
    business_connection_id: []const u8,
    /// Pass True to remove the public photo, which is visible even if the main photo is hidden by the business account's privacy settings. After the main photo is removed, the previous profile photo (if present) becomes the main photo.
    is_public: ?bool = null,
};

/// Removes verification from a chat that is currently verified on behalf of the organization represented by the bot. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#removechatverification
pub const RemoveChatVerification = struct {
    pub const api_method_name = "removeChatVerification";
    pub const ReturnType = bool;

    /// Unique identifier for the target chat or username of the target bot or channel in the format @username
    chat_id: ChatId,
};

/// Removes the profile photo of the bot. Requires no parameters. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#removemyprofilephoto
pub const RemoveMyProfilePhoto = struct {
    pub const api_method_name = "removeMyProfilePhoto";
    pub const ReturnType = bool;
};

/// Removes verification from a user who is currently verified on behalf of the organization represented by the bot. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#removeuserverification
pub const RemoveUserVerification = struct {
    pub const api_method_name = "removeUserVerification";
    pub const ReturnType = bool;

    /// Unique identifier of the target user
    user_id: i64,
};

/// Use this method to reopen a closed topic in a forum supergroup chat. The bot must be an administrator in the chat for this to work and must have the can_manage_topics administrator rights, unless it is the creator of the topic. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#reopenforumtopic
pub const ReopenForumTopic = struct {
    pub const api_method_name = "reopenForumTopic";
    pub const ReturnType = bool;

    /// Unique identifier for the target chat or username of the target supergroup in the format @username
    chat_id: ChatId,
    /// Unique identifier for the target message thread of the forum topic
    message_thread_id: i64,
};

/// Use this method to reopen a closed 'General' topic in a forum supergroup chat. The bot must be an administrator in the chat for this to work and must have the can_manage_topics administrator rights. The topic will be automatically unhidden if it was hidden. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#reopengeneralforumtopic
pub const ReopenGeneralForumTopic = struct {
    pub const api_method_name = "reopenGeneralForumTopic";
    pub const ReturnType = bool;

    /// Unique identifier for the target chat or username of the target supergroup in the format @username
    chat_id: ChatId,
};

/// Use this method to revoke the current token of a managed bot and generate a new one. Returns the new token as String on success.
/// Reference: https://core.telegram.org/bots/api#replacemanagedbottoken
pub const ReplaceManagedBotToken = struct {
    pub const api_method_name = "replaceManagedBotToken";
    pub const ReturnType = []const u8;

    /// User identifier of the managed bot whose token will be replaced
    user_id: i64,
};

/// Use this method to replace an existing sticker in a sticker set with a new one. The method is equivalent to calling deleteStickerFromSet, then addStickerToSet, then setStickerPositionInSet. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#replacestickerinset
pub const ReplaceStickerInSet = struct {
    pub const api_method_name = "replaceStickerInSet";
    pub const ReturnType = bool;

    /// User identifier of the sticker set owner
    user_id: i64,
    /// Sticker set name
    name: []const u8,
    /// File identifier of the replaced sticker
    old_sticker: []const u8,
    /// A JSON-serialized object with information about the added sticker. If exactly the same sticker had already been added to the set, then the set remains unchanged.
    sticker: types.InputSticker,
};

/// Reposts a story on behalf of a business account from another business account. Both business accounts must be managed by the same bot, and the story on the source account must have been posted (or reposted) by the bot. Requires the can_manage_stories business bot right for both business accounts. Returns Story on success.
/// Reference: https://core.telegram.org/bots/api#repoststory
pub const RepostStory = struct {
    pub const api_method_name = "repostStory";
    pub const ReturnType = types.Story;

    /// Unique identifier of the business connection
    business_connection_id: []const u8,
    /// Unique identifier of the chat which posted the story that should be reposted
    from_chat_id: i64,
    /// Unique identifier of the story that should be reposted
    from_story_id: i64,
    /// Period after which the story is moved to the archive, in seconds; must be one of 6 * 3600, 12 * 3600, 86400, or 2 * 86400
    active_period: i64,
    /// Pass True to keep the story accessible after it expires
    post_to_chat_page: ?bool = null,
    /// Pass True if the content of the story must be protected from forwarding and screenshotting
    protect_content: ?bool = null,
};

/// Use this method to restrict a user in a supergroup. The bot must be an administrator in the supergroup for this to work and must have the appropriate administrator rights. Pass True for all permissions to lift restrictions from a user. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#restrictchatmember
pub const RestrictChatMember = struct {
    pub const api_method_name = "restrictChatMember";
    pub const ReturnType = bool;

    /// Unique identifier for the target chat or username of the target supergroup in the format @username
    chat_id: ChatId,
    /// Unique identifier of the target user
    user_id: i64,
    /// A JSON-serialized object for new user permissions
    permissions: types.ChatPermissions,
    /// Pass True if chat permissions are set independently. Otherwise, the can_send_other_messages and can_add_web_page_previews permissions will imply the can_send_messages, can_send_audios, can_send_documents, can_send_photos, can_send_videos, can_send_video_notes, and can_send_voice_notes permissions; the can_send_polls permission will imply the can_send_messages permission.
    use_independent_chat_permissions: ?bool = null,
    /// Date when restrictions will be lifted for the user; Unix time. If user is restricted for more than 366 days or less than 30 seconds from the current time, they are considered to be restricted forever.
    until_date: ?i64 = null,
};

/// Use this method to revoke an invite link created by the bot. If the primary link is revoked, a new link is automatically generated. The bot must be an administrator in the chat for this to work and must have the appropriate administrator rights. Returns the revoked invite link as ChatInviteLink object.
/// Reference: https://core.telegram.org/bots/api#revokechatinvitelink
pub const RevokeChatInviteLink = struct {
    pub const api_method_name = "revokeChatInviteLink";
    pub const ReturnType = types.ChatInviteLink;

    /// Unique identifier of the target chat or username of the target channel in the format @username
    chat_id: ChatId,
    /// The invite link to revoke
    invite_link: []const u8,
};

/// Stores a message that can be sent by a user of a Mini App. Returns a PreparedInlineMessage object.
/// Reference: https://core.telegram.org/bots/api#savepreparedinlinemessage
pub const SavePreparedInlineMessage = struct {
    pub const api_method_name = "savePreparedInlineMessage";
    pub const ReturnType = types.PreparedInlineMessage;

    /// Unique identifier of the target user that can use the prepared message
    user_id: i64,
    /// A JSON-serialized object describing the message to be sent
    result: types.InlineQueryResult,
    /// Pass True if the message can be sent to private chats with users
    allow_user_chats: ?bool = null,
    /// Pass True if the message can be sent to private chats with bots
    allow_bot_chats: ?bool = null,
    /// Pass True if the message can be sent to group and supergroup chats
    allow_group_chats: ?bool = null,
    /// Pass True if the message can be sent to channel chats
    allow_channel_chats: ?bool = null,
};

/// Stores a keyboard button that can be used by a user within a Mini App. Returns a PreparedKeyboardButton object.
/// Reference: https://core.telegram.org/bots/api#savepreparedkeyboardbutton
pub const SavePreparedKeyboardButton = struct {
    pub const api_method_name = "savePreparedKeyboardButton";
    pub const ReturnType = types.PreparedKeyboardButton;

    /// Unique identifier of the target user that can use the button
    user_id: i64,
    /// A JSON-serialized object describing the button to be saved. The button must be of the type request_users, request_chat, or request_managed_bot.
    button: types.KeyboardButton,
};

/// Use this method to send animation files (GIF or H.264/MPEG-4 AVC video without sound). On success, the sent Message is returned. Bots can currently send animation files of up to 50 MB in size, this limit may be changed in the future.
/// Reference: https://core.telegram.org/bots/api#sendanimation
pub const SendAnimation = struct {
    pub const api_method_name = "sendAnimation";
    pub const ReturnType = types.Message;

    /// Unique identifier for the target chat or username of the target bot, supergroup or channel in the format @username
    chat_id: ChatId,
    /// Animation to send. Pass a file_id as String to send an animation that exists on the Telegram servers (recommended), pass an HTTP URL as a String for Telegram to get an animation from the Internet, or upload a new animation using multipart/form-data. More information on Sending Files: https://core.telegram.org/bots/api#sending-files
    animation: InputFile,
    /// Unique identifier of the business connection on behalf of which the message will be sent
    business_connection_id: ?[]const u8 = null,
    /// Unique identifier for the target message thread (topic) of a forum; for forum supergroups and private chats of bots with forum topic mode enabled only
    message_thread_id: ?i64 = null,
    /// Identifier of the direct messages topic to which the message will be sent; required if the message is sent to a direct messages chat
    direct_messages_topic_id: ?i64 = null,
    /// A JSON-serialized object containing the parameters of the ephemeral message to send
    ephemeral_message_parameters: ?types.EphemeralMessageParameters = null,
    /// Duration of sent animation in seconds
    duration: ?i64 = null,
    /// Animation width
    width: ?i64 = null,
    /// Animation height
    height: ?i64 = null,
    /// Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail's width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can't be reused and can be only uploaded as a new file, so you can pass "attach://<file_attach_name>" if the thumbnail was uploaded using multipart/form-data under <file_attach_name>. More information on Sending Files: https://core.telegram.org/bots/api#sending-files
    thumbnail: ?InputFile = null,
    /// Animation caption (may also be used when resending animation by file_id), 0-1024 characters after entities parsing
    caption: ?[]const u8 = null,
    /// Mode for parsing entities in the animation caption. See formatting options for more details.
    parse_mode: ?types.enums.ParseMode = null,
    /// A JSON-serialized list of special entities that appear in the caption, which can be specified instead of parse_mode
    caption_entities: ?[]const types.MessageEntity = null,
    /// Pass True if the caption must be shown above the message media
    show_caption_above_media: ?bool = null,
    /// Pass True if the animation needs to be covered with a spoiler animation
    has_spoiler: ?bool = null,
    /// Sends the message silently. Users will receive a notification with no sound.
    disable_notification: ?bool = null,
    /// Protects the contents of the sent message from forwarding and saving
    protect_content: ?bool = null,
    /// Pass True to allow up to 1000 messages per second, ignoring broadcasting limits for a fee of 0.1 Telegram Stars per message. The relevant Stars will be withdrawn from the bot's balance.
    allow_paid_broadcast: ?bool = null,
    /// Unique identifier of the message effect to be added to the message; for private chats only
    message_effect_id: ?[]const u8 = null,
    /// A JSON-serialized object containing the parameters of the suggested post to send; for direct messages chats only. If the message is sent as a reply to another suggested post, then that suggested post is automatically declined.
    suggested_post_parameters: ?types.SuggestedPostParameters = null,
    /// Description of the message to reply to
    reply_parameters: ?types.ReplyParameters = null,
    /// Additional interface options. A JSON-serialized object for an inline keyboard, custom reply keyboard, instructions to remove a reply keyboard or to force a reply from the user.
    reply_markup: ?ReplyMarkup = null,
};

/// Use this method to send audio files, if you want Telegram clients to display them in the music player. Your audio must be in the .MP3 or .M4A format. On success, the sent Message is returned. Bots can currently send audio files of up to 50 MB in size, this limit may be changed in the future.
/// For sending voice messages, use the sendVoice method instead.
/// Reference: https://core.telegram.org/bots/api#sendaudio
pub const SendAudio = struct {
    pub const api_method_name = "sendAudio";
    pub const ReturnType = types.Message;

    /// Unique identifier for the target chat or username of the target bot, supergroup or channel in the format @username
    chat_id: ChatId,
    /// Audio file to send. Pass a file_id as String to send an audio file that exists on the Telegram servers (recommended), pass an HTTP URL as a String for Telegram to get an audio file from the Internet, or upload a new one using multipart/form-data. More information on Sending Files: https://core.telegram.org/bots/api#sending-files
    audio: InputFile,
    /// Unique identifier of the business connection on behalf of which the message will be sent
    business_connection_id: ?[]const u8 = null,
    /// Unique identifier for the target message thread (topic) of a forum; for forum supergroups and private chats of bots with forum topic mode enabled only
    message_thread_id: ?i64 = null,
    /// Identifier of the direct messages topic to which the message will be sent; required if the message is sent to a direct messages chat
    direct_messages_topic_id: ?i64 = null,
    /// A JSON-serialized object containing the parameters of the ephemeral message to send
    ephemeral_message_parameters: ?types.EphemeralMessageParameters = null,
    /// Audio caption, 0-1024 characters after entities parsing
    caption: ?[]const u8 = null,
    /// Mode for parsing entities in the audio caption. See formatting options for more details.
    parse_mode: ?types.enums.ParseMode = null,
    /// A JSON-serialized list of special entities that appear in the caption, which can be specified instead of parse_mode
    caption_entities: ?[]const types.MessageEntity = null,
    /// Duration of the audio in seconds
    duration: ?i64 = null,
    /// Performer
    performer: ?[]const u8 = null,
    /// Track name
    title: ?[]const u8 = null,
    /// Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail's width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can't be reused and can be only uploaded as a new file, so you can pass "attach://<file_attach_name>" if the thumbnail was uploaded using multipart/form-data under <file_attach_name>. More information on Sending Files: https://core.telegram.org/bots/api#sending-files
    thumbnail: ?InputFile = null,
    /// Sends the message silently. Users will receive a notification with no sound.
    disable_notification: ?bool = null,
    /// Protects the contents of the sent message from forwarding and saving
    protect_content: ?bool = null,
    /// Pass True to allow up to 1000 messages per second, ignoring broadcasting limits for a fee of 0.1 Telegram Stars per message. The relevant Stars will be withdrawn from the bot's balance.
    allow_paid_broadcast: ?bool = null,
    /// Unique identifier of the message effect to be added to the message; for private chats only
    message_effect_id: ?[]const u8 = null,
    /// A JSON-serialized object containing the parameters of the suggested post to send; for direct messages chats only. If the message is sent as a reply to another suggested post, then that suggested post is automatically declined.
    suggested_post_parameters: ?types.SuggestedPostParameters = null,
    /// Description of the message to reply to
    reply_parameters: ?types.ReplyParameters = null,
    /// Additional interface options. A JSON-serialized object for an inline keyboard, custom reply keyboard, instructions to remove a reply keyboard or to force a reply from the user.
    reply_markup: ?ReplyMarkup = null,
};

/// Use this method when you need to tell the user that something is happening on the bot's side. The status is set for 5 seconds or less (when a message arrives from your bot, Telegram clients clear its typing status). Returns True on success.
/// We only recommend using this method when a response from the bot will take a noticeable amount of time to arrive.
/// Reference: https://core.telegram.org/bots/api#sendchataction
pub const SendChatAction = struct {
    pub const api_method_name = "sendChatAction";
    pub const ReturnType = bool;

    /// Unique identifier for the target chat or username of the target bot or supergroup in the format @username. Channel chats and channel direct messages chats aren't supported.
    chat_id: ChatId,
    /// Type of action to broadcast. Choose one, depending on what the user is about to receive: typing for text messages, upload_photo for photos, record_video or upload_video for videos, record_voice or upload_voice for voice notes, upload_document for general files, choose_sticker for stickers, find_location for location data, record_video_note or upload_video_note for video notes.
    action: types.enums.ChatAction,
    /// Unique identifier of the business connection on behalf of which the action will be sent
    business_connection_id: ?[]const u8 = null,
    /// Unique identifier for the target message thread or topic of a forum; for supergroups and private chats of bots with forum topic mode enabled only
    message_thread_id: ?i64 = null,
};

/// Use this method to process a received chat join request query by showing a Mini App to the user before deciding the outcome. Call answerChatJoinRequestQuery to resolve the join request query based on the user interaction with the Mini App. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#sendchatjoinrequestwebapp
pub const SendChatJoinRequestWebApp = struct {
    pub const api_method_name = "sendChatJoinRequestWebApp";
    pub const ReturnType = bool;

    /// Unique identifier of the join request query
    chat_join_request_query_id: []const u8,
    /// An HTTPS URL of a Web App to be opened with additional data as specified in Initializing Web Apps
    web_app_url: []const u8,
};

/// Use this method to send a checklist on behalf of a connected business account. On success, the sent Message is returned.
/// Reference: https://core.telegram.org/bots/api#sendchecklist
pub const SendChecklist = struct {
    pub const api_method_name = "sendChecklist";
    pub const ReturnType = types.Message;

    /// Unique identifier of the business connection on behalf of which the message will be sent
    business_connection_id: []const u8,
    /// Unique identifier for the target chat or username of the target bot in the format @username
    chat_id: ChatId,
    /// A JSON-serialized object for the checklist to send
    checklist: types.InputChecklist,
    /// Sends the message silently. Users will receive a notification with no sound.
    disable_notification: ?bool = null,
    /// Protects the contents of the sent message from forwarding and saving
    protect_content: ?bool = null,
    /// Unique identifier of the message effect to be added to the message
    message_effect_id: ?[]const u8 = null,
    /// A JSON-serialized object for description of the message to reply to
    reply_parameters: ?types.ReplyParameters = null,
    /// A JSON-serialized object for an inline keyboard
    reply_markup: ?types.InlineKeyboardMarkup = null,
};

/// Use this method to send phone contacts. On success, the sent Message is returned.
/// Reference: https://core.telegram.org/bots/api#sendcontact
pub const SendContact = struct {
    pub const api_method_name = "sendContact";
    pub const ReturnType = types.Message;

    /// Unique identifier for the target chat or username of the target bot, supergroup or channel in the format @username
    chat_id: ChatId,
    /// Contact's phone number
    phone_number: []const u8,
    /// Contact's first name
    first_name: []const u8,
    /// Unique identifier of the business connection on behalf of which the message will be sent
    business_connection_id: ?[]const u8 = null,
    /// Unique identifier for the target message thread (topic) of a forum; for forum supergroups and private chats of bots with forum topic mode enabled only
    message_thread_id: ?i64 = null,
    /// Identifier of the direct messages topic to which the message will be sent; required if the message is sent to a direct messages chat
    direct_messages_topic_id: ?i64 = null,
    /// A JSON-serialized object containing the parameters of the ephemeral message to send
    ephemeral_message_parameters: ?types.EphemeralMessageParameters = null,
    /// Contact's last name
    last_name: ?[]const u8 = null,
    /// Additional data about the contact in the form of a vCard, 0-2048 bytes
    vcard: ?[]const u8 = null,
    /// Sends the message silently. Users will receive a notification with no sound.
    disable_notification: ?bool = null,
    /// Protects the contents of the sent message from forwarding and saving
    protect_content: ?bool = null,
    /// Pass True to allow up to 1000 messages per second, ignoring broadcasting limits for a fee of 0.1 Telegram Stars per message. The relevant Stars will be withdrawn from the bot's balance.
    allow_paid_broadcast: ?bool = null,
    /// Unique identifier of the message effect to be added to the message; for private chats only
    message_effect_id: ?[]const u8 = null,
    /// A JSON-serialized object containing the parameters of the suggested post to send; for direct messages chats only. If the message is sent as a reply to another suggested post, then that suggested post is automatically declined.
    suggested_post_parameters: ?types.SuggestedPostParameters = null,
    /// Description of the message to reply to
    reply_parameters: ?types.ReplyParameters = null,
    /// Additional interface options. A JSON-serialized object for an inline keyboard, custom reply keyboard, instructions to remove a reply keyboard or to force a reply from the user.
    reply_markup: ?ReplyMarkup = null,
};

/// Use this method to send an animated emoji that will display a random value. On success, the sent Message is returned.
/// Reference: https://core.telegram.org/bots/api#senddice
pub const SendDice = struct {
    pub const api_method_name = "sendDice";
    pub const ReturnType = types.Message;

    /// Unique identifier for the target chat or username of the target bot, supergroup or channel in the format @username
    chat_id: ChatId,
    /// Unique identifier of the business connection on behalf of which the message will be sent
    business_connection_id: ?[]const u8 = null,
    /// Unique identifier for the target message thread (topic) of a forum; for forum supergroups and private chats of bots with forum topic mode enabled only
    message_thread_id: ?i64 = null,
    /// Identifier of the direct messages topic to which the message will be sent; required if the message is sent to a direct messages chat
    direct_messages_topic_id: ?i64 = null,
    /// Emoji on which the dice throw animation is based. Currently, must be one of "🎲", "🎯", "🏀", "⚽", "🎳", or "🎰". Dice can have values 1-6 for "🎲", "🎯" and "🎳", values 1-5 for "🏀" and "⚽", and values 1-64 for "🎰". Defaults to "🎲".
    emoji: ?[]const u8 = null,
    /// Sends the message silently. Users will receive a notification with no sound.
    disable_notification: ?bool = null,
    /// Protects the contents of the sent message from forwarding
    protect_content: ?bool = null,
    /// Pass True to allow up to 1000 messages per second, ignoring broadcasting limits for a fee of 0.1 Telegram Stars per message. The relevant Stars will be withdrawn from the bot's balance.
    allow_paid_broadcast: ?bool = null,
    /// Unique identifier of the message effect to be added to the message; for private chats only
    message_effect_id: ?[]const u8 = null,
    /// A JSON-serialized object containing the parameters of the suggested post to send; for direct messages chats only. If the message is sent as a reply to another suggested post, then that suggested post is automatically declined.
    suggested_post_parameters: ?types.SuggestedPostParameters = null,
    /// Description of the message to reply to
    reply_parameters: ?types.ReplyParameters = null,
    /// Additional interface options. A JSON-serialized object for an inline keyboard, custom reply keyboard, instructions to remove a reply keyboard or to force a reply from the user.
    reply_markup: ?ReplyMarkup = null,
};

/// Use this method to send general files. On success, the sent Message is returned. Bots can currently send files of any type of up to 50 MB in size, this limit may be changed in the future.
/// Reference: https://core.telegram.org/bots/api#senddocument
pub const SendDocument = struct {
    pub const api_method_name = "sendDocument";
    pub const ReturnType = types.Message;

    /// Unique identifier for the target chat or username of the target bot, supergroup or channel in the format @username
    chat_id: ChatId,
    /// File to send. Pass a file_id as String to send a file that exists on the Telegram servers (recommended), pass an HTTP URL as a String for Telegram to get a file from the Internet, or upload a new one using multipart/form-data. More information on Sending Files: https://core.telegram.org/bots/api#sending-files
    document: InputFile,
    /// Unique identifier of the business connection on behalf of which the message will be sent
    business_connection_id: ?[]const u8 = null,
    /// Unique identifier for the target message thread (topic) of a forum; for forum supergroups and private chats of bots with forum topic mode enabled only
    message_thread_id: ?i64 = null,
    /// Identifier of the direct messages topic to which the message will be sent; required if the message is sent to a direct messages chat
    direct_messages_topic_id: ?i64 = null,
    /// A JSON-serialized object containing the parameters of the ephemeral message to send
    ephemeral_message_parameters: ?types.EphemeralMessageParameters = null,
    /// Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail's width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can't be reused and can be only uploaded as a new file, so you can pass "attach://<file_attach_name>" if the thumbnail was uploaded using multipart/form-data under <file_attach_name>. More information on Sending Files: https://core.telegram.org/bots/api#sending-files
    thumbnail: ?InputFile = null,
    /// Document caption (may also be used when resending documents by file_id), 0-1024 characters after entities parsing
    caption: ?[]const u8 = null,
    /// Mode for parsing entities in the document caption. See formatting options for more details.
    parse_mode: ?types.enums.ParseMode = null,
    /// A JSON-serialized list of special entities that appear in the caption, which can be specified instead of parse_mode
    caption_entities: ?[]const types.MessageEntity = null,
    /// Disables automatic server-side content type detection for files uploaded using multipart/form-data
    disable_content_type_detection: ?bool = null,
    /// Sends the message silently. Users will receive a notification with no sound.
    disable_notification: ?bool = null,
    /// Protects the contents of the sent message from forwarding and saving
    protect_content: ?bool = null,
    /// Pass True to allow up to 1000 messages per second, ignoring broadcasting limits for a fee of 0.1 Telegram Stars per message. The relevant Stars will be withdrawn from the bot's balance.
    allow_paid_broadcast: ?bool = null,
    /// Unique identifier of the message effect to be added to the message; for private chats only
    message_effect_id: ?[]const u8 = null,
    /// A JSON-serialized object containing the parameters of the suggested post to send; for direct messages chats only. If the message is sent as a reply to another suggested post, then that suggested post is automatically declined.
    suggested_post_parameters: ?types.SuggestedPostParameters = null,
    /// Description of the message to reply to
    reply_parameters: ?types.ReplyParameters = null,
    /// Additional interface options. A JSON-serialized object for an inline keyboard, custom reply keyboard, instructions to remove a reply keyboard or to force a reply from the user.
    reply_markup: ?ReplyMarkup = null,
};

/// Use this method to send a game. On success, the sent Message is returned.
/// Reference: https://core.telegram.org/bots/api#sendgame
pub const SendGame = struct {
    pub const api_method_name = "sendGame";
    pub const ReturnType = types.Message;

    /// Unique identifier for the target chat or username of the target bot in the format @username. Games can't be sent to channel direct messages chats and channel chats.
    chat_id: ChatId,
    /// Short name of the game, serves as the unique identifier for the game. Set up your games via @BotFather.
    game_short_name: []const u8,
    /// Unique identifier of the business connection on behalf of which the message will be sent
    business_connection_id: ?[]const u8 = null,
    /// Unique identifier for the target message thread (topic) of a forum; for forum supergroups and private chats of bots with forum topic mode enabled only
    message_thread_id: ?i64 = null,
    /// Sends the message silently. Users will receive a notification with no sound.
    disable_notification: ?bool = null,
    /// Protects the contents of the sent message from forwarding and saving
    protect_content: ?bool = null,
    /// Pass True to allow up to 1000 messages per second, ignoring broadcasting limits for a fee of 0.1 Telegram Stars per message. The relevant Stars will be withdrawn from the bot's balance.
    allow_paid_broadcast: ?bool = null,
    /// Unique identifier of the message effect to be added to the message; for private chats only
    message_effect_id: ?[]const u8 = null,
    /// Description of the message to reply to
    reply_parameters: ?types.ReplyParameters = null,
    /// A JSON-serialized object for an inline keyboard. If empty, one 'Play game_title' button will be shown. If not empty, the first button must launch the game.
    reply_markup: ?types.InlineKeyboardMarkup = null,
};

/// Sends a gift to the given user or channel chat. The gift can't be converted to Telegram Stars by the receiver. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#sendgift
pub const SendGift = struct {
    pub const api_method_name = "sendGift";
    pub const ReturnType = bool;

    /// Identifier of the gift; limited gifts can't be sent to channel chats
    gift_id: []const u8,
    /// Required if chat_id is not specified. Unique identifier of the target user who will receive the gift.
    user_id: ?i64 = null,
    /// Required if user_id is not specified. Unique identifier for the chat or username of the channel (in the format @username) that will receive the gift.
    chat_id: ?ChatId = null,
    /// Pass True to pay for the gift upgrade from the bot's balance, thereby making the upgrade free for the receiver
    pay_for_upgrade: ?bool = null,
    /// Text that will be shown along with the gift; 0-128 characters
    text: ?[]const u8 = null,
    /// Mode for parsing entities in the text. See formatting options for more details. Entities other than "bold", "italic", "underline", "strikethrough", "spoiler", "custom_emoji", and "date_time" are ignored.
    text_parse_mode: ?[]const u8 = null,
    /// A JSON-serialized list of special entities that appear in the gift text. It can be specified instead of text_parse_mode. Entities other than "bold", "italic", "underline", "strikethrough", "spoiler", "custom_emoji", and "date_time" are ignored.
    text_entities: ?[]const types.MessageEntity = null,
};

/// Use this method to send invoices. On success, the sent Message is returned.
/// Reference: https://core.telegram.org/bots/api#sendinvoice
pub const SendInvoice = struct {
    pub const api_method_name = "sendInvoice";
    pub const ReturnType = types.Message;

    /// Unique identifier for the target chat or username of the target bot, supergroup or channel in the format @username
    chat_id: ChatId,
    /// Product name, 1-32 characters
    title: []const u8,
    /// Product description, 1-255 characters
    description: []const u8,
    /// Bot-defined invoice payload, 1-128 bytes. This will not be displayed to the user, use it for your internal processes.
    payload: []const u8,
    /// Three-letter ISO 4217 currency code, see more on currencies. Pass "XTR" for payments in Telegram Stars.
    currency: []const u8,
    /// Price breakdown, a JSON-serialized list of components (e.g. product price, tax, discount, delivery cost, delivery tax, bonus, etc.). Must contain exactly one item for payments in Telegram Stars.
    prices: []const types.LabeledPrice,
    /// Unique identifier for the target message thread (topic) of a forum; for forum supergroups and private chats of bots with forum topic mode enabled only
    message_thread_id: ?i64 = null,
    /// Identifier of the direct messages topic to which the message will be sent; required if the message is sent to a direct messages chat
    direct_messages_topic_id: ?i64 = null,
    /// Payment provider token, obtained via @BotFather. Pass an empty string for payments in Telegram Stars.
    provider_token: ?[]const u8 = null,
    /// The maximum accepted amount for tips in the smallest units of the currency (integer, not float/double). For example, for a maximum tip of US$ 1.45 pass max_tip_amount = 145. See the exp parameter in currencies.json, it shows the number of digits past the decimal point for each currency (2 for the majority of currencies). Defaults to 0. Not supported for payments in Telegram Stars.
    max_tip_amount: ?i64 = null,
    /// A JSON-serialized Array of suggested amounts of tips in the smallest units of the currency (integer, not float/double). At most 4 suggested tip amounts can be specified. The suggested tip amounts must be positive, passed in a strictly increased order and must not exceed max_tip_amount.
    suggested_tip_amounts: ?[]const i64 = null,
    /// Unique deep-linking parameter. If left empty, forwarded copies of the sent message will have a Pay button, allowing multiple users to pay directly from the forwarded message, using the same invoice. If non-empty, forwarded copies of the sent message will have a URL button with a deep link to the bot (instead of a Pay button), with the value used as the start parameter.
    start_parameter: ?[]const u8 = null,
    /// JSON-serialized data about the invoice, which will be shared with the payment provider. A detailed description of required fields should be provided by the payment provider.
    provider_data: ?[]const u8 = null,
    /// URL of the product photo for the invoice. Can be a photo of the goods or a marketing image for a service. People like it better when they see what they are paying for.
    photo_url: ?[]const u8 = null,
    /// Photo size in bytes
    photo_size: ?i64 = null,
    /// Photo width
    photo_width: ?i64 = null,
    /// Photo height
    photo_height: ?i64 = null,
    /// Pass True if you require the user's full name to complete the order. Ignored for payments in Telegram Stars.
    need_name: ?bool = null,
    /// Pass True if you require the user's phone number to complete the order. Ignored for payments in Telegram Stars.
    need_phone_number: ?bool = null,
    /// Pass True if you require the user's email address to complete the order. Ignored for payments in Telegram Stars.
    need_email: ?bool = null,
    /// Pass True if you require the user's shipping address to complete the order. Ignored for payments in Telegram Stars.
    need_shipping_address: ?bool = null,
    /// Pass True if the user's phone number should be sent to the provider. Ignored for payments in Telegram Stars.
    send_phone_number_to_provider: ?bool = null,
    /// Pass True if the user's email address should be sent to the provider. Ignored for payments in Telegram Stars.
    send_email_to_provider: ?bool = null,
    /// Pass True if the final price depends on the shipping method. Ignored for payments in Telegram Stars.
    is_flexible: ?bool = null,
    /// Sends the message silently. Users will receive a notification with no sound.
    disable_notification: ?bool = null,
    /// Protects the contents of the sent message from forwarding and saving
    protect_content: ?bool = null,
    /// Pass True to allow up to 1000 messages per second, ignoring broadcasting limits for a fee of 0.1 Telegram Stars per message. The relevant Stars will be withdrawn from the bot's balance.
    allow_paid_broadcast: ?bool = null,
    /// Unique identifier of the message effect to be added to the message; for private chats only
    message_effect_id: ?[]const u8 = null,
    /// A JSON-serialized object containing the parameters of the suggested post to send; for direct messages chats only. If the message is sent as a reply to another suggested post, then that suggested post is automatically declined.
    suggested_post_parameters: ?types.SuggestedPostParameters = null,
    /// Description of the message to reply to
    reply_parameters: ?types.ReplyParameters = null,
    /// A JSON-serialized object for an inline keyboard. If empty, one 'Pay total price' button will be shown. If not empty, the first button must be a Pay button.
    reply_markup: ?types.InlineKeyboardMarkup = null,
};

/// Use this method to send live photos. On success, the sent Message is returned.
/// Reference: https://core.telegram.org/bots/api#sendlivephoto
pub const SendLivePhoto = struct {
    pub const api_method_name = "sendLivePhoto";
    pub const ReturnType = types.Message;

    /// Unique identifier for the target chat or username of the target channel (in the format @channelusername)
    chat_id: ChatId,
    /// Live photo video to send. The video must be no longer than 10 seconds and must not exceed 10 MB in size. Pass a file_id as String to send a video that exists on the Telegram servers (recommended) or upload a new video using multipart/form-data. More information on Sending Files: https://core.telegram.org/bots/api#sending-files. Sending live photos by a URL is currently unsupported.
    live_photo: InputFile,
    /// The static photo to send. Pass a file_id as String to send a photo that exists on the Telegram servers (recommended) or upload a new video using multipart/form-data. More information on Sending Files: https://core.telegram.org/bots/api#sending-files. Sending live photos by a URL is currently unsupported.
    photo: InputFile,
    /// Unique identifier of the business connection on behalf of which the message will be sent
    business_connection_id: ?[]const u8 = null,
    /// Unique identifier for the target message thread (topic) of a forum; for forum supergroups and private chats of bots with forum topic mode enabled only
    message_thread_id: ?i64 = null,
    /// Identifier of the direct messages topic to which the message will be sent; required if the message is sent to a direct messages chat
    direct_messages_topic_id: ?i64 = null,
    /// A JSON-serialized object containing the parameters of the ephemeral message to send
    ephemeral_message_parameters: ?types.EphemeralMessageParameters = null,
    /// Video caption (may also be used when resending videos by file_id), 0-1024 characters after entities parsing
    caption: ?[]const u8 = null,
    /// Mode for parsing entities in the video caption. See formatting options for more details.
    parse_mode: ?types.enums.ParseMode = null,
    /// A JSON-serialized list of special entities that appear in the caption, which can be specified instead of parse_mode
    caption_entities: ?[]const types.MessageEntity = null,
    /// Pass True if the caption must be shown above the message media
    show_caption_above_media: ?bool = null,
    /// Pass True if the video needs to be covered with a spoiler animation
    has_spoiler: ?bool = null,
    /// Sends the message silently. Users will receive a notification with no sound.
    disable_notification: ?bool = null,
    /// Protects the contents of the sent message from forwarding and saving
    protect_content: ?bool = null,
    /// Pass True to allow up to 1000 messages per second, ignoring broadcasting limits for a fee of 0.1 Telegram Stars per message. The relevant Stars will be withdrawn from the bot's balance.
    allow_paid_broadcast: ?bool = null,
    /// Unique identifier of the message effect to be added to the message; for private chats only
    message_effect_id: ?[]const u8 = null,
    /// A JSON-serialized object containing the parameters of the suggested post to send; for direct messages chats only. If the message is sent as a reply to another suggested post, then that suggested post is automatically declined.
    suggested_post_parameters: ?types.SuggestedPostParameters = null,
    /// Description of the message to reply to
    reply_parameters: ?types.ReplyParameters = null,
    /// Additional interface options. A JSON-serialized object for an inline keyboard, custom reply keyboard, instructions to remove a reply keyboard or to force a reply from the user.
    reply_markup: ?ReplyMarkup = null,
};

/// Use this method to send point on the map. On success, the sent Message is returned.
/// Reference: https://core.telegram.org/bots/api#sendlocation
pub const SendLocation = struct {
    pub const api_method_name = "sendLocation";
    pub const ReturnType = types.Message;

    /// Unique identifier for the target chat or username of the target bot, supergroup or channel in the format @username
    chat_id: ChatId,
    /// Latitude of the location
    latitude: f64,
    /// Longitude of the location
    longitude: f64,
    /// Unique identifier of the business connection on behalf of which the message will be sent
    business_connection_id: ?[]const u8 = null,
    /// Unique identifier for the target message thread (topic) of a forum; for forum supergroups and private chats of bots with forum topic mode enabled only
    message_thread_id: ?i64 = null,
    /// Identifier of the direct messages topic to which the message will be sent; required if the message is sent to a direct messages chat
    direct_messages_topic_id: ?i64 = null,
    /// A JSON-serialized object containing the parameters of the ephemeral message to send
    ephemeral_message_parameters: ?types.EphemeralMessageParameters = null,
    /// The radius of uncertainty for the location, measured in meters; 0-1500
    horizontal_accuracy: ?f64 = null,
    /// Period in seconds during which the location will be updated (see Live Locations), must be between 60 and 86400, or 0x7FFFFFFF for live locations that can be edited indefinitely. Must be 0 for ephemeral messages.
    live_period: ?i64 = null,
    /// For live locations, a direction in which the user is moving, in degrees. Must be between 1 and 360 if specified.
    heading: ?i64 = null,
    /// For live locations, a maximum distance for proximity alerts about approaching another chat member, in meters. Must be between 1 and 100000 if specified.
    proximity_alert_radius: ?i64 = null,
    /// Sends the message silently. Users will receive a notification with no sound.
    disable_notification: ?bool = null,
    /// Protects the contents of the sent message from forwarding and saving
    protect_content: ?bool = null,
    /// Pass True to allow up to 1000 messages per second, ignoring broadcasting limits for a fee of 0.1 Telegram Stars per message. The relevant Stars will be withdrawn from the bot's balance.
    allow_paid_broadcast: ?bool = null,
    /// Unique identifier of the message effect to be added to the message; for private chats only
    message_effect_id: ?[]const u8 = null,
    /// A JSON-serialized object containing the parameters of the suggested post to send; for direct messages chats only. If the message is sent as a reply to another suggested post, then that suggested post is automatically declined.
    suggested_post_parameters: ?types.SuggestedPostParameters = null,
    /// Description of the message to reply to
    reply_parameters: ?types.ReplyParameters = null,
    /// Additional interface options. A JSON-serialized object for an inline keyboard, custom reply keyboard, instructions to remove a reply keyboard or to force a reply from the user.
    reply_markup: ?ReplyMarkup = null,
};

/// Use this method to send a group of photos, live photos, videos, documents or audios as an album. Documents and audio files can be only grouped in an album with messages of the same type. On success, an Array of Message objects that were sent is returned.
/// Reference: https://core.telegram.org/bots/api#sendmediagroup
pub const SendMediaGroup = struct {
    pub const api_method_name = "sendMediaGroup";
    pub const ReturnType = []const types.Message;

    /// Unique identifier for the target chat or username of the target bot, supergroup or channel in the format @username
    chat_id: ChatId,
    /// A JSON-serialized Array describing messages to be sent, must include 2-10 items
    media: []const types.InputMedia,
    /// Unique identifier of the business connection on behalf of which the message will be sent
    business_connection_id: ?[]const u8 = null,
    /// Unique identifier for the target message thread (topic) of a forum; for forum supergroups and private chats of bots with forum topic mode enabled only
    message_thread_id: ?i64 = null,
    /// Identifier of the direct messages topic to which the messages will be sent; required if the messages are sent to a direct messages chat
    direct_messages_topic_id: ?i64 = null,
    /// Sends messages silently. Users will receive a notification with no sound.
    disable_notification: ?bool = null,
    /// Protects the contents of the sent messages from forwarding and saving
    protect_content: ?bool = null,
    /// Pass True to allow up to 1000 messages per second, ignoring broadcasting limits for a fee of 0.1 Telegram Stars per message. The relevant Stars will be withdrawn from the bot's balance.
    allow_paid_broadcast: ?bool = null,
    /// Unique identifier of the message effect to be added to the message; for private chats only
    message_effect_id: ?[]const u8 = null,
    /// Description of the message to reply to
    reply_parameters: ?types.ReplyParameters = null,
};

/// Use this method to send text messages. On success, the sent Message is returned.
/// Reference: https://core.telegram.org/bots/api#sendmessage
pub const SendMessage = struct {
    pub const api_method_name = "sendMessage";
    pub const ReturnType = types.Message;

    /// Unique identifier for the target chat or username of the target bot, supergroup or channel in the format @username
    chat_id: ChatId,
    /// Text of the message to be sent, 1-4096 characters after entities parsing
    text: []const u8,
    /// Unique identifier of the business connection on behalf of which the message will be sent
    business_connection_id: ?[]const u8 = null,
    /// Unique identifier for the target message thread (topic) of a forum; for forum supergroups and private chats of bots with forum topic mode enabled only
    message_thread_id: ?i64 = null,
    /// Identifier of the direct messages topic to which the message will be sent; required if the message is sent to a direct messages chat
    direct_messages_topic_id: ?i64 = null,
    /// A JSON-serialized object containing the parameters of the ephemeral message to send
    ephemeral_message_parameters: ?types.EphemeralMessageParameters = null,
    /// Mode for parsing entities in the message text. See formatting options for more details.
    parse_mode: ?types.enums.ParseMode = null,
    /// A JSON-serialized list of special entities that appear in message text, which can be specified instead of parse_mode
    entities: ?[]const types.MessageEntity = null,
    /// Link preview generation options for the message
    link_preview_options: ?types.LinkPreviewOptions = null,
    /// Sends the message silently. Users will receive a notification with no sound.
    disable_notification: ?bool = null,
    /// Protects the contents of the sent message from forwarding and saving
    protect_content: ?bool = null,
    /// Pass True to allow up to 1000 messages per second, ignoring broadcasting limits for a fee of 0.1 Telegram Stars per message. The relevant Stars will be withdrawn from the bot's balance.
    allow_paid_broadcast: ?bool = null,
    /// Unique identifier of the message effect to be added to the message; for private chats only
    message_effect_id: ?[]const u8 = null,
    /// A JSON-serialized object containing the parameters of the suggested post to send; for direct messages chats only. If the message is sent as a reply to another suggested post, then that suggested post is automatically declined.
    suggested_post_parameters: ?types.SuggestedPostParameters = null,
    /// Description of the message to reply to
    reply_parameters: ?types.ReplyParameters = null,
    /// Additional interface options. A JSON-serialized object for an inline keyboard, custom reply keyboard, instructions to remove a reply keyboard or to force a reply from the user.
    reply_markup: ?ReplyMarkup = null,
};

/// Use this method to stream a partial message to a user while the message is being generated. Note that the streamed draft is ephemeral and acts as a temporary 30-second preview - once the output is finalized, you must call sendMessage with the complete message to persist it in the user's chat. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#sendmessagedraft
pub const SendMessageDraft = struct {
    pub const api_method_name = "sendMessageDraft";
    pub const ReturnType = bool;

    /// Unique identifier for the target private chat
    chat_id: i64,
    /// Unique identifier of the message draft; must be non-zero. Changes to drafts with the same identifier are animated. Otherwise, the draft is replaced without animation.
    draft_id: i64,
    /// Unique identifier for the target message thread
    message_thread_id: ?i64 = null,
    /// Text of the message to be sent, 0-4096 characters after entities parsing. Pass an empty text to show a "Thinking..." placeholder.
    text: ?[]const u8 = null,
    /// Mode for parsing entities in the message text. See formatting options for more details.
    parse_mode: ?types.enums.ParseMode = null,
    /// A JSON-serialized list of special entities that appear in message text, which can be specified instead of parse_mode
    entities: ?[]const types.MessageEntity = null,
    /// Pass True to show the user a button to stop further drafts. The bot will receive an Update "stopped_message_generation" if the user presses the button.
    can_stop: ?bool = null,
    /// Pass True to keep the draft in the chat when the button is pressed. The draft will still disappear after a short time or if the bot sends a message. To fully preserve the partial draft, the bot should send it as a new message.
    keep_on_stop: ?bool = null,
};

/// Use this method to send paid media. On success, the sent Message is returned.
/// Reference: https://core.telegram.org/bots/api#sendpaidmedia
pub const SendPaidMedia = struct {
    pub const api_method_name = "sendPaidMedia";
    pub const ReturnType = types.Message;

    /// Unique identifier for the target chat or username of the target bot, supergroup or channel in the format @username. If the chat is a channel, all Telegram Star proceeds from this media will be credited to the chat's balance. Otherwise, they will be credited to the bot's balance.
    chat_id: ChatId,
    /// The number of Telegram Stars that must be paid to buy access to the media; 1-25000
    star_count: i64,
    /// A JSON-serialized Array describing the media to be sent; up to 10 items
    media: []const types.InputPaidMedia,
    /// Unique identifier of the business connection on behalf of which the message will be sent
    business_connection_id: ?[]const u8 = null,
    /// Unique identifier for the target message thread (topic) of a forum; for forum supergroups and private chats of bots with forum topic mode enabled only
    message_thread_id: ?i64 = null,
    /// Identifier of the direct messages topic to which the message will be sent; required if the message is sent to a direct messages chat
    direct_messages_topic_id: ?i64 = null,
    /// Bot-defined paid media payload, 0-128 bytes. This will not be displayed to the user, use it for your internal processes.
    payload: ?[]const u8 = null,
    /// Media caption, 0-1024 characters after entities parsing
    caption: ?[]const u8 = null,
    /// Mode for parsing entities in the media caption. See formatting options for more details.
    parse_mode: ?types.enums.ParseMode = null,
    /// A JSON-serialized list of special entities that appear in the caption, which can be specified instead of parse_mode
    caption_entities: ?[]const types.MessageEntity = null,
    /// Pass True if the caption must be shown above the message media
    show_caption_above_media: ?bool = null,
    /// Sends the message silently. Users will receive a notification with no sound.
    disable_notification: ?bool = null,
    /// Protects the contents of the sent message from forwarding and saving
    protect_content: ?bool = null,
    /// Pass True to allow up to 1000 messages per second, ignoring broadcasting limits for a fee of 0.1 Telegram Stars per message. The relevant Stars will be withdrawn from the bot's balance.
    allow_paid_broadcast: ?bool = null,
    /// A JSON-serialized object containing the parameters of the suggested post to send; for direct messages chats only. If the message is sent as a reply to another suggested post, then that suggested post is automatically declined.
    suggested_post_parameters: ?types.SuggestedPostParameters = null,
    /// Description of the message to reply to
    reply_parameters: ?types.ReplyParameters = null,
    /// Additional interface options. A JSON-serialized object for an inline keyboard, custom reply keyboard, instructions to remove a reply keyboard or to force a reply from the user.
    reply_markup: ?ReplyMarkup = null,
};

/// Use this method to send photos. On success, the sent Message is returned.
/// Reference: https://core.telegram.org/bots/api#sendphoto
pub const SendPhoto = struct {
    pub const api_method_name = "sendPhoto";
    pub const ReturnType = types.Message;

    /// Unique identifier for the target chat or username of the target bot, supergroup or channel in the format @username
    chat_id: ChatId,
    /// Photo to send. Pass a file_id as String to send a photo that exists on the Telegram servers (recommended), pass an HTTP URL as a String for Telegram to get a photo from the Internet, or upload a new photo using multipart/form-data. The photo must be at most 10 MB in size. The photo's width and height must not exceed 10000 in total. Width and height ratio must be at most 20. More information on Sending Files: https://core.telegram.org/bots/api#sending-files
    photo: InputFile,
    /// Unique identifier of the business connection on behalf of which the message will be sent
    business_connection_id: ?[]const u8 = null,
    /// Unique identifier for the target message thread (topic) of a forum; for forum supergroups and private chats of bots with forum topic mode enabled only
    message_thread_id: ?i64 = null,
    /// Identifier of the direct messages topic to which the message will be sent; required if the message is sent to a direct messages chat
    direct_messages_topic_id: ?i64 = null,
    /// A JSON-serialized object containing the parameters of the ephemeral message to send
    ephemeral_message_parameters: ?types.EphemeralMessageParameters = null,
    /// Photo caption (may also be used when resending photos by file_id), 0-1024 characters after entities parsing
    caption: ?[]const u8 = null,
    /// Mode for parsing entities in the photo caption. See formatting options for more details.
    parse_mode: ?types.enums.ParseMode = null,
    /// A JSON-serialized list of special entities that appear in the caption, which can be specified instead of parse_mode
    caption_entities: ?[]const types.MessageEntity = null,
    /// Pass True if the caption must be shown above the message media
    show_caption_above_media: ?bool = null,
    /// Pass True if the photo needs to be covered with a spoiler animation
    has_spoiler: ?bool = null,
    /// Sends the message silently. Users will receive a notification with no sound.
    disable_notification: ?bool = null,
    /// Protects the contents of the sent message from forwarding and saving
    protect_content: ?bool = null,
    /// Pass True to allow up to 1000 messages per second, ignoring broadcasting limits for a fee of 0.1 Telegram Stars per message. The relevant Stars will be withdrawn from the bot's balance.
    allow_paid_broadcast: ?bool = null,
    /// Unique identifier of the message effect to be added to the message; for private chats only
    message_effect_id: ?[]const u8 = null,
    /// A JSON-serialized object containing the parameters of the suggested post to send; for direct messages chats only. If the message is sent as a reply to another suggested post, then that suggested post is automatically declined.
    suggested_post_parameters: ?types.SuggestedPostParameters = null,
    /// Description of the message to reply to
    reply_parameters: ?types.ReplyParameters = null,
    /// Additional interface options. A JSON-serialized object for an inline keyboard, custom reply keyboard, instructions to remove a reply keyboard or to force a reply from the user.
    reply_markup: ?ReplyMarkup = null,
};

/// Use this method to send a native poll. On success, the sent Message is returned.
/// Reference: https://core.telegram.org/bots/api#sendpoll
pub const SendPoll = struct {
    pub const api_method_name = "sendPoll";
    pub const ReturnType = types.Message;

    /// Unique identifier for the target chat or username of the target bot, supergroup or channel in the format @username. Polls can't be sent to channel direct messages chats.
    chat_id: ChatId,
    /// Poll question, 1-300 characters
    question: []const u8,
    /// A JSON-serialized list of 1-12 answer options
    options: []const types.InputPollOption,
    /// Unique identifier of the business connection on behalf of which the message will be sent
    business_connection_id: ?[]const u8 = null,
    /// Unique identifier for the target message thread (topic) of a forum; for forum supergroups and private chats of bots with forum topic mode enabled only
    message_thread_id: ?i64 = null,
    /// Mode for parsing entities in the question. See formatting options for more details. Currently, only custom emoji entities are allowed.
    question_parse_mode: ?[]const u8 = null,
    /// A JSON-serialized list of special entities that appear in the poll question. It can be specified instead of question_parse_mode.
    question_entities: ?[]const types.MessageEntity = null,
    /// True, if the poll needs to be anonymous, defaults to True
    is_anonymous: ?bool = null,
    /// Poll type, "quiz" or "regular", defaults to "regular"
    type: ?[]const u8 = null,
    /// Pass True if the poll allows multiple answers, defaults to False
    allows_multiple_answers: ?bool = null,
    /// Pass True if the poll allows to change chosen answer options, defaults to False for quizzes and to True for regular polls
    allows_revoting: ?bool = null,
    /// Pass True if the poll options must be shown in random order
    shuffle_options: ?bool = null,
    /// Pass True if answer options can be added to the poll after creation; not supported for anonymous polls and quizzes
    allow_adding_options: ?bool = null,
    /// Pass True if poll results must be shown only after the poll closes
    hide_results_until_closes: ?bool = null,
    /// Pass True if voting is limited to users who have been members of the chat where the poll is being sent for more than 24 hours; for channel chats only
    members_only: ?bool = null,
    /// A JSON-serialized list of 0-12 two-letter ISO 3166-1 alpha-2 country codes indicating the countries from which users can vote in the poll; for channel chats only. Use "FT" as a country code to allow users with anonymous numbers to vote. If omitted or empty, then users from any country can participate in the poll.
    country_codes: ?[]const []const u8 = null,
    /// A JSON-serialized list of monotonically increasing 0-based identifiers of the correct answer options, required for polls in quiz mode
    correct_option_ids: ?[]const i64 = null,
    /// Text that is shown when a user chooses an incorrect answer or taps on the lamp icon in a quiz-style poll, 0-200 characters with at most 2 line feeds after entities parsing
    explanation: ?[]const u8 = null,
    /// Mode for parsing entities in the explanation. See formatting options for more details.
    explanation_parse_mode: ?[]const u8 = null,
    /// A JSON-serialized list of special entities that appear in the poll explanation. It can be specified instead of explanation_parse_mode.
    explanation_entities: ?[]const types.MessageEntity = null,
    /// Media added to the quiz explanation
    explanation_media: ?types.InputPollMedia = null,
    /// Amount of time in seconds the poll will be active after creation, 5-2628000. Can't be used together with close_date.
    open_period: ?i64 = null,
    /// Point in time (Unix timestamp) when the poll will be automatically closed. Must be at least 5 and no more than 2628000 seconds in the future. Can't be used together with open_period.
    close_date: ?i64 = null,
    /// Pass True if the poll needs to be immediately closed. This can be useful for poll preview.
    is_closed: ?bool = null,
    /// Description of the poll to be sent, 0-1024 characters after entities parsing
    description: ?[]const u8 = null,
    /// Mode for parsing entities in the poll description. See formatting options for more details.
    description_parse_mode: ?[]const u8 = null,
    /// A JSON-serialized list of special entities that appear in the poll description, which can be specified instead of description_parse_mode
    description_entities: ?[]const types.MessageEntity = null,
    /// Media added to the poll description
    media: ?types.InputPollMedia = null,
    /// Sends the message silently. Users will receive a notification with no sound.
    disable_notification: ?bool = null,
    /// Protects the contents of the sent message from forwarding and saving
    protect_content: ?bool = null,
    /// Pass True to allow up to 1000 messages per second, ignoring broadcasting limits for a fee of 0.1 Telegram Stars per message. The relevant Stars will be withdrawn from the bot's balance.
    allow_paid_broadcast: ?bool = null,
    /// Unique identifier of the message effect to be added to the message; for private chats only
    message_effect_id: ?[]const u8 = null,
    /// Description of the message to reply to
    reply_parameters: ?types.ReplyParameters = null,
    /// Additional interface options. A JSON-serialized object for an inline keyboard, custom reply keyboard, instructions to remove a reply keyboard or to force a reply from the user.
    reply_markup: ?ReplyMarkup = null,
};

/// Use this method to send rich messages. If the message contains a block with a media element, then the bot must have the right to send the media to the chat. On success, the sent Message is returned.
/// Reference: https://core.telegram.org/bots/api#sendrichmessage
pub const SendRichMessage = struct {
    pub const api_method_name = "sendRichMessage";
    pub const ReturnType = types.Message;

    /// Unique identifier for the target chat or username of the target bot, supergroup or channel in the format @username
    chat_id: ChatId,
    /// The message to be sent
    rich_message: types.InputRichMessage,
    /// Unique identifier of the business connection on behalf of which the message will be sent. Bot can send rich messages on behalf of a business account only if the corresponding user can send rich messages.
    business_connection_id: ?[]const u8 = null,
    /// Unique identifier for the target message thread (topic) of a forum; for forum supergroups and private chats of bots with forum topic mode enabled only
    message_thread_id: ?i64 = null,
    /// Identifier of the direct messages topic to which the message will be sent; required if the message is sent to a direct messages chat
    direct_messages_topic_id: ?i64 = null,
    /// A JSON-serialized object containing the parameters of the ephemeral message to send
    ephemeral_message_parameters: ?types.EphemeralMessageParameters = null,
    /// Sends the message silently. Users will receive a notification with no sound.
    disable_notification: ?bool = null,
    /// Protects the contents of the sent message from forwarding and saving
    protect_content: ?bool = null,
    /// Pass True to allow up to 1000 messages per second, ignoring broadcasting limits for a fee of 0.1 Telegram Stars per message. The relevant Stars will be withdrawn from the bot's balance.
    allow_paid_broadcast: ?bool = null,
    /// Unique identifier of the message effect to be added to the message; for private chats only
    message_effect_id: ?[]const u8 = null,
    /// A JSON-serialized object containing the parameters of the suggested post to send; for direct messages chats only. If the message is sent as a reply to another suggested post, then that suggested post is automatically declined.
    suggested_post_parameters: ?types.SuggestedPostParameters = null,
    /// Description of the message to reply to
    reply_parameters: ?types.ReplyParameters = null,
    /// Additional interface options. A JSON-serialized object for an inline keyboard, custom reply keyboard, instructions to remove a reply keyboard or to force a reply from the user.
    reply_markup: ?ReplyMarkup = null,
};

/// Use this method to stream a partial rich message to a user while the message is being generated. Note that the streamed draft is ephemeral and acts as a temporary 30-second preview - once the output is finalized, you must call sendRichMessage with the complete message to persist it in the user's chat. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#sendrichmessagedraft
pub const SendRichMessageDraft = struct {
    pub const api_method_name = "sendRichMessageDraft";
    pub const ReturnType = bool;

    /// Unique identifier for the target private chat
    chat_id: i64,
    /// Unique identifier of the message draft; must be non-zero. Changes to drafts with the same identifier are animated. Otherwise, the draft is replaced without animation.
    draft_id: i64,
    /// The partial message to be streamed. Direct upload of new files and explicit upload of files by a URL isn't supported.
    rich_message: types.InputRichMessage,
    /// Unique identifier for the target message thread
    message_thread_id: ?i64 = null,
    /// Pass True to show the user a button to stop further drafts. The bot will receive an Update "stopped_message_generation" if the user presses the button.
    can_stop: ?bool = null,
    /// Pass True to keep the draft in the chat when the button is pressed. The draft will still disappear after a short time or if the bot sends a message. To fully preserve the partial draft, the bot should send it as a new message.
    keep_on_stop: ?bool = null,
};

/// Use this method to send static .WEBP, animated .TGS, or video .WEBM stickers. On success, the sent Message is returned.
/// Reference: https://core.telegram.org/bots/api#sendsticker
pub const SendSticker = struct {
    pub const api_method_name = "sendSticker";
    pub const ReturnType = types.Message;

    /// Unique identifier for the target chat or username of the target bot, supergroup or channel in the format @username
    chat_id: ChatId,
    /// Sticker to send. Pass a file_id as String to send a file that exists on the Telegram servers (recommended), pass an HTTP URL as a String for Telegram to get a .WEBP sticker from the Internet, or upload a new .WEBP, .TGS, or .WEBM sticker using multipart/form-data. More information on Sending Files: https://core.telegram.org/bots/api#sending-files. Video and animated stickers can't be sent via an HTTP URL.
    sticker: InputFile,
    /// Unique identifier of the business connection on behalf of which the message will be sent
    business_connection_id: ?[]const u8 = null,
    /// Unique identifier for the target message thread (topic) of a forum; for forum supergroups and private chats of bots with forum topic mode enabled only
    message_thread_id: ?i64 = null,
    /// Identifier of the direct messages topic to which the message will be sent; required if the message is sent to a direct messages chat
    direct_messages_topic_id: ?i64 = null,
    /// A JSON-serialized object containing the parameters of the ephemeral message to send
    ephemeral_message_parameters: ?types.EphemeralMessageParameters = null,
    /// Emoji associated with the sticker; only for just uploaded stickers
    emoji: ?[]const u8 = null,
    /// Sends the message silently. Users will receive a notification with no sound.
    disable_notification: ?bool = null,
    /// Protects the contents of the sent message from forwarding and saving
    protect_content: ?bool = null,
    /// Pass True to allow up to 1000 messages per second, ignoring broadcasting limits for a fee of 0.1 Telegram Stars per message. The relevant Stars will be withdrawn from the bot's balance.
    allow_paid_broadcast: ?bool = null,
    /// Unique identifier of the message effect to be added to the message; for private chats only
    message_effect_id: ?[]const u8 = null,
    /// A JSON-serialized object containing the parameters of the suggested post to send; for direct messages chats only. If the message is sent as a reply to another suggested post, then that suggested post is automatically declined.
    suggested_post_parameters: ?types.SuggestedPostParameters = null,
    /// Description of the message to reply to
    reply_parameters: ?types.ReplyParameters = null,
    /// Additional interface options. A JSON-serialized object for an inline keyboard, custom reply keyboard, instructions to remove a reply keyboard or to force a reply from the user.
    reply_markup: ?ReplyMarkup = null,
};

/// Use this method to send information about a venue. On success, the sent Message is returned.
/// Reference: https://core.telegram.org/bots/api#sendvenue
pub const SendVenue = struct {
    pub const api_method_name = "sendVenue";
    pub const ReturnType = types.Message;

    /// Unique identifier for the target chat or username of the target bot, supergroup or channel in the format @username
    chat_id: ChatId,
    /// Latitude of the venue
    latitude: f64,
    /// Longitude of the venue
    longitude: f64,
    /// Name of the venue
    title: []const u8,
    /// Address of the venue
    address: []const u8,
    /// Unique identifier of the business connection on behalf of which the message will be sent
    business_connection_id: ?[]const u8 = null,
    /// Unique identifier for the target message thread (topic) of a forum; for forum supergroups and private chats of bots with forum topic mode enabled only
    message_thread_id: ?i64 = null,
    /// Identifier of the direct messages topic to which the message will be sent; required if the message is sent to a direct messages chat
    direct_messages_topic_id: ?i64 = null,
    /// A JSON-serialized object containing the parameters of the ephemeral message to send
    ephemeral_message_parameters: ?types.EphemeralMessageParameters = null,
    /// Foursquare identifier of the venue
    foursquare_id: ?[]const u8 = null,
    /// Foursquare type of the venue, if known. (For example, "arts_entertainment/default", "arts_entertainment/aquarium" or "food/icecream".)
    foursquare_type: ?[]const u8 = null,
    /// Google Places identifier of the venue
    google_place_id: ?[]const u8 = null,
    /// Google Places type of the venue. (See supported types.)
    google_place_type: ?[]const u8 = null,
    /// Sends the message silently. Users will receive a notification with no sound.
    disable_notification: ?bool = null,
    /// Protects the contents of the sent message from forwarding and saving
    protect_content: ?bool = null,
    /// Pass True to allow up to 1000 messages per second, ignoring broadcasting limits for a fee of 0.1 Telegram Stars per message. The relevant Stars will be withdrawn from the bot's balance.
    allow_paid_broadcast: ?bool = null,
    /// Unique identifier of the message effect to be added to the message; for private chats only
    message_effect_id: ?[]const u8 = null,
    /// A JSON-serialized object containing the parameters of the suggested post to send; for direct messages chats only. If the message is sent as a reply to another suggested post, then that suggested post is automatically declined.
    suggested_post_parameters: ?types.SuggestedPostParameters = null,
    /// Description of the message to reply to
    reply_parameters: ?types.ReplyParameters = null,
    /// Additional interface options. A JSON-serialized object for an inline keyboard, custom reply keyboard, instructions to remove a reply keyboard or to force a reply from the user.
    reply_markup: ?ReplyMarkup = null,
};

/// Use this method to send video files, Telegram clients support MPEG4 videos (other formats may be sent as Document). On success, the sent Message is returned. Bots can currently send video files of up to 50 MB in size, this limit may be changed in the future.
/// Reference: https://core.telegram.org/bots/api#sendvideo
pub const SendVideo = struct {
    pub const api_method_name = "sendVideo";
    pub const ReturnType = types.Message;

    /// Unique identifier for the target chat or username of the target bot, supergroup or channel in the format @username
    chat_id: ChatId,
    /// Video to send. Pass a file_id as String to send a video that exists on the Telegram servers (recommended), pass an HTTP URL as a String for Telegram to get a video from the Internet, or upload a new video using multipart/form-data. More information on Sending Files: https://core.telegram.org/bots/api#sending-files
    video: InputFile,
    /// Unique identifier of the business connection on behalf of which the message will be sent
    business_connection_id: ?[]const u8 = null,
    /// Unique identifier for the target message thread (topic) of a forum; for forum supergroups and private chats of bots with forum topic mode enabled only
    message_thread_id: ?i64 = null,
    /// Identifier of the direct messages topic to which the message will be sent; required if the message is sent to a direct messages chat
    direct_messages_topic_id: ?i64 = null,
    /// A JSON-serialized object containing the parameters of the ephemeral message to send
    ephemeral_message_parameters: ?types.EphemeralMessageParameters = null,
    /// Duration of sent video in seconds
    duration: ?i64 = null,
    /// Video width
    width: ?i64 = null,
    /// Video height
    height: ?i64 = null,
    /// Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail's width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can't be reused and can be only uploaded as a new file, so you can pass "attach://<file_attach_name>" if the thumbnail was uploaded using multipart/form-data under <file_attach_name>. More information on Sending Files: https://core.telegram.org/bots/api#sending-files
    thumbnail: ?InputFile = null,
    /// Cover for the video in the message. Pass a file_id to send a file that exists on the Telegram servers (recommended), pass an HTTP URL for Telegram to get a file from the Internet, or pass "attach://<file_attach_name>" to upload a new one using multipart/form-data under <file_attach_name> name. More information on Sending Files: https://core.telegram.org/bots/api#sending-files
    cover: ?InputFile = null,
    /// Start timestamp for the video in the message
    start_timestamp: ?i64 = null,
    /// Video caption (may also be used when resending videos by file_id), 0-1024 characters after entities parsing
    caption: ?[]const u8 = null,
    /// Mode for parsing entities in the video caption. See formatting options for more details.
    parse_mode: ?types.enums.ParseMode = null,
    /// A JSON-serialized list of special entities that appear in the caption, which can be specified instead of parse_mode
    caption_entities: ?[]const types.MessageEntity = null,
    /// Pass True if the caption must be shown above the message media
    show_caption_above_media: ?bool = null,
    /// Pass True if the video needs to be covered with a spoiler animation
    has_spoiler: ?bool = null,
    /// Pass True if the uploaded video is suitable for streaming
    supports_streaming: ?bool = null,
    /// Sends the message silently. Users will receive a notification with no sound.
    disable_notification: ?bool = null,
    /// Protects the contents of the sent message from forwarding and saving
    protect_content: ?bool = null,
    /// Pass True to allow up to 1000 messages per second, ignoring broadcasting limits for a fee of 0.1 Telegram Stars per message. The relevant Stars will be withdrawn from the bot's balance.
    allow_paid_broadcast: ?bool = null,
    /// Unique identifier of the message effect to be added to the message; for private chats only
    message_effect_id: ?[]const u8 = null,
    /// A JSON-serialized object containing the parameters of the suggested post to send; for direct messages chats only. If the message is sent as a reply to another suggested post, then that suggested post is automatically declined.
    suggested_post_parameters: ?types.SuggestedPostParameters = null,
    /// Description of the message to reply to
    reply_parameters: ?types.ReplyParameters = null,
    /// Additional interface options. A JSON-serialized object for an inline keyboard, custom reply keyboard, instructions to remove a reply keyboard or to force a reply from the user.
    reply_markup: ?ReplyMarkup = null,
};

/// Use this method to send a rounded square MPEG4 video of up to 1 minute long. On success, the sent Message is returned.
/// Reference: https://core.telegram.org/bots/api#sendvideonote
pub const SendVideoNote = struct {
    pub const api_method_name = "sendVideoNote";
    pub const ReturnType = types.Message;

    /// Unique identifier for the target chat or username of the target bot, supergroup or channel in the format @username
    chat_id: ChatId,
    /// Video note to send. Pass a file_id as String to send a video note that exists on the Telegram servers (recommended) or upload a new video using multipart/form-data. More information on Sending Files: https://core.telegram.org/bots/api#sending-files. Sending video notes by a URL is currently unsupported.
    video_note: InputFile,
    /// Unique identifier of the business connection on behalf of which the message will be sent
    business_connection_id: ?[]const u8 = null,
    /// Unique identifier for the target message thread (topic) of a forum; for forum supergroups and private chats of bots with forum topic mode enabled only
    message_thread_id: ?i64 = null,
    /// Identifier of the direct messages topic to which the message will be sent; required if the message is sent to a direct messages chat
    direct_messages_topic_id: ?i64 = null,
    /// A JSON-serialized object containing the parameters of the ephemeral message to send
    ephemeral_message_parameters: ?types.EphemeralMessageParameters = null,
    /// Duration of sent video in seconds
    duration: ?i64 = null,
    /// Video width and height, i.e. diameter of the video message
    length: ?i64 = null,
    /// Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail's width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can't be reused and can be only uploaded as a new file, so you can pass "attach://<file_attach_name>" if the thumbnail was uploaded using multipart/form-data under <file_attach_name>. More information on Sending Files: https://core.telegram.org/bots/api#sending-files
    thumbnail: ?InputFile = null,
    /// Sends the message silently. Users will receive a notification with no sound.
    disable_notification: ?bool = null,
    /// Protects the contents of the sent message from forwarding and saving
    protect_content: ?bool = null,
    /// Pass True to allow up to 1000 messages per second, ignoring broadcasting limits for a fee of 0.1 Telegram Stars per message. The relevant Stars will be withdrawn from the bot's balance.
    allow_paid_broadcast: ?bool = null,
    /// Unique identifier of the message effect to be added to the message; for private chats only
    message_effect_id: ?[]const u8 = null,
    /// A JSON-serialized object containing the parameters of the suggested post to send; for direct messages chats only. If the message is sent as a reply to another suggested post, then that suggested post is automatically declined.
    suggested_post_parameters: ?types.SuggestedPostParameters = null,
    /// Description of the message to reply to
    reply_parameters: ?types.ReplyParameters = null,
    /// Additional interface options. A JSON-serialized object for an inline keyboard, custom reply keyboard, instructions to remove a reply keyboard or to force a reply from the user.
    reply_markup: ?ReplyMarkup = null,
};

/// Use this method to send audio files, if you want Telegram clients to display the file as a playable voice message. For this to work, your audio must be in an .OGG file encoded with OPUS, or in .MP3 format, or in .M4A format (other formats may be sent as Audio or Document). On success, the sent Message is returned. Bots can currently send voice messages of up to 50 MB in size, this limit may be changed in the future.
/// Reference: https://core.telegram.org/bots/api#sendvoice
pub const SendVoice = struct {
    pub const api_method_name = "sendVoice";
    pub const ReturnType = types.Message;

    /// Unique identifier for the target chat or username of the target bot, supergroup or channel in the format @username
    chat_id: ChatId,
    /// Audio file to send. Pass a file_id as String to send a file that exists on the Telegram servers (recommended), pass an HTTP URL as a String for Telegram to get a file from the Internet, or upload a new one using multipart/form-data. More information on Sending Files: https://core.telegram.org/bots/api#sending-files
    voice: InputFile,
    /// Unique identifier of the business connection on behalf of which the message will be sent
    business_connection_id: ?[]const u8 = null,
    /// Unique identifier for the target message thread (topic) of a forum; for forum supergroups and private chats of bots with forum topic mode enabled only
    message_thread_id: ?i64 = null,
    /// Identifier of the direct messages topic to which the message will be sent; required if the message is sent to a direct messages chat
    direct_messages_topic_id: ?i64 = null,
    /// A JSON-serialized object containing the parameters of the ephemeral message to send
    ephemeral_message_parameters: ?types.EphemeralMessageParameters = null,
    /// Voice message caption, 0-1024 characters after entities parsing
    caption: ?[]const u8 = null,
    /// Mode for parsing entities in the voice message caption. See formatting options for more details.
    parse_mode: ?types.enums.ParseMode = null,
    /// A JSON-serialized list of special entities that appear in the caption, which can be specified instead of parse_mode
    caption_entities: ?[]const types.MessageEntity = null,
    /// Duration of the voice message in seconds
    duration: ?i64 = null,
    /// Sends the message silently. Users will receive a notification with no sound.
    disable_notification: ?bool = null,
    /// Protects the contents of the sent message from forwarding and saving
    protect_content: ?bool = null,
    /// Pass True to allow up to 1000 messages per second, ignoring broadcasting limits for a fee of 0.1 Telegram Stars per message. The relevant Stars will be withdrawn from the bot's balance.
    allow_paid_broadcast: ?bool = null,
    /// Unique identifier of the message effect to be added to the message; for private chats only
    message_effect_id: ?[]const u8 = null,
    /// A JSON-serialized object containing the parameters of the suggested post to send; for direct messages chats only. If the message is sent as a reply to another suggested post, then that suggested post is automatically declined.
    suggested_post_parameters: ?types.SuggestedPostParameters = null,
    /// Description of the message to reply to
    reply_parameters: ?types.ReplyParameters = null,
    /// Additional interface options. A JSON-serialized object for an inline keyboard, custom reply keyboard, instructions to remove a reply keyboard or to force a reply from the user.
    reply_markup: ?ReplyMarkup = null,
};

/// Changes the bio of a managed business account. Requires the can_change_bio business bot right. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#setbusinessaccountbio
pub const SetBusinessAccountBio = struct {
    pub const api_method_name = "setBusinessAccountBio";
    pub const ReturnType = bool;

    /// Unique identifier of the business connection
    business_connection_id: []const u8,
    /// The new value of the bio for the business account; 0-140 characters
    bio: ?[]const u8 = null,
};

/// Changes the privacy settings pertaining to incoming gifts in a managed business account. Requires the can_change_gift_settings business bot right. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#setbusinessaccountgiftsettings
pub const SetBusinessAccountGiftSettings = struct {
    pub const api_method_name = "setBusinessAccountGiftSettings";
    pub const ReturnType = bool;

    /// Unique identifier of the business connection
    business_connection_id: []const u8,
    /// Pass True if a button for sending a gift to the user or by the business account must always be shown in the input field
    show_gift_button: bool,
    /// Types of gifts accepted by the business account
    accepted_gift_types: types.AcceptedGiftTypes,
};

/// Changes the first and last name of a managed business account. Requires the can_change_name business bot right. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#setbusinessaccountname
pub const SetBusinessAccountName = struct {
    pub const api_method_name = "setBusinessAccountName";
    pub const ReturnType = bool;

    /// Unique identifier of the business connection
    business_connection_id: []const u8,
    /// The new value of the first name for the business account; 1-64 characters
    first_name: []const u8,
    /// The new value of the last name for the business account; 0-64 characters
    last_name: ?[]const u8 = null,
};

/// Changes the profile photo of a managed business account. Requires the can_edit_profile_photo business bot right. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#setbusinessaccountprofilephoto
pub const SetBusinessAccountProfilePhoto = struct {
    pub const api_method_name = "setBusinessAccountProfilePhoto";
    pub const ReturnType = bool;

    /// Unique identifier of the business connection
    business_connection_id: []const u8,
    /// The new profile photo to set
    photo: types.InputProfilePhoto,
    /// Pass True to set the public photo, which will be visible even if the main photo is hidden by the business account's privacy settings. An account can have only one public photo.
    is_public: ?bool = null,
};

/// Changes the username of a managed business account. Requires the can_change_username business bot right. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#setbusinessaccountusername
pub const SetBusinessAccountUsername = struct {
    pub const api_method_name = "setBusinessAccountUsername";
    pub const ReturnType = bool;

    /// Unique identifier of the business connection
    business_connection_id: []const u8,
    /// The new value of the username for the business account; 0-32 characters
    username: ?[]const u8 = null,
};

/// Use this method to set a custom title for an administrator in a supergroup promoted by the bot. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#setchatadministratorcustomtitle
pub const SetChatAdministratorCustomTitle = struct {
    pub const api_method_name = "setChatAdministratorCustomTitle";
    pub const ReturnType = bool;

    /// Unique identifier for the target chat or username of the target supergroup in the format @username
    chat_id: ChatId,
    /// Unique identifier of the target user
    user_id: i64,
    /// New custom title for the administrator; 0-16 characters, emoji are not allowed
    custom_title: []const u8,
};

/// Use this method to change the description of a group, a supergroup or a channel. The bot must be an administrator in the chat for this to work and must have the appropriate administrator rights. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#setchatdescription
pub const SetChatDescription = struct {
    pub const api_method_name = "setChatDescription";
    pub const ReturnType = bool;

    /// Unique identifier for the target chat or username of the target channel in the format @username
    chat_id: ChatId,
    /// New chat description, 0-255 characters
    description: ?[]const u8 = null,
};

/// Use this method to set a tag for a regular member in a group or a supergroup. The bot must be an administrator in the chat for this to work and must have the can_manage_tags administrator right. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#setchatmembertag
pub const SetChatMemberTag = struct {
    pub const api_method_name = "setChatMemberTag";
    pub const ReturnType = bool;

    /// Unique identifier for the target chat or username of the target supergroup in the format @username
    chat_id: ChatId,
    /// Unique identifier of the target user
    user_id: i64,
    /// New tag for the member; 0-16 characters, emoji are not allowed
    tag: ?[]const u8 = null,
};

/// Use this method to change the bot's menu button in a private chat, or the default menu button. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#setchatmenubutton
pub const SetChatMenuButton = struct {
    pub const api_method_name = "setChatMenuButton";
    pub const ReturnType = bool;

    /// Unique identifier for the target private chat. If not specified, the bot's default menu button will be changed.
    chat_id: ?i64 = null,
    /// A JSON-serialized object for the bot's new menu button. Defaults to MenuButtonDefault.
    menu_button: ?types.MenuButton = null,
};

/// Use this method to set default chat permissions for all members. The bot must be an administrator in the group or a supergroup for this to work and must have the can_restrict_members administrator rights. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#setchatpermissions
pub const SetChatPermissions = struct {
    pub const api_method_name = "setChatPermissions";
    pub const ReturnType = bool;

    /// Unique identifier for the target chat or username of the target supergroup in the format @username
    chat_id: ChatId,
    /// A JSON-serialized object for new default chat permissions
    permissions: types.ChatPermissions,
    /// Pass True if chat permissions are set independently. Otherwise, the can_send_other_messages and can_add_web_page_previews permissions will imply the can_send_messages, can_send_audios, can_send_documents, can_send_photos, can_send_videos, can_send_video_notes, and can_send_voice_notes permissions; the can_send_polls permission will imply the can_send_messages permission.
    use_independent_chat_permissions: ?bool = null,
};

/// Use this method to set a new profile photo for the chat. Photos can't be changed for private chats. The bot must be an administrator in the chat for this to work and must have the appropriate administrator rights. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#setchatphoto
pub const SetChatPhoto = struct {
    pub const api_method_name = "setChatPhoto";
    pub const ReturnType = bool;

    /// Unique identifier for the target chat or username of the target channel in the format @username
    chat_id: ChatId,
    /// New chat photo, uploaded using multipart/form-data
    photo: InputFile,
};

/// Use this method to set a new group sticker set for a supergroup. The bot must be an administrator in the chat for this to work and must have the appropriate administrator rights. Use the field can_set_sticker_set optionally returned in getChat requests to check if the bot can use this method. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#setchatstickerset
pub const SetChatStickerSet = struct {
    pub const api_method_name = "setChatStickerSet";
    pub const ReturnType = bool;

    /// Unique identifier for the target chat or username of the target supergroup in the format @username
    chat_id: ChatId,
    /// Name of the sticker set to be set as the group sticker set
    sticker_set_name: []const u8,
};

/// Use this method to change the title of a chat. Titles can't be changed for private chats. The bot must be an administrator in the chat for this to work and must have the appropriate administrator rights. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#setchattitle
pub const SetChatTitle = struct {
    pub const api_method_name = "setChatTitle";
    pub const ReturnType = bool;

    /// Unique identifier for the target chat or username of the target channel in the format @username
    chat_id: ChatId,
    /// New chat title, 1-128 characters
    title: []const u8,
};

/// Use this method to set the thumbnail of a custom emoji sticker set. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#setcustomemojistickersetthumbnail
pub const SetCustomEmojiStickerSetThumbnail = struct {
    pub const api_method_name = "setCustomEmojiStickerSetThumbnail";
    pub const ReturnType = bool;

    /// Sticker set name
    name: []const u8,
    /// Custom emoji identifier of a sticker from the sticker set; pass an empty string to drop the thumbnail and use the first sticker as the thumbnail
    custom_emoji_id: ?[]const u8 = null,
};

/// Use this method to set the score of the specified user in a game message. On success, if the message is not an inline message, the Message is returned, otherwise True is returned. Returns an error, if the new score is not greater than the user's current score in the chat and force is False.
/// Reference: https://core.telegram.org/bots/api#setgamescore
pub const SetGameScore = struct {
    pub const api_method_name = "setGameScore";
    pub const ReturnType = ObjectOrBool(types.Message);

    /// User identifier
    user_id: i64,
    /// New score, must be non-negative
    score: i64,
    /// Pass True if the high score is allowed to decrease. This can be useful when fixing mistakes or banning cheaters.
    force: ?bool = null,
    /// Pass True if the game message should not be automatically edited to include the current scoreboard
    disable_edit_message: ?bool = null,
    /// Required if inline_message_id is not specified. Unique identifier for the target chat.
    chat_id: ?i64 = null,
    /// Required if inline_message_id is not specified. Identifier of the sent message.
    message_id: ?i64 = null,
    /// Required if chat_id and message_id are not specified. Identifier of the inline message.
    inline_message_id: ?[]const u8 = null,
};

/// Use this method to change the access settings of a managed bot. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#setmanagedbotaccesssettings
pub const SetManagedBotAccessSettings = struct {
    pub const api_method_name = "setManagedBotAccessSettings";
    pub const ReturnType = bool;

    /// User identifier of the managed bot whose access settings will be changed
    user_id: i64,
    /// Pass True if only selected users can access the bot. The bot's owner can always access it.
    is_access_restricted: bool,
    /// A JSON-serialized list of up to 10 identifiers of users who will have access to the bot in addition to its owner. Ignored if is_access_restricted is False.
    added_user_ids: ?[]const i64 = null,
};

/// Use this method to change the chosen reactions on a message. Service messages of some types can't be reacted to. Automatically forwarded messages from a channel to its discussion group have the same available reactions as messages in the channel. Bots can't use paid reactions. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#setmessagereaction
pub const SetMessageReaction = struct {
    pub const api_method_name = "setMessageReaction";
    pub const ReturnType = bool;

    /// Unique identifier for the target chat or username of the target bot, supergroup or channel in the format @username
    chat_id: ChatId,
    /// Identifier of the target message. If the message belongs to a media group, the reaction is set to the first non-deleted message in the group instead.
    message_id: i64,
    /// A JSON-serialized list of reaction types to set on the message. Currently, as non-premium users, bots can set up to one reaction per message. A custom emoji reaction can be used if it is either already present on the message or explicitly allowed by chat administrators. Paid reactions can't be used by bots.
    reaction: ?[]const types.ReactionType = null,
    /// Pass True to set the reaction with a big animation
    is_big: ?bool = null,
};

/// Use this method to change the list of the bot's commands. See this manual for more details about bot commands. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#setmycommands
pub const SetMyCommands = struct {
    pub const api_method_name = "setMyCommands";
    pub const ReturnType = bool;

    /// A JSON-serialized list of bot commands to be set as the list of the bot's commands. At most 100 commands can be specified.
    commands: []const types.BotCommand,
    /// A JSON-serialized object, describing scope of users for which the commands are relevant. Defaults to BotCommandScopeDefault.
    scope: ?types.BotCommandScope = null,
    /// A two-letter ISO 639-1 language code. If empty, commands will be applied to all users from the given scope, for whose language there are no dedicated commands.
    language_code: ?[]const u8 = null,
};

/// Use this method to change the default administrator rights requested by the bot when it's added as an administrator to groups or channels. These rights will be suggested to users, but they are free to modify the list before adding the bot. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#setmydefaultadministratorrights
pub const SetMyDefaultAdministratorRights = struct {
    pub const api_method_name = "setMyDefaultAdministratorRights";
    pub const ReturnType = bool;

    /// A JSON-serialized object describing new default administrator rights. If not specified, the default administrator rights will be cleared.
    rights: ?types.ChatAdministratorRights = null,
    /// Pass True to change the default administrator rights of the bot in channels. Otherwise, the default administrator rights of the bot for groups and supergroups will be changed.
    for_channels: ?bool = null,
};

/// Use this method to change the bot's description, which is shown in the chat with the bot if the chat is empty. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#setmydescription
pub const SetMyDescription = struct {
    pub const api_method_name = "setMyDescription";
    pub const ReturnType = bool;

    /// New bot description; 0-512 characters. Pass an empty string to remove the dedicated description for the given language.
    description: ?[]const u8 = null,
    /// A two-letter ISO 639-1 language code. If empty, the description will be applied to all users for whose language there is no dedicated description.
    language_code: ?[]const u8 = null,
};

/// Use this method to change the bot's name. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#setmyname
pub const SetMyName = struct {
    pub const api_method_name = "setMyName";
    pub const ReturnType = bool;

    /// New bot name; 0-64 characters. Pass an empty string to remove the dedicated name for the given language.
    name: ?[]const u8 = null,
    /// A two-letter ISO 639-1 language code. If empty, the name will be shown to all users for whose language there is no dedicated name.
    language_code: ?[]const u8 = null,
};

/// Changes the profile photo of the bot. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#setmyprofilephoto
pub const SetMyProfilePhoto = struct {
    pub const api_method_name = "setMyProfilePhoto";
    pub const ReturnType = bool;

    /// The new profile photo to set
    photo: types.InputProfilePhoto,
};

/// Use this method to change the bot's short description, which is shown on the bot's profile page and is sent together with the link when users share the bot. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#setmyshortdescription
pub const SetMyShortDescription = struct {
    pub const api_method_name = "setMyShortDescription";
    pub const ReturnType = bool;

    /// New short description for the bot; 0-120 characters. Pass an empty string to remove the dedicated short description for the given language.
    short_description: ?[]const u8 = null,
    /// A two-letter ISO 639-1 language code. If empty, the short description will be applied to all users for whose language there is no dedicated short description.
    language_code: ?[]const u8 = null,
};

/// Informs a user that some of the Telegram Passport elements they provided contains errors. The user will not be able to re-submit their Passport to you until the errors are fixed (the contents of the field for which you returned the error must change). Returns True on success.
/// Use this if the data submitted by the user doesn't satisfy the standards your service requires for any reason. For example, if a birthday date seems invalid, a submitted document is blurry, a scan shows evidence of tampering, etc. Supply some details in the error message to make sure the user knows how to correct the issues.
/// Reference: https://core.telegram.org/bots/api#setpassportdataerrors
pub const SetPassportDataErrors = struct {
    pub const api_method_name = "setPassportDataErrors";
    pub const ReturnType = bool;

    /// User identifier
    user_id: i64,
    /// A JSON-serialized Array describing the errors
    errors: []const types.PassportElementError,
};

/// Use this method to change the list of emoji assigned to a regular or custom emoji sticker. The sticker must belong to a sticker set created by the bot. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#setstickeremojilist
pub const SetStickerEmojiList = struct {
    pub const api_method_name = "setStickerEmojiList";
    pub const ReturnType = bool;

    /// File identifier of the sticker
    sticker: []const u8,
    /// A JSON-serialized list of 1-20 emoji associated with the sticker
    emoji_list: []const []const u8,
};

/// Use this method to change search keywords assigned to a regular or custom emoji sticker. The sticker must belong to a sticker set created by the bot. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#setstickerkeywords
pub const SetStickerKeywords = struct {
    pub const api_method_name = "setStickerKeywords";
    pub const ReturnType = bool;

    /// File identifier of the sticker
    sticker: []const u8,
    /// A JSON-serialized list of 0-20 search keywords for the sticker with total length of up to 64 characters
    keywords: ?[]const []const u8 = null,
};

/// Use this method to change the mask position of a mask sticker. The sticker must belong to a sticker set that was created by the bot. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#setstickermaskposition
pub const SetStickerMaskPosition = struct {
    pub const api_method_name = "setStickerMaskPosition";
    pub const ReturnType = bool;

    /// File identifier of the sticker
    sticker: []const u8,
    /// A JSON-serialized object with the position where the mask should be placed on faces. Omit the parameter to remove the mask position.
    mask_position: ?types.MaskPosition = null,
};

/// Use this method to move a sticker in a set created by the bot to a specific position. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#setstickerpositioninset
pub const SetStickerPositionInSet = struct {
    pub const api_method_name = "setStickerPositionInSet";
    pub const ReturnType = bool;

    /// File identifier of the sticker
    sticker: []const u8,
    /// New sticker position in the set, zero-based
    position: i64,
};

/// Use this method to set the thumbnail of a regular or mask sticker set. The format of the thumbnail file must match the format of the stickers in the set. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#setstickersetthumbnail
pub const SetStickerSetThumbnail = struct {
    pub const api_method_name = "setStickerSetThumbnail";
    pub const ReturnType = bool;

    /// Sticker set name
    name: []const u8,
    /// User identifier of the sticker set owner
    user_id: i64,
    /// Format of the thumbnail, must be one of "static" for a .WEBP or .PNG image, "animated" for a .TGS animation, or "video" for a .WEBM video
    format: []const u8 = "one",
    /// A .WEBP or .PNG image with the thumbnail, must be up to 128 kilobytes in size and have a width and height of exactly 100px, or a .TGS animation with a thumbnail up to 32 kilobytes in size (see https://core.telegram.org/stickers#animation-requirements for animated sticker technical requirements), or a .WEBM video with the thumbnail up to 32 kilobytes in size; see https://core.telegram.org/stickers#video-requirements for video sticker technical requirements. Pass a file_id as a String to send a file that already exists on the Telegram servers, pass an HTTP URL as a String for Telegram to get a file from the Internet, or upload a new one using multipart/form-data. More information on Sending Files: https://core.telegram.org/bots/api#sending-files. Animated and video sticker set thumbnails can't be uploaded via HTTP URL. If omitted, then the thumbnail is dropped and the first sticker is used as the thumbnail.
    thumbnail: ?InputFile = null,
};

/// Use this method to set the title of a created sticker set. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#setstickersettitle
pub const SetStickerSetTitle = struct {
    pub const api_method_name = "setStickerSetTitle";
    pub const ReturnType = bool;

    /// Sticker set name
    name: []const u8,
    /// Sticker set title, 1-64 characters
    title: []const u8,
};

/// Changes the emoji status for a given user that previously allowed the bot to manage their emoji status via the Mini App method requestEmojiStatusAccess. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#setuseremojistatus
pub const SetUserEmojiStatus = struct {
    pub const api_method_name = "setUserEmojiStatus";
    pub const ReturnType = bool;

    /// Unique identifier of the target user
    user_id: i64,
    /// Custom emoji identifier of the emoji status to set. Pass an empty string to remove the status.
    emoji_status_custom_emoji_id: ?[]const u8 = null,
    /// Expiration date of the emoji status, if any
    emoji_status_expiration_date: ?i64 = null,
};

/// Use this method to specify a URL and receive incoming updates via an outgoing webhook. Whenever there is an update for the bot, we will send an HTTPS POST request to the specified URL, containing a JSON-serialized Update. In case of an unsuccessful request (a request with response HTTP status code different from 2XY), we will repeat the request and give up after a reasonable amount of attempts. Returns True on success.
/// If you'd like to make sure that the webhook was set by you, you can specify secret data in the parameter secret_token. If specified, the request will contain a header "X-Telegram-Bot-Api-Secret-Token" with the secret token as content.
/// Reference: https://core.telegram.org/bots/api#setwebhook
pub const SetWebhook = struct {
    pub const api_method_name = "setWebhook";
    pub const ReturnType = bool;

    /// HTTPS URL to send updates to. Use an empty string to remove webhook integration.
    url: []const u8,
    /// Upload your public key certificate so that the root certificate in use can be checked. See our self-signed guide for details.
    certificate: ?InputFile = null,
    /// The fixed IP address which will be used to send webhook requests instead of the IP address resolved through DNS
    ip_address: ?[]const u8 = null,
    /// The maximum allowed number of simultaneous HTTPS connections to the webhook for update delivery, 1-100. Defaults to 40. Use lower values to limit the load on your bot's server, and higher values to increase your bot's throughput.
    max_connections: ?i64 = null,
    /// A JSON-serialized list of the update types you want your bot to receive. For example, specify ["message", "edited_channel_post", "callback_query"] to only receive updates of these types. See Update for a complete list of available update types. Specify an empty list to receive all update types except chat_member, message_reaction, and message_reaction_count (default). If not specified, the previous setting will be used. Please note that this parameter doesn't affect updates created before the call to the setWebhook, so unwanted updates may be received for a short period of time.
    allowed_updates: ?[]const []const u8 = null,
    /// Pass True to drop all pending updates
    drop_pending_updates: ?bool = null,
    /// A secret token to be sent in a header "X-Telegram-Bot-Api-Secret-Token" in every webhook request, 1-256 characters. Only characters A-Z, a-z, 0-9, _ and - are allowed. The header is useful to ensure that the request comes from a webhook set by you.
    secret_token: ?[]const u8 = null,
};

/// Use this method to stop updating a live location message before live_period expires. On success, if the message is not an inline message, the edited Message is returned, otherwise True is returned.
/// Reference: https://core.telegram.org/bots/api#stopmessagelivelocation
pub const StopMessageLiveLocation = struct {
    pub const api_method_name = "stopMessageLiveLocation";
    pub const ReturnType = ObjectOrBool(types.Message);

    /// Unique identifier of the business connection on behalf of which the message to be edited was sent
    business_connection_id: ?[]const u8 = null,
    /// Required if inline_message_id is not specified. Unique identifier for the target chat or username of the target bot, supergroup or channel in the format @username.
    chat_id: ?ChatId = null,
    /// Required if inline_message_id is not specified. Identifier of the message with live location to stop.
    message_id: ?i64 = null,
    /// Required if chat_id and message_id are not specified. Identifier of the inline message.
    inline_message_id: ?[]const u8 = null,
    /// A JSON-serialized object for a new inline keyboard
    reply_markup: ?types.InlineKeyboardMarkup = null,
};

/// Use this method to stop a poll which was sent by the bot. On success, the stopped Poll is returned.
/// Reference: https://core.telegram.org/bots/api#stoppoll
pub const StopPoll = struct {
    pub const api_method_name = "stopPoll";
    pub const ReturnType = types.Poll;

    /// Unique identifier for the target chat or username of the target bot, supergroup or channel in the format @username
    chat_id: ChatId,
    /// Identifier of the original message with the poll
    message_id: i64,
    /// Unique identifier of the business connection on behalf of which the message to be edited was sent
    business_connection_id: ?[]const u8 = null,
    /// A JSON-serialized object for a new message inline keyboard
    reply_markup: ?types.InlineKeyboardMarkup = null,
};

/// Transfers Telegram Stars from the business account balance to the bot's balance. Requires the can_transfer_stars business bot right. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#transferbusinessaccountstars
pub const TransferBusinessAccountStars = struct {
    pub const api_method_name = "transferBusinessAccountStars";
    pub const ReturnType = bool;

    /// Unique identifier of the business connection
    business_connection_id: []const u8,
    /// Number of Telegram Stars to transfer; 1-10000
    star_count: i64,
};

/// Transfers an owned unique gift to another user. Requires the can_transfer_and_upgrade_gifts business bot right. Requires can_transfer_stars business bot right if the transfer is paid. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#transfergift
pub const TransferGift = struct {
    pub const api_method_name = "transferGift";
    pub const ReturnType = bool;

    /// Unique identifier of the business connection
    business_connection_id: []const u8,
    /// Unique identifier of the regular gift that should be transferred
    owned_gift_id: []const u8,
    /// Unique identifier of the chat which will own the gift. The chat must be active in the last 24 hours.
    new_owner_chat_id: i64,
    /// The amount of Telegram Stars that will be paid for the transfer from the business account balance. If positive, then the can_transfer_stars business bot right is required.
    star_count: ?i64 = null,
};

/// Use this method to unban a previously banned user in a supergroup or channel. The user will not return to the group or channel automatically, but will be able to join via link, etc. The bot must be an administrator for this to work. By default, this method guarantees that after the call the user is not a member of the chat, but will be able to join it. So if the user is a member of the chat they will also be removed from the chat. If you don't want this, use the parameter only_if_banned. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#unbanchatmember
pub const UnbanChatMember = struct {
    pub const api_method_name = "unbanChatMember";
    pub const ReturnType = bool;

    /// Unique identifier for the target group or username of the target supergroup or channel in the format @username
    chat_id: ChatId,
    /// Unique identifier of the target user
    user_id: i64,
    /// Do nothing if the user is not banned
    only_if_banned: ?bool = null,
};

/// Use this method to unban a previously banned channel chat in a supergroup or channel. The bot must be an administrator for this to work and must have the appropriate administrator rights. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#unbanchatsenderchat
pub const UnbanChatSenderChat = struct {
    pub const api_method_name = "unbanChatSenderChat";
    pub const ReturnType = bool;

    /// Unique identifier for the target chat or username of the target channel in the format @username
    chat_id: ChatId,
    /// Unique identifier of the target sender chat
    sender_chat_id: i64,
};

/// Use this method to unhide the 'General' topic in a forum supergroup chat. The bot must be an administrator in the chat for this to work and must have the can_manage_topics administrator rights. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#unhidegeneralforumtopic
pub const UnhideGeneralForumTopic = struct {
    pub const api_method_name = "unhideGeneralForumTopic";
    pub const ReturnType = bool;

    /// Unique identifier for the target chat or username of the target supergroup in the format @username
    chat_id: ChatId,
};

/// Use this method to clear the list of pinned messages in a chat. In private chats and channel direct messages chats, no additional rights are required to unpin all pinned messages. Conversely, the bot must be an administrator with the 'can_pin_messages' right or the 'can_edit_messages' right to unpin all pinned messages in groups and channels respectively. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#unpinallchatmessages
pub const UnpinAllChatMessages = struct {
    pub const api_method_name = "unpinAllChatMessages";
    pub const ReturnType = bool;

    /// Unique identifier for the target chat or username of the target channel in the format @username
    chat_id: ChatId,
};

/// Use this method to clear the list of pinned messages in a forum topic in a forum supergroup chat or a private chat with a user. In the case of a supergroup chat the bot must be an administrator in the chat for this to work and must have the can_pin_messages administrator right in the supergroup. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#unpinallforumtopicmessages
pub const UnpinAllForumTopicMessages = struct {
    pub const api_method_name = "unpinAllForumTopicMessages";
    pub const ReturnType = bool;

    /// Unique identifier for the target chat or username of the target supergroup in the format @username
    chat_id: ChatId,
    /// Unique identifier for the target message thread of the forum topic
    message_thread_id: i64,
};

/// Use this method to clear the list of pinned messages in a General forum topic. The bot must be an administrator in the chat for this to work and must have the can_pin_messages administrator right in the supergroup. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#unpinallgeneralforumtopicmessages
pub const UnpinAllGeneralForumTopicMessages = struct {
    pub const api_method_name = "unpinAllGeneralForumTopicMessages";
    pub const ReturnType = bool;

    /// Unique identifier for the target chat or username of the target supergroup in the format @username
    chat_id: ChatId,
};

/// Use this method to remove a message from the list of pinned messages in a chat. In private chats and channel direct messages chats, all messages can be unpinned. Conversely, the bot must be an administrator with the 'can_pin_messages' right or the 'can_edit_messages' right to unpin messages in groups and channels respectively. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#unpinchatmessage
pub const UnpinChatMessage = struct {
    pub const api_method_name = "unpinChatMessage";
    pub const ReturnType = bool;

    /// Unique identifier for the target chat or username of the target channel in the format @username
    chat_id: ChatId,
    /// Unique identifier of the business connection on behalf of which the message will be unpinned
    business_connection_id: ?[]const u8 = null,
    /// Identifier of the message to unpin. Required if business_connection_id is specified. If not specified, the most recent pinned message (by sending date) will be unpinned.
    message_id: ?i64 = null,
};

/// Upgrades a given regular gift to a unique gift. Requires the can_transfer_and_upgrade_gifts business bot right. Additionally requires the can_transfer_stars business bot right if the upgrade is paid. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#upgradegift
pub const UpgradeGift = struct {
    pub const api_method_name = "upgradeGift";
    pub const ReturnType = bool;

    /// Unique identifier of the business connection
    business_connection_id: []const u8,
    /// Unique identifier of the regular gift that should be upgraded to a unique one
    owned_gift_id: []const u8,
    /// Pass True to keep the original gift text, sender and receiver in the upgraded gift
    keep_original_details: ?bool = null,
    /// The amount of Telegram Stars that will be paid for the upgrade from the business account balance. If gift.prepaid_upgrade_star_count > 0, then pass 0, otherwise, the can_transfer_stars business bot right is required and gift.upgrade_star_count must be passed.
    star_count: ?i64 = null,
};

/// Use this method to upload a file with a sticker for later use in the createNewStickerSet, addStickerToSet, or replaceStickerInSet methods (the file can be used multiple times). Returns the uploaded File on success.
/// Reference: https://core.telegram.org/bots/api#uploadstickerfile
pub const UploadStickerFile = struct {
    pub const api_method_name = "uploadStickerFile";
    pub const ReturnType = types.File;

    /// User identifier of sticker file owner
    user_id: i64,
    /// A file with the sticker in .WEBP, .PNG, .TGS, or .WEBM format. See https://core.telegram.org/stickers for technical requirements. More information on Sending Files: https://core.telegram.org/bots/api#sending-files
    sticker: InputFile,
    /// Format of the sticker, must be one of "static", "animated", "video"
    sticker_format: []const u8 = "one",
};

/// Verifies a chat on behalf of the organization which is represented by the bot. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#verifychat
pub const VerifyChat = struct {
    pub const api_method_name = "verifyChat";
    pub const ReturnType = bool;

    /// Unique identifier for the target chat or username of the target bot, supergroup or channel in the format @username. Channel direct messages chats can't be verified.
    chat_id: ChatId,
    /// Custom description for the verification; 0-70 characters. Must be empty if the organization isn't allowed to provide a custom verification description.
    custom_description: ?[]const u8 = null,
};

/// Verifies a user on behalf of the organization which is represented by the bot. Returns True on success.
/// Reference: https://core.telegram.org/bots/api#verifyuser
pub const VerifyUser = struct {
    pub const api_method_name = "verifyUser";
    pub const ReturnType = bool;

    /// Unique identifier of the target user
    user_id: i64,
    /// Custom description for the verification; 0-70 characters. Must be empty if the organization isn't allowed to provide a custom verification description.
    custom_description: ?[]const u8 = null,
};

pub const all_method_names = [_][]const u8{
    "addStickerToSet",
    "answerCallbackQuery",
    "answerChatJoinRequestQuery",
    "answerGuestQuery",
    "answerInlineQuery",
    "answerPreCheckoutQuery",
    "answerShippingQuery",
    "answerWebAppQuery",
    "approveChatJoinRequest",
    "approveSuggestedPost",
    "banChatMember",
    "banChatSenderChat",
    "close",
    "closeForumTopic",
    "closeGeneralForumTopic",
    "convertGiftToStars",
    "copyMessage",
    "copyMessages",
    "createChatInviteLink",
    "createChatSubscriptionInviteLink",
    "createForumTopic",
    "createInvoiceLink",
    "createNewStickerSet",
    "declineChatJoinRequest",
    "declineSuggestedPost",
    "deleteAllMessageReactions",
    "deleteBusinessMessages",
    "deleteChatPhoto",
    "deleteChatStickerSet",
    "deleteEphemeralMessage",
    "deleteForumTopic",
    "deleteMessage",
    "deleteMessageReaction",
    "deleteMessages",
    "deleteMyCommands",
    "deleteStickerFromSet",
    "deleteStickerSet",
    "deleteStory",
    "deleteWebhook",
    "editChatInviteLink",
    "editChatSubscriptionInviteLink",
    "editEphemeralMessageCaption",
    "editEphemeralMessageMedia",
    "editEphemeralMessageReplyMarkup",
    "editEphemeralMessageText",
    "editForumTopic",
    "editGeneralForumTopic",
    "editMessageCaption",
    "editMessageChecklist",
    "editMessageLiveLocation",
    "editMessageMedia",
    "editMessageReplyMarkup",
    "editMessageText",
    "editStory",
    "editUserStarSubscription",
    "exportChatInviteLink",
    "forwardMessage",
    "forwardMessages",
    "getAvailableGifts",
    "getBusinessAccountGifts",
    "getBusinessAccountStarBalance",
    "getBusinessConnection",
    "getChat",
    "getChatAdministrators",
    "getChatGifts",
    "getChatMember",
    "getChatMemberCount",
    "getChatMenuButton",
    "getCustomEmojiStickers",
    "getFile",
    "getForumTopicIconStickers",
    "getGameHighScores",
    "getManagedBotAccessSettings",
    "getManagedBotToken",
    "getMe",
    "getMyCommands",
    "getMyDefaultAdministratorRights",
    "getMyDescription",
    "getMyName",
    "getMyShortDescription",
    "getMyStarBalance",
    "getStarTransactions",
    "getStickerSet",
    "getUpdates",
    "getUserChatBoosts",
    "getUserGifts",
    "getUserPersonalChatMessages",
    "getUserProfileAudios",
    "getUserProfilePhotos",
    "getWebhookInfo",
    "giftPremiumSubscription",
    "hideGeneralForumTopic",
    "leaveChat",
    "logOut",
    "pinChatMessage",
    "postStory",
    "promoteChatMember",
    "readBusinessMessage",
    "refundStarPayment",
    "removeBusinessAccountProfilePhoto",
    "removeChatVerification",
    "removeMyProfilePhoto",
    "removeUserVerification",
    "reopenForumTopic",
    "reopenGeneralForumTopic",
    "replaceManagedBotToken",
    "replaceStickerInSet",
    "repostStory",
    "restrictChatMember",
    "revokeChatInviteLink",
    "savePreparedInlineMessage",
    "savePreparedKeyboardButton",
    "sendAnimation",
    "sendAudio",
    "sendChatAction",
    "sendChatJoinRequestWebApp",
    "sendChecklist",
    "sendContact",
    "sendDice",
    "sendDocument",
    "sendGame",
    "sendGift",
    "sendInvoice",
    "sendLivePhoto",
    "sendLocation",
    "sendMediaGroup",
    "sendMessage",
    "sendMessageDraft",
    "sendPaidMedia",
    "sendPhoto",
    "sendPoll",
    "sendRichMessage",
    "sendRichMessageDraft",
    "sendSticker",
    "sendVenue",
    "sendVideo",
    "sendVideoNote",
    "sendVoice",
    "setBusinessAccountBio",
    "setBusinessAccountGiftSettings",
    "setBusinessAccountName",
    "setBusinessAccountProfilePhoto",
    "setBusinessAccountUsername",
    "setChatAdministratorCustomTitle",
    "setChatDescription",
    "setChatMemberTag",
    "setChatMenuButton",
    "setChatPermissions",
    "setChatPhoto",
    "setChatStickerSet",
    "setChatTitle",
    "setCustomEmojiStickerSetThumbnail",
    "setGameScore",
    "setManagedBotAccessSettings",
    "setMessageReaction",
    "setMyCommands",
    "setMyDefaultAdministratorRights",
    "setMyDescription",
    "setMyName",
    "setMyProfilePhoto",
    "setMyShortDescription",
    "setPassportDataErrors",
    "setStickerEmojiList",
    "setStickerKeywords",
    "setStickerMaskPosition",
    "setStickerPositionInSet",
    "setStickerSetThumbnail",
    "setStickerSetTitle",
    "setUserEmojiStatus",
    "setWebhook",
    "stopMessageLiveLocation",
    "stopPoll",
    "transferBusinessAccountStars",
    "transferGift",
    "unbanChatMember",
    "unbanChatSenderChat",
    "unhideGeneralForumTopic",
    "unpinAllChatMessages",
    "unpinAllForumTopicMessages",
    "unpinAllGeneralForumTopicMessages",
    "unpinChatMessage",
    "upgradeGift",
    "uploadStickerFile",
    "verifyChat",
    "verifyUser",
};
