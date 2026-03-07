import 'package:Chatty/core/constants/exports.dart';

class SplashBackgroundParticles extends StatelessWidget {
  final AnimationController controller;

  const SplashBackgroundParticles({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, i) {
        return CustomPaint(
          painter: _ParticlePainter(
            controller.value,
            primaryColor: context.colorScheme.primary,
            secondaryColor: context.colorScheme.secondary,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final Color secondaryColor;

  _ParticlePainter(
    this.progress, {
    required this.primaryColor,
    required this.secondaryColor,
  });

  static final List<_Particle> _particles = List.generate(
    22,
    (i) => _Particle(
      x: (i * 0.137 + 0.05) % 1.0,
      y: (i * 0.193 + 0.08) % 1.0,
      radius: 1.0 + (i % 3) * 0.6,
      speed: 0.15 + (i % 4) * 0.05,
      offset: i * 0.3,
    ),
  );

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in _particles) {
      final t = (progress + p.offset) % 1.0;
      final opacity = (0.5 - (t - 0.5).abs()) * 0.7;
      final yPos = (p.y + t * p.speed) % 1.0;

      paint.color = (p.radius > 1.4 ? primaryColor : secondaryColor).withValues(
        alpha: opacity.clamp(0.0, 1.0),
      );

      canvas.drawCircle(
        Offset(p.x * size.width, yPos * size.height),
        p.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}

class _Particle {
  final double x, y, radius, speed, offset;
  const _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.offset,
  });
}
