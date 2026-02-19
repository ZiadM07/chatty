import 'dart:io';
import 'package:chatty/core/utils/enums.dart';
import 'package:chatty/features/chats/data/repositories/chat_repository.dart';
import 'package:chatty/features/stories/data/data_sources/story_data_source.dart';
import 'package:chatty/features/stories/data/models/story_item_model.dart';
import 'package:chatty/features/stories/data/models/story_model.dart';
import 'package:chatty/features/users/data/repositories/users_repository.dart';
import 'package:injectable/injectable.dart';
import '../../../shared/data/storage_data_source.dart';


// ─── Storage paths ────────────────────────────────────────────────────────────

class _StoryPaths {
  static String image(String uid) => 'stories/$uid/images';
  static String video(String uid) => 'stories/$uid/videos';
}

// ─── Repository ───────────────────────────────────────────────────────────────
//
//  Single responsibility contract:
//   - StoryDataSource  → Firestore reads/writes
//   - StorageDataSource → Supabase file uploads/deletes
//   - UsersRepository   → resolving display info for StoryModel assembly
//
//  The cubit only talks to this class — never to data sources directly.
// ─────────────────────────────────────────────────────────────────────────────

@lazySingleton
class StoryRepository {
  final StoryDataSource _dataSource;
  final StorageDataSource _storage;
  final UsersRepository _users;
  final ChatRepository _chat;

  const StoryRepository(this._dataSource, this._storage, this._users, this._chat);

  // ─── Watch My Story ───────────────────────────────────────────────────────

  Stream<List<StoryItemModel>> watchMyStory({required String uid}) =>
      _dataSource.watchMyStory(uid: uid);

  // ─── Watch Feed Stories ───────────────────────────────────────────────────
  //
  //  Assembles full [StoryModel] objects by joining Firestore items with
  //  user display info. We resolve user info once and cache per uid.
  // ─────────────────────────────────────────────────────────────────────────

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

        // Resolve display info — getUserById is cached in UsersRepository
        final user = await _users.getUserById(uid: ownerUid);

        stories.add(StoryModel(
          uid: ownerUid,
          displayName: user?.displayName ?? ownerUid,
          photoUrl: user?.photoUrl,
          items: items,
        ));
      }

      // Sort: unseen first, then by most recently updated
      // (stories with all-seen items go to the end)
      return stories;
    });
  }

  // ─── Get Story for a specific user ───────────────────────────────────────

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

  // ─── Add Image Story ──────────────────────────────────────────────────────

  Future<StoryItemModel> addImageStory({
    required String uid,
    required File imageFile,
    String? caption,
  }) async {
    // 1. Upload to Supabase
    final url = await _storage.uploadFile(
      file: imageFile,
      path: _StoryPaths.image(uid),
    );

    // 2. Write to Firestore
    return _dataSource.addStoryItem(
      uid: uid,
      type: StoryItemType.image,
      url: url,
      caption: caption,
    );
  }

  // ─── Add Video Story ──────────────────────────────────────────────────────

  Future<StoryItemModel> addVideoStory({
    required String uid,
    required File videoFile,
    File? thumbnailFile,
    String? caption,
  }) async {
    // 1. Upload video to Supabase videos bucket
    final videoUrl = await _storage.uploadVideo(
      file: videoFile,
      path: _StoryPaths.video(uid),
    );

    // 2. Upload thumbnail if provided (images bucket)
    String? thumbnailUrl;
    if (thumbnailFile != null) {
      thumbnailUrl = await _storage.uploadFile(
        file: thumbnailFile,
        path: _StoryPaths.image(uid),
      );
    }

    // 3. Write to Firestore
    return _dataSource.addStoryItem(
      uid: uid,
      type: StoryItemType.video,
      url: videoUrl,
      thumbnailUrl: thumbnailUrl,
      caption: caption,
    );
  }

  // ─── Add Text Story ───────────────────────────────────────────────────────

  Future<StoryItemModel> addTextStory({
    required String uid,
    required String text,
    required int backgroundColor, // Color.value int
  }) async {
    return _dataSource.addStoryItem(
      uid: uid,
      type: StoryItemType.text,
      url: '', // no media for text stories
      caption: text,
      backgroundColor: backgroundColor,
    );
  }

  // ─── Mark Viewed ─────────────────────────────────────────────────────────

  Future<void> markItemViewed({
    required String ownerUid,
    required String itemId,
    required String viewerUid,
  }) {
    // Don't mark your own items as viewed
    if (ownerUid == viewerUid) return Future.value();
    return _dataSource.markItemViewed(
      ownerUid: ownerUid,
      itemId: itemId,
      viewerUid: viewerUid,
    );
  }

  // ─── Toggle Like ─────────────────────────────────────────────────────────

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

  // ─── Reply to Story ───────────────────────────────────────────────────────
  //
  //  Opens (or creates) a 1-to-1 chat with the story owner, then sends a
  //  message that references the story item as a reply context so the
  //  owner sees what was being replied to.
  // ─────────────────────────────────────────────────────────────────────────

  Future<String> replyToStory({
    required String senderUid,
    required String ownerUid,
    required StoryItemModel item,
    required String replyText,
  }) async {
    // Open or create the 1-to-1 chat
    final chat = await _chat.openOrCreateOneToOneChat(
      uid: senderUid,
      otherUid: ownerUid,
    );

    // Build a preview of the story item for the reply header
    final storyPreview = item.type == StoryItemType.text
        ? item.caption ?? '📝 Story'
        : item.type == StoryItemType.image
            ? '📷 Photo story'
            : '🎥 Video story';

    // Send the reply as a regular message with story context in the reply fields
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

  // ─── Delete Item ──────────────────────────────────────────────────────────
  //
  //  Deletes both the Firestore doc and the Supabase file.
  //  Fire-and-forget on storage delete — the Firestore delete is the
  //  source of truth for what's visible.
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> deleteStoryItem({
    required String uid,
    required StoryItemModel item,
  }) async {
    // Delete Firestore document first
    await _dataSource.deleteStoryItem(uid: uid, itemId: item.id);

    // Delete from storage (fire-and-forget — don't fail if this errors)
    if (item.url.isNotEmpty) {
      _storage.deleteFile(path: item.url).catchError((_) {});
    }
    if (item.thumbnailUrl != null && item.thumbnailUrl!.isNotEmpty) {
      _storage.deleteFile(path: item.thumbnailUrl!).catchError((_) {});
    }
  }

  // ─── Clear My Story ───────────────────────────────────────────────────────

  Future<void> clearMyStory({
    required String uid,
    required List<StoryItemModel> items,
  }) async {
    // Delete all storage files concurrently (fire-and-forget)
    for (final item in items) {
      if (item.url.isNotEmpty) {
        _storage.deleteFile(path: item.url).catchError((_) {});
      }
      if (item.thumbnailUrl != null && item.thumbnailUrl!.isNotEmpty) {
        _storage.deleteFile(path: item.thumbnailUrl!).catchError((_) {});
      }
    }

    // Delete all Firestore docs
    await _dataSource.clearMyStory(uid: uid);
  }

  // ─── Cleanup expired ──────────────────────────────────────────────────────
  //
  //  Called on app resume / stories screen open to prune expired items.
  //  Storage files are orphaned until the user next uploads — acceptable
  //  since Supabase can have lifecycle policies on the stories bucket.
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> deleteExpiredItems({required String uid}) =>
      _dataSource.deleteExpiredItems(uid: uid);
}