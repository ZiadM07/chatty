import 'package:chatty/config/theme/app_color_scheme.dart';
import 'package:chatty/core/di/injectable.dart';
import 'package:chatty/core/utils/app_border_radius.dart';
import 'package:chatty/core/utils/app_padding.dart';
import 'package:chatty/core/utils/enums.dart';
import 'package:chatty/core/utils/extensions.dart';
import 'package:chatty/features/shared/widgets/app_message_text.dart';
import 'package:chatty/features/shared/widgets/app_text.dart';
import 'package:chatty/features/users/data/repositories/users_repository.dart';
import 'package:flutter/material.dart';

/// Wrap with [SwipeToReply] in the parent for interactions.
class TextMessageBubble extends StatefulWidget {
  final String message;
  final String time;
  final MessageStatus? status;
  final bool isMe;
  final bool isDeleted;
  final MessageType messageType;
  final String? replyToContent;
  final String? replyToSenderId;
  final String? currentUid;

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
  });

  @override
  State<TextMessageBubble> createState() => _TextMessageBubbleState();
}

class _TextMessageBubbleState extends State<TextMessageBubble> {
  String? _replyToDisplayName;

  @override
  void initState() {
    super.initState();
    _resolveReplyName();
  }

  @override
  void didUpdateWidget(covariant TextMessageBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.replyToSenderId != widget.replyToSenderId) {
      _resolveReplyName();
    }
  }

  Future<void> _resolveReplyName() async {
    final senderId = widget.replyToSenderId;
    if (senderId == null || senderId.isEmpty) return;
    if (senderId == widget.currentUid) {
      if (mounted) setState(() => _replyToDisplayName = null);
      return;
    }
    final user = await getIt<UsersRepository>().getUserById(uid: senderId);
    if (mounted) setState(() => _replyToDisplayName = user?.displayName);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * .7,
          minWidth: 90,
        ),
        decoration: BoxDecoration(
          gradient: widget.isMe && !widget.isDeleted
              ? LinearGradient(
                  colors: [
                    context.colorScheme.primary,
                    context.colorScheme.secondary,
                  ],
                )
              : null,
          color: widget.isMe && !widget.isDeleted
              ? null
              : context.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(widget.isMe ? 14 : 4),
            bottomRight: Radius.circular(widget.isMe ? 4 : 14),
          ),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /* ─── Reply preview ─── */
                if (widget.replyToContent != null && !widget.isDeleted)
                  AnimatedSwitcher(
                    key: ValueKey(
                      '${widget.replyToContent}-${widget.replyToSenderId}',
                    ),

                    duration: const Duration(milliseconds: 250),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, anim) => SizeTransition(
                      fixedCrossAxisSizeFactor: 1,
                      sizeFactor: anim,
                      axisAlignment: -1,
                      child: FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position:
                              Tween<Offset>(
                                begin: const Offset(0, -0.3),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: anim,
                                  curve: Curves.easeOut,
                                ),
                              ),
                          child: child,
                        ),
                      ),
                    ),
                    child: widget.replyToContent != null && !widget.isDeleted
                        ? _ReplyHeader(
                            key: ValueKey(widget.replyToSenderId),
                            content: widget.replyToContent!,
                            senderLabel:
                                widget.replyToSenderId == widget.currentUid
                                ? context.locale.you
                                : _replyToDisplayName ?? '',
                            isMe: widget.isMe,
                          )
                        : const SizedBox.shrink(),
                  ),

                /* ─── Content ─── */
                if (widget.isDeleted)
                  _DeletedMessage(isMe: widget.isMe)
                else if (widget.messageType != MessageType.text)
                  _MediaMessage(type: widget.messageType, isMe: widget.isMe)
                else
                  AppMessageText(
                    key: ValueKey(widget.message),

                    widget.message,
                    isMe: widget.isMe,
                    textStyle: context.textTheme.bodyMedium?.copyWith(
                      color: widget.isMe
                          ? context.colorScheme.onPrimary
                          : context.colorScheme.onSurface,
                    ),
                    lessText: context.locale.less,
                    moreText: context.locale.more,
                  ),
              ],
            ).addPadding(horizontal: 15, vertical: 15),

            /* ─── Time + status ─── */
            Positioned(
              right: widget.isMe ? 10 : null,
              left: widget.isMe ? null : 10,
              bottom: 2,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText(
                    widget.time,
                    autoSized: false,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: widget.isDeleted
                          ? context.colorScheme.textSecondary
                          : context.colorScheme.textPrimary,
                      fontWeight: FontWeight.w500,
                      fontSize: 8,
                    ),
                  ),
                  if (widget.isMe &&
                      !widget.isDeleted &&
                      widget.status != null) ...[
                    const SizedBox(width: 6),
                    AppText(
                      _statusToText(widget.status!),
                      autoSized: false,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _statusToText(MessageStatus status) {
    return switch (status) {
      MessageStatus.sending => 'Sending',
      MessageStatus.sent => 'Sent',
      MessageStatus.delivered => 'Delivered',
      MessageStatus.read => 'Seen',
      MessageStatus.failed => 'Failed',
    };
  }
}

// ─── Reply header ─────────────────────────────────────────────────────────────

class _ReplyHeader extends StatelessWidget {
  final String content;
  final String senderLabel;
  final bool isMe;

  const _ReplyHeader({
    super.key,
    required this.content,
    required this.senderLabel,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isMe
        ? context.colorScheme.textPrimary
        : context.colorScheme.textSecondary;
    final borderColor = isMe
        ? context.colorScheme.onPrimary.withValues(alpha: 0.5)
        : context.colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const AppPadding.set(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isMe
            ? Colors.white.withValues(alpha: 0.12)
            : context.colorScheme.outline.withValues(alpha: 0.05),
        borderRadius: AppBorderRadius.set(all: 12),
        border: Border(left: BorderSide(color: borderColor, width: 2.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
                child: child,
              ),
            ),
            child: AppText(
              senderLabel,
              key: ValueKey(senderLabel),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isMe
                    ? context.colorScheme.onPrimary
                    : context.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 2),
          AppText(
            content,
            style: TextStyle(fontSize: 11, color: textColor),
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

// ─── Deleted message ──────────────────────────────────────────────────────────

class _DeletedMessage extends StatelessWidget {
  final bool isMe;
  const _DeletedMessage({required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.block_rounded,
          size: 14,
          color: context.colorScheme.textSecondary,
        ),
        const SizedBox(width: 6),
        AppText(
          context.locale.messageDeleted,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.textSecondary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

// ─── Media message ────────────────────────────────────────────────────────────

class _MediaMessage extends StatelessWidget {
  final MessageType type;
  final bool isMe;
  const _MediaMessage({required this.type, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final (icon, label) = switch (type) {
      MessageType.image => (Icons.image_rounded, 'Photo'),
      MessageType.audio => (Icons.audiotrack_rounded, 'Audio'),
      MessageType.video => (Icons.videocam_rounded, 'Video'),
      MessageType.file => (Icons.insert_drive_file_rounded, 'File'),
      _ => (Icons.attachment_rounded, 'Attachment'),
    };
    final color = isMe
        ? context.colorScheme.onPrimary
        : context.colorScheme.onSurface;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        AppText(
          label,
          style: context.textTheme.bodyMedium?.copyWith(color: color),
        ),
      ],
    );
  }
}
