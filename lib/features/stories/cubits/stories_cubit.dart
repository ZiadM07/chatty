import 'dart:async';
import 'dart:io';
import 'package:Chatty/features/stories/data/models/story_item_model.dart';
import 'package:Chatty/features/stories/data/models/story_model.dart';
import 'package:Chatty/features/stories/data/repositories/story_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/framework/failure.dart';

class StoriesState extends Equatable {
  final AppState<List<StoryModel>> feedState;
  final AppState<List<StoryItemModel>> myStoryState;
  final AppState<StoryItemModel> uploadState;

  const StoriesState({
    this.feedState = const AppState(),
    this.myStoryState = const AppState(),
    this.uploadState = const AppState(),
  });

  StoriesState copyWith({
    AppState<List<StoryModel>>? feedState,
    AppState<List<StoryItemModel>>? myStoryState,
    AppState<StoryItemModel>? uploadState,
  }) => StoriesState(
    feedState: feedState ?? this.feedState,
    myStoryState: myStoryState ?? this.myStoryState,
    uploadState: uploadState ?? this.uploadState,
  );

  @override
  List<Object?> get props => [feedState, myStoryState, uploadState];
}

@injectable
class StoriesCubit extends Cubit<StoriesState> {
  final StoryRepository _repository;

  StreamSubscription<List<StoryItemModel>>? _myStorySub;
  StreamSubscription<List<StoryModel>>? _feedSub;

  StoriesCubit(this._repository) : super(const StoriesState());

  Future<void> watchMyStory({required String uid}) async {
    emit(
      state.copyWith(myStoryState: const AppState(status: StateStatus.loading)),
    );
    await _repository.deleteExpiredItems(uid: uid).catchError((_) {});

    _myStorySub?.cancel();
    _myStorySub = _repository
        .watchMyStory(uid: uid)
        .listen(
          (items) => emit(
            state.copyWith(
              myStoryState: AppState(status: StateStatus.success, data: items),
            ),
          ),
          onError: (_) => emit(
            state.copyWith(
              myStoryState: const AppState(
                status: StateStatus.error,
                message: 'Failed to load your story.',
              ),
            ),
          ),
        );
  }

  void watchFeedStories({
    required String uid,
    required List<String> contactUids,
  }) {
    if (contactUids.isEmpty) {
      emit(
        state.copyWith(
          feedState: const AppState(status: StateStatus.success, data: []),
        ),
      );
      return;
    }

    emit(
      state.copyWith(feedState: const AppState(status: StateStatus.loading)),
    );

    _feedSub?.cancel();
    _feedSub = _repository
        .watchFeedStories(uid: uid, contactUids: contactUids)
        .listen(
          (stories) {
            final unseen =
                stories.where((s) => !s.isFullyViewedBy(uid)).toList()
                  ..sort((a, b) => b.lastUpdatedAt.compareTo(a.lastUpdatedAt));

            final seen = stories.where((s) => s.isFullyViewedBy(uid)).toList()
              ..sort((a, b) => b.lastUpdatedAt.compareTo(a.lastUpdatedAt));

            emit(
              state.copyWith(
                feedState: AppState(
                  status: StateStatus.success,
                  data: [...unseen, ...seen],
                ),
              ),
            );
          },
          onError: (_) => emit(
            state.copyWith(
              feedState: const AppState(
                status: StateStatus.error,
                message: 'Failed to load stories.',
              ),
            ),
          ),
        );
  }

  Future<void> addImageStory({
    required String uid,
    required File imageFile,
    String? caption,
  }) async {
    emit(
      state.copyWith(
        uploadState: const AppState(status: StateStatus.loadingOverlay),
      ),
    );
    try {
      final item = await _repository.addImageStory(
        uid: uid,
        imageFile: imageFile,
        caption: caption,
      );
      emit(
        state.copyWith(
          uploadState: AppState(status: StateStatus.success, data: item),
        ),
      );
    } on Failure catch (e) {
      emit(
        state.copyWith(
          uploadState: AppState(status: StateStatus.error, message: e.message),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          uploadState: const AppState(
            status: StateStatus.error,
            message: 'Failed to post story.',
          ),
        ),
      );
    }
  }

  Future<void> addVideoStory({
    required String uid,
    required File videoFile,
    File? thumbnailFile,
    String? caption,
  }) async {
    emit(
      state.copyWith(
        uploadState: const AppState(status: StateStatus.loadingOverlay),
      ),
    );
    try {
      final item = await _repository.addVideoStory(
        uid: uid,
        videoFile: videoFile,
        thumbnailFile: thumbnailFile,
        caption: caption,
      );
      emit(
        state.copyWith(
          uploadState: AppState(status: StateStatus.success, data: item),
        ),
      );
    } on Failure catch (e) {
      emit(
        state.copyWith(
          uploadState: AppState(status: StateStatus.error, message: e.message),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          uploadState: const AppState(
            status: StateStatus.error,
            message: 'Failed to post video story.',
          ),
        ),
      );
    }
  }

  Future<void> addTextStory({
    required String uid,
    required String text,
    required int backgroundColor,
  }) async {
    emit(
      state.copyWith(
        uploadState: const AppState(status: StateStatus.loadingOverlay),
      ),
    );
    try {
      final item = await _repository.addTextStory(
        uid: uid,
        text: text,
        backgroundColor: backgroundColor,
      );
      emit(
        state.copyWith(
          uploadState: AppState(status: StateStatus.success, data: item),
        ),
      );
    } on Failure catch (e) {
      emit(
        state.copyWith(
          uploadState: AppState(status: StateStatus.error, message: e.message),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          uploadState: const AppState(
            status: StateStatus.error,
            message: 'Failed to post story.',
          ),
        ),
      );
    }
  }

  Future<void> deleteStoryItem({
    required String uid,
    required StoryItemModel item,
  }) async {
    try {
      await _repository.deleteStoryItem(uid: uid, item: item);
    } on Failure catch (e) {
      emit(
        state.copyWith(
          uploadState: AppState(status: StateStatus.error, message: e.message),
        ),
      );
    }
  }

  Future<void> clearMyStory({required String uid}) async {
    final items = state.myStoryState.data ?? [];
    try {
      await _repository.clearMyStory(uid: uid, items: items);
    } on Failure catch (e) {
      emit(
        state.copyWith(
          uploadState: AppState(status: StateStatus.error, message: e.message),
        ),
      );
    }
  }

  void resetUploadState() =>
      emit(state.copyWith(uploadState: const AppState()));

  @override
  Future<void> close() {
    _myStorySub?.cancel();
    _feedSub?.cancel();
    return super.close();
  }
}
