import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/core/utils/enums.dart';
import 'package:Chatty/features/stories/data/models/story_item_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/framework/failure.dart';

abstract class StoryDataSource {
  Stream<List<StoryItemModel>> watchMyStory({required String uid});

  Stream<Map<String, List<StoryItemModel>>> watchFeedStories({
    required String uid,
    required List<String> contactUids,
  });

  Future<List<StoryItemModel>> getStoryItems({required String uid});

  Future<StoryItemModel> addStoryItem({
    required String uid,
    required StoryItemType type,
    required String url,
    String? caption,
    String? thumbnailUrl,
    int? backgroundColor,
  });

  Future<void> markItemViewed({
    required String ownerUid,
    required String itemId,
    required String viewerUid,
  });

  Future<void> toggleLike({
    required String ownerUid,
    required String itemId,
    required String viewerUid,
    required bool isLiked,
  });

  Future<void> deleteStoryItem({required String uid, required String itemId});

  Future<void> clearMyStory({required String uid});

  Future<void> deleteExpiredItems({required String uid});
}

@LazySingleton(as: StoryDataSource)
class StoryDataSourceImpl implements StoryDataSource {
  final FirebaseFirestore _firestore;

  const StoryDataSourceImpl(this._firestore);

  CollectionReference<Map<String, dynamic>> _items(String uid) =>
      _firestore.collection('stories').doc(uid).collection('items');

  Query<Map<String, dynamic>> _activeItemsQuery(String uid) => _items(uid)
      .where('expiresAt', isGreaterThan: Timestamp.now())
      .orderBy('expiresAt')
      .orderBy('createdAt');

  @override
  Stream<List<StoryItemModel>> watchMyStory({required String uid}) {
    return _activeItemsQuery(uid).snapshots().map(
      (snap) => snap.docs
          .map((d) => StoryItemModel.fromFirestore(d.data(), d.id))
          .where((item) => !item.isExpired)
          .toList(),
    );
  }

  @override
  Stream<Map<String, List<StoryItemModel>>> watchFeedStories({
    required String uid,
    required List<String> contactUids,
  }) {
    if (contactUids.isEmpty) {
      return Stream.value({});
    }

    return _firestore
        .collectionGroup('items')
        .where('uid', whereIn: contactUids.take(30).toList())
        .where('expiresAt', isGreaterThan: Timestamp.now())
        .orderBy('expiresAt')
        .orderBy('createdAt')
        .snapshots()
        .map((snap) {
          final Map<String, List<StoryItemModel>> result = {};
          for (final doc in snap.docs) {
            final item = StoryItemModel.fromFirestore(doc.data(), doc.id);
            if (item.isExpired || item.uid == uid) {
              continue;
            }
            result.putIfAbsent(item.uid, () => []).add(item);
          }
          return result;
        });
  }

  @override
  Future<List<StoryItemModel>> getStoryItems({required String uid}) async {
    try {
      final snap = await _activeItemsQuery(uid).get();
      return snap.docs
          .map((d) => StoryItemModel.fromFirestore(d.data(), d.id))
          .where((item) => !item.isExpired)
          .toList();
    } on FirebaseException catch (e) {
      throw Failure(500, e.message ?? 'Failed to fetch story items.');
    }
  }

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
      throw Failure(500, e.message ?? 'Failed to add story item.');
    }
  }

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
      throw Failure(500, e.message ?? 'Failed to mark story as viewed.');
    }
  }

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
      throw Failure(500, e.message ?? 'Failed to toggle like.');
    }
  }

  @override
  Future<void> deleteStoryItem({
    required String uid,
    required String itemId,
  }) async {
    try {
      await _items(uid).doc(itemId).delete();
    } on FirebaseException catch (e) {
      throw Failure(500, e.message ?? 'Failed to delete story item.');
    }
  }

  @override
  Future<void> clearMyStory({required String uid}) async {
    try {
      final snap = await _items(uid).get();
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
      throw Failure(500, e.message ?? 'Failed to clear story.');
    }
  }

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
      throw Failure(500, e.message ?? 'Failed to delete expired items.');
    }
  }
}

