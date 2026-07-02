import 'publication.dart';

class ResearchAnalysis {
  const ResearchAnalysis({
    required this.topic,
    required this.totalWorks,
    required this.publications,
    required this.publicationsByYear,
    required this.totalCitations,
  });

  final String topic;
  final int totalWorks;
  final List<Publication> publications;
  final Map<int, int> publicationsByYear;
  final int totalCitations;

  int get publicationCount => publications.length;

  double get averageCitations =>
      publicationCount == 0 ? 0 : totalCitations / publicationCount;

  int? get newestYear => publicationsByYear.keys.fold<int?>(
    null,
    (latest, year) => latest == null || year > latest ? year : latest,
  );

  int? get busiestYear =>
      publicationsByYear.entries.fold<MapEntry<int, int>?>(null, (best, entry) {
        if (best == null || entry.value > best.value) {
          return entry;
        }
        return best;
      })?.key;

  List<MapEntry<int, int>> get chronologicalPublicationCounts =>
      publicationsByYear.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));

  List<Publication> get influentialPublications =>
      publications.toList()..sort((a, b) => b.citations.compareTo(a.citations));

  Publication? get mostInfluentialPublication =>
      influentialPublications.isEmpty ? null : influentialPublications.first;

  List<MapEntry<String, int>> get journalPublicationCounts {
    final counts = <String, int>{};

    for (final publication in publications) {
      final source = publication.source.trim().isEmpty
          ? 'Unknown source'
          : publication.source.trim();
      counts.update(source, (count) => count + 1, ifAbsent: () => 1);
    }

    return counts.entries.toList()..sort((a, b) {
      final countComparison = b.value.compareTo(a.value);
      if (countComparison != 0) {
        return countComparison;
      }
      return a.key.compareTo(b.key);
    });
  }

  MapEntry<String, int>? get topJournal =>
      journalPublicationCounts.isEmpty ? null : journalPublicationCounts.first;

  List<MapEntry<String, int>> get authorPublicationCounts {
    final counts = <String, int>{};

    for (final publication in publications) {
      for (final author in publication.authors) {
        final name = author.trim();
        if (name.isEmpty) {
          continue;
        }
        counts.update(name, (count) => count + 1, ifAbsent: () => 1);
      }
    }

    return counts.entries.toList()..sort((a, b) {
      final countComparison = b.value.compareTo(a.value);
      if (countComparison != 0) {
        return countComparison;
      }
      return a.key.compareTo(b.key);
    });
  }

  MapEntry<String, int>? get topAuthor =>
      authorPublicationCounts.isEmpty ? null : authorPublicationCounts.first;
}
