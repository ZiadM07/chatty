import 'package:Chatty/core/constants/exports.dart';
import '../../../core/framework/notification_service.dart';
import '../../../core/framework/failure.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repositories.dart';
import 'auth_state.dart';

@lazySingleton
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;
  final NotificationService _notificationService;

  AuthCubit(this._repository, this._notificationService)
    : super(AuthState.initial()) {
    _watchAuthState();
  }

  void _watchAuthState() {
    _repository.authStateChanges.listen(
      (authModel) async {
        emit(
          state.copyWith(
            currentUser: authModel,
            clearCurrentUser: authModel == null,
            authReady: true,
          ),
        );
        if (authModel != null) {
          await _notificationService.login(authModel.uid);
          await setOnline();
        }
      },
      onError: (_) =>
          emit(state.copyWith(clearCurrentUser: true, authReady: true)),
    );
  }

  Future<void> signUp({required String email, required String password}) async {
    emit(
      state.copyWith(
        signUpState: const AppState(status: StateStatus.loadingOverlay),
      ),
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
    } on Failure catch (e) {
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

  Future<void> login({required String email, required String password}) async {
    emit(
      state.copyWith(
        loginState: const AppState(status: StateStatus.loadingOverlay),
      ),
    );
    try {
      final authModel = await _repository.login(
        email: email,
        password: password,
      );

      // ── Block unverified users ──────────────────────────────────────────
      if (!authModel.emailVerified) {
        // Sign them out so authStateChanges doesn't auto-navigate.
        await _repository.signOut();
        emit(
          state.copyWith(
            loginState: const AppState(
              status: StateStatus.error,
              message: 'EMAIL_NOT_VERIFIED',
            ),
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          currentUser: authModel,
          authReady: true,
          loginState: AppState(status: StateStatus.success, data: authModel),
        ),
      );
    } on Failure catch (e) {
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

  // ─── Email Verification ──────────────────────────────────────────────────

  /// Resend the verification email to the current Firebase user.
  Future<void> sendEmailVerification() async {
    emit(
      state.copyWith(
        emailVerificationState: const AppState(
          status: StateStatus.loading,
        ),
      ),
    );
    try {
      await _repository.sendEmailVerification();
      emit(
        state.copyWith(
          emailVerificationState: const AppState(
            status: StateStatus.success,
            message: 'Verification email sent! Check your inbox.',
          ),
        ),
      );
    } on Failure catch (e) {
      emit(
        state.copyWith(
          emailVerificationState: AppState(
            status: StateStatus.error,
            message: e.message,
          ),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          emailVerificationState: const AppState(
            status: StateStatus.error,
            message: 'Failed to send verification email.',
          ),
        ),
      );
    }
  }

  /// Polls Firebase to check if the user has verified their email.
  /// Returns `true` when verified.
  Future<bool> checkEmailVerified() async {
    try {
      final refreshed = await _repository.reloadUser();
      if (refreshed != null && refreshed.emailVerified) {
        emit(state.copyWith(currentUser: refreshed));
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  void resetEmailVerificationState() =>
      emit(state.copyWith(emailVerificationState: const AppState()));

  // ─── Profile ─────────────────────────────────────────────────────────────

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
    } on Failure catch (e) {
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

  // ─── Password Reset ──────────────────────────────────────────────────────

  Future<void> sendPasswordResetEmail({required String email}) async {
    emit(
      state.copyWith(
        forgotPasswordState: const AppState(status: StateStatus.loadingOverlay),
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
    } on Failure catch (e) {
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

  // ─── Sign Out & Delete ───────────────────────────────────────────────────

  Future<void> signOut() async {
    emit(
      state.copyWith(
        signOutState: const AppState(status: StateStatus.loadingOverlay),
      ),
    );
    try {
      await _notificationService.logout();
      await _repository.signOut();
      emit(
        AuthState.initial().copyWith(
          authReady: true,
          signOutState: const AppState(status: StateStatus.success),
        ),
      );
    } on Failure catch (e) {
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
      await _notificationService.logout();
      await _repository.deleteAccount(uid: uid);
      emit(AuthState.initial().copyWith(authReady: true));
    } on Failure catch (e) {
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

  // ─── Presence ─────────────────────────────────────────────────────────────

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

  // ─── Resets ───────────────────────────────────────────────────────────────

  void resetLoginState() => emit(state.copyWith(loginState: const AppState()));

  void resetSignUpState() =>
      emit(state.copyWith(signUpState: const AppState()));

  void resetFillProfileState() =>
      emit(state.copyWith(fillProfileState: const AppState()));

  void resetForgotPasswordState() =>
      emit(state.copyWith(forgotPasswordState: const AppState()));
}
