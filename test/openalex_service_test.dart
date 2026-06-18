import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
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
}
