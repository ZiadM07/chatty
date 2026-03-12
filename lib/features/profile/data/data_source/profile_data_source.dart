import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/exports.dart';
import '../../../../core/framework/failure.dart';
import '../../../auth/data/models/user_model.dart';

abstract class ProfileDataSource {
  Future<UserModel?> getProfile({required String uid});
  Future<void> updateProfileFullName({
    required String uid,
    required String fullName,
  });
  Future<void> updateProfileBio({required String uid, required String bio});
  Future<void> updateProfilePhoto({
    required String uid,
    required String photoUrl,
  });
  Stream<UserModel?> watchProfile({required String uid});
}

@LazySingleton(as: ProfileDataSource)
class ProfileDataSourceImpl implements ProfileDataSource {
  final FirebaseFirestore _firestore;
  const ProfileDataSourceImpl(this._firestore);

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  @override
  Future<UserModel?> getProfile({required String uid}) async {
    try {
      final doc = await _userDoc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromFirestore(doc.data()!, uid);
    } on FirebaseException catch (e) {
      throw Failure(500, e.message ?? 'Failed to fetch profile.');
    }
  }

  @override
  Future<void> updateProfileFullName({
    required String uid,
    required String fullName,
  }) async {
    try {
      await _userDoc(uid).update({'fullName': fullName});
    } on FirebaseException catch (e) {
      throw Failure(500, e.message ?? 'Failed to update FullName.');
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
      throw Failure(500, e.message ?? 'Failed to update bio.');
    }
  }

  @override
  Future<void> updateProfilePhoto({
    required String uid,
    required String photoUrl,
  }) async {
    try {
      await _userDoc(uid).update({'photoUrl': photoUrl});
    } on FirebaseException catch (e) {
      throw Failure(500, e.message ?? 'Failed to update photo.');
    }
  }

  @override
  Stream<UserModel?> watchProfile({required String uid}) {
    return _userDoc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromFirestore(doc.data()!, uid);
    });
  }
}


