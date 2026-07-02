import 'package:flutter/material.dart';

class AuthorContributionList extends StatelessWidget {
  const AuthorContributionList({
    super.key,
    required this.authorCounts,
    this.limit = 8,
  });

  final List<MapEntry<String, int>> authorCounts;
  final int limit;

  @override
  Widget build(BuildContext context) {
    final visibleCounts = authorCounts.take(limit).toList();
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
              _AuthorContributionRow(
                rank: index + 1,
                author: visibleCounts[index].key,
                count: visibleCounts[index].value,
                maxCount: maxCount,
              ),
          ],
        ),
      ),
    );
  }
}

class _AuthorContributionRow extends StatelessWidget {
  const _AuthorContributionRow({
    required this.rank,
    required this.author,
    required this.count,
    required this.maxCount,
  });

  final int rank;
  final String author;
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
                  author,
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
            width: 80,
            child: Text(
              count == 1 ? '1 paper' : '$count papers',
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
