import 'package:Chatty/core/constants/exports.dart';

class SplashTagline extends StatelessWidget {
  final Animation<double> textOpacity;
  final Animation<Offset> textSlide;

  const SplashTagline({
    super.key,
    required this.textOpacity,
    required this.textSlide,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([textOpacity, textSlide]),
      builder: (_, i) {
        return FadeTransition(
          opacity: textOpacity,
          child: SlideTransition(
            position: textSlide,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Text(
                  'Connect. Chat. Belong.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: context.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.6,
                    ),
                    letterSpacing: 2.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
