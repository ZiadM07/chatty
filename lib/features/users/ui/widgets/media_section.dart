import 'package:chatty/core/constants/exports.dart';

class MediaSection extends StatelessWidget {
  const MediaSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.colorScheme.primary,
                context.colorScheme.secondary,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            SolarIconsOutline.fileText,
            color: context.colorScheme.onPrimary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                context.locale.mediaLinks,
                size: 15,
                weight: FontWeight.w600,
              ),
              AppText(
                context.locale.sharedFiles,
                size: 12,
                color: context.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.colorScheme.primary,
                context.colorScheme.secondary,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: AppText(
            '10',
            size: 14,
            color: context.colorScheme.onPrimary,
            weight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 8),
        Icon(Icons.chevron_right, color: context.colorScheme.onSurface),
      ],
    ).addPadding(horizontal: 20, vertical: 5);
  }
}
