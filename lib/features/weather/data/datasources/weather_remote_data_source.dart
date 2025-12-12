import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/weather_model.dart';
import '../models/daily_forecast_model.dart';

abstract class WeatherRemoteDataSource {
  Future<WeatherModel> getCurrentWeatherByCity(String city);

  Future<List<DailyForecastModel>> getFiveDayForecastByCity(String city);
}

class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  final Dio dio;

  WeatherRemoteDataSourceImpl(this.dio);

  @override
  Future<WeatherModel> getCurrentWeatherByCity(String city) async {
    final apiKey = dotenv.env['OPEN_WEATHER_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('OPEN_WEATHER_API_KEY is not set in .env');
    }

    try {
      final response = await dio.get(
        'https://api.openweathermap.org/data/2.5/weather',
        queryParameters: {
          'q': city,
          'appid': apiKey,
          'units': 'metric',
          'lang': 'ua',
        },
      );

      return WeatherModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception(
          'Місто "$city" не знайдено. Перевірте правильність назви.',
        );
      }

      throw Exception('Не вдалося завантажити погоду. Спробуйте пізніше.');
    }
  }

  @override
  Future<List<DailyForecastModel>> getFiveDayForecastByCity(String city) async {
    final apiKey = dotenv.env['OPEN_WEATHER_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('OPEN_WEATHER_API_KEY is not set in .env');
    }

    final response = await dio.get(
      'https://api.openweathermap.org/data/2.5/forecast',
      queryParameters: {
        'q': city,
        'appid': apiKey,
        'units': 'metric',
        'lang': 'ua',
      },
    );

    final data = response.data as Map<String, dynamic>;
    final list = (data['list'] as List<dynamic>).cast<Map<String, dynamic>>();

    // групуємо по даті (yyyy-MM-dd)
    final Map<String, List<Map<String, dynamic>>> byDate = {};

    for (final item in list) {
      final dtTxt = item['dt_txt'] as String?; // "2025-01-12 12:00:00"
      if (dtTxt == null) continue;
      final dateStr = dtTxt.split(' ').first;

      byDate.putIfAbsent(dateStr, () => []).add(item);
    }

    final result = <DailyForecastModel>[];

    final sortedKeys = byDate.keys.toList()..sort();

    for (final dateStr in sortedKeys.take(5)) {
      final itemsForDay = byDate[dateStr]!;
      double minTemp = double.infinity;
      double maxTemp = -double.infinity;

      for (final item in itemsForDay) {
        final main = item['main'] as Map<String, dynamic>;
        final tMin = (main['temp_min'] as num).toDouble();
        final tMax = (main['temp_max'] as num).toDouble();
        if (tMin < minTemp) minTemp = tMin;
        if (tMax > maxTemp) maxTemp = tMax;
      }

      final midItem = itemsForDay[itemsForDay.length ~/ 2];
      final weatherList = midItem['weather'] as List<dynamic>;
      final weather = weatherList.first as Map<String, dynamic>;

      final description = weather['description'] as String? ?? '';
      final iconCode = weather['icon'] as String? ?? '01d';

      result.add(
        DailyForecastModel(
          date: DateTime.parse(dateStr),
          minTemp: minTemp,
          maxTemp: maxTemp,
          description: description,
          iconCode: iconCode,
        ),
      );
    }

    return result;
  }
}
