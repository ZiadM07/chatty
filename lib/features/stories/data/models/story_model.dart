// ─── Story Model ──────────────────────────────────────────────────────────────
//
//  Represents one user's full story (all their active items).
//  This is a virtual model — it's assembled from the items sub-collection.
//  We also cache the owner's display info here so the story ring row
//  doesn't need a separate user fetch.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:chatty/core/constants/exports.dart';
import 'package:chatty/features/stories/data/models/story_item_model.dart';

class StoryModel extends Equatable {
  final String uid; // story owner
  final String displayName;
  final String? photoUrl;
  final List<StoryItemModel> items; // sorted by createdAt asc, non-expired only

  const StoryModel({
    required this.uid,
    required this.displayName,
    this.photoUrl,
    required this.items,
  });

  bool get hasItems => items.isNotEmpty;

  /// True if the current viewer has seen ALL items in this story.
  bool isFullyViewedBy(String viewerUid) =>
      items.every((item) => item.isViewedBy(viewerUid));

  /// True if the viewer has seen SOME but not all items.
  bool isPartiallyViewedBy(String viewerUid) =>
      !isFullyViewedBy(viewerUid) &&
      items.any((item) => item.isViewedBy(viewerUid));

  /// Index of the first unseen item — so the viewer picks up where they left off.
  int firstUnseenIndex(String viewerUid) {
    final idx = items.indexWhere((item) => !item.isViewedBy(viewerUid));
    return idx == -1 ? 0 : idx;
  }

  /// Most recent item's createdAt — used for sorting story rings.
  DateTime get lastUpdatedAt =>
      items.isEmpty ? DateTime(0) : items.last.createdAt;

  StoryModel copyWith({
    String? uid,
    String? displayName,
    String? photoUrl,
    List<StoryItemModel>? items,
  }) {
    return StoryModel(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [uid, displayName, photoUrl, items];
}
