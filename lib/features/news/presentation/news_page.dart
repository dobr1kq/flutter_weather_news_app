import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'news_providers.dart';

class NewsPage extends ConsumerWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(topHeadlinesProvider);

    return newsAsync.when(
      data: (articles) {
        if (articles.isEmpty) {
          return const Center(child: Text('Новин не знайдено'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: articles.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final article = articles[index];

            return Card(
              child: ListTile(
                leading:
                    article.imageUrl != null
                        ? SizedBox(
                          width: 60,
                          height: 60,
                          child: Image.network(
                            article.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => const Icon(Icons.article),
                          ),
                        )
                        : const Icon(Icons.article),
                title: Text(
                  article.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle:
                    article.description != null
                        ? Text(
                          article.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )
                        : null,
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Помилка завантаження новин: $e')),
    );
  }
}
