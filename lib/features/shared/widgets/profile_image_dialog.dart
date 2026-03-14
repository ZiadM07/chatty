import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/features/shared/widgets/app_image.dart';
import 'package:Chatty/features/shared/widgets/profile_placeholder.dart';

class ProfileImageDialog extends StatefulWidget {
  final String? imageUrl;
  final String name;
  final String heroTag;

  const ProfileImageDialog._({
    required this.imageUrl,
    required this.name,
    required this.heroTag,
  });

  static Future<void> show({
    required BuildContext context,
    required String? imageUrl,
    required String name,
    required String heroTag,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.transparent,
        transitionDuration: const Duration(milliseconds: 380),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, i, y) => ProfileImageDialog._(
          imageUrl: imageUrl,
          name: name,
          heroTag: heroTag,
        ),
        transitionsBuilder: (context, animation, _, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
              reverseCurve: Curves.easeIn,
            ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  State<ProfileImageDialog> createState() => _ProfileImageDialogState();
}

class _ProfileImageDialogState extends State<ProfileImageDialog>
    with SingleTickerProviderStateMixin {
  late final TransformationController _transformController;
  late final AnimationController _resetController;
  Animation<Matrix4>? _resetAnimation;
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _transformController = TransformationController();
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _transformController.addListener(() {
      final zoomed = _transformController.value != Matrix4.identity();
      if (zoomed != _isZoomed) setState(() => _isZoomed = zoomed);
    });
  }

  @override
  void dispose() {
    _transformController.dispose();
    _resetController.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _resetAnimation =
        Matrix4Tween(
          begin: _transformController.value,
          end: Matrix4.identity(),
        ).animate(
          CurvedAnimation(parent: _resetController, curve: Curves.easeOutCubic),
        );
    _resetController.forward(from: 0);
    _resetAnimation!.addListener(() {
      _transformController.value = _resetAnimation!.value;
    });
  }

  void _close() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    final hasImage = widget.imageUrl != null && widget.imageUrl!.isNotEmpty;
    final imageSize = MediaQuery.of(context).size.width * 0.78;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: _isZoomed ? _resetZoom : _close,
        child: Container(
          color: Colors.black.withValues(alpha: 0.85),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Row(
                    children: [
                      _CircleButton(icon: Icons.close, onTap: _close),
                      const Spacer(),
                      AnimatedOpacity(
                        opacity: _isZoomed ? 1 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: _CircleButton(
                          icon: Icons.zoom_out_rounded,
                          onTap: _resetZoom,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              width: imageSize + 20,
                              height: imageSize + 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: context.colorScheme.outline
                                        .withValues(alpha: 0.2),
                                    blurRadius: 40,
                                    spreadRadius: 8,
                                  ),
                                ],
                              ),
                            ),

                            Hero(
                              tag: widget.heroTag,
                              flightShuttleBuilder: _circularShuttle,
                              child: GestureDetector(
                                onTap: () {},
                                child: ClipOval(
                                  child: SizedBox(
                                    width: imageSize,
                                    height: imageSize,
                                    child: InteractiveViewer(
                                      transformationController:
                                          _transformController,
                                      minScale: 1.0,
                                      maxScale: 4.0,
                                      child: hasImage
                                          ? AppImage(
                                              imageUrl: widget.imageUrl!,
                                              width: imageSize,
                                              height: imageSize,
                                              fit: BoxFit.cover,
                                            )
                                          : ProfilePlaceholder(
                                              name: widget.name,
                                              size: imageSize,
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        AppText(
                          widget.name,
                          style: context.textTheme.titleMedium?.copyWith(
                            color: context.colorScheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: AnimatedOpacity(
                    opacity: _isZoomed ? 0 : 1,
                    duration: const Duration(milliseconds: 200),
                    child: AppText(
                      context.locale.pinchToZoomTapToClose,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _circularShuttle(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection direction,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return ClipOval(child: child);
      },
      child: direction == HeroFlightDirection.push
          ? toHeroContext.widget
          : fromHeroContext.widget,
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
