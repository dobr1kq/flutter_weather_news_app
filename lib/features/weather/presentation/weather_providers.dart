import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/service_locator.dart';
import '../domain/entities/weather_entity.dart';
import '../domain/repositories/weather_repository.dart';

final _weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return sl<WeatherRepository>();
});

final weatherByCityProvider = FutureProvider.family<WeatherEntity, String>((
  ref,
  city,
) async {
  final repo = ref.watch(_weatherRepositoryProvider);
  return await repo.getCurrentWeatherByCity(city);
});
