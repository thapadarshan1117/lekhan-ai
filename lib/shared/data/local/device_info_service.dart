import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';

class DeviceInfoService {
  static final DeviceInfoService _instance = DeviceInfoService._internal();
  static final DeviceInfoPlugin _devicePlugin = DeviceInfoPlugin();

  factory DeviceInfoService() {
    return _instance;
  }

  DeviceInfoService._internal();

  Future<String> getDeviceId() async {
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await _devicePlugin.androidInfo;
        return androidInfo.id;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await _devicePlugin.iosInfo;
        return iosInfo.identifierForVendor ?? const Uuid().v4();
      } else if (Platform.isWindows) {
        WindowsDeviceInfo windowsInfo = await _devicePlugin.windowsInfo;
        return windowsInfo.computerName;
      } else if (Platform.isLinux) {
        LinuxDeviceInfo linuxInfo = await _devicePlugin.linuxInfo;
        return linuxInfo.machineId ?? const Uuid().v4();
      } else if (Platform.isMacOS) {
        MacOsDeviceInfo macInfo = await _devicePlugin.macOsInfo;
        return macInfo.systemGUID ?? const Uuid().v4();
      }
    } catch (e) {
      return const Uuid().v4();
    }
    return const Uuid().v4();
  }

  Future<String> getDeviceName() async {
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await _devicePlugin.androidInfo;
        return androidInfo.model;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await _devicePlugin.iosInfo;
        return iosInfo.model;
      } else if (Platform.isWindows) {
        WindowsDeviceInfo windowsInfo = await _devicePlugin.windowsInfo;
        return windowsInfo.computerName;
      } else if (Platform.isLinux) {
        LinuxDeviceInfo linuxInfo = await _devicePlugin.linuxInfo;
        return linuxInfo.id;
      } else if (Platform.isMacOS) {
        MacOsDeviceInfo macInfo = await _devicePlugin.macOsInfo;
        return macInfo.model;
      }
    } catch (e) {
      return 'Unknown Device';
    }
    return 'Unknown Device';
  }

  Future<String> getDeviceType() async {
    if (Platform.isAndroid) {
      return 'ANDROID';
    } else if (Platform.isIOS) {
      return 'IOS';
    } else if (Platform.isWindows) {
      return 'WINDOWS';
    } else if (Platform.isLinux) {
      return 'LINUX';
    } else if (Platform.isMacOS) {
      return 'MACOS';
    }
    return 'WEB';
  }

  Future<Map<String, String>> getDeviceInfo() async {
    return {
      'deviceId': await getDeviceId(),
      'deviceName': await getDeviceName(),
      'deviceType': await getDeviceType(),
    };
  }
}
