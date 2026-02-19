import 'package:chatty/core/constants/exports.dart';

/// Wraps any message bubble with swipe-to-reply and long-press-to-delete.
/// All bubbles (text, voice, attachment) use this — keeping them dumb.
class SwipeToReply extends StatefulWidget {
  final Widget child;
  final bool isMe;
  final VoidCallback? onSwipe;
  final VoidCallback? onLongPress;

  const SwipeToReply({
    super.key,
    required this.child,
    required this.isMe,
    this.onSwipe,
    this.onLongPress,
  });

  @override
  State<SwipeToReply> createState() => _SwipeToReplyState();
}

class _SwipeToReplyState extends State<SwipeToReply>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _iconFadeAnim;
  late final Animation<double> _iconScaleAnim;

  static const _swipeThreshold = 60.0;
  static const _velocityThreshold = 300.0;
  double _dragOffset = 0;
  bool _triggered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnim = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(widget.isMe ? -0.12 : 0.12, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _iconFadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _iconScaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (widget.onSwipe == null) return;
    final delta = details.primaryDelta ?? 0;

    // Only allow swipe in the correct direction
    final isValidDirection = widget.isMe ? delta < 0 : delta > 0;
    if (!isValidDirection && _dragOffset == 0) return;

    setState(() {
      _dragOffset = (widget.isMe
          ? (_dragOffset + delta).clamp(-_swipeThreshold, 0.0)
          : (_dragOffset + delta).clamp(0.0, _swipeThreshold));
    });

    final progress = _dragOffset.abs() / _swipeThreshold;
    _controller.value = progress;

    if (!_triggered && _dragOffset.abs() >= _swipeThreshold * 0.85) {
      _triggered = true;
      HapticFeedback.lightImpact();
    }
  }

  void _onDragEnd(DragEndDetails details) {
    if (widget.onSwipe == null) return;
    final velocity = details.primaryVelocity ?? 0;
    final triggeredByVelocity = widget.isMe
        ? velocity < -_velocityThreshold
        : velocity > _velocityThreshold;

    if (_triggered || triggeredByVelocity) {
      widget.onSwipe!();
    }

    // Snap back
    _controller.reverse();
    setState(() {
      _dragOffset = 0;
      _triggered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onSwipe == null && widget.onLongPress == null) {
      return widget.child;
    }

    return GestureDetector(
      onLongPress: widget.onLongPress,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: Stack(
        alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
        children: [
          /* ─── Reply icon revealed behind the bubble ─── */
          FadeTransition(
            opacity: _iconFadeAnim,
            child: ScaleTransition(
              scale: _iconScaleAnim,
              child: Padding(
                padding: AppPadding.set(
                  start: widget.isMe ? 0 : 16,
                  end: widget.isMe ? 16 : 0,
                ),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: context.colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.reply_rounded,
                    size: 18,
                    color: context.colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),

          /* ─── The bubble itself, slides on drag ─── */
          SlideTransition(position: _slideAnim, child: widget.child),
        ],
      ),
    );
  }
}
