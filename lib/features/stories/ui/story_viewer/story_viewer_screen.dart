import 'dart:async';

import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/core/di/injectable.dart';
import 'package:Chatty/features/auth/cubits/auth_cubit.dart';
import 'package:Chatty/features/stories/cubits/story_viewer_cubit.dart';
import 'package:Chatty/config/router/app_router.gr.dart';
import 'package:Chatty/features/shared/widgets/app_toast.dart';
import 'package:Chatty/features/stories/data/models/story_item_model.dart';
import 'package:Chatty/features/stories/ui/story_viewer/widgets/story_caption.dart';
import 'package:Chatty/features/stories/ui/story_viewer/widgets/story_glass_button.dart';
import 'package:Chatty/features/stories/ui/story_viewer/widgets/story_header.dart';
import 'package:Chatty/features/stories/ui/story_viewer/widgets/story_media_page.dart';
import 'package:Chatty/features/stories/ui/story_viewer/widgets/story_progress_bar.dart';
import 'package:Chatty/features/stories/ui/story_viewer/widgets/story_viewer_bottom_bar.dart';
import 'package:Chatty/features/stories/ui/story_viewer/widgets/story_viewers_bar.dart';
import 'package:Chatty/features/stories/ui/story_viewer/widgets/story_viewers_sheet.dart';

const _kItemDuration = Duration(seconds: 15);

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
  late final AnimationController _entryCtrl;
  late final Animation<double> _entryScale;
  late final Animation<double> _entryOpacity;
  Timer? _timer;
  late String _currentUid;

  @override
  void initState() {
    super.initState();
    _currentUid = context.read<AuthCubit>().state.currentUser?.uid ?? '';
    _pageCtrl = PageController();
    _progressCtrl = AnimationController(vsync: this, duration: _kItemDuration);
    _setupEntryAnimation();

    context.read<StoryViewerCubit>().loadStory(
      ownerUid: widget.ownerUid,
      currentUid: _currentUid,
    );
  }

  void _setupEntryAnimation() {
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
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    _pageCtrl.dispose();
    _entryCtrl.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startProgress() {
    _timer?.cancel();
    _progressCtrl.reset();
    _progressCtrl.forward();
    _timer = Timer(_kItemDuration, _advance);
  }

  void _resumeProgress() {
    _progressCtrl.forward();
    final remaining = _kItemDuration * (1 - _progressCtrl.value);
    _timer = Timer(remaining, _advance);
  }

  void _pauseProgress() {
    _timer?.cancel();
    _progressCtrl.stop();
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

  void _goBack() {
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

  Future<void> _exitAndPop() async {
    await _entryCtrl.reverse();
    if (mounted) context.router.maybePop();
  }

  void _onTapLeft() => _goBack();
  void _onTapRight() => _advance();

  void _onHoldStart(LongPressStartDetails _) {
    _pauseProgress();
    context.read<StoryViewerCubit>().pause();
    HapticFeedback.selectionClick();
  }

  void _onHoldEnd(LongPressEndDetails _) {
    context.read<StoryViewerCubit>().resume();
    _resumeProgress();
  }

  void _onSwipeDown() => _exitAndPop();

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return context.locale.justNow;
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} ${context.locale.minute} ${context.locale.ago}';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours} ${context.locale.hour} ${context.locale.ago}';
    }
    return '${diff.inDays} ${context.locale.day} ${context.locale.ago}';
  }

  void _showViewersSheet(BuildContext context, StoryItemModel item) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) =>
          StoryViewersSheet(viewerIds: item.viewerIds, likeIds: item.likeIds),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StoryViewerCubit, StoryViewerState>(
      listenWhen: (p, c) =>
          p.storyState.status != c.storyState.status ||
          p.currentIndex != c.currentIndex ||
          p.replyState.status != c.replyState.status,
      listener: _onStateChanged,
      builder: (context, state) =>
          Scaffold(backgroundColor: Colors.black, body: _body(context, state)),
    );
  }

  void _onStateChanged(BuildContext context, StoryViewerState state) {
    if (state.storyState.status == StateStatus.success && state.story != null) {
      _startProgress();
    }

    if (state.replyState.status == StateStatus.success) {
      context.read<StoryViewerCubit>().resetReplyState();
      final chatId = state.replyState.data;
      if (chatId != null) context.router.push(ChatRoute(chatId: chatId));
    }

    if (state.replyState.status == StateStatus.error) {
      context.read<StoryViewerCubit>().resetReplyState();
      AppToast.showError(
        message: context.locale.thisOperationFailed,
        context: context,
      );
    }
  }

  Widget _body(BuildContext context, StoryViewerState state) {
    if (state.storyState.status == StateStatus.loading) {
      return const _LoadingView();
    }

    if (state.storyState.status == StateStatus.error || state.story == null) {
      return _ErrorView(message: state.storyState.message, onBack: _exitAndPop);
    }

    return _StoryContent(
      state: state,
      entryCtrl: _entryCtrl,
      entryScale: _entryScale,
      entryOpacity: _entryOpacity,
      progressCtrl: _progressCtrl,
      pageCtrl: _pageCtrl,
      currentUid: _currentUid,
      isOwner: widget.ownerUid == _currentUid,
      timeAgo: _timeAgo(state.currentItem!.createdAt),
      onTapLeft: _onTapLeft,
      onTapRight: _onTapRight,
      onHoldStart: _onHoldStart,
      onHoldEnd: _onHoldEnd,
      onSwipeDown: _onSwipeDown,
      onClose: _exitAndPop,
      onShowViewers: () => _showViewersSheet(context, state.currentItem!),
      onLike: () =>
          context.read<StoryViewerCubit>().toggleLike(viewerUid: _currentUid),
      onReply: (text) => context.read<StoryViewerCubit>().replyToStory(
        senderUid: _currentUid,
        replyText: text,
      ),
      onReplyFocusChanged: (hasFocus) {
        if (hasFocus) {
          _pauseProgress();
          context.read<StoryViewerCubit>().pause();
        } else {
          context.read<StoryViewerCubit>().resume();
          _resumeProgress();
        }
      },
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: context.colorScheme.textSecondary,
        strokeWidth: 2,
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String? message;
  final VoidCallback onBack;

  const _ErrorView({this.message, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.broken_image_outlined,
            color: context.colorScheme.textSecondary,
            size: 56,
          ),
          const SizedBox(height: 16),
          AppText(
            message ?? context.locale.noStoryFound,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          StoryGlassButton(
            label: context.locale.goBack,
            onTap: onBack,
            icon: Icons.arrow_back_rounded,
          ),
        ],
      ),
    );
  }
}

class _StoryContent extends StatelessWidget {
  final StoryViewerState state;
  final AnimationController entryCtrl;
  final Animation<double> entryScale;
  final Animation<double> entryOpacity;
  final AnimationController progressCtrl;
  final PageController pageCtrl;
  final String currentUid;
  final bool isOwner;
  final String timeAgo;
  final VoidCallback onTapLeft;
  final VoidCallback onTapRight;
  final void Function(LongPressStartDetails) onHoldStart;
  final void Function(LongPressEndDetails) onHoldEnd;
  final VoidCallback onSwipeDown;
  final VoidCallback onClose;
  final VoidCallback onShowViewers;
  final VoidCallback onLike;
  final ValueChanged<String> onReply;
  final ValueChanged<bool> onReplyFocusChanged;

  const _StoryContent({
    required this.state,
    required this.entryCtrl,
    required this.entryScale,
    required this.entryOpacity,
    required this.progressCtrl,
    required this.pageCtrl,
    required this.currentUid,
    required this.isOwner,
    required this.timeAgo,
    required this.onTapLeft,
    required this.onTapRight,
    required this.onHoldStart,
    required this.onHoldEnd,
    required this.onSwipeDown,
    required this.onClose,
    required this.onShowViewers,
    required this.onLike,
    required this.onReply,
    required this.onReplyFocusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final story = state.story!;
    final item = state.currentItem!;

    return AnimatedBuilder(
      animation: entryCtrl,
      builder: (_, child) => Opacity(
        opacity: entryOpacity.value,
        child: Transform.scale(scale: entryScale.value, child: child),
      ),
      child: GestureDetector(
        onLongPressStart: onHoldStart,
        onLongPressEnd: onHoldEnd,
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null &&
              details.primaryVelocity! > 300) {
            onSwipeDown();
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: pageCtrl,
              itemCount: story.items.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (_, i) => StoryMediaPage(item: story.items[i]),
            ),

            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _Scrim(fromTop: true, height: 220),
            ),
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _Scrim(fromTop: false, height: 240),
            ),

            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: onTapLeft,
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: onTapRight,
                    onDoubleTap: onTapRight,
                  ),
                ),
              ],
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StoryProgressBar(
                      itemCount: story.items.length,
                      currentIndex: state.currentIndex,
                      progressController: progressCtrl,
                    ),
                    const SizedBox(height: 14),
                    StoryHeader(
                      story: story,
                      timeAgo: timeAgo,
                      isPaused: state.isPaused,
                      onClose: onClose,
                    ),
                  ],
                ),
              ),
            ),

            if (item.caption != null && item.caption!.isNotEmpty)
              Positioned(
                left: 20,
                right: 20,
                bottom: isOwner ? 130 : 100,
                child: StoryCaption(text: item.caption!),
              ),

            if (isOwner)
              Positioned(
                bottom: 32,
                left: 16,
                right: 16,
                child: StoryViewersBar(item: item, onTap: onShowViewers),
              ),

            if (!isOwner)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: StoryViewerBottomBar(
                  item: item,
                  currentUid: currentUid,
                  isReplying: state.replyState.status == StateStatus.loading,
                  onLike: onLike,
                  onReply: onReply,
                  onFocusChanged: onReplyFocusChanged,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

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
        ),
      ),
    );
  }
}
