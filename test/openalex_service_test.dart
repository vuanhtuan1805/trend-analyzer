import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:journaltrendanalyzer/models/publication.dart';
import 'package:journaltrendanalyzer/models/research_analysis.dart';
import 'package:journaltrendanalyzer/services/openalex_service.dart';

void main() {
  test('fetchOpenAlexResearchData uses grouped publication years', () async {
    final client = MockClient((request) async {
      if (request.url.queryParameters['group_by'] == 'publication_year') {
        return http.Response(
          jsonEncode({
            'group_by': [
              {'key': '2024', 'count': 12},
              {'key': '2023', 'count': 8},
            ],
          }),
          200,
        );
      }

      return http.Response(
        jsonEncode({
          'meta': {'count': 20},
          'results': [
            {
              'id': 'https://openalex.org/W1',
              'title': 'Highly Cited Work',
              'publication_year': 1999,
              'cited_by_count': 99,
              'type': 'article',
              'primary_location': {
                'source': {'display_name': 'Test Journal'},
              },
              'authorships': [],
            },
          ],
        }),
        200,
      );
    });

    final analysis = await fetchOpenAlexResearchData(
      'data science',
      client: client,
    );

    expect(analysis.totalWorks, 20);
    expect(analysis.publicationsByYear, {2024: 12, 2023: 8});
    expect(analysis.chronologicalPublicationCounts.first.key, 2023);
    expect(analysis.chronologicalPublicationCounts.last.key, 2024);
  });

  test(
    'ResearchAnalysis ranks influential publications, journals, and authors',
    () {
      final analysis = ResearchAnalysis(
        topic: 'testing',
        totalWorks: 4,
        totalCitations: 220,
        publicationsByYear: const {2026: 2, 2025: 2},
        publications: const [
          Publication(
            title: 'Middle cited work',
            year: 2026,
            citations: 50,
            source: 'Journal B',
            type: 'article',
            openAlexUrl: '',
            authors: ['Ada Lovelace', 'Grace Hopper'],
            doi: null,
            abstractText: null,
          ),
          Publication(
            title: 'Most cited work',
            year: 2026,
            citations: 120,
            source: 'Journal A',
            type: 'article',
            openAlexUrl: '',
            authors: ['Ada Lovelace', 'Katherine Johnson'],
            doi: null,
            abstractText: null,
          ),
          Publication(
            title: 'Lower cited work',
            year: 2025,
            citations: 30,
            source: 'Journal A',
            type: 'article',
            openAlexUrl: '',
            authors: ['Grace Hopper'],
            doi: null,
            abstractText: null,
          ),
          Publication(
            title: 'Least cited work',
            year: 2025,
            citations: 20,
            source: 'Journal C',
            type: 'article',
            openAlexUrl: '',
            authors: ['Alan Turing'],
            doi: null,
            abstractText: null,
          ),
        ],
      );

      expect(
        analysis.influentialPublications.map(
          (publication) => publication.title,
        ),
        [
          'Most cited work',
          'Middle cited work',
          'Lower cited work',
          'Least cited work',
        ],
      );
      expect(
        analysis.journalPublicationCounts.map(
          (entry) => '${entry.key}:${entry.value}',
        ),
        ['Journal A:2', 'Journal B:1', 'Journal C:1'],
      );
      expect(
        analysis.authorPublicationCounts.map(
          (entry) => '${entry.key}:${entry.value}',
        ),
        [
          'Ada Lovelace:2',
          'Grace Hopper:2',
          'Alan Turing:1',
          'Katherine Johnson:1',
        ],
      );
      expect(analysis.mostInfluentialPublication?.title, 'Most cited work');
      expect(analysis.topJournal?.key, 'Journal A');
      expect(analysis.topJournal?.value, 2);
      expect(analysis.topAuthor?.key, 'Ada Lovelace');
      expect(analysis.topAuthor?.value, 2);
    },
  );
}
