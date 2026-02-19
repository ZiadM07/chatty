import 'package:chatty/core/constants/exports.dart';
import 'package:chatty/features/auth/data/models/user_model.dart';

class UserInfoState extends Equatable {
  final UserModel? user;
  final AppState<UserModel> userState;

  /// Stores only the chatId on success — that's all the route needs
  final AppState<String> openChatState;

  const UserInfoState({
    this.user,
    this.userState = const AppState(),
    this.openChatState = const AppState(),
  });

  UserInfoState copyWith({
    UserModel? user,
    AppState<UserModel>? userState,
    AppState<String>? openChatState,
  }) => UserInfoState(
    user: user ?? this.user,
    userState: userState ?? this.userState,
    openChatState: openChatState ?? this.openChatState,
  );

  @override
  List<Object?> get props => [user, userState, openChatState];
}
