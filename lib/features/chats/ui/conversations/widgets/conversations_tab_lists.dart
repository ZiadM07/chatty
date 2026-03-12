import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/features/auth/cubits/auth_cubit.dart';
import 'package:Chatty/features/chats/cubits/conversations_cubit.dart';
import 'package:Chatty/features/chats/data/models/chat_model.dart';
import 'messages_item.dart';

class ConversationsTabLists extends StatelessWidget {
  const ConversationsTabLists({super.key, required TabController tabController})
    : _tabController = tabController;

  final TabController _tabController;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConversationsCubit, ConversationsState>(
      buildWhen: (prev, curr) =>
          prev.chatsState != curr.chatsState ||
          prev.searchQuery != curr.searchQuery ||
          prev.isSearching != curr.isSearching,
      builder: (context, state) {
        final currentUid =
            context.read<AuthCubit>().state.currentUser?.uid ?? '';

        final allChats = state.chatsState.data ?? [];
        final filtered = _filterChats(allChats, state.searchQuery, currentUid);
        final directChats = filtered.where((c) => c.isOneToOne).toList();
        final groupChats = filtered.where((c) => c.isGroup).toList();

        return TabBarView(
          controller: _tabController,
          children: [
            _ChatList(
              state: state,
              isEmpty: directChats.isEmpty,
              isSearching: state.isSearching,
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

            _ChatList(
              state: state,
              isEmpty: groupChats.isEmpty,
              isSearching: state.isSearching,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                separatorBuilder: (_, _) => const SizedBox(height: 16),
                itemCount: groupChats.length,
                itemBuilder: (context, index) => MessagesItem(
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

class _ChatList extends StatelessWidget {
  final ConversationsState state;
  final bool isEmpty;
  final bool isSearching;
  final Widget child;

  const _ChatList({
    required this.state,
    required this.isEmpty,
    required this.isSearching,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (state.chatsState.status == StateStatus.loading &&
        state.chatsState.data == null) {
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
          isSearching
              ? context.locale.noResultsFound
              : context.locale.noChatsAvailable,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.textSecondary,
          ),
        ),
      );
    }

    return child;
  }
}

List<ChatModel> _filterChats(
  List<ChatModel> chats,
  String query,
  String currentUid,
) {
  if (query.isEmpty) return chats;
  final q = query.toLowerCase();
  return chats.where((chat) {
    final name = chat.isGroup
        ? (chat.groupName ?? '').toLowerCase()
        : chat.memberNames.entries
              .firstWhere(
                (e) => e.key != currentUid,
                orElse: () => const MapEntry('', ''),
              )
              .value
              .toLowerCase();
    return name.contains(q);
  }).toList();
}
