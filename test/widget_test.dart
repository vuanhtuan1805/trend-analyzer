import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:journaltrendanalyzer/main.dart';

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
}
