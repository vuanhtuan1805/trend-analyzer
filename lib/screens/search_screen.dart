import 'package:flutter/material.dart';

import '../state/research_controller.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_message.dart';
import '../widgets/publication_tile.dart';
import '../widgets/search_panel.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.controller});

  final ResearchController controller;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const _sampleTopics = [
    'Artificial Intelligence',
    'Software Engineering',
    'Data Science',
    'Cybersecurity',
    'Internet of Things',
    'Blockchain',
  ];

  final _topicController = TextEditingController(
    text: 'Artificial Intelligence',
  );

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _search() => widget.controller.search(_topicController.text);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final analysis = widget.controller.analysis;
        final errorMessage = widget.controller.errorMessage;

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Search publications',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Find OpenAlex publications by topic, then open individual papers for metadata, authors, source details, DOI, and abstract text.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            SearchPanel(
              controller: _topicController,
              sampleTopics: _sampleTopics,
              isLoading: widget.controller.isLoading,
              onTopicSelected: (topic) {
                _topicController.text = topic;
                widget.controller.search(topic);
              },
              onSearch: _search,
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 16),
              ErrorMessage(message: errorMessage),
            ],
            const SizedBox(height: 20),
            if (widget.controller.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (analysis == null)
              const EmptyState()
            else ...[
              Text(
                'Top cited publications for "${analysis.topic}"',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              for (final publication in analysis.publications)
                PublicationTile(publication: publication),
            ],
          ],
        );
      },
    );
  }
}
