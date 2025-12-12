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

    _currentCity = dotenv.env['DEFAULT_CITY'] ?? 'Kyiv';
    _controller = TextEditingController(text: _currentCity);

    _loadLastCity();
  }

  Future<void> _loadLastCity() async {
    final savedCity = _localStorage.getLastCity();
    if (savedCity != null && savedCity.isNotEmpty) {
      setState(() {
        _currentCity = savedCity;
        _controller.text = savedCity;
      });
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

    await _localStorage.saveLastCity(input);
    ref.refresh(weatherByCityProvider(_currentCity));
  }

  Future<void> _refreshWeather() async {
    ref.refresh(weatherByCityProvider(_currentCity));
  }

  List<Color> _backgroundGradient(double temp) {
    if (temp <= 0) {
      return [Colors.blue.shade900, Colors.blue.shade400];
    } else if (temp <= 15) {
      return [Colors.indigo.shade700, Colors.lightBlue.shade400];
    } else if (temp <= 25) {
      return [Colors.teal.shade600, Colors.greenAccent.shade400];
    } else {
      return [Colors.deepOrange.shade400, Colors.redAccent.shade200];
    }
  }

  String _iconUrl(String iconCode) {
    return 'https://openweathermap.org/img/wn/$iconCode@4x.png';
  }

  @override
  Widget build(BuildContext context) {
    final weatherAsync = ref.watch(weatherByCityProvider(_currentCity));

    // Якщо є дані — малюємо градієнт, інакше фон залишаємо стандартний
    final gradient = weatherAsync.whenOrNull(
      data: (weather) => _backgroundGradient(weather.temperature),
    );

    return Container(
      decoration:
          gradient != null
              ? BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              )
              : null,
      child: SafeArea(
        child: Column(
          children: [
            // 🔹 Рядок пошуку — завжди зверху
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        labelText: 'Місто',
                        hintText: 'Введіть назву міста',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      onSubmitted: (_) => _search(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _search,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Icon(Icons.search),
                  ),
                ],
              ),
            ),

            // 🔹 Нижче — або картка, або лоадер, або помилка
            Expanded(
              child: weatherAsync.when(
                data: (weather) {
                  return Center(
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              weather.cityName,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              weather.description,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 120,
                              child: Image.network(
                                _iconUrl(weather.iconCode),
                                errorBuilder:
                                    (_, __, ___) =>
                                        const Icon(Icons.cloud, size: 80),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '${weather.temperature.toStringAsFixed(1)} °C',
                              style: Theme.of(context).textTheme.displaySmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Відчувається як: ${weather.feelsLike.toStringAsFixed(1)} °C',
                            ),
                            const SizedBox(height: 4),
                            Text('Вологість: ${weather.humidity}%'),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _refreshWeather,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Оновити погоду'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
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
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
