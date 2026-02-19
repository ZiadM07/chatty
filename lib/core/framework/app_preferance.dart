import 'package:chatty/core/framework/storage_service.dart';

// import '../../config/theme/app_themes.dart';
import '../../config/theme/app_theme.dart';
import '../constants/app_constants.dart';

class AppPreferences {
  final StorageService storage;

  AppPreferences(this.storage);

  // ===========================================================
  // LANGUAGE
  // ===========================================================
  String get language =>
      storage.get<String>(AppConstants.lang, AppConstants.enCode);

  set language(String value) => storage.save(AppConstants.lang, value);

  // ===========================================================
  // THEME MODE
  // ===========================================================
  AppThemeMode get appThemeMode {
    final index = storage.get<int>(
      AppConstants.theme,
      AppThemeMode.system.index,
    );
    return AppThemeMode.values[index];
  }

  set appThemeMode(AppThemeMode value) =>
      storage.save(AppConstants.theme, value.index);

  // ===========================================================
  // AUTH TOKEN
  // ===========================================================
  String get token => storage.get<String>(AppConstants.token, '');

  set token(String value) => storage.save(AppConstants.token, value);

  bool get isAuthenticated => token.isNotEmpty;

  // ===========================================================
  // COMPLETED PROFILE
  // ===========================================================
  bool get hasCompletedProfile =>
      storage.get<bool>(AppConstants.completedProfile, false);

  set hasCompletedProfile(bool value) =>
      storage.save(AppConstants.completedProfile, value);

  // ===========================================================
  // NOTIFICATIONS SETTINGS
  // ===========================================================
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

  // ===========================================================
  // PRIVACY SETTINGS
  // ===========================================================
  bool get readReceipts => storage.get<bool>("read_receipts", true);

  set readReceipts(bool value) => storage.save("read_receipts", value);

  // ===========================================================
  // CHAT WALLPAPER SETTINGS  (Local Only)
  // ===========================================================

  String get chatWallpaperPath =>
      storage.get<String>("chat_wallpaper_path", "");

  set chatWallpaperPath(String value) =>
      storage.save("chat_wallpaper_path", value);

  /// Brightness: 0.0 → 1.0
  double get chatWallpaperBrightness =>
      storage.get<double>("chat_wallpaper_brightness", 0.5);

  set chatWallpaperBrightness(double value) =>
      storage.save("chat_wallpaper_brightness", value);

  // ===========================================================
  //  Enter Is Send   (Local Only)
  // ===========================================================

  bool get enterIsSend => storage.get<bool>("enter_is_send", false);

  set enterIsSend(bool value) => storage.save("enter_is_send", value);
}
