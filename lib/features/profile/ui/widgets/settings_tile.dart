import 'package:Chatty/core/constants/exports.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback onTap;
  final Widget? trailing;
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.enabled = true,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: enabled
                  ? LinearGradient(
                      colors: [
                        context.colorScheme.primary,
                        context.colorScheme.secondary,
                      ],
                    )
                  : null,
              color: enabled
                  ? null
                  : context.colorScheme.surfaceContainerHighest,
            ),
            child: Icon(icon, size: 22, color: context.colorScheme.onPrimary),
          ),

          const SizedBox(width: 16),

          // TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  size: 16,
                  weight: FontWeight.w600,
                  color: context.colorScheme.onSurface,
                ),
                const SizedBox(height: 4),
                AppText(
                  subtitle,
                  size: 13,
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
          trailing ??
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: context.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.5,
                ),
              ),
        ],
      ),
    ).addAction(onTap: onTap);
  }
}
