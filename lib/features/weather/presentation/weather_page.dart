import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../core/config/weather_local_storage.dart';
import '../../../core/di/service_locator.dart';

import 'weather_providers.dart';

class WeatherPage extends ConsumerStatefulWidget {
  const WeatherPage({super.key});

  @override
  ConsumerState<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends ConsumerState<WeatherPage> {
  late TextEditingController _controller;
  late String _currentCity;
  late final WeatherLocalStorage _localStorage;

  @override
  void initState() {
    super.initState();

    _localStorage = sl<WeatherLocalStorage>();

    // Спочатку ставимо дефолтне місто
    _currentCity = dotenv.env['DEFAULT_CITY'] ?? 'Kyiv';
    _controller = TextEditingController(text: _currentCity);

    // Потім пробуємо підвантажити збережене (асинхронно)
    _loadLastCity();
  }

  Future<void> _loadLastCity() async {
    final savedCity = _localStorage.getLastCity();
    if (savedCity != null && savedCity.isNotEmpty) {
      setState(() {
        _currentCity = savedCity;
        _controller.text = savedCity;
      });

      // Перечитати провайдер з новим містом (опційно)
      ref.refresh(weatherByCityProvider(_currentCity));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final input = _controller.text.trim();
    if (input.isEmpty) return;

    setState(() {
      _currentCity = input;
    });

    // Зберігаємо місто
    await _localStorage.saveLastCity(input);

    // Оновлюємо дані
    ref.refresh(weatherByCityProvider(_currentCity));
  }

  @override
  Widget build(BuildContext context) {
    final weatherAsync = ref.watch(weatherByCityProvider(_currentCity));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    labelText: 'Місто',
                    hintText: 'Введіть назву міста',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _search(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(onPressed: _search, icon: const Icon(Icons.search)),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: weatherAsync.when(
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
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48),
                      const SizedBox(height: 8),
                      const Text('Не вдалося завантажити погоду'),
                      const SizedBox(height: 4),
                      Text(
                        '$e',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _search,
                        child: const Text('Спробувати ще раз'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
