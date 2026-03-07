import 'package:Chatty/config/router/app_router.gr.dart';
import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/features/auth/data/models/user_model.dart';
import 'package:Chatty/features/shared/widgets/app_image.dart';

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
          Stack(
            children: [
              AppImage(
                imageUrl: user.photoUrl ?? AppConstants.fakeUserImage,
                width: 55,
                height: 55,
                borderRadius: 100,
              ),
              Positioned(
                right: 2,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: (user.isOnline)
                        ? context.colorScheme.success
                        : context.colorScheme.onSurfaceDisabled,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.colorScheme.surfaceContainerHigh,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 16),

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

          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 18,
            color: context.colorScheme.textSecondary,
          ),
        ],
      ),
    ).addAction(
      onTap: () => context.router.push(ChatInfoRoute(uid: user.uid)),
      padding: const AppPadding.set(horizontal: 20),
    );
  }
}
