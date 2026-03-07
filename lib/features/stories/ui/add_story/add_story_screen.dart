import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/core/framework/pick_file.dart';
import 'package:Chatty/features/auth/cubits/auth_cubit.dart';
import 'package:Chatty/features/stories/cubits/stories_cubit.dart';
import 'package:Chatty/features/shared/widgets/app_toast.dart';
import 'widgets/add_story_app_bar.dart';
import 'widgets/add_story_bottom_control_bar.dart';
import 'widgets/add_story_caption_sheet.dart';
import 'widgets/add_story_empty_state.dart';
import 'widgets/story_content_preview.dart';

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

  void _clearMedia() => setState(() {
    _pickedFile = null;
    _isVideo = false;
    _caption = null;
  });

  void _showCaptionSheet() {
    AddStoryCaptionSheet.show(
      context,
      initialCaption: _caption,
      onSave: (text) => setState(() => _caption = text),
    );
  }

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

  void _onUploadStateChanged(BuildContext context, StoriesState state) {
    if (state.uploadState.status == StateStatus.success) {
      context.read<StoriesCubit>().resetUploadState();
      context.router.maybePop();
    }
    if (state.uploadState.status == StateStatus.error) {
      context.read<StoriesCubit>().resetUploadState();
      AppToast.showError(
        message: context.locale.thisOperationFailed,
        context: context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StoriesCubit, StoriesState>(
      listenWhen: (prev, curr) => prev.uploadState != curr.uploadState,
      listener: _onUploadStateChanged,
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
              child: AddStoryAppBar(
                hasMedia: _hasMedia,
                isUploading: isUploading,
                onBack: () => context.router.maybePop(),
                onClear: _clearMedia,
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
                  child: AddStoryBottomControlBar(
                    hasMedia: _hasMedia,
                    isUploading: isUploading,
                    onPickMedia: _pickMedia,
                    onPost: _hasMedia ? _post : null,
                  ),
                ),

                if (isUploading) const _UploadingOverlay(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _UploadingOverlay extends StatelessWidget {
  const _UploadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
