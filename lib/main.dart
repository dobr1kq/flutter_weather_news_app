import 'package:flutter/material.dart';

void main() {
  runApp(const WeatherNewsApp());
}

class WeatherNewsApp extends StatelessWidget {
  const WeatherNewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather & News',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
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
    final pages = [
      const Center(child: Text('Weather screen (поки заглушка)')),
      const Center(child: Text('News screen (поки заглушка)')),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Weather & News App')),
      body: pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.cloud), label: 'Weather'),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: 'News'),
        ],
      ),
    );
  }
}
