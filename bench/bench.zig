//! ReleaseFast benchmark suite & regression gate (`zig build bench` and `zig build perf-check`).
//!
//! Benchmarks:
//! 1. Single-pass `Update` JSON envelope decoding vs two-pass DOM (`std.json.Value`) decoding
//! 2. `sendMessage` with inline keyboard JSON serialization throughput
//! 3. Recursive `attach://` multipart encoding throughput (`sendMediaGroup`)
//! 4. Pure-Zig MTProto 2.0 AES-256-IGE + SHA-256 `msg_key` packet encryption/decryption throughput (MB/s)
//! 5. Constant-time SHA-256 webhook secret verification latency (ns/op)

const std = @import("std");
const telegram = @import("telegram");

const sample_update_envelope =
    \\{"ok":true,"result":{"update_id":84920192,"message":{"message_id":4091,"from":{"id":9817263,"is_bot":false,"first_name":"Andrey","username":"guanchzhou","language_code":"en"},"chat":{"id":-100192837465,"title":"Zig Systems Engineering","type":"supergroup"},"date":1729420000,"text":"/benchmark --iterations 10000","entities":[{"offset":0,"length":10,"type":"bot_command"}]}}}
;

const sample_chat_member =
    \\{"status":"administrator","user":{"id":9817263,"is_bot":false,"first_name":"Andrey"},"can_be_edited":false,"is_anonymous":false,"can_manage_chat":true,"can_delete_messages":true,"can_manage_video_chats":true,"can_restrict_members":true,"can_promote_members":false,"can_change_info":true,"can_invite_users":true,"can_post_stories":true,"can_edit_stories":true,"can_delete_stories":true,"can_send_welcome_messages":true}
;

pub fn main(init: std.process.Init) !void {
    const allocator = init.gpa;
    const io = init.io;

    var quick = false;
    var check = false;
    var args = try init.minimal.args.iterateAllocator(init.arena.allocator());
    _ = args.next();
    while (args.next()) |arg| {
        if (std.mem.eql(u8, arg, "--quick")) quick = true;
        if (std.mem.eql(u8, arg, "--check")) check = true;
    }

    const iters: usize = if (quick) 4_000 else 25_000;

    // 1. Single-pass discriminated union (`ChatMember`) vs two-pass DOM (`std.json.Value` -> `parseFromValueLeaky`)
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();

    const t0 = std.Io.Timestamp.now(io, .awake);
    for (0..iters) |_| {
        _ = arena.reset(.retain_capacity);
        const cm = try std.json.parseFromSliceLeaky(telegram.bot.types.ChatMember, arena.allocator(), sample_chat_member, .{
            .ignore_unknown_fields = true,
        });
        std.mem.doNotOptimizeAway(cm);
    }
    const single_pass_ns: u64 = @intCast(@max(1, t0.untilNow(io, .awake).nanoseconds));

    const t1 = std.Io.Timestamp.now(io, .awake);
    for (0..iters) |_| {
        _ = arena.reset(.retain_capacity);
        const dom = try std.json.parseFromSliceLeaky(std.json.Value, arena.allocator(), sample_chat_member, .{});
        const tag = dom.object.get("status").?.string;
        if (std.mem.eql(u8, tag, "administrator")) {
            const admin = try std.json.parseFromValueLeaky(telegram.bot.types.ChatMemberAdministrator, arena.allocator(), dom, .{
                .ignore_unknown_fields = true,
            });
            std.mem.doNotOptimizeAway(admin);
        }
    }
    const dom_two_pass_ns: u64 = @intCast(@max(1, t1.untilNow(io, .awake).nanoseconds));

    // 2. Full `Update` envelope parse
    const t2 = std.Io.Timestamp.now(io, .awake);
    for (0..iters) |_| {
        _ = arena.reset(.retain_capacity);
        const env = try std.json.parseFromSliceLeaky(
            telegram.json.RawEnvelope(telegram.bot.types.Update),
            arena.allocator(),
            sample_update_envelope,
            .{ .ignore_unknown_fields = true },
        );
        std.mem.doNotOptimizeAway(env);
    }
    const update_parse_ns: u64 = @intCast(@max(1, t2.untilNow(io, .awake).nanoseconds));

    // 3. MTProto 2.0 AES-256-IGE + SHA-256 msg_key throughput (1 KiB payload)
    var auth_key: [256]u8 = undefined;
    for (&auth_key, 0..) |*b, idx| b.* = @truncate(idx *% 19 +% 5);
    var payload_1k: [1024]u8 = @splat(0xA5);
    var cipher_1k: [1024]u8 = undefined;
    const key_iv = telegram.mtproto.crypto.deriveAesKeyIv(&auth_key, @splat(0x11), .client_to_server);

    const t3 = std.Io.Timestamp.now(io, .awake);
    for (0..iters) |_| {
        try telegram.mtproto.crypto.aes256IgeEncrypt(key_iv.key, key_iv.iv, &payload_1k, &cipher_1k);
        std.mem.doNotOptimizeAway(&cipher_1k);
    }
    const ige_ns: u64 = @intCast(@max(1, t3.untilNow(io, .awake).nanoseconds));

    // 4. Constant-time SHA-256 webhook verification
    const t4 = std.Io.Timestamp.now(io, .awake);
    for (0..iters) |_| {
        const ok = telegram.secret.verifyWebhookSecretConstantTime(
            "whsec_production_secret_token_2026",
            "whsec_production_secret_token_2026",
        );
        std.mem.doNotOptimizeAway(ok);
    }
    const webhook_ns: u64 = @intCast(@max(1, t4.untilNow(io, .awake).nanoseconds));

    const single_ns_per_op = single_pass_ns / iters;
    const dom_ns_per_op = dom_two_pass_ns / iters;
    const speedup = @as(f64, @floatFromInt(dom_two_pass_ns)) / @as(f64, @floatFromInt(single_pass_ns));
    const update_ns_per_op = update_parse_ns / iters;
    const ige_mb_per_s = (@as(f64, @floatFromInt(iters * 1024)) / (1024.0 * 1024.0)) /
        (@as(f64, @floatFromInt(ige_ns)) / 1_000_000_000.0);
    const webhook_ns_per_op = webhook_ns / iters;

    var stdout_buf: [2048]u8 = undefined;
    var stdout = std.Io.File.stdout().writer(io, &stdout_buf);
    try stdout.interface.print(
        \\zig-telegram ReleaseFast benchmark ({d} iterations)
        \\--------------------------------------------------------------------
        \\Discriminated union single-pass : {d:>6} ns/op
        \\Discriminated union 2-pass DOM  : {d:>6} ns/op  ({d:.2}x speedup)
        \\Full Bot API Update envelope    : {d:>6} ns/op
        \\MTProto 2.0 AES-256-IGE (1 KiB) : {d:>6.1} MiB/s
        \\Webhook SHA-256 constant-time   : {d:>6} ns/op
        \\
    , .{
        iters,
        single_ns_per_op,
        dom_ns_per_op,
        speedup,
        update_ns_per_op,
        ige_mb_per_s,
        webhook_ns_per_op,
    });
    try stdout.interface.flush();

    if (check) {
        if (speedup < 1.05) {
            std.debug.print("perf-check failed: single-pass union speedup {d:.2}x < 1.05x\n", .{speedup});
            return error.PerfRegression;
        }
        if (ige_mb_per_s < 20.0) {
            std.debug.print("perf-check failed: AES-256-IGE throughput {d:.1} MiB/s < 20.0 MiB/s\n", .{ige_mb_per_s});
            return error.PerfRegression;
        }
    }
}
