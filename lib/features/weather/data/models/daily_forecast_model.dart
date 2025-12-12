import '../../domain/entities/daily_forecast_entity.dart';

class DailyForecastModel extends DailyForecastEntity {
  const DailyForecastModel({
    required super.date,
    required super.minTemp,
    required super.maxTemp,
    required super.description,
    required super.iconCode,
  });
}
