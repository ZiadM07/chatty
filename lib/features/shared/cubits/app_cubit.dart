import 'dart:math';

import '../../../core/constants/exports.dart';

@singleton
class AppCubit extends Cubit<AppState> {
  final AppPreferences _preferences;

  late Locale locale;
  late AppThemeMode appThemeMode;
  late ValueNotifier<bool> isArSelected;
  late bool enterIsSend;

  AppCubit(this._preferences) : super(AppState()) {
    locale = Locale(_preferences.language);
    appThemeMode = _preferences.appThemeMode;
    isArSelected = ValueNotifier(_preferences.language == AppConstants.arCode);
    enterIsSend = _preferences.enterIsSend;
  }

  static int get randomId => Random().nextInt(999999);

  bool get isAuthenticated => _preferences.isAuthenticated;

  void refreshAuth() {
    emit(state.copyWith(data: randomId));
  }

  void changeLang(String lang) {
    locale = Locale(lang);
    _preferences.language = lang;
    isArSelected.value = lang == AppConstants.arCode;
    emit(state.copyWith(data: randomId));
  }

  void changeThemeMode(int index) {
    _preferences.appThemeMode = getAppThemeModeFromIndex(index);
    appThemeMode = _preferences.appThemeMode;
    emit(state.copyWith(data: randomId));
  }

  void applyPlatformThemeMode() {
    if (appThemeMode == AppThemeMode.system) {
      emit(state.copyWith(data: randomId));
    }
  }

  void toggleEnterIsSend(bool value) {
    enterIsSend = value;
    _preferences.enterIsSend = value;
    emit(state.copyWith(data: randomId));
  }
}
