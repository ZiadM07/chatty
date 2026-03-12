import 'package:Chatty/features/chats/data/models/chat_model.dart';

import '../../../auth/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/framework/failure.dart';

abstract class UsersDataSource {
  Future<List<UserModel>> getUsers({
    required String currentUid,
    int limit = 20,
    Object? lastDocument,
  });

  Future<List<UserModel>> searchUsers({
    required String query,
    required String currentUid,
    int limit = 20,
  });

  Future<UserModel?> getUserById({required String uid});

  Stream<UserModel?> watchUser({required String uid});

  Future<List<ChatModel>> getCommonGroups({
    required String currentUid,
    required String otherUid,
  });
}

@LazySingleton(as: UsersDataSource)
class UsersDataSourceImpl implements UsersDataSource {
  final FirebaseFirestore _firestore;

  const UsersDataSourceImpl(this._firestore);

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _chats =>
      _firestore.collection('chats');

  @override
  Future<List<UserModel>> getUsers({
    required String currentUid,
    int limit = 20,
    Object? lastDocument,
  }) async {
    try {
      var query = _users
          .where('uid', isNotEqualTo: currentUid)
          .orderBy('uid')
          .orderBy('username')
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument as DocumentSnapshot);
      }

      final snap = await query.get();

      return snap.docs
          .map((d) => UserModel.fromFirestore(d.data(), d.id))
          .toList();
    } on FirebaseException catch (e) {
      throw Failure(500, e.message ?? 'Failed to fetch users.');
    }
  }

  @override
  Future<List<UserModel>> searchUsers({
    required String query,
    required String currentUid,
    int limit = 20,
  }) async {
    if (query.trim().isEmpty) return [];

    try {
      final normalised = query.trim().toLowerCase();
      final end =
          normalised.substring(0, normalised.length - 1) +
          String.fromCharCode(normalised.codeUnitAt(normalised.length - 1) + 1);

      final byUsername = await _users
          .where('username', isGreaterThanOrEqualTo: normalised)
          .where('username', isLessThan: end)
          .limit(limit)
          .get();

      final byFullName = await _users
          .where('fullName', isGreaterThanOrEqualTo: normalised)
          .where('fullName', isLessThan: end)
          .limit(limit)
          .get();

      final seen = <String>{};
      final results = <UserModel>[];

      for (final doc in [...byUsername.docs, ...byFullName.docs]) {
        if (seen.contains(doc.id) || doc.id == currentUid) continue;
        seen.add(doc.id);
        results.add(UserModel.fromFirestore(doc.data(), doc.id));
      }

      return results;
    } on FirebaseException catch (e) {
      throw Failure(500, e.message ?? 'Failed to search users.');
    }
  }

  @override
  Future<UserModel?> getUserById({required String uid}) async {
    try {
      final doc = await _users.doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromFirestore(doc.data()!, doc.id);
    } on FirebaseException catch (e) {
      throw Failure(500, e.message ?? 'Failed to fetch user.');
    }
  }

  @override
  Stream<UserModel?> watchUser({required String uid}) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromFirestore(doc.data()!, uid);
    });
  }

  @override
  Future<List<ChatModel>> getCommonGroups({
    required String currentUid,
    required String otherUid,
  }) async {
    try {
      final snap = await _chats
          .where('type', isEqualTo: 'group')
          .where('memberIds', arrayContains: currentUid)
          .get();

      if (snap.docs.isEmpty) return [];

      final commonGroups = snap.docs
          .where((doc) {
            final data = doc.data();
            final members = List<String>.from(data['memberIds'] ?? []);
            return members.contains(otherUid);
          })
          .map((doc) {
            return ChatModel.fromFirestore(doc.data(), doc.id);
          })
          .toList();

      return commonGroups;
    } on FirebaseException catch (e) {
      throw Failure(500, e.message ?? 'Failed to fetch common groups.');
    }
  }
}


