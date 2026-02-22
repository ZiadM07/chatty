import 'package:chatty/core/constants/exports.dart';
import 'package:chatty/features/auth/cubits/auth_cubit.dart';
import 'package:chatty/features/chats/cubits/conversations_cubit.dart';

import 'package:chatty/features/conversations/ui/widgets/group_message_item.dart';
import 'package:chatty/features/conversations/ui/widgets/messages_item.dart';

class ConversationsTabLists extends StatelessWidget {
  const ConversationsTabLists({super.key, required TabController tabController})
    : _tabController = tabController;

  final TabController _tabController;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConversationsCubit, ConversationsState>(
      buildWhen: (prev, curr) => prev.chatsState != curr.chatsState,
      builder: (context, state) {
        final currentUid =
            context.read<AuthCubit>().state.currentUser?.uid ?? '';

        // Split chats by type
        final allChats = state.chatsState.data ?? [];
        final directChats = allChats.where((c) => c.isOneToOne).toList();
        final groupChats = allChats.where((c) => c.isGroup).toList();

        return TabBarView(
          controller: _tabController,
          children: [
            /* ─── Messages Tab ─── */
            _ChatList(
              state: state,
              isEmpty: directChats.isEmpty,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                separatorBuilder: (_, _) => const SizedBox(height: 16),
                itemCount: directChats.length,
                itemBuilder: (context, index) => MessagesItem(
                  chat: directChats[index],
                  currentUid: currentUid,
                ),
              ),
            ),

            /* ─── Groups Tab ─── */
            _ChatList(
              state: state,
              isEmpty: groupChats.isEmpty,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                separatorBuilder: (_, _) => const SizedBox(height: 16),
                itemCount: groupChats.length,
                itemBuilder: (context, index) => GroupMessageItem(
                  chat: groupChats[index],
                  currentUid: currentUid,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Shared list wrapper — handles loading / empty ────────────────────────────

class _ChatList extends StatelessWidget {
  final ConversationsState state;
  final bool isEmpty;
  final Widget child;

  const _ChatList({
    required this.state,
    required this.isEmpty,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (state.chatsState.status == StateStatus.loading &&
        (state.chatsState.data == null)) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.chatsState.status == StateStatus.error) {
      return Center(
        child: AppText(
          state.chatsState.message ?? context.locale.noChatsAvailable,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    if (isEmpty) {
      return Center(
        child: AppText(
          context.locale.noChatsAvailable,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.textSecondary,
          ),
        ),
      );
    }

    return child;
  }
}
