import '../entities/weather_entity.dart';
import '../entities/daily_forecast_entity.dart';

abstract class WeatherRepository {
  Future<WeatherEntity> getCurrentWeatherByCity(String city);

  Future<List<DailyForecastEntity>> getFiveDayForecastByCity(String city);
}
