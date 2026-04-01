import 'package:equatable/equatable.dart';

import '../../../../core/state/app_state.dart';
import '../../auth/data/models/user_model.dart';

class ProfileState extends Equatable {
  final UserModel? profile;
  final AppState<UserModel> fetchState;
  final AppState<UserModel> updateInfoState;
  final AppState<UserModel> updatePhotoState;
  final AppState<void> changePasswordState;

  const ProfileState({
    this.profile,
    this.fetchState = const AppState(),
    this.updateInfoState = const AppState(),
    this.updatePhotoState = const AppState(),
    this.changePasswordState = const AppState(),
  });

  factory ProfileState.initial() => const ProfileState();

  ProfileState copyWith({
    UserModel? profile,
    AppState<UserModel>? fetchState,
    AppState<UserModel>? updateInfoState,
    AppState<UserModel>? updatePhotoState,
    AppState<void>? changePasswordState,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      fetchState: fetchState ?? this.fetchState,
      updateInfoState: updateInfoState ?? this.updateInfoState,
      updatePhotoState: updatePhotoState ?? this.updatePhotoState,
      changePasswordState: changePasswordState ?? this.changePasswordState,
    );
  }

  @override
  List<Object?> get props => [
    profile,
    fetchState,
    updateInfoState,
    updatePhotoState,
    changePasswordState,
  ];
}
