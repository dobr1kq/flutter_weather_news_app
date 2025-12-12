import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../core/di/service_locator.dart';
import '../domain/entities/news_article_entity.dart';
import '../domain/repositories/news_repository.dart';

final _newsRepositoryProvider = Provider<NewsRepository>((ref) {
  return sl<NewsRepository>();
});

final topHeadlinesProvider = FutureProvider<List<NewsArticleEntity>>((
  ref,
) async {
  final repo = ref.watch(_newsRepositoryProvider);
  final countryCode = dotenv.env['DEFAULT_COUNTRY_CODE'] ?? 'ua';

  return await repo.getTopHeadlines(countryCode: countryCode);
});
