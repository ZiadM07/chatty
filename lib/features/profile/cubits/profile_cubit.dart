import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/state/app_state.dart';
import '../../../../core/framework/failure.dart';
import '../data/repositories/profile_repositories.dart';
import 'profile_state.dart';

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _repository;

  ProfileCubit(this._repository) : super(ProfileState.initial());

  Future<void> loadProfile({required String uid}) async {
    emit(
      state.copyWith(fetchState: const AppState(status: StateStatus.loading)),
    );

    try {
      final profile = await _repository.getProfile(uid: uid);

      if (profile == null) {
        emit(
          state.copyWith(
            fetchState: const AppState(
              status: StateStatus.error,
              message: 'Profile not found.',
            ),
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          profile: profile,
          fetchState: AppState(status: StateStatus.success, data: profile),
        ),
      );
    } on Failure catch (e) {
      emit(
        state.copyWith(
          fetchState: AppState(status: StateStatus.error, message: e.message),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          fetchState: const AppState(
            status: StateStatus.error,
            message: 'Failed to load profile.',
          ),
        ),
      );
    }
  }

  Future<void> updateFullName({
    required String uid,
    required String fullName,
  }) async {
    emit(
      state.copyWith(
        updateInfoState: const AppState(status: StateStatus.loadingOverlay),
      ),
    );

    try {
      await _repository.updateProfileFullName(uid: uid, fullName: fullName);

      final updated = state.profile?.copyWith(fullName: fullName);

      emit(
        state.copyWith(
          profile: updated,
          updateInfoState: AppState(
            status: StateStatus.success,
            data: updated,
            message: 'Name updated successfully.',
          ),
        ),
      );
    } on Failure catch (e) {
      emit(
        state.copyWith(
          updateInfoState: AppState(
            status: StateStatus.error,
            message: e.message,
          ),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          updateInfoState: const AppState(
            status: StateStatus.error,
            message: 'Failed to update name.',
          ),
        ),
      );
    }
  }

  Future<void> updateBio({required String uid, required String bio}) async {
    emit(
      state.copyWith(
        updateInfoState: const AppState(status: StateStatus.loadingOverlay),
      ),
    );

    try {
      await _repository.updateProfileBio(uid: uid, bio: bio);

      final updated = state.profile?.copyWith(bio: bio);

      emit(
        state.copyWith(
          profile: updated,
          updateInfoState: AppState(
            status: StateStatus.success,
            data: updated,
            message: 'Bio updated successfully.',
          ),
        ),
      );
    } on Failure catch (e) {
      emit(
        state.copyWith(
          updateInfoState: AppState(
            status: StateStatus.error,
            message: e.message,
          ),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          updateInfoState: const AppState(
            status: StateStatus.error,
            message: 'Failed to update bio.',
          ),
        ),
      );
    }
  }

  Future<void> updateProfilePhoto({
    required String uid,
    required File imageFile,
  }) async {
    emit(
      state.copyWith(
        updatePhotoState: const AppState(status: StateStatus.loadingOverlay),
      ),
    );

    try {
      final newPhotoUrl = await _repository.updateProfilePhoto(
        uid: uid,
        imageFile: imageFile,
        oldPhotoUrl: state.profile?.photoUrl,
      );

      final updated = state.profile?.copyWith(photoUrl: newPhotoUrl);

      emit(
        state.copyWith(
          profile: updated,
          updatePhotoState: AppState(
            status: StateStatus.success,
            data: updated,
          ),
        ),
      );
    } on Failure catch (e) {
      emit(
        state.copyWith(
          updatePhotoState: AppState(
            status: StateStatus.error,
            message: e.message,
          ),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          updatePhotoState: AppState(
            status: StateStatus.error,
            message: e.toString().contains('StorageUploadException')
                ? 'Failed to upload photo. Please try again.'
                : 'Failed to update photo.',
          ),
        ),
      );
    }
  }

  void resetUpdateInfoState() =>
      emit(state.copyWith(updateInfoState: const AppState()));

  void resetUpdatePhotoState() =>
      emit(state.copyWith(updatePhotoState: const AppState()));

  Future<void> deleteProfilePhoto({required String uid}) async {
    final currentPhotoUrl = state.profile?.photoUrl;

    emit(
      state.copyWith(
        updatePhotoState: const AppState(status: StateStatus.loadingOverlay),
      ),
    );

    try {
      await _repository.deleteProfilePhoto(
        uid: uid,
        photoUrl: currentPhotoUrl ?? '',
      );

      await loadProfile(uid: uid);

      emit(
        state.copyWith(
          updatePhotoState: const AppState(status: StateStatus.success),
        ),
      );
    } on Failure catch (e) {
      emit(
        state.copyWith(
          updatePhotoState: AppState(
            status: StateStatus.error,
            message: e.message,
          ),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          updatePhotoState: const AppState(
            status: StateStatus.error,
            message: 'Failed to delete photo.',
          ),
        ),
      );
    }
  }
}
