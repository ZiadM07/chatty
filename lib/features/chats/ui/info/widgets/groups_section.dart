import 'package:Chatty/config/router/app_router.gr.dart';
import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/features/chats/data/models/chat_model.dart';
import 'package:Chatty/features/shared/widgets/app_image.dart';
import 'package:Chatty/features/shared/widgets/profile_placeholder.dart';
import 'package:Chatty/features/users/ui/widgets/create_group_bottom_sheet.dart';
import 'package:Chatty/features/auth/data/models/user_model.dart';

/// Displays common groups between the current user and another user.
/// Shows a "Create group" CTA when no common groups exist,
/// or the list of shared groups when they do.
class GroupsSection extends StatelessWidget {
  final List<ChatModel> groups;
  final String currentUid;
  final UserModel? otherUser;

  const GroupsSection({
    super.key,
    required this.groups,
    required this.currentUid,
    this.otherUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppPadding.set(horizontal: 16),
      padding: AppPadding.set(bottom: 20, top: 10),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHigh,
        borderRadius: AppBorderRadius.set(all: 18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(groupCount: groups.length),
          _CreateGroupCard(
            userName: otherUser?.displayName ?? '',
            otherUser: otherUser,
          ),
          const SizedBox(height: 10),
          if (groups.isNotEmpty)
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              child: Column(
                children: groups
                    .map((group) => _GroupItem(group: group))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final int groupCount;

  const _SectionHeader({required this.groupCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: AppPadding.set(all: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.colorScheme.primary,
                context.colorScheme.secondary,
              ],
            ),
            borderRadius: AppBorderRadius.set(all: 12),
          ),
          child: Icon(
            SolarIconsOutline.usersGroupRounded,
            color: context.colorScheme.onPrimary,
          ),
        ),
        const SizedBox(width: 12),
        AppText(
          context.locale.groupsInCommon(groupCount),
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ).addPadding(horizontal: 15, vertical: 10);
  }
}

class _CreateGroupCard extends StatelessWidget {
  final String userName;
  final UserModel? otherUser;

  const _CreateGroupCard({required this.userName, this.otherUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppPadding.set(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.colorScheme.primary.withValues(alpha: 0.4),
            context.colorScheme.secondary.withValues(alpha: 0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppBorderRadius.set(all: 20),
      ),
      child: Row(
        children: [
          Container(
            padding: AppPadding.set(all: 12),
            margin: AppPadding.set(all: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: AppBorderRadius.set(all: 14),
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
                const SizedBox(height: 10),
                AppText(
                  context.locale.createGroupWith(userName),
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
                const SizedBox(height: 10),
              ],
            ),
          ),
          Container(
            padding: AppPadding.set(all: 6),
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
          const SizedBox(width: 10),
        ],
      ),
    ).addAction(
      onTap: () =>
          CreateGroupBottomSheet.show(context, preSelectedUser: otherUser),
    );
  }
}

class _GroupItem extends StatelessWidget {
  final ChatModel group;

  const _GroupItem({required this.group});

  @override
  Widget build(BuildContext context) {
    return Row(
          children: [
            group.groupPhotoUrl != null
                ? AppImage(
                    imageUrl: group.groupPhotoUrl!,
                    width: 50,
                    height: 50,
                    borderRadius: 100,
                  )
                : ProfilePlaceholder(
                    name: group.groupName ?? 'group',
                    size: 50,
                  ),

            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    group.groupName ?? '',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    '${group.memberIds.length} ${context.locale.members}',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.textSecondary,
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
        )
        .addPadding(horizontal: 15, vertical: 10)
        .addAction(
          onTap: () => context.router.push(ChatRoute(chatId: group.id)),
        );
  }
}
