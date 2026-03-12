import 'dart:io';

import 'package:injectable/injectable.dart';

import '../../../shared/data/data_sources/storage_data_source.dart';
import '../../../auth/data/models/user_model.dart';
import '../data_source/profile_data_source.dart';

class _StoragePaths {
  static String profileFolder(String uid) => 'profiles/$uid';
}

@lazySingleton
class ProfileRepository {
  final ProfileDataSource _profileDataSource;
  final StorageDataSource _storageDataSource;

  const ProfileRepository(this._profileDataSource, this._storageDataSource);

  Future<UserModel?> getProfile({required String uid}) =>
      _profileDataSource.getProfile(uid: uid);

  Stream<UserModel?> watchProfile({required String uid}) =>
      _profileDataSource.watchProfile(uid: uid);

  Future<void> updateProfileFullName({
    required String uid,
    required String fullName,
  }) => _profileDataSource.updateProfileFullName(uid: uid, fullName: fullName);

  Future<void> updateProfileBio({required String uid, required String bio}) =>
      _profileDataSource.updateProfileBio(uid: uid, bio: bio);

  Future<String> updateProfilePhoto({
    required String uid,
    required File imageFile,
    String? oldPhotoUrl,
  }) async {
    if (oldPhotoUrl != null && oldPhotoUrl.isNotEmpty) {
      try {
        await _storageDataSource.deleteFile(path: oldPhotoUrl);
      } catch (_) {}
    }

    final newPhotoUrl = await _storageDataSource.uploadFile(
      file: imageFile,
      path: _StoragePaths.profileFolder(uid),
    );

    await _profileDataSource.updateProfilePhoto(
      uid: uid,
      photoUrl: newPhotoUrl,
    );
    return newPhotoUrl;
  }
}
