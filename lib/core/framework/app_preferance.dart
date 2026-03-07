import 'package:Chatty/core/framework/storage_service.dart';
import '../../config/theme/app_theme.dart';
import '../constants/app_constants.dart';

class AppPreferences {
  final StorageService storage;

  AppPreferences(this.storage);

  String get language =>
      storage.get<String>(AppConstants.lang, AppConstants.enCode);

  set language(String value) => storage.save(AppConstants.lang, value);

  AppThemeMode get appThemeMode {
    final index = storage.get<int>(
      AppConstants.theme,
      AppThemeMode.system.index,
    );
    return AppThemeMode.values[index];
  }

  set appThemeMode(AppThemeMode value) =>
      storage.save(AppConstants.theme, value.index);

  String get token => storage.get<String>(AppConstants.token, '');

  set token(String value) => storage.save(AppConstants.token, value);

  bool get isAuthenticated => token.isNotEmpty;

  bool get hasCompletedProfile =>
      storage.get<bool>(AppConstants.completedProfile, false);

  set hasCompletedProfile(bool value) =>
      storage.save(AppConstants.completedProfile, value);

  bool get messageNotifications =>
      storage.get<bool>("message_notifications", true);

  set messageNotifications(bool value) =>
      storage.save("message_notifications", value);

  bool get groupNotifications => storage.get<bool>("group_notifications", true);

  set groupNotifications(bool value) =>
      storage.save("group_notifications", value);

  bool get vibration => storage.get<bool>("notification_vibration", true);

  set vibration(bool value) => storage.save("notification_vibration", value);

  bool get preview => storage.get<bool>("notification_preview", true);

  set preview(bool value) => storage.save("notification_preview", value);

  bool get sound => storage.get<bool>("notification_sound", true);

  set sound(bool value) => storage.save("notification_sound", value);

  bool get storyReplyNotifications =>
      storage.get<bool>("story_reply_notifications", true);

  set storyReplyNotifications(bool value) =>
      storage.save("story_reply_notifications", value);

  String get oneSignalPlayerId =>
      storage.get<String>("onesignal_player_id", "");

  set oneSignalPlayerId(String value) =>
      storage.save("onesignal_player_id", value);

  bool get inAppSound => storage.get<bool>("in_app_sound", true);

  set inAppSound(bool value) => storage.save("in_app_sound", value);

  Set<String> get mutedChatIds {
    final raw = storage.get<String>("muted_chat_ids", "");
    if (raw.isEmpty) return {};
    return raw.split(',').toSet();
  }

  set mutedChatIds(Set<String> value) =>
      storage.save("muted_chat_ids", value.join(','));

  bool isChatMuted(String chatId) => mutedChatIds.contains(chatId);

  void muteChatId(String chatId) {
    mutedChatIds = {...mutedChatIds, chatId};
  }

  void unmuteChatId(String chatId) {
    mutedChatIds = mutedChatIds.where((id) => id != chatId).toSet();
  }

  void toggleMuteChatId(String chatId) {
    isChatMuted(chatId) ? unmuteChatId(chatId) : muteChatId(chatId);
  }

  bool get readReceipts => storage.get<bool>("read_receipts", true);

  set readReceipts(bool value) => storage.save("read_receipts", value);

  String get chatWallpaperPath =>
      storage.get<String>("chat_wallpaper_path", "");

  set chatWallpaperPath(String value) =>
      storage.save("chat_wallpaper_path", value);

  double get chatWallpaperBrightness =>
      storage.get<double>("chat_wallpaper_brightness", 0.5);

  set chatWallpaperBrightness(double value) =>
      storage.save("chat_wallpaper_brightness", value);

  bool get enterIsSend => storage.get<bool>("enter_is_send", false);

  set enterIsSend(bool value) => storage.save("enter_is_send", value);
}
