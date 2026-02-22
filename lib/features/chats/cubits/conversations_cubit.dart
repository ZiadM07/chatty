import 'dart:async';
import 'dart:io';

import 'package:chatty/features/chats/data/data_source/chat_data_source.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/state/app_state.dart';
import '../data/models/chat_model.dart';
import '../data/repositories/chat_repository.dart';

class ConversationsState extends Equatable {
  final AppState<List<ChatModel>> chatsState;

  final AppState<String> openChatState;

  const ConversationsState({
    this.chatsState = const AppState(),
    this.openChatState = const AppState(),
  });

  ConversationsState copyWith({
    AppState<List<ChatModel>>? chatsState,
    AppState<String>? openChatState,
  }) => ConversationsState(
    chatsState: chatsState ?? this.chatsState,
    openChatState: openChatState ?? this.openChatState,
  );

  @override
  List<Object?> get props => [chatsState, openChatState];
}

@injectable
class ConversationsCubit extends Cubit<ConversationsState> {
  final ChatRepository _repository;
  StreamSubscription<List<ChatModel>>? _chatsSub;

  ConversationsCubit(this._repository) : super(const ConversationsState());

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
        // Mark messages as delivered for chats with unread counts —
        // meaning the sender's message reached us but we haven't opened the chat yet
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
            message: e is ChatException ? e.message : 'Failed to load chats.',
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
      final chat = await _repository.openOrCreateOneToOneChat(
        uid: uid,
        otherUid: otherUid,
      );
      // Store only the id
      emit(
        state.copyWith(
          openChatState: AppState(status: StateStatus.success, data: chat.id),
        ),
      );
    } on ChatException catch (e) {
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
    File? groupPhotoFile,
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
        groupName: groupName,
        groupPhotoFile: groupPhotoFile,
      );
      // Store only the id
      emit(
        state.copyWith(
          openChatState: AppState(status: StateStatus.success, data: chat.id),
        ),
      );
    } on ChatException catch (e) {
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

  @override
  Future<void> close() {
    _chatsSub?.cancel();
    return super.close();
  }
}
