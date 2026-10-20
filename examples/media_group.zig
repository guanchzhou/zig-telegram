//! Example: Multi-file album upload (`sendMediaGroup`) using automatic recursive
//! `attach://part_<n>` multipart rewriting.

const std = @import("std");
const telegram = @import("telegram");

pub fn main(init: std.process.Init) !void {
    const allocator = init.gpa;
    const io = init.io;

    var mock = telegram.MockTransport.init(allocator);
    defer mock.deinit();

    try mock.pushResponse(200,
        \\{"ok":true,"result":[{"message_id":301,"date":1726000000,"chat":{"id":-100777,"type":"supergroup"}},{"message_id":302,"date":1726000000,"chat":{"id":-100777,"type":"supergroup"}}]}
    );

    const token = try telegram.SecretToken.initValidated("123456:AAH_media_group_example");
    const client = telegram.BotClient.init(allocator, io, token, mock.transport(), .{});

    const album = [_]telegram.bot.types.InputMedia{
        .{
            .photo = .{
                .media = .{
                    .bytes = .{
                        .filename = "architecture.png",
                        .data = "\x89PNG\r\n\x1a\n",
                        .content_type = "image/png",
                    },
                },
                .caption = "Architecture diagram",
            },
        },
        .{
            .photo = .{
                .media = .{
                    .bytes = .{
                        .filename = "benchmarks.png",
                        .data = "\x89PNG\r\n\x1a\n",
                        .content_type = "image/png",
                    },
                },
                .caption = "Throughput chart",
            },
        },
    };

    var sent = try client.sendMediaGroup(.{
        .chat_id = .{ .id = -100777 },
        .media = &album,
    }, null);
    defer sent.deinit();

    std.debug.assert(sent.value.len == 2);
}
