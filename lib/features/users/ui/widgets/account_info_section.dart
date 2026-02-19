import 'package:chatty/core/constants/exports.dart';
import 'package:chatty/features/auth/data/models/user_model.dart';
import 'package:chatty/features/shared/widgets/app_image.dart';
import 'package:intl/intl.dart';

class AccountInfoSection extends StatelessWidget {
  final UserModel user;
  const AccountInfoSection({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /* ─── Avatar ─── */
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.colorScheme.surfaceContainerHighest,
          ),
          child: AppImage(
            imageUrl: user.photoUrl ?? AppConstants.fakeUserImage,
            width: 100,
            height: 100,
            borderRadius: 50,
          ),
        ),

        const SizedBox(height: 20),

        /* ─── Name ─── */
        AppText(user.displayName, style: context.textTheme.headlineSmall),

        const SizedBox(height: 10),

        /* ─── Email ─── */
        AppText(user.email, style: context.textTheme.bodyMedium),

        /* ─── Bio ─── */
        if (user.hasBio) ...[
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: context.colorScheme.surfaceContainerHigh,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.format_quote,
                  color: context.colorScheme.onSurface,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppText(
                    user.bio!,
                    style: context.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 20),

        /* ─── Joined date ─── */
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: context.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                SolarIconsOutline.calendarMinimalistic,
                size: 14,
                color: context.colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 8),
            AppText(
              'Joined ${DateFormat('MMMM yyyy').format(user.createdAt)}',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}