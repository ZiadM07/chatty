import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/core/utils/enums.dart';
import 'package:Chatty/features/shared/widgets/app_image.dart';
import 'package:Chatty/features/stories/data/models/story_item_model.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:video_player/video_player.dart';

class StoryMediaPage extends StatefulWidget {
  final StoryItemModel item;

  const StoryMediaPage({super.key, required this.item});

  @override
  State<StoryMediaPage> createState() => _StoryMediaPageState();
}

class _StoryMediaPageState extends State<StoryMediaPage> {
  Color _color1 = Colors.black;
  Color _color2 = Colors.black;

  @override
  void initState() {
    super.initState();
    _extractColors();
  }

  @override
  void didUpdateWidget(covariant StoryMediaPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.url != widget.item.url) {
      _extractColors();
    }
  }

  Future<void> _extractColors() async {
    if (widget.item.type != StoryItemType.image) return;
    try {
      final generator = await PaletteGenerator.fromImageProvider(
        NetworkImage(widget.item.url),
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
    return switch (widget.item.type) {
      StoryItemType.image => _ImagePage(
        item: widget.item,
        color1: _color1,
        color2: _color2,
      ),
      StoryItemType.video => _VideoPage(url: widget.item.url),
      StoryItemType.text => _TextPage(item: widget.item),
    };
  }
}

class _ImagePage extends StatelessWidget {
  final StoryItemModel item;
  final Color color1;
  final Color color2;

  const _ImagePage({
    required this.item,
    required this.color1,
    required this.color2,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color1, color2],
            ),
          ),
        ),
        AppImage(
          imageUrl: item.url,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.contain,
        ),
      ],
    );
  }
}

class _VideoPage extends StatefulWidget {
  final String url;

  const _VideoPage({required this.url});

  @override
  State<_VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<_VideoPage> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  @override
  void didUpdateWidget(covariant _VideoPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _controller.dispose();
      _initialized = false;
      _hasError = false;
      _initController();
    }
  }

  Future<void> _initController() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
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
      return Container(
        color: Colors.black,
        child: const Center(
          child: Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: Colors.white54,
          ),
        ),
      );
    }

    if (!_initialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white54,
            strokeWidth: 2,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        _controller.value.isPlaying ? _controller.pause() : _controller.play();
        setState(() {});
      },
      child: Container(
        color: Colors.black,
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
      ),
    );
  }
}

class _TextPage extends StatelessWidget {
  final StoryItemModel item;

  const _TextPage({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: item.backgroundColor != null
              ? [
                  item.backgroundColor!,
                  item.backgroundColor!.withValues(alpha: 0.6),
                ]
              : [context.colorScheme.primary, context.colorScheme.secondary],
        ),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(40),
      child: AppText(
        item.caption ?? '',
        align: TextAlign.center,
        style: context.textTheme.headlineSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          height: 1.35,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}
