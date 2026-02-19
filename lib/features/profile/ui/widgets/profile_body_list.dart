import 'package:chatty/config/router/app_router.gr.dart';
import 'package:chatty/core/constants/exports.dart';
import 'package:chatty/features/auth/cubits/auth_cubit.dart';
import 'package:chatty/features/auth/cubits/auth_state.dart';
import 'package:chatty/features/shared/widgets/app_gradient_button.dart';
import 'package:chatty/features/shared/widgets/app_toast.dart';

class ProfileBodyList extends StatelessWidget {
  const ProfileBodyList({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        spacing: 10,
        children: [
          _ProfileTile(
            icon: Icon(
              SolarIconsOutline.user,
              color: context.colorScheme.textPrimary,
            ),
            title: context.locale.profile,
            subtitle: context.locale.editProfile,
            onTap: () => context.router.push(const ProfileSettingsRoute()),
          ),
          _ProfileTile(
            icon: Icon(
              SolarIconsOutline.chatRoundLine,
              color: context.colorScheme.textPrimary,
            ),
            title: context.locale.chats,
            subtitle: context.locale.chatsSubtitle,
            onTap: () => context.router.push(const ChatsSettingsRoute()),
          ),
          _ProfileTile(
            icon: Icon(
              SolarIconsOutline.globus,
              color: context.colorScheme.textPrimary,
            ),
            title: context.locale.language,
            subtitle: context.locale.languageSubtitle,
            onTap: () => context.router.push(const LanguageSettingsRoute()),
          ),
          _ProfileTile(
            icon: Icon(
              SolarIconsOutline.bell,
              color: context.colorScheme.textPrimary,
            ),
            title: context.locale.notification,
            subtitle: context.locale.notificationSubtitle,
            onTap: () => context.router.push(const NotificationSettingsRoute()),
          ),
          _ProfileTile(
            icon: Icon(
              SolarIconsOutline.logout_2,
              color: context.colorScheme.textPrimary,
            ),
            title: context.locale.logout,
            subtitle: context.locale.logoutDescription,
            onTap: () => _confirmLogout(context),
          ),
        ],
      ),
    );
  }
}

// ─── Logout Bottom Sheet ──────────────────────────────────────────────────────

void _confirmLogout(BuildContext context) {
  // Capture cubit before entering the sheet — the sheet's context
  // may not have BlocProvider above it since showModalBottomSheet
  // creates a new route detached from the widget tree.
  final authCubit = context.read<AuthCubit>();

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) {
      // Re-provide the cubit into the sheet's isolated route context
      return BlocProvider.value(
        value: authCubit,
        child: BlocConsumer<AuthCubit, AuthState>(
          listenWhen: (prev, curr) => prev.signOutState != curr.signOutState,
          listener: (ctx, state) {
            if (state.signOutState.status == StateStatus.success) {
              // Close the sheet first, then replace the entire route stack
              ctx.router.replaceAll([const UnauthenticatedRoutes()]);
            }
            if (state.signOutState.status == StateStatus.error) {
              ctx.router.pop(); // close sheet
              AppToast.showError(
                message:
                    state.signOutState.message ??
                    context.locale.unexpectedError,
                context: context,
              );
            }
          },
          builder: (ctx, state) {
            return StateHandler(
              state: state.signOutState,
              // Overlay spinner keeps the sheet visible while signing out
              loadingOverlayWidget: const CircularProgressIndicator(),
              builder: (_, __) => _LogoutSheetContent(authCubit: authCubit),
            );
          },
        ),
      );
    },
  );
}

// ─── Sheet Content ────────────────────────────────────────────────────────────

class _LogoutSheetContent extends StatelessWidget {
  final AuthCubit authCubit;

  const _LogoutSheetContent({required this.authCubit});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /* ──────────────── ICON ──────────────── */
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      context.colorScheme.primary,
                      context.colorScheme.secondary.withValues(alpha: 0.8),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  SolarIconsOutline.logout_2,
                  color: context.colorScheme.textPrimary,
                  size: 28,
                ),
              ),

              const SizedBox(height: 16),

              /* ──────────────── TITLE ─────────────── */
              Text(
                context.locale.logout,
                style: context.textTheme.titleLarge?.copyWith(
                  color: context.colorScheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              /* ────────────────── BODY ────────────── */
              Text(
                context.locale.logoutConfirm,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.textSecondary,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 28),

              /* ────────────────── ACTIONS ─────────── */
              Row(
                children: [
                  // Cancel
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: context.colorScheme.surfaceContainerHighest,
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

                  // Confirm logout
                  Expanded(
                    child: AppButton(
                      text: context.locale.logout,
                      onTap: () => authCubit.signOut(),
                    ),
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

// ─── Profile Tile ─────────────────────────────────────────────────────────────

class _ProfileTile extends StatelessWidget {
  final Widget icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: icon,
      title: AppText(
        title,
        style: context.textTheme.titleMedium?.copyWith(
          color: context.colorScheme.textPrimary,
        ),
      ),
      subtitle: AppText(
        subtitle,
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.colorScheme.textSecondary,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      horizontalTitleGap: 20,
    ).addAction(onTap: onTap);
  }
}
