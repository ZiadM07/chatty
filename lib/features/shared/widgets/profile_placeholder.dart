import 'package:Chatty/core/constants/exports.dart';

class ProfilePlaceholder extends StatelessWidget {
  final String name;
  final double size;
  final double borderWidth;
  final Color? borderColor;

  const ProfilePlaceholder({
    super.key,
    required this.name,
    required this.size,
    this.borderWidth = 0,
    this.borderColor,
  });

  String _initials() {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  List<Color> _gradientColors(BuildContext context) {
    if (name.isEmpty) {
      return [context.colorScheme.primary, context.colorScheme.secondary];
    }

    final hash = name.codeUnits.fold(
      0,
      (prev, c) => (prev * 31 + c) & 0xFFFFFFFF,
    );
    final hue = (hash % 360).toDouble();

    final base = HSLColor.fromAHSL(1.0, hue, 0.60, 0.48);
    final accent = HSLColor.fromAHSL(1.0, (hue + 30) % 360, 0.65, 0.55);

    return [base.toColor(), accent.toColor()];
  }

  @override
  Widget build(BuildContext context) {
    final initials = _initials();
    final colors = _gradientColors(context);
    final fontSize = size * (initials.length > 1 ? 0.32 : 0.38);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        border: borderWidth > 0
            ? Border.all(
                color: borderColor ?? context.colorScheme.surface,
                width: borderWidth,
              )
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: size * 0.08,
            left: size * 0.12,
            child: Container(
              width: size * 0.45,
              height: size * 0.22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.28),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          AppText(
            initials,
            size: fontSize,
            weight: FontWeight.w700,
            color: context.colorScheme.onPrimary,
            height: 1.0,
          ),
        ],
      ),
    );
  }
}
