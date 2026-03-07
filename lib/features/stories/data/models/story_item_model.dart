import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/core/utils/enums.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StoryItemModel extends Equatable {
  final String id;
  final String uid;
  final StoryItemType type;
  final String url;
  final String? caption;
  final String? thumbnailUrl;
  final Color? backgroundColor;
  final DateTime createdAt;
  final DateTime expiresAt;
  final List<String> viewerIds;
  final List<String> likeIds;

  const StoryItemModel({
    required this.id,
    required this.uid,
    required this.type,
    required this.url,
    this.caption,
    this.thumbnailUrl,
    this.backgroundColor,
    required this.createdAt,
    required this.expiresAt,
    this.viewerIds = const [],
    this.likeIds = const [],
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool isViewedBy(String viewerUid) => viewerIds.contains(viewerUid);
  bool isLikedBy(String uid) => likeIds.contains(uid);
  int get viewCount => viewerIds.length;
  int get likeCount => likeIds.length;

  Duration get timeRemaining {
    final remaining = expiresAt.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  factory StoryItemModel.fromFirestore(Map<String, dynamic> data, String id) {
    return StoryItemModel(
      id: id,
      uid: data['uid'] as String? ?? '',
      type: StoryItemType.values.firstWhere(
        (e) => e.name == (data['type'] as String?),
        orElse: () => StoryItemType.image,
      ),
      url: data['url'] as String? ?? '',
      caption: data['caption'] as String?,
      thumbnailUrl: data['thumbnailUrl'] as String?,
      backgroundColor: data['backgroundColor'] != null
          ? Color(data['backgroundColor'] as int)
          : null,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt:
          (data['expiresAt'] as Timestamp?)?.toDate() ??
          DateTime.now().add(const Duration(hours: 24)),
      viewerIds: List<String>.from(data['viewerIds'] as List? ?? []),
      likeIds: List<String>.from(data['likeIds'] as List? ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'type': type.name,
      'url': url,
      'caption': caption,
      'thumbnailUrl': thumbnailUrl,
      // ignore: deprecated_member_use
      'backgroundColor': backgroundColor?.value,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'viewerIds': viewerIds,
      'likeIds': likeIds,
    };
  }

  StoryItemModel copyWith({
    String? id,
    String? uid,
    StoryItemType? type,
    String? url,
    String? caption,
    String? thumbnailUrl,
    Color? backgroundColor,
    DateTime? createdAt,
    DateTime? expiresAt,
    List<String>? viewerIds,
    List<String>? likeIds,
  }) {
    return StoryItemModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      type: type ?? this.type,
      url: url ?? this.url,
      caption: caption ?? this.caption,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      viewerIds: viewerIds ?? this.viewerIds,
      likeIds: likeIds ?? this.likeIds,
    );
  }

  @override
  List<Object?> get props => [
    id,
    uid,
    type,
    url,
    caption,
    thumbnailUrl,
    backgroundColor,
    createdAt,
    expiresAt,
    viewerIds,
    likeIds,
  ];
}
