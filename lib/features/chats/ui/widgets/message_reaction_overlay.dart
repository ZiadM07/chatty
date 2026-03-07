import 'dart:ui';
import 'package:Chatty/core/utils/enums.dart';
import 'package:Chatty/features/chats/data/models/message_model.dart';
import '../../../../core/constants/exports.dart';

TextStyle _emojiStyle(double size) => TextStyle(
  fontSize: size,
  fontFamily: 'NotoColorEmoji',
  fontFamilyFallback: const [
    'Apple Color Emoji',
    'Noto Color Emoji',
    'Segoe UI Emoji',
  ],
);

const _emojiBarH = 62.0;
const _emojiBarW = 296.0;
const _menuW = 215.0;
const _menuEstH = 175.0;
const _gap = 10.0;
const _edgePad = 12.0;

class MessageReactionOverlay extends StatefulWidget {
  final Widget child;
  final MessageModel message;
  final bool isMe;
  final String currentUid;
  final VoidCallback onReply;
  final VoidCallback? onDelete;
  final ValueChanged<String?> onReact;

  const MessageReactionOverlay({
    super.key,
    required this.child,
    required this.message,
    required this.isMe,
    required this.currentUid,
    required this.onReply,
    required this.onReact,
    this.onDelete,
  });

  @override
  State<MessageReactionOverlay> createState() => _MessageReactionOverlayState();
}

class _MessageReactionOverlayState extends State<MessageReactionOverlay> {
  OverlayEntry? _entry;

  void _show() {
    if (widget.message.isDeleted) return;
    if (_entry != null) return;
    HapticFeedback.mediumImpact();

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final globalPos = renderBox.localToGlobal(Offset.zero);

    _entry = OverlayEntry(
      builder: (_) => _ReactionPanel(
        anchorSize: size,
        anchorGlobalPos: globalPos,
        bubbleChild: widget.child,
        message: widget.message,
        isMe: widget.isMe,
        currentUid: widget.currentUid,
        onReply: widget.onReply,
        onDelete: widget.onDelete,
        onReact: widget.onReact,
        onDismiss: _dismiss,
      ),
    );

    Overlay.of(context, rootOverlay: true).insert(_entry!);
  }

  void _dismiss() {
    _entry?.remove();
    _entry = null;
  }

  @override
  void dispose() {
    _dismiss();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: _show,
      child: widget.child,
    );
  }
}

class _ReactionPanel extends StatefulWidget {
  final Size anchorSize;
  final Offset anchorGlobalPos;
  final Widget bubbleChild;
  final MessageModel message;
  final bool isMe;
  final String currentUid;
  final VoidCallback onReply;
  final VoidCallback? onDelete;
  final ValueChanged<String?> onReact;
  final VoidCallback onDismiss;

  const _ReactionPanel({
    required this.anchorSize,
    required this.anchorGlobalPos,
    required this.bubbleChild,
    required this.message,
    required this.isMe,
    required this.currentUid,
    required this.onReply,
    required this.onDelete,
    required this.onReact,
    required this.onDismiss,
  });

  @override
  State<_ReactionPanel> createState() => _ReactionPanelState();
}

class _ReactionPanelState extends State<_ReactionPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _blurAnim;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _bubbleScaleAnim; // subtle lift effect on ghost
  late final Animation<Offset> _slideUp; // element slides up into position
  late final Animation<Offset> _slideDown; // element slides down into position

  late Map<String, String> _localReactions;

  static const _emojis = ['❤️', '😂', '😮', '😢', '😡', '👍'];

  @override
  void initState() {
    super.initState();
    _localReactions = Map<String, String>.from(widget.message.reactions);

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    )..forward();

    _blurAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scaleAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);

    // Ghost bubble scales from 1.0 → 1.05 — subtle "lifted off screen" feel
    _bubbleScaleAnim = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    // Slides from below upward (for elements below the bubble)
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    // Slides from above downward (for elements above the bubble)
    _slideDown = Tween<Offset>(
      begin: const Offset(0, -0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    if (!mounted) return;
    await _ctrl.reverse();
    widget.onDismiss();
  }

  void _handleReact(String emoji) {
    final current = _localReactions[widget.currentUid];
    final newReaction = current == emoji ? null : emoji;

    setState(() {
      if (newReaction == null) {
        _localReactions.remove(widget.currentUid);
      } else {
        _localReactions[widget.currentUid] = newReaction;
      }
    });

    widget.onReact(newReaction);
    Future.delayed(const Duration(milliseconds: 200), _dismiss);
  }

  // ── Layout computation ──────────────────────────────────────────────────────
  //
  // Four modes depending on how much space is available around the bubble:
  //
  //  NORMAL : space above AND below  →  EMOJI ╌ BUBBLE ╌ MENU
  //  TOP    : near top, no space above →  BUBBLE ╌ EMOJI ╌ MENU
  //  BOTTOM : near bottom, no space below →  MENU ╌ EMOJI ╌ BUBBLE
  //  TIGHT  : no space either side   →  centred, EMOJI ╌ BUBBLE ╌ MENU
  //
  _LayoutResult _computeLayout(MediaQueryData mq) {
    final screenH = mq.size.height;
    final safeTop = mq.padding.top;
    final safeBot = mq.padding.bottom;
    final bandTop = safeTop + kToolbarHeight + 8.0;
    final bandBot = screenH - safeBot - 8.0;
    final bandH = bandBot - bandTop;

    final rawTop = widget.anchorGlobalPos.dy;
    final rawBot = rawTop + widget.anchorSize.height;
    final spaceAbove = rawTop - bandTop;
    final spaceBelow = bandBot - rawBot;

    final isNearTop = spaceAbove < _emojiBarH + _gap + 4;
    final isNearBot = spaceBelow < _menuEstH + _gap + 4;

    double emojiTop;
    double menuTop;

    if (isNearTop && !isNearBot) {
      // ── TOP: bubble stays, emoji + menu stack below ──────────────────────
      emojiTop = rawBot + _gap;
      menuTop = emojiTop + _emojiBarH + _gap;
      if (menuTop + _menuEstH > bandBot) menuTop = bandBot - _menuEstH;
    } else if (isNearBot && !isNearTop) {
      // ── BOTTOM: menu + emoji stack above, bubble stays ───────────────────
      menuTop = rawTop - _gap - _menuEstH;
      emojiTop = menuTop - _gap - _emojiBarH;
      if (emojiTop < bandTop) {
        emojiTop = bandTop;
        menuTop = emojiTop + _emojiBarH + _gap;
      }
    } else if (isNearTop && isNearBot) {
      // ── TIGHT: centre the whole group ────────────────────────────────────
      final totalH =
          _emojiBarH + _gap + widget.anchorSize.height + _gap + _menuEstH;
      final start = bandTop + ((bandH - totalH) / 2).clamp(0.0, bandH);
      emojiTop = start;
      menuTop = start + _emojiBarH + _gap + widget.anchorSize.height + _gap;
    } else {
      // ── NORMAL: emoji above bubble, menu below ────────────────────────────
      emojiTop = rawTop - _emojiBarH - _gap;
      menuTop = rawBot + _gap;
    }

    return _LayoutResult(
      emojiTop: emojiTop,
      menuTop: menuTop,
      emojiAbove: emojiTop < rawTop,
      menuBelow: menuTop > rawTop,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenW = mq.size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final layout = _computeLayout(mq);

    // Horizontal — same side as the message bubble
    double emojiLeft = widget.isMe ? screenW - _emojiBarW - _edgePad : _edgePad;
    emojiLeft = emojiLeft.clamp(_edgePad, screenW - _emojiBarW - _edgePad);

    double menuLeft = widget.isMe ? screenW - _menuW - _edgePad : _edgePad;
    menuLeft = menuLeft.clamp(_edgePad, screenW - _menuW - _edgePad);

    return AnimatedBuilder(
      animation: _blurAnim,
      builder: (ctx, _) => Material(
        // Material ancestor is required — without it bare Text widgets render
        // with Flutter's yellow-underline DefaultTextStyle fallback.
        color: Colors.transparent,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Full-screen blur + dim tap-to-dismiss ──────────────────────
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _dismiss,
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 14 * _blurAnim.value,
                  sigmaY: 14 * _blurAnim.value,
                ),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.40 * _blurAnim.value),
                ),
              ),
            ),

            // ── Ghost bubble ───────────────────────────────────────────────
            //
            // We use a plain Positioned with the pixel-perfect coordinates
            // captured at long-press time (anchorGlobalPos / anchorSize).
            //
            // WHY NOT CompositedTransformFollower:
            //   The target is placed on the GestureDetector which is
            //   full-width (MessageBubbleShell wraps in Align internally),
            //   so the follower's origin is the screen left-edge, not the
            //   bubble pill's left-edge. Using the captured globalPos is
            //   exact and avoids any Align/margin offset confusion.
            //
            // The bubble is rendered at full screen-width so that
            // MessageBubbleShell's internal Align (centerRight / centerLeft)
            // places the pill in exactly the right horizontal position.
            Positioned(
              top: widget.anchorGlobalPos.dy,
              left: 0,
              right: 0,
              // Give it the exact height of the captured bubble so nothing
              // overflows into the emoji/menu zones.
              height: widget.anchorSize.height,
              child: ScaleTransition(
                scale: _bubbleScaleAnim,
                alignment: widget.isMe
                    ? Alignment.bottomRight
                    : Alignment.bottomLeft,
                child: widget.bubbleChild,
              ),
            ),

            // ── Emoji reaction bar ─────────────────────────────────────────
            Positioned(
              top: layout.emojiTop,
              left: emojiLeft,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  // Emoji above bubble slides down into place, below slides up
                  position: layout.emojiAbove ? _slideDown : _slideUp,
                  child: ScaleTransition(
                    scale: _scaleAnim,
                    // Scale origin at the corner closest to the bubble
                    alignment: layout.emojiAbove
                        ? (widget.isMe
                              ? Alignment.bottomRight
                              : Alignment.bottomLeft)
                        : (widget.isMe
                              ? Alignment.topRight
                              : Alignment.topLeft),
                    child: _EmojiBar(
                      emojis: _emojis,
                      currentReaction: _localReactions[widget.currentUid],
                      onReact: _handleReact,
                      isDark: isDark,
                    ),
                  ),
                ),
              ),
            ),

            // ── Context menu ───────────────────────────────────────────────
            Positioned(
              top: layout.menuTop,
              left: menuLeft,
              width: _menuW,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: layout.menuBelow ? _slideUp : _slideDown,
                  child: ScaleTransition(
                    scale: _scaleAnim,
                    alignment: layout.menuBelow
                        ? (widget.isMe ? Alignment.topRight : Alignment.topLeft)
                        : (widget.isMe
                              ? Alignment.bottomRight
                              : Alignment.bottomLeft),
                    child: _ContextMenu(
                      isMe: widget.isMe,
                      messageType: widget.message.type,
                      isDark: isDark,
                      onReply: () {
                        widget.onReply();
                        _dismiss();
                      },
                      onCopy: widget.message.type == MessageType.text
                          ? () {
                              Clipboard.setData(
                                ClipboardData(text: widget.message.content),
                              );
                              _dismiss();
                            }
                          : null,
                      onDelete: widget.onDelete != null
                          ? () {
                              widget.onDelete!();
                              _dismiss();
                            }
                          : null,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LayoutResult {
  final double emojiTop;
  final double menuTop;
  final bool emojiAbove;
  final bool menuBelow;

  const _LayoutResult({
    required this.emojiTop,
    required this.menuTop,
    required this.emojiAbove,
    required this.menuBelow,
  });
}

class _EmojiBar extends StatelessWidget {
  final List<String> emojis;
  final String? currentReaction;
  final ValueChanged<String> onReact;
  final bool isDark;

  const _EmojiBar({
    required this.emojis,
    required this.currentReaction,
    required this.onReact,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: emojis
            .map(
              (e) => _EmojiButton(
                emoji: e,
                isSelected: currentReaction == e,
                onTap: () => onReact(e),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _EmojiButton extends StatefulWidget {
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const _EmojiButton({
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_EmojiButton> createState() => _EmojiButtonState();
}

class _EmojiButtonState extends State<_EmojiButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounce;

  @override
  void initState() {
    super.initState();
    _bounce = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      lowerBound: 0.75,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    HapticFeedback.selectionClick();
    await _bounce.animateTo(
      0.75,
      duration: const Duration(milliseconds: 80),
      curve: Curves.easeIn,
    );
    await _bounce.animateTo(
      1.0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.elasticOut,
    );
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _bounce,
        builder: (_, i) => Transform.scale(
          scale: _bounce.value,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            width: widget.isSelected ? 46 : 40,
            height: widget.isSelected ? 46 : 40,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? context.colorScheme.primary.withValues(alpha: 0.14)
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                widget.emoji,
                textScaler: TextScaler.noScaling,
                style: _emojiStyle(widget.isSelected ? 27 : 22),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ContextMenu extends StatelessWidget {
  final bool isMe;
  final MessageType messageType;
  final VoidCallback onReply;
  final VoidCallback? onCopy;
  final VoidCallback? onDelete;
  final bool isDark;

  const _ContextMenu({
    required this.isMe,
    required this.messageType,
    required this.onReply,
    required this.isDark,
    this.onCopy,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final items = <_MenuItemData>[
      _MenuItemData(
        icon: SolarIconsOutline.reply,
        label: context.locale.reply,
        onTap: onReply,
      ),
      if (onCopy != null)
        _MenuItemData(
          icon: SolarIconsOutline.copy,
          label: context.locale.copy,
          onTap: onCopy!,
        ),
      if (isMe && onDelete != null)
        _MenuItemData(
          icon: SolarIconsOutline.trashBinMinimalistic,
          label: context.locale.delete,
          onTap: onDelete!,
          isDestructive: true,
        ),
    ];

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (i > 0)
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.07),
                  ),
                _MenuTile(data: item, isDark: isDark),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MenuItemData({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });
}

class _MenuTile extends StatefulWidget {
  final _MenuItemData data;
  final bool isDark;
  const _MenuTile({required this.data, required this.isDark});

  @override
  State<_MenuTile> createState() => _MenuTileState();
}

class _MenuTileState extends State<_MenuTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.data.isDestructive
        ? context.colorScheme.error
        : context.colorScheme.onSurface;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.data.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        color: _pressed
            ? (widget.isDark
                  ? Colors.white.withValues(alpha: 0.07)
                  : Colors.black.withValues(alpha: 0.05))
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.data.icon, size: 19, color: color),
            const SizedBox(width: 13),
            Expanded(
              child: AppText(
                widget.data.label,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReactionSummaryChip extends StatelessWidget {
  final Map<String, String> reactions;
  final String currentUid;
  final bool isMe;
  final VoidCallback? onTap;

  const ReactionSummaryChip({
    super.key,
    required this.reactions,
    required this.currentUid,
    required this.isMe,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (reactions.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iReacted = reactions.containsKey(currentUid);

    final counts = <String, int>{};
    for (final emoji in reactions.values) {
      counts[emoji] = (counts[emoji] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topEmojis = sorted.take(3).map((e) => e.key).toList();
    final total = reactions.length;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: iReacted
              ? context.colorScheme.primary.withValues(alpha: 0.12)
              : (isDark ? const Color(0xFF2C2C2E) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: iReacted
                ? context.colorScheme.primary.withValues(alpha: 0.30)
                : (isDark
                      ? Colors.white.withValues(alpha: 0.10)
                      : Colors.black.withValues(alpha: 0.08)),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...topEmojis.map(
              (e) => Text(
                e,
                textScaler: TextScaler.noScaling,
                style: _emojiStyle(13),
              ),
            ),
            const SizedBox(width: 3),
            Text(
              '$total',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: iReacted
                    ? context.colorScheme.primary
                    : context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BubbleWithReactions extends StatelessWidget {
  final Widget bubble;
  final MessageModel message;
  final bool isMe;
  final String currentUid;
  final VoidCallback onReply;
  final VoidCallback? onDelete;
  final ValueChanged<String?> onReact;

  const BubbleWithReactions({
    super.key,
    required this.bubble,
    required this.message,
    required this.isMe,
    required this.currentUid,
    required this.onReply,
    required this.onReact,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hasReactions = message.reactions.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(bottom: hasReactions ? 14.0 : 0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          MessageReactionOverlay(
            message: message,
            isMe: isMe,
            currentUid: currentUid,
            onReply: onReply,
            onReact: onReact,
            onDelete: isMe && !message.isDeleted ? onDelete : null,
            child: bubble,
          ),
          if (hasReactions)
            Positioned(
              bottom: -12,
              left: isMe ? null : 18,
              right: isMe ? 18 : null,
              child: ReactionSummaryChip(
                reactions: message.reactions,
                currentUid: currentUid,
                isMe: isMe,
              ),
            ),
        ],
      ),
    );
  }
}
