import 'package:shared_preferences/shared_preferences.dart';

class WeatherLocalStorage {
  static const _lastCityKey = 'last_city';

  final SharedPreferences _prefs;

  WeatherLocalStorage(this._prefs);

  String? getLastCity() {
    return _prefs.getString(_lastCityKey);
  }

  Future<void> saveLastCity(String city) async {
    await _prefs.setString(_lastCityKey, city);
  }
}
