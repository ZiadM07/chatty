import 'dart:async';
import 'package:chatty/core/utils/enums.dart';
import 'package:chatty/features/chats/data/models/message_model.dart';
import 'package:chatty/core/constants/exports.dart';
import 'package:chatty/features/chats/data/data_source/chat_data_source.dart';
import 'package:chatty/features/chats/data/models/chat_model.dart';
import 'package:chatty/features/chats/data/repositories/chat_repository.dart';

class ChatState extends Equatable {
  final ChatModel? chat;
  final AppState<ChatModel> chatState;
  final AppState<List<MessageModel>> messagesState;
  final AppState<MessageModel> sendState;
  final AppState<void> deleteMessageState;
  final AppState<void> updateGroupState;
  final MessageModel? replyingTo;

  const ChatState({
    this.chat,
    this.chatState = const AppState(),
    this.messagesState = const AppState(),
    this.sendState = const AppState(),
    this.deleteMessageState = const AppState(),
    this.updateGroupState = const AppState(),
    this.replyingTo,
  });

  ChatState copyWith({
    ChatModel? chat,
    AppState<ChatModel>? chatState,
    AppState<List<MessageModel>>? messagesState,
    AppState<MessageModel>? sendState,
    AppState<void>? deleteMessageState,
    AppState<void>? updateGroupState,
    MessageModel? replyingTo,
    bool clearReplyingTo = false,
  }) => ChatState(
    chat: chat ?? this.chat,
    chatState: chatState ?? this.chatState,
    messagesState: messagesState ?? this.messagesState,
    sendState: sendState ?? this.sendState,
    deleteMessageState: deleteMessageState ?? this.deleteMessageState,
    updateGroupState: updateGroupState ?? this.updateGroupState,
    replyingTo: clearReplyingTo ? null : replyingTo ?? this.replyingTo,
  );

  @override
  List<Object?> get props => [
    chat,
    chatState,
    messagesState,
    sendState,
    deleteMessageState,
    updateGroupState,
    replyingTo,
  ];
}

@injectable
class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _repository;
  StreamSubscription<List<MessageModel>>? _messagesSub;

  ChatCubit(this._repository) : super(const ChatState());

  Future<void> init({
    required String chatId,
    required String currentUid,
  }) async {
    emit(
      state.copyWith(chatState: const AppState(status: StateStatus.loading)),
    );

    try {
      final chat = await _repository.getChat(chatId: chatId);

      if (chat == null) {
        emit(
          state.copyWith(
            chatState: const AppState(
              status: StateStatus.error,
              message: 'Chat not found.',
            ),
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          chat: chat,
          chatState: AppState(status: StateStatus.success, data: chat),
          messagesState: const AppState(status: StateStatus.loading),
        ),
      );

      _watchMessages(chatId: chatId, currentUid: currentUid);
    } on ChatException catch (e) {
      emit(
        state.copyWith(
          chatState: AppState(status: StateStatus.error, message: e.message),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          chatState: const AppState(
            status: StateStatus.error,
            message: 'Failed to open chat.',
          ),
        ),
      );
    }
  }

  void _watchMessages({required String chatId, required String currentUid}) {
    _messagesSub?.cancel();
    _messagesSub = _repository
        .watchMessages(chatId: chatId)
        .listen(
          (messages) => emit(
            state.copyWith(
              messagesState: AppState(
                status: StateStatus.success,
                data: messages,
              ),
            ),
          ),
          onError: (e) => emit(
            state.copyWith(
              messagesState: AppState(
                status: StateStatus.error,
                message: e is ChatException
                    ? e.message
                    : 'Failed to load messages.',
              ),
            ),
          ),
        );

    _repository.markChatAsRead(chatId: chatId, uid: currentUid);
  }

  Future<void> sendTextMessage({
    required String senderId,
    required String content,
  }) async {
    final chat = state.chat;
    if (chat == null) return;

    final reply = state.replyingTo;
    emit(state.copyWith(clearReplyingTo: true));

    try {
      await _repository.sendTextMessage(
        chatId: chat.id,
        senderId: senderId,
        memberIds: chat.memberIds,
        content: content,
        replyToId: reply?.id,
        replyToContent: reply?.content,
        replyToSenderId: reply?.senderId,
      );
    } on ChatException catch (e) {
      emit(
        state.copyWith(
          sendState: AppState(status: StateStatus.error, message: e.message),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          sendState: const AppState(
            status: StateStatus.error,
            message: 'Failed to send message.',
          ),
        ),
      );
    }
  }

  Future<void> sendMediaMessage({
    required String senderId,
    required File file,
    required MessageType type,
  }) async {
    final chat = state.chat;
    if (chat == null) return;

    final reply = state.replyingTo;
    emit(
      state.copyWith(
        sendState: const AppState(status: StateStatus.loadingOverlay),
        clearReplyingTo: true,
      ),
    );

    try {
      await _repository.sendMediaMessage(
        chatId: chat.id,
        senderId: senderId,
        memberIds: chat.memberIds,
        file: file,
        type: type,
        replyToId: reply?.id,
        replyToContent: reply?.content,
        replyToSenderId: reply?.senderId,
      );
      emit(state.copyWith(sendState: const AppState()));
    } on ChatException catch (e) {
      emit(
        state.copyWith(
          sendState: AppState(status: StateStatus.error, message: e.message),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          sendState: const AppState(
            status: StateStatus.error,
            message: 'Failed to send media.',
          ),
        ),
      );
    }
  }

  Future<void> deleteMessage({required String messageId}) async {
    final chatId = state.chat?.id;
    if (chatId == null) return;
    try {
      await _repository.deleteMessage(chatId: chatId, messageId: messageId);
    } on ChatException catch (e) {
      emit(
        state.copyWith(
          deleteMessageState: AppState(
            status: StateStatus.error,
            message: e.message,
          ),
        ),
      );
    }
  }

  Future<void> markAsRead({required String uid}) async {
    final chatId = state.chat?.id;
    if (chatId == null) return;
    await _repository.markChatAsRead(chatId: chatId, uid: uid);
  }

  Future<void> addGroupMembers({required List<String> newMemberIds}) async {
    final chatId = state.chat?.id;
    if (chatId == null) return;
    try {
      await _repository.addGroupMembers(
        chatId: chatId,
        newMemberIds: newMemberIds,
      );
    } on ChatException catch (e) {
      emit(
        state.copyWith(
          updateGroupState: AppState(
            status: StateStatus.error,
            message: e.message,
          ),
        ),
      );
    }
  }

  Future<void> removeGroupMember({required String memberId}) async {
    final chatId = state.chat?.id;
    if (chatId == null) return;
    try {
      await _repository.removeGroupMember(chatId: chatId, memberId: memberId);
    } on ChatException catch (e) {
      emit(
        state.copyWith(
          updateGroupState: AppState(
            status: StateStatus.error,
            message: e.message,
          ),
        ),
      );
    }
  }

  Future<void> updateGroupInfo({
    String? groupName,
    File? groupPhotoFile,
  }) async {
    final chat = state.chat;
    if (chat == null) return;
    emit(
      state.copyWith(
        updateGroupState: const AppState(status: StateStatus.loadingOverlay),
      ),
    );
    try {
      await _repository.updateGroupInfo(
        chatId: chat.id,
        groupName: groupName,
        groupPhotoFile: groupPhotoFile,
        oldGroupPhotoUrl: chat.groupPhotoUrl,
      );
      emit(
        state.copyWith(
          updateGroupState: const AppState(status: StateStatus.success),
        ),
      );
    } on ChatException catch (e) {
      emit(
        state.copyWith(
          updateGroupState: AppState(
            status: StateStatus.error,
            message: e.message,
          ),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          updateGroupState: const AppState(
            status: StateStatus.error,
            message: 'Failed to update group.',
          ),
        ),
      );
    }
  }

  void setReplyingTo(MessageModel message) =>
      emit(state.copyWith(replyingTo: message));

  void clearReplyingTo() => emit(state.copyWith(clearReplyingTo: true));

  void resetSendState() => emit(state.copyWith(sendState: const AppState()));
  void resetDeleteMessageState() =>
      emit(state.copyWith(deleteMessageState: const AppState()));
  void resetUpdateGroupState() =>
      emit(state.copyWith(updateGroupState: const AppState()));

  @override
  Future<void> close() {
    _messagesSub?.cancel();
    return super.close();
  }
}
