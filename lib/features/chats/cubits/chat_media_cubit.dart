import 'package:chatty/core/constants/exports.dart';
import 'package:chatty/core/utils/enums.dart';
import 'package:chatty/features/chats/data/data_source/chat_data_source.dart';
import 'package:chatty/features/chats/data/models/message_model.dart';
import 'package:chatty/features/chats/data/repositories/chat_repository.dart';

// ─── State ────────────────────────────────────────────────────────────────────

class ChatMediaState extends Equatable {
  final AppState<List<MessageModel>> mediaState;
  final MessageType? selectedType; // null = all media
  final bool hasMore;
  final String? lastMessageId;
  final int count;

  const ChatMediaState({
    this.mediaState = const AppState(),
    this.selectedType,
    this.hasMore = true,
    this.lastMessageId,
    this.count = 0,
  });

  List<MessageModel> get media => mediaState.data ?? [];

  ChatMediaState copyWith({
    AppState<List<MessageModel>>? mediaState,
    MessageType? selectedType,
    bool? hasMore,
    String? lastMessageId,
    bool clearType = false,
    int? count,
  }) => ChatMediaState(
    count: count ?? this.count,
    mediaState: mediaState ?? this.mediaState,
    selectedType: clearType ? null : selectedType ?? this.selectedType,
    hasMore: hasMore ?? this.hasMore,
    lastMessageId: lastMessageId ?? this.lastMessageId,
  );

  @override
  List<Object?> get props => [
    mediaState,
    selectedType,
    hasMore,
    lastMessageId,
    count,
  ];
}

// ─── Cubit ────────────────────────────────────────────────────────────────────

@injectable
class ChatMediaCubit extends Cubit<ChatMediaState> {
  final ChatRepository _repository;

  ChatMediaCubit(this._repository) : super(const ChatMediaState());

  // ─── Load Media ───────────────────────────────────────────────────────────

  Future<void> loadMedia({required String chatId, MessageType? type}) async {
    emit(
      state.copyWith(
        mediaState: const AppState(status: StateStatus.loading),
        selectedType: type,
        clearType: type == null,
      ),
    );

    try {
      final messages = await _repository.getMediaMessages(
        chatId: chatId,
        type: type,
        limit: 30,
      );

      emit(
        state.copyWith(
          mediaState: AppState(status: StateStatus.success, data: messages),
          hasMore: messages.length >= 30,
          lastMessageId: messages.isEmpty ? null : messages.last.id,
        ),
      );
    } on ChatException catch (e) {
      emit(
        state.copyWith(
          mediaState: AppState(status: StateStatus.error, message: e.message),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          mediaState: const AppState(
            status: StateStatus.error,
            message: 'Failed to load media.',
          ),
        ),
      );
    }
  }

  // ─── Load More ────────────────────────────────────────────────────────────

  Future<void> loadMore({required String chatId}) async {
    if (!state.hasMore || state.mediaState.isLoading) return;

    try {
      final newMessages = await _repository.getMediaMessages(
        chatId: chatId,
        type: state.selectedType,
        limit: 30,
        lastMessageId: state.lastMessageId,
      );

      final allMessages = [...state.media, ...newMessages];

      emit(
        state.copyWith(
          mediaState: AppState(status: StateStatus.success, data: allMessages),
          hasMore: newMessages.length >= 30,
          lastMessageId: newMessages.isEmpty
              ? state.lastMessageId
              : newMessages.last.id,
        ),
      );
    } catch (_) {
      // Silent fail on pagination - keep existing data
    }
  }

  Future<void> changeType({
    required String chatId,
    required MessageType? type,
  }) async {
    if (state.selectedType == type) return;
    await loadMedia(chatId: chatId, type: type);
  }

  Future<void> loadCount({required String chatId}) async {
    emit(
      state.copyWith(mediaState: const AppState(status: StateStatus.loading)),
    );

    try {
      final messages = await _repository.getMediaMessages(
        chatId: chatId,
        type: null,
        limit: 100,
      );

      emit(
        state.copyWith(
          count: messages.length,
          mediaState: const AppState(status: StateStatus.success),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          count: 0,
          mediaState: const AppState(status: StateStatus.error),
        ),
      );
    }
  }
}
