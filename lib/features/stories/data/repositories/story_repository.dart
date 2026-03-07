import 'dart:io';
import 'package:Chatty/core/utils/enums.dart';
import 'package:Chatty/features/chats/data/repositories/chat_repository.dart';
import 'package:Chatty/features/stories/data/data_sources/story_data_source.dart';
import 'package:Chatty/features/stories/data/models/story_item_model.dart';
import 'package:Chatty/features/stories/data/models/story_model.dart';
import 'package:Chatty/features/users/data/repositories/users_repository.dart';
import 'package:injectable/injectable.dart';
import '../../../shared/data/data_sources/storage_data_source.dart';

class _StoryPaths {
  static String image(String uid) => 'stories/$uid/images';
  static String video(String uid) => 'stories/$uid/videos';
}

@lazySingleton
class StoryRepository {
  final StoryDataSource _dataSource;
  final StorageDataSource _storage;
  final UsersRepository _users;
  final ChatRepository _chat;

  const StoryRepository(
    this._dataSource,
    this._storage,
    this._users,
    this._chat,
  );

  Stream<List<StoryItemModel>> watchMyStory({required String uid}) =>
      _dataSource.watchMyStory(uid: uid);

  Stream<List<StoryModel>> watchFeedStories({
    required String uid,
    required List<String> contactUids,
  }) {
    return _dataSource
        .watchFeedStories(uid: uid, contactUids: contactUids)
        .asyncMap((itemsMap) async {
          final stories = <StoryModel>[];

          for (final entry in itemsMap.entries) {
            final ownerUid = entry.key;
            final items = entry.value;
            if (items.isEmpty) continue;

            final user = await _users.getUserById(uid: ownerUid);

            stories.add(
              StoryModel(
                uid: ownerUid,
                displayName: user?.displayName ?? ownerUid,
                photoUrl: user?.photoUrl,
                items: items,
              ),
            );
          }
          return stories;
        });
  }

  Future<StoryModel?> getStory({
    required String ownerUid,
    required String currentUid,
  }) async {
    final items = await _dataSource.getStoryItems(uid: ownerUid);
    if (items.isEmpty) return null;

    final user = await _users.getUserById(uid: ownerUid);
    return StoryModel(
      uid: ownerUid,
      displayName: user?.displayName ?? ownerUid,
      photoUrl: user?.photoUrl,
      items: items,
    );
  }

  Future<StoryItemModel> addImageStory({
    required String uid,
    required File imageFile,
    String? caption,
  }) async {
    final url = await _storage.uploadFile(
      file: imageFile,
      path: _StoryPaths.image(uid),
    );

    return _dataSource.addStoryItem(
      uid: uid,
      type: StoryItemType.image,
      url: url,
      caption: caption,
    );
  }

  Future<StoryItemModel> addVideoStory({
    required String uid,
    required File videoFile,
    File? thumbnailFile,
    String? caption,
  }) async {
    final videoUrl = await _storage.uploadVideo(
      file: videoFile,
      path: _StoryPaths.video(uid),
    );

    String? thumbnailUrl;
    if (thumbnailFile != null) {
      thumbnailUrl = await _storage.uploadFile(
        file: thumbnailFile,
        path: _StoryPaths.image(uid),
      );
    }

    return _dataSource.addStoryItem(
      uid: uid,
      type: StoryItemType.video,
      url: videoUrl,
      thumbnailUrl: thumbnailUrl,
      caption: caption,
    );
  }

  Future<StoryItemModel> addTextStory({
    required String uid,
    required String text,
    required int backgroundColor,
  }) async {
    return _dataSource.addStoryItem(
      uid: uid,
      type: StoryItemType.text,
      url: '',
      caption: text,
      backgroundColor: backgroundColor,
    );
  }

  Future<void> markItemViewed({
    required String ownerUid,
    required String itemId,
    required String viewerUid,
  }) {
    if (ownerUid == viewerUid) return Future.value();
    return _dataSource.markItemViewed(
      ownerUid: ownerUid,
      itemId: itemId,
      viewerUid: viewerUid,
    );
  }

  Future<void> toggleLike({
    required String ownerUid,
    required String itemId,
    required String viewerUid,
    required bool isLiked,
  }) => _dataSource.toggleLike(
    ownerUid: ownerUid,
    itemId: itemId,
    viewerUid: viewerUid,
    isLiked: isLiked,
  );

  Future<String> replyToStory({
    required String senderUid,
    required String ownerUid,
    required StoryItemModel item,
    required String replyText,
  }) async {
    final senderUser = await _users.getUserById(uid: senderUid);
    final ownerUser = await _users.getUserById(uid: ownerUid);

    final chat = await _chat.openOrCreateOneToOneChat(
      uid: senderUid,
      otherUid: ownerUid,
      uidName: senderUser?.displayName ?? senderUid,
      otherUidName: ownerUser?.displayName ?? ownerUid,
    );

    final storyPreview = item.type == StoryItemType.text
        ? item.caption ?? '📝 Story'
        : item.type == StoryItemType.image
        ? '📷 Photo story'
        : '🎥 Video story';

    await _chat.sendTextMessage(
      chatId: chat.id,
      senderId: senderUid,
      memberIds: chat.memberIds,
      content: replyText,
      replyToId: item.id,
      replyToContent: storyPreview,
      replyToSenderId: ownerUid,
    );

    return chat.id;
  }

  Future<void> deleteStoryItem({
    required String uid,
    required StoryItemModel item,
  }) async {
    await _dataSource.deleteStoryItem(uid: uid, itemId: item.id);
    if (item.url.isNotEmpty) {
      _storage.deleteFile(path: item.url).catchError((_) {});
    }
    if (item.thumbnailUrl != null && item.thumbnailUrl!.isNotEmpty) {
      _storage.deleteFile(path: item.thumbnailUrl!).catchError((_) {});
    }
  }

  Future<void> clearMyStory({
    required String uid,
    required List<StoryItemModel> items,
  }) async {
    for (final item in items) {
      if (item.url.isNotEmpty) {
        _storage.deleteFile(path: item.url).catchError((_) {});
      }
      if (item.thumbnailUrl != null && item.thumbnailUrl!.isNotEmpty) {
        _storage.deleteFile(path: item.thumbnailUrl!).catchError((_) {});
      }
    }

    await _dataSource.clearMyStory(uid: uid);
  }

  Future<void> deleteExpiredItems({required String uid}) =>
      _dataSource.deleteExpiredItems(uid: uid);
}
