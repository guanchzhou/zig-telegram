# Changelog

All notable changes to `zig-telegram` are documented in this file.

## [0.1.0] - 2026-10-20

### Added

- **Bot API 10.3 (`telegram.bot`)**: Complete, zero-dependency implementation of
  the Telegram Bot API 10.3 specification (185 methods, 383 types, 45 enums),
  generated deterministically from `spec/bot_api_10_3.json` via
  `tools/gen_bot_api.zig`.
- **Single-pass JSON & recursive `attach://` multipart engine**:
  - Comptime recursive attachment detector (`multipart.containsAttachment`) that
    discovers `InputFile` across top-level fields, slices (`[]const InputMedia`),
    and tagged unions (`InputRichBlock`, `InputStoryContent`).
  - CSPRNG 128-bit multipart boundary generation and RFC 7578 header escaping.
  - Bodiless request optimization for empty-parameter calls (`getMe`, `close`,
    `logOut`) compatible with `telegram-bot-api --local`.
- **Persistent HTTP Keep-Alive & Local Bot API Server support**:
  - Thread-safe `HttpTransport` over `std.http.Client` with connection pooling,
    replayable request payloads for HTTP/2 GOAWAY retry, and bounded response
    allocation.
  - `LocalServerConfig` with `file://` path remapping for zero-copy local file
    reads up to 2000 MB.
  - Deterministic `MockTransport` for offline testing of all 185 Bot API methods.
- **Caller-owned `ErrorDetail` sink (`*?ErrorDetail`)**:
  - Thread-safe per-call error detail capture (`error_code`, `description`,
    `retry_after`, `migrate_to_chat_id`) without mutable state on the shared
    client.
- **Long Poller, Constant-Time Webhook Verifier, and Comptime Router**:
  - `Poller` with automatic `offset` advancement, HTTP 429 `retry_after` compliance,
    and Fibonacci backoff on transient errors.
  - `webhook.verifySecretToken` using SHA-256 + `std.crypto.timing_safe.eql` and
    bounded update parsing.
  - Comptime `Router` for commands (`/cmd` and `/cmd@bot`), callback queries,
    inline queries, and custom predicates.
- **Pure-Zig MTProto 2.0 Core (`telegram.mtproto`)**:
  - Type Language (TL) binary serializer and bounded parser (`tl.zig`) for boxed
    and bare types, `int128`, `int256`, aligned strings/bytes, and vectors.
  - Pure-Zig AES-256-IGE encryption/decryption, MTProto 2.0 SHA-256 `msg_key`
    derivation and constant-time verification, and Diffie-Hellman `pq`
    factorization (`crypto.zig`).
  - Abridged, Intermediate, Padded Intermediate, and Obfuscated2 AES-256-CTR
    transports (`transport.zig`) plus monotonic `msg_id`/`seq_no` session state
    (`session.zig`).
- **Optional TDLib Bridge (`telegram.tdlib`)**:
  - Dynamic `libtdjson` loader (`std.DynLib`) and optional C ABI binding that
    requires zero C/libc dependencies when unused.
- **Native CLI (`zig-telegram`)**:
  - `me`, `send`, `poll`, `call`, `file`, `webhook`, `mtproto`, `spec`, and
    `version` commands.
- **Technical-Design Landing Page & API Docs**:
  - Static blueprint landing page at `docs/site/index.html` bundled with Zig
    autodoc reference under `/api/`.
