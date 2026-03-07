import 'dart:io';

import 'package:injectable/injectable.dart';

import '../../../shared/data/data_sources/storage_data_source.dart';
import '../../../auth/data/models/user_model.dart';
import '../data_source/profile_data_source.dart';

// ─── Storage Path ─────────────────────────────────────────────────────────────

class _StoragePaths {
  static String profileFolder(String uid) => 'profiles/$uid';
}

// ─── Repository ───────────────────────────────────────────────────────────────

@lazySingleton
class ProfileRepository {
  final ProfileDataSource _profileDataSource;
  final StorageDataSource _storageDataSource;

  const ProfileRepository(this._profileDataSource, this._storageDataSource);

  // ─── Get Profile ──────────────────────────────────────────────────────────

  Future<UserModel?> getProfile({required String uid}) =>
      _profileDataSource.getProfile(uid: uid);

  // ─── Watch Profile ────────────────────────────────────────────────────────

  Stream<UserModel?> watchProfile({required String uid}) =>
      _profileDataSource.watchProfile(uid: uid);

  // ─── Update Full Name ─────────────────────────────────────────────────────

  Future<void> updateProfileFullName({
    required String uid,
    required String fullName,
  }) => _profileDataSource.updateProfileFullName(uid: uid, fullName: fullName);

  // ─── Update Bio ───────────────────────────────────────────────────────────

  Future<void> updateProfileBio({required String uid, required String bio}) =>
      _profileDataSource.updateProfileBio(uid: uid, bio: bio);

  // ─── Update Photo ─────────────────────────────────────────────────────────
  //
  //  1. Delete the old image from Supabase (if one exists) — avoids orphaned
  //     files piling up in storage since each upload creates a new timestamped
  //     file inside the profiles/<uid>/ folder.
  //  2. Upload the new image → get public URL.
  //  3. Write the new URL to Firestore.
  //
  //  Returns the new public URL so the cubit can patch local state immediately.
  // ─────────────────────────────────────────────────────────────────────────

  Future<String> updateProfilePhoto({
    required String uid,
    required File imageFile,
    String? oldPhotoUrl, // ← current photoUrl from state, may be null
  }) async {
    // 1. Delete old image — fire and forget, don't block or fail the upload
    //    if the old file is already gone or the URL is malformed.
    if (oldPhotoUrl != null && oldPhotoUrl.isNotEmpty) {
      try {
        await _storageDataSource.deleteFile(path: oldPhotoUrl);
      } catch (_) {
        // Non-fatal — old file may already be deleted or URL stale
      }
    }

    // 2. Upload new image to Supabase
    final newPhotoUrl = await _storageDataSource.uploadFile(
      file: imageFile,
      path: _StoragePaths.profileFolder(uid),
    );

    // 3. Persist new URL to Firestore
    await _profileDataSource.updateProfilePhoto(
      uid: uid,
      photoUrl: newPhotoUrl,
    );

    return newPhotoUrl;
  }
}
