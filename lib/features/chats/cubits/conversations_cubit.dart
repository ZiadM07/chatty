import 'dart:async';
import 'dart:io';

import 'package:Chatty/core/framework/failure.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/state/app_state.dart';
import '../../users/data/repositories/users_repository.dart';
import '../data/models/chat_model.dart';
import '../data/repositories/chat_repository.dart';

class ConversationsState extends Equatable {
  final AppState<List<ChatModel>> chatsState;
  final AppState<String> openChatState;
  final String searchQuery;
  final bool isSearching;

  const ConversationsState({
    this.chatsState = const AppState(),
    this.openChatState = const AppState(),
    this.searchQuery = '',
    this.isSearching = false,
  });

  ConversationsState copyWith({
    AppState<List<ChatModel>>? chatsState,
    AppState<String>? openChatState,
    String? searchQuery,
    bool? isSearching,
  }) => ConversationsState(
    chatsState: chatsState ?? this.chatsState,
    openChatState: openChatState ?? this.openChatState,
    searchQuery: searchQuery ?? this.searchQuery,
    isSearching: isSearching ?? this.isSearching,
  );

  @override
  List<Object?> get props => [
    chatsState,
    openChatState,
    searchQuery,
    isSearching,
  ];
}

@injectable
class ConversationsCubit extends Cubit<ConversationsState> {
  final ChatRepository _repository;
  final UsersRepository _usersRepository;
  StreamSubscription<List<ChatModel>>? _chatsSub;

  ConversationsCubit(this._repository, this._usersRepository)
    : super(const ConversationsState());

  void watchChats({required String uid}) {
    emit(
      state.copyWith(chatsState: const AppState(status: StateStatus.loading)),
    );

    _chatsSub?.cancel();
    _chatsSub = _repository.watchChats(uid: uid).listen(
      (chats) {
        emit(
          state.copyWith(
            chatsState: AppState(status: StateStatus.success, data: chats),
          ),
        );

        for (final chat in chats) {
          if (chat.unreadCountFor(uid) > 0) {
            _repository.markMessagesDelivered(chatId: chat.id, uid: uid);
          }
        }
      },
      onError: (e) => emit(
        state.copyWith(
          chatsState: AppState(
            status: StateStatus.error,
            message: e is Failure ? e.message : 'Failed to load chats.',
          ),
        ),
      ),
    );
  }

  Future<void> openOrCreateOneToOneChat({
    required String uid,
    required String otherUid,
  }) async {
    emit(
      state.copyWith(
        openChatState: const AppState(status: StateStatus.loading),
      ),
    );
    try {
      final currentUser = await _usersRepository.getUserById(uid: uid);
      final otherUser = await _usersRepository.getUserById(uid: otherUid);

      final chat = await _repository.openOrCreateOneToOneChat(
        uid: uid,
        otherUid: otherUid,
        uidName: currentUser?.displayName ?? uid,
        otherUidName: otherUser?.displayName ?? otherUid,
      );
      emit(
        state.copyWith(
          openChatState: AppState(status: StateStatus.success, data: chat.id),
        ),
      );
    } on Failure catch (e) {
      emit(
        state.copyWith(
          openChatState: AppState(
            status: StateStatus.error,
            message: e.message,
          ),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          openChatState: const AppState(
            status: StateStatus.error,
            message: 'Failed to open chat.',
          ),
        ),
      );
    }
  }

  Future<void> createGroupChat({
    required String createdBy,
    required List<String> memberIds,
    required String groupName,
    required Map<String, String> memberNames,
    File? groupPhotoFile,
    String? groupDescription,
  }) async {
    emit(
      state.copyWith(
        openChatState: const AppState(status: StateStatus.loading),
      ),
    );
    try {
      final chat = await _repository.createGroupChat(
        createdBy: createdBy,
        memberIds: memberIds,
        memberNames: memberNames,
        groupName: groupName,
        groupPhotoFile: groupPhotoFile,
        groupDescription:
            groupDescription ?? 'this is the group description tap to edit',
      );
      emit(
        state.copyWith(
          openChatState: AppState(status: StateStatus.success, data: chat.id),
        ),
      );
    } on Failure catch (e) {
      emit(
        state.copyWith(
          openChatState: AppState(
            status: StateStatus.error,
            message: e.message,
          ),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          openChatState: const AppState(
            status: StateStatus.error,
            message: 'Failed to create group.',
          ),
        ),
      );
    }
  }

  void resetOpenChatState() =>
      emit(state.copyWith(openChatState: const AppState()));

  void search(String query) {
    final trimmed = query.trim();
    emit(state.copyWith(searchQuery: trimmed, isSearching: trimmed.isNotEmpty));
  }

  void clearSearch() {
    emit(state.copyWith(searchQuery: '', isSearching: false));
  }

  @override
  Future<void> close() {
    _chatsSub?.cancel();
    return super.close();
  }
}
