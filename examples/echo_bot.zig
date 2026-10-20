//! Example: Echo & command bot using `BotClient`, `Router`, and `MockTransport`.

const std = @import("std");
const telegram = @import("telegram");

const BotState = struct {
    client: *const telegram.BotClient,
    replies_sent: usize = 0,

    fn onStart(self: *BotState, msg: telegram.bot.types.Message, cmd: telegram.bot.ParsedCommand) !void {
        const greeting = if (cmd.args.len > 0) cmd.args else "Welcome to zig-telegram!";
        var sent = try self.client.sendMessage(.{
            .chat_id = .{ .id = msg.chat.id },
            .text = greeting,
            .parse_mode = .HTML,
        }, null);
        defer sent.deinit();
        self.replies_sent += 1;
    }

    fn onEcho(self: *BotState, msg: telegram.bot.types.Message) !void {
        const text = msg.text orelse return;
        var sent = try self.client.sendMessage(.{
            .chat_id = .{ .id = msg.chat.id },
            .text = text,
        }, null);
        defer sent.deinit();
        self.replies_sent += 1;
    }
};

pub fn main(init: std.process.Init) !void {
    const allocator = init.gpa;
    const io = init.io;

    var mock = telegram.MockTransport.init(allocator);
    defer mock.deinit();

    try mock.pushResponse(200,
        \\{"ok":true,"result":[{"update_id":1,"message":{"message_id":10,"date":1725000000,"chat":{"id":42,"type":"private"},"text":"/start@echo_bot Hello Zig 0.17"}}]}
    );
    try mock.pushResponse(200,
        \\{"ok":true,"result":{"message_id":11,"date":1725000001,"chat":{"id":42,"type":"private"},"text":"Hello Zig 0.17"}}
    );

    const token = try telegram.SecretToken.initValidated("123456:AAH_example_token");
    const client = telegram.BotClient.init(allocator, io, token, mock.transport(), .{});

    var state = BotState{ .client = &client };
    const router = telegram.Router(*BotState){
        .bot_username = "echo_bot",
        .commands = &.{
            .{ .command = "start", .handler = BotState.onStart },
        },
        .on_message = BotState.onEcho,
    };

    var poller = telegram.Poller.init(&client, .{ .timeout_seconds = 0 });
    var batch = try poller.pollBatch(null);
    defer batch.deinit();

    for (batch.value) |upd| {
        _ = try router.dispatch(&state, upd);
    }

    std.debug.assert(state.replies_sent == 1);
}
