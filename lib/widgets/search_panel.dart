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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => onSearch(),
                    decoration: const InputDecoration(
                      labelText: 'Research topic',
                      hintText: 'Enter any research topic',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: isLoading ? null : onSearch,
                  icon: const Icon(Icons.analytics_outlined),
                  label: const Text('Analyze'),
                ),
              ],
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
