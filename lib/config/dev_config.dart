import 'dart:io';

import 'base_config.dart';

class DevConfig implements BaseConfig {
  @override
  String get apiHost => // "http://192.168.15.3:8080";
      Platform.isAndroid
          ? "http://10.0.2.2:8080"
          // "http://192.168.15.3:8080"
          : "http://localhost:8080";
}
