import 'package:eventos_da_rep/http/user_client.dart';
import 'package:eventos_da_rep/providers/auth_provider.dart';
import 'package:eventos_da_rep/providers/shared_preferences_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../models/app_version.dart';
import 'firebase_service.dart';

class SettingsService {
  final SharedPreferencesProvider _sharedPreferencesProvider =
      SharedPreferencesProvider();

  final UserClient _userClient = UserClient();
  final FirebaseService firebaseService = FirebaseService();

  void logout(BuildContext context) {
    final authService = Provider.of<AuthProvider>(context, listen: false);
    authService.logout().then((_) => Navigator.pop(context));
  }

  Future<AppVersion> getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;

    return AppVersion(
      appName: appName,
      packageName: packageName,
      version: version,
      buildVersion: buildNumber,
    );
  }

  Future<void> deleteUser(BuildContext context) async {
    try {
      String? userId =
          await _sharedPreferencesProvider.getStringValue(prefUserId);

      if (userId != null) {
        await _userClient.deleteUser(userId);
        await FirebaseMessaging.instance.deleteToken();
        await firebaseService.getAuthUser()?.delete();
      }
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
