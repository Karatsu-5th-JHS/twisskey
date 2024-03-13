import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static late SharedPreferences _preferences;

  static const _keyLanguage = 'language';

  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

  static Future setLanguage(String languageCode) async =>
      await _preferences.setString(_keyLanguage, languageCode);

  static String? getLanguage() => _preferences.getString(_keyLanguage);
}
