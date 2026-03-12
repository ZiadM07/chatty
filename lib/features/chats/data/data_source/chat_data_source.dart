import 'package:Chatty/core/utils/enums.dart';
import 'package:Chatty/features/chats/data/models/chat_model.dart';
import 'package:Chatty/features/chats/data/models/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/framework/failure.dart';

abstract class ChatDataSource {
  Stream<List<ChatModel>> watchChats({required String uid});
  Stream<ChatModel?> watchChat({required String chatId});
  Future<ChatModel?> getChat({required String chatId});
  Future<ChatModel?> findOneToOneChat({
    required String uid,
    required String otherUid,
  });
  Future<ChatModel> createOneToOneChat({
    required String uid,
    required String otherUid,
    required String uidName,
    required String otherUidName,
  });
  Future<ChatModel> createGroupChat({
    required String createdBy,
    required List<String> memberIds,
    required Map<String, String> memberNames,
    required String groupName,
    String? groupDescription,
    String? groupPhotoUrl,
  });
  Future<void> deleteChat({required String chatId});
  Stream<List<MessageModel>> watchMessages({required String chatId});
  Future<MessageModel> sendMessage({
    required String chatId,
    required String senderId,
    required List<String> memberIds,
    required String content,
    MessageType type,
    Map<String, dynamic>? metadata,
    String? replyToId,
    String? replyToContent,
    String? replyToSenderId,
    MessageType? replyToType,
  });
  Future<void> reactToMessage({
    required String chatId,
    required String messageId,
    required String uid,
    required String? reaction,
  });

  Future<void> markMessagesDelivered({
    required String chatId,
    required String uid,
  });
  Future<void> markChatAsRead({required String chatId, required String uid});

  Future<void> markMessagesSeenBy({
    required String chatId,
    required String uid,
  });

  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
  });
  Future<List<MessageModel>> getMediaMessages({
    required String chatId,
    MessageType? type,
    int limit = 30,
    String? lastMessageId,
  });
  Future<void> addGroupMembers({
    required String chatId,
    required List<String> newMemberIds,
    required Map<String, String> newMemberNames,
  });
  Future<void> removeGroupMember({
    required String chatId,
    required String memberId,
  });
  Future<void> updateGroupInfo({
    required String chatId,
    String? groupName,
    String? groupDescription,
    String? groupPhotoUrl,
  });

  Future<void> patchMemberNames({
    required String chatId,
    required Map<String, String> memberNames,
  });

  Future<void> transferOwnershipAndLeave({
    required String chatId,
    required String newOwnerUid,
    required String currentOwnerUid,
  });

  Future<void> leaveGroup({required String chatId, required String uid});
}

@LazySingleton(as: ChatDataSource)
class ChatDataSourceImpl implements ChatDataSource {
  final FirebaseFirestore _firestore;

  const ChatDataSourceImpl(this._firestore);

  CollectionReference<Map<String, dynamic>> get _chats =>
      _firestore.collection('chats');

  CollectionReference<Map<String, dynamic>> _messages(String chatId) =>
      _chats.doc(chatId).collection('messages');

  @override
  Stream<List<ChatModel>> watchChats({required String uid}) {
    return _chats.where('memberIds', arrayContains: uid).snapshots().map((s) {
      final chats = s.docs
          .map((d) => ChatModel.fromFirestore(d.data(), d.id))
          .toList();
      chats.sort((a, b) {
        final aTime = a.lastMessageAt ?? a.createdAt;
        final bTime = b.lastMessageAt ?? b.createdAt;
        return bTime.compareTo(aTime);
      });
      return chats;
    });
  }

  @override
  Stream<ChatModel?> watchChat({required String chatId}) {
    return _chats.doc(chatId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return ChatModel.fromFirestore(snap.data()!, snap.id);
    });
  }

  @override
  Future<ChatModel?> getChat({required String chatId}) async {
    try {
      final doc = await _chats.doc(chatId).get();
      if (!doc.exists || doc.data() == null) return null;
      return ChatModel.fromFirestore(doc.data()!, doc.id);
    } on FirebaseException catch (e) {
      throw Failure(500, e.message ?? 'Failed to get chat.');
    }
  }

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
      throw Failure(500, e.message ?? 'Failed to find chat.');
    }
  }

  @override
  Future<ChatModel> createOneToOneChat({
    required String uid,
    required String otherUid,
    required String uidName,
    required String otherUidName,
  }) async {
    try {
      final doc = _chats.doc();
      final chat = ChatModel(
        id: doc.id,
        type: ChatType.oneToOne,
        memberIds: [uid, otherUid],
        memberNames: {uid: uidName, otherUid: otherUidName},
        unreadCounts: {uid: 0, otherUid: 0},
        createdAt: DateTime.now(),
      );
      await doc.set(chat.toFirestore());
      return chat;
    } on FirebaseException catch (e) {
      throw Failure(500, e.message ?? 'Failed to create chat.');
    }
  }

  @override
  Future<ChatModel> createGroupChat({
    required String createdBy,
    required List<String> memberIds,
    required Map<String, String> memberNames,
    required String groupName,
    String? groupDescription,
    String? groupPhotoUrl,
  }) async {
    try {
      final doc = _chats.doc();
      final allMembers = {...memberIds, createdBy}.toList();
      final chat = ChatModel(
        id: doc.id,
        type: ChatType.group,
        memberIds: allMembers,
        memberNames: memberNames,
        groupName: groupName,
        groupDescription: groupDescription,
        groupPhotoUrl: groupPhotoUrl,
        groupCreatedBy: createdBy,
        unreadCounts: {for (final id in allMembers) id: 0},
        createdAt: DateTime.now(),
      );
      await doc.set(chat.toFirestore());
      return chat;
    } on FirebaseException catch (e) {
      throw Failure(500, e.message ?? 'Failed to create group.');
    }
  }

  @override
  Future<void> deleteChat({required String chatId}) async {
    try {
      await _deleteSubCollection(_messages(chatId));
      await _chats.doc(chatId).delete();
    } on FirebaseException catch (e) {
      throw Failure(500, e.message ?? 'Failed to delete chat.');
    }
  }

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

  @override
  Future<MessageModel> sendMessage({
    required String chatId,
    required String senderId,
    required List<String> memberIds,
    required String content,
    MessageType type = MessageType.text,
    Map<String, dynamic>? metadata,
    String? replyToId,
    String? replyToContent,
    String? replyToSenderId,
    MessageType? replyToType,
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
        metadata: metadata,
        replyToId: replyToId,
        replyToContent: replyToContent,
        replyToSenderId: replyToSenderId,
        replyToType: replyToType,
      );
      final unreadIncrements = {
        for (final uid in memberIds.where((id) => id != senderId))
          'unreadCounts.$uid': FieldValue.increment(1),
      };
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
      throw Failure(500, e.message ?? 'Failed to send message.');
    }
  }

  @override
  Future<void> reactToMessage({
    required String chatId,
    required String messageId,
    required String uid,
    required String? reaction,
  }) async {
    try {
      await _messages(chatId).doc(messageId).update({
        if (reaction != null)
          'reactions.$uid': reaction
        else
          'reactions.$uid': FieldValue.delete(),
      });
    } on FirebaseException catch (e) {
      throw Failure(500, e.message ?? 'Failed to react.');
    }
  }

  @override
  Future<void> markChatAsRead({
    required String chatId,
    required String uid,
  }) async {
    try {
      final unreadSnap = await _messages(chatId)
          .where('senderId', isNotEqualTo: uid)
          .where('isDeleted', isEqualTo: false)
          .get();

      final toUpdate = unreadSnap.docs.where((doc) {
        final s = doc.data()['status'] as String?;
        return s == 'sent' || s == 'delivered';
      }).toList();

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

      if (toUpdate.isEmpty) {
        await _chats.doc(chatId).update({'unreadCounts.$uid': 0});
      }
    } on FirebaseException catch (e) {
      throw Failure(500, e.message ?? 'Failed to mark as read.');
    }
  }

  @override
  Future<void> markMessagesSeenBy({
    required String chatId,
    required String uid,
  }) async {
    try {
      final snap = await _messages(chatId)
          .where('senderId', isNotEqualTo: uid)
          .where('isDeleted', isEqualTo: false)
          .get();

      final unseen = snap.docs.where((doc) {
        final readBy = List<String>.from(doc.data()['readBy'] as List? ?? []);
        return !readBy.contains(uid);
      }).toList();

      if (unseen.isEmpty) return;

      const chunkSize = 400;
      for (var i = 0; i < unseen.length; i += chunkSize) {
        final chunk = unseen.skip(i).take(chunkSize);
        final batch = _firestore.batch();
        for (final doc in chunk) {
          batch.update(doc.reference, {
            'readBy': FieldValue.arrayUnion([uid]),
            'status': MessageStatus.read.name,
          });
        }

        batch.update(_chats.doc(chatId), {'unreadCounts.$uid': 0});
        await batch.commit();
      }
    } on FirebaseException catch (e) {
      throw Failure(500, e.message ?? 'Failed to mark messages as seen.');
    }
  }

  @override
  Future<void> markMessagesDelivered({
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
      throw Failure(500, e.message ?? 'Failed to mark delivered.');
    }
  }

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
      throw Failure(500, e.message ?? 'Failed to delete message.');
    }
  }

  @override
  Future<List<MessageModel>> getMediaMessages({
    required String chatId,
    MessageType? type,
    int limit = 30,
    String? lastMessageId,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _messages(chatId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('createdAt', descending: true);

      if (type != null) {
        query = query.where('type', isEqualTo: type.name);
      } else {
        query = query.where(
          'type',
          whereIn: [
            MessageType.image.name,
            MessageType.video.name,
            MessageType.audio.name,
            MessageType.file.name,
          ],
        );
      }

      if (lastMessageId != null) {
        final lastDoc = await _messages(chatId).doc(lastMessageId).get();
        if (lastDoc.exists) query = query.startAfterDocument(lastDoc);
      }

      final snap = await query.limit(limit).get();
      return snap.docs
          .map((d) => MessageModel.fromFirestore(d.data(), d.id, chatId))
          .toList();
    } on FirebaseException catch (e) {
      throw Failure(500, e.message ?? 'Failed to load media.');
    }
  }

  @override
  Future<void> addGroupMembers({
    required String chatId,
    required List<String> newMemberIds,
    required Map<String, String> newMemberNames,
  }) async {
    try {
      await _chats.doc(chatId).update({
        'memberIds': FieldValue.arrayUnion(newMemberIds),
        for (final uid in newMemberIds) 'unreadCounts.$uid': 0,
        for (final entry in newMemberNames.entries)
          'memberNames.${entry.key}': entry.value,
      });
    } on FirebaseException catch (e) {
      throw Failure(500, e.message ?? 'Failed to add members.');
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
      throw Failure(500, e.message ?? 'Failed to remove member.');
    }
  }

  @override
  Future<void> leaveGroup({required String chatId, required String uid}) async {
    try {
      await _chats.doc(chatId).update({
        'memberIds': FieldValue.arrayRemove([uid]),
        'unreadCounts.$uid': FieldValue.delete(),
      });
    } on FirebaseException catch (e) {
      throw Failure(500, e.message ?? 'Failed to leave group.');
    }
  }

  @override
  Future<void> transferOwnershipAndLeave({
    required String chatId,
    required String newOwnerUid,
    required String currentOwnerUid,
  }) async {
    try {
      await _chats.doc(chatId).update({
        'groupCreatedBy': newOwnerUid,
        'memberIds': FieldValue.arrayRemove([currentOwnerUid]),
        'unreadCounts.$currentOwnerUid': FieldValue.delete(),
      });
    } on FirebaseException catch (e) {
      throw Failure(500, e.message ?? 'Failed to transfer ownership.');
    }
  }

  @override
  Future<void> updateGroupInfo({
    required String chatId,
    String? groupName,
    String? groupPhotoUrl,
    String? groupDescription,
  }) async {
    try {
      final data = <String, dynamic>{
        'groupName': ?groupName,
        'groupPhotoUrl': ?groupPhotoUrl,
        'groupDescription': ?groupDescription,
      };
      if (data.isEmpty) return;
      await _chats.doc(chatId).update(data);
    } on FirebaseException catch (e) {
      throw Failure(500, e.message ?? 'Failed to update group.');
    }
  }

  @override
  Future<void> patchMemberNames({
    required String chatId,
    required Map<String, String> memberNames,
  }) async {
    try {
      await _chats.doc(chatId).update({'memberNames': memberNames});
    } on FirebaseException catch (e) {
      throw Failure(500, e.message ?? 'Failed to patch member names.');
    }
  }

  String _mediaLabel(MessageType type) => switch (type) {
    MessageType.image => '🖼️ Photo',
    MessageType.audio => '🎙️ Voice Message',
    MessageType.video => '🎬 Video',
    MessageType.file => '📄 File',
    _ => '',
  };

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


