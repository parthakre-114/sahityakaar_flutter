import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Provider for the currently selected labels filter
final selectedLabelsProvider = StateProvider<Set<String>>((ref) => {});

final articlesProvider =
    AsyncNotifierProvider<ArticlesNotifier, List<Map<String, dynamic>>>(() {
      return ArticlesNotifier();
    });

class ArticlesNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    return _fetchArticles();
  }

  Future<List<Map<String, dynamic>>> _fetchArticles() async {
    final selectedLabels = ref.read(selectedLabelsProvider);

    if (selectedLabels.isEmpty) {
      final response = await Supabase.instance.client
          .from('articles')
          .select()
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } else {
      // Fetch articles that have any of the selected labels
      final response = await Supabase.instance.client
          .from('articles')
          .select('''
            *,
            article_labels!inner (
              labels!inner (
                name
              )
            )
          ''')
          .or(
            selectedLabels
                .map((label) => 'article_labels.labels.name.eq.$label')
                .join(','),
          )
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    }
  }

  Future<void> updateArticle(String id, String content) async {
    // Optimistically update the UI
    state = AsyncData(
      state.value!.map((article) {
        if (article['id'] == id) {
          return {...article, 'content': content};
        }
        return article;
      }).toList(),
    );

    // Perform the actual update
    await Supabase.instance.client
        .from('articles')
        .update({'content': content})
        .eq('id', id);
  }

  Future<void> deleteArticle(String id) async {
    // Optimistically update the UI
    state = AsyncData(
      state.value!.where((article) => article['id'] != id).toList(),
    );

    // Perform the actual delete
    await Supabase.instance.client.from('articles').delete().eq('id', id);
  }

  Future<void> refreshArticles() async {
    state = const AsyncLoading();
    state = AsyncData(await _fetchArticles());
  }
}
