import 'package:Chatty/core/constants/exports.dart';

class AddStoryAppBar extends StatelessWidget {
  final bool hasMedia;
  final bool isUploading;
  final VoidCallback onBack;
  final VoidCallback onClear;
  final VoidCallback? onAddCaption;

  const AddStoryAppBar({
    super.key,
    required this.hasMedia,
    required this.isUploading,
    required this.onBack,
    required this.onClear,
    this.onAddCaption,
  });

  Widget _iconBtn(BuildContext context, IconData icon, VoidCallback? onTap) {
    return IconButton(
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
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: _iconBtn(context, SolarIconsOutline.altArrowLeft, onBack),
      title: AppText(context.locale.addStory),
      actions: [
        if (hasMedia) ...[
          if (onAddCaption != null)
            _iconBtn(context, SolarIconsOutline.text, onAddCaption),
          _iconBtn(context, SolarIconsOutline.trashBin2, onClear),
        ],
      ],
    );
  }
}
