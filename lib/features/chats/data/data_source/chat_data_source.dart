import 'package:chatty/core/utils/enums.dart';
import 'package:chatty/features/chats/data/models/chat_model.dart';
import 'package:chatty/features/chats/data/models/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

abstract class ChatDataSource {
  // ─── Conversations ────────────────────────────────────────────────────────

  /// Real-time stream of all chats the user is a member of, sorted by lastMessageAt desc.
  Stream<List<ChatModel>> watchChats({required String uid});

  /// Fetch a single chat document once.
  Future<ChatModel?> getChat({required String chatId});

  /// Find an existing 1-to-1 chat between [uid] and [otherUid]. Returns null if none.
  Future<ChatModel?> findOneToOneChat({
    required String uid,
    required String otherUid,
  });

  /// Create a new 1-to-1 chat. Caller should call [findOneToOneChat] first.
  Future<ChatModel> createOneToOneChat({
    required String uid,
    required String otherUid,
  });

  /// Create a new group chat.
  Future<ChatModel> createGroupChat({
    required String createdBy,
    required List<String> memberIds,
    required String groupName,
    String? groupPhotoUrl,
  });

  /// Delete a chat and all its messages.
  Future<void> deleteChat({required String chatId});

  // ─── Messages ─────────────────────────────────────────────────────────────

  /// Real-time stream of messages for [chatId], sorted by createdAt asc.
  Stream<List<MessageModel>> watchMessages({required String chatId});

  /// Send a message. Atomically writes the message + updates chat preview + increments unread counts.
  Future<MessageModel> sendMessage({
    required String chatId,
    required String senderId,
    required List<String> memberIds,
    required String content,
    MessageType type,
    String? replyToId,
    String? replyToContent,
    String? replyToSenderId,
  });

  /// Reset unreadCounts[uid] to 0 when the user opens a chat.
  Future<void> markChatAsRead({required String chatId, required String uid});

  /// Mark a message as delivered.
  Future<void> markMessageAsDelivered({
    required String chatId,
    required String uid,
  });

  /// Soft delete — sets isDeleted = true and clears content.
  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
  });

  // ─── Group Management ─────────────────────────────────────────────────────

  Future<void> addGroupMembers({
    required String chatId,
    required List<String> newMemberIds,
  });

  Future<void> removeGroupMember({
    required String chatId,
    required String memberId,
  });

  Future<void> updateGroupInfo({
    required String chatId,
    String? groupName,
    String? groupPhotoUrl,
  });
}

@LazySingleton(as: ChatDataSource)
class ChatDataSourceImpl implements ChatDataSource {
  final FirebaseFirestore _firestore;

  const ChatDataSourceImpl(this._firestore);

  // ─── Refs ─────────────────────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _chats =>
      _firestore.collection('chats');

  CollectionReference<Map<String, dynamic>> _messages(String chatId) =>
      _chats.doc(chatId).collection('messages');

  // ─── Watch Chats ──────────────────────────────────────────────────────────

  @override
  Stream<List<ChatModel>> watchChats({required String uid}) {
    return _chats.where('memberIds', arrayContains: uid).snapshots().map((s) {
      final chats = s.docs
          .map((d) => ChatModel.fromFirestore(d.data(), d.id))
          .toList();

      // Sort client-side so null lastMessageAt (new chats) don't crash the query
      chats.sort((a, b) {
        final aTime = a.lastMessageAt ?? a.createdAt;
        final bTime = b.lastMessageAt ?? b.createdAt;
        return bTime.compareTo(aTime); // descending
      });

      return chats;
    });
  }

  // ─── Get Chat ─────────────────────────────────────────────────────────────

  @override
  Future<ChatModel?> getChat({required String chatId}) async {
    try {
      final doc = await _chats.doc(chatId).get();
      if (!doc.exists || doc.data() == null) return null;
      return ChatModel.fromFirestore(doc.data()!, doc.id);
    } on FirebaseException catch (e) {
      throw ChatException(e.message ?? 'Failed to get chat.');
    }
  }

  // ─── Find One-to-One ──────────────────────────────────────────────────────

  @override
  Future<ChatModel?> findOneToOneChat({
    required String uid,
    required String otherUid,
  }) async {
    try {
      final snap = await _chats
          .where('type', isEqualTo: ChatType.oneToOne.name)
          .where('memberIds', arrayContains: uid)
          .get();

      final match = snap.docs
          .map((d) => ChatModel.fromFirestore(d.data(), d.id))
          .where((c) => c.memberIds.contains(otherUid))
          .toList();

      return match.isEmpty ? null : match.first;
    } on FirebaseException catch (e) {
      throw ChatException(e.message ?? 'Failed to find chat.');
    }
  }

  // ─── Create One-to-One ────────────────────────────────────────────────────

  @override
  Future<ChatModel> createOneToOneChat({
    required String uid,
    required String otherUid,
  }) async {
    try {
      final doc = _chats.doc();
      final chat = ChatModel(
        id: doc.id,
        type: ChatType.oneToOne,
        memberIds: [uid, otherUid],
        unreadCounts: {uid: 0, otherUid: 0},
        createdAt: DateTime.now(),
      );
      await doc.set(chat.toFirestore());
      return chat;
    } on FirebaseException catch (e) {
      throw ChatException(e.message ?? 'Failed to create chat.');
    }
  }

  // ─── Create Group ─────────────────────────────────────────────────────────

  @override
  Future<ChatModel> createGroupChat({
    required String createdBy,
    required List<String> memberIds,
    required String groupName,
    String? groupPhotoUrl,
  }) async {
    try {
      final doc = _chats.doc();
      final allMembers = {...memberIds, createdBy}.toList();
      final chat = ChatModel(
        id: doc.id,
        type: ChatType.group,
        memberIds: allMembers,
        groupName: groupName,
        groupPhotoUrl: groupPhotoUrl,
        groupCreatedBy: createdBy,
        unreadCounts: {for (final id in allMembers) id: 0},
        createdAt: DateTime.now(),
      );
      await doc.set(chat.toFirestore());
      return chat;
    } on FirebaseException catch (e) {
      throw ChatException(e.message ?? 'Failed to create group.');
    }
  }

  // ─── Delete Chat ──────────────────────────────────────────────────────────

  @override
  Future<void> deleteChat({required String chatId}) async {
    try {
      await _deleteSubCollection(_messages(chatId));
      await _chats.doc(chatId).delete();
    } on FirebaseException catch (e) {
      throw ChatException(e.message ?? 'Failed to delete chat.');
    }
  }

  // ─── Watch Messages ───────────────────────────────────────────────────────

  @override
  Stream<List<MessageModel>> watchMessages({required String chatId}) {
    return _messages(chatId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (s) => s.docs
              .map((d) => MessageModel.fromFirestore(d.data(), d.id, chatId))
              .toList(),
        );
  }

  // ─── Send Message ─────────────────────────────────────────────────────────

  @override
  Future<MessageModel> sendMessage({
    required String chatId,
    required String senderId,
    required List<String> memberIds,
    required String content,
    MessageType type = MessageType.text,
    String? replyToId,
    String? replyToContent,
    String? replyToSenderId,
  }) async {
    try {
      final msgRef = _messages(chatId).doc();
      final now = DateTime.now();

      final message = MessageModel(
        id: msgRef.id,
        chatId: chatId,
        senderId: senderId,
        content: content,
        type: type,
        status: MessageStatus.sent,
        createdAt: now,
        replyToId: replyToId,
        replyToContent: replyToContent,
        replyToSenderId: replyToSenderId,
      );

      // Increment unread for everyone except sender
      final unreadIncrements = {
        for (final uid in memberIds.where((id) => id != senderId))
          'unreadCounts.$uid': FieldValue.increment(1),
      };

      // Atomic: write message + update chat preview in one batch
      final batch = _firestore.batch();
      batch.set(msgRef, message.toFirestore());
      batch.update(_chats.doc(chatId), {
        'lastMessage': type == MessageType.text ? content : _mediaLabel(type),
        'lastMessageType': type.name,
        'lastMessageSenderId': senderId,
        'lastMessageAt': Timestamp.fromDate(now),
        ...unreadIncrements,
      });
      await batch.commit();

      return message;
    } on FirebaseException catch (e) {
      throw ChatException(e.message ?? 'Failed to send message.');
    }
  }

  // ─── Mark As Read ─────────────────────────────────────────────────────────

  @override
  Future<void> markChatAsRead({
    required String chatId,
    required String uid,
  }) async {
    try {
      // 1. Reset unread counter
      // 2. Bulk-update all sent/delivered messages from others → read
      //    We do this in a batch so it's one round-trip.

      final unreadSnap = await _messages(chatId)
          .where('senderId', isNotEqualTo: uid)
          .where('isDeleted', isEqualTo: false)
          .get();

      final toUpdate = unreadSnap.docs.where((doc) {
        final s = doc.data()['status'] as String?;
        return s == 'sent' || s == 'delivered';
      }).toList();

      // Firestore batch limit is 500 — chunk if needed
      const chunkSize = 400;
      for (var i = 0; i < toUpdate.length; i += chunkSize) {
        final chunk = toUpdate.skip(i).take(chunkSize);
        final batch = _firestore.batch();
        for (final doc in chunk) {
          batch.update(doc.reference, {'status': MessageStatus.read.name});
        }
        batch.update(_chats.doc(chatId), {'unreadCounts.$uid': 0});
        await batch.commit();
      }

      // If no messages to update, still reset the counter
      if (toUpdate.isEmpty) {
        await _chats.doc(chatId).update({'unreadCounts.$uid': 0});
      }
    } on FirebaseException catch (e) {
      throw ChatException(e.message ?? 'Failed to mark as read.');
    }
  }

  // ─── Mark Delivered ──────────────────────────────────────────────────────
  //
  //  Called when the recipient's device receives messages but they haven't
  //  opened the chat yet. Upgrades all `sent` messages from others → `delivered`.
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<void> markMessageAsDelivered({
    required String chatId,
    required String uid,
  }) async {
    try {
      final snap = await _messages(chatId)
          .where('senderId', isNotEqualTo: uid)
          .where('status', isEqualTo: MessageStatus.sent.name)
          .where('isDeleted', isEqualTo: false)
          .get();

      if (snap.docs.isEmpty) return;

      const chunkSize = 400;
      final docs = snap.docs;
      for (var i = 0; i < docs.length; i += chunkSize) {
        final batch = _firestore.batch();
        for (final doc in docs.skip(i).take(chunkSize)) {
          batch.update(doc.reference, {'status': MessageStatus.delivered.name});
        }
        await batch.commit();
      }
    } on FirebaseException catch (e) {
      throw ChatException(e.message ?? 'Failed to mark delivered.');
    }
  }

  // ─── Delete Message ───────────────────────────────────────────────────────

  @override
  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
  }) async {
    try {
      await _messages(
        chatId,
      ).doc(messageId).update({'isDeleted': true, 'content': ''});
    } on FirebaseException catch (e) {
      throw ChatException(e.message ?? 'Failed to delete message.');
    }
  }

  // ─── Group Management ─────────────────────────────────────────────────────

  @override
  Future<void> addGroupMembers({
    required String chatId,
    required List<String> newMemberIds,
  }) async {
    try {
      await _chats.doc(chatId).update({
        'memberIds': FieldValue.arrayUnion(newMemberIds),
        for (final uid in newMemberIds) 'unreadCounts.$uid': 0,
      });
    } on FirebaseException catch (e) {
      throw ChatException(e.message ?? 'Failed to add members.');
    }
  }

  @override
  Future<void> removeGroupMember({
    required String chatId,
    required String memberId,
  }) async {
    try {
      await _chats.doc(chatId).update({
        'memberIds': FieldValue.arrayRemove([memberId]),
        'unreadCounts.$memberId': FieldValue.delete(),
      });
    } on FirebaseException catch (e) {
      throw ChatException(e.message ?? 'Failed to remove member.');
    }
  }

  @override
  Future<void> updateGroupInfo({
    required String chatId,
    String? groupName,
    String? groupPhotoUrl,
  }) async {
    try {
      final data = <String, dynamic>{
        'groupName': ?groupName,
        'groupPhotoUrl': ?groupPhotoUrl,
      };
      if (data.isEmpty) return;
      await _chats.doc(chatId).update(data);
    } on FirebaseException catch (e) {
      throw ChatException(e.message ?? 'Failed to update group.');
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String _mediaLabel(MessageType type) {
    return switch (type) {
      MessageType.image => '📷 Photo',
      MessageType.audio => '🎵 Audio',
      MessageType.video => '🎥 Video',
      MessageType.file => '📎 File',
      _ => '',
    };
  }

  Future<void> _deleteSubCollection(
    CollectionReference<Map<String, dynamic>> ref,
  ) async {
    const batchSize = 100;
    while (true) {
      final snap = await ref.limit(batchSize).get();
      if (snap.docs.isEmpty) break;
      final batch = _firestore.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }
}

// ─── Exception ────────────────────────────────────────────────────────────────

class ChatException implements Exception {
  final String message;
  const ChatException(this.message);
  @override
  String toString() => 'ChatException: $message';
}
