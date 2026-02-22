import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/state/app_state.dart';
import '../data/data_sources/auth_data_source.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repositories.dart';
import 'auth_state.dart';

@lazySingleton
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(AuthState.initial()) {
    _watchAuthState();
  }

  // ─── Watch Firebase Auth Stream ───────────────────────────────────────────

  void _watchAuthState() {
    _repository.authStateChanges.listen(
      (authModel) => emit(
        state.copyWith(
          currentUser: authModel,
          clearCurrentUser: authModel == null,
          authReady: true, // ← first real Firebase response received
        ),
      ),
      onError: (_) =>
          emit(state.copyWith(clearCurrentUser: true, authReady: true)),
    );
  }

  // ─── Sign Up ──────────────────────────────────────────────────────────────

  Future<void> signUp({required String email, required String password}) async {
    emit(
      state.copyWith(signUpState: const AppState(status: StateStatus.loading)),
    );
    try {
      final authModel = await _repository.signUp(
        email: email,
        password: password,
      );
      emit(
        state.copyWith(
          currentUser: authModel,
          authReady: true,
          signUpState: AppState(status: StateStatus.success, data: authModel),
        ),
      );
    } on AuthException catch (e) {
      emit(
        state.copyWith(
          signUpState: AppState(status: StateStatus.error, message: e.message),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          signUpState: const AppState(
            status: StateStatus.error,
            message: 'Something went wrong. Please try again.',
          ),
        ),
      );
    }
  }

  // ─── Login ────────────────────────────────────────────────────────────────

  Future<void> login({required String email, required String password}) async {
    emit(
      state.copyWith(loginState: const AppState(status: StateStatus.loading)),
    );
    try {
      final authModel = await _repository.login(
        email: email,
        password: password,
      );
      emit(
        state.copyWith(
          currentUser: authModel,
          authReady: true,
          loginState: AppState(status: StateStatus.success, data: authModel),
        ),
      );
    } on AuthException catch (e) {
      emit(
        state.copyWith(
          loginState: AppState(status: StateStatus.error, message: e.message),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          loginState: const AppState(
            status: StateStatus.error,
            message: 'Something went wrong. Please try again.',
          ),
        ),
      );
    }
  }

  Future<void> saveProfile({required UserModel user, File? imageFile}) async {
    emit(
      state.copyWith(
        fillProfileState: const AppState(status: StateStatus.loadingOverlay),
      ),
    );
    try {
      await _repository.saveUserProfile(user: user, imageFile: imageFile);
      final updatedAuth = state.currentUser?.copyWith(isProfileComplete: true);
      emit(
        state.copyWith(
          currentUser: updatedAuth,
          fillProfileState: AppState(status: StateStatus.success, data: user),
        ),
      );
    } on AuthException catch (e) {
      emit(
        state.copyWith(
          fillProfileState: AppState(
            status: StateStatus.error,
            message: e.message,
          ),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          fillProfileState: AppState(
            status: StateStatus.error,
            message: e.toString().contains('StorageUploadException')
                ? 'Failed to upload image. Please try again.'
                : 'Failed to save profile. Please try again.',
          ),
        ),
      );
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    emit(
      state.copyWith(
        forgotPasswordState: const AppState(status: StateStatus.loading),
      ),
    );
    try {
      await _repository.sendPasswordResetEmail(email: email);
      emit(
        state.copyWith(
          forgotPasswordState: const AppState(
            status: StateStatus.success,
            message: 'Password reset email sent! Check your inbox.',
          ),
        ),
      );
    } on AuthException catch (e) {
      emit(
        state.copyWith(
          forgotPasswordState: AppState(
            status: StateStatus.error,
            message: e.message,
          ),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          forgotPasswordState: const AppState(
            status: StateStatus.error,
            message: 'Failed to send reset email. Please try again.',
          ),
        ),
      );
    }
  }

  Future<void> signOut() async {
    emit(
      state.copyWith(
        signOutState: const AppState(status: StateStatus.loadingOverlay),
      ),
    );
    try {
      await _repository.signOut();
      emit(
        AuthState.initial().copyWith(
          authReady: true,
          signOutState: const AppState(status: StateStatus.success),
        ),
      );
    } on AuthException catch (e) {
      emit(
        state.copyWith(
          signOutState: AppState(status: StateStatus.error, message: e.message),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          signOutState: const AppState(
            status: StateStatus.error,
            message: 'Sign out failed. Please try again.',
          ),
        ),
      );
    }
  }

  Future<void> deleteAccount() async {
    final uid = state.currentUser?.uid;
    if (uid == null) return;

    emit(
      state.copyWith(
        signOutState: const AppState(status: StateStatus.loadingOverlay),
      ),
    );

    try {
      await _repository.deleteAccount(uid: uid);
      emit(AuthState.initial().copyWith(authReady: true));
    } on AuthException catch (e) {
      emit(
        state.copyWith(
          signOutState: AppState(status: StateStatus.error, message: e.message),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          signOutState: const AppState(
            status: StateStatus.error,
            message: 'Failed to delete account. Please try again.',
          ),
        ),
      );
    }
  }

  Future<void> setOnline() async {
    final uid = state.currentUser?.uid;
    if (uid == null) return;
    await _repository.updateUserPresence(uid: uid, isOnline: true);
  }

  Future<void> setOffline() async {
    final uid = state.currentUser?.uid;
    if (uid == null) return;
    await _repository.updateUserPresence(uid: uid, isOnline: false);
  }

  void resetLoginState() => emit(state.copyWith(loginState: const AppState()));

  void resetSignUpState() =>
      emit(state.copyWith(signUpState: const AppState()));

  void resetFillProfileState() =>
      emit(state.copyWith(fillProfileState: const AppState()));

  void resetForgotPasswordState() =>
      emit(state.copyWith(forgotPasswordState: const AppState()));
}
