import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_weather_news_app/features/weather/data/datasources/weather_remote_data_source.dart';
import 'package:flutter_weather_news_app/features/weather/data/models/weather_model.dart';
import 'package:flutter_weather_news_app/features/weather/data/repositories/weather_repository_impl.dart';
import 'package:flutter_weather_news_app/features/weather/data/models/daily_forecast_model.dart';

class MockWeatherRemoteDataSource extends Mock
    implements WeatherRemoteDataSource {}

void main() {
  late MockWeatherRemoteDataSource mockDs;
  late WeatherRepositoryImpl repo;

  setUp(() {
    mockDs = MockWeatherRemoteDataSource();
    repo = WeatherRepositoryImpl(mockDs);
  });

  group('WeatherRepositoryImpl', () {
    test(
      'getCurrentWeatherByCity повертає WeatherEntity (model) з dataSource',
      () async {
        const city = 'Kyiv';

        const model = WeatherModel(
          cityName: 'Kyiv',
          temperature: 10.5,
          description: 'clear sky',
          iconCode: '01d',
          feelsLike: 9.0,
          humidity: 55,
        );

        when(
          () => mockDs.getCurrentWeatherByCity(city),
        ).thenAnswer((_) async => model);

        final result = await repo.getCurrentWeatherByCity(city);

        expect(result.cityName, 'Kyiv');
        expect(result.temperature, 10.5);
        verify(() => mockDs.getCurrentWeatherByCity(city)).called(1);
        verifyNoMoreInteractions(mockDs);
      },
    );

    test(
      'getFiveDayForecastByCity повертає список forecast з dataSource',
      () async {
        const city = 'Kyiv';

        final models = <DailyForecastModel>[
          DailyForecastModel(
            date: DateTime(2025, 1, 1),
            minTemp: 1,
            maxTemp: 5,
            description: 'clouds',
            iconCode: '02d',
          ),
        ];

        when(
          () => mockDs.getFiveDayForecastByCity(city),
        ).thenAnswer((_) async => models);

        final result = await repo.getFiveDayForecastByCity(city);

        expect(result.length, 1);
        expect(result.first.maxTemp, 5);
        verify(() => mockDs.getFiveDayForecastByCity(city)).called(1);
        verifyNoMoreInteractions(mockDs);
      },
    );
  });
}
