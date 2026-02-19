import 'package:equatable/equatable.dart';

import '../../../../core/state/app_state.dart';
import '../../auth/data/models/user_model.dart';

class ProfileState extends Equatable {
  /// The currently loaded profile — updated after fetch and after any edit.
  final UserModel? profile;

  /// Fetching the profile on screen load.
  final AppState<UserModel> fetchState;

  /// Saving name + bio changes.
  final AppState<UserModel> updateInfoState;

  /// Uploading + saving a new profile photo.
  final AppState<UserModel> updatePhotoState;

  const ProfileState({
    this.profile,
    this.fetchState = const AppState(),
    this.updateInfoState = const AppState(),
    this.updatePhotoState = const AppState(),
  });

  factory ProfileState.initial() => const ProfileState();

  ProfileState copyWith({
    UserModel? profile,
    AppState<UserModel>? fetchState,
    AppState<UserModel>? updateInfoState,
    AppState<UserModel>? updatePhotoState,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      fetchState: fetchState ?? this.fetchState,
      updateInfoState: updateInfoState ?? this.updateInfoState,
      updatePhotoState: updatePhotoState ?? this.updatePhotoState,
    );
  }

  @override
  List<Object?> get props => [
    profile,
    fetchState,
    updateInfoState,
    updatePhotoState,
  ];
}
