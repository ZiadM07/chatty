import 'dart:io';

import 'package:injectable/injectable.dart';

import '../../data/data_sources/auth_data_source.dart';
import '../../../shared/data/storage_data_source.dart';
import '../../data/models/auth_model.dart';
import '../../data/models/user_model.dart';

// ─── Storage Path Helpers ─────────────────────────────────────────────────────

class _StoragePaths {
  /// Folder path passed to uploadFile → 'profiles/<uid>'
  /// uploadFile appends a timestamped filename internally.
  static String profileFolder(String uid) => 'profiles/$uid';
}

// ─── Repository ───────────────────────────────────────────────────────────────

@lazySingleton
class AuthRepository {
  final AuthDataSource _authDataSource;
  final StorageDataSource _storageDataSource;

  const AuthRepository(this._authDataSource, this._storageDataSource);

  // ─── Auth State Stream ────────────────────────────────────────────────────

  Stream<AuthModel?> get authStateChanges => _authDataSource.authStateChanges;

  // ─── Get Current User ─────────────────────────────────────────────────────

  Future<AuthModel?> getCurrentUser() => _authDataSource.getCurrentUser();

  // ─── Sign Up ──────────────────────────────────────────────────────────────

  Future<AuthModel> signUp({required String email, required String password}) =>
      _authDataSource.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );

  // ─── Login ────────────────────────────────────────────────────────────────

  Future<AuthModel> login({required String email, required String password}) =>
      _authDataSource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

  // ─── Sign Out ─────────────────────────────────────────────────────────────

  Future<void> signOut() => _authDataSource.signOut();

  // ─── Password Reset ───────────────────────────────────────────────────────

  Future<void> sendPasswordResetEmail({required String email}) =>
      _authDataSource.sendPasswordResetEmail(email: email);

  // ─── Save Profile ─────────────────────────────────────────────────────────
  //
  //  Accepts an optional [imageFile]. If provided:
  //  1. Uploads to Supabase Storage → gets public URL
  //  2. Attaches URL to UserModel before saving to Firestore
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> saveUserProfile({
    required UserModel user,
    File? imageFile,
  }) async {
    String? photoUrl;

    if (imageFile != null) {
      // Pass the folder — impl appends timestamped filename automatically
      photoUrl = await _storageDataSource.uploadFile(
        file: imageFile,
        path: _StoragePaths.profileFolder(user.uid),
      );
    }

    final userToSave = photoUrl != null
        ? user.copyWith(photoUrl: photoUrl)
        : user;

    await _authDataSource.saveUserProfile(user: userToSave);
    await _authDataSource.markProfileComplete(uid: user.uid);
  }

  // ─── Get User Profile ─────────────────────────────────────────────────────

  Future<UserModel?> getUserProfile({required String uid}) =>
      _authDataSource.getUserProfile(uid: uid);

  // ─── Presence ─────────────────────────────────────────────────────────────

  Future<void> updateUserPresence({
    required String uid,
    required bool isOnline,
  }) => _authDataSource.updateUserPresence(uid: uid, isOnline: isOnline);

  // ─── Delete Account ───────────────────────────────────────────────────────

  Future<void> deleteAccount({required String uid}) async {
    // Get photoUrl so we can delete from Supabase by full URL
    final userProfile = await _authDataSource.getUserProfile(uid: uid);
    if (userProfile?.photoUrl != null && userProfile!.photoUrl!.isNotEmpty) {
      await _storageDataSource.deleteFile(path: userProfile.photoUrl!);
    }

    await _authDataSource.deleteAccount(uid: uid);
  }
}
