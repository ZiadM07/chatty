import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:chatty/core/utils/enums.dart';
import 'package:chatty/features/chats/data/data_source/chat_data_source.dart';
import 'package:chatty/features/chats/data/models/chat_model.dart';
import 'package:chatty/features/chats/data/models/message_model.dart';
import 'package:injectable/injectable.dart';
import '../../../shared/data/storage_data_source.dart';

class _StoragePaths {
  static String chatMedia(String chatId) => 'chat_media/$chatId';
}

@lazySingleton
class ChatRepository {
  final ChatDataSource _dataSource;
  final StorageDataSource _storageDataSource;

  const ChatRepository(this._dataSource, this._storageDataSource);

  // ─── Conversations ────────────────────────────────────────────────────────

  Stream<List<ChatModel>> watchChats({required String uid}) =>
      _dataSource.watchChats(uid: uid);

  Future<ChatModel?> getChat({required String chatId}) =>
      _dataSource.getChat(chatId: chatId);

  /// Opens a 1-to-1 chat — creates it if it doesn't exist yet.
  Future<ChatModel> openOrCreateOneToOneChat({
    required String uid,
    required String otherUid,
  }) async {
    final existing = await _dataSource.findOneToOneChat(
      uid: uid,
      otherUid: otherUid,
    );
    return existing ??
        await _dataSource.createOneToOneChat(uid: uid, otherUid: otherUid);
  }

  Future<ChatModel> createGroupChat({
    required String createdBy,
    required List<String> memberIds,
    required String groupName,
    File? groupPhotoFile,
  }) async {
    String? groupPhotoUrl;

    if (groupPhotoFile != null) {
      // Use a temp path before we have the chatId — we'll update after creation
      groupPhotoUrl = await _storageDataSource.uploadFile(
        file: groupPhotoFile,
        path: 'group_photos/temp',
      );
    }

    return _dataSource.createGroupChat(
      createdBy: createdBy,
      memberIds: memberIds,
      groupName: groupName,
      groupPhotoUrl: groupPhotoUrl,
    );
  }

  Future<void> deleteChat({required String chatId}) =>
      _dataSource.deleteChat(chatId: chatId);

  // ─── Messages ─────────────────────────────────────────────────────────────

  Stream<List<MessageModel>> watchMessages({required String chatId}) =>
      _dataSource.watchMessages(chatId: chatId);

  /// Send a text message.
  Future<MessageModel> sendTextMessage({
    required String chatId,
    required String senderId,
    required List<String> memberIds,
    required String content,
    String? replyToId,
    String? replyToContent,
    String? replyToSenderId,
  }) => _dataSource.sendMessage(
    chatId: chatId,
    senderId: senderId,
    memberIds: memberIds,
    content: content,
    type: MessageType.text,
    replyToId: replyToId,
    replyToContent: replyToContent,
    replyToSenderId: replyToSenderId,
  );

  /// Upload media to Supabase then send as a message.
  Future<MessageModel> sendMediaMessage({
    required String chatId,
    required String senderId,
    required List<String> memberIds,
    required File file,
    required MessageType type,
    String? replyToId,
    String? replyToContent,
    String? replyToSenderId,
  }) async {
    final url = await _storageDataSource.uploadFile(
      file: file,
      path: _StoragePaths.chatMedia(chatId),
    );

    // Extract audio duration if this is an audio message
    Map<String, dynamic>? metadata;
    if (type == MessageType.audio) {
      final player = AudioPlayer();
      try {
        await player.setSourceDeviceFile(file.path);
        final duration = await player.getDuration();
        if (duration != null) {
          metadata = {'duration': duration.inMilliseconds};
        }
      } catch (_) {
        // If duration extraction fails, send without metadata
      } finally {
        await player.dispose();
      }
    }

    return _dataSource.sendMessage(
      chatId: chatId,
      senderId: senderId,
      memberIds: memberIds,
      content: url,
      type: type,
      metadata: metadata,
      replyToId: replyToId,
      replyToContent: replyToContent,
      replyToSenderId: replyToSenderId,
    );
  }

  Future<void> markMessagesDelivered({
    required String chatId,
    required String uid,
  }) => _dataSource.markMessagesDelivered(chatId: chatId, uid: uid);

  Future<void> markChatAsRead({required String chatId, required String uid}) =>
      _dataSource.markChatAsRead(chatId: chatId, uid: uid);

  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
  }) => _dataSource.deleteMessage(chatId: chatId, messageId: messageId);

  // ─── Media Messages ───────────────────────────────────────────────────────

  Future<List<MessageModel>> getMediaMessages({
    required String chatId,
    MessageType? type,
    int limit = 30,
    String? lastMessageId,
  }) => _dataSource.getMediaMessages(
    chatId: chatId,
    type: type,
    limit: limit,
    lastMessageId: lastMessageId,
  );

  // ─── Group Management ─────────────────────────────────────────────────────

  Future<void> addGroupMembers({
    required String chatId,
    required List<String> newMemberIds,
  }) => _dataSource.addGroupMembers(chatId: chatId, newMemberIds: newMemberIds);

  Future<void> removeGroupMember({
    required String chatId,
    required String memberId,
  }) => _dataSource.removeGroupMember(chatId: chatId, memberId: memberId);

  Future<void> updateGroupInfo({
    required String chatId,
    String? groupName,
    File? groupPhotoFile,
    String? oldGroupPhotoUrl,
  }) async {
    String? newPhotoUrl;

    if (groupPhotoFile != null) {
      if (oldGroupPhotoUrl != null && oldGroupPhotoUrl.isNotEmpty) {
        try {
          await _storageDataSource.deleteFile(path: oldGroupPhotoUrl);
        } catch (_) {}
      }
      newPhotoUrl = await _storageDataSource.uploadFile(
        file: groupPhotoFile,
        path: 'group_photos/$chatId',
      );
    }

    await _dataSource.updateGroupInfo(
      chatId: chatId,
      groupName: groupName,
      groupPhotoUrl: newPhotoUrl,
    );
  }
}
