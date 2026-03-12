import 'dart:async';

import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/core/di/injectable.dart';
import 'package:Chatty/core/framework/audio_service.dart';
import 'package:Chatty/core/utils/enums.dart';
import 'package:Chatty/features/chats/data/models/message_model.dart';
import 'package:Chatty/features/chats/ui/chat/widgets/message_bubble_shell.dart';
import 'package:Chatty/features/chats/ui/chat/widgets/message_reaction_overlay.dart';

class VoiceMessageBubble extends StatefulWidget {
  final MessageModel message;
  final String time;
  final MessageStatus? status;
  final bool isMe;
  final String? currentUid;
  final String? replyToContent;
  final String? replyToSenderId;
  final MessageType? replyToType;
  final VoidCallback? onReplyTap;
  final Map<String, String> memberNames;
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
  bool _isBuffering = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  String get _audioUrl => widget.message.content;
  bool get _isDeleted => widget.message.isDeleted;

  Duration get _sourceDuration =>
      Duration(milliseconds: widget.message.metadata?['duration'] as int? ?? 0);

  List<double> get _waveformBars {
    final raw = widget.message.metadata?['waveform'];
    if (raw is List && raw.isNotEmpty) {
      return raw.map((e) => (e as num).toDouble().clamp(0.0, 1.0)).toList();
    }
    return List.generate(30, (i) => 0.22 + ((i * 12 + 7) % 17) / 13 * 0.70);
  }

  @override
  void initState() {
    super.initState();
    _duration = _sourceDuration;
    _sub = _audioService.playbackState.listen(_onPlaybackState);
    final snap = _audioService.currentState;
    if (snap.activeUrl == _audioUrl) {
      _isPlaying = snap.isPlaying;
      _isBuffering = snap.isBuffering;
      _position = snap.position;
      if (snap.duration > Duration.zero) _duration = snap.duration;
    }
  }

  void _onPlaybackState(AudioPlaybackState state) {
    if (!mounted) return;
    setState(() {
      if (state.activeUrl == _audioUrl) {
        _isPlaying = state.isPlaying;
        _isBuffering = state.isBuffering;
        _position = state.position;
        if (state.duration > Duration.zero) _duration = state.duration;
      } else {
        _isPlaying = false;
        _isBuffering = false;
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
    if (_isDeleted || _isBuffering) return;
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

    final iconColor = widget.isMe
        ? context.colorScheme.onPrimary
        : context.colorScheme.primary;

    final subtleColor =
        (widget.isMe
                ? context.colorScheme.onPrimary
                : context.colorScheme.onSurface)
            .withValues(alpha: 0.6);

    final displayDuration = _isPlaying
        ? _duration - _position
        : (_position > Duration.zero ? _duration - _position : _duration);

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
                  child: _isBuffering
                      ? Padding(
                          padding: const EdgeInsets.all(10),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: iconColor,
                          ),
                        )
                      : Icon(
                          _isPlaying
                              ? SolarIconsBold.pause
                              : SolarIconsBold.play,
                          color: iconColor,
                          size: 14,
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Waveform(
                  bars: _waveformBars,
                  progress: progress,
                  isMe: widget.isMe,
                  onSeek: _onSeek,
                ),
              ),
              const SizedBox(width: 10),
              AppText(
                _fmt(displayDuration),
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
                        ? subtleColor
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
  final List<double> bars;
  final double progress;
  final bool isMe;
  final ValueChanged<double> onSeek;

  const _Waveform({
    required this.bars,
    required this.progress,
    required this.isMe,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (d) {
        final box = context.findRenderObject() as RenderBox;
        onSeek((d.localPosition.dx / box.size.width).clamp(0.0, 1.0));
      },
      onHorizontalDragEnd: (_) {},
      child: SizedBox(
        height: 28,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(bars.length, (i) {
            final isPast = (i / bars.length) <= progress;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 80),
              width: 2.5,
              height: (bars[i] * 28).clamp(4.0, 28.0),
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
