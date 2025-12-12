import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/news_article_model.dart';

abstract class NewsRemoteDataSource {
  Future<List<NewsArticleModel>> getTopHeadlines({
    String? countryCode,
    String? category,
  });
}

class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  final Dio dio;

  NewsRemoteDataSourceImpl(this.dio);

  @override
  Future<List<NewsArticleModel>> getTopHeadlines({
    String? countryCode,
    String? category,
  }) async {
    final apiKey = dotenv.env['NEWS_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('NEWS_API_KEY is not set in .env');
    }

    final country = countryCode ?? dotenv.env['DEFAULT_COUNTRY_CODE'] ?? 'ua';

    final response = await dio.get(
      'https://newsapi.org/v2/top-headlines',
      queryParameters: {
        'country': country,
        if (category != null) 'category': category,
        'apiKey': apiKey,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final articles =
        (data['articles'] as List<dynamic>).cast<Map<String, dynamic>>();

    return articles
        .map((articleJson) => NewsArticleModel.fromJson(articleJson))
        .toList();
  }
}
