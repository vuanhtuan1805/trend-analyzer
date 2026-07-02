import 'package:flutter/material.dart';

class JournalContributionList extends StatelessWidget {
  const JournalContributionList({
    super.key,
    required this.journalCounts,
    this.limit = 8,
  });

  final List<MapEntry<String, int>> journalCounts;
  final int limit;

  @override
  Widget build(BuildContext context) {
    final visibleCounts = journalCounts.take(limit).toList();
    final maxCount = visibleCounts.fold<int>(
      0,
      (best, entry) => entry.value > best ? entry.value : best,
    );

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            for (var index = 0; index < visibleCounts.length; index++)
              _JournalContributionRow(
                rank: index + 1,
                journal: visibleCounts[index].key,
                count: visibleCounts[index].value,
                maxCount: maxCount,
              ),
          ],
        ),
      ),
    );
  }
}

class _JournalContributionRow extends StatelessWidget {
  const _JournalContributionRow({
    required this.rank,
    required this.journal,
    required this.count,
    required this.maxCount,
  });

  final int rank;
  final String journal;
  final int count;
  final int maxCount;

  @override
  Widget build(BuildContext context) {
    final ratio = maxCount == 0 ? 0.0 : count / maxCount;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '$rank',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  journal,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  minHeight: 8,
                  value: ratio,
                  borderRadius: BorderRadius.circular(8),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 72,
            child: Text(
              '$count works',
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
