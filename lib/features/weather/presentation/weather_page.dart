import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';

import '../../../core/notifications/notification_service.dart';
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

  String? _lastAlertSignature;

  bool _isAlertCondition(double temp, String description) {
    final desc = description.toLowerCase();

    // Можеш підкоригувати пороги під себе
    if (temp <= 0) return true; // мороз
    if (temp >= 30) return true; // спека
    if (desc.contains('дощ') || desc.contains('rain')) return true;
    if (desc.contains('гроза') ||
        desc.contains('storm') ||
        desc.contains('thunder')) {
      return true;
    }

    return false;
  }

  Future<void> _maybeShowAlert({
    required String city,
    required double temp,
    required String description,
  }) async {
    final signature =
        '${city.toLowerCase()}-${temp.round()}-${description.toLowerCase()}';

    // щоб не спамити — якщо вже показували для такого стану
    if (_lastAlertSignature == signature) return;

    if (_isAlertCondition(temp, description)) {
      _lastAlertSignature = signature;

      String title = 'Погодні попередження для $city';
      String body;

      if (temp <= 0) {
        body =
            'На вулиці мороз (${temp.toStringAsFixed(1)} °C). Одягайся тепліше!';
      } else if (temp >= 30) {
        body =
            'Сильна спека (${temp.toStringAsFixed(1)} °C). Не забудь про воду!';
      } else {
        body = 'Увага: $description. Перевір погоду перед виходом.';
      }

      await NotificationService.instance.showWeatherAlert(
        title: title,
        body: body,
      );
    }
  }

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
      ref.refresh(forecastByCityProvider(_currentCity));
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
    ref.refresh(forecastByCityProvider(_currentCity));
  }

  Future<void> _refreshWeather() async {
    ref.refresh(weatherByCityProvider(_currentCity));
    ref.refresh(forecastByCityProvider(_currentCity));
  }

  Future<void> _selectSavedCity(String city) async {
    setState(() {
      _currentCity = city;
      _controller.text = city;
    });

    await _localStorage.saveLastCity(city);

    ref.refresh(weatherByCityProvider(_currentCity));
    ref.refresh(forecastByCityProvider(_currentCity));
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Геолокація + reverse geocoding через OpenWeatherMap
  Future<void> _useCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnack('Служба геолокації вимкнена. Увімкніть Location Services.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showSnack('Немає доступу до геолокації.');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );

      final apiKey = dotenv.env['OPEN_WEATHER_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        _showSnack('OPEN_WEATHER_API_KEY не налаштовано в .env');
        return;
      }

      final dio = sl<Dio>();
      final response = await dio.get(
        'http://api.openweathermap.org/geo/1.0/reverse',
        queryParameters: {
          'lat': position.latitude,
          'lon': position.longitude,
          'limit': 1,
          'appid': apiKey,
        },
      );

      final data = response.data as List<dynamic>;
      if (data.isEmpty) {
        _showSnack('Не вдалося визначити місто за координатами.');
        return;
      }

      final city =
          (data.first as Map<String, dynamic>)['name'] as String? ?? 'Unknown';

      setState(() {
        _currentCity = city;
        _controller.text = city;
      });

      await _localStorage.saveLastCity(city);

      ref.refresh(weatherByCityProvider(_currentCity));
      ref.refresh(forecastByCityProvider(_currentCity));

      _showSnack('Місто визначено: $city');
    } catch (e) {
      _showSnack('Помилка геолокації: $e');
    }
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
    final savedCities = ref.watch(savedCitiesProvider);

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
            // 🔹 Рядок пошуку + my location + bookmark + search
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
                  IconButton(
                    tooltip: 'Моя локація',
                    onPressed: _useCurrentLocation,
                    icon: const Icon(Icons.my_location),
                  ),
                  IconButton(
                    tooltip: 'Додати в обрані',
                    onPressed: () {
                      ref
                          .read(savedCitiesProvider.notifier)
                          .addCity(_controller.text);
                    },
                    icon: const Icon(Icons.bookmark_add_outlined),
                  ),
                  const SizedBox(width: 4),
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

            // 🔹 Рядок збережених міст (чіпи)
            if (savedCities.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                child: SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: savedCities.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final city = savedCities[index];
                      final bool isSelected =
                          city.toLowerCase() == _currentCity.toLowerCase();

                      return InputChip(
                        label: Text(city),
                        selected: isSelected,
                        onPressed: () => _selectSavedCity(city),
                        onDeleted: () {
                          ref
                              .read(savedCitiesProvider.notifier)
                              .removeCity(city);
                        },
                      );
                    },
                  ),
                ),
              ),

            // 🔹 Основний контент: погода + прогноз (scrollable)
            Expanded(
              child: weatherAsync.when(
                data: (weather) {
                  _maybeShowAlert(
                    city: weather.cityName,
                    temp: weather.temperature,
                    description: weather.description,
                  );
                  final forecastAsync = ref.watch(
                    forecastByCityProvider(_currentCity),
                  );
                  return SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // картка поточної погоди
                        Center(
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    weather.description,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall
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
                        ),

                        const SizedBox(height: 12),

                        // прогноз на 5 днів
                        SizedBox(
                          height: 150,
                          child: forecastAsync.when(
                            data: (days) {
                              if (days.isEmpty) {
                                return const Center(
                                  child: Text('Прогноз недоступний'),
                                );
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Text(
                                      'Прогноз на 5 днів',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Expanded(
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      itemCount: days.length,
                                      separatorBuilder:
                                          (_, __) => const SizedBox(width: 8),
                                      itemBuilder: (context, index) {
                                        final day = days[index];
                                        final date =
                                            '${day.date.day.toString().padLeft(2, '0')}.'
                                            '${day.date.month.toString().padLeft(2, '0')}';

                                        return Container(
                                          width: 110,
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(
                                              0.06,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          padding: const EdgeInsets.all(8),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                date,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 40,
                                                child: Image.network(
                                                  _iconUrl(day.iconCode),
                                                  errorBuilder:
                                                      (_, __, ___) =>
                                                          const Icon(
                                                            Icons.cloud,
                                                          ),
                                                ),
                                              ),
                                              Text(
                                                '${day.minTemp.toStringAsFixed(0)}° / ${day.maxTemp.toStringAsFixed(0)}°',
                                              ),
                                              Text(
                                                day.description,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                            loading:
                                () => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                            error:
                                (e, st) => const Center(
                                  child: Text('Не вдалося завантажити прогноз'),
                                ),
                          ),
                        ),
                      ],
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
