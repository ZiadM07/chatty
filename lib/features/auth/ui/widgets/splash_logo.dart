import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/features/shared/widgets/app_asset_image.dart';

class SplashLogo extends StatelessWidget {
  final Animation<double> logoScale;
  final Animation<double> logoOpacity;
  final Animation<Offset> logoSlide;
  final Animation<double> pulseScale;

  const SplashLogo({
    super.key,
    required this.logoScale,
    required this.logoOpacity,
    required this.logoSlide,
    required this.pulseScale,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        logoScale,
        logoOpacity,
        logoSlide,
        pulseScale,
      ]),
      builder: (context, _) {
        return FadeTransition(
          opacity: logoOpacity,
          child: SlideTransition(
            position: logoSlide,
            child: ScaleTransition(
              scale: logoScale,
              child: const AppAssetImage(
                Pngs.chatty,
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }
}
