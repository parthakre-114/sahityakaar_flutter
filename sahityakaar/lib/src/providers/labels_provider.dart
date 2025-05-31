import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for all available labels
final allLabelsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final response = await Supabase.instance.client
      .from('labels')
      .select()
      .order('name');
  return List<Map<String, dynamic>>.from(response);
});

/// Provider for article-specific labels
final articleLabelsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      articleId,
    ) async {
      final response = await Supabase.instance.client
          .from('article_labels')
          .select('labels(id, name)')
          .eq('article_id', articleId);
      return List<Map<String, dynamic>>.from(response);
    });
