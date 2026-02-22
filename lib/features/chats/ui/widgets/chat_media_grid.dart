import 'package:chatty/core/utils/enums.dart';
import 'package:chatty/features/shared/widgets/app_image.dart';

import '../../../../core/constants/exports.dart';
import '../../data/models/message_model.dart';

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

          return _MediaTile(media: media[i], index: i);
        },
      ),
    );
  }
}

class _MediaTile extends StatefulWidget {
  final MessageModel media;
  final int index;

  const _MediaTile({required this.media, required this.index});

  @override
  State<_MediaTile> createState() => _MediaTileState();
}

class _MediaTileState extends State<_MediaTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _scale = Tween(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fade = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(
      Duration(milliseconds: widget.index * 40),
      () => mounted ? _controller.forward() : null,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
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
            onTap: () {
              // Add viewer / download logic if needed
            },
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
    if (widget.media.type case MessageType.image) {
      return AppImage(imageUrl: widget.media.content);
    } else if (widget.media.type case MessageType.video) {
      return Stack(
        fit: StackFit.expand,
        children: [
          AppImage(imageUrl: widget.media.content),
          const Center(
            child: Icon(
              Icons.play_circle_fill_rounded,
              size: 42,
              color: Colors.white,
            ),
          ),
        ],
      );
    } else if (widget.media.type case MessageType.audio) {
      return _iconPreview(Icons.audiotrack);
    } else if (widget.media.type case MessageType.file) {
      return _iconPreview(Icons.description);
    }
    return const SizedBox.shrink();
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
