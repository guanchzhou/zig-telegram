//! `zig-telegram` — Fast, memory-safe, zero-dependency Telegram Bot API 10.3,
//! MTProto 2.0, and TDLib library for Zig 0.17.
//!
//! Architecture planes:
//! - `telegram.bot`: Complete Bot API 10.3 (185 methods, 400 types/unions,
//!   45 enums), recursive `attach://` multipart streaming, persistent TLS 1.3
//!   keep-alive transport, local Bot API server support, long poller,
//!   constant-time webhook verifier, and comptime command router.
//! - `telegram.mtproto`: Pure-Zig MTProto 2.0 core (TL binary codec, pure-Zig
//!   AES-256-IGE, SHA-256 `msg_key` KDF, DH `pq` factorization, Abridged /
//!   Intermediate / Obfuscated2 framing, and session state machine).
//! - `telegram.tdlib`: Optional zero-cost `libtdjson` dynamic C ABI bridge.

pub const version = "0.1.0";
pub const bot_api_version = bot.methods.spec_version;

pub const secret = @import("secret.zig");
pub const err = @import("error.zig");
pub const json = @import("json.zig");
pub const multipart = @import("multipart.zig");
pub const transport = @import("transport.zig");

pub const bot = @import("bot/root.zig");
pub const mtproto = @import("mtproto/root.zig");
pub const tdlib = @import("tdlib/root.zig");
pub const fuzz = @import("fuzz.zig");

// Top-level convenience re-exports
pub const SecretToken = secret.SecretToken;
pub const TelegramError = err.TelegramError;
pub const ErrorDetail = err.ErrorDetail;
pub const ErrorParameters = err.ErrorParameters;
pub const ChatId = json.ChatId;
pub const InputFile = json.InputFile;
pub const ObjectOrBool = json.ObjectOrBool;
pub const Transport = transport.Transport;
pub const HttpTransport = transport.HttpTransport;
pub const MockTransport = transport.MockTransport;
pub const LocalServerConfig = transport.LocalServerConfig;
pub const BotClient = bot.BotClient;
pub const ClientConfig = bot.ClientConfig;
pub const Poller = bot.Poller;
pub const PollerConfig = bot.PollerConfig;
pub const Router = bot.Router;

test {
    _ = secret;
    _ = err;
    _ = json;
    _ = multipart;
    _ = transport;
    _ = bot;
    _ = mtproto;
    _ = tdlib;
    _ = fuzz;
}
