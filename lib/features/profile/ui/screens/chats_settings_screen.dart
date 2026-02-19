import 'package:chatty/config/router/app_router.gr.dart';
import 'package:chatty/core/constants/exports.dart';
import 'package:chatty/features/profile/ui/widgets/settings_tile.dart';
import 'package:chatty/features/shared/cubits/app_cubit.dart';

@RoutePage()
class ChatsSettingsScreen extends StatelessWidget {
  const ChatsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appCubit = context.read<AppCubit>();

    return AppScaffold(
      title: context.locale.chatSettings,
      showBackButton: true,
      body: BlocBuilder<AppCubit, AppState>(
        builder: (context, state) {
          final currentThemeIndex = appCubit.appThemeMode.index;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const SizedBox(height: 30),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          context.colorScheme.primary,
                          context.colorScheme.secondary,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: context.colorScheme.primary.withValues(
                            alpha: 0.3,
                          ),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      SolarIconsOutline.chatRoundLine,
                      color: context.colorScheme.onPrimary,
                      size: 48,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                AppText(
                  context.locale.appearance,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                _ThemeOption(
                  title: context.locale.lightMode,
                  description: context.locale.brightAndClean,
                  icon: SolarIconsOutline.sun2,
                  isSelected: currentThemeIndex == AppThemeMode.light.index,
                  onTap: () {
                    appCubit.changeThemeMode(AppThemeMode.light.index);
                  },
                ),
                const SizedBox(height: 16),
                _ThemeOption(
                  title: context.locale.darkMode,
                  description: context.locale.easierOnEyes,
                  icon: SolarIconsOutline.moon,
                  isSelected: currentThemeIndex == AppThemeMode.dark.index,
                  onTap: () {
                    appCubit.changeThemeMode(AppThemeMode.dark.index);
                  },
                ),
                const SizedBox(height: 16),

                _ThemeOption(
                  title: context.locale.systemDefault,
                  description: context.locale.matchDeviceSettings,
                  icon: SolarIconsOutline.settings,
                  isSelected: currentThemeIndex == AppThemeMode.system.index,
                  onTap: () {
                    appCubit.changeThemeMode(AppThemeMode.system.index);
                  },
                ),

                const SizedBox(height: 16),
                AppText(
                  context.locale.chatWallpaperTitle,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                SettingsTile(
                  title: context.locale.chatWallpaper,
                  subtitle: context.locale.chatsWallpaperSubtitle,
                  icon: SolarIconsOutline.album,
                  onTap: () {
                    context.router.push(const ChatWallpaperRoute());
                  },
                ),
                const SizedBox(height: 30),
                AppText(
                  context.locale.preferences,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                SettingsTile(
                  title: context.locale.enterIsSend,
                  subtitle: context.locale.pressEnterToSend,
                  icon: Icons.keyboard_return,
                  onTap: () {},
                  trailing: Switch(
  value: appCubit.enterIsSend,
  onChanged: appCubit.toggleEnterIsSend,
)

                ),
              ],
            ).addPadding(horizontal: 20),
          );
        },
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  const _ThemeOption({
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const AppPadding.set(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? context.colorScheme.primary
              : context.colorScheme.surfaceContainerHigh,
          width: isSelected ? 1 : 0,
        ),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const AppPadding.set(all: 8),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        context.colorScheme.primary,
                        context.colorScheme.secondary,
                      ],
                    )
                  : null,
              color: isSelected
                  ? null
                  : context.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: isSelected
                  ? context.colorScheme.onPrimary
                  : context.colorScheme.onSurfaceVariant,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: AppText(
              title,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(
            isSelected ? Icons.check : null,
            size: 16,
            color: context.colorScheme.textPrimary,
          ),
        ],
      ),
    ).addAction(onTap: onTap);
  }
}
