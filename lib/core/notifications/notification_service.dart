import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._internal();

  static final NotificationService _instance = NotificationService._internal();
  static NotificationService get instance => _instance;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(android: androidInit);

    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  Future<void> showWeatherAlert({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'weather_alerts',
      'Weather Alerts',
      channelDescription: 'Сповіщення про небезпечні погодні умови',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _plugin.show(
      0, // id нотифікації
      title,
      body,
      notificationDetails,
    );
  }
}
