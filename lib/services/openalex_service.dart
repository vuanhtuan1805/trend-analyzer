import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/publication.dart';
import '../models/research_analysis.dart';

const _openAlexBaseUrl = 'api.openalex.org';

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
  final worksQueryParameters = _withApiKey({
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
      'authorships',
      'doi',
      'abstract_inverted_index',
    ].join(','),
  }, apiKey);

  final yearlyQueryParameters = _withApiKey({
    'search': normalizedTopic,
    'group_by': 'publication_year',
    'per_page': '200',
  }, apiKey);

  final httpClient = client ?? http.Client();
  final shouldCloseClient = client == null;

  try {
    final worksUri = Uri.https(
      _openAlexBaseUrl,
      '/works',
      worksQueryParameters,
    );
    final yearlyUri = Uri.https(
      _openAlexBaseUrl,
      '/works',
      yearlyQueryParameters,
    );

    final responses = await Future.wait([
      httpClient.get(worksUri),
      httpClient.get(yearlyUri),
    ]);
    final worksResponse = responses.first;
    final yearlyResponse = responses.last;

    if (worksResponse.statusCode != 200) {
      throw OpenAlexException(
        'OpenAlex publication request failed with status ${worksResponse.statusCode}.',
      );
    }

    if (yearlyResponse.statusCode != 200) {
      throw OpenAlexException(
        'OpenAlex year grouping request failed with status ${yearlyResponse.statusCode}.',
      );
    }

    final worksDecoded = jsonDecode(worksResponse.body) as Map<String, dynamic>;
    final yearlyDecoded =
        jsonDecode(yearlyResponse.body) as Map<String, dynamic>;
    final results = worksDecoded['results'] as List<dynamic>? ?? const [];
    final meta = worksDecoded['meta'] as Map<String, dynamic>? ?? const {};
    final publications = results
        .whereType<Map<String, dynamic>>()
        .map(Publication.fromJson)
        .toList(growable: false);

    final publicationsByYear = _publicationsByYearFromGroupBy(yearlyDecoded);
    final fallbackPublicationsByYear = _publicationsByYearFromSample(
      publications,
    );
    final totalCitations = publications.fold<int>(
      0,
      (total, publication) => total + publication.citations,
    );

    return ResearchAnalysis(
      topic: normalizedTopic,
      totalWorks: meta['count'] as int? ?? publications.length,
      publications: publications,
      publicationsByYear: publicationsByYear.isNotEmpty
          ? publicationsByYear
          : fallbackPublicationsByYear,
      totalCitations: totalCitations,
    );
  } finally {
    if (shouldCloseClient) {
      httpClient.close();
    }
  }
}

Map<String, String> _withApiKey(
  Map<String, String> queryParameters,
  String apiKey,
) {
  if (apiKey.isEmpty) {
    return queryParameters;
  }

  return {...queryParameters, 'api_key': apiKey};
}

Map<int, int> _publicationsByYearFromGroupBy(Map<String, dynamic> decoded) {
  final groups = decoded['group_by'] as List<dynamic>? ?? const [];
  final years = <int, int>{};

  for (final group in groups.whereType<Map<String, dynamic>>()) {
    final year = int.tryParse(group['key'] as String? ?? '');
    final count = group['count'] as int?;
    if (year != null && count != null) {
      years[year] = count;
    }
  }

  return Map.fromEntries(
    years.entries.toList()..sort((a, b) => b.key.compareTo(a.key)),
  );
}

Map<int, int> _publicationsByYearFromSample(List<Publication> publications) {
  final years = <int, int>{};

  for (final publication in publications) {
    final year = publication.year;
    if (year != null) {
      years.update(year, (count) => count + 1, ifAbsent: () => 1);
    }
  }

  return Map.fromEntries(
    years.entries.toList()..sort((a, b) => b.key.compareTo(a.key)),
  );
}

class OpenAlexException implements Exception {
  const OpenAlexException(this.message);

  final String message;

  @override
  String toString() => message;
}
