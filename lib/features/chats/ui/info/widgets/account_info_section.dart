import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/features/auth/data/models/user_model.dart';
import 'package:Chatty/features/shared/widgets/app_image.dart';
import 'package:intl/intl.dart';

import '../../../../shared/widgets/profile_placeholder.dart';

class AccountInfoSection extends StatelessWidget {
  final UserModel user;
  const AccountInfoSection({super.key, required this.user});

  void _showProfileImage(BuildContext context) {
    if (user.photoUrl == null) return;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withValues(alpha: 0.92),
      transitionDuration: const Duration(milliseconds: 220),
      transitionBuilder: (context, animation, _, child) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween(
            begin: 0.92,
            end: 1.0,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        ),
      ),
      pageBuilder: (context, _, u) =>
          _ProfileImageViewer(photoUrl: user.photoUrl!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.colorScheme.surfaceContainerHighest,
          ),
          child: user.photoUrl != null
              ? AppImage(
                  imageUrl: user.photoUrl!,
                  width: 100,
                  height: 100,
                  borderRadius: 50,
                )
              : ProfilePlaceholder(name: user.displayName, size: 100),
        ).addAction(onTap: () => _showProfileImage(context)),

        const SizedBox(height: 20),
        AppText(user.displayName, style: context.textTheme.headlineSmall),

        const SizedBox(height: 10),

        AppText(user.email, style: context.textTheme.bodyMedium),

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
                Icon(Icons.format_quote, color: context.colorScheme.onSurface),
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

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              SolarIconsOutline.calendarMinimalistic,
              size: 14,
              color: context.colorScheme.onSurface,
            ),
            const SizedBox(width: 8),
            AppText(
              '${context.locale.joined} ${DateFormat('MMMM yyyy').format(user.createdAt)}',
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

class _ProfileImageViewer extends StatelessWidget {
  final String photoUrl;
  const _ProfileImageViewer({required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Center(
            child: AppImage(
              imageUrl: photoUrl,
              width: context.width,
              height: context.width,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 12,
            left: 5,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: AppBorderRadius.set(all: 12),
              ),
              child: Icon(
                SolarIconsOutline.altArrowLeft,
                color: Colors.white,
                size: 25,
              ),
            ).addAction(onBounce: () => context.router.maybePop()),
          ),
        ],
      ),
    );
  }
}
