# zig-telegram

[![CI](https://github.com/guanchzhou/zig-telegram/actions/workflows/ci.yml/badge.svg)](https://github.com/guanchzhou/zig-telegram/actions/workflows/ci.yml)
[![Docs](https://github.com/guanchzhou/zig-telegram/actions/workflows/docs.yml/badge.svg)](https://guanchzhou.github.io/zig-telegram/)
[![Zig 0.17.0](https://img.shields.io/badge/zig-0.17.0-f7a41d?logo=zig)](https://ziglang.org)
[![Bot API 10.3](https://img.shields.io/badge/Telegram%20Bot%20API-10.3%20(185%20methods)-26A5E4?logo=telegram)](https://core.telegram.org/bots/api)
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

**`zig-telegram`** is a zero-dependency, pure-Zig Telegram SDK and CLI for **Zig 0.17.0** covering three protocol planes in one cohesive package:

1. **Plane 1 — `telegram.bot` (Telegram Bot API 10.3 Complete)**:
   - **100% of Telegram Bot API 10.3** (August 24, 2026 — **185 methods** and **400 types/unions**), deterministically generated from [`spec/bot_api_10_3.json`](spec/bot_api_10_3.json) via [`tools/gen_bot_api.zig`](tools/gen_bot_api.zig) (`zig build gen-spec` / `zig build spec-check`).
   - **Recursive `attach://` Multipart Engine**: Comptime + runtime inspection across nested structs, optionals, slices, and unions (`sendMediaGroup`, `sendPaidMedia`, `editMessageMedia`, `sendPoll`, `sendRichMessage`), automatically rewriting nested `.path` and `.bytes` `InputFile` fields into `"attach://part_<n>"` JSON references and streaming RFC 7578 binary parts with 128-bit CSPRNG boundaries.
   - **Single-Pass Discriminated Unions**: All 23 Bot API discriminated unions (`MaybeInaccessibleMessage`, `ChatMember`, `MessageOrigin`, `ReactionType`, `BackgroundFill`, `BackgroundType`, `RevenuePartner`, `TransactionPartner`, `PaidMedia`, `StoryAreaType`, `OwnedGift`, `BotCommandScope`, `MenuButton`, `InputMedia`, `InputPaidMedia`, `InputProfilePhoto`, `InputStoryContent`, `RichText`, etc.) parse in a single pass without intermediate `std.json.Value` DOM allocations.
   - **Persistent Keep-Alive HTTP Transport + MockTransport**: Built on `std.http.Client` with TLS 1.3 connection pooling, single automatic retry on stale keep-alive reset, bounded response reader (`error.ResponseTooLarge`), and `--local` Bot API server `file://` path remapping.
   - **Caller-Owned `ErrorDetail` Diagnostics**: Every `BotClient` method accepts `err_out: ?*?ErrorDetail`, preserving `error_code`, `description`, `retry_after` (429 rate-limit backoff), and `migrate_to_chat_id` without thread-unsafe mutable client state.
   - **Bot Runtime Utilities**: Resilient `Poller` (automatic `offset = last_update_id + 1`, `429 Retry-After` sleep, exponential jitter backoff), constant-time `WebhookProcessor` (`X-Telegram-Bot-Api-Secret-Token` verified via SHA-256 + `std.crypto.timing_safe.eql`), and comptime `Router(Context, routes)`.
2. **Plane 2 — `telegram.mtproto` (Pure-Zig MTProto 2.0 Core)**:
   - **TL Binary Codec (`mtproto.tl`)**: 32-bit constructor IDs, 24-bit/56-bit length-prefixed strings and byte arrays with 4-byte padding alignment, `Int128`/`Int256`, and `Vector<T>`.
   - **Pure-Zig MTProto 2.0 Cryptography (`mtproto.crypto`)**: AES-256-IGE (Infinite Garble Extension) built directly on `std.crypto.core.aes.Aes256`, MTProto 2.0 SHA-256 `msg_key` and `aes_key`/`aes_iv` KDF, and Brent–Pollard $\rho$ `pq` prime factorization for Diffie-Hellman key exchange.
   - **Transport Framing (`mtproto.transport`)**: Abridged (`0xef`), Intermediate (`0xeeeeeeee`), Padded Intermediate (`0xdddddddd`), and Obfuscated2 (64-byte header + dual CTR keystreams).
   - **Session Framing (`mtproto.session`)**: Unencrypted handshake envelopes and encrypted MTProto 2.0 packets with 12..1024-byte random padding and monotonic time-synchronized 64-bit `msg_id` + `seq_no` state.
3. **Plane 3 — `telegram.tdlib` (Optional TDLib `tdjson` Bridge)**:
   - Zero-cost runtime dynamic loader (`std.DynLib`) and mockable C ABI vtable for `libtdjson` (`td_create_client_id`, `td_send`, `td_receive`, `td_execute`) — requiring **zero C/C++ dependencies** by default.

**Documentation & API Reference**: [**https://guanchzhou.github.io/zig-telegram/**](https://guanchzhou.github.io/zig-telegram/) ([Zig Autodoc `/api/`](https://guanchzhou.github.io/zig-telegram/api/))

---

## Ecosystem Comparison

| Capability | **`zig-telegram`** | `zigtgshka` | `ziogram` | `telebot.zig` |
| :--- | :--- | :--- | :--- | :--- |
| **Telegram Bot API Spec** | **10.3 (185 methods / 400 types)** | 9.2 (161 methods) | 7.10 partial | ~30 manual methods |
| **Zig Version** | **0.17.0 (`std.Io`)** | 0.14 / 0.15 | 0.14 | 0.11 |
| **Nested `attach://` Multipart (`sendMediaGroup`)** | **Recursive comptime + runtime** | Top-level fields only | None | `libcurl` C FFI |
| **Discriminated Unions (23 unions + `RichText`)** | **Single-pass zero-DOM scanner** | 2-pass `std.json.Value` DOM | Incomplete | Manual structs |
| **HTTP Transport & TLS Keep-Alive** | **Persistent pooled `std.http.Client`** | New client per request | New client per request | Requires C `libcurl` |
| **Error Diagnostics (`retry_after`, `migrate_to_chat_id`)** | **Caller-owned `?*?ErrorDetail`** | Discarded on error | Thread-unsafe struct field | Status code only |
| **Token Redaction & Constant-Time Webhook Auth** | **`SecretToken` + SHA-256 `timing_safe.eql`** | Raw `[]const u8` | Raw `[]const u8` | Raw `[*c]const u8` |
| **Pure-Zig MTProto 2.0 Core (TL + AES-256-IGE)** | **Built-in (`telegram.mtproto`)** | No | No | No |

---

## Installation

Requires **Zig `0.17.0`**.

```sh
zig fetch --save git+https://github.com/guanchzhou/zig-telegram
```

Then wire the `telegram` module in your `build.zig`:

```zig
const telegram_dep = b.dependency("zig_telegram", .{
    .target = target,
    .optimize = optimize,
});
exe.root_module.addImport("telegram", telegram_dep.module("telegram"));
```

---

## Quickstart

### 1. Bot API 10.3 Client, Command Router & Long Poller

```zig
const std = @import("std");
const telegram = @import("telegram");

const AppContext = struct {
    client: *telegram.bot.BotClient,

    pub fn onStart(self: *AppContext, msg: telegram.bot.types.Message, args: []const u8) !void {
        _ = args;
        var res = try self.client.sendMessage(.{
            .chat_id = .fromInt(msg.chat.id),
            .text = "Hello from *zig\\-telegram* \\(Bot API 10\\.3\\)\\!",
            .parse_mode = .MarkdownV2,
        }, null);
        res.deinit();
    }
};

const BotRouter = telegram.bot.Router(*AppContext, .{
    .commands = &.{
        .{ .name = "start", .handler = AppContext.onStart },
    },
});

pub fn main(init: std.process.Init) !void {
    var http: telegram.transport.HttpTransport = .init(init.gpa, init.io);
    defer http.deinit();

    const raw_token = init.minimal.environ.getPosix("TELEGRAM_BOT_TOKEN") orelse return error.MissingToken;
    const token = try telegram.SecretToken.initValidated(raw_token);

    var client = telegram.bot.BotClient.init(init.gpa, init.io, token, http.transport(), .{});
    var ctx: AppContext = .{ .client = &client };

    var poller = telegram.bot.Poller.init(init.gpa, &client, .{ .timeout_seconds = 30 });
    try poller.run(*AppContext, &ctx, BotRouter.dispatch);
}
```

### 2. Recursive `attach://` Multipart Uploads (`sendMediaGroup`)

`zig-telegram` automatically inspects nested slices and tagged unions for `.path` or `.bytes` `InputFile` values, rewrites them to `"attach://part_<n>"` in the JSON field, and streams the binary parts:

```zig
const media_items = [_]telegram.bot.types.InputMedia{
    .{
        .photo = .{
            .media = .fromBytes("architecture.png", png_bytes),
            .caption = "Uploaded via attach://part_0",
        },
    },
    .{
        .document = .{
            .media = .fromPath("./spec/bot_api_10_3.json"),
            .thumbnail = .fromBytes("thumb.jpg", jpg_bytes),
            .caption = "Uploaded via attach://part_1 and attach://part_2",
        },
    },
};

var sent = try client.sendMediaGroup(.{
    .chat_id = .fromChannel("@zig_announcements"),
    .media = &media_items,
}, null);
defer sent.deinit();
```

### 3. Constant-Time Webhook Verification

```zig
var processor: telegram.bot.WebhookProcessor = .{
    .expected_secret_token = "whsec_production_secret_token_2026",
};

var parsed_update = try processor.verifyAndParseUpdate(
    allocator,
    request_headers,
    request_body,
);
defer parsed_update.deinit();
```

### 4. Local Bot API Server (`telegram-bot-api --local`)

```zig
var client = telegram.bot.BotClient.init(allocator, io, token, http.transport(), .{
    .local_server = .{
        .base_url = "http://127.0.0.1:8081",
        .server_data_dir = "/var/lib/telegram-bot-api",
        .host_data_dir = "/mnt/telegram-data",
    },
});
```

### 5. Pure-Zig MTProto 2.0 Packet Encryption & Framing

```zig
const mtproto = telegram.mtproto;

const auth_key: [256]u8 = @splat(0x42);
var session = mtproto.session.Session.init(auth_key, 0x0102030405060708, 0x1122334455667788);

const encrypted = try session.encryptPacket(
    allocator,
    tl_payload,
    1_729_420_000,
    true,
    .client_to_server,
    @splat(0x7F),
);
defer allocator.free(encrypted.packet);

const framed = try mtproto.transport.encodeFrame(allocator, .intermediate, encrypted.packet);
defer allocator.free(framed);
```

---

## CLI (`zig-telegram`)

Build or run the bundled CLI:

```sh
# Print Bot API 10.3 specification coverage
zig build run -- spec

# Run MTProto 2.0 self-test (AES-256-IGE + SHA-256 msg_key + pq factorization)
zig build run -- mtproto

# Call getMe
TELEGRAM_BOT_TOKEN="123456:ABC-DEF" zig build run -- me

# Send a message
TELEGRAM_BOT_TOKEN="123456:ABC-DEF" zig build run -- send --chat 42 --text "Hello!" --parse-mode MarkdownV2

# Long-poll updates as JSONL
TELEGRAM_BOT_TOKEN="123456:ABC-DEF" zig build run -- poll --timeout 25

# Call any of the 185 Bot API 10.3 methods with raw JSON
TELEGRAM_BOT_TOKEN="123456:ABC-DEF" zig build run -- call getWebhookInfo '{}'
```

---

## Benchmarks (`ReleaseFast`, Apple M-series, Zig 0.17.0)

Run `zig build bench` or enforce the regression gate with `zig build perf-check`:

```text
zig-telegram ReleaseFast benchmark (25000 iterations)
--------------------------------------------------------------------
Discriminated union single-pass :    740 ns/op
Discriminated union 2-pass DOM  :    863 ns/op  (1.17x speedup)
Full Bot API Update envelope    :   1696 ns/op
MTProto 2.0 AES-256-IGE (1 KiB) :  979.2 MiB/s
Webhook SHA-256 constant-time   :     34 ns/op
```

---

## Build, Test, Fuzz & Docs Commands

```sh
zig build test                              # Unit, golden, surface probe, OOM, CLI, and example builds
zig build spec-check                        # Verify src/bot/*.zig matches spec/bot_api_10_3.json
zig build perf-check                        # Run ReleaseFast performance regression gate
zig build docs                              # Generate landing page + Zig autodoc in zig-out/docs/
mkdir -p .zig-cache/tmp && zig build test -Dllvm=true --fuzz=50K
```

---

## Security Guarantees

- **Redacted `SecretToken`**: `SecretToken.format` always emits `bot<id>:[REDACTED]` so bot tokens cannot leak via `std.log` or formatting calls.
- **Constant-Time Webhook Authentication**: `X-Telegram-Bot-Api-Secret-Token` is hashed with SHA-256 on both sides and compared via `std.crypto.timing_safe.eql([32]u8, a, b)` to eliminate length and content timing side channels.
- **RFC 7578 Multipart Hardening**: 128-bit CSPRNG multipart boundaries (`std.Io.random`) and strict filename/field-name quote and CRLF escaping prevent multipart header injection.
- **Bounded Memory & Path Traversal Protection**: `max_response_bytes` (default 16 MiB) prevents unbounded response allocation, and `LocalServerConfig.resolveLocalFilePath` rejects `..` traversal segments.

---

## License

MIT License — Copyright (c) 2026 Andrey Maltsev. See [LICENSE](LICENSE).
