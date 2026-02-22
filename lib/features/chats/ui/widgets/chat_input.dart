import 'package:chatty/core/constants/exports.dart';
import 'package:chatty/core/di/injectable.dart';
import 'package:chatty/core/framework/pick_file.dart';
import 'package:chatty/core/utils/enums.dart';
import 'package:chatty/features/chats/data/models/message_model.dart';
import 'package:chatty/features/shared/cubits/app_cubit.dart';
import '../../../../core/framework/audio_service.dart';
import '../../../users/data/repositories/users_repository.dart';

class ChatInput extends StatefulWidget {
  final ValueChanged<String>? onSendPressed;
  final void Function(String)? onTextChanged;
  final TextEditingController? controller;
  final String? hintText;
  final FocusNode? focusNode;
  final void Function(File file)? onSendAttachment;
  final bool isSendingMedia;
  final MessageModel? replyingTo;
  final String? currentUid;
  final VoidCallback? onCancelReply;

  const ChatInput({
    super.key,
    required this.onSendPressed,
    required this.onTextChanged,
    required this.controller,
    required this.hintText,
    required this.focusNode,
    required this.onSendAttachment,
    this.isSendingMedia = false,
    this.replyingTo,
    this.currentUid,
    this.onCancelReply,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  late final TextEditingController _controller;
  bool _hasText = false;
  bool _showQuickActions = false;
  final _audioService = getIt<AudioService>();

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
    widget.onTextChanged?.call(_controller.text);
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSendPressed?.call(text);
    _controller.clear();
  }

  void _toggleQuickActions() =>
      setState(() => _showQuickActions = !_showQuickActions);

  // ─── Voice recording ───────────────────────────────────────────────────

  Future<void> _startRecording() async {
    final hasPermission = await _audioService.hasRecordPermission();
    if (!hasPermission) {
      // TODO: show permission denied snackbar
      return;
    }
    await _audioService.startRecording();
  }

  Future<void> _stopRecordingAndSend() async {
    final result = await _audioService.stopRecording();
    if (mounted) {
      widget.onSendAttachment?.call(result.file!);
    }
  }

  // Future<void> _cancelRecording() async {
  //   await _audioService.cancelRecording();
  // }

  Future<void> _pickImage() async {
    setState(() => _showQuickActions = false);
    final file = await PickFile.image();
    if (file != null) widget.onSendAttachment?.call(file);
  }

  Future<void> _pickFile() async {
    setState(() => _showQuickActions = false);
    final file = await PickFile.pickFile();
    if (file != null) widget.onSendAttachment?.call(file);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appCubit = context.read<AppCubit>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        /* ─── Reply Preview — animated in/out ─── */
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, anim) => SizeTransition(
            sizeFactor: anim,
            axisAlignment: -1,
            child: FadeTransition(opacity: anim, child: child),
          ),
          child: widget.replyingTo != null
              ? _ReplyPreview(
                  key: ValueKey(widget.replyingTo!.id),
                  message: widget.replyingTo!,
                  currentUid: widget.currentUid ?? '',
                  onCancel: widget.onCancelReply,
                )
              : const SizedBox.shrink(),
        ),

        /* ─── Input Row ─── */
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: widget.focusNode,
                  keyboardType: TextInputType.multiline,
                  maxLines: 5,
                  minLines: 1,
                  textInputAction: appCubit.enterIsSend
                      ? TextInputAction.send
                      : TextInputAction.newline,
                  onSubmitted: (value) {
                    if (appCubit.enterIsSend) {
                      _sendMessage();
                    }
                  },
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hintText ?? context.locale.typeMessage,
                    hintStyle: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.textSecondary,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 6),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                /* ─── Quick Actions ─── */
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _showQuickActions
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 8,
                          children: [
                            _ActionButton(
                              icon: SolarIconsBold.linkMinimalistic_2,
                              onPressed: _pickFile,
                            ),
                            _ActionButton(
                              icon: SolarIconsBold.camera,
                              onPressed: _pickImage,
                            ),
                            GestureDetector(
                              onLongPress: _startRecording,
                              onLongPressEnd: (_) => _stopRecordingAndSend(),
                              child: _ActionButton(
                                icon: SolarIconsBold.microphone2,
                                onPressed: () {}, // Only long-press works
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),

                /* ─── Send / Add button ─── */
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeInOut,
                  child: widget.isSendingMedia
                      ? _ActionButton(
                          key: const ValueKey('loading'),
                          icon: Icons.hourglass_top_rounded,
                          onPressed: () {},
                          isLoading: true,
                        )
                      : _hasText
                      ? _ActionButton(
                          key: const ValueKey('send'),
                          icon: Icons.send_rounded,
                          onPressed: _sendMessage,
                          color: context.colorScheme.primary,
                        )
                      : _ActionButton(
                          key: const ValueKey('add'),
                          icon: _showQuickActions
                              ? Icons.close_rounded
                              : Icons.add_rounded,
                          onPressed: _toggleQuickActions,
                          color: context.colorScheme.primary,
                        ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Reply Preview ────────────────────────────────────────────────────────────

class _ReplyPreview extends StatefulWidget {
  final MessageModel message;
  final String currentUid;
  final VoidCallback? onCancel;

  const _ReplyPreview({
    super.key,
    required this.message,
    required this.currentUid,
    required this.onCancel,
  });

  @override
  State<_ReplyPreview> createState() => _ReplyPreviewState();
}

class _ReplyPreviewState extends State<_ReplyPreview> {
  String? _senderName;

  @override
  void initState() {
    super.initState();
    _resolveName();
  }

  Future<void> _resolveName() async {
    final senderId = widget.message.senderId;
    if (senderId == widget.currentUid) return; // "You" — no fetch needed
    final user = await getIt<UsersRepository>().getUserById(uid: senderId);
    if (mounted) setState(() => _senderName = user?.displayName);
  }

  @override
  Widget build(BuildContext context) {
    final isMe = widget.message.senderId == widget.currentUid;
    final senderLabel = isMe
        ? context.locale.you
        : _senderName ?? widget.message.senderId; // uid while loading

    final preview = widget.message.isDeleted
        ? context.locale.messageDeleted
        : widget.message.type != MessageType.text
        ? _mediaLabel(widget.message.type)
        : widget.message.content;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.5,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: context.colorScheme.primary, width: 3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: AppText(
                    senderLabel,
                    key: ValueKey(senderLabel),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                AppText(
                  preview,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.textSecondary,
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: widget.onCancel,
            child: Icon(
              Icons.close_rounded,
              size: 18,
              color: context.colorScheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _mediaLabel(MessageType type) {
    return switch (type) {
      MessageType.image => '📷 Photo',
      MessageType.audio => '🎵 Audio',
      MessageType.video => '🎥 Video',
      MessageType.file => '📎 File',
      _ => '',
    };
  }
}

// ─── Action Button ────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final bool isLoading;

  const _ActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color:
            color ??
            context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
      child: isLoading
          ? Padding(
              padding: const EdgeInsets.all(14),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: context.colorScheme.onPrimary,
              ),
            )
          : IconButton(
              onPressed: onPressed,
              icon: Icon(icon, size: 20, color: context.colorScheme.onPrimary),
            ),
    );
  }
}
