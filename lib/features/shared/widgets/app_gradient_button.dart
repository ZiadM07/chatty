import 'package:Chatty/core/constants/exports.dart';

enum AppButtonType { normal, gradient, error }

class AppButton extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double? borderRadius;
  final VoidCallback? onTap;
  final AppButtonType type;
  const AppButton({
    required this.text,
    this.style,
    this.borderRadius = 24,
    this.onTap,
    this.type = AppButtonType.gradient,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: type == AppButtonType.normal
            ? context.colorScheme.surfaceContainerHighest
            : null,
        gradient: type == AppButtonType.gradient
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  context.colorScheme.primary,
                  context.colorScheme.secondary,
                ],
              )
            : type == AppButtonType.error
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [context.colorScheme.error, context.colorScheme.error],
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
