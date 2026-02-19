import 'package:chatty/core/constants/exports.dart';

enum AppGradientButtonType { normal, gradient }

class AppButton extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double? borderRadius;
  final VoidCallback? onTap;
  final AppGradientButtonType type;
  const AppButton({
    required this.text,
    this.style,
    this.borderRadius = 24,
    this.onTap,
    this.type = AppGradientButtonType.gradient,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: type == AppGradientButtonType.normal
            ? context.colorScheme.surfaceContainerHighest
            : null,
        gradient: type == AppGradientButtonType.gradient
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  context.colorScheme.primary,
                  context.colorScheme.secondary,
                ],
              )
            : null,

        borderRadius: BorderRadius.circular(borderRadius!),
      ),
      child: Center(
        child: AppText(
          text,
          style:
              style ??
              context.textTheme.titleMedium?.copyWith(
                color: context.colorScheme.onPrimary,
              ),
        ),
      ),
    ).addAction(onTap: onTap);
  }
}
