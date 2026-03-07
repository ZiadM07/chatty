import 'package:Chatty/core/constants/exports.dart';

class AddStoryBottomControlBar extends StatelessWidget {
  final bool hasMedia;
  final bool isUploading;
  final VoidCallback onPickMedia;
  final VoidCallback? onPost;

  const AddStoryBottomControlBar({
    super.key,
    required this.hasMedia,
    required this.isUploading,
    required this.onPickMedia,
    this.onPost,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            Expanded(
              child: _MediaPickerButton(
                isUploading: isUploading,
                onTap: onPickMedia,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _PostButton(
                hasMedia: hasMedia,
                isUploading: isUploading,
                onTap: onPost,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MediaPickerButton extends StatelessWidget {
  final bool isUploading;
  final VoidCallback onTap;

  const _MediaPickerButton({required this.isUploading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isUploading ? null : onTap,
      child: Container(
        padding: const AppPadding.set(all: 10),
        decoration: BoxDecoration(
          borderRadius: AppBorderRadius.set(all: 24),
          color: context.colorScheme.outline.withValues(alpha: 0.2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(SolarIconsOutline.galleryAdd, size: 20),
            const SizedBox(height: 4),
            AppText(
              context.locale.chooseMedia,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostButton extends StatelessWidget {
  final bool hasMedia;
  final bool isUploading;
  final VoidCallback? onTap;

  const _PostButton({
    required this.hasMedia,
    required this.isUploading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isUploading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const AppPadding.set(all: 10),
        decoration: BoxDecoration(
          borderRadius: AppBorderRadius.set(all: 24),
          gradient: hasMedia
              ? LinearGradient(
                  colors: [
                    context.colorScheme.primary,
                    context.colorScheme.secondary,
                  ],
                )
              : null,
          color: hasMedia
              ? null
              : context.colorScheme.outline.withValues(alpha: 0.2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PostIcon(hasMedia: hasMedia, isUploading: isUploading),
            const SizedBox(height: 4),
            AppText(
              context.locale.post,
              style: context.textTheme.bodyMedium?.copyWith(
                color: hasMedia
                    ? Colors.white
                    : context.colorScheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostIcon extends StatelessWidget {
  final bool hasMedia;
  final bool isUploading;

  const _PostIcon({required this.hasMedia, required this.isUploading});

  @override
  Widget build(BuildContext context) {
    if (isUploading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      );
    }
    return Icon(
      Icons.rocket_launch_rounded,
      size: 20,
      color: hasMedia ? Colors.white : context.colorScheme.onSurface,
    );
  }
}
