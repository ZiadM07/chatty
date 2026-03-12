import 'package:Chatty/config/router/app_router.gr.dart';
import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/features/auth/cubits/auth_cubit.dart';
import 'package:Chatty/features/auth/cubits/auth_state.dart';
import 'package:Chatty/features/shared/widgets/app_gradient_button.dart';
import 'package:Chatty/features/shared/widgets/app_toast.dart';

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

void _confirmLogout(BuildContext context) {
  final authCubit = context.read<AuthCubit>();

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return BlocProvider.value(
        value: authCubit,
        child: BlocConsumer<AuthCubit, AuthState>(
          listenWhen: (prev, curr) => prev.signOutState != curr.signOutState,
          listener: (ctx, state) {
            if (state.signOutState.status == StateStatus.success) {
              ctx.router.replaceAll([const UnauthenticatedRoutes()]);
            }
            if (state.signOutState.status == StateStatus.error) {
              ctx.router.pop();
              AppToast.showError(
                message: context.locale.thisOperationFailed,

                context: context,
              );
            }
          },
          builder: (context, state) {
            return StateHandler(
              state: state.signOutState,
              loadingOverlayWidget: const CircularProgressIndicator(),
              builder: (context, state) =>
                  _LogoutSheetContent(authCubit: authCubit),
            );
          },
        ),
      );
    },
  );
}

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

              Text(
                context.locale.logout,
                style: context.textTheme.titleLarge?.copyWith(
                  color: context.colorScheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                context.locale.logoutConfirm,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.textSecondary,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 28),

              Row(
                children: [
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
