import 'package:flutter/material.dart';

import '../models/research_analysis.dart';
import 'metric_tile.dart';
import 'publication_tile.dart';
import 'publication_trend_chart.dart';

class AnalysisResults extends StatelessWidget {
  const AnalysisResults({super.key, required this.analysis});

  final ResearchAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final yearlyCounts = analysis.chronologicalPublicationCounts;

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
        if (yearlyCounts.isNotEmpty) ...[
          Text(
            'Publication activity over time',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          PublicationTrendChart(yearlyCounts: yearlyCounts),
          const SizedBox(height: 20),
        ],
        Text(
          'Top cited publications',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        for (final publication in analysis.publications.take(8))
          PublicationTile(publication: publication),
      ],
    );
  }
}
