import 'package:flutter/material.dart';

import '../models/research_analysis.dart';
import '../state/research_controller.dart';
import '../widgets/author_contribution_list.dart';
import '../widgets/journal_contribution_list.dart';
import '../widgets/metric_tile.dart';
import '../widgets/publication_trend_chart.dart';

class TrendAnalysisScreen extends StatelessWidget {
  const TrendAnalysisScreen({super.key, required this.controller});

  final ResearchController controller;

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
              'Trend analysis',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              analysis == null
                  ? 'Search for a topic to view publication activity over time.'
                  : 'Publication volume and citation indicators for "${analysis.topic}".',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            if (controller.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (analysis == null)
              const _TrendEmptyState()
            else
              _TrendContent(analysis: analysis),
          ],
        );
      },
    );
  }
}

class _TrendContent extends StatelessWidget {
  const _TrendContent({required this.analysis});

  final ResearchAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final yearlyCounts = analysis.chronologicalPublicationCounts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 720;
            return GridView.count(
              crossAxisCount: isWide ? 4 : 2,
              childAspectRatio: isWide ? 2.05 : 1.35,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                MetricTile(
                  label: 'Total citations',
                  value: analysis.totalCitations.toString(),
                  icon: Icons.format_quote_outlined,
                ),
                MetricTile(
                  label: 'Avg. citations',
                  value: analysis.averageCitations.toStringAsFixed(1),
                  icon: Icons.equalizer_outlined,
                ),
                MetricTile(
                  label: 'Newest year',
                  value: analysis.newestYear?.toString() ?? 'N/A',
                  icon: Icons.event_available_outlined,
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
        if (yearlyCounts.isEmpty)
          const _TrendEmptyState()
        else ...[
          PublicationTrendChart(yearlyCounts: yearlyCounts),
          const SizedBox(height: 20),
          Text(
            'Yearly publication volume',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _YearlyVolumeTable(yearlyCounts: yearlyCounts.reversed.toList()),
          if (analysis.journalPublicationCounts.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'Journal publication contributors',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            JournalContributionList(
              journalCounts: analysis.journalPublicationCounts,
            ),
          ],
          if (analysis.authorPublicationCounts.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'Author publication contributors',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            AuthorContributionList(
              authorCounts: analysis.authorPublicationCounts,
            ),
          ],
        ],
      ],
    );
  }
}

class _YearlyVolumeTable extends StatelessWidget {
  const _YearlyVolumeTable({required this.yearlyCounts});

  final List<MapEntry<int, int>> yearlyCounts;

  @override
  Widget build(BuildContext context) {
    final maxCount = yearlyCounts
        .map((entry) => entry.value)
        .fold<int>(0, (best, count) => count > best ? count : best);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            for (final entry in yearlyCounts.take(12))
              _YearVolumeRow(
                year: entry.key,
                count: entry.value,
                maxCount: maxCount,
              ),
          ],
        ),
      ),
    );
  }
}

class _YearVolumeRow extends StatelessWidget {
  const _YearVolumeRow({
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
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          SizedBox(width: 52, child: Text('$year')),
          Expanded(
            child: LinearProgressIndicator(
              minHeight: 10,
              value: ratio,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(width: 56, child: Text('$count', textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}

class _TrendEmptyState extends StatelessWidget {
  const _TrendEmptyState();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text('Trend analysis will appear after a successful search.'),
        ),
      ),
    );
  }
}
