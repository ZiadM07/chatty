import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/features/stories/data/models/story_item_model.dart';

class StoryModel extends Equatable {
  final String uid;
  final String displayName;
  final String? photoUrl;
  final List<StoryItemModel> items;

  const StoryModel({
    required this.uid,
    required this.displayName,
    this.photoUrl,
    required this.items,
  });

  bool get hasItems => items.isNotEmpty;

  bool isFullyViewedBy(String viewerUid) =>
      items.every((item) => item.isViewedBy(viewerUid));

  bool isPartiallyViewedBy(String viewerUid) =>
      !isFullyViewedBy(viewerUid) &&
      items.any((item) => item.isViewedBy(viewerUid));

  int firstUnseenIndex(String viewerUid) {
    final idx = items.indexWhere((item) => !item.isViewedBy(viewerUid));
    return idx == -1 ? 0 : idx;
  }

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
