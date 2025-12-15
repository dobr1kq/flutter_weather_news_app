import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_weather_news_app/features/news/data/datasources/news_remote_data_source.dart';
import 'package:flutter_weather_news_app/features/news/data/models/news_article_model.dart';
import 'package:flutter_weather_news_app/features/news/data/repositories/news_repository_impl.dart';

class MockNewsRemoteDataSource extends Mock implements NewsRemoteDataSource {}

void main() {
  late MockNewsRemoteDataSource mockDs;
  late NewsRepositoryImpl repo;

  setUp(() {
    mockDs = MockNewsRemoteDataSource();
    repo = NewsRepositoryImpl(mockDs);
  });

  group('NewsRepositoryImpl', () {
    test('getTopHeadlines повертає список статей з dataSource', () async {
      final models = <NewsArticleModel>[
        NewsArticleModel(
          title: 'Title 1',
          description: 'Desc',
          url: 'https://example.com',
          imageUrl: null,
          publishedAt: DateTime(2025, 1, 1),
          sourceName: 'Example',
        ),
      ];

      when(
        () => mockDs.getTopHeadlines(countryCode: 'us', category: 'sports'),
      ).thenAnswer((_) async => models);

      final result = await repo.getTopHeadlines(
        countryCode: 'us',
        category: 'sports',
      );

      expect(result.length, 1);
      expect(result.first.title, 'Title 1');

      verify(
        () => mockDs.getTopHeadlines(countryCode: 'us', category: 'sports'),
      ).called(1);
      verifyNoMoreInteractions(mockDs);
    });
  });
}
