import '../../../auth/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

abstract class UsersDataSource {
  /// Fetch a paginated list of users excluding [currentUid].
  /// [lastDocument] is used for cursor-based pagination.
  Future<List<UserModel>> getUsers({
    required String currentUid,
    int limit = 20,
    Object? lastDocument, // DocumentSnapshot for Firestore cursor
  });

  /// Search users by [query] matching username or fullName.
  Future<List<UserModel>> searchUsers({
    required String query,
    required String currentUid,
    int limit = 20,
  });

  /// Fetch a single user by [uid].
  Future<UserModel?> getUserById({required String uid});

  /// Real-time stream of a single user — used in user info screen
  /// to reflect online status changes live.
  Stream<UserModel?> watchUser({required String uid});
}

@LazySingleton(as: UsersDataSource)
class UsersDataSourceImpl implements UsersDataSource {
  final FirebaseFirestore _firestore;

  const UsersDataSourceImpl(this._firestore);

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  // ─── Get Users (paginated) ────────────────────────────────────────────────

  @override
  Future<List<UserModel>> getUsers({
    required String currentUid,
    int limit = 20,
    Object? lastDocument,
  }) async {
    try {
      var query = _users
          .where('uid', isNotEqualTo: currentUid)
          .orderBy('uid') // required when using isNotEqualTo
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
      throw UsersException(e.message ?? 'Failed to fetch users.');
    }
  }

  // ─── Search Users ─────────────────────────────────────────────────────────
  //
  //  Firestore doesn't support full-text search natively.
  //  We use >= / <= range queries on username for prefix matching,
  //  then do a second query on fullName and merge client-side.
  // ─────────────────────────────────────────────────────────────────────────

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

      // Search by username prefix
      final byUsername = await _users
          .where('username', isGreaterThanOrEqualTo: normalised)
          .where('username', isLessThan: end)
          .limit(limit)
          .get();

      // Search by fullName prefix
      final byFullName = await _users
          .where('fullName', isGreaterThanOrEqualTo: normalised)
          .where('fullName', isLessThan: end)
          .limit(limit)
          .get();

      // Merge + deduplicate + exclude current user
      final seen = <String>{};
      final results = <UserModel>[];

      for (final doc in [...byUsername.docs, ...byFullName.docs]) {
        if (seen.contains(doc.id) || doc.id == currentUid) continue;
        seen.add(doc.id);
        results.add(UserModel.fromFirestore(doc.data(), doc.id));
      }

      return results;
    } on FirebaseException catch (e) {
      throw UsersException(e.message ?? 'Failed to search users.');
    }
  }

  // ─── Get User By ID ───────────────────────────────────────────────────────

  @override
  Future<UserModel?> getUserById({required String uid}) async {
    try {
      final doc = await _users.doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromFirestore(doc.data()!, doc.id);
    } on FirebaseException catch (e) {
      throw UsersException(e.message ?? 'Failed to fetch user.');
    }
  }

  // ─── Watch User ───────────────────────────────────────────────────────────

  @override
  Stream<UserModel?> watchUser({required String uid}) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromFirestore(doc.data()!, uid);
    });
  }
}

// ─── Exception ────────────────────────────────────────────────────────────────

class UsersException implements Exception {
  final String message;
  const UsersException(this.message);
  @override
  String toString() => 'UsersException: $message';
}
