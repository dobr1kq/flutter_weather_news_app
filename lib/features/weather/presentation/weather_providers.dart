import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/config/saved_cities_storage.dart';

import '../domain/entities/weather_entity.dart';
import '../domain/entities/daily_forecast_entity.dart';
import '../domain/repositories/weather_repository.dart';

// Репозиторій погоди
final _weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return sl<WeatherRepository>();
});

// Поточна погода по місту
final weatherByCityProvider = FutureProvider.family<WeatherEntity, String>((
  ref,
  city,
) async {
  final repo = ref.watch(_weatherRepositoryProvider);
  return await repo.getCurrentWeatherByCity(city);
});

// Прогноз на 5 днів по місту
final forecastByCityProvider =
    FutureProvider.family<List<DailyForecastEntity>, String>((ref, city) async {
      final repo = ref.watch(_weatherRepositoryProvider);
      return await repo.getFiveDayForecastByCity(city);
    });

// ======================== ЗБЕРЕЖЕНІ МІСТА ========================

class SavedCitiesNotifier extends StateNotifier<List<String>> {
  final SavedCitiesStorage _storage;

  SavedCitiesNotifier(this._storage) : super(_storage.getSavedCities());

  Future<void> addCity(String city) async {
    final trimmed = city.trim();
    if (trimmed.isEmpty) return;

    if (!state.contains(trimmed)) {
      final updated = [...state, trimmed];
      state = updated;
      await _storage.saveCities(updated);
    }
  }

  Future<void> removeCity(String city) async {
    final updated = state.where((c) => c != city).toList();
    state = updated;
    await _storage.saveCities(updated);
  }
}

final savedCitiesProvider =
    StateNotifierProvider<SavedCitiesNotifier, List<String>>((ref) {
      final storage = sl<SavedCitiesStorage>();
      return SavedCitiesNotifier(storage);
    });
