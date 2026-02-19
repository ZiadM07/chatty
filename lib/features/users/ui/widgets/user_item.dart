import 'package:chatty/config/router/app_router.gr.dart';
import 'package:chatty/core/constants/exports.dart';
import 'package:chatty/features/auth/data/models/user_model.dart';
import 'package:chatty/features/shared/widgets/app_image.dart';

class UserItem extends StatelessWidget {
  final UserModel user;

  const UserItem({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const AppPadding.set(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          /* ─── AVATAR + ONLINE DOT ─── */
          Stack(
            children: [
              AppImage(
                imageUrl: user.photoUrl ?? AppConstants.fakeUserImage,
                width: 55,
                height: 55,
                borderRadius: 100,
              ),
              if (user.isOnline)
                Positioned(
                  bottom: 1,
                  right: 1,
                  child: Container(
                    width: 13,
                    height: 13,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: context.colorScheme.primaryContainer,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 16),

          /* ─── NAME + BIO ─── */
          Expanded(
            child: Column(
              spacing: 5,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText(
                  user.displayName,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                ),
                if (user.hasBio)
                  AppText(
                    user.bio!,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.textSecondary,
                    ),
                    maxLines: 1,
                  ),
              ],
            ),
          ),

          /* ─── ARROW ─── */
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 18,
            color: context.colorScheme.textSecondary,
          ),
        ],
      ),
    ).addAction(
      onTap: () => context.router.push(UserInfoRoute(uid: user.uid)),
      padding: const AppPadding.set(horizontal: 20),
    );
  }
}
