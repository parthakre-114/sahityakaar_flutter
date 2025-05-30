// Import necessary packages and widgets
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/expandable_editor.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../article/article_detail_screen.dart';
import '../../providers/articles_provider.dart';

/// CategoryScreen displays articles filtered by a specific category.
/// It shows articles in a 2-column grid layout with a floating editor
/// for creating new articles.
class CategoryScreen extends ConsumerWidget {
  final String category;

  const CategoryScreen({super.key, required this.category});

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articlesAsync = ref.watch(articlesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(category)),
      body: Column(
        children: [
          // Editor at the top
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: ExpandableEditor(),
          ),

          // Articles grid below
          Expanded(
            child: articlesAsync.when(
              data: (articles) {
                final categoryArticles = articles
                    .where((article) => article['category'] == category)
                    .toList();

                if (categoryArticles.isEmpty) {
                  return Center(
                    child: Text(
                      'No $category articles yet.\nBe the first to write one!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 150,
                  ),
                  itemCount: categoryArticles.length,
                  itemBuilder: (context, index) {
                    final article = categoryArticles[index];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ArticleDetailScreen(
                            article: article,
                            category: category,
                          ),
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.teal.shade200.withOpacity(0.3),
                              Colors.blue.shade100.withOpacity(0.2),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.teal.shade200.withOpacity(0.3),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.teal.shade200.withOpacity(0.2),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                article['content'] as String,
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.teal.shade900,
                                  height: 1.4,
                                ),
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  const Icon(Icons.access_time, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatDate(
                                      article['created_at'] as String,
                                    ),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNav(),
    );
  }
}
