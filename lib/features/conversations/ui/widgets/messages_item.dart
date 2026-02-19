import 'package:chatty/config/router/app_router.gr.dart';
import 'package:chatty/core/constants/exports.dart';
import 'package:chatty/core/di/injectable.dart';
import 'package:chatty/features/auth/data/models/user_model.dart';
import 'package:chatty/features/chats/data/models/chat_model.dart';
import 'package:chatty/features/shared/widgets/app_image.dart';
import 'package:chatty/features/users/data/repositories/users_repository.dart';

class MessagesItem extends StatefulWidget {
  final ChatModel chat;
  final String currentUid;

  const MessagesItem({super.key, required this.chat, required this.currentUid});

  @override
  State<MessagesItem> createState() => _MessagesItemState();
}

class _MessagesItemState extends State<MessagesItem> {
  UserModel? _otherUser;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void didUpdateWidget(covariant MessagesItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chat.id != widget.chat.id) _loadUser();
  }

  Future<void> _loadUser() async {
    final otherUid = widget.chat.otherMemberId(widget.currentUid);
    if (otherUid.isEmpty) return;
    final user = await getIt<UsersRepository>().getUserById(uid: otherUid);
    if (mounted) setState(() => _otherUser = user);
  }

  String _lastMessagePreview(BuildContext context) {
    if (widget.chat.lastMessage == null || widget.chat.lastMessage!.isEmpty) {
      return context.locale.noMessagesYet;
    }
    return widget.chat.lastMessage!;
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${dt.day}/${dt.month}';
  }

  @override
  Widget build(BuildContext context) {
    final unread = widget.chat.unreadCountFor(widget.currentUid);
    final displayName = _otherUser?.displayName ?? '...';
    final photoUrl = _otherUser?.photoUrl ?? AppConstants.fakeUserImage;

    return Container(
      padding: const AppPadding.set(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /* ─── Avatar ─── */
          AppImage(
            imageUrl: photoUrl,
            width: 55,
            height: 55,
            borderRadius: 100,
          ),

          const SizedBox(width: 16),

          /* ─── Name + Last message ─── */
          Expanded(
            child: Column(
              spacing: 5,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText(
                  displayName,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                ),
                AppText(
                  _lastMessagePreview(context),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.textSecondary,
                    fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.w400,
                  ),
                  maxLines: 1,
                  maxWidth: 200,
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          /* ─── Time + Unread badge ─── */
          Column(
            spacing: 6,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (widget.chat.lastMessageAt != null)
                AppText(
                  _formatTime(widget.chat.lastMessageAt!),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.textSecondary,
                  ),
                ),
              if (unread > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        context.colorScheme.primary,
                        context.colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: AppText(
                    unread > 99 ? '99+' : '$unread',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: context.colorScheme.textSecondary,
                ),
            ],
          ),
        ],
      ),
    ).addAction(
      onTap: () => context.router.push(ChatRoute(chatId: widget.chat.id)),
    );
  }
}
