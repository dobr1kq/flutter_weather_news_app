import 'package:hive/hive.dart';

class SavedCitiesStorage {
  static const _savedCitiesKey = 'saved_cities';

  final Box _box;

  SavedCitiesStorage(this._box);

  List<String> getSavedCities() {
    final data = _box.get(_savedCitiesKey);
    if (data is List) {
      return data.cast<String>();
    }
    return <String>[];
  }

  Future<void> saveCities(List<String> cities) async {
    await _box.put(_savedCitiesKey, cities);
  }
}
