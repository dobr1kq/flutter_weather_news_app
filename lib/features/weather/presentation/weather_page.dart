import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'weather_providers.dart';

class WeatherPage extends ConsumerWidget {
  const WeatherPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defaultCity = dotenv.env['DEFAULT_CITY'] ?? 'Kyiv';
    final weatherAsync = ref.watch(weatherByCityProvider(defaultCity));

    return weatherAsync.when(
      data: (weather) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                weather.cityName,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                '${weather.temperature.toStringAsFixed(1)} °C',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 8),
              Text(
                weather.description,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'Відчувається як: ${weather.feelsLike.toStringAsFixed(1)} °C',
              ),
              Text('Вологість: ${weather.humidity}%'),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) {
        return Center(child: Text('Помилка завантаження погоди: $e'));
      },
    );
  }
}
