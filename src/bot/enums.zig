//! Telegram Bot API 10.3 (August 24, 2026) strongly-typed enumerations.
//!
//! Generated deterministically from `spec/bot_api_10_3.json` by `tools/gen_bot_api.zig`.

pub const ParseMode = enum {
    HTML,
    Markdown,
    MarkdownV2,
};

pub const ChatType = enum {
    private,
    group,
    supergroup,
    channel,
};

pub const ChatAction = enum {
    typing,
    upload_photo,
    record_video,
    upload_video,
    record_voice,
    upload_voice,
    upload_document,
    choose_sticker,
    find_location,
    record_video_note,
    upload_video_note,
};

pub const ChatMemberStatus = enum {
    creator,
    administrator,
    member,
    restricted,
    left,
    kicked,
};

pub const MessageEntityType = enum {
    mention,
    hashtag,
    cashtag,
    bot_command,
    url,
    email,
    phone_number,
    bold,
    italic,
    underline,
    strikethrough,
    spoiler,
    blockquote,
    expandable_blockquote,
    code,
    pre,
    text_link,
    text_mention,
    custom_emoji,
    date_time,
};

pub const PollType = enum {
    regular,
    quiz,
};

pub const DiceEmoji = enum {
    @"🎲",
    @"🎯",
    @"🏀",
    @"⚽",
    @"🎳",
    @"🎰",
};

pub const StickerFormat = enum {
    static,
    animated,
    video,
};

pub const StickerType = enum {
    regular,
    mask,
    custom_emoji,
};

pub const MaskPositionPoint = enum {
    forehead,
    eyes,
    mouth,
    chin,
};

pub const UpdateType = enum {
    message,
    edited_message,
    channel_post,
    edited_channel_post,
    business_connection,
    business_message,
    edited_business_message,
    deleted_business_messages,
    message_reaction,
    message_reaction_count,
    inline_query,
    chosen_inline_result,
    callback_query,
    shipping_query,
    pre_checkout_query,
    purchased_paid_media,
    poll,
    poll_answer,
    my_chat_member,
    chat_member,
    chat_join_request,
    chat_boost,
    removed_chat_boost,
    managed_bot,
};

pub const Currency = enum {
    XTR,
    TON,
};

pub const BotSubscriptionState = enum {
    canceled,
    active,
    failed,
};

pub const ButtonsAlign = enum {
    left,
    center,
    right,
};

pub const HorizontalAlignment = enum {
    left,
    center,
    right,
};

pub const VerticalAlignment = enum {
    top,
    middle,
    bottom,
};

pub const ChatJoinRequestQueryResult = enum {
    approve,
    decline,
    queue,
};

pub const GiftRarity = enum {
    uncommon,
    rare,
    epic,
    legendary,
};

pub const InlineQueryChatType = enum {
    sender,
    private,
    group,
    supergroup,
    channel,
};

pub const KeyboardButtonStyle = enum {
    primary,
    secondary,
    outline,
};

pub const RefundReason = enum {
    post_deleted,
    payment_refunded,
};

pub const RichBlockListItemType = enum {
    a,
    A,
    i,
    I,
    @"1",
};

pub const SuggestedPostState = enum {
    pending,
    approved,
    declined,
};

pub const TransactionType = enum {
    invoice_payment,
    paid_media_payment,
    gift_purchase,
    premium_purchase,
    business_account_transfer,
};

pub const UniqueGiftOrigin = enum {
    upgrade,
    transfer,
    resale,
    gifted_upgrade,
    offer,
};
