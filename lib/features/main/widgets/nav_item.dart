import 'dart:math';

import '../../../../core/constants/exports.dart';

class NavItem extends StatelessWidget {
  final bool isActive;
  final bool isMiddleItem;
  final String icon;
  final String title;
  final Key? itemKey;
  final double iconSize;

  const NavItem({
    super.key,
    required this.isActive,
    required this.icon,
    required this.title,
    required this.isMiddleItem,
    this.itemKey,
    this.iconSize = 18.0,
  });

  @override
  Widget build(BuildContext context) {
    return isMiddleItem
        ? _buildMiddleItem(context)
        : _buildRegularItem(context);
  }

  Widget _buildMiddleItem(BuildContext context) {
    return Container(
      key: itemKey,
      width: 64,
      height: 64,
      margin: const EdgeInsets.all(6),
      decoration: _buildMiddleItemDecoration(context),
      child: Center(
        child: AppSvg(
          icon,
          color: context.colorScheme.onPrimary,
          height: 32,
          width: 32,
        ),
      ),
    ).addPadding(bottom: 15);
  }

  BoxDecoration _buildMiddleItemDecoration(BuildContext context) {
    return BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [context.colorScheme.primary, context.colorScheme.secondary],
      ),
      boxShadow: [
        BoxShadow(
          color: context.colorScheme.primary.withValues(alpha: 0.25),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildRegularItem(BuildContext context) {
    return Column(
      key: itemKey,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildIcon(context),
        const SizedBox(height: 6),
        _buildText(context),
      ],
    ).addPadding(top: 12);
  }

  Widget _buildIcon(BuildContext context) {
    final primary = context.colorScheme.primary;
    final secondary = context.colorScheme.secondary;

    if (!isActive) {
      return AppSvg(
        icon,
        color: AppColors.navigationUnselected,
        height: iconSize,
      );
    }

    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          colors: [primary, secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds);
      },
      child: AppSvg(icon, color: Colors.white, height: iconSize),
    );
  }

  Widget _buildText(BuildContext context) {
    final primary = context.colorScheme.primary;
    final secondary = context.colorScheme.secondary;

    if (!isActive) {
      return AppText(
        title,
        style: context.textTheme.bodyMedium?.copyWith(
          color: AppColors.navigationUnselected,
        ),
      );
    }

    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          colors: [primary, secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds);
      },
      child: AppText(
        title,
        style: context.textTheme.bodyMedium?.copyWith(color: Colors.white),
      ),
    );
  }
}

class HalfCircleClipper extends CustomPainter {
  final Color color;

  const HalfCircleClipper({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, -pi / 22, 1.08 * pi, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
