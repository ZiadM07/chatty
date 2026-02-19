import 'package:chatty/core/constants/exports.dart';
import 'package:chatty/features/auth/data/models/user_model.dart';

class UsersState extends Equatable {
  final AppState<List<UserModel>> usersState;
  final List<UserModel> users;
  final bool hasMore;         // false when last page was smaller than limit
  final bool isSearching;
  final String searchQuery;

  const UsersState({
    this.usersState = const AppState(),
    this.users = const [],
    this.hasMore = true,
    this.isSearching = false,
    this.searchQuery = '',
  });

  UsersState copyWith({
    AppState<List<UserModel>>? usersState,
    List<UserModel>? users,
    bool? hasMore,
    bool? isSearching,
    String? searchQuery,
  }) =>
      UsersState(
        usersState: usersState ?? this.usersState,
        users: users ?? this.users,
        hasMore: hasMore ?? this.hasMore,
        isSearching: isSearching ?? this.isSearching,
        searchQuery: searchQuery ?? this.searchQuery,
      );

  @override
  List<Object?> get props =>
      [usersState, users, hasMore, isSearching, searchQuery];
}