import '../constants/exports.dart';
import '../di/injectable.dart';
import 'app_info.dart';

class AppHeaders {
  static final _pref = getIt<SharedPreferences>();

  static String get lng => _pref.getString(AppConstants.lang) ?? 'en';

  static String get userToken {
    final token = _pref.getString(AppConstants.token) ?? '';
    return token;
  }

  static Map<String, dynamic> to() {
    Map<String, dynamic> header = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'lang': lng,
      'os-type': Platform.isAndroid ? 'android' : 'ios',
      'os-app-version': AppInfo.version,
    };
    if (userToken.isNotEmpty) {
      header['Authorization'] = userToken;
      kPrint(userToken);
    }
    return header;
  }
}
