
import 'package:chatty/core/constants/exports.dart';
import 'package:chatty/core/framework/pick_file.dart';
import 'package:chatty/features/auth/cubits/auth_cubit.dart';
import 'package:chatty/features/stories/cubits/stories_cubit.dart';
import 'package:chatty/features/shared/widgets/app_toast.dart';
import 'package:palette_generator/palette_generator.dart';

@RoutePage()
class AddStoryScreen extends StatefulWidget {
  const AddStoryScreen({super.key});

  @override
  State<AddStoryScreen> createState() => _AddStoryScreenState();
}

class _AddStoryScreenState extends State<AddStoryScreen> {
  File? _pickedFile;
  bool _isVideo = false;
  String? _caption;

  bool get _hasMedia => _pickedFile != null;

  Future<void> _pickMedia() async {
    final file = await PickFile.image();
    if (file == null) return;
    final ext = file.path.split('.').last.toLowerCase();
    setState(() {
      _pickedFile = file;
      _isVideo = ['mp4', 'mov', 'avi', 'mkv'].contains(ext);
      _caption = null;
    });
  }

  void _clear() => setState(() {
    _pickedFile = null;
    _isVideo = false;
    _caption = null;
  });

  Future<void> _post() async {
    if (!_hasMedia) return;
    final uid = context.read<AuthCubit>().state.currentUser?.uid ?? '';
    final cubit = context.read<StoriesCubit>();
    if (_isVideo) {
      await cubit.addVideoStory(uid: uid, videoFile: _pickedFile!);
    } else {
      await cubit.addImageStory(
        uid: uid,
        imageFile: _pickedFile!,
        caption: _caption,
      );
    }
  }

  void _showCaptionSheet() {
    final controller = TextEditingController(text: _caption);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          top: 24,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              maxLines: 3,
              maxLength: 150,
              decoration: InputDecoration(
                hintText: context.locale.addCaption,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  setState(
                    () => _caption = controller.text.trim().isEmpty
                        ? null
                        : controller.text.trim(),
                  );
                  Navigator.pop(context);
                },
                child: AppText(context.locale.done),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StoriesCubit, StoriesState>(
      listenWhen: (prev, curr) => prev.uploadState != curr.uploadState,
      listener: (context, state) {
        if (state.uploadState.status == StateStatus.success) {
          context.read<StoriesCubit>().resetUploadState();
          context.router.maybePop();
        }
        if (state.uploadState.status == StateStatus.error) {
          context.read<StoriesCubit>().resetUploadState();
          AppToast.showError(
            message:
                state.uploadState.message ?? context.locale.unexpectedError,
            context: context,
          );
        }
      },
      child: BlocBuilder<StoriesCubit, StoriesState>(
        buildWhen: (prev, curr) =>
            prev.uploadState.status != curr.uploadState.status,
        builder: (context, state) {
          final isUploading =
              state.uploadState.status == StateStatus.loadingOverlay;

          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: _AddStoryAppBar(
                hasMedia: _hasMedia,
                isUploading: isUploading,
                onBack: () => context.router.maybePop(),
                onClear: _clear,
                onAddCaption: _hasMedia && !_isVideo ? _showCaptionSheet : null,
              ),
            ),
            body: Stack(
              children: [
                _hasMedia
                    ? StoryContentPreview(
                        isVideo: _isVideo,
                        pickedFile: _pickedFile!,
                        caption: _caption,
                      )
                    : const AddStoryEmptyState(),

                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 20,
                  child: _BottomControlBar(
                    hasMedia: _hasMedia,
                    isUploading: isUploading,
                    onPickMedia: _pickMedia,
                    onPost: _hasMedia ? _post : null,
                  ),
                ),

                if (isUploading)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── App Bar ──────────────────────────────────────────────────────────────────

class _AddStoryAppBar extends StatelessWidget {
  final bool hasMedia;
  final bool isUploading;
  final VoidCallback onBack;
  final VoidCallback onClear;
  final VoidCallback? onAddCaption;

  const _AddStoryAppBar({
    required this.hasMedia,
    required this.isUploading,
    required this.onBack,
    required this.onClear,
    this.onAddCaption,
  });

  Widget _btn(BuildContext context, IconData icon, VoidCallback? onTap) =>
      IconButton(
        onPressed: isUploading ? null : onTap,
        icon: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.colorScheme.outline.withValues(alpha: 0.2),
          ),
          padding: const AppPadding.set(all: 8),
          child: Icon(icon),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: _btn(context, SolarIconsOutline.altArrowLeft, onBack),
      title: AppText(context.locale.addStory),
      actions: [
        if (hasMedia) ...[
          if (onAddCaption != null)
            _btn(context, SolarIconsOutline.text, onAddCaption),
          _btn(context, SolarIconsOutline.trashBin2, onClear),
        ],
      ],
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class AddStoryEmptyState extends StatelessWidget {
  const AddStoryEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
            context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
            context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const AppPadding.set(all: 32),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    context.colorScheme.primary.withValues(alpha: 0.3),
                    context.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.3,
                    ),
                  ],
                ),
              ),
              child: Icon(
                Icons.auto_awesome,
                size: 80,
                color: context.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            AppText(
              context.locale.createYourStory,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            AppText(
              context.locale.shareMomentWithFriends,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const AppPadding.set(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: context.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
              child: AppText(
                context.locale.storyUploadHint,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Bottom Control Bar ───────────────────────────────────────────────────────

class _BottomControlBar extends StatelessWidget {
  final bool hasMedia;
  final bool isUploading;
  final VoidCallback onPickMedia;
  final VoidCallback? onPost;

  const _BottomControlBar({
    required this.hasMedia,
    required this.isUploading,
    required this.onPickMedia,
    this.onPost,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Row(
        children: [
          const SizedBox(width: 10),

          // ── Choose media ──
          Expanded(
            child: GestureDetector(
              onTap: isUploading ? null : onPickMedia,
              child: Container(
                padding: const AppPadding.set(all: 10),
                decoration: BoxDecoration(
                  borderRadius: AppBorderRadius.set(all: 24),
                  color: context.colorScheme.outline.withValues(alpha: 0.2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(SolarIconsOutline.galleryAdd, size: 20),
                    const SizedBox(height: 4),
                    AppText(
                      context.locale.chooseMedia,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // ── Post ──
          Expanded(
            child: GestureDetector(
              onTap: isUploading ? null : onPost,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const AppPadding.set(all: 10),
                decoration: BoxDecoration(
                  borderRadius: AppBorderRadius.set(all: 24),
                  gradient: hasMedia
                      ? LinearGradient(
                          colors: [
                            context.colorScheme.primary,
                            context.colorScheme.secondary,
                          ],
                        )
                      : null,
                  color: hasMedia
                      ? null
                      : context.colorScheme.outline.withValues(alpha: 0.2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    isUploading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            Icons.rocket_launch_rounded,
                            size: 20,
                            color: hasMedia
                                ? Colors.white
                                : context.colorScheme.onSurface,
                          ),
                    const SizedBox(height: 4),
                    AppText(
                      context.locale.post,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: hasMedia
                            ? Colors.white
                            : context.colorScheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),
        ],
      ),
    );
  }
}

// ─── Story Content Preview ────────────────────────────────────────────────────

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
        // ── Palette-derived gradient background ──
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_color1, _color2],
            ),
          ),
        ),

        // ── Media ──
        if (!widget.isVideo)
          Image.file(widget.pickedFile, fit: BoxFit.contain)
        else
          Center(
            child: Icon(
              Icons.videocam_rounded,
              size: 80,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),

        // ── Caption overlay ──
        if (widget.caption != null && widget.caption!.isNotEmpty)
          Positioned(
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
                widget.caption!,
                align: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
