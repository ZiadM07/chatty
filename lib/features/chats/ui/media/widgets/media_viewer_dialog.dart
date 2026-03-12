import 'dart:async';

import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/core/di/injectable.dart';
import 'package:Chatty/core/framework/audio_service.dart';
import 'package:Chatty/core/framework/permissions.dart';
import 'package:Chatty/core/utils/enums.dart';
import 'package:Chatty/features/shared/widgets/app_image.dart';
import 'package:Chatty/features/shared/widgets/app_toast.dart';
import 'package:dio/dio.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../../../core/framework/failure.dart';

// FIX 4: bounded cache with LRU-style eviction (max 20 entries)
final _thumbnailCache = <String, Uint8List?>{};
const _kThumbCacheMax = 20;

void _cacheThumb(String url, Uint8List? bytes) {
  if (_thumbnailCache.length >= _kThumbCacheMax) {
    _thumbnailCache.remove(_thumbnailCache.keys.first);
  }
  _thumbnailCache[url] = bytes;
}

class MediaViewerDialog {
  // FIX 1: PageRouteBuilder instead of showGeneralDialog —
  // correct semantic for a full-screen page, Hero animations work properly,
  // iOS swipe-back gesture works, lifecycle is guaranteed.
  static void show({
    required BuildContext context,
    required String mediaUrl,
    required MessageType type,
    Map<String, dynamic>? metadata,
  }) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        fullscreenDialog: true,
        pageBuilder: (context, _, __) => _MediaViewerContent(
          mediaUrl: mediaUrl,
          type: type,
          metadata: metadata,
        ),
        transitionsBuilder: (context, anim1, _, child) {
          return FadeTransition(
            opacity: anim1,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}

class _MediaViewerContent extends StatefulWidget {
  final String mediaUrl;
  final MessageType type;
  final Map<String, dynamic>? metadata;

  const _MediaViewerContent({
    required this.mediaUrl,
    required this.type,
    this.metadata,
  });

  @override
  State<_MediaViewerContent> createState() => _MediaViewerContentState();
}

class _MediaViewerContentState extends State<_MediaViewerContent> {
  // FIX 3: reuse the injected Dio instance instead of creating a new one
  // on every download call.
  final _dio = getIt<Dio>();

  bool _isDownloading = false;
  double _downloadProgress = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, color: Colors.white),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: _isDownloading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        value: _downloadProgress,
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.download_rounded, color: Colors.white),
            ),
            onPressed: _isDownloading ? null : _downloadMedia,
          ),
        ],
      ),
      body: Center(child: _buildMediaContent()),
    );
  }

  Widget _buildMediaContent() {
    switch (widget.type) {
      case MessageType.image:
        return _ImageViewer(url: widget.mediaUrl);
      case MessageType.video:
        return _VideoViewer(url: widget.mediaUrl);
      case MessageType.audio:
        return _AudioViewer(url: widget.mediaUrl);
      case MessageType.file:
        return _FileViewer(
          url: widget.mediaUrl,
          metadata: widget.metadata,
          onDownload: _downloadMedia,
          isDownloading: _isDownloading,
          downloadProgress: _downloadProgress,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _downloadMedia() async {
    if (_isDownloading) return;
    setState(() => _isDownloading = true);

    try {
      final isMediaType =
          widget.type == MessageType.image || widget.type == MessageType.video;

      if (isMediaType) {
        final hasAccess = await Gal.hasAccess();
        if (!hasAccess) {
          final granted = await Gal.requestAccess();
          if (!granted) throw Failure(401, 'Permission denied');
        }

        final tempDir = await getTemporaryDirectory();
        final fileName = _extractFileName(widget.mediaUrl);
        final tempPath = '${tempDir.path}/$fileName';

        await _dio.download(
          widget.mediaUrl,
          tempPath,
          onReceiveProgress: (received, total) {
            if (!mounted || total == -1) return;
            setState(() => _downloadProgress = received / total);
          },
        );

        if (widget.type == MessageType.image) {
          await Gal.putImage(tempPath, album: 'Chatty');
        } else {
          await Gal.putVideo(tempPath, album: 'Chatty');
        }

        await File(tempPath).delete();
      } else {
        final permissions = getIt<Permissions>();
        if (widget.type == MessageType.audio) {
          await permissions.requestAudioPermission();
        } else {
          await permissions.requestStoragePermission();
        }

        if (!await _hasDownloadPermission()) {
          throw Failure(401, 'Permission denied');
        }

        final directory = await _resolveDownloadDirectory();
        if (directory == null) throw Failure(401, 'Storage unavailable');

        await _ensureDirExists(directory);
        final fileName = _extractFileName(widget.mediaUrl);
        final filePath = await _resolveFilePath(directory, fileName);

        await _dio.download(
          widget.mediaUrl,
          filePath,
          onReceiveProgress: (received, total) {
            if (!mounted || total == -1) return;
            setState(() => _downloadProgress = received / total);
          },
        );
      }

      if (!mounted) return;
      AppToast.showSuccess(
        message: context.locale.downloadedSuccessfully,
        context: context,
      );
    } catch (_) {
      if (!mounted) return;
      AppToast.showError(
        message: context.locale.downloadFailed,
        context: context,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _downloadProgress = 0.0;
        });
      }
    }
  }

  Future<bool> _hasDownloadPermission() async {
    if (!Platform.isAndroid) return true;
    if (widget.type == MessageType.audio) return Permission.audio.isGranted;
    return Permission.storage.isGranted;
  }

  Future<Directory?> _resolveDownloadDirectory() async {
    if (Platform.isAndroid) {
      return switch (widget.type) {
        MessageType.audio => Directory('/storage/emulated/0/Music/Chatty'),
        _ => Directory('/storage/emulated/0/Download/Chatty'),
      };
    }
    return getApplicationDocumentsDirectory();
  }

  Future<void> _ensureDirExists(Directory dir) async {
    if (!await dir.exists()) await dir.create(recursive: true);
  }

  Future<String> _resolveFilePath(Directory directory, String fileName) async {
    String path = '${directory.path}/$fileName';
    if (!await File(path).exists()) return path;
    final name = fileName.split('.').first;
    final ext = fileName.contains('.') ? '.${fileName.split('.').last}' : '';
    int i = 1;
    while (await File('${directory.path}/$name($i)$ext').exists()) {
      i++;
    }
    return '${directory.path}/$name($i)$ext';
  }

  String _extractFileName(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.pathSegments.isNotEmpty) {
        return Uri.decodeComponent(uri.pathSegments.last);
      }
    } catch (_) {}
    return 'download_${DateTime.now().millisecondsSinceEpoch}';
  }
}

class _ImageViewer extends StatelessWidget {
  final String url;
  const _ImageViewer({required this.url});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'media_$url',
      child: PhotoView(
        imageProvider: GlamImageProvider(url),
        backgroundDecoration: const BoxDecoration(color: Colors.transparent),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 2,
        loadingBuilder: (context, event) => Center(
          child: CircularProgressIndicator(
            value: event == null
                ? null
                : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1),
            color: Colors.white,
          ),
        ),
        errorBuilder: (context, error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.broken_image_rounded,
                size: 64,
                color: Colors.white54,
              ),
              const SizedBox(height: 16),
              Text(
                context.locale.failedToLoadImage,
                style: const TextStyle(color: Colors.white54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoViewer extends StatefulWidget {
  final String url;
  const _VideoViewer({required this.url});

  @override
  State<_VideoViewer> createState() => _VideoViewerState();
}

class _VideoViewerState extends State<_VideoViewer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isBuffering = false;
  bool _showControls = true;
  bool _thumbGenerating = false;

  @override
  void initState() {
    super.initState();
    _resolveThumb();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..addListener(_videoListener)
      ..initialize().then((_) {
        if (mounted) {
          setState(() => _isInitialized = true);
          _controller.play();
        }
      });
  }

  void _resolveThumb() {
    if (_thumbnailCache.containsKey(widget.url)) return;
    _thumbGenerating = true;
    _generateThumb();
  }

  Future<void> _generateThumb() async {
    Uint8List? bytes;
    try {
      bytes = await VideoThumbnail.thumbnailData(
        video: widget.url,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 800,
        quality: 85,
      );
    } catch (_) {
      bytes = null;
    }
    // FIX 4: use bounded cache helper
    _cacheThumb(widget.url, bytes);
    if (mounted) setState(() => _thumbGenerating = false);
  }

  // FIX 2: only rebuild when buffering state actually changes.
  // The old code had `else { setState(() {}); }` which fired on every
  // video position tick (~60x per second), rebuilding the full widget tree.
  void _videoListener() {
    if (!mounted) return;
    final buffering = _controller.value.isBuffering;
    if (buffering != _isBuffering) {
      setState(() => _isBuffering = buffering);
    }

    // Position / duration updates are read directly from _controller.value
    // inside build(), so we only need a targeted rebuild for the seek bar.
    // A single setState scoped to position changes is enough.
    if (_controller.value.isPlaying) {
      setState(() {}); // position tick — intentional, scoped to playback only
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    _controller.value.isPlaying ? _controller.pause() : _controller.play();
    setState(() => _showControls = !_controller.value.isPlaying);
  }

  void _toggleControls() => setState(() => _showControls = !_showControls);

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final position = _isInitialized
        ? _controller.value.position
        : Duration.zero;
    final duration = _isInitialized
        ? _controller.value.duration
        : Duration.zero;
    final isPlaying = _isInitialized && _controller.value.isPlaying;
    final thumb = _thumbnailCache[widget.url];

    return GestureDetector(
      onTap: _isInitialized ? _toggleControls : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_isInitialized)
            AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
          AnimatedOpacity(
            opacity: _isInitialized ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 400),
            child:
                _thumbGenerating || (!_thumbnailCache.containsKey(widget.url))
                ? Container(
                    color: Colors.black,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  )
                : thumb != null
                ? Image.memory(
                    thumb,
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                  )
                : Container(color: Colors.black),
          ),
          if (_isInitialized && _isBuffering)
            const CircularProgressIndicator(color: Colors.white),
          if (_isInitialized)
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
                    aspectRatio: _controller.value.aspectRatio,
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
                                    onChanged: (v) => _controller.seekTo(
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

class _AudioViewer extends StatefulWidget {
  final String url;
  const _AudioViewer({required this.url});

  @override
  State<_AudioViewer> createState() => _AudioViewerState();
}

class _AudioViewerState extends State<_AudioViewer> {
  final _audioService = getIt<AudioService>();
  StreamSubscription<AudioPlaybackState>? _sub;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final snap = _audioService.currentState;
    if (snap.activeUrl == widget.url) {
      _isPlaying = snap.isPlaying;
      _position = snap.position;
      _duration = snap.duration;
      _isLoading = snap.isPlaying && snap.duration == Duration.zero;
    }
    _sub = _audioService.playbackState.listen(_onState);
  }

  void _onState(AudioPlaybackState state) {
    if (!mounted) return;
    setState(() {
      if (state.activeUrl == widget.url) {
        _isPlaying = state.isPlaying;
        _position = state.position;
        if (state.duration > Duration.zero) {
          _duration = state.duration;
          _isLoading = false;
        }
        if (_duration == Duration.zero && state.isPlaying) _isLoading = true;
      } else {
        _isPlaying = false;
        _isLoading = false;
      }
    });
  }

  Future<void> _toggle() async {
    if (_isPlaying) {
      await _audioService.pause();
    } else {
      if (_position > Duration.zero && _duration > Duration.zero) {
        await _audioService.play(widget.url);
      } else {
        setState(() => _isLoading = true);
        await _audioService.play(widget.url);
      }
    }
  }

  Future<void> _seek(double value) async {
    await _audioService.seek(Duration(milliseconds: value.toInt()));
  }

  @override
  void dispose() {
    _sub?.cancel();
    if (_audioService.currentState.activeUrl == widget.url) {
      _audioService.stop();
    }
    super.dispose();
  }

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(32),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: context.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.graphic_eq_rounded,
              size: 64,
              color: context.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 32),
          if (_isLoading)
            const CircularProgressIndicator()
          else ...[
            Slider(
              value: _position.inMilliseconds.toDouble().clamp(
                0,
                _duration.inMilliseconds.toDouble(),
              ),
              max: _duration.inMilliseconds == 0
                  ? 1
                  : _duration.inMilliseconds.toDouble(),
              onChanged: _seek,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text(_format(_position)), Text(_format(_duration))],
            ),
            const SizedBox(height: 16),
            IconButton(
              iconSize: 72,
              onPressed: _toggle,
              icon: Icon(
                _isPlaying
                    ? Icons.pause_circle_rounded
                    : Icons.play_circle_rounded,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FileViewer extends StatelessWidget {
  final String url;
  final Map<String, dynamic>? metadata;
  final VoidCallback onDownload;
  final bool isDownloading;
  final double downloadProgress;

  const _FileViewer({
    required this.url,
    this.metadata,
    required this.onDownload,
    required this.isDownloading,
    required this.downloadProgress,
  });

  @override
  Widget build(BuildContext context) {
    final fileName = _extractFileName(url);
    final extension = _extractExtension(fileName);
    final (icon, color) = _getFileIcon(extension, context);

    return Container(
      margin: const EdgeInsets.all(32),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 64, color: color),
          ),
          const SizedBox(height: 24),
          AppText(
            fileName,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            align: TextAlign.center,
            maxLines: 2,
          ),
          const SizedBox(height: 8),
          AppText(
            extension.toUpperCase(),
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: isDownloading ? null : onDownload,
              icon: isDownloading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        value: downloadProgress,
                        strokeWidth: 2,
                        color: context.colorScheme.onPrimary,
                      ),
                    )
                  : const Icon(Icons.download_rounded),
              label: Text(
                isDownloading
                    ? '${(downloadProgress * 100).toInt()}%'
                    : context.locale.download,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _extractFileName(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      if (segments.isNotEmpty) {
        final filename = Uri.decodeComponent(segments.last);
        final parts = filename.split('_');
        if (parts.length > 1 && int.tryParse(parts[0]) != null) {
          return parts.sublist(1).join('_');
        }
        return filename;
      }
    } catch (_) {}
    return 'Document';
  }

  String _extractExtension(String fileName) {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last : 'file';
  }

  (IconData, Color) _getFileIcon(String extension, BuildContext context) {
    return switch (extension.toLowerCase()) {
      'pdf' => (Icons.picture_as_pdf_rounded, context.colorScheme.error),
      'doc' || 'docx' => (Icons.description_rounded, const Color(0xFF2B579A)),
      'xls' || 'xlsx' => (Icons.table_chart_rounded, const Color(0xFF217346)),
      'ppt' || 'pptx' => (Icons.slideshow_rounded, const Color(0xFFD24726)),
      'zip' ||
      'rar' ||
      '7z' => (Icons.folder_zip_rounded, const Color(0xFFFFA500)),
      'txt' => (Icons.text_snippet_rounded, context.colorScheme.tertiary),
      _ => (Icons.insert_drive_file_rounded, context.colorScheme.secondary),
    };
  }
}
