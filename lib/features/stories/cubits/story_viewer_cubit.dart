import 'package:chatty/features/stories/data/data_sources/story_data_source.dart';
import 'package:chatty/features/stories/data/models/story_item_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/state/app_state.dart';
import '../data/models/story_model.dart';
import '../data/repositories/story_repository.dart';

// ─── State ────────────────────────────────────────────────────────────────────

class StoryViewerState extends Equatable {
  /// The story currently being displayed.
  final StoryModel? story;

  /// Index of the currently active item within [story.items].
  final int currentIndex;

  /// Whether the story is paused (e.g. user holding down).
  final bool isPaused;

  /// Fetch state — loading while resolving the story from repository.
  final AppState<StoryModel> storyState;

  /// Reply send state — drives the reply input loading indicator.
  final AppState<String> replyState; // data = chatId on success

  const StoryViewerState({
    this.story,
    this.currentIndex = 0,
    this.isPaused = false,
    this.storyState = const AppState(),
    this.replyState = const AppState(),
  });

  StoryItemModel? get currentItem {
    final items = story?.items;
    if (items == null || items.isEmpty) return null;
    if (currentIndex >= items.length) return null;
    return items[currentIndex];
  }

  bool get isFirstItem => currentIndex == 0;
  bool get isLastItem =>
      story == null || currentIndex >= (story!.items.length - 1);

  StoryViewerState copyWith({
    StoryModel? story,
    int? currentIndex,
    bool? isPaused,
    AppState<StoryModel>? storyState,
    AppState<String>? replyState,
  }) => StoryViewerState(
    story: story ?? this.story,
    currentIndex: currentIndex ?? this.currentIndex,
    isPaused: isPaused ?? this.isPaused,
    storyState: storyState ?? this.storyState,
    replyState: replyState ?? this.replyState,
  );

  @override
  List<Object?> get props => [
    story,
    currentIndex,
    isPaused,
    storyState,
    replyState,
  ];
}

// ─── Cubit ────────────────────────────────────────────────────────────────────
//
//  Provided at route level via AutoRouteWrapper — one instance per viewer session.
//  The viewer screen passes [ownerUid] + [currentUid] on open.
//  Starting index = first unseen item so viewers resume naturally.
// ─────────────────────────────────────────────────────────────────────────────

@injectable
class StoryViewerCubit extends Cubit<StoryViewerState> {
  final StoryRepository _repository;

  StoryViewerCubit(this._repository) : super(const StoryViewerState());

  // ─── Load Story ───────────────────────────────────────────────────────────

  Future<void> loadStory({
    required String ownerUid,
    required String currentUid,
  }) async {
    emit(
      state.copyWith(storyState: const AppState(status: StateStatus.loading)),
    );

    try {
      final story = await _repository.getStory(
        ownerUid: ownerUid,
        currentUid: currentUid,
      );

      if (story == null || story.items.isEmpty) {
        emit(
          state.copyWith(
            storyState: const AppState(
              status: StateStatus.error,
              message: 'No active story.',
            ),
          ),
        );
        return;
      }

      final startIndex = story.firstUnseenIndex(currentUid);

      emit(
        state.copyWith(
          story: story,
          currentIndex: startIndex,
          storyState: AppState(status: StateStatus.success, data: story),
        ),
      );

      // Mark the first item as viewed immediately
      _markCurrentViewed(currentUid);
    } on StoryException catch (e) {
      emit(
        state.copyWith(
          storyState: AppState(status: StateStatus.error, message: e.message),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          storyState: const AppState(
            status: StateStatus.error,
            message: 'Failed to load story.',
          ),
        ),
      );
    }
  }

  // ─── Navigation ───────────────────────────────────────────────────────────

  /// Move to next item. Returns false if this was the last item (viewer should close).
  bool nextItem({required String currentUid}) {
    if (state.isLastItem) return false;

    emit(state.copyWith(currentIndex: state.currentIndex + 1));
    _markCurrentViewed(currentUid);
    return true;
  }

  /// Move to previous item. No-op if already at first.
  void previousItem() {
    if (state.isFirstItem) return;
    emit(state.copyWith(currentIndex: state.currentIndex - 1));
  }

  // ─── Pause / Resume ───────────────────────────────────────────────────────

  void pause() => emit(state.copyWith(isPaused: true));
  void resume() => emit(state.copyWith(isPaused: false));

  // ─── Mark viewed ─────────────────────────────────────────────────────────
  //
  //  Fire-and-forget — we never block UI on this.
  // ─────────────────────────────────────────────────────────────────────────

  void _markCurrentViewed(String currentUid) {
    final item = state.currentItem;
    final story = state.story;
    if (item == null || story == null) return;

    _repository
        .markItemViewed(
          ownerUid: story.uid,
          itemId: item.id,
          viewerUid: currentUid,
        )
        .catchError((_) {});
  }

  /// Manually mark a specific item as viewed (e.g. after timer completes).
  void markItemViewed({required String currentUid, required String itemId}) {
    final story = state.story;
    if (story == null) return;

    _repository
        .markItemViewed(
          ownerUid: story.uid,
          itemId: itemId,
          viewerUid: currentUid,
        )
        .catchError((_) {});
  }

  // ─── Toggle Like ─────────────────────────────────────────────────────────
  //
  //  Optimistic: we don't block the UI, fire-and-forget.
  // ─────────────────────────────────────────────────────────────────────────

  void toggleLike({required String viewerUid}) {
    final item = state.currentItem;
    final story = state.story;
    if (item == null || story == null) return;
    // Don't like your own story
    if (story.uid == viewerUid) return;

    final isLiked = item.isLikedBy(viewerUid);

    _repository
        .toggleLike(
          ownerUid: story.uid,
          itemId: item.id,
          viewerUid: viewerUid,
          isLiked: isLiked,
        )
        .catchError((_) {});
  }

  // ─── Reply to Story ───────────────────────────────────────────────────────

  Future<void> replyToStory({
    required String senderUid,
    required String replyText,
  }) async {
    final item = state.currentItem;
    final story = state.story;
    if (item == null || story == null || replyText.trim().isEmpty) return;

    emit(
      state.copyWith(replyState: const AppState(status: StateStatus.loading)),
    );
    try {
      final chatId = await _repository.replyToStory(
        senderUid: senderUid,
        ownerUid: story.uid,
        item: item,
        replyText: replyText.trim(),
      );
      emit(
        state.copyWith(
          replyState: AppState(status: StateStatus.success, data: chatId),
        ),
      );
    } on StoryException catch (e) {
      emit(
        state.copyWith(
          replyState: AppState(status: StateStatus.error, message: e.message),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          replyState: const AppState(
            status: StateStatus.error,
            message: 'Failed to send reply.',
          ),
        ),
      );
    }
  }

  void resetReplyState() => emit(state.copyWith(replyState: const AppState()));
}
