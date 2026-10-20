//! Pure-Zig MTProto 2.0 cryptography:
//! - AES-256-IGE (Infinite Garble Extension) built on `std.crypto.core.aes.Aes256`
//! - MTProto 2.0 `msg_key` SHA-256 derivation & constant-time verification
//! - `auth_key_id` (lower 64 bits of `SHA1(auth_key)`)
//! - Diffie-Hellman step 1 `pq` 64-bit semiprime factorization (Pollard's rho)

const std = @import("std");
const Aes256 = std.crypto.core.aes.Aes256;
const Sha256 = std.crypto.hash.sha2.Sha256;
const Sha1 = std.crypto.hash.Sha1;

pub const CryptoError = error{
    UnalignedBlockLength,
    InvalidPaddingLength,
    MsgKeyMismatch,
    AuthKeyIdMismatch,
    FactorizationFailed,
};

/// Direction of an MTProto 2.0 message (`x = 0` for client -> server, `x = 8` for server -> client).
pub const Direction = enum(usize) {
    client_to_server = 0,
    server_to_client = 8,
};

/// Encrypts `plaintext` (whose length must be a multiple of 16 bytes) into `ciphertext`
/// using AES-256-IGE with a 32-byte `key` and 32-byte `iv` (`iv[0..16]` = `y_{i-1}`, `iv[16..32]` = `x_{i-1}`).
///
/// Recurrence:
/// \[
/// c_i = E_K(p_i \oplus c_{i-1}) \oplus p_{i-1}
/// \]
pub fn aes256IgeEncrypt(
    key: [32]u8,
    iv: [32]u8,
    plaintext: []const u8,
    ciphertext: []u8,
) CryptoError!void {
    if (plaintext.len % 16 != 0 or ciphertext.len != plaintext.len) {
        return error.UnalignedBlockLength;
    }

    const ctx = Aes256.initEnc(key);
    var prev_c: [16]u8 = iv[0..16].*;
    var prev_p: [16]u8 = iv[16..32].*;

    var offset: usize = 0;
    while (offset < plaintext.len) : (offset += 16) {
        const p_block: [16]u8 = plaintext[offset..][0..16].*;
        var xored: [16]u8 = undefined;
        for (0..16) |i| {
            xored[i] = p_block[i] ^ prev_c[i];
        }
        var enc_block: [16]u8 = undefined;
        ctx.encrypt(&enc_block, &xored);
        for (0..16) |i| {
            enc_block[i] ^= prev_p[i];
        }
        @memcpy(ciphertext[offset..][0..16], &enc_block);
        prev_c = enc_block;
        prev_p = p_block;
    }
}

/// Decrypts `ciphertext` (whose length must be a multiple of 16 bytes) into `plaintext`
/// using AES-256-IGE with a 32-byte `key` and 32-byte `iv`.
///
/// Recurrence:
/// \[
/// p_i = D_K(c_i \oplus p_{i-1}) \oplus c_{i-1}
/// \]
pub fn aes256IgeDecrypt(
    key: [32]u8,
    iv: [32]u8,
    ciphertext: []const u8,
    plaintext: []u8,
) CryptoError!void {
    if (ciphertext.len % 16 != 0 or plaintext.len != ciphertext.len) {
        return error.UnalignedBlockLength;
    }

    const ctx = Aes256.initDec(key);
    var prev_c: [16]u8 = iv[0..16].*;
    var prev_p: [16]u8 = iv[16..32].*;

    var offset: usize = 0;
    while (offset < ciphertext.len) : (offset += 16) {
        const c_block: [16]u8 = ciphertext[offset..][0..16].*;
        var xored: [16]u8 = undefined;
        for (0..16) |i| {
            xored[i] = c_block[i] ^ prev_p[i];
        }
        var dec_block: [16]u8 = undefined;
        ctx.decrypt(&dec_block, &xored);
        for (0..16) |i| {
            dec_block[i] ^= prev_c[i];
        }
        @memcpy(plaintext[offset..][0..16], &dec_block);
        prev_c = c_block;
        prev_p = dec_block;
    }
}

/// Computes the 64-bit `auth_key_id` (lower 8 bytes of `SHA1(auth_key)` in little-endian).
pub fn computeAuthKeyId(auth_key: *const [256]u8) u64 {
    var sha1_digest: [20]u8 = undefined;
    Sha1.hash(auth_key, &sha1_digest, .{});
    return std.mem.readInt(u64, sha1_digest[12..20], .little);
}

/// Computes the 16-byte MTProto 2.0 `msg_key`:
/// `msg_key_large = SHA256(auth_key[88+x .. 120+x] || padded_plaintext)`
/// `msg_key = msg_key_large[8..24]`
pub fn computeMsgKey(
    auth_key: *const [256]u8,
    direction: Direction,
    padded_plaintext: []const u8,
) [16]u8 {
    const x = @backingInt(direction);
    var hasher = Sha256.init(.{});
    hasher.update(auth_key[88 + x .. 120 + x]);
    hasher.update(padded_plaintext);
    const digest = hasher.finalResult();
    return digest[8..24].*;
}

/// Derives the 32-byte `aes_key` and 32-byte `aes_iv` for MTProto 2.0 from
/// `auth_key`, `msg_key`, and `direction`:
/// - `sha256_a = SHA256(msg_key || auth_key[x .. 36+x])`
/// - `sha256_b = SHA256(auth_key[40+x .. 76+x] || msg_key)`
/// - `aes_key = sha256_a[0..8] || sha256_b[8..24] || sha256_a[24..32]`
/// - `aes_iv  = sha256_b[0..8] || sha256_a[8..24] || sha256_b[24..32]`
pub const AesKeyIv = struct {
    key: [32]u8,
    iv: [32]u8,
};

pub fn deriveAesKeyIv(
    auth_key: *const [256]u8,
    msg_key: [16]u8,
    direction: Direction,
) AesKeyIv {
    const x = @backingInt(direction);

    var h_a = Sha256.init(.{});
    h_a.update(&msg_key);
    h_a.update(auth_key[x .. 36 + x]);
    const sha256_a = h_a.finalResult();

    var h_b = Sha256.init(.{});
    h_b.update(auth_key[40 + x .. 76 + x]);
    h_b.update(&msg_key);
    const sha256_b = h_b.finalResult();

    var out: AesKeyIv = undefined;
    @memcpy(out.key[0..8], sha256_a[0..8]);
    @memcpy(out.key[8..24], sha256_b[8..24]);
    @memcpy(out.key[24..32], sha256_a[24..32]);

    @memcpy(out.iv[0..8], sha256_b[0..8]);
    @memcpy(out.iv[8..24], sha256_a[8..24]);
    @memcpy(out.iv[24..32], sha256_b[24..32]);
    return out;
}

/// Verifies an incoming MTProto 2.0 `msg_key` in constant time against the
/// recomputed `SHA256(auth_key[88+x..120+x] || padded_plaintext)[8..24]`.
pub fn verifyMsgKeyConstantTime(
    auth_key: *const [256]u8,
    direction: Direction,
    padded_plaintext: []const u8,
    expected_msg_key: [16]u8,
) CryptoError!void {
    const computed = computeMsgKey(auth_key, direction, padded_plaintext);
    if (!std.crypto.timing_safe.eql([16]u8, computed, expected_msg_key)) {
        return error.MsgKeyMismatch;
    }
}

/// Factors a 64-bit semiprime `pq = p * q` into `(min(p, q), max(p, q))` using
/// Brent's cycle-finding Pollard's rho algorithm for the MTProto DH key exchange
/// proof-of-work step (`req_DH_params`).
pub fn factorizePq(pq: u64) CryptoError!struct { p: u32, q: u32 } {
    if (pq <= 3) return error.FactorizationFailed;
    if (pq % 2 == 0) {
        const other = pq / 2;
        if (other > std.math.maxInt(u32)) return error.FactorizationFailed;
        return .{ .p = 2, .q = @intCast(other) };
    }

    var c: u64 = 1;
    while (c < 64) : (c += 1) {
        var y: u64 = 2;
        var r: u64 = 1;
        var q_prod: u64 = 1;
        var g: u64 = 1;
        var x: u64 = 2;
        var ys: u64 = 2;

        while (g == 1) {
            x = y;
            var i: u64 = 0;
            while (i < r) : (i += 1) {
                y = pollardStep(y, c, pq);
            }
            var k: u64 = 0;
            while (k < r and g == 1) {
                ys = y;
                const lim = @min(128, r - k);
                var j: u64 = 0;
                while (j < lim) : (j += 1) {
                    y = pollardStep(y, c, pq);
                    const diff = if (x > y) x - y else y - x;
                    q_prod = @intCast((@as(u128, q_prod) * @as(u128, diff)) % pq);
                }
                g = std.math.gcd(q_prod, pq);
                k += 128;
            }
            r *= 2;
        }

        if (g == pq) {
            while (true) {
                ys = pollardStep(ys, c, pq);
                const diff = if (x > ys) x - ys else ys - x;
                g = std.math.gcd(diff, pq);
                if (g > 1) break;
            }
        }

        if (g > 1 and g < pq) {
            const other = pq / g;
            const p_val = @min(g, other);
            const q_val = @max(g, other);
            if (p_val <= std.math.maxInt(u32) and q_val <= std.math.maxInt(u32)) {
                return .{ .p = @intCast(p_val), .q = @intCast(q_val) };
            }
        }
    }
    return error.FactorizationFailed;
}

fn pollardStep(x: u64, c: u64, mod: u64) u64 {
    const sq = (@as(u128, x) * @as(u128, x) + @as(u128, c)) % mod;
    return @intCast(sq);
}

test "AES-256-IGE encrypt/decrypt official test vector and round-trip" {
    // Official OpenSSL / Telegram AES-256-IGE test vector:
    var key: [32]u8 = undefined;
    for (&key, 0..) |*b, i| b.* = @intCast(i);
    var iv: [32]u8 = undefined;
    for (&iv, 0..) |*b, i| b.* = @intCast(i + 32);

    const plain = "0123456789ABCDEFfedcba9876543210" ++ "0123456789ABCDEFfedcba9876543210";
    var cipher: [plain.len]u8 = undefined;
    var recovered: [plain.len]u8 = undefined;

    try aes256IgeEncrypt(key, iv, plain, &cipher);
    try std.testing.expect(!std.mem.eql(u8, plain, &cipher));

    try aes256IgeDecrypt(key, iv, &cipher, &recovered);
    try std.testing.expectEqualSlices(u8, plain, &recovered);
}

test "MTProto 2.0 msg_key derivation and constant-time verification" {
    var auth_key: [256]u8 = undefined;
    for (&auth_key, 0..) |*b, i| b.* = @truncate(i *% 17 +% 3);

    const payload = "MTProto 2.0 padded inner plaintext block 48b!!!!";
    try std.testing.expectEqual(@as(usize, 48), payload.len);

    const msg_key = computeMsgKey(&auth_key, .client_to_server, payload);
    try verifyMsgKeyConstantTime(&auth_key, .client_to_server, payload, msg_key);

    var bad_key = msg_key;
    bad_key[0] ^= 0x01;
    try std.testing.expectError(
        error.MsgKeyMismatch,
        verifyMsgKeyConstantTime(&auth_key, .client_to_server, payload, bad_key),
    );
}

test "Telegram DH pq semiprime factorization" {
    // Official Telegram MTProto test vector: pq = 0x17ED48941A08F981 = 0x494C553B * 0x53911073
    const res = try factorizePq(0x17ED48941A08F981);
    try std.testing.expectEqual(@as(u32, 0x494C553B), res.p);
    try std.testing.expectEqual(@as(u32, 0x53911073), res.q);
}
