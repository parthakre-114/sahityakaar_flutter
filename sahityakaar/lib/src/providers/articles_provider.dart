import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    final response = await Supabase.instance.client
        .from('articles')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
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
