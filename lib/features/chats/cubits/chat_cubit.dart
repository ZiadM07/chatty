import 'dart:async';
import 'package:Chatty/core/framework/audio_service.dart';
import 'package:Chatty/core/framework/failure.dart';
import 'package:Chatty/core/framework/in_app_sound_service.dart';
import 'package:Chatty/core/utils/enums.dart';
import 'package:Chatty/features/chats/data/models/message_model.dart';
import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/core/di/injectable.dart';
import 'package:Chatty/features/chats/data/models/chat_model.dart';
import 'package:Chatty/features/chats/data/repositories/chat_repository.dart';
import '../../../core/framework/notification_service.dart';
import '../../users/data/repositories/users_repository.dart';

class ChatState extends Equatable {
  final ChatModel? chat;
  final AppState<ChatModel> chatState;
  final AppState<List<MessageModel>> messagesState;
  final AppState<MessageModel> sendState;
  final AppState<void> deleteMessageState;
  final AppState<void> updateGroupState;
  final MessageModel? replyingTo;
  final bool isAtBottom;

  const ChatState({
    this.chat,
    this.chatState = const AppState(),
    this.messagesState = const AppState(),
    this.sendState = const AppState(),
    this.deleteMessageState = const AppState(),
    this.updateGroupState = const AppState(),
    this.replyingTo,
    this.isAtBottom = true,
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
    bool? isAtBottom,
  }) => ChatState(
    chat: chat ?? this.chat,
    chatState: chatState ?? this.chatState,
    messagesState: messagesState ?? this.messagesState,
    sendState: sendState ?? this.sendState,
    deleteMessageState: deleteMessageState ?? this.deleteMessageState,
    updateGroupState: updateGroupState ?? this.updateGroupState,
    replyingTo: clearReplyingTo ? null : replyingTo ?? this.replyingTo,
    isAtBottom: isAtBottom ?? this.isAtBottom,
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
    isAtBottom,
  ];
}

@injectable
class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _repository;
  final NotificationService _notificationService;
  StreamSubscription<List<MessageModel>>? _messagesSub;

  bool _isFirstLoad = true;
  int _lastMessageCount = 0;
  String? _currentUid;
  String? _currentChatId;

  ChatCubit(this._repository, this._notificationService)
    : super(const ChatState());

  Future<void> init({
    required String chatId,
    required String currentUid,
  }) async {
    _currentUid = currentUid;
    _currentChatId = chatId;

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

      final patchedChat = await _patchMemberNamesIfNeeded(chat);

      emit(
        state.copyWith(
          chat: patchedChat,
          chatState: AppState(status: StateStatus.success, data: patchedChat),
          messagesState: const AppState(status: StateStatus.loading),
        ),
      );

      _watchMessages(chatId: chatId, currentUid: currentUid);
    } on Failure catch (e) {
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

  Future<ChatModel> _patchMemberNamesIfNeeded(ChatModel chat) async {
    final missingUids = chat.memberIds
        .where((uid) => chat.memberNames[uid] == null)
        .toList();

    if (missingUids.isEmpty) return chat;

    final updates = <String, String>{...chat.memberNames};
    for (final uid in missingUids) {
      final user = await getIt<UsersRepository>().getUserById(uid: uid);
      if (user != null) updates[uid] = user.displayName;
    }

    await _repository.patchMemberNames(chatId: chat.id, memberNames: updates);

    return chat.copyWith(memberNames: updates);
  }

  void _watchMessages({required String chatId, required String currentUid}) {
    _messagesSub?.cancel();
    _isFirstLoad = true;
    _lastMessageCount = 0;

    _messagesSub = _repository.watchMessages(chatId: chatId).listen(
      (messages) {
        if (_isFirstLoad) {
          _lastMessageCount = messages.length;
          _isFirstLoad = false;
          _markSeenIfAtBottom();
        } else if (messages.length > _lastMessageCount) {
          final newest = messages.last;
          final isIncoming = newest.senderId != currentUid;

          if (isIncoming) {
            getIt<InAppSoundService>().playMessageSound();

            if (state.isAtBottom) {
              _markSeenIfAtBottom();
            }
          }

          _lastMessageCount = messages.length;
        } else {
          _lastMessageCount = messages.length;
        }

        emit(
          state.copyWith(
            messagesState: AppState(
              status: StateStatus.success,
              data: messages,
            ),
          ),
        );
      },
      onError: (e) => emit(
        state.copyWith(
          messagesState: AppState(
            status: StateStatus.error,
            message: e is Failure ? e.message : 'Failed to load messages.',
          ),
        ),
      ),
    );

    _repository.markChatAsRead(chatId: chatId, uid: currentUid);
  }

  void onScrolledToBottom() {
    if (state.isAtBottom) return;
    emit(state.copyWith(isAtBottom: true));
    _markSeenIfAtBottom();
  }

  void onScrolledAway() {
    if (!state.isAtBottom) return;
    emit(state.copyWith(isAtBottom: false));
  }

  void _markSeenIfAtBottom() {
    final chatId = _currentChatId;
    final uid = _currentUid;
    if (chatId == null || uid == null) return;

    _repository
        .markMessagesSeenBy(chatId: chatId, uid: uid)
        .catchError((e) => debugPrint('⚠️ markSeenBy failed: $e'));
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
        replyToType: reply?.type,
      );

      final senderName = chat.nameFor(senderId);
      final recipientUids = chat.memberIds
          .where((id) => id != senderId)
          .toList();

      if (chat.isGroup) {
        await _notificationService.sendGroupNotification(
          senderUsername: senderName,
          recipientUids: recipientUids,
          message: content,
          chatId: chat.id,
          groupName: chat.groupName ?? 'Group',
          groupPhoto: chat.groupPhotoUrl,
        );
      } else {
        await _notificationService.sendMessageNotification(
          senderUid: senderId,
          senderUsername: senderName,
          receiverUid: recipientUids.first,
          message: content,
          chatId: chat.id,
        );
      }
    } on Failure catch (e) {
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

  Future<void> reactToMessage({
    required String messageId,
    required String? reaction,
  }) async {
    final chatId = state.chat?.id;
    final uid = _currentUid;
    if (chatId == null || uid == null) return;
    try {
      await _repository.reactToMessage(
        chatId: chatId,
        messageId: messageId,
        uid: uid,
        reaction: reaction,
      );
    } catch (_) {}
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
        replyToType: reply?.type,
      );

      final senderName = chat.nameFor(senderId);
      final recipientUids = chat.memberIds
          .where((id) => id != senderId)
          .toList();
      final mediaLabel = switch (type) {
        MessageType.image => '📷 Photo',
        MessageType.video => '🎥 Video',
        MessageType.audio => '🎵 Audio',
        MessageType.file => '📎 File',
        _ => 'Media',
      };

      if (chat.isGroup) {
        await _notificationService.sendGroupNotification(
          senderUsername: senderName,
          recipientUids: recipientUids,
          message: mediaLabel,
          chatId: chat.id,
          groupName: chat.groupName ?? 'Group',
          groupPhoto: chat.groupPhotoUrl,
        );
      } else {
        await _notificationService.sendMessageNotification(
          senderUid: senderId,
          senderUsername: senderName,
          receiverUid: recipientUids.first,
          message: mediaLabel,
          chatId: chat.id,
        );
      }

      emit(state.copyWith(sendState: const AppState()));
    } on Failure catch (e) {
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

  Future<void> sendVoiceMessage({
    required String senderId,
    required RecordingResult result,
  }) async {
    final chat = state.chat;
    if (chat == null || result.file == null) return;

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
        file: result.file!,
        type: MessageType.audio,
        metadata: {
          'duration': result.duration.inMilliseconds,
          'waveform': result.waveform,
        },
        replyToId: reply?.id,
        replyToContent: reply?.content,
        replyToSenderId: reply?.senderId,
        replyToType: reply?.type,
      );

      final senderName = chat.nameFor(senderId);
      final recipientUids = chat.memberIds
          .where((id) => id != senderId)
          .toList();

      if (chat.isGroup) {
        await _notificationService.sendGroupNotification(
          senderUsername: senderName,
          recipientUids: recipientUids,
          message: '🎤 Voice message',
          chatId: chat.id,
          groupName: chat.groupName ?? 'Group',
          groupPhoto: chat.groupPhotoUrl,
        );
      } else {
        await _notificationService.sendMessageNotification(
          senderUid: senderId,
          senderUsername: senderName,
          receiverUid: recipientUids.first,
          message: '🎤 Voice message',
          chatId: chat.id,
        );
      }

      emit(state.copyWith(sendState: const AppState()));
    } on Failure catch (e) {
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
            message: 'Failed to send voice message.',
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
    } on Failure catch (e) {
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

  Future<void> addGroupMembers({
    required List<String> newMemberIds,
    required Map<String, String> newMemberNames,
  }) async {
    final chatId = state.chat?.id;
    if (chatId == null) return;
    try {
      await _repository.addGroupMembers(
        chatId: chatId,
        newMemberIds: newMemberIds,
        newMemberNames: newMemberNames,
      );
    } on Failure catch (e) {
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
    } on Failure catch (e) {
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
    } on Failure catch (e) {
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
