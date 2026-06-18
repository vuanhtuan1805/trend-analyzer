class Publication {
  const Publication({
    required this.title,
    required this.year,
    required this.citations,
    required this.source,
    required this.type,
    required this.openAlexUrl,
    required this.authors,
    required this.doi,
    required this.abstractText,
  });

  final String title;
  final int? year;
  final int citations;
  final String source;
  final String type;
  final String openAlexUrl;
  final List<String> authors;
  final String? doi;
  final String? abstractText;

  factory Publication.fromJson(Map<String, dynamic> json) {
    final primaryLocation = json['primary_location'];
    final sourceJson = primaryLocation is Map<String, dynamic>
        ? primaryLocation['source']
        : null;
    final authorships = json['authorships'] as List<dynamic>? ?? const [];

    return Publication(
      title: (json['title'] as String?)?.trim().isNotEmpty == true
          ? json['title'] as String
          : 'Untitled publication',
      year: json['publication_year'] as int?,
      citations: json['cited_by_count'] as int? ?? 0,
      source: sourceJson is Map<String, dynamic>
          ? sourceJson['display_name'] as String? ?? 'Unknown source'
          : 'Unknown source',
      type: json['type'] as String? ?? 'work',
      openAlexUrl: json['id'] as String? ?? '',
      authors: authorships
          .whereType<Map<String, dynamic>>()
          .map((authorship) {
            final author = authorship['author'];
            if (author is Map<String, dynamic>) {
              return author['display_name'] as String?;
            }
            return null;
          })
          .whereType<String>()
          .where((author) => author.trim().isNotEmpty)
          .toList(growable: false),
      doi: (json['doi'] as String?)?.trim(),
      abstractText: _abstractFromInvertedIndex(json['abstract_inverted_index']),
    );
  }

  String get authorsLabel =>
      authors.isEmpty ? 'Unknown authors' : authors.join(', ');
}

String? _abstractFromInvertedIndex(Object? invertedIndex) {
  if (invertedIndex is! Map<String, dynamic> || invertedIndex.isEmpty) {
    return null;
  }

  final wordsByPosition = <int, String>{};
  for (final entry in invertedIndex.entries) {
    final positions = entry.value;
    if (positions is! List<dynamic>) {
      continue;
    }

    for (final position in positions.whereType<int>()) {
      wordsByPosition[position] = entry.key;
    }
  }

  if (wordsByPosition.isEmpty) {
    return null;
  }

  final orderedPositions = wordsByPosition.keys.toList()..sort();
  return orderedPositions
      .map((position) => wordsByPosition[position])
      .join(' ');
}
