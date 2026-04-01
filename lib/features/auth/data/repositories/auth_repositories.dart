import 'dart:io';

import 'package:Chatty/features/chats/data/data_source/chat_data_source.dart';
import 'package:injectable/injectable.dart';

import '../../data/data_sources/auth_data_source.dart';
import '../../../shared/data/data_sources/storage_data_source.dart';
import '../../data/models/auth_model.dart';
import '../../data/models/user_model.dart';

class _StoragePaths {
  static String profileFolder(String uid) => 'profiles/$uid';
}

@lazySingleton
class AuthRepository {
  final AuthDataSource _authDataSource;
  final ChatDataSource _chatDataSource;
  final StorageDataSource _storageDataSource;

  const AuthRepository(
    this._authDataSource,
    this._storageDataSource,
    this._chatDataSource,
  );

  Stream<AuthModel?> get authStateChanges => _authDataSource.authStateChanges;

  Future<AuthModel?> getCurrentUser() => _authDataSource.getCurrentUser();

  Future<AuthModel> signUp({required String email, required String password}) =>
      _authDataSource.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );

  Future<AuthModel> login({required String email, required String password}) =>
      _authDataSource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

  Future<void> signOut() => _authDataSource.signOut();

  Future<void> sendPasswordResetEmail({required String email}) =>
      _authDataSource.sendPasswordResetEmail(email: email);

  Future<void> saveUserProfile({
    required UserModel user,
    File? imageFile,
  }) async {
    String? photoUrl;

    if (imageFile != null) {
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

  Future<UserModel?> getUserProfile({required String uid}) =>
      _authDataSource.getUserProfile(uid: uid);

  Future<void> updateUserPresence({
    required String uid,
    required bool isOnline,
  }) => _authDataSource.updateUserPresence(uid: uid, isOnline: isOnline);

  Future<void> deleteAccount({required String uid}) async {
    final userProfile = await _authDataSource.getUserProfile(uid: uid);
    if (userProfile?.photoUrl != null && userProfile!.photoUrl!.isNotEmpty) {
      await _storageDataSource.deleteFile(path: userProfile.photoUrl!);
    }

    await _chatDataSource.deleteAllUserChats(uid: uid);

    await _authDataSource.deleteAccount(uid: uid);
  }

  Future<void> reauthenticate({required String password}) =>
      _authDataSource.reauthenticate(password: password);

  Future<void> sendEmailVerification() =>
      _authDataSource.sendEmailVerification();

  Future<AuthModel?> reloadUser() => _authDataSource.reloadUser();

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) => _authDataSource.changePassword(
    currentPassword: currentPassword,
    newPassword: newPassword,
  );
}
