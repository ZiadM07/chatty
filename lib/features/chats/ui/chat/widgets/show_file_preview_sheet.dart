import 'dart:math' as math;
import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/features/shared/widgets/app_gradient_button.dart';
import 'package:Chatty/features/shared/widgets/app_file_image.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart';

enum _FileKind { image, video, audio, document }

_FileKind _kindOf(File file) {
  final mime = lookupMimeType(file.path) ?? '';
  if (mime.startsWith('image/')) return _FileKind.image;
  if (mime.startsWith('video/')) return _FileKind.video;
  if (mime.startsWith('audio/')) return _FileKind.audio;
  return _FileKind.document;
}

class ShowFilePreviewSheet {
  const ShowFilePreviewSheet._();

  static Future<void> show(
    BuildContext context,
    File file, {
    void Function(File file, String? caption)? onSend,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: context.colorScheme.scrim.withValues(alpha: 0.6),
      builder: (_) => _FilePreviewSheet(file: file, onSend: onSend),
    );
  }
}

class _FilePreviewSheet extends StatefulWidget {
  final File file;
  final void Function(File file, String? caption)? onSend;

  const _FilePreviewSheet({required this.file, this.onSend});

  @override
  State<_FilePreviewSheet> createState() => _FilePreviewSheetState();
}

class _FilePreviewSheetState extends State<_FilePreviewSheet> {
  late final _FileKind _kind;

  @override
  void initState() {
    super.initState();
    _kind = _kindOf(widget.file);
  }

  void _send() {
    widget.onSend?.call(widget.file, null);
    context.router.maybePop();
  }

  void _cancel() => context.router.maybePop();

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: AppPadding.set(bottom: bottomPad),
      child: Container(
        constraints: BoxConstraints(maxHeight: context.height * 0.92),
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SheetHandle(),
            _SheetHeader(
              fileName: p.basename(widget.file.path),
              kind: _kind,
              onCancel: _cancel,
            ),
            Flexible(
              child: _PreviewArea(file: widget.file, kind: _kind),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: context.locale.cancel,
                    onTap: () {
                      context.router.pop();
                    },
                    type: AppButtonType.normal,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    text: context.locale.send,
                    onTap: _send,
                    type: AppButtonType.gradient,
                  ),
                ),
              ],
            ).addPadding(horizontal: 15),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppPadding.set(top: 10, bottom: 4),
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: context.colorScheme.outlineVariant.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  final String fileName;
  final _FileKind kind;
  final VoidCallback onCancel;

  const _SheetHeader({
    required this.fileName,
    required this.kind,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _KindBadge(kind: kind),
        const SizedBox(width: 10),
        Expanded(
          child: AppText(
            fileName,
            size: 14,
            weight: FontWeight.w600,
            maxLines: 1,
            color: context.colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          Icons.close_rounded,
          size: 22,
          color: context.colorScheme.onSurfaceVariant,
        ).addAction(onBounce: onCancel),
      ],
    ).addPadding(horizontal: 20, vertical: 12);
  }
}

class _KindBadge extends StatelessWidget {
  final _FileKind kind;
  const _KindBadge({required this.kind});

  (IconData, Color) _meta(BuildContext context) => switch (kind) {
    _FileKind.image => (Icons.image_rounded, context.colorScheme.primary),
    _FileKind.video => (Icons.videocam_rounded, context.colorScheme.secondary),
    _FileKind.audio => (
      Icons.audiotrack_rounded,
      context.colorScheme.tertiaryContainer,
    ),
    _FileKind.document => (
      Icons.insert_drive_file_rounded,
      context.colorScheme.tertiary,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _meta(context);
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }
}

class _PreviewArea extends StatelessWidget {
  final File file;
  final _FileKind kind;

  const _PreviewArea({required this.file, required this.kind});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: AppPadding.set(horizontal: 16),
        constraints: BoxConstraints(
          maxHeight: context.height * 0.52,
          minHeight: 180,
        ),
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.5,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: switch (kind) {
          _FileKind.image => _ImagePreview(file: file),
          _FileKind.video => _VideoPreview(file: file),
          _FileKind.audio => _AudioPreview(file: file),
          _FileKind.document => _DocumentPreview(file: file),
        },
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final File file;
  const _ImagePreview({required this.file});

  @override
  Widget build(BuildContext context) {
    return AppFileImage(
      file,
      fit: BoxFit.contain,
      width: double.infinity,
      height: double.infinity,
    );
  }
}

class _VideoPreview extends StatefulWidget {
  final File file;
  const _VideoPreview({required this.file});

  @override
  State<_VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<_VideoPreview> {
  late final VideoPlayerController _ctrl;
  bool _initialized = false;
  bool _failed = false;
  bool _isBuffering = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _ctrl = VideoPlayerController.file(widget.file)
      ..addListener(_videoListener)
      ..initialize().then((_) {
        if (mounted) {
          setState(() => _initialized = true);
          _ctrl.play();
        }
      }).catchError((_) {
        if (mounted) setState(() => _failed = true);
      });
  }

  void _videoListener() {
    if (!mounted) return;
    final buffering = _ctrl.value.isBuffering;
    if (buffering != _isBuffering) {
      setState(() => _isBuffering = buffering);
    }
    if (_ctrl.value.isPlaying) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _ctrl.removeListener(_videoListener);
    _ctrl.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    _ctrl.value.isPlaying ? _ctrl.pause() : _ctrl.play();
    setState(() => _showControls = !_ctrl.value.isPlaying);
  }

  void _toggleControls() => setState(() => _showControls = !_showControls);

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return _BrokenFileState(
        icon: Icons.videocam_off_rounded,
        label: context.locale.couldNotLoadFile,
      );
    }

    if (!_initialized) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    final position = _ctrl.value.position;
    final duration = _ctrl.value.duration;
    final isPlaying = _ctrl.value.isPlaying;

    return GestureDetector(
      onTap: _toggleControls,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _ctrl.value.aspectRatio,
            child: VideoPlayer(_ctrl),
          ),
          if (_isBuffering) const CircularProgressIndicator(color: Colors.white),
          AnimatedOpacity(
            opacity: _showControls ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 250),
            child: IgnorePointer(
              ignoring: !_showControls,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: AspectRatio(
                  aspectRatio: _ctrl.value.aspectRatio,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Center(
                          child: GestureDetector(
                            onTap: _togglePlayPause,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: Row(
                          children: [
                            Text(
                              _format(position),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 2,
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 6,
                                  ),
                                  overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 12,
                                  ),
                                  activeTrackColor: Colors.white,
                                  inactiveTrackColor: Colors.white.withValues(
                                    alpha: 0.3,
                                  ),
                                  thumbColor: Colors.white,
                                  overlayColor: Colors.white.withValues(
                                    alpha: 0.2,
                                  ),
                                ),
                                child: Slider(
                                  value: position.inMilliseconds
                                      .toDouble()
                                      .clamp(
                                        0,
                                        duration.inMilliseconds.toDouble(),
                                      ),
                                  max: duration.inMilliseconds == 0
                                      ? 1
                                      : duration.inMilliseconds.toDouble(),
                                  onChanged: (v) => _ctrl.seekTo(
                                    Duration(milliseconds: v.toInt()),
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              _format(duration),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AudioPreview extends StatefulWidget {
  final File file;
  const _AudioPreview({required this.file});

  @override
  State<_AudioPreview> createState() => _AudioPreviewState();
}

class _AudioPreviewState extends State<_AudioPreview>
    with SingleTickerProviderStateMixin {
  final _player = AudioPlayer();
  bool _initialized = false;
  bool _failed = false;
  late final AnimationController _waveCtrl;

  @override
  void initState() {
    super.initState();
    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _player
        .setFilePath(widget.file.path)
        .then((_) {
          if (mounted) setState(() => _initialized = true);
        })
        .catchError((_) {
          if (mounted) setState(() => _failed = true);
        });

    _player.playerStateStream.listen((state) {
      if (!mounted) return;
      if (state.playing) {
        _waveCtrl.repeat();
      } else {
        _waveCtrl.stop();
      }
    });
  }

  @override
  void dispose() {
    _waveCtrl.dispose();
    _player.dispose();
    super.dispose();
  }

  String _formatDuration(Duration? d) {
    if (d == null) return '0:00';
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return _BrokenFileState(
        icon: Icons.music_off_rounded,
        label: context.locale.couldNotLoadFile,
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Waveform visualizer
        AnimatedBuilder(
          animation: _waveCtrl,
          builder: (_, i) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 4,
            children: List.generate(20, (i) {
              final phase = (_waveCtrl.value + i / 20) % 1.0;
              final height = _player.playing
                  ? 8.0 + 36.0 * math.sin(phase * math.pi).abs()
                  : 8.0 + 36.0 * math.sin(i / 20 * math.pi).abs() * 0.3;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 80),
                width: 4,
                height: height,
                decoration: BoxDecoration(
                  color: context.colorScheme.primary.withValues(
                    alpha: _player.playing ? 0.85 : 0.4,
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ).addPadding(horizontal: 24, bottom: 20),

        // Play / Pause button
        StreamBuilder<PlayerState>(
          stream: _player.playerStateStream,
          builder: (_, snap) {
            final isPlaying = snap.data?.playing ?? false;
            return _initialized
                ? Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: context.colorScheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: context.colorScheme.primary.withValues(
                            alpha: 0.35,
                          ),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: context.colorScheme.onPrimary,
                      size: 32,
                    ),
                  ).addAction(
                    onBounce: () {
                      isPlaying ? _player.pause() : _player.play();
                    },
                  )
                : const CircularProgressIndicator(strokeWidth: 2);
          },
        ),

        const SizedBox(height: 16),

        // Duration
        StreamBuilder<Duration?>(
          stream: _player.positionStream,
          builder: (_, posSnap) => StreamBuilder<Duration?>(
            stream: _player.durationStream,
            builder: (_, durSnap) {
              final pos = posSnap.data ?? Duration.zero;
              final dur = durSnap.data;
              return AppText(
                '${_formatDuration(pos)} / ${_formatDuration(dur)}',
                size: 12,
                color: context.colorScheme.onSurfaceVariant,
                style: context.textTheme.bodySmall?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // Seekbar
        StreamBuilder<Duration?>(
          stream: _player.positionStream,
          builder: (_, posSnap) => StreamBuilder<Duration?>(
            stream: _player.durationStream,
            builder: (_, durSnap) {
              final pos = posSnap.data?.inMilliseconds.toDouble() ?? 0;
              final dur = durSnap.data?.inMilliseconds.toDouble() ?? 1;
              return SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 14,
                  ),
                  activeTrackColor: context.colorScheme.primary,
                  inactiveTrackColor:
                      context.colorScheme.surfaceContainerHighest,
                  thumbColor: context.colorScheme.primary,
                ),
                child: Slider(
                  value: pos.clamp(0, dur),
                  min: 0,
                  max: dur,
                  onChanged: (v) =>
                      _player.seek(Duration(milliseconds: v.toInt())),
                ),
              );
            },
          ),
        ).addPadding(horizontal: 12),
      ],
    ).addPadding(vertical: 24);
  }
}

class _DocumentPreview extends StatelessWidget {
  final File file;
  const _DocumentPreview({required this.file});

  String _sizeLabel(File file) {
    try {
      final bytes = file.lengthSync();
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1024 * 1024) {
        return '${(bytes / 1024).toStringAsFixed(1)} KB';
      }
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (_) {
      return '';
    }
  }

  String _extLabel(File file) =>
      p.extension(file.path).replaceFirst('.', '').toUpperCase();

  @override
  Widget build(BuildContext context) {
    final ext = _extLabel(file);
    final size = _sizeLabel(file);
    final name = p.basename(file.path);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: context.colorScheme.primaryContainer.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.insert_drive_file_rounded,
                size: 48,
                color: context.colorScheme.primary.withValues(alpha: 0.8),
              ),
              if (ext.isNotEmpty)
                Positioned(
                  bottom: 14,
                  child: Container(
                    padding: AppPadding.set(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: context.colorScheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: AppText(
                      ext,
                      size: 8,
                      weight: FontWeight.w700,
                      color: context.colorScheme.onPrimary,
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        AppText(
          name,
          size: 14,
          weight: FontWeight.w600,
          maxLines: 2,
          align: TextAlign.center,
          color: context.colorScheme.onSurface,
        ).addPadding(horizontal: 32),

        if (size.isNotEmpty) ...[
          const SizedBox(height: 6),
          AppText(size, size: 12, color: context.colorScheme.onSurfaceVariant),
        ],
      ],
    );
  }
}

class _BrokenFileState extends StatelessWidget {
  final IconData icon;
  final String label;

  const _BrokenFileState({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 48,
          color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
        ),
        const SizedBox(height: 12),
        AppText(
          label,
          size: 13,
          color: context.colorScheme.onSurfaceVariant,
          align: TextAlign.center,
        ).addPadding(horizontal: 32),
      ],
    );
  }
}
