import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/core/di/injectable.dart';
import 'package:Chatty/core/framework/pick_file.dart';
import 'package:Chatty/features/shared/cubits/app_cubit.dart';
import 'package:Chatty/features/shared/widgets/app_asset_image.dart';
import 'package:Chatty/features/shared/widgets/app_file_image.dart';

@RoutePage()
class ChatWallpaperScreen extends StatefulWidget {
  const ChatWallpaperScreen({super.key});

  @override
  State<ChatWallpaperScreen> createState() => _ChatWallpaperScreenState();
}

class _ChatWallpaperScreenState extends State<ChatWallpaperScreen> {
  late String _selectedPath;
  late double _brightness;
  File? _userPickedImage;

  final _presets = [
    Pngs.defaultChatWallpaper,
    Pngs.chatWallpaper1,
    Pngs.chatWallpaper2,
  ];

  @override
  void initState() {
    super.initState();
    final prefs = getIt<AppPreferences>();
    _selectedPath = prefs.chatWallpaperPath;
    _brightness = prefs.chatWallpaperBrightness;

    // If a custom path is saved, check if it's a file that still exists
    if (_selectedPath.isNotEmpty && !_presets.contains(_selectedPath)) {
      final file = File(_selectedPath);
      if (file.existsSync()) {
        _userPickedImage = file;
      } else {
        // File was deleted — reset to default
        _selectedPath = _presets[0];
      }
    }

    // Default to first preset if empty
    if (_selectedPath.isEmpty) {
      _selectedPath = _presets[0];
    }
  }

  Future<void> _pickUserPhoto() async {
    final file = await PickFile.image();
    if (file == null) return;
    setState(() {
      _userPickedImage = file;
      _selectedPath = file.path;
    });
    _save();
  }

  void _selectPreset(String path) {
    setState(() {
      _selectedPath = path;
      _userPickedImage = null; // Clear custom image when choosing preset
    });
    _save();
  }

  void _save() {
    final prefs = getIt<AppPreferences>();
    prefs.chatWallpaperPath = _selectedPath;
    prefs.chatWallpaperBrightness = _brightness;
    // Trigger AppCubit rebuild so ChatBackGround picks up the change
    context.read<AppCubit>().refreshAuth();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: context.locale.chatWallpaperTitle,
      showBackButton: true,
      body: Column(
        children: [
          const SizedBox(height: 20),

          // Title
          AppText(
            context.locale.chooseWallpaper,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),

          // Grid
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.75,
              children: [
                // Preset 1
                _WallpaperOption(
                  title: context.locale.wallpaperClassic,
                  isSelected: _selectedPath == _presets[0],
                  onTap: () => _selectPreset(_presets[0]),
                  child: AppAssetImage(
                    _presets[0],
                    fit: BoxFit.cover,
                    width: 150,
                  ),
                ),

                // Preset 2
                _WallpaperOption(
                  title: context.locale.wallpaperAbstractBlue,
                  isSelected: _selectedPath == _presets[1],
                  onTap: () => _selectPreset(_presets[1]),
                  child: AppAssetImage(
                    _presets[1],
                    fit: BoxFit.cover,
                    width: 150,
                  ),
                ),

                // Preset 3
                _WallpaperOption(
                  title: context.locale.wallpaperGreenTexture,
                  isSelected: _selectedPath == _presets[2],
                  onTap: () => _selectPreset(_presets[2]),
                  child: AppAssetImage(
                    _presets[2],
                    fit: BoxFit.cover,
                    width: 150,
                  ),
                ),

                // Custom photo
                _WallpaperOption(
                  title: context.locale.wallpaperYourPhoto,
                  isSelected:
                      _userPickedImage != null &&
                      _selectedPath == _userPickedImage!.path,
                  onTap: _pickUserPhoto,
                  child: _userPickedImage == null
                      ? Container(
                          width: 150,
                          decoration: BoxDecoration(
                            color: context.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 40,
                                color: context.colorScheme.primary,
                              ),
                              const SizedBox(height: 8),
                              AppText(
                                'Tap to select',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: context.colorScheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : AppFileImage(
                          _userPickedImage!,
                          fit: BoxFit.cover,
                          borderRadius: 16,
                          width: 150,
                        ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Brightness slider
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.brightness_6_rounded,
                      size: 20,
                      color: context.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    AppText(
                      'Dim wallpaper',
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    AppText(
                      '${(_brightness * 100).toInt()}%',
                      style: TextStyle(
                        color: context.colorScheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 8,
                    ),
                  ),
                  child: Slider(
                    value: _brightness,
                    min: 0.0,
                    max: 1.0,
                    divisions: 20,
                    activeColor: context.colorScheme.primary,
                    onChanged: (v) => setState(() => _brightness = v),
                    onChangeEnd: (_) => _save(),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Adjust overlay darkness to improve text readability',
                  style: TextStyle(
                    fontSize: 11,
                    color: context.colorScheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ).addPadding(horizontal: 20),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Wallpaper option tile
// ─────────────────────────────────────────────────────────────────────────────

class _WallpaperOption extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget child;

  const _WallpaperOption({
    required this.title,
    required this.isSelected,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? context.colorScheme.primary
                      : context.colorScheme.outline.withValues(alpha: 0.2),
                  width: isSelected ? 3 : 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: context.colorScheme.primary.withValues(
                            alpha: 0.3,
                          ),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: child,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        AppText(
          title,
          size: 12,
          color: isSelected
              ? context.colorScheme.primary
              : context.colorScheme.onSurfaceVariant,
          weight: isSelected ? FontWeight.w700 : FontWeight.w500,
          align: TextAlign.center,
        ),
      ],
    );
  }
}
