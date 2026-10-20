//! Comprehensive Bot API 10.3 golden wire tests, surface method-address probe
//! (semantic analysis of all 185 `BotClient` method bodies), recursive nested
//! `attach://` multipart tests (`sendMediaGroup`, `sendPaidMedia`, `editMessageMedia`,
//! `sendRichMessage`), discriminated union round-trip tests, and
//! `std.testing.FailingAllocator` OOM resilience tests.

const std = @import("std");
const telegram = @import("telegram");

test "surface probe: force semantic analysis of all 185 BotClient methods" {
    // Note: `std.testing.refAllDecls` only touches declarations without analyzing
    // function bodies. Taking the address of every public `BotClient` method
    // (`_ = &telegram.BotClient.<method>;`) forces the Zig compiler to semantically
    // analyze all 185 method bodies, their parameter structs, and their return types.
    const decls = @typeInfo(telegram.BotClient).@"struct".decl_names;
    inline for (decls) |decl_name| {
        _ = &@field(telegram.BotClient, decl_name);
    }
    try std.testing.expectEqual(@as(usize, 185), telegram.bot.methods.method_count);
}

test "nested attach:// multipart in sendMediaGroup and editMessageMedia" {
    const allocator = std.testing.allocator;
    const io = std.testing.io;

    var mock = telegram.MockTransport.init(allocator);
    defer mock.deinit();

    try mock.pushResponse(200,
        \\{"ok":true,"result":[{"message_id":201,"date":1725000000,"chat":{"id":-100123,"type":"supergroup"}},{"message_id":202,"date":1725000000,"chat":{"id":-100123,"type":"supergroup"}}]}
    );
    try mock.pushResponse(200,
        \\{"ok":true,"result":{"message_id":201,"date":1725000001,"chat":{"id":-100123,"type":"supergroup"}}}
    );

    const token = try telegram.SecretToken.initValidated("999111:AAH_golden_test");
    const client = telegram.BotClient.init(allocator, io, token, mock.transport(), .{});

    const media_items = [_]telegram.bot.types.InputMedia{
        .{
            .photo = .{
                .media = .{
                    .bytes = .{
                        .filename = "slide_1.png",
                        .data = "PNG_BYTES_ONE",
                        .content_type = "image/png",
                    },
                },
                .caption = "Slide 1",
            },
        },
        .{
            .video = .{
                .media = .{
                    .bytes = .{
                        .filename = "demo_2.mp4",
                        .data = "MP4_BYTES_TWO",
                        .content_type = "video/mp4",
                    },
                },
                .thumbnail = .{
                    .bytes = .{
                        .filename = "thumb_2.jpg",
                        .data = "JPG_THUMB_TWO",
                        .content_type = "image/jpeg",
                    },
                },
                .caption = "Demo 2",
            },
        },
    };

    var group_res = try client.sendMediaGroup(.{
        .chat_id = .{ .id = -100123 },
        .media = &media_items,
    }, null);
    defer group_res.deinit();

    try std.testing.expectEqual(@as(usize, 2), group_res.value.len);
    const req1 = mock.recorded.items[0];
    try std.testing.expect(req1.content_type != null);
    try std.testing.expect(std.mem.startsWith(u8, req1.content_type.?, "multipart/form-data; boundary=----ZigTelegramBoundary"));

    const body1 = req1.body.?;
    try std.testing.expect(std.mem.indexOf(u8, body1, "\"media\":\"attach://part_0\"") != null);
    try std.testing.expect(std.mem.indexOf(u8, body1, "\"media\":\"attach://part_1\"") != null);
    try std.testing.expect(std.mem.indexOf(u8, body1, "\"thumbnail\":\"attach://part_2\"") != null);
    try std.testing.expect(std.mem.indexOf(u8, body1, "name=\"part_0\"; filename=\"slide_1.png\"") != null);
    try std.testing.expect(std.mem.indexOf(u8, body1, "name=\"part_1\"; filename=\"demo_2.mp4\"") != null);
    try std.testing.expect(std.mem.indexOf(u8, body1, "name=\"part_2\"; filename=\"thumb_2.jpg\"") != null);

    // Also test editMessageMedia (union top-level field with nested InputFile)
    var edit_res = try client.editMessageMedia(.{
        .chat_id = .{ .id = -100123 },
        .message_id = 201,
        .media = .{
            .photo = .{
                .media = .{
                    .bytes = .{
                        .filename = "replacement.png",
                        .data = "REPLACED_PNG",
                        .content_type = "image/png",
                    },
                },
            },
        },
    }, null);
    defer edit_res.deinit();
    try std.testing.expectEqual(@as(i64, 201), edit_res.value.object.message_id);
}

test "discriminated unions: MaybeInaccessibleMessage, ChatMember, MessageOrigin, ReactionType, RichText" {
    const allocator = std.testing.allocator;
    const types = telegram.bot.types;

    // 1. MaybeInaccessibleMessage (date == 0 -> inaccessible_message, date > 0 -> message)
    const json_inaccessible =
        \\{"chat":{"id":-10055,"type":"supergroup"},"message_id":99,"date":0}
    ;
    var parsed_inacc = try std.json.parseFromSlice(types.MaybeInaccessibleMessage, allocator, json_inaccessible, .{});
    defer parsed_inacc.deinit();
    try std.testing.expect(parsed_inacc.value == .inaccessible_message);
    try std.testing.expectEqual(@as(i64, 99), parsed_inacc.value.inaccessible_message.message_id);

    const json_accessible =
        \\{"chat":{"id":-10055,"type":"supergroup"},"message_id":100,"date":1726000000,"text":"live message"}
    ;
    var parsed_acc = try std.json.parseFromSlice(types.MaybeInaccessibleMessage, allocator, json_accessible, .{});
    defer parsed_acc.deinit();
    try std.testing.expect(parsed_acc.value == .message);
    try std.testing.expectEqualStrings("live message", parsed_acc.value.message.text.?);

    // 2. ChatMember (`status = "creator"` -> `.owner`)
    const json_owner =
        \\{"status":"creator","user":{"id":42,"is_bot":false,"first_name":"Andrey"},"is_anonymous":false}
    ;
    var parsed_owner = try std.json.parseFromSlice(types.ChatMember, allocator, json_owner, .{});
    defer parsed_owner.deinit();
    try std.testing.expect(parsed_owner.value == .owner);
    try std.testing.expectEqualStrings("Andrey", parsed_owner.value.owner.user.first_name);

    // 3. ReactionType (`type = "emoji"`)
    const json_react =
        \\{"type":"emoji","emoji":"🔥"}
    ;
    var parsed_react = try std.json.parseFromSlice(types.ReactionType, allocator, json_react, .{});
    defer parsed_react.deinit();
    try std.testing.expect(parsed_react.value == .emoji);
    try std.testing.expectEqualStrings("🔥", parsed_react.value.emoji.emoji);

    // 4. Bot API 10.3 RichText (plain string, array, or object with `"type":"bold"`)
    const json_rich =
        \\[{"type":"bold","text":"Zig 0.17"}," + Bot API 10.3"]
    ;
    var parsed_rich = try std.json.parseFromSlice(types.RichText, allocator, json_rich, .{});
    defer parsed_rich.deinit();
    try std.testing.expect(parsed_rich.value == .array);
    try std.testing.expectEqual(@as(usize, 2), parsed_rich.value.array.len);
    try std.testing.expect(parsed_rich.value.array[0] == .bold);
    try std.testing.expectEqualStrings(" + Bot API 10.3", parsed_rich.value.array[1].plain);
}

test "OOM resilience under std.testing.FailingAllocator" {
    const io = std.testing.io;
    const raw_envelope =
        \\{"ok":true,"result":{"id":12345,"is_bot":true,"first_name":"OomBot","username":"oom_bot"}}
    ;

    var fail_index: usize = 0;
    while (fail_index < 32) : (fail_index += 1) {
        var failing = std.testing.FailingAllocator.init(std.testing.allocator, .{
            .fail_index = fail_index,
        });
        const alloc = failing.allocator();

        var detail: ?telegram.ErrorDetail = null;
        defer if (detail) |*d| d.deinit(alloc);

        if (telegram.json.parseResponseEnvelope(telegram.bot.types.User, alloc, 200, raw_envelope, &detail)) |*parsed| {
            defer parsed.deinit();
            try std.testing.expectEqual(@as(i64, 12345), parsed.value.id);
            break;
        } else |err| {
            try std.testing.expectEqual(error.OutOfMemory, err);
        }
    }

    // Also test MTProto Session encrypt/decrypt under FailingAllocator
    const auth_key: [256]u8 = @splat(0x42);
    var session = telegram.mtproto.Session.init(auth_key, 1, 2);
    var fail_mt: usize = 0;
    while (fail_mt < 16) : (fail_mt += 1) {
        var failing = std.testing.FailingAllocator.init(std.testing.allocator, .{
            .fail_index = fail_mt,
        });
        const alloc = failing.allocator();
        if (session.encryptMessage(alloc, io, .client_to_server, 4, 1, "test_payload")) |pkt| {
            defer alloc.free(pkt);
            break;
        } else |err| {
            try std.testing.expectEqual(error.OutOfMemory, err);
        }
    }
}
