import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/core/utils/enums.dart';
import 'package:Chatty/features/chats/data/models/message_model.dart';
import 'package:Chatty/features/chats/ui/chat/widgets/message_bubble_shell.dart';
import 'package:Chatty/features/shared/widgets/app_message_text.dart';

import 'message_reaction_overlay.dart';

class TextMessageBubble extends StatelessWidget {
  final MessageModel message;
  final String time;
  final MessageStatus? status;
  final bool isMe;
  final bool isDeleted;
  final MessageType messageType;
  final String? replyToContent;
  final String? replyToSenderId;
  final String? currentUid;
  final MessageType? replyToType;
  final VoidCallback? onReplyTap;
  final Map<String, String> memberNames;
  final ValueChanged<String?> onReact;
  final VoidCallback onReply;
  final VoidCallback? onDelete;
  final bool showSenderName;
  final String? senderId;

  const TextMessageBubble({
    super.key,
    required this.message,
    required this.time,
    this.status,
    required this.isMe,
    this.isDeleted = false,
    this.messageType = MessageType.text,
    this.replyToContent,
    this.replyToSenderId,
    this.currentUid,
    this.replyToType,
    this.onReplyTap,
    this.memberNames = const {},
    required this.onReact,
    required this.onReply,
    this.onDelete,
    this.showSenderName = false,
    this.senderId,
  });

  @override
  Widget build(BuildContext context) {
    final bubble = MessageBubbleShell(
      isMe: isMe,
      isDeleted: isDeleted,
      time: time,
      status: status,
      replyToContent: replyToContent,
      replyToSenderId: replyToSenderId,
      currentUid: currentUid,
      replyToType: replyToType,
      onReplyTap: onReplyTap,
      memberNames: memberNames,
      showSenderName: showSenderName,
      senderId: senderId,
      child: messageType != MessageType.text
          ? _MediaMessage(type: messageType, isMe: isMe)
          : AppMessageText(
              key: ValueKey(message.content),
              message.isDeleted
                  ? context.locale.messageDeleted
                  : message.content,
              isMe: isMe,
              textStyle: context.textTheme.bodyMedium?.copyWith(
                color: isMe
                    ? context.colorScheme.onPrimary
                    : context.colorScheme.onSurface,
                height: 1.4,
              ),
              lessText: context.locale.less,
              moreText: context.locale.more,
            ),
    );

    return BubbleWithReactions(
      message: message,
      isMe: isMe,
      currentUid: currentUid ?? '',
      onReply: onReply,
      onReact: onReact,
      onDelete: onDelete,
      bubble: bubble,
    );
  }
}

class _MediaMessage extends StatelessWidget {
  final MessageType type;
  final bool isMe;
  const _MediaMessage({required this.type, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final (icon, label) = switch (type) {
      MessageType.image => (Icons.image_rounded, context.locale.photo),
      MessageType.audio => (Icons.audiotrack_rounded, context.locale.audio),
      MessageType.video => (Icons.videocam_rounded, context.locale.video),
      MessageType.file => (
        Icons.insert_drive_file_rounded,
        context.locale.file,
      ),
      _ => (Icons.attachment_rounded, context.locale.attachment),
    };
    final color = isMe
        ? context.colorScheme.onPrimary
        : context.colorScheme.onSurface;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        AppText(
          label,
          style: context.textTheme.bodyMedium?.copyWith(color: color),
        ),
      ],
    );
  }
}
