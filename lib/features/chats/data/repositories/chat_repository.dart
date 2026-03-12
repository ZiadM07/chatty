import 'dart:io';
import 'package:Chatty/core/utils/enums.dart';
import 'package:Chatty/features/chats/data/data_source/chat_data_source.dart';
import 'package:Chatty/features/chats/data/models/chat_model.dart';
import 'package:Chatty/features/chats/data/models/message_model.dart';
import 'package:injectable/injectable.dart';
import '../../../shared/data/data_sources/storage_data_source.dart';

class _StoragePaths {
  static String chatMedia(String chatId) => 'chat_media/$chatId';
}

@lazySingleton
class ChatRepository {
  final ChatDataSource _dataSource;
  final StorageDataSource _storageDataSource;

  const ChatRepository(this._dataSource, this._storageDataSource);

  Stream<List<ChatModel>> watchChats({required String uid}) =>
      _dataSource.watchChats(uid: uid);

  Stream<ChatModel?> watchChat({required String chatId}) =>
      _dataSource.watchChat(chatId: chatId);

  Future<ChatModel?> getChat({required String chatId}) =>
      _dataSource.getChat(chatId: chatId);

  Future<ChatModel> openOrCreateOneToOneChat({
    required String uid,
    required String otherUid,
    required String uidName,
    required String otherUidName,
  }) async {
    final existing = await _dataSource.findOneToOneChat(
      uid: uid,
      otherUid: otherUid,
    );
    return existing ??
        await _dataSource.createOneToOneChat(
          uid: uid,
          otherUid: otherUid,
          uidName: uidName,
          otherUidName: otherUidName,
        );
  }

  Future<ChatModel> createGroupChat({
    required String createdBy,
    required List<String> memberIds,
    required Map<String, String> memberNames,
    required String groupName,
    String? groupDescription,
    File? groupPhotoFile,
  }) async {
    String? groupPhotoUrl;
    if (groupPhotoFile != null) {
      groupPhotoUrl = await _storageDataSource.uploadFile(
        file: groupPhotoFile,
        path: 'group_photos/temp',
      );
    }
    return _dataSource.createGroupChat(
      createdBy: createdBy,
      memberIds: memberIds,
      memberNames: memberNames,
      groupName: groupName,
      groupDescription: groupDescription,
      groupPhotoUrl: groupPhotoUrl,
    );
  }

  Future<void> deleteChat({required String chatId}) =>
      _dataSource.deleteChat(chatId: chatId);

  Stream<List<MessageModel>> watchMessages({required String chatId}) =>
      _dataSource.watchMessages(chatId: chatId);

  Future<MessageModel> sendTextMessage({
    required String chatId,
    required String senderId,
    required List<String> memberIds,
    required String content,
    String? replyToId,
    String? replyToContent,
    String? replyToSenderId,
    MessageType? replyToType,
  }) => _dataSource.sendMessage(
    chatId: chatId,
    senderId: senderId,
    memberIds: memberIds,
    content: content,
    type: MessageType.text,
    replyToId: replyToId,
    replyToContent: replyToContent,
    replyToSenderId: replyToSenderId,
    replyToType: replyToType,
  );

  Future<void> reactToMessage({
    required String chatId,
    required String messageId,
    required String uid,
    required String? reaction,
  }) => _dataSource.reactToMessage(
    chatId: chatId,
    messageId: messageId,
    uid: uid,
    reaction: reaction,
  );

  Future<MessageModel> sendMediaMessage({
    required String chatId,
    required String senderId,
    required List<String> memberIds,
    required File file,
    required MessageType type,
    Map<String, dynamic>? metadata,
    String? replyToId,
    String? replyToContent,
    String? replyToSenderId,
    MessageType? replyToType,
  }) async {
    final url = await _storageDataSource.uploadFile(
      file: file,
      path: _StoragePaths.chatMedia(chatId),
    );

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
      replyToType: replyToType,
    );
  }

  Future<void> markMessagesDelivered({
    required String chatId,
    required String uid,
  }) => _dataSource.markMessagesDelivered(chatId: chatId, uid: uid);

  Future<void> markChatAsRead({required String chatId, required String uid}) =>
      _dataSource.markChatAsRead(chatId: chatId, uid: uid);

  Future<void> markMessagesSeenBy({
    required String chatId,
    required String uid,
  }) => _dataSource.markMessagesSeenBy(chatId: chatId, uid: uid);

  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
  }) => _dataSource.deleteMessage(chatId: chatId, messageId: messageId);

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

  Future<void> addGroupMembers({
    required String chatId,
    required List<String> newMemberIds,
    required Map<String, String> newMemberNames,
  }) => _dataSource.addGroupMembers(
    chatId: chatId,
    newMemberIds: newMemberIds,
    newMemberNames: newMemberNames,
  );
  Future<void> removeGroupMember({
    required String chatId,
    required String memberId,
  }) => _dataSource.removeGroupMember(chatId: chatId, memberId: memberId);

  Future<void> updateGroupInfo({
    required String chatId,
    String? groupName,
    String? groupDescription,
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
      groupDescription: groupDescription,
      groupPhotoUrl: newPhotoUrl,
    );
  }

  Future<void> patchMemberNames({
    required String chatId,
    required Map<String, String> memberNames,
  }) => _dataSource.patchMemberNames(chatId: chatId, memberNames: memberNames);

  Future<void> leaveGroup({required String chatId, required String uid}) =>
      _dataSource.leaveGroup(chatId: chatId, uid: uid);

  Future<void> transferOwnershipAndLeave({
    required String chatId,
    required String newOwnerUid,
    required String currentOwnerUid,
  }) => _dataSource.transferOwnershipAndLeave(
    chatId: chatId,
    newOwnerUid: newOwnerUid,
    currentOwnerUid: currentOwnerUid,
  );
}
