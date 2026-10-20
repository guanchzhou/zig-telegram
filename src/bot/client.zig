//! Typed Telegram Bot API 10.3 (August 24, 2026) client with all 185 Bot API methods, automatic
//! JSON vs `multipart/form-data` (`attach://`) selection, bodiless empty-param
//! requests, and caller-owned `ErrorDetail` diagnostics.
//!
//! Generated deterministically from `spec/bot_api_10_3.json` by `tools/gen_bot_api.zig`.

const std = @import("std");
const Allocator = std.mem.Allocator;
const secret_mod = @import("../secret.zig");
const err_mod = @import("../error.zig");
const json_mod = @import("../json.zig");
const multipart_mod = @import("../multipart.zig");
const transport_mod = @import("../transport.zig");
pub const types = @import("types.zig");
pub const methods = @import("methods.zig");
pub const enums = @import("enums.zig");

pub const SecretToken = secret_mod.SecretToken;
pub const TelegramError = err_mod.TelegramError;
pub const ErrorDetail = err_mod.ErrorDetail;
pub const Transport = transport_mod.Transport;
pub const LocalServerConfig = transport_mod.LocalServerConfig;

pub const ClientConfig = struct {
    /// Base URL for Bot API calls (`https://api.telegram.org` or local server URL).
    base_url: []const u8 = transport_mod.default_api_base_url,
    /// Maximum allowed response body size in bytes (defaults to 16 MiB).
    max_response_bytes: usize = transport_mod.default_max_response_bytes,
    /// Optional `--local` server path remapping configuration.
    local_server: ?LocalServerConfig = null,
};

pub const BotClient = struct {
    allocator: Allocator,
    io: std.Io,
    token: SecretToken,
    transport: Transport,
    config: ClientConfig = .{},

    pub fn init(
        allocator: Allocator,
        io: std.Io,
        token: SecretToken,
        transport: Transport,
        config: ClientConfig,
    ) BotClient {
        var resolved_config = config;
        if (config.local_server) |ls| {
            if (std.mem.eql(u8, config.base_url, transport_mod.default_api_base_url)) {
                resolved_config.base_url = ls.base_url;
            }
        }
        return .{
            .allocator = allocator,
            .io = io,
            .token = token,
            .transport = transport,
            .config = resolved_config,
        };
    }

    /// Builds the full request URL for `method_name`.
    pub fn buildMethodUrl(self: *const BotClient, allocator: Allocator, method_name: []const u8) Allocator.Error![]u8 {
        const base = std.mem.trimEnd(u8, self.config.base_url, "/");
        return std.fmt.allocPrint(allocator, "{s}/bot{s}/{s}", .{
            base,
            self.token.expose(),
            method_name,
        });
    }

    /// Builds the download URL for a `File.file_path` returned by `getFile`.
    pub fn buildFileDownloadUrl(self: *const BotClient, allocator: Allocator, file_path: []const u8) Allocator.Error![]u8 {
        const base = std.mem.trimEnd(u8, self.config.base_url, "/");
        const trimmed_path = std.mem.trimStart(u8, file_path, "/");
        return std.fmt.allocPrint(allocator, "{s}/file/bot{s}/{s}", .{
            base,
            self.token.expose(),
            trimmed_path,
        });
    }

    /// Downloads a file by `file_path` (from `getFile`), or reads it directly
    /// from disk when `config.local_server` is configured and `file_path` is an
    /// absolute local path.
    pub fn downloadFile(self: *const BotClient, allocator: Allocator, file_path: []const u8) TelegramError![]u8 {
        if (self.config.local_server) |ls| {
            if (std.fs.path.isAbsolute(file_path)) {
                const host_path = try ls.resolveLocalFilePath(allocator, file_path);
                defer allocator.free(host_path);
                return std.Io.Dir.cwd().readFileAlloc(
                    self.io,
                    host_path,
                    allocator,
                    .limited(self.config.max_response_bytes),
                ) catch return error.FileReadError;
            }
        }
        const url = try self.buildFileDownloadUrl(allocator, file_path);
        defer allocator.free(url);
        var raw = try self.transport.send(allocator, .{
            .url = url,
            .body = null,
            .max_response_bytes = self.config.max_response_bytes,
        });
        errdefer raw.deinit(allocator);
        if (raw.status >= 400) {
            const code = raw.status;
            raw.deinit(allocator);
            return err_mod.errorFromCode(code);
        }
        return raw.body;
    }

    /// Executes any `methods.<Method>` struct and decodes `Method.ReturnType`.
    ///
    /// Automatically selects between:
    /// 1. Bodiless request when all parameters are unset/empty
    /// 2. `multipart/form-data` with recursive `attach://part_<n>` rewriting when
    ///    any top-level or nested `InputFile` is `.path` or `.bytes`
    /// 3. Single-pass `application/json`
    pub fn call(
        self: *const BotClient,
        comptime Method: type,
        params: Method,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(Method.ReturnType) {
        const url = try self.buildMethodUrl(self.allocator, Method.api_method_name);
        defer self.allocator.free(url);

        var raw_resp: transport_mod.RawResponse = undefined;
        if (json_mod.isEmptyParams(params)) {
            raw_resp = try self.transport.send(self.allocator, .{
                .url = url,
                .content_type = null,
                .body = null,
                .max_response_bytes = self.config.max_response_bytes,
            });
        } else if (comptime multipart_mod.containsAttachment(Method)) {
            if (multipart_mod.hasRuntimeAttachment(params)) {
                const boundary = multipart_mod.generateBoundary(self.io);
                var mp = try multipart_mod.encodeMultipart(self.allocator, self.io, &boundary, params);
                defer mp.deinit(self.allocator);
                raw_resp = try self.transport.send(self.allocator, .{
                    .url = url,
                    .content_type = mp.content_type,
                    .body = mp.body,
                    .max_response_bytes = self.config.max_response_bytes,
                });
            } else {
                const json_body = try json_mod.stringifyAlloc(self.allocator, params);
                defer self.allocator.free(json_body);
                raw_resp = try self.transport.send(self.allocator, .{
                    .url = url,
                    .content_type = "application/json",
                    .body = json_body,
                    .max_response_bytes = self.config.max_response_bytes,
                });
            }
        } else {
            const json_body = try json_mod.stringifyAlloc(self.allocator, params);
            defer self.allocator.free(json_body);
            raw_resp = try self.transport.send(self.allocator, .{
                .url = url,
                .content_type = "application/json",
                .body = json_body,
                .max_response_bytes = self.config.max_response_bytes,
            });
        }
        defer raw_resp.deinit(self.allocator);

        return json_mod.parseResponseEnvelope(
            Method.ReturnType,
            self.allocator,
            raw_resp.status,
            raw_resp.body,
            err_out,
        );
    }

    /// Executes an arbitrary Bot API method by name with a raw JSON body (or `null`)
    /// and returns the raw response JSON string. Useful for CLI `call` and debugging.
    pub fn callRawJson(
        self: *const BotClient,
        allocator: Allocator,
        method_name: []const u8,
        json_body: ?[]const u8,
    ) TelegramError!transport_mod.RawResponse {
        const url = try self.buildMethodUrl(allocator, method_name);
        defer allocator.free(url);
        const trimmed = if (json_body) |b| std.mem.trim(u8, b, " \t\r\n") else null;
        const is_empty = trimmed == null or trimmed.?.len == 0 or std.mem.eql(u8, trimmed.?, "{}");
        return self.transport.send(allocator, .{
            .url = url,
            .content_type = if (is_empty) null else "application/json",
            .body = if (is_empty) null else trimmed,
            .max_response_bytes = self.config.max_response_bytes,
        });
    }

    pub fn addStickerToSet(
        self: *const BotClient,
        params: methods.AddStickerToSet,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.AddStickerToSet.ReturnType) {
        return self.call(methods.AddStickerToSet, params, err_out);
    }

    pub fn answerCallbackQuery(
        self: *const BotClient,
        params: methods.AnswerCallbackQuery,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.AnswerCallbackQuery.ReturnType) {
        return self.call(methods.AnswerCallbackQuery, params, err_out);
    }

    pub fn answerChatJoinRequestQuery(
        self: *const BotClient,
        params: methods.AnswerChatJoinRequestQuery,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.AnswerChatJoinRequestQuery.ReturnType) {
        return self.call(methods.AnswerChatJoinRequestQuery, params, err_out);
    }

    pub fn answerGuestQuery(
        self: *const BotClient,
        params: methods.AnswerGuestQuery,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.AnswerGuestQuery.ReturnType) {
        return self.call(methods.AnswerGuestQuery, params, err_out);
    }

    pub fn answerInlineQuery(
        self: *const BotClient,
        params: methods.AnswerInlineQuery,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.AnswerInlineQuery.ReturnType) {
        return self.call(methods.AnswerInlineQuery, params, err_out);
    }

    pub fn answerPreCheckoutQuery(
        self: *const BotClient,
        params: methods.AnswerPreCheckoutQuery,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.AnswerPreCheckoutQuery.ReturnType) {
        return self.call(methods.AnswerPreCheckoutQuery, params, err_out);
    }

    pub fn answerShippingQuery(
        self: *const BotClient,
        params: methods.AnswerShippingQuery,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.AnswerShippingQuery.ReturnType) {
        return self.call(methods.AnswerShippingQuery, params, err_out);
    }

    pub fn answerWebAppQuery(
        self: *const BotClient,
        params: methods.AnswerWebAppQuery,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.AnswerWebAppQuery.ReturnType) {
        return self.call(methods.AnswerWebAppQuery, params, err_out);
    }

    pub fn approveChatJoinRequest(
        self: *const BotClient,
        params: methods.ApproveChatJoinRequest,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.ApproveChatJoinRequest.ReturnType) {
        return self.call(methods.ApproveChatJoinRequest, params, err_out);
    }

    pub fn approveSuggestedPost(
        self: *const BotClient,
        params: methods.ApproveSuggestedPost,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.ApproveSuggestedPost.ReturnType) {
        return self.call(methods.ApproveSuggestedPost, params, err_out);
    }

    pub fn banChatMember(
        self: *const BotClient,
        params: methods.BanChatMember,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.BanChatMember.ReturnType) {
        return self.call(methods.BanChatMember, params, err_out);
    }

    pub fn banChatSenderChat(
        self: *const BotClient,
        params: methods.BanChatSenderChat,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.BanChatSenderChat.ReturnType) {
        return self.call(methods.BanChatSenderChat, params, err_out);
    }

    pub fn close(
        self: *const BotClient,
        params: methods.Close,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.Close.ReturnType) {
        return self.call(methods.Close, params, err_out);
    }

    pub fn closeForumTopic(
        self: *const BotClient,
        params: methods.CloseForumTopic,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.CloseForumTopic.ReturnType) {
        return self.call(methods.CloseForumTopic, params, err_out);
    }

    pub fn closeGeneralForumTopic(
        self: *const BotClient,
        params: methods.CloseGeneralForumTopic,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.CloseGeneralForumTopic.ReturnType) {
        return self.call(methods.CloseGeneralForumTopic, params, err_out);
    }

    pub fn convertGiftToStars(
        self: *const BotClient,
        params: methods.ConvertGiftToStars,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.ConvertGiftToStars.ReturnType) {
        return self.call(methods.ConvertGiftToStars, params, err_out);
    }

    pub fn copyMessage(
        self: *const BotClient,
        params: methods.CopyMessage,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.CopyMessage.ReturnType) {
        return self.call(methods.CopyMessage, params, err_out);
    }

    pub fn copyMessages(
        self: *const BotClient,
        params: methods.CopyMessages,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.CopyMessages.ReturnType) {
        return self.call(methods.CopyMessages, params, err_out);
    }

    pub fn createChatInviteLink(
        self: *const BotClient,
        params: methods.CreateChatInviteLink,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.CreateChatInviteLink.ReturnType) {
        return self.call(methods.CreateChatInviteLink, params, err_out);
    }

    pub fn createChatSubscriptionInviteLink(
        self: *const BotClient,
        params: methods.CreateChatSubscriptionInviteLink,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.CreateChatSubscriptionInviteLink.ReturnType) {
        return self.call(methods.CreateChatSubscriptionInviteLink, params, err_out);
    }

    pub fn createForumTopic(
        self: *const BotClient,
        params: methods.CreateForumTopic,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.CreateForumTopic.ReturnType) {
        return self.call(methods.CreateForumTopic, params, err_out);
    }

    pub fn createInvoiceLink(
        self: *const BotClient,
        params: methods.CreateInvoiceLink,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.CreateInvoiceLink.ReturnType) {
        return self.call(methods.CreateInvoiceLink, params, err_out);
    }

    pub fn createNewStickerSet(
        self: *const BotClient,
        params: methods.CreateNewStickerSet,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.CreateNewStickerSet.ReturnType) {
        return self.call(methods.CreateNewStickerSet, params, err_out);
    }

    pub fn declineChatJoinRequest(
        self: *const BotClient,
        params: methods.DeclineChatJoinRequest,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.DeclineChatJoinRequest.ReturnType) {
        return self.call(methods.DeclineChatJoinRequest, params, err_out);
    }

    pub fn declineSuggestedPost(
        self: *const BotClient,
        params: methods.DeclineSuggestedPost,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.DeclineSuggestedPost.ReturnType) {
        return self.call(methods.DeclineSuggestedPost, params, err_out);
    }

    pub fn deleteAllMessageReactions(
        self: *const BotClient,
        params: methods.DeleteAllMessageReactions,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.DeleteAllMessageReactions.ReturnType) {
        return self.call(methods.DeleteAllMessageReactions, params, err_out);
    }

    pub fn deleteBusinessMessages(
        self: *const BotClient,
        params: methods.DeleteBusinessMessages,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.DeleteBusinessMessages.ReturnType) {
        return self.call(methods.DeleteBusinessMessages, params, err_out);
    }

    pub fn deleteChatPhoto(
        self: *const BotClient,
        params: methods.DeleteChatPhoto,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.DeleteChatPhoto.ReturnType) {
        return self.call(methods.DeleteChatPhoto, params, err_out);
    }

    pub fn deleteChatStickerSet(
        self: *const BotClient,
        params: methods.DeleteChatStickerSet,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.DeleteChatStickerSet.ReturnType) {
        return self.call(methods.DeleteChatStickerSet, params, err_out);
    }

    pub fn deleteEphemeralMessage(
        self: *const BotClient,
        params: methods.DeleteEphemeralMessage,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.DeleteEphemeralMessage.ReturnType) {
        return self.call(methods.DeleteEphemeralMessage, params, err_out);
    }

    pub fn deleteForumTopic(
        self: *const BotClient,
        params: methods.DeleteForumTopic,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.DeleteForumTopic.ReturnType) {
        return self.call(methods.DeleteForumTopic, params, err_out);
    }

    pub fn deleteMessage(
        self: *const BotClient,
        params: methods.DeleteMessage,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.DeleteMessage.ReturnType) {
        return self.call(methods.DeleteMessage, params, err_out);
    }

    pub fn deleteMessageReaction(
        self: *const BotClient,
        params: methods.DeleteMessageReaction,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.DeleteMessageReaction.ReturnType) {
        return self.call(methods.DeleteMessageReaction, params, err_out);
    }

    pub fn deleteMessages(
        self: *const BotClient,
        params: methods.DeleteMessages,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.DeleteMessages.ReturnType) {
        return self.call(methods.DeleteMessages, params, err_out);
    }

    pub fn deleteMyCommands(
        self: *const BotClient,
        params: methods.DeleteMyCommands,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.DeleteMyCommands.ReturnType) {
        return self.call(methods.DeleteMyCommands, params, err_out);
    }

    pub fn deleteStickerFromSet(
        self: *const BotClient,
        params: methods.DeleteStickerFromSet,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.DeleteStickerFromSet.ReturnType) {
        return self.call(methods.DeleteStickerFromSet, params, err_out);
    }

    pub fn deleteStickerSet(
        self: *const BotClient,
        params: methods.DeleteStickerSet,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.DeleteStickerSet.ReturnType) {
        return self.call(methods.DeleteStickerSet, params, err_out);
    }

    pub fn deleteStory(
        self: *const BotClient,
        params: methods.DeleteStory,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.DeleteStory.ReturnType) {
        return self.call(methods.DeleteStory, params, err_out);
    }

    pub fn deleteWebhook(
        self: *const BotClient,
        params: methods.DeleteWebhook,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.DeleteWebhook.ReturnType) {
        return self.call(methods.DeleteWebhook, params, err_out);
    }

    pub fn editChatInviteLink(
        self: *const BotClient,
        params: methods.EditChatInviteLink,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.EditChatInviteLink.ReturnType) {
        return self.call(methods.EditChatInviteLink, params, err_out);
    }

    pub fn editChatSubscriptionInviteLink(
        self: *const BotClient,
        params: methods.EditChatSubscriptionInviteLink,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.EditChatSubscriptionInviteLink.ReturnType) {
        return self.call(methods.EditChatSubscriptionInviteLink, params, err_out);
    }

    pub fn editEphemeralMessageCaption(
        self: *const BotClient,
        params: methods.EditEphemeralMessageCaption,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.EditEphemeralMessageCaption.ReturnType) {
        return self.call(methods.EditEphemeralMessageCaption, params, err_out);
    }

    pub fn editEphemeralMessageMedia(
        self: *const BotClient,
        params: methods.EditEphemeralMessageMedia,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.EditEphemeralMessageMedia.ReturnType) {
        return self.call(methods.EditEphemeralMessageMedia, params, err_out);
    }

    pub fn editEphemeralMessageReplyMarkup(
        self: *const BotClient,
        params: methods.EditEphemeralMessageReplyMarkup,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.EditEphemeralMessageReplyMarkup.ReturnType) {
        return self.call(methods.EditEphemeralMessageReplyMarkup, params, err_out);
    }

    pub fn editEphemeralMessageText(
        self: *const BotClient,
        params: methods.EditEphemeralMessageText,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.EditEphemeralMessageText.ReturnType) {
        return self.call(methods.EditEphemeralMessageText, params, err_out);
    }

    pub fn editForumTopic(
        self: *const BotClient,
        params: methods.EditForumTopic,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.EditForumTopic.ReturnType) {
        return self.call(methods.EditForumTopic, params, err_out);
    }

    pub fn editGeneralForumTopic(
        self: *const BotClient,
        params: methods.EditGeneralForumTopic,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.EditGeneralForumTopic.ReturnType) {
        return self.call(methods.EditGeneralForumTopic, params, err_out);
    }

    pub fn editMessageCaption(
        self: *const BotClient,
        params: methods.EditMessageCaption,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.EditMessageCaption.ReturnType) {
        return self.call(methods.EditMessageCaption, params, err_out);
    }

    pub fn editMessageChecklist(
        self: *const BotClient,
        params: methods.EditMessageChecklist,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.EditMessageChecklist.ReturnType) {
        return self.call(methods.EditMessageChecklist, params, err_out);
    }

    pub fn editMessageLiveLocation(
        self: *const BotClient,
        params: methods.EditMessageLiveLocation,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.EditMessageLiveLocation.ReturnType) {
        return self.call(methods.EditMessageLiveLocation, params, err_out);
    }

    pub fn editMessageMedia(
        self: *const BotClient,
        params: methods.EditMessageMedia,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.EditMessageMedia.ReturnType) {
        return self.call(methods.EditMessageMedia, params, err_out);
    }

    pub fn editMessageReplyMarkup(
        self: *const BotClient,
        params: methods.EditMessageReplyMarkup,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.EditMessageReplyMarkup.ReturnType) {
        return self.call(methods.EditMessageReplyMarkup, params, err_out);
    }

    pub fn editMessageText(
        self: *const BotClient,
        params: methods.EditMessageText,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.EditMessageText.ReturnType) {
        return self.call(methods.EditMessageText, params, err_out);
    }

    pub fn editStory(
        self: *const BotClient,
        params: methods.EditStory,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.EditStory.ReturnType) {
        return self.call(methods.EditStory, params, err_out);
    }

    pub fn editUserStarSubscription(
        self: *const BotClient,
        params: methods.EditUserStarSubscription,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.EditUserStarSubscription.ReturnType) {
        return self.call(methods.EditUserStarSubscription, params, err_out);
    }

    pub fn exportChatInviteLink(
        self: *const BotClient,
        params: methods.ExportChatInviteLink,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.ExportChatInviteLink.ReturnType) {
        return self.call(methods.ExportChatInviteLink, params, err_out);
    }

    pub fn forwardMessage(
        self: *const BotClient,
        params: methods.ForwardMessage,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.ForwardMessage.ReturnType) {
        return self.call(methods.ForwardMessage, params, err_out);
    }

    pub fn forwardMessages(
        self: *const BotClient,
        params: methods.ForwardMessages,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.ForwardMessages.ReturnType) {
        return self.call(methods.ForwardMessages, params, err_out);
    }

    pub fn getAvailableGifts(
        self: *const BotClient,
        params: methods.GetAvailableGifts,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.GetAvailableGifts.ReturnType) {
        return self.call(methods.GetAvailableGifts, params, err_out);
    }

    pub fn getBusinessAccountGifts(
        self: *const BotClient,
        params: methods.GetBusinessAccountGifts,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.GetBusinessAccountGifts.ReturnType) {
        return self.call(methods.GetBusinessAccountGifts, params, err_out);
    }

    pub fn getBusinessAccountStarBalance(
        self: *const BotClient,
        params: methods.GetBusinessAccountStarBalance,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.GetBusinessAccountStarBalance.ReturnType) {
        return self.call(methods.GetBusinessAccountStarBalance, params, err_out);
    }

    pub fn getBusinessConnection(
        self: *const BotClient,
        params: methods.GetBusinessConnection,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.GetBusinessConnection.ReturnType) {
        return self.call(methods.GetBusinessConnection, params, err_out);
    }

    pub fn getChat(
        self: *const BotClient,
        params: methods.GetChat,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.GetChat.ReturnType) {
        return self.call(methods.GetChat, params, err_out);
    }

    pub fn getChatAdministrators(
        self: *const BotClient,
        params: methods.GetChatAdministrators,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.GetChatAdministrators.ReturnType) {
        return self.call(methods.GetChatAdministrators, params, err_out);
    }

    pub fn getChatGifts(
        self: *const BotClient,
        params: methods.GetChatGifts,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.GetChatGifts.ReturnType) {
        return self.call(methods.GetChatGifts, params, err_out);
    }

    pub fn getChatMember(
        self: *const BotClient,
        params: methods.GetChatMember,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.GetChatMember.ReturnType) {
        return self.call(methods.GetChatMember, params, err_out);
    }

    pub fn getChatMemberCount(
        self: *const BotClient,
        params: methods.GetChatMemberCount,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.GetChatMemberCount.ReturnType) {
        return self.call(methods.GetChatMemberCount, params, err_out);
    }

    pub fn getChatMenuButton(
        self: *const BotClient,
        params: methods.GetChatMenuButton,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.GetChatMenuButton.ReturnType) {
        return self.call(methods.GetChatMenuButton, params, err_out);
    }

    pub fn getCustomEmojiStickers(
        self: *const BotClient,
        params: methods.GetCustomEmojiStickers,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.GetCustomEmojiStickers.ReturnType) {
        return self.call(methods.GetCustomEmojiStickers, params, err_out);
    }

    pub fn getFile(
        self: *const BotClient,
        params: methods.GetFile,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.GetFile.ReturnType) {
        return self.call(methods.GetFile, params, err_out);
    }

    pub fn getForumTopicIconStickers(
        self: *const BotClient,
        params: methods.GetForumTopicIconStickers,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.GetForumTopicIconStickers.ReturnType) {
        return self.call(methods.GetForumTopicIconStickers, params, err_out);
    }

    pub fn getGameHighScores(
        self: *const BotClient,
        params: methods.GetGameHighScores,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.GetGameHighScores.ReturnType) {
        return self.call(methods.GetGameHighScores, params, err_out);
    }

    pub fn getManagedBotAccessSettings(
        self: *const BotClient,
        params: methods.GetManagedBotAccessSettings,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.GetManagedBotAccessSettings.ReturnType) {
        return self.call(methods.GetManagedBotAccessSettings, params, err_out);
    }

    pub fn getManagedBotToken(
        self: *const BotClient,
        params: methods.GetManagedBotToken,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.GetManagedBotToken.ReturnType) {
        return self.call(methods.GetManagedBotToken, params, err_out);
    }

    pub fn getMe(
        self: *const BotClient,
        params: methods.GetMe,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.GetMe.ReturnType) {
        return self.call(methods.GetMe, params, err_out);
    }

    pub fn getMyCommands(
        self: *const BotClient,
        params: methods.GetMyCommands,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.GetMyCommands.ReturnType) {
        return self.call(methods.GetMyCommands, params, err_out);
    }

    pub fn getMyDefaultAdministratorRights(
        self: *const BotClient,
        params: methods.GetMyDefaultAdministratorRights,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.GetMyDefaultAdministratorRights.ReturnType) {
        return self.call(methods.GetMyDefaultAdministratorRights, params, err_out);
    }

    pub fn getMyDescription(
        self: *const BotClient,
        params: methods.GetMyDescription,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.GetMyDescription.ReturnType) {
        return self.call(methods.GetMyDescription, params, err_out);
    }

    pub fn getMyName(
        self: *const BotClient,
        params: methods.GetMyName,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.GetMyName.ReturnType) {
        return self.call(methods.GetMyName, params, err_out);
    }

    pub fn getMyShortDescription(
        self: *const BotClient,
        params: methods.GetMyShortDescription,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.GetMyShortDescription.ReturnType) {
        return self.call(methods.GetMyShortDescription, params, err_out);
    }

    pub fn getMyStarBalance(
        self: *const BotClient,
        params: methods.GetMyStarBalance,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.GetMyStarBalance.ReturnType) {
        return self.call(methods.GetMyStarBalance, params, err_out);
    }

    pub fn getStarTransactions(
        self: *const BotClient,
        params: methods.GetStarTransactions,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.GetStarTransactions.ReturnType) {
        return self.call(methods.GetStarTransactions, params, err_out);
    }

    pub fn getStickerSet(
        self: *const BotClient,
        params: methods.GetStickerSet,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.GetStickerSet.ReturnType) {
        return self.call(methods.GetStickerSet, params, err_out);
    }

    pub fn getUpdates(
        self: *const BotClient,
        params: methods.GetUpdates,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.GetUpdates.ReturnType) {
        return self.call(methods.GetUpdates, params, err_out);
    }

    pub fn getUserChatBoosts(
        self: *const BotClient,
        params: methods.GetUserChatBoosts,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.GetUserChatBoosts.ReturnType) {
        return self.call(methods.GetUserChatBoosts, params, err_out);
    }

    pub fn getUserGifts(
        self: *const BotClient,
        params: methods.GetUserGifts,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.GetUserGifts.ReturnType) {
        return self.call(methods.GetUserGifts, params, err_out);
    }

    pub fn getUserPersonalChatMessages(
        self: *const BotClient,
        params: methods.GetUserPersonalChatMessages,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.GetUserPersonalChatMessages.ReturnType) {
        return self.call(methods.GetUserPersonalChatMessages, params, err_out);
    }

    pub fn getUserProfileAudios(
        self: *const BotClient,
        params: methods.GetUserProfileAudios,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.GetUserProfileAudios.ReturnType) {
        return self.call(methods.GetUserProfileAudios, params, err_out);
    }

    pub fn getUserProfilePhotos(
        self: *const BotClient,
        params: methods.GetUserProfilePhotos,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.GetUserProfilePhotos.ReturnType) {
        return self.call(methods.GetUserProfilePhotos, params, err_out);
    }

    pub fn getWebhookInfo(
        self: *const BotClient,
        params: methods.GetWebhookInfo,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.GetWebhookInfo.ReturnType) {
        return self.call(methods.GetWebhookInfo, params, err_out);
    }

    pub fn giftPremiumSubscription(
        self: *const BotClient,
        params: methods.GiftPremiumSubscription,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.GiftPremiumSubscription.ReturnType) {
        return self.call(methods.GiftPremiumSubscription, params, err_out);
    }

    pub fn hideGeneralForumTopic(
        self: *const BotClient,
        params: methods.HideGeneralForumTopic,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.HideGeneralForumTopic.ReturnType) {
        return self.call(methods.HideGeneralForumTopic, params, err_out);
    }

    pub fn leaveChat(
        self: *const BotClient,
        params: methods.LeaveChat,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.LeaveChat.ReturnType) {
        return self.call(methods.LeaveChat, params, err_out);
    }

    pub fn logOut(
        self: *const BotClient,
        params: methods.LogOut,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.LogOut.ReturnType) {
        return self.call(methods.LogOut, params, err_out);
    }

    pub fn pinChatMessage(
        self: *const BotClient,
        params: methods.PinChatMessage,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.PinChatMessage.ReturnType) {
        return self.call(methods.PinChatMessage, params, err_out);
    }

    pub fn postStory(
        self: *const BotClient,
        params: methods.PostStory,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.PostStory.ReturnType) {
        return self.call(methods.PostStory, params, err_out);
    }

    pub fn promoteChatMember(
        self: *const BotClient,
        params: methods.PromoteChatMember,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.PromoteChatMember.ReturnType) {
        return self.call(methods.PromoteChatMember, params, err_out);
    }

    pub fn readBusinessMessage(
        self: *const BotClient,
        params: methods.ReadBusinessMessage,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.ReadBusinessMessage.ReturnType) {
        return self.call(methods.ReadBusinessMessage, params, err_out);
    }

    pub fn refundStarPayment(
        self: *const BotClient,
        params: methods.RefundStarPayment,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.RefundStarPayment.ReturnType) {
        return self.call(methods.RefundStarPayment, params, err_out);
    }

    pub fn removeBusinessAccountProfilePhoto(
        self: *const BotClient,
        params: methods.RemoveBusinessAccountProfilePhoto,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.RemoveBusinessAccountProfilePhoto.ReturnType) {
        return self.call(methods.RemoveBusinessAccountProfilePhoto, params, err_out);
    }

    pub fn removeChatVerification(
        self: *const BotClient,
        params: methods.RemoveChatVerification,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.RemoveChatVerification.ReturnType) {
        return self.call(methods.RemoveChatVerification, params, err_out);
    }

    pub fn removeMyProfilePhoto(
        self: *const BotClient,
        params: methods.RemoveMyProfilePhoto,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.RemoveMyProfilePhoto.ReturnType) {
        return self.call(methods.RemoveMyProfilePhoto, params, err_out);
    }

    pub fn removeUserVerification(
        self: *const BotClient,
        params: methods.RemoveUserVerification,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.RemoveUserVerification.ReturnType) {
        return self.call(methods.RemoveUserVerification, params, err_out);
    }

    pub fn reopenForumTopic(
        self: *const BotClient,
        params: methods.ReopenForumTopic,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.ReopenForumTopic.ReturnType) {
        return self.call(methods.ReopenForumTopic, params, err_out);
    }

    pub fn reopenGeneralForumTopic(
        self: *const BotClient,
        params: methods.ReopenGeneralForumTopic,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.ReopenGeneralForumTopic.ReturnType) {
        return self.call(methods.ReopenGeneralForumTopic, params, err_out);
    }

    pub fn replaceManagedBotToken(
        self: *const BotClient,
        params: methods.ReplaceManagedBotToken,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.ReplaceManagedBotToken.ReturnType) {
        return self.call(methods.ReplaceManagedBotToken, params, err_out);
    }

    pub fn replaceStickerInSet(
        self: *const BotClient,
        params: methods.ReplaceStickerInSet,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.ReplaceStickerInSet.ReturnType) {
        return self.call(methods.ReplaceStickerInSet, params, err_out);
    }

    pub fn repostStory(
        self: *const BotClient,
        params: methods.RepostStory,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.RepostStory.ReturnType) {
        return self.call(methods.RepostStory, params, err_out);
    }

    pub fn restrictChatMember(
        self: *const BotClient,
        params: methods.RestrictChatMember,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.RestrictChatMember.ReturnType) {
        return self.call(methods.RestrictChatMember, params, err_out);
    }

    pub fn revokeChatInviteLink(
        self: *const BotClient,
        params: methods.RevokeChatInviteLink,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.RevokeChatInviteLink.ReturnType) {
        return self.call(methods.RevokeChatInviteLink, params, err_out);
    }

    pub fn savePreparedInlineMessage(
        self: *const BotClient,
        params: methods.SavePreparedInlineMessage,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SavePreparedInlineMessage.ReturnType) {
        return self.call(methods.SavePreparedInlineMessage, params, err_out);
    }

    pub fn savePreparedKeyboardButton(
        self: *const BotClient,
        params: methods.SavePreparedKeyboardButton,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SavePreparedKeyboardButton.ReturnType) {
        return self.call(methods.SavePreparedKeyboardButton, params, err_out);
    }

    pub fn sendAnimation(
        self: *const BotClient,
        params: methods.SendAnimation,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SendAnimation.ReturnType) {
        return self.call(methods.SendAnimation, params, err_out);
    }

    pub fn sendAudio(
        self: *const BotClient,
        params: methods.SendAudio,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SendAudio.ReturnType) {
        return self.call(methods.SendAudio, params, err_out);
    }

    pub fn sendChatAction(
        self: *const BotClient,
        params: methods.SendChatAction,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SendChatAction.ReturnType) {
        return self.call(methods.SendChatAction, params, err_out);
    }

    pub fn sendChatJoinRequestWebApp(
        self: *const BotClient,
        params: methods.SendChatJoinRequestWebApp,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SendChatJoinRequestWebApp.ReturnType) {
        return self.call(methods.SendChatJoinRequestWebApp, params, err_out);
    }

    pub fn sendChecklist(
        self: *const BotClient,
        params: methods.SendChecklist,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SendChecklist.ReturnType) {
        return self.call(methods.SendChecklist, params, err_out);
    }

    pub fn sendContact(
        self: *const BotClient,
        params: methods.SendContact,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SendContact.ReturnType) {
        return self.call(methods.SendContact, params, err_out);
    }

    pub fn sendDice(
        self: *const BotClient,
        params: methods.SendDice,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SendDice.ReturnType) {
        return self.call(methods.SendDice, params, err_out);
    }

    pub fn sendDocument(
        self: *const BotClient,
        params: methods.SendDocument,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SendDocument.ReturnType) {
        return self.call(methods.SendDocument, params, err_out);
    }

    pub fn sendGame(
        self: *const BotClient,
        params: methods.SendGame,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SendGame.ReturnType) {
        return self.call(methods.SendGame, params, err_out);
    }

    pub fn sendGift(
        self: *const BotClient,
        params: methods.SendGift,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SendGift.ReturnType) {
        return self.call(methods.SendGift, params, err_out);
    }

    pub fn sendInvoice(
        self: *const BotClient,
        params: methods.SendInvoice,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SendInvoice.ReturnType) {
        return self.call(methods.SendInvoice, params, err_out);
    }

    pub fn sendLivePhoto(
        self: *const BotClient,
        params: methods.SendLivePhoto,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SendLivePhoto.ReturnType) {
        return self.call(methods.SendLivePhoto, params, err_out);
    }

    pub fn sendLocation(
        self: *const BotClient,
        params: methods.SendLocation,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SendLocation.ReturnType) {
        return self.call(methods.SendLocation, params, err_out);
    }

    pub fn sendMediaGroup(
        self: *const BotClient,
        params: methods.SendMediaGroup,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SendMediaGroup.ReturnType) {
        return self.call(methods.SendMediaGroup, params, err_out);
    }

    pub fn sendMessage(
        self: *const BotClient,
        params: methods.SendMessage,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SendMessage.ReturnType) {
        return self.call(methods.SendMessage, params, err_out);
    }

    pub fn sendMessageDraft(
        self: *const BotClient,
        params: methods.SendMessageDraft,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SendMessageDraft.ReturnType) {
        return self.call(methods.SendMessageDraft, params, err_out);
    }

    pub fn sendPaidMedia(
        self: *const BotClient,
        params: methods.SendPaidMedia,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SendPaidMedia.ReturnType) {
        return self.call(methods.SendPaidMedia, params, err_out);
    }

    pub fn sendPhoto(
        self: *const BotClient,
        params: methods.SendPhoto,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SendPhoto.ReturnType) {
        return self.call(methods.SendPhoto, params, err_out);
    }

    pub fn sendPoll(
        self: *const BotClient,
        params: methods.SendPoll,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SendPoll.ReturnType) {
        return self.call(methods.SendPoll, params, err_out);
    }

    pub fn sendRichMessage(
        self: *const BotClient,
        params: methods.SendRichMessage,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SendRichMessage.ReturnType) {
        return self.call(methods.SendRichMessage, params, err_out);
    }

    pub fn sendRichMessageDraft(
        self: *const BotClient,
        params: methods.SendRichMessageDraft,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SendRichMessageDraft.ReturnType) {
        return self.call(methods.SendRichMessageDraft, params, err_out);
    }

    pub fn sendSticker(
        self: *const BotClient,
        params: methods.SendSticker,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SendSticker.ReturnType) {
        return self.call(methods.SendSticker, params, err_out);
    }

    pub fn sendVenue(
        self: *const BotClient,
        params: methods.SendVenue,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SendVenue.ReturnType) {
        return self.call(methods.SendVenue, params, err_out);
    }

    pub fn sendVideo(
        self: *const BotClient,
        params: methods.SendVideo,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SendVideo.ReturnType) {
        return self.call(methods.SendVideo, params, err_out);
    }

    pub fn sendVideoNote(
        self: *const BotClient,
        params: methods.SendVideoNote,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SendVideoNote.ReturnType) {
        return self.call(methods.SendVideoNote, params, err_out);
    }

    pub fn sendVoice(
        self: *const BotClient,
        params: methods.SendVoice,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SendVoice.ReturnType) {
        return self.call(methods.SendVoice, params, err_out);
    }

    pub fn setBusinessAccountBio(
        self: *const BotClient,
        params: methods.SetBusinessAccountBio,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SetBusinessAccountBio.ReturnType) {
        return self.call(methods.SetBusinessAccountBio, params, err_out);
    }

    pub fn setBusinessAccountGiftSettings(
        self: *const BotClient,
        params: methods.SetBusinessAccountGiftSettings,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SetBusinessAccountGiftSettings.ReturnType) {
        return self.call(methods.SetBusinessAccountGiftSettings, params, err_out);
    }

    pub fn setBusinessAccountName(
        self: *const BotClient,
        params: methods.SetBusinessAccountName,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SetBusinessAccountName.ReturnType) {
        return self.call(methods.SetBusinessAccountName, params, err_out);
    }

    pub fn setBusinessAccountProfilePhoto(
        self: *const BotClient,
        params: methods.SetBusinessAccountProfilePhoto,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SetBusinessAccountProfilePhoto.ReturnType) {
        return self.call(methods.SetBusinessAccountProfilePhoto, params, err_out);
    }

    pub fn setBusinessAccountUsername(
        self: *const BotClient,
        params: methods.SetBusinessAccountUsername,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SetBusinessAccountUsername.ReturnType) {
        return self.call(methods.SetBusinessAccountUsername, params, err_out);
    }

    pub fn setChatAdministratorCustomTitle(
        self: *const BotClient,
        params: methods.SetChatAdministratorCustomTitle,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SetChatAdministratorCustomTitle.ReturnType) {
        return self.call(methods.SetChatAdministratorCustomTitle, params, err_out);
    }

    pub fn setChatDescription(
        self: *const BotClient,
        params: methods.SetChatDescription,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SetChatDescription.ReturnType) {
        return self.call(methods.SetChatDescription, params, err_out);
    }

    pub fn setChatMemberTag(
        self: *const BotClient,
        params: methods.SetChatMemberTag,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SetChatMemberTag.ReturnType) {
        return self.call(methods.SetChatMemberTag, params, err_out);
    }

    pub fn setChatMenuButton(
        self: *const BotClient,
        params: methods.SetChatMenuButton,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SetChatMenuButton.ReturnType) {
        return self.call(methods.SetChatMenuButton, params, err_out);
    }

    pub fn setChatPermissions(
        self: *const BotClient,
        params: methods.SetChatPermissions,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SetChatPermissions.ReturnType) {
        return self.call(methods.SetChatPermissions, params, err_out);
    }

    pub fn setChatPhoto(
        self: *const BotClient,
        params: methods.SetChatPhoto,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SetChatPhoto.ReturnType) {
        return self.call(methods.SetChatPhoto, params, err_out);
    }

    pub fn setChatStickerSet(
        self: *const BotClient,
        params: methods.SetChatStickerSet,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SetChatStickerSet.ReturnType) {
        return self.call(methods.SetChatStickerSet, params, err_out);
    }

    pub fn setChatTitle(
        self: *const BotClient,
        params: methods.SetChatTitle,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SetChatTitle.ReturnType) {
        return self.call(methods.SetChatTitle, params, err_out);
    }

    pub fn setCustomEmojiStickerSetThumbnail(
        self: *const BotClient,
        params: methods.SetCustomEmojiStickerSetThumbnail,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SetCustomEmojiStickerSetThumbnail.ReturnType) {
        return self.call(methods.SetCustomEmojiStickerSetThumbnail, params, err_out);
    }

    pub fn setGameScore(
        self: *const BotClient,
        params: methods.SetGameScore,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SetGameScore.ReturnType) {
        return self.call(methods.SetGameScore, params, err_out);
    }

    pub fn setManagedBotAccessSettings(
        self: *const BotClient,
        params: methods.SetManagedBotAccessSettings,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SetManagedBotAccessSettings.ReturnType) {
        return self.call(methods.SetManagedBotAccessSettings, params, err_out);
    }

    pub fn setMessageReaction(
        self: *const BotClient,
        params: methods.SetMessageReaction,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SetMessageReaction.ReturnType) {
        return self.call(methods.SetMessageReaction, params, err_out);
    }

    pub fn setMyCommands(
        self: *const BotClient,
        params: methods.SetMyCommands,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SetMyCommands.ReturnType) {
        return self.call(methods.SetMyCommands, params, err_out);
    }

    pub fn setMyDefaultAdministratorRights(
        self: *const BotClient,
        params: methods.SetMyDefaultAdministratorRights,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SetMyDefaultAdministratorRights.ReturnType) {
        return self.call(methods.SetMyDefaultAdministratorRights, params, err_out);
    }

    pub fn setMyDescription(
        self: *const BotClient,
        params: methods.SetMyDescription,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SetMyDescription.ReturnType) {
        return self.call(methods.SetMyDescription, params, err_out);
    }

    pub fn setMyName(
        self: *const BotClient,
        params: methods.SetMyName,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SetMyName.ReturnType) {
        return self.call(methods.SetMyName, params, err_out);
    }

    pub fn setMyProfilePhoto(
        self: *const BotClient,
        params: methods.SetMyProfilePhoto,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SetMyProfilePhoto.ReturnType) {
        return self.call(methods.SetMyProfilePhoto, params, err_out);
    }

    pub fn setMyShortDescription(
        self: *const BotClient,
        params: methods.SetMyShortDescription,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SetMyShortDescription.ReturnType) {
        return self.call(methods.SetMyShortDescription, params, err_out);
    }

    pub fn setPassportDataErrors(
        self: *const BotClient,
        params: methods.SetPassportDataErrors,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SetPassportDataErrors.ReturnType) {
        return self.call(methods.SetPassportDataErrors, params, err_out);
    }

    pub fn setStickerEmojiList(
        self: *const BotClient,
        params: methods.SetStickerEmojiList,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SetStickerEmojiList.ReturnType) {
        return self.call(methods.SetStickerEmojiList, params, err_out);
    }

    pub fn setStickerKeywords(
        self: *const BotClient,
        params: methods.SetStickerKeywords,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SetStickerKeywords.ReturnType) {
        return self.call(methods.SetStickerKeywords, params, err_out);
    }

    pub fn setStickerMaskPosition(
        self: *const BotClient,
        params: methods.SetStickerMaskPosition,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SetStickerMaskPosition.ReturnType) {
        return self.call(methods.SetStickerMaskPosition, params, err_out);
    }

    pub fn setStickerPositionInSet(
        self: *const BotClient,
        params: methods.SetStickerPositionInSet,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SetStickerPositionInSet.ReturnType) {
        return self.call(methods.SetStickerPositionInSet, params, err_out);
    }

    pub fn setStickerSetThumbnail(
        self: *const BotClient,
        params: methods.SetStickerSetThumbnail,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SetStickerSetThumbnail.ReturnType) {
        return self.call(methods.SetStickerSetThumbnail, params, err_out);
    }

    pub fn setStickerSetTitle(
        self: *const BotClient,
        params: methods.SetStickerSetTitle,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SetStickerSetTitle.ReturnType) {
        return self.call(methods.SetStickerSetTitle, params, err_out);
    }

    pub fn setUserEmojiStatus(
        self: *const BotClient,
        params: methods.SetUserEmojiStatus,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SetUserEmojiStatus.ReturnType) {
        return self.call(methods.SetUserEmojiStatus, params, err_out);
    }

    pub fn setWebhook(
        self: *const BotClient,
        params: methods.SetWebhook,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.SetWebhook.ReturnType) {
        return self.call(methods.SetWebhook, params, err_out);
    }

    pub fn stopMessageLiveLocation(
        self: *const BotClient,
        params: methods.StopMessageLiveLocation,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.StopMessageLiveLocation.ReturnType) {
        return self.call(methods.StopMessageLiveLocation, params, err_out);
    }

    pub fn stopPoll(
        self: *const BotClient,
        params: methods.StopPoll,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.StopPoll.ReturnType) {
        return self.call(methods.StopPoll, params, err_out);
    }

    pub fn transferBusinessAccountStars(
        self: *const BotClient,
        params: methods.TransferBusinessAccountStars,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.TransferBusinessAccountStars.ReturnType) {
        return self.call(methods.TransferBusinessAccountStars, params, err_out);
    }

    pub fn transferGift(
        self: *const BotClient,
        params: methods.TransferGift,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.TransferGift.ReturnType) {
        return self.call(methods.TransferGift, params, err_out);
    }

    pub fn unbanChatMember(
        self: *const BotClient,
        params: methods.UnbanChatMember,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.UnbanChatMember.ReturnType) {
        return self.call(methods.UnbanChatMember, params, err_out);
    }

    pub fn unbanChatSenderChat(
        self: *const BotClient,
        params: methods.UnbanChatSenderChat,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.UnbanChatSenderChat.ReturnType) {
        return self.call(methods.UnbanChatSenderChat, params, err_out);
    }

    pub fn unhideGeneralForumTopic(
        self: *const BotClient,
        params: methods.UnhideGeneralForumTopic,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.UnhideGeneralForumTopic.ReturnType) {
        return self.call(methods.UnhideGeneralForumTopic, params, err_out);
    }

    pub fn unpinAllChatMessages(
        self: *const BotClient,
        params: methods.UnpinAllChatMessages,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.UnpinAllChatMessages.ReturnType) {
        return self.call(methods.UnpinAllChatMessages, params, err_out);
    }

    pub fn unpinAllForumTopicMessages(
        self: *const BotClient,
        params: methods.UnpinAllForumTopicMessages,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.UnpinAllForumTopicMessages.ReturnType) {
        return self.call(methods.UnpinAllForumTopicMessages, params, err_out);
    }

    pub fn unpinAllGeneralForumTopicMessages(
        self: *const BotClient,
        params: methods.UnpinAllGeneralForumTopicMessages,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.UnpinAllGeneralForumTopicMessages.ReturnType) {
        return self.call(methods.UnpinAllGeneralForumTopicMessages, params, err_out);
    }

    pub fn unpinChatMessage(
        self: *const BotClient,
        params: methods.UnpinChatMessage,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.UnpinChatMessage.ReturnType) {
        return self.call(methods.UnpinChatMessage, params, err_out);
    }

    pub fn upgradeGift(
        self: *const BotClient,
        params: methods.UpgradeGift,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.UpgradeGift.ReturnType) {
        return self.call(methods.UpgradeGift, params, err_out);
    }

    pub fn uploadStickerFile(
        self: *const BotClient,
        params: methods.UploadStickerFile,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.UploadStickerFile.ReturnType) {
        return self.call(methods.UploadStickerFile, params, err_out);
    }

    pub fn verifyChat(
        self: *const BotClient,
        params: methods.VerifyChat,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.VerifyChat.ReturnType) {
        return self.call(methods.VerifyChat, params, err_out);
    }

    pub fn verifyUser(
        self: *const BotClient,
        params: methods.VerifyUser,
        err_out: ?*?ErrorDetail,
    ) TelegramError!std.json.Parsed(methods.VerifyUser.ReturnType) {
        return self.call(methods.VerifyUser, params, err_out);
    }
};
