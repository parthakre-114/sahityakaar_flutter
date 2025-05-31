import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/articles_provider.dart';
import '../providers/labels_provider.dart';

class LabelFilter extends ConsumerWidget {
  const LabelFilter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allLabelsAsync = ref.watch(allLabelsProvider);
    final selectedLabels = ref.watch(selectedLabelsProvider);

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: allLabelsAsync.when(
        data: (allLabels) => allLabels.isEmpty
            ? const Center(child: Text('No labels created yet'))
            : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: allLabels.length,
                itemBuilder: (context, index) {
                  final label = allLabels[index];
                  final isSelected = selectedLabels.contains(label['name']);

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(label['name']),
                      selected: isSelected,
                      selectedColor: Colors.teal.shade100,
                      checkmarkColor: Colors.teal.shade700,
                      onSelected: (selected) {
                        if (selected) {
                          ref.read(selectedLabelsProvider.notifier).state = {
                            ...selectedLabels,
                            label['name'],
                          };
                        } else {
                          final newLabels = selectedLabels.toSet();
                          newLabels.remove(label['name']);
                          ref.read(selectedLabelsProvider.notifier).state =
                              newLabels;
                        }
                        // Refresh articles with new filter
                        ref.read(articlesProvider.notifier).refreshArticles();
                      },
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Error loading labels: $error',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
