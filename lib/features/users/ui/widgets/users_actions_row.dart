import 'package:chatty/core/constants/exports.dart';
import 'package:chatty/features/users/ui/widgets/create_group_bottom_sheet.dart';

class UsersActionsRow extends StatelessWidget {
  const UsersActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 50,

        children: [
          _UsersActionItem(
            icon: SolarIconsOutline.usersGroupRounded,
            title: context.locale.createGroup,
            onTap: () {
              CreateGroupBottomSheet.show(context);
            },
          ),
          _UsersActionItem(
            icon: SolarIconsOutline.paletteRound,
            title: context.locale.theme,
            onTap: () {},
          ),
          _UsersActionItem(
            icon: SolarIconsOutline.share,
            title: context.locale.inviteFriends,
            onTap: () {},
          ),
        ],
      ).addPadding(top: 15, bottom: 15),
    );
  }
}

class _UsersActionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _UsersActionItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainerHigh.withValues(
              alpha: 0.5,
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: context.colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: Icon(icon, size: 26, color: context.colorScheme.onSurface),
        ).addAction(onTap: onTap),
        SizedBox(height: 6),
        AppText(
          title,
          style: context.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: context.colorScheme.textSecondary,
            height: 1.5,
            letterSpacing: 0.1,
          ),
        ),
      ],
    ).addPadding(top: 10);
  }
}
