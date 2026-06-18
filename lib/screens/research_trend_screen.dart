import 'package:flutter/material.dart';

import '../services/openalex_service.dart';
import '../state/research_controller.dart';
import '../widgets/analysis_results.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_message.dart';
import '../widgets/search_panel.dart';

class ResearchTrendScreen extends StatefulWidget {
  const ResearchTrendScreen({super.key, required this.openAlexService});

  final OpenAlexService openAlexService;

  @override
  State<ResearchTrendScreen> createState() => _ResearchTrendScreenState();
}

class _ResearchTrendScreenState extends State<ResearchTrendScreen> {
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
  late final ResearchController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ResearchController(openAlexService: widget.openAlexService);
  }

  @override
  void dispose() {
    _topicController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() => _controller.search(_topicController.text);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Trend Analyzer'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final analysis = _controller.analysis;
            final errorMessage = _controller.errorMessage;

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Research publication trends',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Search OpenAlex works by topic and review publication volume, citation activity, and recent top papers.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
                SearchPanel(
                  controller: _topicController,
                  sampleTopics: _sampleTopics,
                  isLoading: _controller.isLoading,
                  onTopicSelected: (topic) {
                    _topicController.text = topic;
                    _controller.search(topic);
                  },
                  onSearch: _search,
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 16),
                  ErrorMessage(message: errorMessage),
                ],
                const SizedBox(height: 20),
                if (_controller.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (analysis == null)
                  const EmptyState()
                else
                  AnalysisResults(analysis: analysis),
              ],
            );
          },
        ),
      ),
    );
  }
}
