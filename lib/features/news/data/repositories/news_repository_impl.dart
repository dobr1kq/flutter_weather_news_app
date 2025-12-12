import '../../domain/entities/news_article_entity.dart';
import '../../domain/repositories/news_repository.dart';
import '../datasources/news_remote_data_source.dart';

class NewsRepositoryImpl implements NewsRepository {
  final NewsRemoteDataSource remoteDataSource;

  NewsRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<NewsArticleEntity>> getTopHeadlines({
    String? countryCode,
    String? category,
  }) async {
    return await remoteDataSource.getTopHeadlines(
      countryCode: countryCode,
      category: category,
    );
  }
}
