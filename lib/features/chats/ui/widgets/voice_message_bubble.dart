import 'dart:async';

import 'package:chatty/config/theme/app_color_scheme.dart';
import 'package:chatty/core/di/injectable.dart';
import 'package:chatty/core/framework/audio_service.dart';
import 'package:chatty/core/utils/enums.dart';
import 'package:chatty/core/utils/extensions.dart';
import 'package:chatty/features/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';

/// Enhanced voice message bubble with:
/// - Smooth playback progress
/// - Animated waveform visualization
/// - Visual feedback (playing state, progress)
/// - Seek support (tap waveform to jump)
/// - Global playback (one voice at a time)
///
/// Wrap with [SwipeToReply] in the parent for interactions.
class VoiceMessageBubble extends StatefulWidget {
  final String audioUrl;
  final Duration duration;
  final String time;
  final MessageStatus? status;
  final bool isMe;
  final bool isDeleted;
  final String? currentUid;

  const VoiceMessageBubble({
    super.key,
    required this.audioUrl,
    required this.duration,
    required this.time,
    this.status,
    required this.isMe,
    this.isDeleted = false,
    this.currentUid,
  });

  @override
  State<VoiceMessageBubble> createState() => _VoiceMessageBubbleState();
}

class _VoiceMessageBubbleState extends State<VoiceMessageBubble>
    with SingleTickerProviderStateMixin {
  final _audioService = getIt<AudioService>();
  StreamSubscription<PlaybackState>? _playbackSub;

  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _duration = Duration.zero;

  late AnimationController _waveController;
  late Animation<double> _playButtonScale;

  @override
  void initState() {
    super.initState();
    _duration = widget.duration;

    // Wave animation controller
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Play button scale animation (subtle pulse when playing)
    _playButtonScale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );

    // Listen to global playback state
    _playbackSub = _audioService.playbackState.listen((state) {
      if (!mounted) return;

      // Only update if this is our audio
      if (state.url == widget.audioUrl) {
        setState(() {
          _isPlaying = state.isPlaying;
          _currentPosition = state.position;
          if (state.duration > Duration.zero) {
            _duration = state.duration;
          }
        });

        if (state.isPlaying && !_waveController.isAnimating) {
          _waveController.repeat(reverse: true);
        } else if (!state.isPlaying && _waveController.isAnimating) {
          _waveController.stop();
        }
      } else if (_isPlaying) {
        // Another audio started playing — stop this one's UI
        setState(() {
          _isPlaying = false;
          _currentPosition = Duration.zero;
        });
        _waveController.stop();
      }
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _playbackSub?.cancel();
    super.dispose();
  }

  // ─── Playback control ─────────────────────────────────────────────────────

  Future<void> _togglePlayback() async {
    if (widget.isDeleted) return;

    if (_isPlaying) {
      await _audioService.pause();
      setState(() => _isPlaying = false);
      _waveController.stop();
    } else {
      await _audioService.play(widget.audioUrl);
      // State updates come through stream
    }
  }

  void _onWaveformTap(double normalizedPosition) {
    if (widget.isDeleted || _duration == Duration.zero) return;
    final seekPosition = _duration * normalizedPosition;
    _audioService.seek(seekPosition);
  }

  String _formatDuration(Duration d) {
    final mins = d.inMinutes.remainder(60);
    final secs = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _duration.inMilliseconds > 0
        ? _currentPosition.inMilliseconds / _duration.inMilliseconds
        : 0.0;

    return Align(
      alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,

      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
          minWidth: 220,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          padding: const EdgeInsets.fromLTRB(14, 12, 16, 12),
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
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(widget.isMe ? 16 : 4),
              bottomRight: Radius.circular(widget.isMe ? 4 : 16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: widget.isDeleted
              ? _DeletedVoice(isMe: widget.isMe)
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Play button + waveform + duration ──
                    Row(
                      children: [
                        // Play/pause button with scale animation
                        ScaleTransition(
                          scale: _playButtonScale,
                          child: GestureDetector(
                            onTap: _togglePlayback,
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: widget.isMe
                                    ? LinearGradient(
                                        colors: [
                                          Colors.white.withValues(alpha: 0.25),
                                          Colors.white.withValues(alpha: 0.15),
                                        ],
                                      )
                                    : LinearGradient(
                                        colors: [
                                          context.colorScheme.primary
                                              .withValues(alpha: 0.2),
                                          context.colorScheme.primary
                                              .withValues(alpha: 0.1),
                                        ],
                                      ),
                                shape: BoxShape.circle,
                                boxShadow: _isPlaying
                                    ? [
                                        BoxShadow(
                                          color:
                                              (widget.isMe
                                                      ? Colors.white
                                                      : context
                                                            .colorScheme
                                                            .primary)
                                                  .withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Icon(
                                _isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: widget.isMe
                                    ? context.colorScheme.onPrimary
                                    : context.colorScheme.primary,
                                size: 24,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Waveform with tap-to-seek
                        Expanded(
                          child: _Waveform(
                            isPlaying: _isPlaying,
                            progress: progress,
                            isMe: widget.isMe,
                            waveController: _waveController,
                            onTap: _onWaveformTap,
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Duration (animated transition)
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, anim) =>
                              FadeTransition(opacity: anim, child: child),
                          child: AppText(
                            key: ValueKey(_isPlaying),
                            _isPlaying
                                ? _formatDuration(_currentPosition)
                                : _formatDuration(_duration),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: widget.isMe
                                  ? context.colorScheme.onPrimary.withValues(
                                      alpha: 0.9,
                                    )
                                  : context.colorScheme.textPrimary,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // ── Time + status row ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AppText(
                          widget.time,
                          style: TextStyle(
                            color: widget.isMe
                                ? context.colorScheme.onPrimary.withValues(
                                    alpha: 0.7,
                                  )
                                : context.colorScheme.textSecondary,
                            fontWeight: FontWeight.w500,
                            fontSize: 10,
                          ),
                        ),
                        if (widget.isMe && widget.status != null) ...[
                          const SizedBox(width: 6),
                          AppText(
                            _statusToText(widget.status!),
                            style: TextStyle(
                              color: context.colorScheme.onPrimary.withValues(
                                alpha: 0.7,
                              ),
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
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

// ─────────────────────────────────────────────────────────────────────────────
//  Enhanced Waveform with tap-to-seek
// ─────────────────────────────────────────────────────────────────────────────

class _Waveform extends StatelessWidget {
  final bool isPlaying;
  final double progress;
  final bool isMe;
  final AnimationController waveController;
  final ValueChanged<double> onTap;

  const _Waveform({
    required this.isPlaying,
    required this.progress,
    required this.isMe,
    required this.waveController,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 35 bars with deterministic pseudo-random heights
    final barHeights = List.generate(
      35,
      (i) => 0.25 + (((i * 13 + 7) % 17) / 17) * 0.75,
    );

    return GestureDetector(
      onTapDown: (details) {
        final box = context.findRenderObject() as RenderBox;
        final localX = details.localPosition.dx;
        final normalizedX = (localX / box.size.width).clamp(0.0, 1.0);
        onTap(normalizedX);
      },
      child: Container(
        height: 36,
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(barHeights.length, (i) {
            final isPast = (i / barHeights.length) <= progress;
            final baseHeight = barHeights[i] * 36;

            return AnimatedBuilder(
              animation: waveController,
              builder: (context, child) {
                // Wave effect: animate only played bars
                final animatedHeight = isPlaying && isPast
                    ? baseHeight *
                          (0.65 +
                              0.35 *
                                  ((waveController.value +
                                          (i / barHeights.length) * 0.4)
                                      .clamp(0, 1)))
                    : baseHeight;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  width: 2.8,
                  height: animatedHeight,
                  decoration: BoxDecoration(
                    gradient: isPast
                        ? (isMe
                              ? const LinearGradient(
                                  colors: [Colors.white, Colors.white70],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                )
                              : LinearGradient(
                                  colors: [
                                    context.colorScheme.primary,
                                    context.colorScheme.primary.withValues(
                                      alpha: 0.7,
                                    ),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ))
                        : null,
                    color: !isPast
                        ? (isMe
                              ? Colors.white.withValues(alpha: 0.3)
                              : context.colorScheme.outline.withValues(
                                  alpha: 0.35,
                                ))
                        : null,
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Deleted voice message
// ─────────────────────────────────────────────────────────────────────────────

class _DeletedVoice extends StatelessWidget {
  final bool isMe;
  const _DeletedVoice({required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.block_rounded,
          size: 16,
          color: context.colorScheme.textSecondary,
        ),
        const SizedBox(width: 8),
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
