import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  const SharedPreferencesService(this._preferences);

  final SharedPreferences _preferences;

  int? getInt(String key) => _preferences.getInt(key);

  Future<bool> setInt(String key, int value) => _preferences.setInt(key, value);
}
