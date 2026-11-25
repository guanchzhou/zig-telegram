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

test "CLI rejects non-https --api-url unless the host is loopback" {
    try std.testing.expect(cli.isAllowedApiUrl("https://api.telegram.org"));
    try std.testing.expect(cli.isAllowedApiUrl("http://127.0.0.1:8081"));
    try std.testing.expect(cli.isAllowedApiUrl("http://localhost:8081"));
    try std.testing.expect(cli.isAllowedApiUrl("http://[::1]:8081"));
    try std.testing.expect(!cli.isAllowedApiUrl("http://api.telegram.org"));
    try std.testing.expect(!cli.isAllowedApiUrl("http://127.0.0.1.evil.example"));
    try std.testing.expect(!cli.isAllowedApiUrl("ftp://127.0.0.1"));
    try std.testing.expect(!cli.isAllowedApiUrl("not a url"));
    // Missing host, userinfo, query, and fragment must all be rejected.
    try std.testing.expect(!cli.isAllowedApiUrl("https://"));
    try std.testing.expect(!cli.isAllowedApiUrl("https://user@api.telegram.org"));
    try std.testing.expect(!cli.isAllowedApiUrl("https://user:pass@api.telegram.org"));
    try std.testing.expect(!cli.isAllowedApiUrl("https://api.telegram.org?x=1"));
    try std.testing.expect(!cli.isAllowedApiUrl("https://api.telegram.org#frag"));
    try std.testing.expect(!cli.isAllowedApiUrl("http://user@127.0.0.1:8081"));
    try std.testing.expect(!cli.isAllowedApiUrl("http://127.0.0.1:8081?x=1"));
    try std.testing.expect(!cli.isAllowedApiUrl("http://127.0.0.1:8081#frag"));

    const allocator = std.testing.allocator;
    var out: std.Io.Writer.Allocating = .init(allocator);
    defer out.deinit();
    var err_out: std.Io.Writer.Allocating = .init(allocator);
    defer err_out.deinit();
    var mock = telegram.MockTransport.init(allocator);
    defer mock.deinit();
    const code = try cli.runCli(allocator, std.testing.io, &.{ "me", "--token", "123:abc", "--api-url", "http://example.com" }, null, mock.transport(), &out.writer, &err_out.writer);
    try std.testing.expectEqual(@as(u8, 2), code);
    try std.testing.expect(mock.recorded.items.len == 0);
}

test "CLI poll returns exit code 2 on invalid or out-of-range --timeout and --limit" {
    const allocator = std.testing.allocator;
    const io = std.testing.io;
    const tok = "777000:AAH_cli_poll_test";

    const bad_cases = [_][]const []const u8{
        &.{ "poll", "--timeout" },
        &.{ "poll", "--timeout", "abc" },
        &.{ "poll", "--timeout", "-1" },
        &.{ "poll", "--timeout", "3601" },
        &.{ "poll", "--limit" },
        &.{ "poll", "--limit", "xyz" },
        &.{ "poll", "--limit", "0" },
        &.{ "poll", "--limit", "101" },
    };

    for (bad_cases) |argv| {
        var out: std.Io.Writer.Allocating = .init(allocator);
        defer out.deinit();
        var err_out: std.Io.Writer.Allocating = .init(allocator);
        defer err_out.deinit();
        var mock = telegram.MockTransport.init(allocator);
        defer mock.deinit();

        const code = try cli.runCli(allocator, io, argv, tok, mock.transport(), &out.writer, &err_out.writer);
        try std.testing.expectEqual(@as(u8, 2), code);
        try std.testing.expectEqual(@as(usize, 0), mock.recorded.items.len);
    }
}

test "CLI file --out emits properly JSON-escaped output" {
    const allocator = std.testing.allocator;
    const io = std.testing.io;

    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    var dir_buf: [std.Io.Dir.max_path_bytes]u8 = undefined;
    const dir_len = try tmp.dir.realPath(io, &dir_buf);
    const out_path = try std.fmt.allocPrint(allocator, "{s}/out\"quote\\slash.bin", .{dir_buf[0..dir_len]});
    defer allocator.free(out_path);

    var mock = telegram.MockTransport.init(allocator);
    defer mock.deinit();
    try mock.pushResponse(200,
        \\{"ok":true,"result":{"file_id":"fid1","file_unique_id":"uid1","file_path":"photos/p1.bin"}}
    );
    try mock.pushResponse(200, "HELLO");

    var out: std.Io.Writer.Allocating = .init(allocator);
    defer out.deinit();
    var err_out: std.Io.Writer.Allocating = .init(allocator);
    defer err_out.deinit();

    const code = try cli.runCli(
        allocator,
        io,
        &.{ "file", "--id", "fid1", "--out", out_path },
        "777000:AAH_cli_file_test",
        mock.transport(),
        &out.writer,
        &err_out.writer,
    );
    try std.testing.expectEqual(@as(u8, 0), code);

    const Parsed = struct { saved: []const u8, bytes: usize };
    var parsed = try std.json.parseFromSlice(Parsed, allocator, std.mem.trimEnd(u8, out.written(), "\r\n"), .{});
    defer parsed.deinit();
    try std.testing.expectEqualStrings(out_path, parsed.value.saved);
    try std.testing.expectEqual(@as(usize, 5), parsed.value.bytes);
}

test "callRawJson rejects invalid method names before sending" {
    const allocator = std.testing.allocator;
    var mock = telegram.MockTransport.init(allocator);
    defer mock.deinit();
    const token = try telegram.SecretToken.initValidated("123:abc");
    const client = telegram.BotClient.init(allocator, std.testing.io, token, mock.transport(), .{});
    try std.testing.expectError(error.InvalidMethodName, client.callRawJson(allocator, "../getMe", null));
    try std.testing.expect(mock.recorded.items.len == 0);
}
