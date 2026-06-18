import 'package:flutter/material.dart';

class SearchPanel extends StatelessWidget {
  const SearchPanel({
    super.key,
    required this.controller,
    required this.sampleTopics,
    required this.isLoading,
    required this.onTopicSelected,
    required this.onSearch,
  });

  final TextEditingController controller;
  final List<String> sampleTopics;
  final bool isLoading;
  final ValueChanged<String> onTopicSelected;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 560;
                final topicField = TextField(
                  key: const ValueKey('research-topic-field'),
                  controller: controller,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => onSearch(),
                  decoration: const InputDecoration(
                    labelText: 'Research topic',
                    hintText: 'Enter any research topic',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                );
                final analyzeButton = FilledButton.icon(
                  key: const ValueKey('analyze-topic-button'),
                  onPressed: isLoading ? null : onSearch,
                  icon: const Icon(Icons.analytics_outlined),
                  label: const Text('Analyze'),
                );

                if (isCompact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      topicField,
                      const SizedBox(height: 12),
                      analyzeButton,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: topicField),
                    const SizedBox(width: 12),
                    analyzeButton,
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final topic in sampleTopics)
                  ActionChip(
                    label: Text(topic),
                    avatar: const Icon(Icons.topic_outlined, size: 18),
                    onPressed: isLoading ? null : () => onTopicSelected(topic),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
