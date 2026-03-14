import 'package:Chatty/config/router/app_router.gr.dart';
import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/core/di/injectable.dart';
import 'package:Chatty/features/auth/cubits/auth_cubit.dart';
import 'package:Chatty/features/chats/cubits/chat_info_cubit.dart';
import 'package:Chatty/features/chats/ui/info/widgets/account_info_section.dart';
import 'package:Chatty/features/chats/ui/info/widgets/actions_section.dart';
import 'package:Chatty/features/chats/ui/info/widgets/groups_section.dart';
import 'package:Chatty/features/chats/ui/info/widgets/group_info_section.dart';
import 'package:Chatty/features/chats/ui/info/widgets/group_members_section.dart';
import 'package:Chatty/features/chats/ui/info/widgets/media_section.dart';
import 'package:Chatty/features/chats/ui/info/widgets/notifications_section.dart';
import 'package:Chatty/features/shared/widgets/app_toast.dart';

@RoutePage()
class ChatInfoScreen extends StatefulWidget implements AutoRouteWrapper {
  final String? uid;
  final String? chatId;
  const ChatInfoScreen({super.key, this.uid, this.chatId});

  @override
  State<ChatInfoScreen> createState() => _ChatInfoTestScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ChatInfoCubit>(),
      child: this,
    );
  }
}

class _ChatInfoTestScreenState extends State<ChatInfoScreen> {
  late final String _currentUid;

  @override
  void initState() {
    super.initState();
    _currentUid = context.read<AuthCubit>().state.currentUser?.uid ?? '';
    final cubit = context.read<ChatInfoCubit>();

    if (widget.uid != null) {
      cubit.watchUser(uid: widget.uid!);
      cubit.loadCommonGroups(currentUid: _currentUid, otherUid: widget.uid!);
    }

    if (widget.chatId != null) {
      cubit.watchChat(chatId: widget.chatId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: BlocConsumer<ChatInfoCubit, ChatInfoState>(
        listenWhen: (prev, curr) =>
            prev.openChatState != curr.openChatState ||
            prev.chatState.status != curr.chatState.status ||
            prev.leaveGroupState != curr.leaveGroupState,
        listener: (context, state) {
          if (state.openChatState.isSuccess) {
            context.read<ChatInfoCubit>().resetOpenChatState();
            context.router.replace(
              ChatRoute(chatId: state.openChatState.data!),
            );
          }
          if (state.openChatState.isError) {
            context.read<ChatInfoCubit>().resetOpenChatState();
            AppToast.showError(
              message: context.locale.failedToCreateChat,
              context: context,
            );
          }
          if (state.chatState.isError) {
            AppToast.showError(
              message: context.locale.thisOperationFailed,
              context: context,
            );
          }
          if (state.leaveGroupState.isSuccess) {
            context.read<ChatInfoCubit>().resetLeaveGroupState();
            context.router.popUntilRouteWithName(ConversationsRoute.name);
          }
          if (state.leaveGroupState.isError) {
            context.read<ChatInfoCubit>().resetLeaveGroupState();
            AppToast.showError(
              message: context.locale.thisOperationFailed,
              context: context,
            );
          }
        },
        buildWhen: (prev, curr) =>
            prev.userState != curr.userState ||
            prev.chatState != curr.chatState ||
            prev.isMuted != curr.isMuted ||
            prev.commonGroupsState != curr.commonGroupsState,
        builder: (context, state) {
          final isGroup = state.chat?.isGroup == true;
          return CustomScrollView(
            slivers: [
              isGroup
                  ? SliverToBoxAdapter(
                      child: _GroupInfoContent(
                        currentUid: _currentUid,
                        chatId: widget.chatId,
                      ),
                    )
                  : SliverToBoxAdapter(
                      child: _UserInfoContent(
                        currentUid: _currentUid,
                        uid: widget.uid,
                        chatId: widget.chatId,
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }
}

class _UserInfoContent extends StatelessWidget {
  final String currentUid;
  final String? uid;
  final String? chatId;

  const _UserInfoContent({
    required this.currentUid,
    required this.uid,
    required this.chatId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatInfoCubit, ChatInfoState>(
      buildWhen: (prev, curr) =>
          prev.userState != curr.userState ||
          prev.openChatState != curr.openChatState ||
          prev.isMuted != curr.isMuted ||
          prev.commonGroupsState != curr.commonGroupsState,
      builder: (context, state) {
        final user = state.user;
        if (state.userState.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (user == null) {
          return Center(
            child: AppText(
              context.locale.userNotFound,
              style: context.textTheme.bodyMedium,
            ),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AccountInfoSection(user: user),
            const SizedBox(height: 30),

            ActionsSection(
              isLoadingChat: state.openChatState.isLoading,
              showStory: true,
              onMessage: () => context.read<ChatInfoCubit>().openOrCreateChat(
                currentUid: currentUid,
                otherUid: uid!,
              ),
              onViewStory: () =>
                  context.router.push(StoryViewerRoute(ownerUid: uid!)),
            ),
            const SizedBox(height: 24),

            NotificationsSection(
              isMuted: state.isMuted,
              onToggleMute: () => context.read<ChatInfoCubit>().toggleMute(),
            ),
            const SizedBox(height: 10),

            MediaSection(chatId: chatId),
            const SizedBox(height: 30),

            if (state.commonGroupsState.isSuccess &&
                state.commonGroupsState.data != null)
              GroupsSection(
                groups: state.commonGroupsState.data!,
                currentUid: currentUid,
                otherUser: user,
              ),
            const SizedBox(height: 32),
          ],
        );
      },
    );
  }
}

class _GroupInfoContent extends StatelessWidget {
  final String currentUid;
  final String? chatId;

  const _GroupInfoContent({required this.currentUid, required this.chatId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatInfoCubit, ChatInfoState>(
      buildWhen: (prev, curr) =>
          prev.chatState != curr.chatState || prev.isMuted != curr.isMuted,
      builder: (context, state) {
        return StateHandler(
          state: state.chatState,
          builder: (context, chatState) {
            final chat = state.chat;
            final isOwner = chat?.groupCreatedBy == currentUid;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GroupInfoSection(
                  chat: chat!,
                  currentUid: currentUid,
                  isOwner: isOwner,
                ),
                const SizedBox(height: 24),

                NotificationsSection(
                  isMuted: state.isMuted,
                  onToggleMute: () =>
                      context.read<ChatInfoCubit>().toggleMute(),
                ),
                const SizedBox(height: 10),

                MediaSection(chatId: chat.id),
                const SizedBox(height: 20),

                GroupMembersSection(
                  memberIds: chat.memberIds,
                  currentUid: currentUid,
                  chatId: chat.id,
                  isOwner: isOwner,
                  ownerUid: chat.groupCreatedBy!,
                ),
                const SizedBox(height: 20),

                _LeaveGroupButton(
                  currentUid: currentUid,
                  isOwner: isOwner,
                  memberIds: chat.memberIds,
                  isLoading: state.leaveGroupState.isLoading,
                ),
                const SizedBox(height: 32),
              ],
            );
          },
        );
      },
    );
  }
}

class _LeaveGroupButton extends StatelessWidget {
  final String currentUid;
  final bool isOwner;
  final List<String> memberIds;
  final bool isLoading;

  const _LeaveGroupButton({
    required this.currentUid,
    required this.isOwner,
    required this.memberIds,
    required this.isLoading,
  });

  void _confirmLeave(BuildContext context) {
    final otherMembers = memberIds.where((id) => id != currentUid).toList();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: AppText(
          autoSized: false,
          context.locale.leaveGroup,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        content: AppText(
          autoSized: false,
          isOwner && otherMembers.isNotEmpty
              ? context.locale.leaveGroupOwnerConfirm
              : context.locale.leaveGroupConfirm,
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
              context.read<ChatInfoCubit>().leaveGroup(
                currentUid: currentUid,
                memberIds: memberIds,
              );
            },
            child: AppText(
              autoSized: false,
              context.locale.leaveGroup,
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: isLoading ? null : () => _confirmLeave(context),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: context.colorScheme.error.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: context.colorScheme.error.withValues(alpha: 0.2),
            ),
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: context.colorScheme.error,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        SolarIconsOutline.logout,
                        size: 18,
                        color: context.colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      AppText(
                        isOwner
                            ? context.locale.leaveAndTransfer
                            : context.locale.leaveGroup,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
