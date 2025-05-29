import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/edit_article_editor.dart';
import '../../providers/articles_provider.dart';

/// Provider to control the article editing state
final isEditingProvider = StateProvider<bool>((ref) => false);

/// ArticleDetailScreen displays the full content of an article
/// with additional details like creation time and category.
class ArticleDetailScreen extends ConsumerWidget {
  final Map<String, dynamic> article;
  final String category;

  const ArticleDetailScreen({
    super.key,
    required this.article,
    required this.category,
  });

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute}';
  }

  /// Toggles the edit mode
  void _toggleEditMode(WidgetRef ref) {
    final isEditing = ref.read(isEditingProvider.notifier);
    isEditing.state = !isEditing.state;
  }

  /// Shows confirmation dialog before deleting article
  Future<void> _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Article'),
        content: const Text(
          'Are you sure you want to delete this article? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        await ref.read(articlesProvider.notifier).deleteArticle(article['id']);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Article deleted successfully')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error deleting article: $e')));
        }
      }
    }
  }

  /// Handles actions from the more options menu
  Future<void> _handleMenuAction(BuildContext context, String value) async {
    switch (value) {
      case 'share':
        // TODO: Implement sharing functionality
        break;
      case 'bookmark':
        try {
          await Supabase.instance.client.from('bookmarks').insert({
            'article_id': article['id'],
            'user_id': Supabase.instance.client.auth.currentUser?.id,
            'created_at': DateTime.now().toIso8601String(),
          });

          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Article bookmarked')));
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error bookmarking article: $e')),
            );
          }
        }
        break;
      case 'report':
        _showReportDialog(context);
        break;
    }
  }

  /// Shows dialog for reporting inappropriate content
  Future<void> _showReportDialog(BuildContext context) async {
    final TextEditingController reasonController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Article'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for reporting this article:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter reason...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, reasonController.text),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && context.mounted) {
      try {
        await Supabase.instance.client.from('reports').insert({
          'article_id': article['id'],
          'reporter_id': Supabase.instance.client.auth.currentUser?.id,
          'reason': result,
          'created_at': DateTime.now().toIso8601String(),
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Report submitted. Thank you for helping us maintain quality content.',
              ),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error submitting report: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditing = ref.watch(isEditingProvider);
    final articleState = ref.watch(articlesProvider);

    return articleState.when(
      data: (articles) {
        final currentArticle = articles.firstWhere(
          (a) => a['id'] == article['id'],
          orElse: () => article,
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(category),
            actions: [
              // Edit button
              IconButton(
                icon: Icon(isEditing ? Icons.close : Icons.edit),
                onPressed: () => _toggleEditMode(ref),
              ),
              // Delete button
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _showDeleteConfirmation(context, ref),
              ),
              // More options menu
              PopupMenuButton<String>(
                onSelected: (value) => _handleMenuAction(context, value),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'share',
                    child: Row(
                      children: [
                        Icon(Icons.share),
                        SizedBox(width: 8),
                        Text('Share'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'bookmark',
                    child: Row(
                      children: [
                        Icon(Icons.bookmark_border),
                        SizedBox(width: 8),
                        Text('Save to bookmarks'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'report',
                    child: Row(
                      children: [
                        Icon(Icons.flag),
                        SizedBox(width: 8),
                        Text('Report'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: isEditing
              ? EditArticleEditor(
                  initialContent: currentArticle['content'] as String,
                  category: category,
                  onClose: () => _toggleEditMode(ref),
                  onSaved: (content) async {
                    try {
                      await ref
                          .read(articlesProvider.notifier)
                          .updateArticle(currentArticle['id'], content);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Article updated successfully'),
                          ),
                        );
                        _toggleEditMode(ref);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error updating article: $e')),
                        );
                      }
                    }
                  },
                )
              : SingleChildScrollView(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.teal.shade50, Colors.blue.shade50],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.teal.shade200.withOpacity(0.2),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Category tag
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.teal.shade100.withOpacity(
                                      0.3,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      color: Colors.teal.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Article content
                                Text(
                                  currentArticle['content'] as String,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade800,
                                    height: 1.8,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Creation time
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Created on ${_formatDate(currentArticle['created_at'] as String)}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) =>
          Scaffold(body: Center(child: Text('Error: $error'))),
    );
  }
}
