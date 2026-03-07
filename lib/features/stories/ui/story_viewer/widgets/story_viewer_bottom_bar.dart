import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/features/stories/data/models/story_item_model.dart';

class StoryViewerBottomBar extends StatefulWidget {
  final StoryItemModel item;
  final String currentUid;
  final bool isReplying;
  final VoidCallback onLike;
  final ValueChanged<String> onReply;
  final ValueChanged<bool> onFocusChanged;

  const StoryViewerBottomBar({
    super.key,
    required this.item,
    required this.currentUid,
    required this.isReplying,
    required this.onLike,
    required this.onReply,
    required this.onFocusChanged,
  });

  @override
  State<StoryViewerBottomBar> createState() => _StoryViewerBottomBarState();
}

class _StoryViewerBottomBarState extends State<StoryViewerBottomBar>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  bool _hasText = false;

  late bool _isLiked;

  late final AnimationController _likeCtrl;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.item.isLikedBy(widget.currentUid);
    _likeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      lowerBound: 0.85,
      upperBound: 1.0,
      value: 1.0,
    );
    _controller.addListener(_onTextChanged);
    _focus.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(covariant StoryViewerBottomBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item != widget.item) {
      _isLiked = widget.item.isLikedBy(widget.currentUid);
    }
  }

  void _onTextChanged() {
    final has = _controller.text.trim().isNotEmpty;
    if (has != _hasText) setState(() => _hasText = has);
  }

  void _onFocusChanged() => widget.onFocusChanged(_focus.hasFocus);

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    _likeCtrl.dispose();
    super.dispose();
  }

  void _send() {
    if (!_hasText) return;
    widget.onReply(_controller.text.trim());
    _controller.clear();
    _focus.unfocus();
  }

  Future<void> _onLikeTap() async {
    HapticFeedback.lightImpact();
    setState(() => _isLiked = !_isLiked);
    await _likeCtrl.reverse();
    widget.onLike();
    await _likeCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    final isLiked = _isLiked;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: _ReplyField(
                controller: _controller,
                focus: _focus,
                hasText: _hasText,
                isReplying: widget.isReplying,
                onSend: _send,
              ),
            ),
            const SizedBox(width: 10),
            _LikeButton(
              isLiked: isLiked,
              controller: _likeCtrl,
              onTap: _onLikeTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReplyField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focus;
  final bool hasText;
  final bool isReplying;
  final VoidCallback onSend;

  const _ReplyField({
    required this.controller,
    required this.focus,
    required this.hasText,
    required this.isReplying,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focus,
              style: context.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
              ),
              cursorColor: Colors.white,
              maxLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(
                hintText: context.locale.replyToStory,
                hintStyle: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.textSecondary,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: hasText
                ? _SendButton(
                    key: const ValueKey('send'),
                    isReplying: isReplying,
                    onSend: onSend,
                  )
                : const SizedBox.shrink(key: ValueKey('empty')),
          ),
          if (!hasText) const SizedBox(width: 12),
        ],
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final bool isReplying;
  final VoidCallback onSend;

  const _SendButton({
    super.key,
    required this.isReplying,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isReplying ? null : onSend,
      child: Container(
        margin: const EdgeInsets.all(6),
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              context.colorScheme.primary,
              context.colorScheme.secondary,
            ],
          ),
          shape: BoxShape.circle,
        ),
        child: isReplying
            ? const Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              )
            : const Icon(Icons.send_rounded, color: Colors.white, size: 16),
      ),
    );
  }
}

class _LikeButton extends StatelessWidget {
  final bool isLiked;
  final AnimationController controller;
  final VoidCallback onTap;

  const _LikeButton({
    required this.isLiked,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ScaleTransition(
        scale: controller,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isLiked
                ? context.colorScheme.primary.withValues(alpha: 0.25)
                : Colors.white.withValues(alpha: 0.12),
            border: Border.all(
              color: isLiked
                  ? context.colorScheme.primary.withValues(alpha: 0.6)
                  : Colors.white.withValues(alpha: 0.2),
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            switchInCurve: Curves.elasticOut,
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Icon(
              key: ValueKey(isLiked),
              isLiked ? SolarIconsBold.heart : SolarIconsOutline.heart,
              color: isLiked ? context.colorScheme.primary : Colors.white,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
