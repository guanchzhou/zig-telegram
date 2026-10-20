//! Deterministic CLI test suite (`zig build test-cli`).

const std = @import("std");
const telegram = @import("telegram");
const cli = @import("cli");

test "CLI version and --help" {
    const allocator = std.testing.allocator;
    const io = std.testing.io;

    var out: std.Io.Writer.Allocating = .init(allocator);
    defer out.deinit();
    var err_out: std.Io.Writer.Allocating = .init(allocator);
    defer err_out.deinit();

    const code_help = try cli.runCli(allocator, io, &.{"--help"}, null, null, &out.writer, &err_out.writer);
    try std.testing.expectEqual(@as(u8, 0), code_help);
    try std.testing.expect(std.mem.indexOf(u8, out.written(), "USAGE:") != null);

    out.clearRetainingCapacity();
    const code_ver = try cli.runCli(allocator, io, &.{"version"}, null, null, &out.writer, &err_out.writer);
    try std.testing.expectEqual(@as(u8, 0), code_ver);
    try std.testing.expect(std.mem.indexOf(u8, out.written(), "Bot API 10.3, 185 methods") != null);
}

test "CLI spec and mtproto subcommands" {
    const allocator = std.testing.allocator;
    const io = std.testing.io;

    var out: std.Io.Writer.Allocating = .init(allocator);
    defer out.deinit();
    var err_out: std.Io.Writer.Allocating = .init(allocator);
    defer err_out.deinit();

    const code_spec = try cli.runCli(allocator, io, &.{ "spec", "--method", "sendRichMessage" }, null, null, &out.writer, &err_out.writer);
    try std.testing.expectEqual(@as(u8, 0), code_spec);
    try std.testing.expect(std.mem.indexOf(u8, out.written(), "\"method\":\"sendRichMessage\"") != null);

    out.clearRetainingCapacity();
    const code_pq = try cli.runCli(allocator, io, &.{ "mtproto", "factor-pq", "--pq", "0x17ED48941A08F981" }, null, null, &out.writer, &err_out.writer);
    try std.testing.expectEqual(@as(u8, 0), code_pq);
    try std.testing.expect(std.mem.indexOf(u8, out.written(), "\"p\":1229739323") != null);

    out.clearRetainingCapacity();
    const code_tl = try cli.runCli(allocator, io, &.{ "mtproto", "inspect-tl", "--hex", "ec77be7a01020304" }, null, null, &out.writer, &err_out.writer);
    try std.testing.expectEqual(@as(u8, 0), code_tl);
    try std.testing.expect(std.mem.indexOf(u8, out.written(), "\"constructor_id\":\"0x7abe77ec\"") != null);
}

test "CLI me, send, call, and webhook with MockTransport" {
    const allocator = std.testing.allocator;
    const io = std.testing.io;

    var mock = telegram.MockTransport.init(allocator);
    defer mock.deinit();

    try mock.pushResponse(200,
        \\{"ok":true,"result":{"id":777000,"is_bot":true,"first_name":"ZigBot","username":"zig_telegram_bot"}}
    );
    try mock.pushResponse(200,
        \\{"ok":true,"result":{"message_id":55,"date":1720000000,"chat":{"id":1001,"type":"private"},"text":"hello from cli"}}
    );
    try mock.pushResponse(200,
        \\{"ok":true,"result":true}
    );

    var out: std.Io.Writer.Allocating = .init(allocator);
    defer out.deinit();
    var err_out: std.Io.Writer.Allocating = .init(allocator);
    defer err_out.deinit();

    const tok = "777000:AAH_cli_test_secret";

    const code_me = try cli.runCli(allocator, io, &.{"me"}, tok, mock.transport(), &out.writer, &err_out.writer);
    try std.testing.expectEqual(@as(u8, 0), code_me);
    try std.testing.expect(std.mem.indexOf(u8, out.written(), "\"username\":\"zig_telegram_bot\"") != null);

    out.clearRetainingCapacity();
    const code_send = try cli.runCli(
        allocator,
        io,
        &.{ "send", "--chat", "1001", "--text", "hello from cli", "--parse-mode", "HTML" },
        tok,
        mock.transport(),
        &out.writer,
        &err_out.writer,
    );
    try std.testing.expectEqual(@as(u8, 0), code_send);
    try std.testing.expect(std.mem.indexOf(u8, out.written(), "\"message_id\":55") != null);

    out.clearRetainingCapacity();
    const code_wh = try cli.runCli(
        allocator,
        io,
        &.{ "webhook", "set", "--url", "https://bot.example.com/hook", "--secret", "s3cr3t" },
        tok,
        mock.transport(),
        &out.writer,
        &err_out.writer,
    );
    try std.testing.expectEqual(@as(u8, 0), code_wh);
    try std.testing.expectEqualStrings("{\"ok\":true}\n", out.written());
}
