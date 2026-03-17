import 'package:Chatty/features/chats/ui/chat/widgets/text_message_bubble.dart';
import 'package:Chatty/features/chats/ui/chat/widgets/voice_message_bubble.dart';

import '../../../../../core/constants/exports.dart';
import '../../../../../core/utils/enums.dart';
import '../../../data/models/message_model.dart';
import 'media_message_bubble.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.isLastMyMessage,
    required this.currentUid,
    required this.memberNames,
    required this.onReplyTap,
    required this.onReact,
    required this.onReply,
    required this.onDelete,
    this.isGroup = false,
  });

  final MessageModel message;
  final bool isMe;
  final bool isLastMyMessage;
  final String currentUid;
  final Map<String, String> memberNames;
  final VoidCallback? onReplyTap;
  final void Function(String? emoji) onReact;
  final VoidCallback onReply;
  final VoidCallback? onDelete;
  final bool isGroup;

  String _formatTime(DateTime dt, BuildContext context) {
    final hour = dt.hour > 12
        ? dt.hour - 12
        : dt.hour == 0
        ? 12
        : dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? context.locale.pm : context.locale.am;
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final time = _formatTime(message.createdAt, context);
    final status = isMe && isLastMyMessage ? message.status : null;
    final replyTap = message.replyToId != null ? onReplyTap : null;
    final bool showSenderName = isGroup && !isMe && !message.isDeleted;

    return switch (message.type) {
      MessageType.audio => VoiceMessageBubble(
        key: ValueKey(message.id),
        message: message,
        time: time,
        status: status,
        isMe: isMe,
        currentUid: currentUid,
        replyToContent: message.replyToContent,
        replyToSenderId: message.replyToSenderId,
        replyToType: message.replyToType,
        onReplyTap: replyTap,
        memberNames: memberNames,
        onReact: onReact,
        onReply: onReply,
        onDelete: isMe && !message.isDeleted ? onDelete : null,
        showSenderName: showSenderName,
        senderId: message.senderId,
      ),

      MessageType.image ||
      MessageType.video ||
      MessageType.file => MediaMessageBubble(
        key: ValueKey(message.id),
        message: message,
        type: message.type,
        time: time,
        status: status,
        isMe: isMe,
        currentUid: currentUid,
        metadata: message.metadata,
        replyToContent: message.replyToContent,
        replyToSenderId: message.replyToSenderId,
        replyToType: message.replyToType,
        onReplyTap: replyTap,
        memberNames: memberNames,
        onReact: onReact,
        onReply: onReply,
        onDelete: isMe && !message.isDeleted ? onDelete : null,
        showSenderName: showSenderName,
        senderId: message.senderId,
      ),

      _ => TextMessageBubble(
        key: ValueKey(message.id),
        message: message,
        time: time,
        status: status,
        isMe: isMe,
        isDeleted: message.isDeleted,
        messageType: message.type,
        replyToContent: message.replyToContent,
        replyToSenderId: message.replyToSenderId,
        replyToType: message.replyToType,
        currentUid: currentUid,
        onReplyTap: replyTap,
        memberNames: memberNames,
        onReact: onReact,
        onReply: onReply,
        onDelete: onDelete,
        showSenderName: showSenderName,
        senderId: message.senderId,
      ),
    };
  }
}
