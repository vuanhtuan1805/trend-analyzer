import 'dart:convert';

import 'package:http/http.dart' as http;

const _openAlexBaseUrl = 'api.openalex.org';

class Publication {
  const Publication({
    required this.title,
    required this.year,
    required this.citations,
    required this.source,
    required this.type,
    required this.openAlexUrl,
  });

  final String title;
  final int? year;
  final int citations;
  final String source;
  final String type;
  final String openAlexUrl;

  factory Publication.fromJson(Map<String, dynamic> json) {
    final primaryLocation = json['primary_location'];
    final sourceJson = primaryLocation is Map<String, dynamic>
        ? primaryLocation['source']
        : null;

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
    );
  }
}

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
}

class OpenAlexService {
  OpenAlexService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<ResearchAnalysis> fetchResearchData(
    String topic, {
    int perPage = 25,
  }) async {
    return fetchOpenAlexResearchData(topic, client: _client, perPage: perPage);
  }
}

Future<ResearchAnalysis> fetchOpenAlexResearchData(
  String topic, {
  http.Client? client,
  int perPage = 25,
}) async {
  final normalizedTopic = topic.trim();
  if (normalizedTopic.isEmpty) {
    throw ArgumentError('Enter a research topic to search.');
  }

  final safePerPage = perPage.clamp(1, 100);
  final apiKey = const String.fromEnvironment('OPENALEX_API_KEY');
  final queryParameters = <String, String>{
    'search': normalizedTopic,
    'sort': 'cited_by_count:desc',
    'per_page': '$safePerPage',
    'select': [
      'id',
      'title',
      'publication_year',
      'cited_by_count',
      'primary_location',
      'type',
    ].join(','),
  };

  if (apiKey.isNotEmpty) {
    queryParameters['api_key'] = apiKey;
  }

  final uri = Uri.https(_openAlexBaseUrl, '/works', queryParameters);
  final httpClient = client ?? http.Client();
  final response = await httpClient.get(uri);

  if (response.statusCode != 200) {
    throw OpenAlexException(
      'OpenAlex request failed with status ${response.statusCode}.',
    );
  }

  final decoded = jsonDecode(response.body) as Map<String, dynamic>;
  final results = decoded['results'] as List<dynamic>? ?? const [];
  final meta = decoded['meta'] as Map<String, dynamic>? ?? const {};
  final publications = results
      .whereType<Map<String, dynamic>>()
      .map(Publication.fromJson)
      .toList(growable: false);

  final publicationsByYear = <int, int>{};
  var totalCitations = 0;
  for (final publication in publications) {
    totalCitations += publication.citations;
    final year = publication.year;
    if (year != null) {
      publicationsByYear.update(year, (count) => count + 1, ifAbsent: () => 1);
    }
  }

  final sortedYears = Map.fromEntries(
    publicationsByYear.entries.toList()..sort((a, b) => b.key.compareTo(a.key)),
  );

  return ResearchAnalysis(
    topic: normalizedTopic,
    totalWorks: meta['count'] as int? ?? publications.length,
    publications: publications,
    publicationsByYear: sortedYears,
    totalCitations: totalCitations,
  );
}

class OpenAlexException implements Exception {
  const OpenAlexException(this.message);

  final String message;

  @override
  String toString() => message;
}
