import 'package:chatty/core/constants/exports.dart';
import 'package:chatty/features/auth/data/models/user_model.dart';
import 'package:chatty/features/chats/data/data_source/chat_data_source.dart';
import 'package:chatty/features/chats/data/repositories/chat_repository.dart';
import 'package:chatty/features/users/data/data_sources/users_data_source.dart';
import 'package:chatty/features/users/data/repositories/users_repository.dart';
import 'package:chatty/features/users/cubits/user_info_state.dart';
import 'dart:async';

@injectable
class UserInfoCubit extends Cubit<UserInfoState> {
  final UsersRepository _usersRepository;
  final ChatRepository _chatRepository;
  StreamSubscription<UserModel?>? _userSub;

  UserInfoCubit(this._usersRepository, this._chatRepository)
    : super(const UserInfoState());

  // ─── Watch User ───────────────────────────────────────────────────────────

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
            message: e is UsersException ? e.message : 'Failed to load user.',
          ),
        ),
      ),
    );
  }

  // ─── Open or Create Chat ──────────────────────────────────────────────────
  //
  //  Returns only the chatId — the route uses it to push ChatRoute(chatId:)
  //  and ChatCubit fetches the full document live. No stale model passed around.
  // ─────────────────────────────────────────────────────────────────────────

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
      final chat = await _chatRepository.openOrCreateOneToOneChat(
        uid: currentUid,
        otherUid: otherUid,
      );

      // Store only the id — not the full model
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

  void resetOpenChatState() =>
      emit(state.copyWith(openChatState: const AppState()));

  @override
  Future<void> close() {
    _userSub?.cancel();
    return super.close();
  }
}
