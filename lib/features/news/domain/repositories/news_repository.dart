import '../entities/news_article_entity.dart';

abstract class NewsRepository {
  Future<List<NewsArticleEntity>> getTopHeadlines({
    String? countryCode,
    String? category,
  });
}
