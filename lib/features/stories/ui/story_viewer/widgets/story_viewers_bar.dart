import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/features/stories/data/models/story_item_model.dart';

class StoryViewersBar extends StatelessWidget {
  final StoryItemModel item;
  final VoidCallback onTap;

  const StoryViewersBar({super.key, required this.item, required this.onTap});

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
            _ViewIcon(context: context),
            const SizedBox(width: 14),
            _ViewCount(item: item),
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

class _ViewIcon extends StatelessWidget {
  const _ViewIcon({required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class _ViewCount extends StatelessWidget {
  final StoryItemModel item;

  const _ViewCount({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText(
          '${item.viewCount} ${context.locale.views}',
          style: context.textTheme.titleSmall?.copyWith(
            color: context.colorScheme.onPrimary,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        AppText(
          context.locale.tapToSeeWhoViewed,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.onPrimary.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }
}
