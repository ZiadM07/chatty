import 'package:chatty/core/constants/exports.dart';
import 'package:chatty/features/shared/widgets/app_image.dart';

class GroupsSection extends StatelessWidget {
  const GroupsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.only(bottom: 20, top: 10),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
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
                  SolarIconsOutline.usersGroupRounded,
                  color: context.colorScheme.onPrimary,
                ),
              ),
              const SizedBox(width: 12),
              AppText(
                context.locale.groupsInCommon(3),
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ).addPadding(horizontal: 15, vertical: 10),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  context.colorScheme.primary.withValues(alpha: 0.4),
                  context.colorScheme.secondary.withValues(alpha: 0.4),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    SolarIconsOutline.usersGroupRounded,
                    color: context.colorScheme.onPrimary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      AppText(
                        context.locale.createGroupWith('Ziad Ahmed'),

                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      AppText(
                        context.locale.startNewCommunity,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.onPrimary.withValues(
                            alpha: 0.75,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: context.colorScheme.onPrimary,
                    size: 18,
                  ),
                ),
                SizedBox(width: 10),
              ],
            ),
          ),
          SizedBox(height: 10),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,

            child: Column(children: List.generate(3, (index) => _GroupItem())),
          ),
        ],
      ),
    );
  }
}

class _GroupItem extends StatelessWidget {
  const _GroupItem();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppImage(
          imageUrl: AppConstants.fakeUserImage,
          width: 50,
          height: 50,
          borderRadius: 100,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                'Group Name',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              AppText(
                'Members',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onPrimary.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.chevron_right_rounded,
          color: context.colorScheme.onSurfaceVariant,
        ),
      ],
    ).addPadding(horizontal: 15, vertical: 10);
  }
}
