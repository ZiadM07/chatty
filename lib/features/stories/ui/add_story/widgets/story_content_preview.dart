import 'package:Chatty/core/constants/exports.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:video_player/video_player.dart';

class StoryContentPreview extends StatefulWidget {
  final bool isVideo;
  final File pickedFile;
  final String? caption;

  const StoryContentPreview({
    super.key,
    required this.isVideo,
    required this.pickedFile,
    this.caption,
  });

  @override
  State<StoryContentPreview> createState() => _StoryContentPreviewState();
}

class _StoryContentPreviewState extends State<StoryContentPreview> {
  Color _color1 = Colors.black;
  Color _color2 = Colors.black;

  @override
  void initState() {
    super.initState();
    _extractColors();
  }

  @override
  void didUpdateWidget(covariant StoryContentPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pickedFile.path != widget.pickedFile.path) {
      _extractColors();
    }
  }

  Future<void> _extractColors() async {
    if (widget.isVideo) return;
    try {
      final generator = await PaletteGenerator.fromImageProvider(
        FileImage(widget.pickedFile),
        maximumColorCount: 16,
      );
      if (generator.paletteColors.isNotEmpty && mounted) {
        final colors = generator.paletteColors;
        setState(() {
          _color1 = colors[0].color;
          _color2 = colors.length > 1 ? colors[1].color : colors[0].color;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _GradientBackground(color1: _color1, color2: _color2),
        _MediaContent(isVideo: widget.isVideo, file: widget.pickedFile),
        if (widget.caption != null && widget.caption!.isNotEmpty)
          _CaptionOverlay(caption: widget.caption!),
      ],
    );
  }
}

class _GradientBackground extends StatelessWidget {
  final Color color1;
  final Color color2;

  const _GradientBackground({required this.color1, required this.color2});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color1, color2],
        ),
      ),
    );
  }
}

class _MediaContent extends StatelessWidget {
  final bool isVideo;
  final File file;

  const _MediaContent({required this.isVideo, required this.file});

  @override
  Widget build(BuildContext context) {
    if (!isVideo) {
      return Image.file(file, fit: BoxFit.contain);
    }
    return _VideoPreview(file: file);
  }
}

class _VideoPreview extends StatefulWidget {
  final File file;

  const _VideoPreview({required this.file});

  @override
  State<_VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<_VideoPreview> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  @override
  void didUpdateWidget(covariant _VideoPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.file.path != widget.file.path) {
      _controller.dispose();
      _initialized = false;
      _hasError = false;
      _initController();
    }
  }

  Future<void> _initController() async {
    _controller = VideoPlayerController.file(widget.file);
    try {
      await _controller.initialize();
      await _controller.setLooping(true);
      await _controller.play();
      if (mounted) setState(() => _initialized = true);
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return const Center(
        child: Icon(
          Icons.error_outline_rounded,
          size: 48,
          color: Colors.white54,
        ),
      );
    }

    if (!_initialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white54, strokeWidth: 2),
      );
    }

    return GestureDetector(
      onTap: () {
        _controller.value.isPlaying ? _controller.pause() : _controller.play();
        setState(() {});
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
          ),

          if (!_controller.value.isPlaying)
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
        ],
      ),
    );
  }
}

class _CaptionOverlay extends StatelessWidget {
  final String caption;

  const _CaptionOverlay({required this.caption});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 20,
      right: 20,
      bottom: 120,
      child: Container(
        padding: const AppPadding.set(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(12),
        ),
        child: AppText(
          caption,
          align: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
