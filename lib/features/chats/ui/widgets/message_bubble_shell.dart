import 'package:Chatty/config/theme/app_color_scheme.dart';
import 'package:Chatty/core/di/injectable.dart';
import 'package:Chatty/core/utils/enums.dart';
import 'package:Chatty/core/utils/extensions.dart';
import 'package:Chatty/features/shared/widgets/app_image.dart';
import 'package:Chatty/features/shared/widgets/app_text.dart';
import 'package:Chatty/features/users/data/repositories/users_repository.dart';
import 'package:flutter/material.dart';

class MessageBubbleShell extends StatefulWidget {
  final Widget child;
  final bool isDeleted;
  final bool isMe;
  final EdgeInsetsGeometry contentPadding;
  final double maxWidthFraction;
  final double minWidth;
  final Map<String, String> memberNames;
  final String? time;
  final MessageStatus? status;
  final MainAxisAlignment footerAlignment;
  final String? replyToContent;
  final String? replyToSenderId;
  final String? currentUid;
  final MessageType? replyToType;
  final VoidCallback? onReplyTap;

  const MessageBubbleShell({
    super.key,
    required this.child,
    required this.isMe,
    required this.isDeleted,
    this.contentPadding = const EdgeInsets.fromLTRB(14, 10, 14, 8),
    this.maxWidthFraction = 0.72,
    this.minWidth = 80,
    this.time,
    this.status,
    this.footerAlignment = MainAxisAlignment.start,
    this.replyToContent,
    this.replyToSenderId,
    this.currentUid,
    this.replyToType,
    this.onReplyTap,
    required this.memberNames,
  });

  @override
  State<MessageBubbleShell> createState() => _MessageBubbleShellState();
}

class _MessageBubbleShellState extends State<MessageBubbleShell> {
  String? _replyToDisplayName;

  @override
  void initState() {
    super.initState();
    _resolveReplyName();
  }

  @override
  void didUpdateWidget(covariant MessageBubbleShell oldWidget) {
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
    final cached = widget.memberNames[senderId];
    if (cached != null) {
      if (mounted) setState(() => _replyToDisplayName = cached);
      return;
    }
    final user = await getIt<UsersRepository>().getUserById(uid: senderId);
    if (mounted) setState(() => _replyToDisplayName = user?.displayName);
  }

  @override
  Widget build(BuildContext context) {
    final hasReply = widget.replyToContent != null && !widget.isDeleted;

    return Align(
      alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * widget.maxWidthFraction,
          minWidth: widget.minWidth,
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
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(widget.isMe ? 18 : 4),
            bottomRight: Radius.circular(widget.isMe ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: widget.contentPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasReply)
                BubbleReplyHeader(
                  content: widget.replyToContent!,
                  replyToType: widget.replyToType ?? MessageType.text,
                  senderLabel: widget.replyToSenderId == widget.currentUid
                      ? context.locale.you
                      : _replyToDisplayName ?? '',
                  isMe: widget.isMe,
                  onTap: widget.onReplyTap,
                ),

              if (widget.isDeleted)
                BubbleDeletedMessage(isMe: widget.isMe)
              else
                widget.child,

              if (widget.time != null) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: widget.footerAlignment,
                  children: [
                    AppText(
                      widget.time!,
                      autoSized: false,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.textPrimary,
                        fontSize: 10,
                      ),
                    ),
                    if (widget.isMe &&
                        !widget.isDeleted &&
                        widget.status != null) ...[
                      const SizedBox(width: 4),
                      AppText(
                        bubbleStatusText(widget.status!, context),
                        autoSized: false,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.textPrimary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────────────────────

String bubbleStatusText(MessageStatus status, BuildContext context) =>
    switch (status) {
      MessageStatus.sending => context.locale.sending,
      MessageStatus.sent => context.locale.sent,
      MessageStatus.delivered => context.locale.delivered,
      MessageStatus.read => context.locale.seen,
      MessageStatus.failed => context.locale.failed,
    };

// ─────────────────────────────────────────────────────────────────────────────
// BubbleReplyHeader
// ─────────────────────────────────────────────────────────────────────────────

class BubbleReplyHeader extends StatelessWidget {
  final String content;
  final MessageType replyToType;
  final String senderLabel;
  final bool isMe;

  /// Tapping the header scrolls to the original message.
  final VoidCallback? onTap;

  const BubbleReplyHeader({
    super.key,
    required this.content,
    required this.replyToType,
    required this.senderLabel,
    required this.isMe,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                    if (replyToType == MessageType.image)
                      _MediaReplyLabel(
                        isMe: isMe,
                        icon: Icons.image_rounded,
                        label: context.locale.photo,
                      )
                    else if (replyToType == MessageType.audio)
                      _MediaReplyLabel(
                        isMe: isMe,
                        icon: Icons.mic_rounded,
                        label: context.locale.voiceMessage,
                      )
                    else if (replyToType == MessageType.video)
                      _MediaReplyLabel(
                        isMe: isMe,
                        icon: Icons.videocam_rounded,
                        label: context.locale.video,
                      )
                    else if (replyToType == MessageType.file)
                      _MediaReplyLabel(
                        isMe: isMe,
                        icon: Icons.insert_drive_file_rounded,
                        label: context.locale.file,
                      )
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
            if (replyToType == MessageType.image)
              _ReplyThumbnail(imageUrl: content),
          ],
        ),
      ),
    );
  }
}

class _MediaReplyLabel extends StatelessWidget {
  final bool isMe;
  final IconData icon;
  final String label;

  const _MediaReplyLabel({
    required this.isMe,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final color = isMe
        ? context.colorScheme.onPrimary.withValues(alpha: 0.8)
        : context.colorScheme.textSecondary;
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

// ─────────────────────────────────────────────────────────────────────────────
// BubbleDeletedMessage
// ─────────────────────────────────────────────────────────────────────────────

class BubbleDeletedMessage extends StatelessWidget {
  final bool isMe;
  const BubbleDeletedMessage({super.key, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.block_rounded,
          size: 13,
          color: context.colorScheme.textSecondary,
        ),
        const SizedBox(width: 5),
        AppText(
          context.locale.messageDeleted,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.textSecondary,
            fontStyle: FontStyle.italic,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
