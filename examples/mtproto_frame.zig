//! Example: Pure-Zig MTProto 2.0 Type Language (TL) serialization, AES-256-IGE
//! session packet encryption, and Intermediate transport framing.

const std = @import("std");
const telegram = @import("telegram");

pub fn main(init: std.process.Init) !void {
    const allocator = init.gpa;
    const io = init.io;

    // 1. Serialize a TL `ping#7abe77ec` request
    var tl_writer = telegram.mtproto.TlWriter.init(allocator);
    defer tl_writer.deinit();
    try tl_writer.writeU32(telegram.mtproto.tl.ping_id);
    try tl_writer.writeI64(0x123456789ABCDEF0);

    // 2. Encrypt inside an MTProto 2.0 session packet (AES-256-IGE + SHA-256 msg_key)
    var auth_key: [256]u8 = undefined;
    for (&auth_key, 0..) |*b, i| b.* = @truncate(i *% 31 +% 11);

    var session = telegram.mtproto.Session.init(auth_key, 0x1122334455667788, 0xAABBCCDDEEFF0011);
    const msg_id = session.nextMsgId(1_730_000_000 * std.time.ns_per_s);
    const seq_no = session.nextSeqNo(false);

    const encrypted_packet = try session.encryptMessage(
        allocator,
        io,
        .client_to_server,
        msg_id,
        seq_no,
        tl_writer.written(),
    );
    defer allocator.free(encrypted_packet);

    // 3. Frame with MTProto Intermediate transport
    const wire_frame = try telegram.mtproto.transport.encodeFrame(
        allocator,
        io,
        .intermediate,
        encrypted_packet,
    );
    defer allocator.free(wire_frame);

    // 4. Decode frame and decrypt MTProto 2.0 session packet
    const unframed = try telegram.mtproto.transport.decodeFrame(
        .intermediate,
        wire_frame,
        telegram.mtproto.transport.default_max_frame_bytes,
    );
    var decrypted = try session.decryptMessage(allocator, .client_to_server, unframed.payload, 1_730_000_000);
    defer decrypted.deinit(allocator);

    var tl_reader = telegram.mtproto.TlReader.init(decrypted.body);
    std.debug.assert((try tl_reader.readU32()) == telegram.mtproto.tl.ping_id);
    std.debug.assert((try tl_reader.readI64()) == 0x123456789ABCDEF0);
}
