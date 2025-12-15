import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_weather_news_app/main.dart';
import 'helpers/test_di.dart';

void main() {
  setUpAll(() async {
    await setupTestDependencies();
  });

  testWidgets('MainPage: має таби і перемикається', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: MainPage())),
    );

    expect(find.byType(BottomNavigationBar), findsOneWidget);

    expect(find.text('Погода'), findsWidgets);

    await tester.tap(find.text('Новини'));
    await tester.pumpAndSettle();

    expect(find.text('Новини'), findsWidgets);
  });
}
