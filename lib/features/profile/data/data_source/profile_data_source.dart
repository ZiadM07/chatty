import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/exports.dart';
import '../../../auth/data/models/user_model.dart';

abstract class ProfileDataSource {
  /// Fetches the full [UserModel] from Firestore by [uid].
  Future<UserModel?> getProfile({required String uid});

  /// Updates only the [fullName] field in Firestore.
  Future<void> updateProfileFullName({
    required String uid,
    required String fullName,
  });

  /// Updates only the [bio] field in Firestore.
  Future<void> updateProfileBio({required String uid, required String bio});

  /// Updates only the [photoUrl] field in Firestore.
  Future<void> updateProfilePhoto({
    required String uid,
    required String photoUrl,
  });

  /// Stream of real-time profile changes from Firestore.
  Stream<UserModel?> watchProfile({required String uid});
}

@LazySingleton(as: ProfileDataSource)
class ProfileDataSourceImpl implements ProfileDataSource {
  final FirebaseFirestore _firestore;

  const ProfileDataSourceImpl(this._firestore);

  // ─── Collection ref ───────────────────────────────────────────────────────

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  // ─── Get Profile ──────────────────────────────────────────────────────────

  @override
  Future<UserModel?> getProfile({required String uid}) async {
    try {
      final doc = await _userDoc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromFirestore(doc.data()!, uid);
    } on FirebaseException catch (e) {
      throw ProfileException(e.message ?? 'Failed to fetch profile.');
    }
  }

  // ─── Update Info ──────────────────────────────────────────────────────────

  @override
  Future<void> updateProfileFullName({
    required String uid,
    required String fullName,
  }) async {
    try {
      await _userDoc(uid).update({'fullName': fullName});
    } on FirebaseException catch (e) {
      throw ProfileException(e.message ?? 'Failed to update FullName.');
    }
  }

  @override
  Future<void> updateProfileBio({
    required String uid,
    required String bio,
  }) async {
    try {
      await _userDoc(uid).update({'bio': bio});
    } on FirebaseException catch (e) {
      throw ProfileException(e.message ?? 'Failed to update bio.');
    }
  }

  // ─── Update Photo ─────────────────────────────────────────────────────────

  @override
  Future<void> updateProfilePhoto({
    required String uid,
    required String photoUrl,
  }) async {
    try {
      await _userDoc(uid).update({'photoUrl': photoUrl});
    } on FirebaseException catch (e) {
      throw ProfileException(e.message ?? 'Failed to update photo.');
    }
  }

  // ─── Watch Profile ────────────────────────────────────────────────────────

  @override
  Stream<UserModel?> watchProfile({required String uid}) {
    return _userDoc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromFirestore(doc.data()!, uid);
    });
  }
}

// ─── Exception ────────────────────────────────────────────────────────────────

class ProfileException implements Exception {
  final String message;
  const ProfileException(this.message);

  @override
  String toString() => 'ProfileException: $message';
}
