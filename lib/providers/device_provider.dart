import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:eventos_da_rep/models/device.dart';

class DeviceProvider {
  Future<Device> getDeviceInfos(String token) async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String? brand;
    String? model;

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
      model = androidDeviceInfo.model;
      brand = androidDeviceInfo.brand;
    } else {
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      model = iosDeviceInfo.model;
      brand = 'Apple';
    }

    return Device(brand: brand!, model: model!, token: token);
  }
}
