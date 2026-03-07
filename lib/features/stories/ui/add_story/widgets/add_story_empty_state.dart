import 'package:Chatty/core/constants/exports.dart';

class AddStoryEmptyState extends StatelessWidget {
  const AddStoryEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
            context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
            context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _EmptyIcon(),
            const SizedBox(height: 32),
            AppText(
              context.locale.createYourStory,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            AppText(
              context.locale.shareMomentWithFriends,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            _HintChip(),
          ],
        ),
      ),
    );
  }
}

class _EmptyIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const AppPadding.set(all: 32),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            context.colorScheme.primary.withValues(alpha: 0.3),
            context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          ],
        ),
      ),
      child: Icon(
        Icons.auto_awesome,
        size: 80,
        color: context.colorScheme.primary,
      ),
    );
  }
}

class _HintChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const AppPadding.set(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: AppText(
        context.locale.storyUploadHint,
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.colorScheme.textSecondary,
        ),
      ),
    );
  }
}
