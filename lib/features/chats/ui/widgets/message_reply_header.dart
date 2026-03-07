import 'package:Chatty/config/theme/app_color_scheme.dart';
import 'package:Chatty/core/utils/enums.dart';
import 'package:Chatty/core/utils/extensions.dart';
import 'package:Chatty/features/shared/widgets/app_image.dart';
import 'package:Chatty/features/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';

class MessageReplyHeader extends StatelessWidget {
  final String content;
  final MessageType replyToType;
  final String senderLabel;
  final bool isMe;

  const MessageReplyHeader({
    super.key,
    required this.content,
    required this.replyToType,
    required this.senderLabel,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final isImageReply = replyToType == MessageType.image;
    final isMediaReply =
        replyToType == MessageType.audio ||
        replyToType == MessageType.video ||
        replyToType == MessageType.file ||
        isImageReply;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isMe
            ? Colors.white.withValues(alpha: 0.15)
            : context.colorScheme.outline.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(
            color: isMe
                ? context.colorScheme.onPrimary.withValues(alpha: 0.6)
                : context.colorScheme.primary,
            width: 2.5,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 8, 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    senderLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isMe
                          ? context.colorScheme.onPrimary
                          : context.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (isMediaReply)
                    _MediaReplyLabel(type: replyToType, isMe: isMe)
                  else
                    AppText(
                      content,
                      style: TextStyle(
                        fontSize: 11,
                        color: isMe
                            ? context.colorScheme.onPrimary.withValues(
                                alpha: 0.8,
                              )
                            : context.colorScheme.textSecondary,
                      ),
                      maxLines: 1,
                    ),
                ],
              ),
            ),
          ),

          if (isImageReply) _ReplyThumbnail(imageUrl: content),
        ],
      ),
    );
  }
}

class _MediaReplyLabel extends StatelessWidget {
  final MessageType type;
  final bool isMe;

  const _MediaReplyLabel({required this.type, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final color = isMe
        ? context.colorScheme.onPrimary.withValues(alpha: 0.8)
        : context.colorScheme.textSecondary;

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

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 4),
        AppText(label, style: TextStyle(fontSize: 11, color: color)),
      ],
    );
  }
}

class _ReplyThumbnail extends StatelessWidget {
  final String imageUrl;
  const _ReplyThumbnail({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 4, 4),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(9),
          bottomRight: Radius.circular(9),
        ),
        child: AppImage(
          imageUrl: imageUrl,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
