# Security Policy

## Supported versions

`zig-telegram` is pre-1.0. Only the latest tagged release receives security fixes.

| Version | Supported |
| ------- | --------- |
| latest `0.1.x` | Yes |
| older | No |

## Reporting a vulnerability

Please report security issues **privately** rather than opening a public issue:

- Use GitHub's [private vulnerability reporting](https://github.com/guanchzhou/zig-telegram/security/advisories/new), or
- email the maintainer (see the GitHub profile for `guanchzhou`).

Include a description, affected version/commit, and a reproduction if possible.
You can expect an initial acknowledgement within a few days.

## Verifying releases

Release artifacts are checksummed (`SHA256SUMS`) and signed with **cosign keyless**
(Sigstore), with SLSA build provenance attested via GitHub Actions. Verify a
downloaded artifact:

```sh
cosign verify-blob \
  --bundle SHA256SUMS.cosign.bundle \
  --certificate-identity-regexp 'https://github.com/guanchzhou/zig-telegram/.*' \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  SHA256SUMS
shasum -a 256 -c SHA256SUMS
```

## Security Guarantees in `zig-telegram`

- **Secret token redaction**: `SecretToken` implements a custom `format` method
  that always prints `bot<id>:[REDACTED]`. Bot tokens never appear in formatted
  error messages, logs, or panic traces.
- **Constant-time webhook authentication**: `X-Telegram-Bot-Api-Secret-Token` is
  verified by comparing SHA-256 digests with `std.crypto.timing_safe.eql` so
  neither secret length nor byte prefixes leak over timing channels.
- **Strict memory bounds**: All HTTP response readers, webhook body readers, and
  MTProto frame decoders enforce explicit byte ceilings (`max_response_bytes`,
  `max_webhook_bytes`, `max_frame_bytes`) before allocating.
- **Cryptographic multipart boundaries & RFC 7578 sanitization**: Multipart
  boundaries use 128 bits of CSPRNG entropy (`io.random`), and field/file names
  reject or escape CR, LF, and quote characters to prevent multipart header
  injection.
- **MTProto 2.0 `msg_key` verification**: Incoming MTProto 2.0 frames verify the
  full SHA-256 `msg_key` in constant time and validate body alignment and padding
  length (12..1024 bytes) before exposing plaintext to the TL decoder; all of these
  failures return the same `error.DecryptionFailed`. Authenticated messages are
  then checked for `session_id`, server `msg_id` parity, a +30 s/−300 s window
  against the server clock, and replayed `msg_id`s. Decrypted plaintext buffers
  are zeroed before they are freed.
- **No DH key exchange**: `auth_key` creation is not implemented; callers supply
  an existing key.
