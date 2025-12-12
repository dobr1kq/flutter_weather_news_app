class NewsArticleEntity {
  final String title;
  final String? description;
  final String? url;
  final String? imageUrl;
  final DateTime? publishedAt;
  final String? sourceName;

  const NewsArticleEntity({
    required this.title,
    this.description,
    this.url,
    this.imageUrl,
    this.publishedAt,
    this.sourceName,
  });
}
