import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/features/shared/widgets/app_image.dart';
import 'package:Chatty/features/stories/data/models/story_model.dart';

import '../../../../shared/widgets/profile_placeholder.dart';

class StoryHeader extends StatelessWidget {
  final StoryModel story;
  final String timeAgo;
  final bool isPaused;
  final VoidCallback onClose;

  const StoryHeader({
    super.key,
    required this.story,
    required this.timeAgo,
    required this.isPaused,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Avatar(photoUrl: story.photoUrl, displayName: story.displayName),
        const SizedBox(width: 10),
        Expanded(
          child: _UserInfo(displayName: story.displayName, timeAgo: timeAgo),
        ),
        _PausedBadge(isPaused: isPaused),
        const SizedBox(width: 6),
        _CloseButton(onClose: onClose),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? photoUrl;
  final String displayName;

  const _Avatar({this.photoUrl, required this.displayName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [context.colorScheme.primary, context.colorScheme.secondary],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: const BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
        child: photoUrl != null
            ? AppImage(
                imageUrl: photoUrl!,
                width: 38,
                height: 38,
                borderRadius: 100,
              )
            : ProfilePlaceholder(name: displayName, size: 38),
      ),
    );
  }
}

class _UserInfo extends StatelessWidget {
  final String displayName;
  final String timeAgo;

  const _UserInfo({required this.displayName, required this.timeAgo});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText(
          displayName,
          style: context.textTheme.titleSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
          maxLines: 1,
        ),
        AppText(
          timeAgo,
          style: context.textTheme.labelSmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }
}

class _PausedBadge extends StatelessWidget {
  final bool isPaused;

  const _PausedBadge({required this.isPaused});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: isPaused
          ? Container(
              key: const ValueKey('paused'),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                  AppText(
                    context.locale.paused,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(key: ValueKey('playing')),
    );
  }
}

class _CloseButton extends StatelessWidget {
  final VoidCallback onClose;

  const _CloseButton({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white12),
        ),
        child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
      ),
    );
  }
}
