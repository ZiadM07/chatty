import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/core/di/injectable.dart';
import 'package:Chatty/features/auth/data/models/user_model.dart';
import 'package:Chatty/features/chats/cubits/chat_info_cubit.dart';
import 'package:Chatty/features/chats/ui/info/widgets/add_members_sheet.dart';
import 'package:Chatty/features/shared/widgets/app_image.dart';
import 'package:Chatty/features/shared/widgets/profile_placeholder.dart';
import 'package:Chatty/features/users/data/repositories/users_repository.dart';

class GroupMembersSection extends StatelessWidget {
  final List<String> memberIds;
  final String currentUid;
  final String chatId;
  final bool isOwner;
  final String ownerUid;

  const GroupMembersSection({
    super.key,
    required this.memberIds,
    required this.currentUid,
    required this.chatId,
    required this.isOwner,
    required this.ownerUid,
  });

  void _showAddMembersSheet(BuildContext context) {
    final cubit = context.read<ChatInfoCubit>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddMembersSheet(
        chatId: chatId,
        currentUid: currentUid,
        existingMemberIds: memberIds,
        onAddMembers: (ids, names) => cubit.addGroupMembers(
          chatId: chatId,
          newMemberIds: ids,
          newMemberNames: names,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.08,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: context.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.2,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        context.colorScheme.primary.withValues(alpha: 0.15),
                        context.colorScheme.secondary.withValues(alpha: 0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    SolarIconsOutline.usersGroupRounded,
                    size: 18,
                    color: context.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppText(
                    context.locale.membersCount(memberIds.length),
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (isOwner)
                  GestureDetector(
                    onTap: () => _showAddMembersSheet(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            context.colorScheme.primary.withValues(alpha: 0.15),
                            context.colorScheme.secondary.withValues(
                              alpha: 0.15,
                            ),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        SolarIconsOutline.userPlus,
                        size: 18,
                        color: context.colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          ...memberIds.map(
            (uid) => _MemberTile(
              uid: uid,
              isSelf: uid == currentUid,
              isViewerOwner: isOwner,
              isRealOwner: uid == ownerUid,
              canRemove: isOwner && uid != currentUid,
              onRemove: () => context.read<ChatInfoCubit>().removeGroupMember(
                chatId: chatId,
                memberId: uid,
              ),
              onTap: () {
                if (uid == currentUid) return;
                context.read<ChatInfoCubit>().openOrCreateChat(
                  currentUid: currentUid,
                  otherUid: uid,
                );
              },
            ),
          ),

          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

class _MemberTile extends StatefulWidget {
  final String uid;
  final bool isSelf;
  final bool isViewerOwner;
  final bool isRealOwner;
  final bool canRemove;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const _MemberTile({
    required this.uid,
    required this.isSelf,
    required this.isViewerOwner,
    required this.isRealOwner,
    required this.canRemove,
    required this.onRemove,
    required this.onTap,
  });

  @override
  State<_MemberTile> createState() => _MemberTileState();
}

class _MemberTileState extends State<_MemberTile> {
  UserModel? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    getIt<UsersRepository>().watchUser(uid: widget.uid).first.then((user) {
      if (!mounted) return;
      setState(() {
        _user = user;
        _loading = false;
      });
    });
  }

  void _showRemoveConfirm() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: AppText(
          autoSized: false,
          context.locale.removeMember,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        content: AppText(
          autoSized: false,
          context.locale.removeMemberConfirm,
          style: context.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: AppText(
              autoSized: false,
              context.locale.cancel,
              style: context.textTheme.labelLarge,
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: context.colorScheme.error,
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              widget.onRemove();
            },
            child: AppText(
              autoSized: false,
              context.locale.removeFromGroup,
              style: context.textTheme.labelLarge?.copyWith(
                color: context.colorScheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              _user?.photoUrl != null
                  ? AppImage(
                      imageUrl: _user!.photoUrl!,
                      width: 48,
                      height: 48,
                      borderRadius: 100,
                    )
                  : ProfilePlaceholder(
                      name: _user?.displayName ?? 'user',
                      size: 48,
                    ),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _user?.isOnline == true
                      ? context.colorScheme.success
                      : context.colorScheme.onSurfaceDisabled,
                  border: Border.all(
                    color: context.colorScheme.surfaceContainerHigh,
                    width: 2,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 12),

          Expanded(
            child: _loading
                ? _SkeletonText()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: _user?.displayName ?? widget.uid,
                              style: context.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: context.colorScheme.onSurface,
                              ),
                            ),
                            if (widget.isRealOwner)
                              TextSpan(
                                text: ' (${context.locale.owner})',
                                style: context.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: context.colorScheme.primary,
                                ),
                              ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      AppText(
                        widget.isSelf
                            ? context.locale.you
                            : (_user?.isOnline ?? false
                                  ? context.locale.online
                                  : context.locale.offline),
                        style: context.textTheme.bodySmall?.copyWith(
                          color: widget.isSelf
                              ? context.colorScheme.primary
                              : (_user?.isOnline ?? false
                                    ? context.colorScheme.success
                                    : context.colorScheme.textSecondary),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ).addAction(onTap: widget.onTap),
          ),

          if (widget.canRemove)
            GestureDetector(
              onTap: _showRemoveConfirm,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.colorScheme.error.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  SolarIconsOutline.userMinus,
                  size: 18,
                  color: context.colorScheme.error,
                ),
              ),
            ),
        ],
      ).addPadding(vertical: 8),
    );
  }
}

class _SkeletonText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 12,
          width: 120,
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 10,
          width: 60,
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ],
    );
  }
}
