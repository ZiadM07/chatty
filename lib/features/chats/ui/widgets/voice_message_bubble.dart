import 'dart:async';

import 'package:Chatty/core/di/injectable.dart';
import 'package:Chatty/core/framework/audio_service.dart';
import 'package:Chatty/core/utils/enums.dart';
import 'package:Chatty/core/utils/extensions.dart';
import 'package:Chatty/features/chats/data/models/message_model.dart';
import 'package:Chatty/features/chats/ui/widgets/message_bubble_shell.dart';
import 'package:Chatty/features/chats/ui/widgets/message_reaction_overlay.dart';
import 'package:Chatty/features/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';

class VoiceMessageBubble extends StatefulWidget {
  final MessageModel message; // ← now takes full model
  final String time;
  final MessageStatus? status;
  final bool isMe;
  final String? currentUid;
  final String? replyToContent;
  final String? replyToSenderId;
  final MessageType? replyToType;
  final VoidCallback? onReplyTap;
  final Map<String, String> memberNames;

  // Reaction / menu callbacks
  final ValueChanged<String?> onReact;
  final VoidCallback onReply;
  final VoidCallback? onDelete;

  const VoiceMessageBubble({
    super.key,
    required this.message,
    required this.time,
    this.status,
    required this.isMe,
    this.currentUid,
    this.replyToContent,
    this.replyToSenderId,
    this.replyToType,
    this.onReplyTap,
    this.memberNames = const {},
    required this.onReact,
    required this.onReply,
    this.onDelete,
  });

  @override
  State<VoiceMessageBubble> createState() => _VoiceMessageBubbleState();
}

class _VoiceMessageBubbleState extends State<VoiceMessageBubble> {
  final _audioService = getIt<AudioService>();
  StreamSubscription<AudioPlaybackState>? _sub;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  String get _audioUrl => widget.message.content;
  bool get _isDeleted => widget.message.isDeleted;
  Duration get _sourceDuration =>
      Duration(milliseconds: widget.message.metadata?['duration'] as int? ?? 0);

  @override
  void initState() {
    super.initState();
    _duration = _sourceDuration;
    _sub = _audioService.playbackState.listen(_onPlaybackState);
    final snap = _audioService.currentState;
    if (snap.activeUrl == _audioUrl) {
      _isPlaying = snap.isPlaying;
      _position = snap.position;
      if (snap.duration > Duration.zero) _duration = snap.duration;
    }
  }

  void _onPlaybackState(AudioPlaybackState state) {
    if (!mounted) return;
    setState(() {
      if (state.activeUrl == _audioUrl) {
        _isPlaying = state.isPlaying;
        _position = state.position;
        if (state.duration > Duration.zero) _duration = state.duration;
      } else {
        _isPlaying = false;
        _position = Duration.zero;
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    if (_isDeleted) return;
    if (_isPlaying) {
      await _audioService.pause();
    } else {
      await _audioService.play(_audioUrl);
    }
  }

  Future<void> _onSeek(double normalized) async {
    if (_isDeleted || _duration == Duration.zero) return;
    await _audioService.seek(_duration * normalized);
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _duration.inMilliseconds > 0
        ? (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    final subtleColor =
        (widget.isMe
                ? context.colorScheme.onPrimary
                : context.colorScheme.onSurface)
            .withValues(alpha: 0.6);

    final bubble = MessageBubbleShell(
      isMe: widget.isMe,
      isDeleted: _isDeleted,
      minWidth: 220,
      time: null,
      replyToContent: widget.replyToContent,
      replyToSenderId: widget.replyToSenderId,
      currentUid: widget.currentUid,
      replyToType: widget.replyToType,
      onReplyTap: widget.onReplyTap,
      memberNames: widget.memberNames,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _togglePlayback,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: widget.isMe
                        ? Colors.white.withValues(alpha: 0.2)
                        : context.colorScheme.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: widget.isMe
                        ? context.colorScheme.onPrimary
                        : context.colorScheme.primary,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Waveform(
                  progress: progress,
                  isMe: widget.isMe,
                  onSeek: _onSeek,
                ),
              ),
              const SizedBox(width: 10),
              AppText(
                _isPlaying ? _fmt(_position) : _fmt(_duration),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: subtleColor,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppText(
                widget.time,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: subtleColor,
                ),
              ),
              if (widget.isMe && widget.status != null) ...[
                const SizedBox(width: 4),
                AppText(
                  bubbleStatusText(widget.status!, context),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: widget.status == MessageStatus.read
                        ? Colors.lightBlueAccent.withValues(alpha: 0.9)
                        : subtleColor,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );

    return BubbleWithReactions(
      message: widget.message,
      isMe: widget.isMe,
      currentUid: widget.currentUid ?? '',
      onReply: widget.onReply,
      onReact: widget.onReact,
      onDelete: widget.onDelete,
      bubble: bubble,
    );
  }
}

class _Waveform extends StatelessWidget {
  final double progress;
  final bool isMe;
  final ValueChanged<double> onSeek;

  const _Waveform({
    required this.progress,
    required this.isMe,
    required this.onSeek,
  });

  static final _heights = List.generate(
    30,
    (i) => 0.22 + ((i * 12 + 7) % 17) / 13 * 0.70,
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (d) {
        final box = context.findRenderObject() as RenderBox;
        onSeek((d.localPosition.dx / box.size.width).clamp(0.0, 1.0));
      },
      child: SizedBox(
        height: 20,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(_heights.length, (i) {
            final isPast = (i / _heights.length) <= progress;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 80),
              width: 2.5,
              height: _heights[i] * 20,
              decoration: BoxDecoration(
                color: isPast
                    ? (isMe
                          ? Colors.white.withValues(alpha: 0.9)
                          : context.colorScheme.primary)
                    : (isMe
                          ? Colors.white.withValues(alpha: 0.28)
                          : context.colorScheme.outline.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        ),
      ),
    );
  }
}
