import 'package:chatty/config/router/app_router.gr.dart';
import 'package:chatty/core/constants/exports.dart';
import 'package:chatty/features/chats/data/models/chat_model.dart';
import 'package:chatty/features/shared/widgets/app_image.dart';

class GroupMessageItem extends StatelessWidget {
  final ChatModel chat;
  final String currentUid;

  const GroupMessageItem({
    super.key,
    required this.chat,
    required this.currentUid,
  });

  String _lastMessagePreview(BuildContext context) {
    if (chat.lastMessage == null || chat.lastMessage!.isEmpty) {
      return context.locale.noMessagesYet;
    }
    // For groups prefix with sender uid — replace with display name once cached
    final isMe = chat.lastMessageSenderId == currentUid;
    final prefix = isMe ? context.locale.you : chat.lastMessageSenderId ?? '';
    return '$prefix: ${chat.lastMessage!}';
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
    final unread = chat.unreadCountFor(currentUid);

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
            imageUrl: chat.groupPhotoUrl ?? AppConstants.fakeUserImage,
            width: 55,
            height: 55,
            borderRadius: 100,
          ),

          const SizedBox(width: 16),

          /* ─── Group name + Last message ─── */
          Expanded(
            child: Column(
              spacing: 5,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText(
                  chat.groupName ?? context.locale.groupName,
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
              if (chat.lastMessageAt != null)
                AppText(
                  _formatTime(chat.lastMessageAt!),
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
    ).addAction(onTap: () => context.router.push(ChatRoute(chatId: chat.id)));
  }
}
