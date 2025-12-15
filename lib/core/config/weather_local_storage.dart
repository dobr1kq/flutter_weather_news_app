import 'package:shared_preferences/shared_preferences.dart';
import 'i_weather_local_storage.dart';

class WeatherLocalStorage implements IWeatherLocalStorage {
  final SharedPreferences _prefs;

  WeatherLocalStorage(this._prefs);

  @override
  String? getLastCity() => _prefs.getString('last_city');

  @override
  Future<void> saveLastCity(String city) async {
    await _prefs.setString('last_city', city);
  }
}
