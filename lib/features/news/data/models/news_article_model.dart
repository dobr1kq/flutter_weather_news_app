import '../../domain/entities/news_article_entity.dart';

class NewsArticleModel extends NewsArticleEntity {
  const NewsArticleModel({
    required super.title,
    super.description,
    super.url,
    super.imageUrl,
    super.publishedAt,
    super.sourceName,
  });

  factory NewsArticleModel.fromJson(Map<String, dynamic> json) {
    return NewsArticleModel(
      title: json['title'] as String? ?? 'No title',
      description: json['description'] as String?,
      url: json['url'] as String?,
      imageUrl: json['urlToImage'] as String?,
      publishedAt:
          json['publishedAt'] != null
              ? DateTime.tryParse(json['publishedAt'] as String)
              : null,
      sourceName: json['source']?['name'] as String?,
    );
  }
}
