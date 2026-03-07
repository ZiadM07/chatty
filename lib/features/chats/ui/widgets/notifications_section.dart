import 'package:Chatty/core/constants/exports.dart';

class NotificationsSection extends StatelessWidget {
  final bool isMuted;
  final VoidCallback onToggleMute;

  const NotificationsSection({
    super.key,
    required this.isMuted,
    required this.onToggleMute,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.colorScheme.primary,
                context.colorScheme.secondary,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isMuted ? SolarIconsOutline.bellOff : SolarIconsBold.bell,
            size: 25,
            color: context.colorScheme.onPrimary,
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              context.locale.muteNotifications,
              style: context.textTheme.titleSmall?.copyWith(
                color: context.colorScheme.textPrimary,
              ),
            ),
            AppText(
              isMuted
                  ? context.locale.notificationsMuted
                  : context.locale.silenceAlerts,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        const Spacer(),
        Switch(value: isMuted, onChanged: (_) => onToggleMute()),
      ],
    ).addPadding(horizontal: 20, vertical: 5);
  }
}
