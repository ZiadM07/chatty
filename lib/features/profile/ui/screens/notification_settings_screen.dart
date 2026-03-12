import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/core/di/injectable.dart';
import 'package:Chatty/features/profile/cubits/notifications_cubit.dart';
import 'package:Chatty/features/profile/ui/widgets/settings_tile.dart';

@RoutePage()
class NotificationSettingsScreen extends StatelessWidget
    implements AutoRouteWrapper {
  const NotificationSettingsScreen({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<NotificationsCubit>(),
      child: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: context.locale.notificationSettings,
      showBackButton: true,
      body: BlocBuilder<NotificationsCubit, AppState<NotificationSettings>>(
        builder: (context, state) {
          final cubit = context.read<NotificationsCubit>();

          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final settings = state.data ?? cubit.settings;

          return SingleChildScrollView(
            child: Column(
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
                      Icons.notifications_active_outlined,
                      color: context.colorScheme.onPrimary,
                      size: 48,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                SettingsTile(
                  title: context.locale.messageNotifications,
                  subtitle: context.locale.messageNotificationsDesc,
                  icon: SolarIconsBold.chatRoundLine,
                  trailing: Switch(
                    value: settings.messageNotifications,
                    onChanged: cubit.toggleMessageNotifications,
                  ),
                  onTap: () {},
                ),

                const SizedBox(height: 15),

                SettingsTile(
                  title: context.locale.groupNotifications,
                  subtitle: context.locale.groupNotificationsDesc,
                  icon: Icons.group_outlined,
                  trailing: Switch(
                    value: settings.groupNotifications,
                    onChanged: cubit.toggleGroupNotifications,
                  ),
                  onTap: () {},
                ),

                const SizedBox(height: 15),

                SettingsTile(
                  title: context.locale.storyReplyNotifications,
                  subtitle: context.locale.storyReplyNotificationsDesc,
                  icon: SolarIconsBold.reply,
                  trailing: Switch(
                    value: settings.storyReplyNotifications,
                    onChanged: cubit.toggleStoryReplyNotifications,
                  ),
                  onTap: () {},
                ),

                const SizedBox(height: 15),

                SettingsTile(
                  title: context.locale.notificationSound,
                  subtitle: context.locale.notificationSoundDesc,
                  icon: SolarIconsBold.volume,
                  trailing: Switch(
                    value: settings.sound,
                    onChanged: cubit.toggleSound,
                  ),
                  onTap: () {},
                ),

                const SizedBox(height: 15),

                SettingsTile(
                  title: context.locale.vibration,
                  subtitle: context.locale.vibrationDesc,
                  icon: SolarIconsBold.smartphoneVibration,
                  trailing: Switch(
                    value: settings.vibration,
                    onChanged: cubit.toggleVibration,
                  ),
                  onTap: () {},
                ),

                const SizedBox(height: 15),

                // ── Message Preview ─────────────────────────────────────────
                SettingsTile(
                  title: context.locale.messagePreview,
                  subtitle: context.locale.messagePreviewDesc,
                  icon: Icons.visibility_outlined,
                  trailing: Switch(
                    value: settings.preview,
                    onChanged: cubit.togglePreview,
                  ),
                  onTap: () {},
                ),

                const SizedBox(height: 15),

                // ── In-App Sound ────────────────────────────────────────────
                SettingsTile(
                  title: context.locale.inAppSound,
                  subtitle: context.locale.inAppSoundDesc,
                  icon: Icons.music_note_outlined,
                  trailing: Switch(
                    value: settings.inAppSound,
                    onChanged: cubit.toggleInAppSound,
                  ),
                  onTap: () {},
                ),

                const SizedBox(height: 30),
              ],
            ).addPadding(horizontal: 20),
          );
        },
      ),
    );
  }
}
