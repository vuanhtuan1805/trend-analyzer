import 'package:flutter/material.dart';

import '../models/research_analysis.dart';
import '../state/research_controller.dart';
import '../widgets/author_contribution_list.dart';
import '../widgets/journal_contribution_list.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DashboardInsights(analysis: analysis),
        const SizedBox(height: 20),
        Text(
          'Most influential publications',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        for (final publication in analysis.influentialPublications.take(5))
          PublicationTile(publication: publication),
        if (analysis.journalPublicationCounts.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            'Top contributing journals',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          JournalContributionList(
            journalCounts: analysis.journalPublicationCounts,
            limit: 6,
          ),
        ],
        if (analysis.authorPublicationCounts.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            'Top publishing authors',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          AuthorContributionList(
            authorCounts: analysis.authorPublicationCounts,
            limit: 6,
          ),
        ],
      ],
    );
  }
}

class _DashboardInsights extends StatelessWidget {
  const _DashboardInsights({required this.analysis});

  final ResearchAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final topJournal = analysis.topJournal;
    final topAuthor = analysis.topAuthor;
    final mostInfluentialPaper = analysis.mostInfluentialPublication;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key insights',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 1000
                ? 3
                : constraints.maxWidth >= 640
                ? 2
                : 1;

            return GridView.count(
              crossAxisCount: columns,
              childAspectRatio: columns == 1 ? 3.4 : 2.1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _InsightTile(
                  icon: Icons.library_books_outlined,
                  label: 'Total publications',
                  value: analysis.totalWorks.toString(),
                ),
                _InsightTile(
                  icon: Icons.format_quote_outlined,
                  label: 'Average citation count',
                  value: analysis.averageCitations.toStringAsFixed(1),
                ),
                _InsightTile(
                  icon: Icons.calendar_month_outlined,
                  label: 'Most active publication year',
                  value: analysis.busiestYear?.toString() ?? 'N/A',
                ),
                _InsightTile(
                  icon: Icons.menu_book_outlined,
                  label: 'Top journal',
                  value: topJournal == null
                      ? 'N/A'
                      : '${topJournal.key} (${topJournal.value})',
                ),
                _InsightTile(
                  icon: Icons.person_search_outlined,
                  label: 'Top author',
                  value: topAuthor == null
                      ? 'N/A'
                      : '${topAuthor.key} (${topAuthor.value})',
                ),
                _InsightTile(
                  icon: Icons.workspace_premium_outlined,
                  label: 'Most influential paper',
                  value: mostInfluentialPaper?.title ?? 'N/A',
                  supportingText: mostInfluentialPaper == null
                      ? null
                      : '${mostInfluentialPaper.citations} citations',
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _InsightTile extends StatelessWidget {
  const _InsightTile({
    required this.icon,
    required this.label,
    required this.value,
    this.supportingText,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? supportingText;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    maxLines: supportingText == null ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (supportingText != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      supportingText!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
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
