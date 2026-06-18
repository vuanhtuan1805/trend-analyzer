import 'package:flutter/material.dart';

import '../models/research_analysis.dart';
import '../models/publication.dart';
import '../state/research_controller.dart';
import '../widgets/metric_tile.dart';
import '../widgets/publication_tile.dart';

class ResearchDashboardScreen extends StatelessWidget {
  const ResearchDashboardScreen({
    super.key,
    required this.controller,
    required this.onOpenSearch,
    required this.onOpenTrends,
  });

  final ResearchController controller;
  final VoidCallback onOpenSearch;
  final VoidCallback onOpenTrends;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final analysis = controller.analysis;

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Research dashboard',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              analysis == null
                  ? 'Run a topic search to populate the dashboard with publication volume, citation activity, and top papers.'
                  : 'Snapshot for "${analysis.topic}" based on the latest OpenAlex search results.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            _DashboardActions(
              hasAnalysis: analysis != null,
              onOpenSearch: onOpenSearch,
              onOpenTrends: onOpenTrends,
            ),
            const SizedBox(height: 20),
            if (analysis == null)
              const _DashboardEmptyState()
            else
              _DashboardContent(analysis: analysis),
          ],
        );
      },
    );
  }
}

class _DashboardActions extends StatelessWidget {
  const _DashboardActions({
    required this.hasAnalysis,
    required this.onOpenSearch,
    required this.onOpenTrends,
  });

  final bool hasAnalysis;
  final VoidCallback onOpenSearch;
  final VoidCallback onOpenTrends;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        FilledButton.icon(
          onPressed: onOpenSearch,
          icon: const Icon(Icons.search_outlined),
          label: Text(hasAnalysis ? 'Search another topic' : 'Start search'),
        ),
        OutlinedButton.icon(
          onPressed: hasAnalysis ? onOpenTrends : null,
          icon: const Icon(Icons.stacked_line_chart_outlined),
          label: const Text('View trends'),
        ),
      ],
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.analysis});

  final ResearchAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final topPublication = analysis.publications.isEmpty
        ? null
        : analysis.publications.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 900
                ? 4
                : constraints.maxWidth >= 560
                ? 2
                : 1;
            return GridView.count(
              crossAxisCount: columns,
              childAspectRatio: columns == 1 ? 3.2 : 1.55,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                MetricTile(
                  label: 'Total works',
                  value: analysis.totalWorks.toString(),
                  icon: Icons.library_books_outlined,
                ),
                MetricTile(
                  label: 'Loaded sample',
                  value: analysis.publicationCount.toString(),
                  icon: Icons.dataset_outlined,
                ),
                MetricTile(
                  label: 'Avg. citations',
                  value: analysis.averageCitations.toStringAsFixed(1),
                  icon: Icons.format_quote_outlined,
                ),
                MetricTile(
                  label: 'Busiest year',
                  value: analysis.busiestYear?.toString() ?? 'N/A',
                  icon: Icons.calendar_month_outlined,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        _DashboardSummaryCard(
          analysis: analysis,
          topPublication: topPublication,
        ),
        const SizedBox(height: 20),
        Text(
          'Recent top papers',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        for (final publication in analysis.publications.take(5))
          PublicationTile(publication: publication),
      ],
    );
  }
}

class _DashboardSummaryCard extends StatelessWidget {
  const _DashboardSummaryCard({
    required this.analysis,
    required this.topPublication,
  });

  final ResearchAnalysis analysis;
  final Publication? topPublication;

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
            Text(
              'Topic pulse',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _SummaryChip(
                  icon: Icons.auto_graph_outlined,
                  label:
                      '${analysis.publicationsByYear.length} active publication years',
                ),
                _SummaryChip(
                  icon: Icons.event_available_outlined,
                  label: analysis.newestYear == null
                      ? 'Newest year unknown'
                      : 'Newest year ${analysis.newestYear}',
                ),
                _SummaryChip(
                  icon: Icons.workspace_premium_outlined,
                  label: topPublication == null
                      ? 'No top paper loaded'
                      : '${topPublication!.citations} citations on top paper',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.icon, required this.label});

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

class _DashboardEmptyState extends StatelessWidget {
  const _DashboardEmptyState();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text('Search for a topic to build the dashboard.'),
        ),
      ),
    );
  }
}
