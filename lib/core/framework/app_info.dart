import 'package:package_info_plus/package_info_plus.dart';

class AppInfo {
  static String version = '';
  static String buildNumber = '';
  static String packageName = '';

  static Future<PackageInfo> init() async {
    final info = await PackageInfo.fromPlatform();
    version = info.version;
    buildNumber = info.buildNumber;
    packageName = info.packageName;
    return info;
  }
}
