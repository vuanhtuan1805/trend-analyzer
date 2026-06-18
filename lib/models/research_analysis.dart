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
}
