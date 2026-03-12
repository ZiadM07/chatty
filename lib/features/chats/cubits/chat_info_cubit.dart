import 'dart:async';

import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/core/framework/failure.dart';
import 'package:Chatty/features/auth/data/models/user_model.dart';
import 'package:Chatty/features/chats/data/models/chat_model.dart';
import 'package:Chatty/features/chats/data/repositories/chat_repository.dart';
import 'package:Chatty/features/users/data/repositories/users_repository.dart';

class ChatInfoState extends Equatable {
  final UserModel? user;
  final ChatModel? chat;
  final AppState<UserModel> userState;
  final AppState<List<ChatModel>> commonGroupsState;
  final AppState<void> leaveGroupState;
  final AppState<ChatModel> chatState;
  final AppState<String> openChatState;
  final bool isMuted;

  const ChatInfoState({
    this.user,
    this.chat,
    this.userState = const AppState(),
    this.chatState = const AppState(),
    this.openChatState = const AppState(),
    this.commonGroupsState = const AppState(),
    this.leaveGroupState = const AppState(),
    this.isMuted = false,
  });

  ChatInfoState copyWith({
    UserModel? user,
    AppState<UserModel>? userState,
    ChatModel? chat,
    AppState<ChatModel>? chatState,
    AppState<String>? openChatState,
    AppState<List<ChatModel>>? commonGroupsState,
    AppState<void>? leaveGroupState,
    bool? isMuted,
  }) => ChatInfoState(
    user: user ?? this.user,
    userState: userState ?? this.userState,
    chat: chat ?? this.chat,
    chatState: chatState ?? this.chatState,
    openChatState: openChatState ?? this.openChatState,
    commonGroupsState: commonGroupsState ?? this.commonGroupsState,
    isMuted: isMuted ?? this.isMuted,
    leaveGroupState: leaveGroupState ?? this.leaveGroupState,
  );

  @override
  List<Object?> get props => [
    user,
    userState,
    chat,
    chatState,
    openChatState,
    commonGroupsState,
    isMuted,
    leaveGroupState,
  ];
}

@injectable
class ChatInfoCubit extends Cubit<ChatInfoState> {
  final UsersRepository _usersRepository;
  final ChatRepository _chatRepository;
  final AppPreferences _prefs;

  StreamSubscription<UserModel?>? _userSub;
  StreamSubscription<ChatModel?>? _chatSub;

  ChatInfoCubit(this._usersRepository, this._chatRepository, this._prefs)
    : super(const ChatInfoState());

  void watchUser({required String uid}) {
    emit(
      state.copyWith(userState: const AppState(status: StateStatus.loading)),
    );
    _userSub?.cancel();
    _userSub = _usersRepository.watchUser(uid: uid).listen(
      (user) {
        if (user == null) {
          emit(
            state.copyWith(
              userState: const AppState(
                status: StateStatus.error,
                message: 'User not found.',
              ),
            ),
          );
          return;
        }
        emit(
          state.copyWith(
            user: user,
            userState: AppState(status: StateStatus.success, data: user),
          ),
        );
      },
      onError: (e) => emit(
        state.copyWith(
          userState: AppState(
            status: StateStatus.error,
            message: e is Failure ? e.message : 'Failed to load user.',
          ),
        ),
      ),
    );
  }

  void watchChat({required String chatId}) {
    emit(
      state.copyWith(
        chatState: const AppState(status: StateStatus.loading),
        isMuted: _prefs.isChatMuted(chatId),
      ),
    );
    _chatSub?.cancel();
    _chatSub = _chatRepository.watchChat(chatId: chatId).listen(
      (chat) {
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
          ),
        );
      },
      onError: (e) => emit(
        state.copyWith(
          chatState: AppState(
            status: StateStatus.error,
            message: e is Failure ? e.message : 'Failed to load chat.',
          ),
        ),
      ),
    );
  }

  Future<void> openOrCreateChat({
    required String currentUid,
    required String otherUid,
  }) async {
    emit(
      state.copyWith(
        openChatState: const AppState(status: StateStatus.loading),
      ),
    );
    try {
      final currentUser = await _usersRepository.getUserById(uid: currentUid);
      final otherUser = await _usersRepository.getUserById(uid: otherUid);

      final chat = await _chatRepository.openOrCreateOneToOneChat(
        uid: currentUid,
        otherUid: otherUid,
        uidName: currentUser?.displayName ?? currentUid,
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

  Future<void> addGroupMembers({
    required String chatId,
    required List<String> newMemberIds,
    required Map<String, String> newMemberNames,
  }) async {
    try {
      await _chatRepository.addGroupMembers(
        chatId: chatId,
        newMemberIds: newMemberIds,
        newMemberNames: newMemberNames,
      );
    } on Failure catch (e) {
      emit(
        state.copyWith(
          chatState: AppState(status: StateStatus.error, message: e.message),
        ),
      );
    } catch (_) {}
  }

  void resetOpenChatState() =>
      emit(state.copyWith(openChatState: const AppState()));

  void toggleMute() {
    final chatId = state.chat?.id;
    if (chatId == null) return;

    _prefs.toggleMuteChatId(chatId);
    emit(state.copyWith(isMuted: _prefs.isChatMuted(chatId)));
    kPrint('isMuted: ${state.isMuted}');
  }

  Future<void> updateGroupInfo({
    required String chatId,
    String? groupName,
    File? groupPhotoFile,
    String? oldGroupPhotoUrl,
    String? groupDescription,
  }) async {
    try {
      await _chatRepository.updateGroupInfo(
        chatId: chatId,
        groupName: groupName,
        groupPhotoFile: groupPhotoFile,
        oldGroupPhotoUrl: oldGroupPhotoUrl,
        groupDescription: groupDescription,
      );
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
            message: 'Failed to update group.',
          ),
        ),
      );
    }
  }

  Future<void> removeGroupMember({
    required String chatId,
    required String memberId,
  }) async {
    try {
      await _chatRepository.removeGroupMember(
        chatId: chatId,
        memberId: memberId,
      );
    } on Failure catch (e) {
      emit(
        state.copyWith(
          chatState: AppState(status: StateStatus.error, message: e.message),
        ),
      );
    } catch (_) {}
  }

  Future<void> loadCommonGroups({
    required String currentUid,
    required String otherUid,
  }) async {
    emit(
      state.copyWith(
        commonGroupsState: const AppState(status: StateStatus.loading),
      ),
    );

    try {
      final groups = await _usersRepository.getCommonGroups(
        currentUid: currentUid,
        otherUid: otherUid,
      );

      emit(
        state.copyWith(
          commonGroupsState: AppState(
            status: StateStatus.success,
            data: groups,
          ),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          commonGroupsState: AppState(
            status: StateStatus.error,
            message: 'Failed to load common groups.',
          ),
        ),
      );
    }
  }

  Future<void> leaveGroup({
    required String currentUid,
    required List<String> memberIds,
  }) async {
    final chat = state.chat;
    if (chat == null) return;

    emit(
      state.copyWith(
        leaveGroupState: const AppState(status: StateStatus.loading),
      ),
    );

    try {
      final isOwner = chat.groupCreatedBy == currentUid;

      if (isOwner) {
        final nextOwner = memberIds.firstWhere(
          (id) => id != currentUid,
          orElse: () => '',
        );

        if (nextOwner.isEmpty) {
          await _chatRepository.deleteChat(chatId: chat.id);
        } else {
          await _chatRepository.transferOwnershipAndLeave(
            chatId: chat.id,
            newOwnerUid: nextOwner,
            currentOwnerUid: currentUid,
          );
        }
      } else {
        await _chatRepository.leaveGroup(chatId: chat.id, uid: currentUid);
      }

      emit(
        state.copyWith(
          leaveGroupState: const AppState(status: StateStatus.success),
        ),
      );
    } on Failure catch (e) {
      emit(
        state.copyWith(
          leaveGroupState: AppState(
            status: StateStatus.error,
            message: e.message,
          ),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          leaveGroupState: const AppState(
            status: StateStatus.error,
            message: 'Failed to leave group.',
          ),
        ),
      );
    }
  }

  void resetLeaveGroupState() =>
      emit(state.copyWith(leaveGroupState: const AppState()));

  @override
  Future<void> close() {
    _userSub?.cancel();
    _chatSub?.cancel();
    return super.close();
  }
}
