//! Example: Constant-time webhook verification (`X-Telegram-Bot-Api-Secret-Token`)
//! and zero-RTT inline JSON webhook response encoding.

const std = @import("std");
const telegram = @import("telegram");

pub fn main(init: std.process.Init) !void {
    const allocator = init.gpa;
    const webhook_secret = "whsec_9f86d081884c7d659a2feaa0c55ad015";

    const incoming_body =
        \\{"update_id":5001,"message":{"message_id":88,"date":1726000000,"chat":{"id":9001,"type":"private"},"text":"/ping"}}
    ;

    var parsed = try telegram.bot.webhook.parseWebhookUpdate(
        allocator,
        incoming_body,
        webhook_secret,
        webhook_secret,
        telegram.bot.webhook.default_max_webhook_bytes,
    );
    defer parsed.deinit();

    const chat_id = parsed.value.message.?.chat.id;
    const inline_reply = try telegram.bot.webhook.encodeWebhookReply(
        allocator,
        telegram.bot.methods.SendMessage{
            .chat_id = .{ .id = chat_id },
            .text = "pong (inline webhook reply)",
        },
    );
    defer allocator.free(inline_reply);

    std.debug.assert(std.mem.indexOf(u8, inline_reply, "\"method\":\"sendMessage\"") != null);
}
