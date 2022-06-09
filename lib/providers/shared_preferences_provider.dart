import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesProvider {
  Future<void> putStringValue(String key, String value) async {
    final pref = await SharedPreferences.getInstance();

    pref.setString(key, value);
  }

  Future<String?> getStringValue(String key) async {
    final pref = await SharedPreferences.getInstance();

    return pref.getString(key);
  }
}
