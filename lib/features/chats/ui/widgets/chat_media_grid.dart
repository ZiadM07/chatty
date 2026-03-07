import 'package:Chatty/core/utils/enums.dart';
import 'package:Chatty/features/chats/ui/widgets/media_viewer_dialog.dart';
import 'package:Chatty/features/shared/widgets/app_image.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../../core/constants/exports.dart';
import '../../data/models/message_model.dart';

final Map<String, Uint8List?> _thumbnailCache = {};

class ChatMediaGrid extends StatelessWidget {
  final List<MessageModel> media;
  final int tabIndex;
  final ScrollController controller;
  final bool hasMore;

  const ChatMediaGrid({
    super.key,
    required this.media,
    required this.tabIndex,
    required this.controller,
    required this.hasMore,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: GridView.builder(
        key: ValueKey('grid_$tabIndex${media.length}'),
        controller: controller,
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: media.length + (hasMore ? 1 : 0),
        itemBuilder: (_, i) {
          if (i >= media.length) {
            return const Center(child: CircularProgressIndicator());
          }

          return _MediaTile(
            media: media[i],
            index: i,
            onTap: () => MediaViewerDialog.show(
              context: context,
              mediaUrl: media[i].content,
              type: media[i].type,
              metadata: media[i].metadata,
            ),
          );
        },
      ),
    );
  }
}

class _MediaTile extends StatefulWidget {
  final MessageModel media;
  final int index;
  final VoidCallback? onTap;

  const _MediaTile({required this.media, required this.index, this.onTap});

  @override
  State<_MediaTile> createState() => _MediaTileState();
}

class _MediaTileState extends State<_MediaTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _scale = Tween(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _fade = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.index * 40), () {
      if (mounted) _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;

    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: widget.onTap,
            child: Container(
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: cs.shadow.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: _buildPreview(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      widget.media.content,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return switch (widget.media.type) {
      MessageType.image => AppImage(imageUrl: widget.media.content),
      MessageType.video => _VideoThumbPreview(url: widget.media.content),
      MessageType.audio => _iconPreview(Icons.audiotrack),
      MessageType.file => _iconPreview(Icons.description),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _iconPreview(IconData icon) {
    return Container(
      color: context.colorScheme.primaryContainer,
      child: Center(
        child: Icon(icon, size: 48, color: context.colorScheme.primary),
      ),
    );
  }
}

class _VideoThumbPreview extends StatefulWidget {
  final String url;
  const _VideoThumbPreview({required this.url});

  @override
  State<_VideoThumbPreview> createState() => _VideoThumbPreviewState();
}

class _VideoThumbPreviewState extends State<_VideoThumbPreview> {
  bool _generating = false;

  @override
  void initState() {
    super.initState();
    _resolveThumb();
  }

  @override
  void didUpdateWidget(covariant _VideoThumbPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) _resolveThumb();
  }

  void _resolveThumb() {
    if (_thumbnailCache.containsKey(widget.url)) {
      if (_generating) setState(() => _generating = false);
      return;
    }
    setState(() => _generating = true);
    _generateThumb(widget.url);
  }

  Future<void> _generateThumb(String url) async {
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
      fit: StackFit.expand,
      children: [
        if (_generating)
          _TileSkeletonShimmer()
        else if (thumb != null)
          Image.memory(thumb, fit: BoxFit.cover, gaplessPlayback: true)
        else
          Container(
            color: Colors.black45,
            child: Center(
              child: Icon(
                Icons.videocam_off_rounded,
                size: 32,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ),
        if (!_generating)
          Center(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                size: 28,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}

class _TileSkeletonShimmer extends StatefulWidget {
  @override
  State<_TileSkeletonShimmer> createState() => _TileSkeletonShimmerState();
}

class _TileSkeletonShimmerState extends State<_TileSkeletonShimmer>
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
        color: context.colorScheme.surfaceContainerHighest,
        child: Center(
          child: Icon(
            Icons.videocam_rounded,
            size: 32,
            color: context.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}
