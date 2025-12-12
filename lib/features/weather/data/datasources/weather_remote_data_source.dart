import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/weather_model.dart';

abstract class WeatherRemoteDataSource {
  Future<WeatherModel> getCurrentWeatherByCity(String city);
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
      // Якщо місто не знайдено
      if (e.response?.statusCode == 404) {
        throw Exception(
          'Місто "$city" не знайдено. Перевірте правильність назви.',
        );
      }

      // Інші помилки – більш загальне повідомлення
      throw Exception('Не вдалося завантажити погоду. Спробуйте пізніше.');
    }
  }
}
