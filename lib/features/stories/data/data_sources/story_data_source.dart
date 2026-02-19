import 'package:chatty/core/constants/exports.dart';
import 'package:chatty/core/utils/enums.dart';
import 'package:chatty/features/stories/data/models/story_item_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class StoryDataSource {
  // ─── Watch ────────────────────────────────────────────────────────────────

  /// Real-time stream of all active (non-expired) story items for [uid].
  /// Sorted by createdAt ascending.
  Stream<List<StoryItemModel>> watchMyStory({required String uid});

  /// Real-time stream of stories from all users that [uid] follows / contacts.
  /// Returns one [StoryItemModel] list per user uid — caller assembles
  /// [StoryModel] objects with user display info.
  /// Ordered by most recently updated first.
  Stream<Map<String, List<StoryItemModel>>> watchFeedStories({
    required String uid,
    required List<String> contactUids,
  });

  // ─── Read ─────────────────────────────────────────────────────────────────

  /// Fetch all active story items for a specific user — used when opening
  /// a story viewer for a single user.
  Future<List<StoryItemModel>> getStoryItems({required String uid});

  // ─── Write ────────────────────────────────────────────────────────────────

  /// Add a new item to [uid]'s story. The [url] is the Supabase public URL
  /// already uploaded by the repository before calling this.
  Future<StoryItemModel> addStoryItem({
    required String uid,
    required StoryItemType type,
    required String url,
    String? caption,
    String? thumbnailUrl,
    int? backgroundColor,
  });

  /// Mark a story item as viewed by [viewerUid].
  /// Uses arrayUnion so concurrent viewers don't overwrite each other.
  Future<void> markItemViewed({
    required String ownerUid,
    required String itemId,
    required String viewerUid,
  });

  /// Toggle like on a story item — adds uid if not present, removes if already liked.
  /// Uses arrayUnion / arrayRemove so concurrent likes don't conflict.
  Future<void> toggleLike({
    required String ownerUid,
    required String itemId,
    required String viewerUid,
    required bool isLiked, // current state BEFORE toggle
  });

  /// Delete a single story item (owner only).
  Future<void> deleteStoryItem({required String uid, required String itemId});

  /// Delete ALL story items for [uid] — called on logout or manual clear.
  Future<void> clearMyStory({required String uid});

  /// Called by a background job / Cloud Function — deletes all expired items.
  /// In the client we only call this for the current user's own items.
  Future<void> deleteExpiredItems({required String uid});
}

// ─── Firestore paths ──────────────────────────────────────────────────────────
//
//  stories/{uid}/items/{itemId}
//
//  Each user has a document in `stories` collection.
//  Their items live in the `items` sub-collection.
//  This keeps security rules simple: only the owner writes, everyone reads.
// ─────────────────────────────────────────────────────────────────────────────

@LazySingleton(as: StoryDataSource)
class StoryDataSourceImpl implements StoryDataSource {
  final FirebaseFirestore _firestore;

  const StoryDataSourceImpl(this._firestore);

  // ─── Collection helpers ───────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> _items(String uid) =>
      _firestore.collection('stories').doc(uid).collection('items');

  // ─── Active items filter ──────────────────────────────────────────────────
  //
  //  Firestore can't do "expiresAt > now" in a real-time stream cheaply
  //  without a composite index per user. Instead we:
  //    1. Query items where expiresAt > now (uses index below)
  //    2. Filter client-side as a safety net
  // ─────────────────────────────────────────────────────────────────────────

  Query<Map<String, dynamic>> _activeItemsQuery(String uid) => _items(uid)
      .where('expiresAt', isGreaterThan: Timestamp.now())
      .orderBy('expiresAt') // required when filtering on expiresAt
      .orderBy('createdAt');

  // ─── Watch My Story ───────────────────────────────────────────────────────

  @override
  Stream<List<StoryItemModel>> watchMyStory({required String uid}) {
    return _activeItemsQuery(uid).snapshots().map(
      (snap) => snap.docs
          .map((d) => StoryItemModel.fromFirestore(d.data(), d.id))
          .where((item) => !item.isExpired) // client-side safety net
          .toList(),
    );
  }

  // ─── Watch Feed Stories ───────────────────────────────────────────────────
  //
  //  We listen to each contact's items sub-collection individually and merge
  //  results into a Map<uid, List<StoryItemModel>>. This is simpler than a
  //  collection-group query and avoids cross-user security issues.
  //
  //  Returns a Stream that replays whenever any contact's story changes.
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Stream<Map<String, List<StoryItemModel>>> watchFeedStories({
    required String uid,
    required List<String> contactUids,
  }) {
    if (contactUids.isEmpty) {
      return Stream.value({});
    }

    // Combine streams from each contact using Firestore snapshots
    // We use rxdart-free approach: track latest value per uid manually
    return _firestore
        .collectionGroup('items')
        .where(
          'uid',
          whereIn: contactUids.take(30).toList(),
        ) // Firestore whereIn limit = 30
        .where('expiresAt', isGreaterThan: Timestamp.now())
        .orderBy('expiresAt')
        .orderBy('createdAt')
        .snapshots()
        .map((snap) {
          final Map<String, List<StoryItemModel>> result = {};
          for (final doc in snap.docs) {
            final item = StoryItemModel.fromFirestore(doc.data(), doc.id);
            if (item.isExpired || item.uid == uid) {
              continue; // skip own & expired
            }
            result.putIfAbsent(item.uid, () => []).add(item);
          }
          return result;
        });
  }

  // ─── Get Story Items ──────────────────────────────────────────────────────

  @override
  Future<List<StoryItemModel>> getStoryItems({required String uid}) async {
    try {
      final snap = await _activeItemsQuery(uid).get();
      return snap.docs
          .map((d) => StoryItemModel.fromFirestore(d.data(), d.id))
          .where((item) => !item.isExpired)
          .toList();
    } on FirebaseException catch (e) {
      throw StoryException(e.message ?? 'Failed to fetch story items.');
    }
  }

  // ─── Add Story Item ───────────────────────────────────────────────────────

  @override
  Future<StoryItemModel> addStoryItem({
    required String uid,
    required StoryItemType type,
    required String url,
    String? caption,
    String? thumbnailUrl,
    int? backgroundColor,
  }) async {
    try {
      final now = DateTime.now();
      final ref = _items(uid).doc();

      final item = StoryItemModel(
        id: ref.id,
        uid: uid,
        type: type,
        url: url,
        caption: caption,
        thumbnailUrl: thumbnailUrl,
        backgroundColor: backgroundColor != null
            ? Color(backgroundColor)
            : null,
        createdAt: now,
        expiresAt: now.add(const Duration(hours: 24)),
      );

      await ref.set(item.toFirestore());
      return item;
    } on FirebaseException catch (e) {
      throw StoryException(e.message ?? 'Failed to add story item.');
    }
  }

  // ─── Mark Viewed ─────────────────────────────────────────────────────────

  @override
  Future<void> markItemViewed({
    required String ownerUid,
    required String itemId,
    required String viewerUid,
  }) async {
    try {
      await _items(ownerUid).doc(itemId).update({
        'viewerIds': FieldValue.arrayUnion([viewerUid]),
      });
    } on FirebaseException catch (e) {
      throw StoryException(e.message ?? 'Failed to mark story as viewed.');
    }
  }

  // ─── Toggle Like ──────────────────────────────────────────────────────────

  @override
  Future<void> toggleLike({
    required String ownerUid,
    required String itemId,
    required String viewerUid,
    required bool isLiked,
  }) async {
    try {
      await _items(ownerUid).doc(itemId).update({
        'likeIds': isLiked
            ? FieldValue.arrayRemove([viewerUid])
            : FieldValue.arrayUnion([viewerUid]),
      });
    } on FirebaseException catch (e) {
      throw StoryException(e.message ?? 'Failed to toggle like.');
    }
  }

  // ─── Delete Item ──────────────────────────────────────────────────────────

  @override
  Future<void> deleteStoryItem({
    required String uid,
    required String itemId,
  }) async {
    try {
      await _items(uid).doc(itemId).delete();
    } on FirebaseException catch (e) {
      throw StoryException(e.message ?? 'Failed to delete story item.');
    }
  }

  // ─── Clear My Story ───────────────────────────────────────────────────────

  @override
  Future<void> clearMyStory({required String uid}) async {
    try {
      final snap = await _items(uid).get();
      if (snap.docs.isEmpty) return;

      // Batch delete in chunks of 400
      const chunkSize = 400;
      for (var i = 0; i < snap.docs.length; i += chunkSize) {
        final batch = _firestore.batch();
        for (final doc in snap.docs.skip(i).take(chunkSize)) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }
    } on FirebaseException catch (e) {
      throw StoryException(e.message ?? 'Failed to clear story.');
    }
  }

  // ─── Delete Expired Items ─────────────────────────────────────────────────

  @override
  Future<void> deleteExpiredItems({required String uid}) async {
    try {
      final snap = await _items(
        uid,
      ).where('expiresAt', isLessThanOrEqualTo: Timestamp.now()).get();

      if (snap.docs.isEmpty) return;

      const chunkSize = 400;
      for (var i = 0; i < snap.docs.length; i += chunkSize) {
        final batch = _firestore.batch();
        for (final doc in snap.docs.skip(i).take(chunkSize)) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }
    } on FirebaseException catch (e) {
      throw StoryException(e.message ?? 'Failed to delete expired items.');
    }
  }
}
// ─── Exception ────────────────────────────────────────────────────────────────

class StoryException implements Exception {
  final String message;
  const StoryException(this.message);

  @override
  String toString() => 'StoryException: $message';
}
