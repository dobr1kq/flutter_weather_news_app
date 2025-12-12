import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../core/di/service_locator.dart';
import '../domain/entities/news_article_entity.dart';
import '../domain/repositories/news_repository.dart';

final _newsRepositoryProvider = Provider<NewsRepository>((ref) {
  return sl<NewsRepository>();
});

// null = усі категорії
final selectedNewsCategoryProvider = StateProvider<String?>((ref) => null);

final topHeadlinesProvider = FutureProvider<List<NewsArticleEntity>>((
  ref,
) async {
  final repo = ref.watch(_newsRepositoryProvider);
  final countryCode = dotenv.env['DEFAULT_COUNTRY_CODE'] ?? 'us';

  final category = ref.watch(selectedNewsCategoryProvider);

  return await repo.getTopHeadlines(
    countryCode: countryCode,
    category: category,
  );
});
