import 'package:flutter/material.dart';

import 'openalex_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.openAlexService});

  final OpenAlexService? openAlexService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Journal Trend Analyzer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF15616D),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        useMaterial3: true,
      ),
      home: ResearchTrendPage(
        openAlexService: openAlexService ?? OpenAlexService(),
      ),
    );
  }
}

class ResearchTrendPage extends StatefulWidget {
  const ResearchTrendPage({super.key, required this.openAlexService});

  final OpenAlexService openAlexService;

  @override
  State<ResearchTrendPage> createState() => _ResearchTrendPageState();
}

class _ResearchTrendPageState extends State<ResearchTrendPage> {
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
  ResearchAnalysis? _analysis;
  String? _error;
  bool _isLoading = false;

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) {
      setState(() {
        _error = 'Enter a research topic to search.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final analysis = await widget.openAlexService.fetchResearchData(topic);
      if (!mounted) {
        return;
      }
      setState(() {
        _analysis = analysis;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final analysis = _analysis;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Trend Analyzer'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Research publication trends',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Search OpenAlex works by topic and review publication volume, citation activity, and recent top papers.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            _SearchPanel(
              controller: _topicController,
              sampleTopics: _sampleTopics,
              isLoading: _isLoading,
              onTopicSelected: (topic) {
                _topicController.text = topic;
                _search();
              },
              onSearch: _search,
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              _ErrorMessage(message: _error!),
            ],
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (analysis == null)
              const _EmptyState()
            else
              _AnalysisResults(analysis: analysis),
          ],
        ),
      ),
    );
  }
}

class _SearchPanel extends StatelessWidget {
  const _SearchPanel({
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

class _AnalysisResults extends StatelessWidget {
  const _AnalysisResults({required this.analysis});

  final ResearchAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final topYears = analysis.publicationsByYear.entries.take(6).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analysis for "${analysis.topic}"',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 720;
            return GridView.count(
              crossAxisCount: isWide ? 4 : 2,
              childAspectRatio: isWide ? 2.1 : 1.65,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _MetricTile(
                  label: 'Total works',
                  value: analysis.totalWorks.toString(),
                  icon: Icons.library_books_outlined,
                ),
                _MetricTile(
                  label: 'Loaded sample',
                  value: analysis.publicationCount.toString(),
                  icon: Icons.dataset_outlined,
                ),
                _MetricTile(
                  label: 'Avg. citations',
                  value: analysis.averageCitations.toStringAsFixed(1),
                  icon: Icons.format_quote_outlined,
                ),
                _MetricTile(
                  label: 'Busiest year',
                  value: analysis.busiestYear?.toString() ?? 'N/A',
                  icon: Icons.calendar_month_outlined,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        if (topYears.isNotEmpty) ...[
          Text(
            'Recent publication volume',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  for (final entry in topYears)
                    _YearBar(
                      year: entry.key,
                      count: entry.value,
                      maxCount: topYears
                          .map((year) => year.value)
                          .reduce((a, b) => a > b ? a : b),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
        Text(
          'Top cited publications',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        for (final publication in analysis.publications.take(8))
          _PublicationTile(publication: publication),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _YearBar extends StatelessWidget {
  const _YearBar({
    required this.year,
    required this.count,
    required this.maxCount,
  });

  final int year;
  final int count;
  final int maxCount;

  @override
  Widget build(BuildContext context) {
    final ratio = maxCount == 0 ? 0.0 : count / maxCount;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 48, child: Text('$year')),
          Expanded(
            child: LinearProgressIndicator(
              minHeight: 10,
              value: ratio,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(width: 32, child: Text('$count', textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}

class _PublicationTile extends StatelessWidget {
  const _PublicationTile({required this.publication});

  final Publication publication;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => PublicationDetailPage(publication: publication),
            ),
          );
        },
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(_yearBadge(publication.year)),
        ),
        title: Text(publication.title),
        subtitle: Text(
          [
            publication.authors.take(3).join(', '),
            publication.source,
            publication.year?.toString(),
            publication.type,
          ].whereType<String>().where((value) => value.isNotEmpty).join(' . '),
        ),
        isThreeLine: publication.authors.isNotEmpty,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              publication.citations.toString(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Text('cites'),
          ],
        ),
      ),
    );
  }

  String _yearBadge(int? year) {
    if (year == null) {
      return '--';
    }
    return year.toString().substring(0, 2);
  }
}

class PublicationDetailPage extends StatelessWidget {
  const PublicationDetailPage({super.key, required this.publication});

  final Publication publication;

  @override
  Widget build(BuildContext context) {
    final abstractText = publication.abstractText;

    return Scaffold(
      appBar: AppBar(title: const Text('Publication details')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              publication.title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _DetailChip(
                  icon: Icons.calendar_month_outlined,
                  label: publication.year?.toString() ?? 'Year unknown',
                ),
                _DetailChip(
                  icon: Icons.format_quote_outlined,
                  label: '${publication.citations} citations',
                ),
                _DetailChip(
                  icon: Icons.category_outlined,
                  label: publication.type,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _DetailSection(
              title: 'Authors',
              icon: Icons.people_outline,
              child: Text(publication.authorsLabel),
            ),
            _DetailSection(
              title: 'Journal',
              icon: Icons.menu_book_outlined,
              child: Text(publication.source),
            ),
            _DetailSection(
              title: 'DOI',
              icon: Icons.link_outlined,
              child: SelectableText(
                publication.doi?.isNotEmpty == true
                    ? publication.doi!
                    : 'Not available',
              ),
            ),
            _DetailSection(
              title: 'Abstract',
              icon: Icons.article_outlined,
              child: Text(
                abstractText?.isNotEmpty == true
                    ? abstractText!
                    : 'Abstract not available from OpenAlex for this publication.',
              ),
            ),
            if (publication.openAlexUrl.isNotEmpty)
              _DetailSection(
                title: 'OpenAlex',
                icon: Icons.public_outlined,
                child: SelectableText(publication.openAlexUrl),
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            DefaultTextStyle.merge(
              style: Theme.of(context).textTheme.bodyLarge,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text('Choose a topic or enter your own to begin.'),
        ),
      ),
    );
  }
}
