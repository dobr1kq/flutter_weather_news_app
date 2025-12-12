import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../features/weather/data/datasources/weather_remote_data_source.dart';
import '../../features/weather/data/repositories/weather_repository_impl.dart';
import '../../features/weather/domain/repositories/weather_repository.dart';

import '../../features/news/data/datasources/news_remote_data_source.dart';
import '../../features/news/data/repositories/news_repository_impl.dart';
import '../../features/news/domain/repositories/news_repository.dart';

import '../config/weather_local_storage.dart';
import '../config/saved_cities_storage.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // SharedPreferences
  final sharedPrefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPrefs);

  // Hive (для user preferences)
  await Hive.initFlutter();
  final prefsBox = await Hive.openBox('preferences');
  sl.registerSingleton<Box>(prefsBox, instanceName: 'preferences');

  // Local storage services
  sl.registerLazySingleton<WeatherLocalStorage>(
    () => WeatherLocalStorage(sl<SharedPreferences>()),
  );

  sl.registerLazySingleton<SavedCitiesStorage>(
    () => SavedCitiesStorage(sl<Box>(instanceName: 'preferences')),
  );

  // Dio
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    return dio;
  });

  // Weather feature
  sl.registerLazySingleton<WeatherRemoteDataSource>(
    () => WeatherRemoteDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<WeatherRepository>(
    () => WeatherRepositoryImpl(sl<WeatherRemoteDataSource>()),
  );

  // News feature
  sl.registerLazySingleton<NewsRemoteDataSource>(
    () => NewsRemoteDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<NewsRepository>(
    () => NewsRepositoryImpl(sl<NewsRemoteDataSource>()),
  );
}
