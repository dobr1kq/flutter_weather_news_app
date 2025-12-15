import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hive/hive.dart';

import 'package:flutter_weather_news_app/core/di/service_locator.dart';
import 'package:flutter_weather_news_app/core/config/i_weather_local_storage.dart';
import 'package:flutter_weather_news_app/core/config/saved_cities_storage.dart';

import 'package:flutter_weather_news_app/features/weather/domain/entities/weather_entity.dart';
import 'package:flutter_weather_news_app/features/weather/domain/entities/daily_forecast_entity.dart';
import 'package:flutter_weather_news_app/features/weather/domain/repositories/weather_repository.dart';

import 'package:flutter_weather_news_app/features/news/domain/repositories/news_repository.dart';
import 'package:flutter_weather_news_app/features/news/domain/entities/news_article_entity.dart';

class FakeWeatherLocalStorage implements IWeatherLocalStorage {
  String? _lastCity;

  @override
  String? getLastCity() => _lastCity;

  @override
  Future<void> saveLastCity(String city) async {
    _lastCity = city;
  }
}

class MockBox extends Mock implements Box<dynamic> {}

class FakeWeatherRepository implements WeatherRepository {
  @override
  Future<WeatherEntity> getCurrentWeatherByCity(String city) async {
    return WeatherEntity(
      cityName: city,
      temperature: 10.0,
      description: 'clear sky',
      iconCode: '01d',
      feelsLike: 9.0,
      humidity: 50,
    );
  }

  @override
  Future<List<DailyForecastEntity>> getFiveDayForecastByCity(
    String city,
  ) async {
    return [
      DailyForecastEntity(
        date: DateTime(2025, 1, 1),
        minTemp: 1,
        maxTemp: 5,
        description: 'clouds',
        iconCode: '02d',
      ),
    ];
  }
}

class FakeNewsRepository implements NewsRepository {
  @override
  Future<List<NewsArticleEntity>> getTopHeadlines({
    String? countryCode,
    String? category,
  }) async {
    return [];
  }
}

Future<void> setupTestDependencies() async {
  final getIt = sl;
  await getIt.reset();

  getIt.registerLazySingleton<IWeatherLocalStorage>(
    () => FakeWeatherLocalStorage(),
  );

  final box = MockBox();
  when(() => box.get(any())).thenReturn(<String>[]);
  when(() => box.put(any(), any())).thenAnswer((_) async {});
  getIt.registerLazySingleton<SavedCitiesStorage>(
    () => SavedCitiesStorage(box),
  );

  getIt.registerLazySingleton<WeatherRepository>(() => FakeWeatherRepository());
  getIt.registerLazySingleton<NewsRepository>(() => FakeNewsRepository());
}
