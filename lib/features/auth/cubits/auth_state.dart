import 'package:equatable/equatable.dart';

import '../../../../core/state/app_state.dart';

import '../data/models/auth_model.dart';
import '../data/models/user_model.dart';

// ─── Auth State ───────────────────────────────────────────────────────────────
//
//  We use a single class with named constructors so StateHandler can consume
//  it directly via `state.authState`, `state.loginState`, etc.
//  Each screen gets its own AppState slot — they never interfere.
// ─────────────────────────────────────────────────────────────────────────────

class AuthState extends Equatable {
  /// Tracks the currently signed-in user. Drives the root router.
  final AuthModel? currentUser;

  /// login screen state  → data: AuthModel
  final AppState<AuthModel> loginState;

  /// signup screen state → data: AuthModel
  final AppState<AuthModel> signUpState;

  /// fill profile screen state → data: UserModel
  final AppState<UserModel> fillProfileState;

  /// password reset state → no data needed, just status + message
  final AppState<void> forgotPasswordState;

  /// sign out / delete account state
  final AppState<void> signOutState;

  final bool authReady;

  const AuthState({
    this.currentUser,
    this.loginState = const AppState(),
    this.signUpState = const AppState(),
    this.fillProfileState = const AppState(),
    this.forgotPasswordState = const AppState(),
    this.signOutState = const AppState(),
    this.authReady = false,
  });

  // ─── Initial ──────────────────────────────────────────────────────────────

  factory AuthState.initial() => const AuthState();

  // ─── CopyWith ─────────────────────────────────────────────────────────────

  AuthState copyWith({
    AuthModel? currentUser,
    bool clearCurrentUser = false,
    bool? authReady,
    AppState<AuthModel>? loginState,
    AppState<AuthModel>? signUpState,
    AppState<UserModel>? fillProfileState,
    AppState<void>? forgotPasswordState,
    AppState<void>? signOutState,
  }) {
    return AuthState(
      currentUser: clearCurrentUser ? null : currentUser ?? this.currentUser,
      authReady: authReady ?? this.authReady,
      loginState: loginState ?? this.loginState,
      signUpState: signUpState ?? this.signUpState,
      fillProfileState: fillProfileState ?? this.fillProfileState,
      forgotPasswordState: forgotPasswordState ?? this.forgotPasswordState,
      signOutState: signOutState ?? this.signOutState,
    );
  }

  // ─── Equatable ────────────────────────────────────────────────────────────

  @override
  List<Object?> get props => [
    currentUser,
    authReady,
    loginState,
    signUpState,
    fillProfileState,
    forgotPasswordState,
    signOutState,
  ];
}
