import '../../domain/entities/weather_entity.dart';
import '../../domain/entities/daily_forecast_entity.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/weather_remote_data_source.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource remoteDataSource;

  WeatherRepositoryImpl(this.remoteDataSource);

  @override
  Future<WeatherEntity> getCurrentWeatherByCity(String city) async {
    return await remoteDataSource.getCurrentWeatherByCity(city);
  }

  @override
  Future<List<DailyForecastEntity>> getFiveDayForecastByCity(
    String city,
  ) async {
    return await remoteDataSource.getFiveDayForecastByCity(city);
  }
}
