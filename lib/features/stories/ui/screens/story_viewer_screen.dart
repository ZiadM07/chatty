import 'dart:async';

import 'package:chatty/core/constants/exports.dart';
import 'package:chatty/core/di/injectable.dart';
import 'package:chatty/core/utils/enums.dart';
import 'package:chatty/features/auth/cubits/auth_cubit.dart';
import 'package:chatty/features/shared/widgets/app_image.dart';
import 'package:chatty/features/stories/cubits/story_viewer_cubit.dart';
import 'package:chatty/config/router/app_router.gr.dart';
import 'package:chatty/features/shared/widgets/app_toast.dart';
import 'package:chatty/features/stories/data/models/story_item_model.dart';
import 'package:chatty/features/stories/data/models/story_model.dart';
import 'package:chatty/features/users/data/repositories/users_repository.dart';

const _kItemDuration = Duration(seconds: 15);

// ─────────────────────────────────────────────────────────────────────────────
//  StoryViewerScreen
// ─────────────────────────────────────────────────────────────────────────────

@RoutePage()
class StoryViewerScreen extends StatefulWidget implements AutoRouteWrapper {
  final String ownerUid;
  const StoryViewerScreen({super.key, required this.ownerUid});

  @override
  Widget wrappedRoute(BuildContext context) =>
      BlocProvider(create: (_) => getIt<StoryViewerCubit>(), child: this);

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen>
    with TickerProviderStateMixin {
  late final AnimationController _progressCtrl;
  late final PageController _pageCtrl;
  Timer? _timer;
  late String _currentUid;

  // ── Entry animation ──────────────────────────────────────────────────────
  late final AnimationController _entryCtrl;
  late final Animation<double> _entryScale;
  late final Animation<double> _entryOpacity;

  @override
  void initState() {
    super.initState();
    _currentUid = context.read<AuthCubit>().state.currentUser?.uid ?? '';

    _pageCtrl = PageController();

    _progressCtrl = AnimationController(vsync: this, duration: _kItemDuration);

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _entryScale = Tween<double>(
      begin: 0.88,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));
    _entryOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut));
    _entryCtrl.forward();

    context.read<StoryViewerCubit>().loadStory(
      ownerUid: widget.ownerUid,
      currentUid: _currentUid,
    );
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    _pageCtrl.dispose();
    _entryCtrl.dispose();
    _timer?.cancel();
    super.dispose();
  }

  // ─── Progress control ─────────────────────────────────────────────────────

  void _startProgress() {
    _timer?.cancel();
    _progressCtrl.reset();
    _progressCtrl.forward();
    _timer = Timer(_kItemDuration, _advance);
  }

  void _advance() {
    final cubit = context.read<StoryViewerCubit>();
    final hasNext = cubit.nextItem(currentUid: _currentUid);
    if (!hasNext) {
      _exitAndPop();
      return;
    }
    _pageCtrl.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
    _startProgress();
  }

  Future<void> _exitAndPop() async {
    await _entryCtrl.reverse();
    if (mounted) context.router.maybePop();
  }

  // ─── Tap zones ────────────────────────────────────────────────────────────

  void _onTapLeft() {
    final cubit = context.read<StoryViewerCubit>();
    if (cubit.state.isFirstItem) {
      _exitAndPop();
      return;
    }
    cubit.previousItem();
    _pageCtrl.previousPage(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
    _startProgress();
  }

  void _onTapRight() => _advance();

  // ─── Long press pause / resume ────────────────────────────────────────────

  void _onHoldStart(LongPressStartDetails _) {
    _timer?.cancel();
    _progressCtrl.stop();
    context.read<StoryViewerCubit>().pause();
  }

  void _onHoldEnd(LongPressEndDetails _) {
    context.read<StoryViewerCubit>().resume();
    _progressCtrl.forward();
    final remaining = _kItemDuration * (1 - _progressCtrl.value);
    _timer = Timer(remaining, _advance);
  }

  // ─── Time helper ─────────────────────────────────────────────────────────

  String _timeAgo(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inSeconds < 60) return 'just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StoryViewerCubit, StoryViewerState>(
      listenWhen: (p, c) =>
          p.storyState.status != c.storyState.status ||
          p.currentIndex != c.currentIndex ||
          p.replyState.status != c.replyState.status,
      listener: (context, state) {
        if (state.storyState.status == StateStatus.success &&
            state.story != null) {
          _startProgress();
        }
        if (state.replyState.status == StateStatus.success) {
          context.read<StoryViewerCubit>().resetReplyState();
          // Navigate to the chat the reply was sent in
          final chatId = state.replyState.data;
          if (chatId != null) {
            context.router.push(ChatRoute(chatId: chatId));
          }
        }
        if (state.replyState.status == StateStatus.error) {
          context.read<StoryViewerCubit>().resetReplyState();
          AppToast.showError(
            message: state.replyState.message ?? 'Failed to send reply.',
            context: context,
          );
        }
      },
      builder: (context, state) =>
          Scaffold(backgroundColor: Colors.black, body: _body(context, state)),
    );
  }

  Widget _body(BuildContext context, StoryViewerState state) {
    if (state.storyState.status == StateStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white54, strokeWidth: 2),
      );
    }

    if (state.storyState.status == StateStatus.error || state.story == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.broken_image_outlined,
              color: Colors.white30,
              size: 56,
            ),
            const SizedBox(height: 16),
            Text(
              state.storyState.message ?? 'No story found',
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 20),
            _GlassButton(label: 'Go back', onTap: _exitAndPop),
          ],
        ),
      );
    }

    final story = state.story!;
    final item = state.currentItem!;
    final isOwner = widget.ownerUid == _currentUid;

    return AnimatedBuilder(
      animation: _entryCtrl,
      builder: (_, child) => Opacity(
        opacity: _entryOpacity.value,
        child: Transform.scale(scale: _entryScale.value, child: child),
      ),
      child: GestureDetector(
        onLongPressStart: _onHoldStart,
        onLongPressEnd: _onHoldEnd,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Media ──────────────────────────────────────────────────────
            PageView.builder(
              controller: _pageCtrl,
              itemCount: story.items.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (_, i) => _MediaPage(item: story.items[i]),
            ),

            // ── Top scrim ──────────────────────────────────────────────────
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _Scrim(fromTop: true, height: 220),
            ),

            // ── Bottom scrim ───────────────────────────────────────────────
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _Scrim(fromTop: false, height: 240),
            ),

            // ── Tap zones (sit above scrims, below chrome) ─────────────────
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: _onTapLeft,
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: _onTapRight,
                  ),
                ),
              ],
            ),

            // ── Top chrome ────────────────────────────────────────────────
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Progress bars
                    Row(
                      children: List.generate(story.items.length, (i) {
                        return Expanded(
                          child: _ProgressSegment(
                            isPast: i < state.currentIndex,
                            isCurrent: i == state.currentIndex,
                            controller: i == state.currentIndex
                                ? _progressCtrl
                                : null,
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 14),

                    // Header: avatar / name / time / close
                    _Header(
                      story: story,
                      timeAgo: _timeAgo(item.createdAt),
                      isPaused: state.isPaused,
                      onClose: _exitAndPop,
                    ),
                  ],
                ),
              ),
            ),

            // ── Caption ───────────────────────────────────────────────────
            if (item.caption != null && item.caption!.isNotEmpty)
              Positioned(
                left: 20,
                right: 20,
                bottom: isOwner ? 130 : 100,
                child: _Caption(text: item.caption!),
              ),

            // ── Owner: viewers bar ─────────────────────────────────────────
            if (isOwner)
              Positioned(
                bottom: 32,
                left: 16,
                right: 16,
                child: _ViewersBar(
                  item: item,
                  onTap: () => _showViewersSheet(context, item),
                ),
              ),

            // ── Viewer: like + reply bar ───────────────────────────────────
            if (!isOwner)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _ViewerBottomBar(
                  item: item,
                  currentUid: _currentUid,
                  isReplying: state.replyState.status == StateStatus.loading,
                  onLike: () => context.read<StoryViewerCubit>().toggleLike(
                    viewerUid: _currentUid,
                  ),
                  onReply: (text) => context
                      .read<StoryViewerCubit>()
                      .replyToStory(senderUid: _currentUid, replyText: text),
                  onFocusChanged: (hasFocus) {
                    if (hasFocus) {
                      _timer?.cancel();
                      _progressCtrl.stop();
                      context.read<StoryViewerCubit>().pause();
                    } else {
                      context.read<StoryViewerCubit>().resume();
                      _progressCtrl.forward();
                      final remaining =
                          _kItemDuration * (1 - _progressCtrl.value);
                      _timer = Timer(remaining, _advance);
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── Viewers bottom sheet ─────────────────────────────────────────────────

  void _showViewersSheet(BuildContext context, StoryItemModel item) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ViewersSheet(viewerIds: item.viewerIds),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Media page
// ─────────────────────────────────────────────────────────────────────────────

class _MediaPage extends StatelessWidget {
  final StoryItemModel item;
  const _MediaPage({required this.item});

  @override
  Widget build(BuildContext context) {
    switch (item.type) {
      case StoryItemType.image:
        return AppImage(
          imageUrl: item.url,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        );

      case StoryItemType.video:
        // TODO: VideoPlayer — placeholder for now
        return Container(
          color: Colors.black,
          child: Center(
            child: Icon(
              Icons.videocam_rounded,
              size: 80,
              color: Colors.white.withValues(alpha: 0.25),
            ),
          ),
        );

      case StoryItemType.text:
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: item.backgroundColor != null
                  ? [
                      item.backgroundColor!,
                      item.backgroundColor!.withValues(alpha: 0.6),
                    ]
                  : [
                      context.colorScheme.primary,
                      context.colorScheme.secondary,
                    ],
            ),
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(40),
          child: Text(
            item.caption ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              height: 1.35,
              letterSpacing: -0.5,
            ),
          ),
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Gradient scrims
// ─────────────────────────────────────────────────────────────────────────────

class _Scrim extends StatelessWidget {
  final bool fromTop;
  final double height;
  const _Scrim({required this.fromTop, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: fromTop ? Alignment.topCenter : Alignment.bottomCenter,
          end: fromTop ? Alignment.bottomCenter : Alignment.topCenter,
          colors: const [Colors.black87, Colors.transparent],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Progress segments
// ─────────────────────────────────────────────────────────────────────────────

class _ProgressSegment extends StatelessWidget {
  final bool isPast;
  final bool isCurrent;
  final AnimationController? controller;
  const _ProgressSegment({
    required this.isPast,
    required this.isCurrent,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2.5,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: Colors.white.withValues(alpha: 0.25),
      ),
      clipBehavior: Clip.hardEdge,
      child: isPast
          ? _fill(context, 1.0)
          : isCurrent && controller != null
          ? AnimatedBuilder(
              animation: controller!,
              builder: (_, child) => _fill(context, controller!.value),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _fill(BuildContext context, double fraction) => FractionallySizedBox(
    alignment: Alignment.centerLeft,
    widthFactor: fraction,
    child: DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [context.colorScheme.primary, context.colorScheme.secondary],
        ),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  Header row
// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final StoryModel story;
  final String timeAgo;
  final bool isPaused;
  final VoidCallback onClose;

  const _Header({
    required this.story,
    required this.timeAgo,
    required this.isPaused,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar with gradient ring
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                context.colorScheme.primary,
                context.colorScheme.secondary,
              ],
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            child: AppImage(
              imageUrl: story.photoUrl ?? AppConstants.fakeUserImage,
              width: 38,
              height: 38,
              borderRadius: 100,
            ),
          ),
        ),

        const SizedBox(width: 10),

        // Name + time
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                story.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                timeAgo,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),

        // Paused badge
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isPaused
              ? Container(
                  key: const ValueKey('paused'),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.pause_rounded,
                        color: Colors.white,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Paused',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('playing')),
        ),

        // Close button
        GestureDetector(
          onTap: onClose,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white12),
            ),
            child: const Icon(
              Icons.close_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Caption overlay
// ─────────────────────────────────────────────────────────────────────────────

class _Caption extends StatelessWidget {
  final String text;
  const _Caption({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          height: 1.45,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Viewers bar (owner only)
// ─────────────────────────────────────────────────────────────────────────────

class _ViewersBar extends StatelessWidget {
  final StoryItemModel item;
  final VoidCallback onTap;

  const _ViewersBar({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        ),
        child: Row(
          children: [
            // Icon chip
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.colorScheme.primary.withValues(alpha: 0.8),
                    context.colorScheme.secondary.withValues(alpha: 0.8),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.visibility_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 14),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${item.viewCount} views',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  'Tap to see who viewed',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const Spacer(),

            Icon(
              Icons.keyboard_arrow_up_rounded,
              color: Colors.white.withValues(alpha: 0.5),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Viewers bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _ViewersSheet extends StatelessWidget {
  final List<String> viewerIds;
  const _ViewersSheet({required this.viewerIds});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),

          // Handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: context.colorScheme.outline.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  '${viewerIds.length} viewers',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          if (viewerIds.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(
                    Icons.visibility_off_rounded,
                    size: 40,
                    color: context.colorScheme.outline.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No views yet',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.45,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: viewerIds.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: context.colorScheme.outline.withValues(alpha: 0.08),
                ),
                itemBuilder: (_, i) => _ViewerTile(uid: viewerIds[i]),
              ),
            ),
        ],
      ),
    );
  }
}

class _ViewerTile extends StatefulWidget {
  final String uid;
  const _ViewerTile({required this.uid});

  @override
  State<_ViewerTile> createState() => _ViewerTileState();
}

class _ViewerTileState extends State<_ViewerTile> {
  String? _name;
  String? _photo;

  @override
  void initState() {
    super.initState();
    getIt<UsersRepository>().getUserById(uid: widget.uid).then((u) {
      if (mounted) {
        setState(() {
          _name = u?.displayName;
          _photo = u?.photoUrl;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          AppImage(
            imageUrl: _photo ?? AppConstants.fakeUserImage,
            width: 44,
            height: 44,
            borderRadius: 100,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _name ?? '...',
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Glass button — used in error state
// ─────────────────────────────────────────────────────────────────────────────

class _GlassButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _GlassButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white24),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Viewer bottom bar — like + reply (non-owner only)
// ─────────────────────────────────────────────────────────────────────────────

class _ViewerBottomBar extends StatefulWidget {
  final StoryItemModel item;
  final String currentUid;
  final bool isReplying;
  final void Function() onLike;
  final ValueChanged<String> onReply;
  final ValueChanged<bool> onFocusChanged;

  const _ViewerBottomBar({
    required this.item,
    required this.currentUid,
    required this.isReplying,
    required this.onLike,
    required this.onReply,
    required this.onFocusChanged,
  });

  @override
  State<_ViewerBottomBar> createState() => _ViewerBottomBarState();
}

class _ViewerBottomBarState extends State<_ViewerBottomBar> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final has = _controller.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
    _focus.addListener(() => widget.onFocusChanged(_focus.hasFocus));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _send() {
    if (!_hasText) return;
    widget.onReply(_controller.text);
    _controller.clear();
    _focus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final isLiked = widget.item.isLikedBy(widget.currentUid);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: [
            // ── Reply input field ──────────────────────────────────────────
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focus,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        cursorColor: Colors.white,
                        maxLines: 1,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                        decoration: InputDecoration(
                          hintText: 'Reply to story...',
                          hintStyle: context.textTheme.bodyMedium?.copyWith(
                            color: context.colorScheme.textSecondary,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),

                    // Send button — only visible when typing
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: _hasText
                          ? GestureDetector(
                              key: const ValueKey('send'),
                              onTap: widget.isReplying ? null : _send,
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
                                child: widget.isReplying
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
                                    : const Icon(
                                        Icons.send_rounded,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                              ),
                            )
                          : const SizedBox.shrink(key: ValueKey('empty')),
                    ),
                    if (!_hasText) const SizedBox(width: 12),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 10),

            // ── Like button ────────────────────────────────────────────────
            GestureDetector(
              onTap: widget.onLike,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.elasticOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Container(
                  key: ValueKey(isLiked),
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
                  child: Icon(
                    isLiked ? SolarIconsBold.heart : SolarIconsOutline.heart,
                    color: isLiked ? context.colorScheme.primary : Colors.white,
                    size: 22,
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
