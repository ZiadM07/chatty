// ─── Story Viewer Model ───────────────────────────────────────────────────────
//
//  Light model for showing who viewed a story item.
//  Assembled in the UI layer from viewerIds + cached user data.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:chatty/core/constants/exports.dart';


class StoryViewerModel extends Equatable {
  final String uid;
  final String displayName;
  final String? photoUrl;
  final DateTime viewedAt;

  const StoryViewerModel({
    required this.uid,
    required this.displayName,
    this.photoUrl,
    required this.viewedAt,
  });

  @override
  List<Object?> get props => [uid, displayName, photoUrl, viewedAt];
}