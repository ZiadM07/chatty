// ignore_for_file: unused_local_variable

import 'package:device_info_plus/device_info_plus.dart';

import '../constants/exports.dart';

class DeviceInfo {
  static Future<Device> getInfo() async {
    String name = '';
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    bool isHuawei = false;
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      name = androidInfo.model;
      final manufacturer = androidInfo.manufacturer.toLowerCase();
      final brand = androidInfo.brand.toLowerCase();
      isHuawei = manufacturer.contains("huawei") || brand.contains("huawei");
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      name = iosInfo.name;
    }
    return Device(id: name, type: Platform.isIOS ? 2 : 1);
  }
}

class Device {
  final String id;
  final int type;
  final String? fcmToken;

  Device({required this.id, required this.type, this.fcmToken});
}
