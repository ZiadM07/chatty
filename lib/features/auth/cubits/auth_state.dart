import 'package:equatable/equatable.dart';

import '../../../../core/state/app_state.dart';

import '../data/models/auth_model.dart';
import '../data/models/user_model.dart';

class AuthState extends Equatable {
  final AuthModel? currentUser;

  final AppState<AuthModel> loginState;

  final AppState<AuthModel> signUpState;

  final AppState<UserModel> fillProfileState;

  final AppState<void> forgotPasswordState;

  final AppState<void> signOutState;

  /// Tracks email-verification flow: resend, polling, etc.
  final AppState<void> emailVerificationState;

  final bool authReady;

  const AuthState({
    this.currentUser,
    this.loginState = const AppState(),
    this.signUpState = const AppState(),
    this.fillProfileState = const AppState(),
    this.forgotPasswordState = const AppState(),
    this.signOutState = const AppState(),
    this.emailVerificationState = const AppState(),
    this.authReady = false,
  });

  factory AuthState.initial() => const AuthState();

  AuthState copyWith({
    AuthModel? currentUser,
    bool clearCurrentUser = false,
    bool? authReady,
    AppState<AuthModel>? loginState,
    AppState<AuthModel>? signUpState,
    AppState<UserModel>? fillProfileState,
    AppState<void>? forgotPasswordState,
    AppState<void>? signOutState,
    AppState<void>? emailVerificationState,
  }) {
    return AuthState(
      currentUser: clearCurrentUser ? null : currentUser ?? this.currentUser,
      authReady: authReady ?? this.authReady,
      loginState: loginState ?? this.loginState,
      signUpState: signUpState ?? this.signUpState,
      fillProfileState: fillProfileState ?? this.fillProfileState,
      forgotPasswordState: forgotPasswordState ?? this.forgotPasswordState,
      signOutState: signOutState ?? this.signOutState,
      emailVerificationState:
          emailVerificationState ?? this.emailVerificationState,
    );
  }

  @override
  List<Object?> get props => [
    currentUser,
    authReady,
    loginState,
    signUpState,
    fillProfileState,
    forgotPasswordState,
    signOutState,
    emailVerificationState,
  ];
}
