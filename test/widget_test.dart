import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:journaltrendanalyzer/main.dart';
import 'package:journaltrendanalyzer/openalex_service.dart';

void main() {
  testWidgets('research topic search UI renders', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Journal Trend Analyzer'), findsOneWidget);
    expect(find.text('Research topic'), findsOneWidget);
    expect(find.text('Artificial Intelligence'), findsWidgets);
    expect(find.text('Software Engineering'), findsOneWidget);
    expect(find.text('Analyze'), findsOneWidget);
  });

  testWidgets('empty search shows validation message', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.enterText(find.byType(EditableText), '');
    await tester.tap(find.text('Analyze'));
    await tester.pump();

    expect(find.text('Enter a research topic to search.'), findsOneWidget);
  });

  testWidgets('publication detail screen renders metadata', (tester) async {
    const publication = Publication(
      title: 'A Test Publication',
      year: 2026,
      citations: 42,
      source: 'Journal of Helpful Tests',
      type: 'article',
      openAlexUrl: 'https://openalex.org/W123',
      authors: ['Ada Lovelace', 'Grace Hopper'],
      doi: 'https://doi.org/10.1234/example',
      abstractText: 'This abstract is available for the selected publication.',
    );

    await tester.pumpWidget(
      const MaterialApp(home: PublicationDetailPage(publication: publication)),
    );

    expect(find.text('A Test Publication'), findsOneWidget);
    expect(find.text('Ada Lovelace, Grace Hopper'), findsOneWidget);
    expect(find.text('Journal of Helpful Tests'), findsOneWidget);
    expect(find.text('42 citations'), findsOneWidget);
    expect(find.text('https://doi.org/10.1234/example'), findsOneWidget);
    expect(
      find.text('This abstract is available for the selected publication.'),
      findsOneWidget,
    );
  });
}
