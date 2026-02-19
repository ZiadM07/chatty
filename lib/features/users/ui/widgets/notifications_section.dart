import 'package:chatty/core/constants/exports.dart';

class NotificationsSection extends StatelessWidget {
  const NotificationsSection({super.key});

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
            SolarIconsBold.bell,
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
              context.locale.silenceAlerts,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        const Spacer(),
        Switch(value: true, onChanged: (value) {}),
      ],
    ).addPadding(horizontal: 20, vertical: 5);
  }
}
