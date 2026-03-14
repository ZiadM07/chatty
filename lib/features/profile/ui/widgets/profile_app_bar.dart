import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/features/profile/cubits/profile_cubit.dart';
import 'package:Chatty/features/profile/cubits/profile_state.dart';
import 'package:Chatty/features/shared/widgets/app_asset_image.dart';
import 'package:Chatty/features/shared/widgets/app_image.dart';
import 'package:Chatty/features/shared/widgets/profile_image_dialog.dart';

import '../../../shared/widgets/profile_placeholder.dart';

class ProfileAppBar extends StatelessWidget {
  const ProfileAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = Directionality.of(context) == TextDirection.rtl;

    return SliverAppBar(
      centerTitle: false,
      title: AppText(
        context.locale.profile,
        style: context.textTheme.headlineSmall?.copyWith(
          color: context.colorScheme.onPrimary,
        ),
      ).addPadding(left: 5, top: 10),
      expandedHeight: 305,
      flexibleSpace: Stack(
        children: [
          AppAssetImage(
            Pngs.profileBackground,
            height: 350,
            width: double.infinity,
            fit: BoxFit.cover,
          ),

          Positioned(
            top: 130,
            left: isArabic ? null : 24,
            right: isArabic ? 24 : null,
            child: BlocBuilder<ProfileCubit, ProfileState>(
              buildWhen: (prev, curr) =>
                  prev.profile != curr.profile ||
                  prev.updatePhotoState != curr.updatePhotoState,
              builder: (context, state) {
                final profile = state.profile;
                final photoUrl = profile?.photoUrl ?? '';
                final name = profile?.fullName ?? profile?.username ?? '';
                final heroTag = 'profile_avatar_${profile?.uid ?? 'me'}';

                return Row(
                  textDirection: isArabic
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  children: [
                    _ProfileAvatar(
                      photoUrl: photoUrl,
                      heroTag: heroTag,
                      name: name,
                      isUploading:
                          state.updatePhotoState.status ==
                          StateStatus.loadingOverlay,
                      onLongPress: () => ProfileImageDialog.show(
                        context: context,
                        imageUrl: photoUrl,
                        name: name,
                        heroTag: heroTag,
                      ),
                    ),

                    const SizedBox(width: 16),

                    if (profile != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: context.colorScheme.surface.withValues(
                            alpha: .1,
                          ),
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: Column(
                          crossAxisAlignment: isArabic
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            AppText(
                              profile.fullName.isNotEmpty
                                  ? profile.fullName
                                  : profile.username,
                              style: context.textTheme.titleSmall?.copyWith(
                                color: context.colorScheme.onPrimary,
                              ),
                              align: isArabic ? TextAlign.end : TextAlign.start,
                            ),
                            if (profile.hasBio)
                              AppText(
                                profile.bio!,
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: context.colorScheme.onPrimary,
                                ),
                                align: isArabic
                                    ? TextAlign.end
                                    : TextAlign.start,
                              ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String? photoUrl;
  final bool isUploading;
  final String heroTag;
  final VoidCallback onLongPress;
  final String name;

  const _ProfileAvatar({
    required this.photoUrl,
    required this.isUploading,
    required this.heroTag,
    required this.onLongPress,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Hero(
            tag: heroTag,
            child: photoUrl != null
                ? ProfilePlaceholder(name: name, size: 56)
                : AppImage(
                    imageUrl: photoUrl!,
                    width: 56,
                    height: 56,
                    borderRadius: 100,
                  ),
          ),

          if (isUploading) ...[
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
