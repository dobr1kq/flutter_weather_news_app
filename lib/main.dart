import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/notifications/notification_service.dart';
import 'core/di/service_locator.dart';
import 'features/weather/presentation/weather_page.dart';
import 'features/news/presentation/news_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await initDependencies();
  await NotificationService.instance.init();

  runApp(const ProviderScope(child: WeatherNewsApp()));
}

class WeatherNewsApp extends StatelessWidget {
  const WeatherNewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.blue,
    );

    return MaterialApp(
      title: 'Weather & News',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: baseTheme.copyWith(
        cardTheme: CardTheme(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = const [WeatherPage(), NewsPage()];

    final titles = ['Погода', 'Новини'];

    return Scaffold(
      appBar: AppBar(title: Text(titles[_index])),
      body: pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.cloud), label: 'Погода'),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: 'Новини'),
        ],
      ),
    );
  }
}
