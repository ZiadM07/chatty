import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/core/utils/enums.dart';
import 'package:Chatty/features/chats/data/models/message_model.dart';
import 'package:Chatty/features/chats/ui/media/widgets/media_viewer_dialog.dart';
import 'package:Chatty/features/chats/ui/chat/widgets/message_bubble_shell.dart';
import 'package:Chatty/features/chats/ui/chat/widgets/message_reaction_overlay.dart';
import 'package:Chatty/features/shared/widgets/app_image.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

final Map<String, Uint8List?> _thumbnailCache = {};

class MediaMessageBubble extends StatelessWidget {
  final MessageModel message;
  final MessageType type;
  final String time;
  final MessageStatus? status;
  final bool isMe;
  final String? currentUid;
  final Map<String, dynamic>? metadata;
  final String? replyToContent;
  final String? replyToSenderId;
  final MessageType? replyToType;
  final VoidCallback? onReplyTap;
  final Map<String, String> memberNames;

  final ValueChanged<String?> onReact;
  final VoidCallback onReply;
  final VoidCallback? onDelete;

  const MediaMessageBubble({
    super.key,
    required this.message,
    required this.type,
    required this.time,
    this.status,
    required this.isMe,
    this.currentUid,
    this.metadata,
    this.replyToContent,
    this.replyToSenderId,
    this.replyToType,
    this.onReplyTap,
    this.memberNames = const {},
    required this.onReact,
    required this.onReply,
    this.onDelete,
  });

  String get _mediaUrl => message.content;
  bool get _isDeleted => message.isDeleted;

  @override
  Widget build(BuildContext context) {
    Widget bubble;

    if (_isDeleted) {
      bubble = MessageBubbleShell(
        isMe: isMe,
        isDeleted: true,
        time: time,
        memberNames: memberNames,
        child: const SizedBox.shrink(),
      );
    } else if (type == MessageType.file) {
      bubble = MessageBubbleShell(
        isMe: isMe,
        isDeleted: false,
        time: time,
        status: status,
        footerAlignment: MainAxisAlignment.end,
        replyToContent: replyToContent,
        replyToSenderId: replyToSenderId,
        currentUid: currentUid,
        replyToType: replyToType,
        onReplyTap: onReplyTap,
        memberNames: memberNames,
        child: _FileBody(
          url: _mediaUrl,
          isMe: isMe,
          onTap: () => _openViewer(context),
        ),
      );
    } else {
      bubble = MessageBubbleShell(
        isMe: isMe,
        isDeleted: false,
        contentPadding: EdgeInsets.zero,
        time: null,
        replyToContent: replyToContent,
        replyToSenderId: replyToSenderId,
        currentUid: currentUid,
        replyToType: replyToType,
        onReplyTap: onReplyTap,
        memberNames: memberNames,
        child: GestureDetector(
          onTap: () => _openViewer(context),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isMe ? 18 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 18),
            ),
            child: Stack(
              children: [
                if (type == MessageType.image)
                  _ImagePreview(url: _mediaUrl)
                else if (type == MessageType.video)
                  _VideoPreview(url: _mediaUrl),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          time,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        if (isMe && status != null) ...[
                          const SizedBox(width: 4),
                          Text(
                            bubbleStatusText(status!, context),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return BubbleWithReactions(
      message: message,
      isMe: isMe,
      currentUid: currentUid ?? '',
      onReply: onReply,
      onReact: onReact,
      onDelete: onDelete,
      bubble: bubble,
    );
  }

  void _openViewer(BuildContext context) => MediaViewerDialog.show(
    context: context,
    mediaUrl: _mediaUrl,
    type: type,
    metadata: metadata,
  );
}

class _FileBody extends StatelessWidget {
  final String url;
  final bool isMe;
  final VoidCallback onTap;
  const _FileBody({required this.url, required this.isMe, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final fileName = _extractFileName(url);
    final ext = _extractExtension(fileName);
    final (icon, iconColor) = _fileIcon(ext, context);

    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isMe
                  ? Colors.white.withValues(alpha: 0.18)
                  : iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isMe ? context.colorScheme.onPrimary : iconColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  fileName,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isMe
                        ? context.colorScheme.onPrimary
                        : context.colorScheme.onSurface,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 2),
                AppText(
                  ext.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isMe
                        ? context.colorScheme.onPrimary.withValues(alpha: 0.6)
                        : context.colorScheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.download_rounded,
            size: 18,
            color: isMe
                ? context.colorScheme.onPrimary.withValues(alpha: 0.7)
                : context.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  String _extractFileName(String url) {
    try {
      final segments = Uri.parse(url).pathSegments;
      if (segments.isNotEmpty) {
        final name = Uri.decodeComponent(segments.last);
        final parts = name.split('_');
        if (parts.length > 1 && int.tryParse(parts[0]) != null) {
          return parts.sublist(1).join('_');
        }
        return name;
      }
    } catch (_) {}
    return 'Document';
  }

  String _extractExtension(String name) {
    final parts = name.split('.');
    return parts.length > 1 ? parts.last : 'file';
  }

  (IconData, Color) _fileIcon(String ext, BuildContext context) {
    return switch (ext.toLowerCase()) {
      'pdf' => (Icons.picture_as_pdf_rounded, context.colorScheme.error),
      'doc' || 'docx' => (Icons.description_rounded, const Color(0xFF2B579A)),
      'xls' || 'xlsx' => (Icons.table_chart_rounded, const Color(0xFF217346)),
      'ppt' || 'pptx' => (Icons.slideshow_rounded, const Color(0xFFD24726)),
      'zip' ||
      'rar' ||
      '7z' => (Icons.folder_zip_rounded, const Color(0xFFFFA500)),
      'txt' => (Icons.text_snippet_rounded, context.colorScheme.tertiary),
      _ => (Icons.insert_drive_file_rounded, context.colorScheme.secondary),
    };
  }
}

class _ImagePreview extends StatelessWidget {
  final String url;
  const _ImagePreview({required this.url});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'media_$url',
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: 280,
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        child: AppImage(
          imageUrl: url,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      ),
    );
  }
}

class _VideoPreview extends StatefulWidget {
  final String url;
  const _VideoPreview({required this.url});

  @override
  State<_VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<_VideoPreview> {
  bool _generating = false;

  @override
  void initState() {
    super.initState();
    _resolveThumb();
  }

  @override
  void didUpdateWidget(covariant _VideoPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) _resolveThumb();
  }

  void _resolveThumb() {
    if (_thumbnailCache.containsKey(widget.url)) {
      _generating = false;
      return;
    }
    _generating = true;
    _generateThumbnail(widget.url);
  }

  Future<void> _generateThumbnail(String url) async {
    Uint8List? bytes;
    try {
      bytes = await VideoThumbnail.thumbnailData(
        video: url,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 400,
        quality: 75,
      );
    } catch (_) {
      bytes = null;
    }
    _thumbnailCache[url] = bytes;
    if (mounted && widget.url == url) {
      setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final thumb = _thumbnailCache[widget.url];

    return Stack(
      alignment: Alignment.center,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: 280,
            maxWidth: MediaQuery.of(context).size.width * 0.72,
          ),
          child: _generating
              ? _ThumbnailSkeleton()
              : thumb != null
              // Cached thumbnail
              ? Image.memory(
                  thumb,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  gaplessPlayback: true,
                )
              : _ThumbnailFallback(),
        ),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.play_arrow_rounded,
            color: Colors.white,
            size: 36,
          ),
        ),
      ],
    );
  }
}

class _ThumbnailSkeleton extends StatefulWidget {
  @override
  State<_ThumbnailSkeleton> createState() => _ThumbnailSkeletonState();
}

class _ThumbnailSkeletonState extends State<_ThumbnailSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween(
      begin: 0.3,
      end: 0.7,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: double.infinity,
        height: 200,
        color: context.colorScheme.surfaceContainerHighest,
      ),
    );
  }
}

class _ThumbnailFallback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      color: Colors.black45,
      child: Center(
        child: Icon(
          Icons.videocam_off_rounded,
          size: 36,
          color: Colors.white.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
