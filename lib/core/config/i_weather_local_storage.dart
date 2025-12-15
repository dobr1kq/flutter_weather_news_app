abstract class IWeatherLocalStorage {
  String? getLastCity();
  Future<void> saveLastCity(String city);
}
