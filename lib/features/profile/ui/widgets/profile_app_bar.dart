import 'package:chatty/core/constants/exports.dart';
import 'package:chatty/features/profile/cubits/profile_cubit.dart';
import 'package:chatty/features/profile/cubits/profile_state.dart';
import 'package:chatty/features/shared/widgets/app_asset_image.dart';
import 'package:chatty/features/shared/widgets/app_image.dart';

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
          /* ──────────────── BACKGROUND ──────────────── */
          AppAssetImage(
            Pngs.profileBackground,
            height: 350,
            width: double.infinity,
            fit: BoxFit.cover,
          ),

          /* ──────────────── USER INFO ROW ───────────── */
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

                return Row(
                  textDirection: isArabic
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  children: [
                    /* ────────── AVATAR ────────── */
                    _ProfileAvatar(
                      photoUrl: profile?.photoUrl,
                      isUploading:
                          state.updatePhotoState.status ==
                          StateStatus.loadingOverlay,
                    ),

                    const SizedBox(width: 16),

                    /* ────────── NAME + BIO ─────── */
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

// ─── Avatar with upload spinner ───────────────────────────────────────────────

class _ProfileAvatar extends StatelessWidget {
  final String? photoUrl;
  final bool isUploading;

  const _ProfileAvatar({required this.photoUrl, required this.isUploading});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AppImage(
          imageUrl: photoUrl ?? AppConstants.fakeUserImage,
          width: 56,
          height: 56,
          borderRadius: 100,
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
    );
  }
}
