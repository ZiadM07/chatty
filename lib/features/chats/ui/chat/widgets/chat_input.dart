import 'dart:async';
import 'dart:math' as math;
import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/core/di/injectable.dart';
import 'package:Chatty/core/framework/pick_file.dart';
import 'package:Chatty/core/utils/enums.dart';
import 'package:Chatty/features/chats/data/models/message_model.dart';
import 'package:Chatty/features/chats/ui/chat/widgets/show_file_preview_sheet.dart';
import 'package:Chatty/features/shared/cubits/app_cubit.dart';
import 'package:Chatty/features/shared/widgets/app_toast.dart';
import '../../../../../core/framework/audio_service.dart';
import '../../../../users/data/repositories/users_repository.dart';

class ChatInput extends StatefulWidget {
  final ValueChanged<String>? onSendPressed;
  final void Function(String)? onTextChanged;
  final TextEditingController? controller;
  final String? hintText;
  final FocusNode? focusNode;
  final void Function(File file)? onSendAttachment;
  final void Function(RecordingResult result)? onSendVoice;
  final bool isSendingMedia;
  final MessageModel? replyingTo;
  final String? currentUid;
  final VoidCallback? onCancelReply;
  final Map<String, String> memberNames;

  const ChatInput({
    super.key,
    required this.onSendPressed,
    required this.onTextChanged,
    required this.controller,
    required this.hintText,
    required this.focusNode,
    required this.onSendAttachment,
    this.onSendVoice,
    this.isSendingMedia = false,
    this.replyingTo,
    this.currentUid,
    this.onCancelReply,
    this.memberNames = const {},
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  late final TextEditingController _controller;
  late final bool _ownsController;
  bool _hasText = false;
  bool _showQuickActions = false;
  final _audioService = getIt<AudioService>();

  bool _isRecording = false;
  Duration _recordDuration = Duration.zero;
  Timer? _recordTimer;
  double _dragOffset = 0;
  static const double _cancelThreshold = 100.0;
  Timer? _longPressTimer;
  Offset? _pointerDownPosition;
  static const Duration _longPressDuration = Duration(milliseconds: 400);

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
    widget.focusNode?.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    if ((widget.focusNode?.hasFocus ?? false) && _showQuickActions) {
      setState(() => _showQuickActions = false);
    }
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

  Future<void> _camera() async {
    setState(() => _showQuickActions = false);
    final file = await PickFile.camera();
    if (file != null && mounted) widget.onSendAttachment?.call(file);
  }

  Future<void> _pickFile() async {
    setState(() => _showQuickActions = false);
    final file = await PickFile.media();
    if (file == null || !mounted) return;

    ShowFilePreviewSheet.show(
      context,
      file,
      onSend: (confirmedFile, _) {
        widget.onSendAttachment?.call(confirmedFile);
      },
    );
  }

  void _onMicPointerDown(PointerDownEvent event) {
    _pointerDownPosition = event.position;
    _longPressTimer?.cancel();
    _longPressTimer = Timer(_longPressDuration, () => _startRecording());
  }

  void _onMicPointerMove(PointerMoveEvent event) {
    if (!_isRecording) return;
    final dx =
        event.position.dx - (_pointerDownPosition?.dx ?? event.position.dx);
    final newOffset = dx.clamp(-_cancelThreshold * 1.5, 0.0);
    if ((newOffset - _dragOffset).abs() > 1.0) {
      setState(() => _dragOffset = newOffset);
    }
  }

  void _onMicPointerUp(PointerUpEvent event) {
    _longPressTimer?.cancel();
    _longPressTimer = null;
    if (_isRecording) _stopRecording();
  }

  void _onMicPointerCancel(PointerCancelEvent event) {
    _longPressTimer?.cancel();
    _longPressTimer = null;
    if (_isRecording) _stopRecording(forceCancel: true);
  }

  Future<void> _startRecording() async {
    if (!mounted) return;

    final hasPermission = await _audioService.hasRecordPermission();
    if (!mounted) return;

    if (!hasPermission) {
      AppToast.showError(
        context: context,
        message: context.locale.permissionDenied,
      );
      return;
    }

    await _audioService.startRecording();
    if (!mounted) return;

    setState(() {
      _isRecording = true;
      _recordDuration = Duration.zero;
      _dragOffset = 0;
      _showQuickActions = false;
    });

    _recordTimer?.cancel();
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _recordDuration += const Duration(seconds: 1));
      }
    });
  }

  Future<void> _stopRecording({bool forceCancel = false}) async {
    _recordTimer?.cancel();
    _recordTimer = null;

    final cancelled = forceCancel || _dragOffset <= -_cancelThreshold;
    final result = await _audioService.stopRecording();

    if (!mounted) return;

    setState(() {
      _isRecording = false;
      _dragOffset = 0;
      _pointerDownPosition = null;
    });

    if (cancelled || result.file == null) return;

    if (widget.onSendVoice != null) {
      widget.onSendVoice!(result);
    } else {
      widget.onSendAttachment?.call(result.file!);
    }
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    _longPressTimer?.cancel();
    widget.focusNode?.removeListener(_onFocusChanged);
    _controller.removeListener(_onTextChanged);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appCubit = context.read<AppCubit>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, anim) => SizeTransition(
            sizeFactor: anim,
            axisAlignment: -1,
            child: FadeTransition(opacity: anim, child: child),
          ),
          child: _isRecording
              ? _RecordingBar(
                  key: const ValueKey('recording_bar'),
                  duration: _recordDuration,
                  dragOffset: _dragOffset,
                  cancelThreshold: _cancelThreshold,
                )
              : const SizedBox.shrink(),
        ),

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
                  memberNames: widget.memberNames,
                )
              : const SizedBox.shrink(),
        ),

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
                  onSubmitted: (_) {
                    if (appCubit.enterIsSend) _sendMessage();
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
                              onPressed: _camera,
                            ),
                            Listener(
                              onPointerDown: _onMicPointerDown,
                              onPointerMove: _onMicPointerMove,
                              onPointerUp: _onMicPointerUp,
                              onPointerCancel: _onMicPointerCancel,
                              child: _MicButton(isRecording: _isRecording),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),

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

class _RecordingBar extends StatelessWidget {
  final Duration duration;
  final double dragOffset;
  final double cancelThreshold;

  const _RecordingBar({
    super.key,
    required this.duration,
    required this.dragOffset,
    required this.cancelThreshold,
  });

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final cancelProgress = (-dragOffset / cancelThreshold).clamp(0.0, 1.0);
    final accentColor = Color.lerp(
      context.colorScheme.primary,
      context.colorScheme.error,
      cancelProgress,
    )!;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.6,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accentColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          _PulsingIcon(color: accentColor),
          const SizedBox(width: 10),
          AppText(
            _format(duration),
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.textPrimary,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 10),
          const _MiniWaveform(),
          const Spacer(),
          AnimatedOpacity(
            opacity: 1.0 - cancelProgress,
            duration: const Duration(milliseconds: 100),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.chevron_left_rounded,
                  size: 16,
                  color: context.colorScheme.textSecondary,
                ),
                AppText(
                  context.locale.slideToCancel,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          AnimatedOpacity(
            opacity: cancelProgress,
            duration: const Duration(milliseconds: 100),
            child: AppText(
              context.locale.releaseToCancel,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingIcon extends StatefulWidget {
  final Color color;
  const _PulsingIcon({required this.color});

  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _scale = Tween(
      begin: 0.9,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Icon(Icons.mic_rounded, color: widget.color, size: 22),
    );
  }
}

class _MiniWaveform extends StatefulWidget {
  const _MiniWaveform();

  @override
  State<_MiniWaveform> createState() => _MiniWaveformState();
}

class _MiniWaveformState extends State<_MiniWaveform>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) {
        return Row(
          spacing: 3,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(6, (i) {
            final phase = (_ctrl.value + i / 6) % 1.0;
            final height = 6.0 + 14.0 * math.sin(phase * math.pi).abs();
            return Container(
              width: 3,
              height: height,
              decoration: BoxDecoration(
                color: context.colorScheme.primary.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }
}

class _ReplyPreview extends StatefulWidget {
  final MessageModel message;
  final String currentUid;
  final VoidCallback? onCancel;
  final Map<String, String> memberNames;

  const _ReplyPreview({
    super.key,
    required this.message,
    required this.currentUid,
    required this.onCancel,
    required this.memberNames,
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

  @override
  void didUpdateWidget(covariant _ReplyPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message.id != widget.message.id ||
        oldWidget.message.senderId != widget.message.senderId) {
      _senderName = null;
      _resolveName();
    }
  }

  Future<void> _resolveName() async {
    final senderId = widget.message.senderId;
    if (senderId == widget.currentUid) return;
    final cached = widget.memberNames[senderId];
    if (cached != null) {
      if (mounted) setState(() => _senderName = cached);
      return;
    }
    final user = await getIt<UsersRepository>().getUserById(uid: senderId);
    if (mounted) setState(() => _senderName = user?.displayName);
  }

  @override
  Widget build(BuildContext context) {
    final isMe = widget.message.senderId == widget.currentUid;
    final senderLabel = isMe
        ? context.locale.you
        : _senderName ?? widget.message.senderId;

    final preview = widget.message.isDeleted
        ? context.locale.messageDeleted
        : widget.message.type != MessageType.text
        ? _mediaLabel(widget.message.type)
        : widget.message.content;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest,
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

  String _mediaLabel(MessageType type) => switch (type) {
    MessageType.image => '📷 Photo',
    MessageType.audio => '🎵 Audio',
    MessageType.video => '🎥 Video',
    MessageType.file => '📎 File',
    _ => '',
  };
}

class _MicButton extends StatelessWidget {
  final bool isRecording;
  const _MicButton({required this.isRecording});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isRecording
            ? context.colorScheme.error
            : context.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.5,
              ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          SolarIconsBold.microphone2,
          size: 20,
          color: context.colorScheme.onPrimary,
        ),
      ),
    );
  }
}

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
