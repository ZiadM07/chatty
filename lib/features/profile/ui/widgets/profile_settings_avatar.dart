import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/core/framework/pick_file.dart';
import 'package:Chatty/features/auth/cubits/auth_cubit.dart';
import 'package:Chatty/features/profile/cubits/profile_cubit.dart';
import 'package:Chatty/features/profile/cubits/profile_state.dart';
import 'package:Chatty/features/shared/widgets/app_image.dart';

class ProfileSettingsAvatar extends StatelessWidget {
  const ProfileSettingsAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      buildWhen: (prev, curr) =>
          prev.profile?.photoUrl != curr.profile?.photoUrl ||
          prev.updatePhotoState != curr.updatePhotoState,
      builder: (context, state) {
        final isUploading =
            state.updatePhotoState.status == StateStatus.loadingOverlay;

        return SliverToBoxAdapter(
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AppImage(
                      imageUrl:
                          state.profile?.photoUrl ?? AppConstants.fakeUserImage,
                      width: 120,
                      height: 120,
                      borderRadius: 100,
                    ),

                    if (isUploading) ...[
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              Positioned(
                bottom: 0,
                right: 145,
                child: Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        context.colorScheme.primary,
                        context.colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: IconButton(
                    onPressed: isUploading
                        ? null
                        : () => _showProfilePhotoOptions(context),
                    icon: Icon(
                      SolarIconsOutline.cameraAdd,
                      size: 20,
                      color: context.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

void _showProfilePhotoOptions(BuildContext context) {
  final profileCubit = context.read<ProfileCubit>();
  final uid = context.read<AuthCubit>().state.currentUser?.uid ?? '';

  showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          context.locale.profilePhoto,
          style: context.textTheme.titleMedium,
        ),
        content: Text(
          context.locale.profilePhotoAction,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurface,
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
            },
            child: Text(
              context.locale.cancel,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.primary,
              ),
            ),
          ),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colorScheme.primary,
              foregroundColor: context.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await _pickAndUpload(
                context: context,
                profileCubit: profileCubit,
                uid: uid,
              );
            },
            icon: const Icon(Icons.camera_alt_rounded),
            label: Text(
              context.locale.change,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      );
    },
  );
}

Future<void> _pickAndUpload({
  required BuildContext context,
  required ProfileCubit profileCubit,
  required String uid,
}) async {
  final file = await PickFile.image();
  if (file == null) return;

  profileCubit.updateProfilePhoto(uid: uid, imageFile: file);
}
