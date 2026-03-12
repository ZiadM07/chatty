import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/features/auth/cubits/auth_cubit.dart';
import 'package:Chatty/features/profile/cubits/profile_cubit.dart';
import 'package:Chatty/features/profile/cubits/profile_state.dart';
import 'package:Chatty/features/profile/ui/widgets/profile_settings_avatar.dart';
import 'package:Chatty/features/profile/ui/widgets/settings_tile.dart';
import 'package:Chatty/features/shared/widgets/app_gradient_button.dart';
import 'package:Chatty/features/shared/widgets/app_text_form_field.dart';
import 'package:Chatty/features/shared/widgets/app_toast.dart';

@RoutePage()
class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      buildWhen: (prev, curr) => prev.profile != curr.profile,
      listenWhen: (prev, curr) => prev.updateInfoState != curr.updateInfoState,
      listener: (context, state) {
        if (state.updateInfoState.status == StateStatus.success) {
          context.read<ProfileCubit>().resetUpdateInfoState();
          AppToast.showSuccess(
            message: context.locale.updatedSuccessfully,
            context: context,
          );
        }
        if (state.updateInfoState.status == StateStatus.error) {
          context.read<ProfileCubit>().resetUpdateInfoState();
          AppToast.showError(
            message: context.locale.unexpectedError,
            context: context,
          );
        }
      },
      builder: (context, state) {
        final profile = state.profile;
        final uid = context.read<AuthCubit>().state.currentUser?.uid ?? '';

        return AppScaffold(
          showBackButton: true,
          title: context.locale.profileSettings,
          body: CustomScrollView(
            slivers: [
              const ProfileSettingsAvatar(),

              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),

                    AppText(
                      context.locale.accountInformation,
                      style: context.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),

                    SettingsTile(
                      icon: SolarIconsOutline.user,
                      title: context.locale.nameLabel,
                      subtitle: profile?.fullName ?? '—',
                      enabled: true,
                      onTap: () => _showEditSheet(
                        context: context,
                        title: context.locale.nameLabel,
                        initialValue: profile?.fullName ?? '',
                        onSave: (value) => context
                            .read<ProfileCubit>()
                            .updateFullName(uid: uid, fullName: value),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 18,
                        color: context.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    SettingsTile(
                      icon: SolarIconsOutline.infoCircle,
                      title: context.locale.bioLabel,
                      subtitle: profile?.bio ?? '—',
                      enabled: true,
                      onTap: () => _showEditSheet(
                        context: context,
                        title: context.locale.bioLabel,
                        initialValue: profile?.bio ?? '',
                        onSave: (value) => context
                            .read<ProfileCubit>()
                            .updateBio(uid: uid, bio: value),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 18,
                        color: context.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    AppText(
                      context.locale.userDetails,
                      style: context.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),

                    SettingsTile(
                      icon: SolarIconsOutline.mailbox,
                      title: context.locale.emailLabel,
                      subtitle: profile?.email ?? '—',
                      enabled: false,
                      onTap: () {
                        AppToast.showError(
                          message: context.locale.emailCannotBeChanged,
                          context: context,
                        );
                      },
                      trailing: Icon(
                        SolarIconsOutline.lockKeyhole,
                        size: 20,
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 15),

                    SettingsTile(
                      icon: Icons.alternate_email,
                      title: context.locale.usernameLabel,
                      subtitle: profile?.username ?? '—',
                      enabled: false,
                      onTap: () {
                        AppToast.showError(
                          message: context.locale.usernameCannotBeChanged,
                          context: context,
                        );
                      },
                      trailing: Icon(
                        SolarIconsOutline.lockKeyhole,
                        size: 20,
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ).addPadding(horizontal: 20),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Inline Edit Sheet ────────────────────────────────────────────────────────

void _showEditSheet({
  required BuildContext context,
  required String title,
  required String initialValue,
  required void Function(String value) onSave,
}) {
  final profileCubit = context.read<ProfileCubit>();

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    // Pushes the sheet up when the keyboard appears
    isScrollControlled: true,
    builder: (ctx) => BlocProvider.value(
      value: profileCubit,
      child: _EditSheet(
        title: title,
        initialValue: initialValue,
        onSave: onSave,
      ),
    ),
  );
}

class _EditSheet extends StatefulWidget {
  final String title;
  final String initialValue;
  final void Function(String value) onSave;

  const _EditSheet({
    required this.title,
    required this.initialValue,
    required this.onSave,
  });

  @override
  State<_EditSheet> createState() => _EditSheetState();
}

class _EditSheetState extends State<_EditSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();
    if (value.isEmpty || value == widget.initialValue) {
      context.router.pop();
      return;
    }
    context.router.pop();
    widget.onSave(value);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileCubit, ProfileState>(
      listenWhen: (prev, curr) => prev.updateInfoState != curr.updateInfoState,
      listener: (context, state) {
        // Close sheet on success or error — screen's listener handles snackbar
        if (state.updateInfoState.status == StateStatus.success ||
            state.updateInfoState.status == StateStatus.error) {
          context.router.pop();
        }
      },
      child: Padding(
        // Shift sheet above keyboard
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /* ──────────── TITLE ──────────── */
              AppText(widget.title, style: context.textTheme.titleMedium),

              const SizedBox(height: 16),

              /* ──────────── FIELD ──────────── */
              AppTextFormField(
                controller: _controller,
                hintText: widget.title,
                borderRadius: 12,
                borderWidth: 1,
                borderColor: context.colorScheme.outline.withValues(alpha: 0.4),
                onFieldSubmitted: (_) => _submit(),
              ),

              const SizedBox(height: 20),

              /* ──────────── ACTIONS ────────── */
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: context.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Center(
                        child: AppText(
                          context.locale.cancel,
                          style: context.textTheme.bodyMedium,
                        ),
                      ),
                    ).addAction(onTap: () => context.router.pop()),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(text: context.locale.save, onTap: _submit),
                  ),
                ],
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
