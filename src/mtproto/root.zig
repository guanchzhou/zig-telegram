//! Pure-Zig MTProto 2.0 protocol plane (`telegram.mtproto`).
//!
//! Provides:
//! - Type Language (TL) binary serializer and zero-copy decoder (`tl`)
//! - Pure-Zig AES-256-IGE, MTProto 2.0 SHA-256 `msg_key` KDF, and DH `pq` factorization (`crypto`)
//! - Abridged, Intermediate, Padded Intermediate, and Obfuscated2 transports (`transport`)
//! - Encrypted/unencrypted MTProto 2.0 session packet state machine (`session`)

pub const tl = @import("tl.zig");
pub const crypto = @import("crypto.zig");
pub const transport = @import("transport.zig");
pub const session = @import("session.zig");

pub const TlWriter = tl.TlWriter;
pub const TlReader = tl.TlReader;
pub const Session = session.Session;
pub const FramingMode = transport.FramingMode;
pub const Obfuscated2 = transport.Obfuscated2;

test {
    _ = tl;
    _ = crypto;
    _ = transport;
    _ = session;
}
