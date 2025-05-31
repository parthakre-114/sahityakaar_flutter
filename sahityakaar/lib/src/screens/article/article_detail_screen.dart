import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/edit_article_editor.dart';
import '../../providers/articles_provider.dart';
import '../../providers/labels_provider.dart';

/// Provider to control the article editing state
final isEditingProvider = StateProvider<bool>((ref) => false);

/// ArticleDetailScreen displays the full content of an article
class ArticleDetailScreen extends ConsumerWidget {
  final Map<String, dynamic> article;
  final String category;

  const ArticleDetailScreen({
    super.key,
    required this.article,
    required this.category,
  });

  /// Toggles the edit mode
  void _toggleEditMode(WidgetRef ref) {
    ref.read(isEditingProvider.notifier).state = !ref.read(isEditingProvider);
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
  Future<void> _handleMenuAction(
    BuildContext context,
    WidgetRef ref,
    String action,
  ) async {
    switch (action) {
      case 'labels':
        await _showLabelDialog(context, ref);
        break;
      case 'delete':
        await _showDeleteConfirmation(context, ref);
        break;
      case 'report':
        await _showReportDialog(context);
        break;
      case 'edit':
        _toggleEditMode(ref);
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

  /// Shows dialog for managing article labels
  Future<void> _showLabelDialog(BuildContext context, WidgetRef ref) async {
    final TextEditingController newLabelController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Manage Labels'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Add new label section
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: newLabelController,
                        decoration: const InputDecoration(
                          hintText: 'Create new label...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () async {
                        final newLabel = newLabelController.text.trim();
                        if (newLabel.isEmpty) return;

                        try {
                          debugPrint('Creating new label: $newLabel');

                          // First create the label
                          final labelResponse = await Supabase.instance.client
                              .from('labels')
                              .insert({'name': newLabel})
                              .select()
                              .single();

                          debugPrint('Label created: $labelResponse');

                          // Then create the article-label relationship
                          await Supabase.instance.client
                              .from('article_labels')
                              .insert({
                                'article_id': article['id'],
                                'label_id': labelResponse['id'],
                              });

                          // Clear the input and refresh labels
                          if (context.mounted) {
                            ref.invalidate(allLabelsProvider);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Label created and added to article',
                                ),
                              ),
                            );
                            // Close the dialog after successful creation
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          debugPrint('Error creating label: $e');
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error creating label: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Existing labels
                Consumer(
                  builder: (context, ref, _) {
                    final allLabelsAsync = ref.watch(allLabelsProvider);

                    return allLabelsAsync.when(
                      data: (allLabels) => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: allLabels.map((label) {
                          return FutureBuilder<bool>(
                            future: Supabase.instance.client
                                .from('article_labels')
                                .select()
                                .eq('article_id', article['id'])
                                .eq('label_id', label['id'])
                                .then((result) => result.isNotEmpty),
                            builder: (context, snapshot) {
                              final isSelected = snapshot.data ?? false;
                              return FilterChip(
                                label: Text(label['name']),
                                selected: isSelected,
                                onSelected: (selected) async {
                                  try {
                                    if (selected) {
                                      await Supabase.instance.client
                                          .from('article_labels')
                                          .insert({
                                            'article_id': article['id'],
                                            'label_id': label['id'],
                                          });
                                    } else {
                                      await Supabase.instance.client
                                          .from('article_labels')
                                          .delete()
                                          .eq('article_id', article['id'])
                                          .eq('label_id', label['id']);
                                    }
                                    ref.invalidate(allLabelsProvider);
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Error updating label: $e',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                              );
                            },
                          );
                        }).toList(),
                      ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, st) => Text('Error loading labels: $e'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditing = ref.watch(isEditingProvider);
    final labelsAsync = ref.watch(allLabelsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(article['title'] ?? 'Article'),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.close : Icons.edit),
            onPressed: () => _toggleEditMode(ref),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, ref, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'labels',
                child: Text('Manage Labels'),
              ),
              const PopupMenuItem(
                value: 'report',
                child: Text('Report Article'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete Article'),
              ),
            ],
          ),
        ],
      ),
      body: isEditing
          ? EditArticleEditor(
              initialContent: article['content'] as String,
              category: category,
              onClose: () => _toggleEditMode(ref),
              onSaved: (content) async {
                try {
                  await ref
                      .read(articlesProvider.notifier)
                      .updateArticle(article['id'], content);
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
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.teal.shade50.withOpacity(0.3),
                    Colors.blue.shade50.withOpacity(0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Article content with larger text and styling
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 24,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Text(
                        article['content'] ?? '',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 18,
                          height: 1.8,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Labels section with a title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Labels',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: 12),
                    labelsAsync.when(
                      data: (labels) {
                        final articleLabels = labels.where((label) {
                          return label['articles']?.any(
                                (a) => a['id'] == article['id'],
                              ) ??
                              false;
                        }).toList();

                        return articleLabels.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Text('No labels yet'),
                              )
                            : Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: articleLabels.map((label) {
                                    return Chip(
                                      label: Text(label['name']),
                                      deleteIcon: const Icon(
                                        Icons.close,
                                        size: 18,
                                      ),
                                      onDeleted: () async {
                                        try {
                                          await Supabase.instance.client
                                              .from('article_labels')
                                              .delete()
                                              .match({
                                                'article_id': article['id'],
                                                'label_id': label['id'],
                                              });
                                          ref.invalidate(allLabelsProvider);
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Error removing label: $e',
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                    );
                                  }).toList(),
                                ),
                              );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, st) => Text('Error loading labels: $e'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

/* New Design (for reference)
  body: isEditing
      ? EditArticleEditor(...)  // Same as above
      : SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Labels section
              labelsAsync.when(
                data: (labels) => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: labels.map((label) {
                    return Chip(
                      label: Text(label['name']),
                      onDeleted: () async {
                        try {
                          await Supabase.instance.client
                              .from('article_labels')
                              .delete()
                              .match({
                                'article_id': article['id'],
                                'label_id': label['id']
                              });
                          ref.invalidate(allLabelsProvider);
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error removing label: $e'),
                              ),
                            );
                          }
                        }
                      },
                    );
                  }).toList(),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Text('Error loading labels: $e'),
              ),
              const SizedBox(height: 16),
              // Article content
              Text(
                article['content'] ?? '',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
*/
