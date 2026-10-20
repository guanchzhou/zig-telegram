//! Telegram Bot API 10.3 plane (`telegram.bot`).
//!
//! Exposes `BotClient`, all 185 Bot API methods (`methods`), all 400 data types
//! and discriminated unions (`types`), strongly-typed enums (`enums`), the
//! long-polling runner (`Poller`), constant-time webhook verifier (`webhook`),
//! and zero-allocation command/callback router (`Router`).

pub const enums = @import("enums.zig");
pub const types = @import("types.zig");
pub const methods = @import("methods.zig");
pub const client = @import("client.zig");
pub const poller = @import("poller.zig");
pub const webhook = @import("webhook.zig");
pub const router = @import("router.zig");

pub const BotClient = client.BotClient;
pub const ClientConfig = client.ClientConfig;
pub const Poller = poller.Poller;
pub const PollerConfig = poller.PollerConfig;
pub const Router = router.Router;
pub const ParsedCommand = router.ParsedCommand;
pub const ChatId = types.ChatId;
pub const InputFile = types.InputFile;
pub const ReplyMarkup = types.ReplyMarkup;
pub const ObjectOrBool = types.ObjectOrBool;

test {
    _ = enums;
    _ = types;
    _ = methods;
    _ = client;
    _ = poller;
    _ = webhook;
    _ = router;
}
