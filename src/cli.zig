//! `zig-telegram` command-line interface.
//!
//! Commands:
//! - `zig-telegram me [--token <tok>] [--api-url <url>]`
//! - `zig-telegram send --chat <id|@channel> --text <msg> [--parse-mode HTML|MarkdownV2] [--file <path>]`
//! - `zig-telegram poll [--timeout 30] [--limit 100]`
//! - `zig-telegram call <methodName> [--json '{"key":"val"}']`
//! - `zig-telegram file --id <file_id> --out <path>`
//! - `zig-telegram webhook set --url <https://...> [--secret <tok>]`
//! - `zig-telegram webhook info`
//! - `zig-telegram webhook delete`
//! - `zig-telegram mtproto inspect-tl --hex <hex_bytes>`
//! - `zig-telegram mtproto factor-pq --pq <u64_or_0xhex>`
//! - `zig-telegram spec [--method <name>]`
//! - `zig-telegram version`
//! - `zig-telegram --help`

const std = @import("std");
const Allocator = std.mem.Allocator;
const telegram = @import("telegram");

pub const usage_text =
    \\zig-telegram 0.1.0 — Fast, memory-safe Telegram Bot API 10.3 & MTProto 2.0 CLI
    \\
    \\USAGE:
    \\  zig-telegram <command> [options]
    \\
    \\COMMANDS:
    \\  me                                Inspect bot identity via getMe
    \\  send --chat <id> --text <msg>     Send a message or upload a file (--file <path>)
    \\  poll [--timeout 30] [--limit 100] Stream incoming updates as NDJSON
    \\  call <method> [--json '{...}']    Execute any of the 185 Bot API 10.3 methods
    \\  file --id <file_id> --out <path>  Resolve and download a Telegram file
    \\  webhook <set|info|delete>         Manage webhook configuration
    \\  mtproto <inspect-tl|factor-pq>    Inspect MTProto 2.0 TL frames or factor DH pq
    \\  spec [--method <name>]            Query Bot API 10.3 specification inventory
    \\  version                           Print library and Bot API specification version
    \\
    \\GLOBAL OPTIONS:
    \\  --token <bot_token>               Bot token (or set TELEGRAM_BOT_TOKEN)
    \\  --api-url <url>                   Override Bot API base URL (default: https://api.telegram.org)
    \\  --help, -h                        Print this help message
    \\
;

pub const CliError = error{
    MissingCommand,
    UnknownCommand,
    MissingArgument,
    InvalidArgument,
    MissingToken,
};

/// Executes a CLI invocation against `args` (excluding `argv[0]`), writing
/// output to `stdout` and errors to `stderr`. Accepts an optional `custom_transport`
/// so unit tests can run all CLI commands against `MockTransport` deterministically.
pub fn runCli(
    allocator: Allocator,
    io: std.Io,
    args: []const []const u8,
    env_token: ?[]const u8,
    custom_transport: ?telegram.Transport,
    stdout: *std.Io.Writer,
    stderr: *std.Io.Writer,
) !u8 {
    if (args.len == 0) {
        try stdout.writeAll(usage_text);
        return 0;
    }

    const cmd = args[0];
    if (std.mem.eql(u8, cmd, "--help") or std.mem.eql(u8, cmd, "-h") or std.mem.eql(u8, cmd, "help")) {
        try stdout.writeAll(usage_text);
        return 0;
    }

    if (std.mem.eql(u8, cmd, "version") or std.mem.eql(u8, cmd, "--version") or std.mem.eql(u8, cmd, "-V")) {
        try stdout.print("zig-telegram {s} ({s}, {d} methods)\n", .{
            telegram.version,
            telegram.bot_api_version,
            telegram.bot.methods.method_count,
        });
        return 0;
    }

    if (std.mem.eql(u8, cmd, "spec")) {
        return runSpecCmd(args[1..], stdout, stderr);
    }

    if (std.mem.eql(u8, cmd, "mtproto")) {
        return runMtprotoCmd(allocator, args[1..], stdout, stderr);
    }

    // Remaining commands require a BotClient (`me`, `send`, `poll`, `call`, `file`, `webhook`).
    var token_raw: ?[]const u8 = env_token;
    var api_url: []const u8 = telegram.transport.default_api_base_url;

    var i: usize = 1;
    while (i < args.len) : (i += 1) {
        if (std.mem.eql(u8, args[i], "--token")) {
            i += 1;
            if (i >= args.len) {
                try stderr.writeAll("error: --token requires a value\n");
                return 2;
            }
            token_raw = args[i];
        } else if (std.mem.eql(u8, args[i], "--api-url")) {
            i += 1;
            if (i >= args.len) {
                try stderr.writeAll("error: --api-url requires a value\n");
                return 2;
            }
            api_url = args[i];
        }
    }

    const tok_str = token_raw orelse {
        try stderr.writeAll("error: missing bot token (pass --token <tok> or set TELEGRAM_BOT_TOKEN)\n");
        return 2;
    };
    const secret_tok = telegram.SecretToken.initValidated(tok_str) catch |err| {
        try stderr.print("error: invalid bot token format ({s})\n", .{@errorName(err)});
        return 2;
    };

    var http_transport: ?telegram.HttpTransport = if (custom_transport == null)
        telegram.HttpTransport.init(allocator, io)
    else
        null;
    defer if (http_transport) |*ht| ht.deinit();

    const active_transport = custom_transport orelse http_transport.?.transport();
    const client = telegram.BotClient.init(allocator, io, secret_tok, active_transport, .{
        .base_url = api_url,
    });

    if (std.mem.eql(u8, cmd, "me")) {
        var detail: ?telegram.ErrorDetail = null;
        defer if (detail) |*d| d.deinit(allocator);
        var me = client.getMe(.{}, &detail) catch |err| {
            try reportTelegramError(stderr, err, detail);
            return 1;
        };
        defer me.deinit();
        const json_out = try telegram.json.stringifyAlloc(allocator, me.value);
        defer allocator.free(json_out);
        try stdout.print("{s}\n", .{json_out});
        return 0;
    }

    if (std.mem.eql(u8, cmd, "send")) {
        return runSendCmd(allocator, &client, args[1..], stdout, stderr);
    }

    if (std.mem.eql(u8, cmd, "call")) {
        return runCallCmd(allocator, &client, args[1..], stdout, stderr);
    }

    if (std.mem.eql(u8, cmd, "poll")) {
        return runPollCmd(allocator, &client, args[1..], stdout, stderr);
    }

    if (std.mem.eql(u8, cmd, "file")) {
        return runFileCmd(allocator, io, &client, args[1..], stdout, stderr);
    }

    if (std.mem.eql(u8, cmd, "webhook")) {
        return runWebhookCmd(allocator, &client, args[1..], stdout, stderr);
    }

    try stderr.print("error: unknown command '{s}'\n", .{cmd});
    return 2;
}

fn runSpecCmd(args: []const []const u8, stdout: *std.Io.Writer, stderr: *std.Io.Writer) !u8 {
    var filter_method: ?[]const u8 = null;
    var i: usize = 0;
    while (i < args.len) : (i += 1) {
        if (std.mem.eql(u8, args[i], "--method")) {
            i += 1;
            if (i >= args.len) {
                try stderr.writeAll("error: --method requires a name\n");
                return 2;
            }
            filter_method = args[i];
        }
    }

    if (filter_method) |target| {
        for (telegram.bot.methods.all_method_names) |m| {
            if (std.ascii.eqlIgnoreCase(m, target)) {
                try stdout.print("{{\"version\":\"{s}\",\"method\":\"{s}\",\"supported\":true}}\n", .{
                    telegram.bot.methods.spec_version,
                    m,
                });
                return 0;
            }
        }
        try stderr.print("error: method '{s}' not found in {s}\n", .{ target, telegram.bot.methods.spec_version });
        return 1;
    }

    try stdout.print("{{\"version\":\"{s}\",\"release_date\":\"{s}\",\"methods\":{d}}}\n", .{
        telegram.bot.methods.spec_version,
        telegram.bot.methods.spec_release_date,
        telegram.bot.methods.method_count,
    });
    return 0;
}

fn runMtprotoCmd(
    allocator: Allocator,
    args: []const []const u8,
    stdout: *std.Io.Writer,
    stderr: *std.Io.Writer,
) !u8 {
    if (args.len == 0) {
        try stderr.writeAll("error: mtproto requires subcommand <inspect-tl|factor-pq>\n");
        return 2;
    }
    const sub = args[0];
    if (std.mem.eql(u8, sub, "factor-pq")) {
        var pq_str: ?[]const u8 = null;
        var i: usize = 1;
        while (i < args.len) : (i += 1) {
            if (std.mem.eql(u8, args[i], "--pq")) {
                i += 1;
                if (i < args.len) pq_str = args[i];
            }
        }
        const raw = pq_str orelse {
            try stderr.writeAll("error: mtproto factor-pq requires --pq <u64>\n");
            return 2;
        };
        const pq_val = std.fmt.parseInt(u64, raw, 0) catch {
            try stderr.writeAll("error: invalid --pq integer\n");
            return 2;
        };
        const factored = telegram.mtproto.crypto.factorizePq(pq_val) catch {
            try stderr.writeAll("error: failed to factor pq\n");
            return 1;
        };
        try stdout.print("{{\"pq\":{d},\"p\":{d},\"q\":{d}}}\n", .{ pq_val, factored.p, factored.q });
        return 0;
    }

    if (std.mem.eql(u8, sub, "inspect-tl")) {
        var hex_str: ?[]const u8 = null;
        var i: usize = 1;
        while (i < args.len) : (i += 1) {
            if (std.mem.eql(u8, args[i], "--hex")) {
                i += 1;
                if (i < args.len) hex_str = args[i];
            }
        }
        const raw_hex = hex_str orelse {
            try stderr.writeAll("error: mtproto inspect-tl requires --hex <hex_bytes>\n");
            return 2;
        };
        if (raw_hex.len < 8 or raw_hex.len % 2 != 0) {
            try stderr.writeAll("error: --hex must contain at least 4 bytes (8 hex digits)\n");
            return 2;
        }
        const bytes = try allocator.alloc(u8, raw_hex.len / 2);
        defer allocator.free(bytes);
        _ = std.fmt.hexToBytes(bytes, raw_hex) catch {
            try stderr.writeAll("error: invalid hex string\n");
            return 2;
        };
        var reader = telegram.mtproto.TlReader.init(bytes);
        const constructor_id = try reader.readU32();
        try stdout.print("{{\"constructor_id\":\"0x{x:0>8}\",\"total_bytes\":{d},\"aligned_4b\":{s}}}\n", .{
            constructor_id,
            bytes.len,
            if (bytes.len % 4 == 0) "true" else "false",
        });
        return 0;
    }

    try stderr.print("error: unknown mtproto subcommand '{s}'\n", .{sub});
    return 2;
}

fn runSendCmd(
    allocator: Allocator,
    client: *const telegram.BotClient,
    args: []const []const u8,
    stdout: *std.Io.Writer,
    stderr: *std.Io.Writer,
) !u8 {
    var chat_str: ?[]const u8 = null;
    var text_str: ?[]const u8 = null;
    var file_path: ?[]const u8 = null;
    var parse_mode: ?telegram.bot.enums.ParseMode = null;

    var i: usize = 0;
    while (i < args.len) : (i += 1) {
        const a = args[i];
        if (std.mem.eql(u8, a, "--chat")) {
            i += 1;
            if (i < args.len) chat_str = args[i];
        } else if (std.mem.eql(u8, a, "--text")) {
            i += 1;
            if (i < args.len) text_str = args[i];
        } else if (std.mem.eql(u8, a, "--file")) {
            i += 1;
            if (i < args.len) file_path = args[i];
        } else if (std.mem.eql(u8, a, "--parse-mode")) {
            i += 1;
            if (i < args.len) {
                parse_mode = std.meta.stringToEnum(telegram.bot.enums.ParseMode, args[i]) orelse {
                    try stderr.writeAll("error: invalid --parse-mode (expected HTML, Markdown, or MarkdownV2)\n");
                    return 2;
                };
            }
        } else if (std.mem.eql(u8, a, "--token") or std.mem.eql(u8, a, "--api-url")) {
            i += 1;
        }
    }

    const raw_chat = chat_str orelse {
        try stderr.writeAll("error: send requires --chat <id|@username>\n");
        return 2;
    };
    const chat_id: telegram.ChatId = if (std.fmt.parseInt(i64, raw_chat, 10)) |id_num|
        .{ .id = id_num }
    else |_|
        .{ .username = raw_chat };

    var detail: ?telegram.ErrorDetail = null;
    defer if (detail) |*d| d.deinit(allocator);

    if (file_path) |fpath| {
        var sent = client.sendDocument(.{
            .chat_id = chat_id,
            .document = .{ .path = fpath },
            .caption = text_str,
            .parse_mode = parse_mode,
        }, &detail) catch |err| {
            try reportTelegramError(stderr, err, detail);
            return 1;
        };
        defer sent.deinit();
        const json_out = try telegram.json.stringifyAlloc(allocator, sent.value);
        defer allocator.free(json_out);
        try stdout.print("{s}\n", .{json_out});
        return 0;
    }

    const msg_text = text_str orelse {
        try stderr.writeAll("error: send requires --text <msg> or --file <path>\n");
        return 2;
    };
    var sent = client.sendMessage(.{
        .chat_id = chat_id,
        .text = msg_text,
        .parse_mode = parse_mode,
    }, &detail) catch |err| {
        try reportTelegramError(stderr, err, detail);
        return 1;
    };
    defer sent.deinit();
    const json_out = try telegram.json.stringifyAlloc(allocator, sent.value);
    defer allocator.free(json_out);
    try stdout.print("{s}\n", .{json_out});
    return 0;
}

fn runCallCmd(
    allocator: Allocator,
    client: *const telegram.BotClient,
    args: []const []const u8,
    stdout: *std.Io.Writer,
    stderr: *std.Io.Writer,
) !u8 {
    if (args.len == 0) {
        try stderr.writeAll("error: call requires <methodName>\n");
        return 2;
    }
    const method_name = args[0];
    var json_payload: ?[]const u8 = null;

    var i: usize = 1;
    while (i < args.len) : (i += 1) {
        if (std.mem.eql(u8, args[i], "--json")) {
            i += 1;
            if (i < args.len) json_payload = args[i];
        } else if (std.mem.eql(u8, args[i], "--token") or std.mem.eql(u8, args[i], "--api-url")) {
            i += 1;
        }
    }

    var resp = client.callRawJson(allocator, method_name, json_payload) catch |err| {
        try stderr.print("error: call {s} failed: {s}\n", .{ method_name, @errorName(err) });
        return 1;
    };
    defer resp.deinit(allocator);
    try stdout.print("{s}\n", .{resp.body});
    return if (resp.status >= 400) 1 else 0;
}

fn runPollCmd(
    allocator: Allocator,
    client: *const telegram.BotClient,
    args: []const []const u8,
    stdout: *std.Io.Writer,
    stderr: *std.Io.Writer,
) !u8 {
    var timeout: i64 = 30;
    var limit: i64 = 100;
    var max_batches: ?usize = null;

    var i: usize = 0;
    while (i < args.len) : (i += 1) {
        if (std.mem.eql(u8, args[i], "--timeout")) {
            i += 1;
            if (i < args.len) timeout = std.fmt.parseInt(i64, args[i], 10) catch 30;
        } else if (std.mem.eql(u8, args[i], "--limit")) {
            i += 1;
            if (i < args.len) limit = std.fmt.parseInt(i64, args[i], 10) catch 100;
        } else if (std.mem.eql(u8, args[i], "--once")) {
            max_batches = 1;
        } else if (std.mem.eql(u8, args[i], "--token") or std.mem.eql(u8, args[i], "--api-url")) {
            i += 1;
        }
    }

    var poller = telegram.Poller.init(client, .{
        .timeout_seconds = timeout,
        .limit = limit,
    });

    const Ctx = struct {
        alloc: Allocator,
        out: *std.Io.Writer,

        fn onUpdate(ctx: @This(), upd: telegram.bot.types.Update) !void {
            const line = try telegram.json.stringifyAlloc(ctx.alloc, upd);
            defer ctx.alloc.free(line);
            try ctx.out.print("{s}\n", .{line});
            try ctx.out.flush();
        }
    };

    poller.run(Ctx{ .alloc = allocator, .out = stdout }, Ctx.onUpdate, max_batches) catch |err| {
        try stderr.print("error: poll failed: {s}\n", .{@errorName(err)});
        return 1;
    };
    return 0;
}

fn runFileCmd(
    allocator: Allocator,
    io: std.Io,
    client: *const telegram.BotClient,
    args: []const []const u8,
    stdout: *std.Io.Writer,
    stderr: *std.Io.Writer,
) !u8 {
    var file_id: ?[]const u8 = null;
    var out_path: ?[]const u8 = null;

    var i: usize = 0;
    while (i < args.len) : (i += 1) {
        if (std.mem.eql(u8, args[i], "--id")) {
            i += 1;
            if (i < args.len) file_id = args[i];
        } else if (std.mem.eql(u8, args[i], "--out")) {
            i += 1;
            if (i < args.len) out_path = args[i];
        } else if (std.mem.eql(u8, args[i], "--token") or std.mem.eql(u8, args[i], "--api-url")) {
            i += 1;
        }
    }

    const fid = file_id orelse {
        try stderr.writeAll("error: file requires --id <file_id>\n");
        return 2;
    };

    var detail: ?telegram.ErrorDetail = null;
    defer if (detail) |*d| d.deinit(allocator);

    var file_info = client.getFile(.{ .file_id = fid }, &detail) catch |err| {
        try reportTelegramError(stderr, err, detail);
        return 1;
    };
    defer file_info.deinit();

    if (out_path) |dest| {
        const remote_path = file_info.value.file_path orelse {
            try stderr.writeAll("error: getFile response did not include file_path\n");
            return 1;
        };
        const data = try client.downloadFile(allocator, remote_path);
        defer allocator.free(data);
        try std.Io.Dir.cwd().writeFile(io, .{ .sub_path = dest, .data = data });
        try stdout.print("{{\"saved\":\"{s}\",\"bytes\":{d}}}\n", .{ dest, data.len });
    } else {
        const json_out = try telegram.json.stringifyAlloc(allocator, file_info.value);
        defer allocator.free(json_out);
        try stdout.print("{s}\n", .{json_out});
    }
    return 0;
}

fn runWebhookCmd(
    allocator: Allocator,
    client: *const telegram.BotClient,
    args: []const []const u8,
    stdout: *std.Io.Writer,
    stderr: *std.Io.Writer,
) !u8 {
    if (args.len == 0) {
        try stderr.writeAll("error: webhook requires subcommand <set|info|delete>\n");
        return 2;
    }
    const sub = args[0];
    var detail: ?telegram.ErrorDetail = null;
    defer if (detail) |*d| d.deinit(allocator);

    if (std.mem.eql(u8, sub, "info")) {
        var info = client.getWebhookInfo(.{}, &detail) catch |err| {
            try reportTelegramError(stderr, err, detail);
            return 1;
        };
        defer info.deinit();
        const json_out = try telegram.json.stringifyAlloc(allocator, info.value);
        defer allocator.free(json_out);
        try stdout.print("{s}\n", .{json_out});
        return 0;
    }

    if (std.mem.eql(u8, sub, "delete")) {
        var res = client.deleteWebhook(.{}, &detail) catch |err| {
            try reportTelegramError(stderr, err, detail);
            return 1;
        };
        defer res.deinit();
        try stdout.print("{{\"ok\":{s}}}\n", .{if (res.value) "true" else "false"});
        return 0;
    }

    if (std.mem.eql(u8, sub, "set")) {
        var url: ?[]const u8 = null;
        var secret: ?[]const u8 = null;
        var i: usize = 1;
        while (i < args.len) : (i += 1) {
            if (std.mem.eql(u8, args[i], "--url")) {
                i += 1;
                if (i < args.len) url = args[i];
            } else if (std.mem.eql(u8, args[i], "--secret")) {
                i += 1;
                if (i < args.len) secret = args[i];
            } else if (std.mem.eql(u8, args[i], "--token") or std.mem.eql(u8, args[i], "--api-url")) {
                i += 1;
            }
        }
        const target_url = url orelse {
            try stderr.writeAll("error: webhook set requires --url <https://...>\n");
            return 2;
        };
        var res = client.setWebhook(.{
            .url = target_url,
            .secret_token = secret,
        }, &detail) catch |err| {
            try reportTelegramError(stderr, err, detail);
            return 1;
        };
        defer res.deinit();
        try stdout.print("{{\"ok\":{s}}}\n", .{if (res.value) "true" else "false"});
        return 0;
    }

    try stderr.print("error: unknown webhook subcommand '{s}'\n", .{sub});
    return 2;
}

fn reportTelegramError(
    stderr: *std.Io.Writer,
    err: telegram.TelegramError,
    detail: ?telegram.ErrorDetail,
) !void {
    if (detail) |d| {
        try stderr.print("error: {f}\n", .{d});
    } else {
        try stderr.print("error: {s}\n", .{@errorName(err)});
    }
}

pub fn main(init: std.process.Init) !u8 {
    const arena = init.arena.allocator();
    const io = init.io;

    var arg_list: std.ArrayList([]const u8) = .empty;
    var it = try init.minimal.args.iterateAllocator(arena);
    _ = it.next();
    while (it.next()) |arg| {
        try arg_list.append(arena, arg);
    }

    const env_token = init.environ_map.get("TELEGRAM_BOT_TOKEN");

    var stdout_buf: [4096]u8 = undefined;
    var stderr_buf: [4096]u8 = undefined;
    var stdout_writer = std.Io.File.stdout().writer(io, &stdout_buf);
    var stderr_writer = std.Io.File.stderr().writer(io, &stderr_buf);

    const code = try runCli(
        init.gpa,
        io,
        arg_list.items,
        env_token,
        null,
        &stdout_writer.interface,
        &stderr_writer.interface,
    );
    try stdout_writer.interface.flush();
    try stderr_writer.interface.flush();
    return code;
}
