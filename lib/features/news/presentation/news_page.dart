import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'news_providers.dart';

class NewsPage extends ConsumerWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(topHeadlinesProvider);
    final selectedCategory = ref.watch(selectedNewsCategoryProvider);

    final categories = <String?, String>{
      null: 'Усі',
      'business': 'Бізнес',
      'entertainment': 'Розваги',
      'general': 'Загальні',
      'health': 'Здоров’я',
      'science': 'Наука',
      'sports': 'Спорт',
      'technology': 'Технології',
    };

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              const Text('Категорія:'),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButton<String?>(
                  isExpanded: true,
                  value: selectedCategory,
                  items:
                      categories.entries
                          .map(
                            (entry) => DropdownMenuItem<String?>(
                              value: entry.key,
                              child: Text(entry.value),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    ref.read(selectedNewsCategoryProvider.notifier).state =
                        value;
                    ref.refresh(topHeadlinesProvider);
                  },
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: newsAsync.when(
            data: (articles) {
              if (articles.isEmpty) {
                return const Center(child: Text('Новин не знайдено'));
              }

              return RefreshIndicator(
                onRefresh: () async {
                  ref.refresh(topHeadlinesProvider);
                  await Future.delayed(const Duration(milliseconds: 300));
                },
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  itemCount: articles.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final article = articles[index];

                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () async {
                          final url = article.url;
                          if (url == null) return;
                          final uri = Uri.tryParse(url);
                          if (uri == null) return;
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (article.imageUrl != null)
                              AspectRatio(
                                aspectRatio: 16 / 9,
                                child: Image.network(
                                  article.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (_, __, ___) => Container(
                                        color: Colors.grey.shade300,
                                        child: const Center(
                                          child: Icon(Icons.article),
                                        ),
                                      ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (article.sourceName != null)
                                    Text(
                                      article.sourceName!,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelMedium?.copyWith(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  if (article.sourceName != null)
                                    const SizedBox(height: 4),
                                  Text(
                                    article.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  if (article.description != null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      article.description!,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  if (article.publishedAt != null)
                                    Text(
                                      _formatDate(article.publishedAt!),
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.labelSmall,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (e, st) =>
                    Center(child: Text('Помилка завантаження новин: $e')),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.'
        '${dt.month.toString().padLeft(2, '0')}.'
        '${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}
