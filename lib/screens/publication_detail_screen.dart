import 'package:flutter/material.dart';

import '../models/publication.dart';
import '../widgets/detail_chip.dart';
import '../widgets/detail_section.dart';

class PublicationDetailScreen extends StatelessWidget {
  const PublicationDetailScreen({super.key, required this.publication});

  final Publication publication;

  @override
  Widget build(BuildContext context) {
    final abstractText = publication.abstractText;

    return Scaffold(
      appBar: AppBar(title: const Text('Publication details')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              publication.title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                DetailChip(
                  icon: Icons.calendar_month_outlined,
                  label: publication.year?.toString() ?? 'Year unknown',
                ),
                DetailChip(
                  icon: Icons.format_quote_outlined,
                  label: '${publication.citations} citations',
                ),
                DetailChip(
                  icon: Icons.category_outlined,
                  label: publication.type,
                ),
              ],
            ),
            const SizedBox(height: 20),
            DetailSection(
              title: 'Authors',
              icon: Icons.people_outline,
              child: Text(publication.authorsLabel),
            ),
            DetailSection(
              title: 'Journal',
              icon: Icons.menu_book_outlined,
              child: Text(publication.source),
            ),
            DetailSection(
              title: 'DOI',
              icon: Icons.link_outlined,
              child: SelectableText(
                publication.doi?.isNotEmpty == true
                    ? publication.doi!
                    : 'Not available',
              ),
            ),
            DetailSection(
              title: 'Abstract',
              icon: Icons.article_outlined,
              child: Text(
                abstractText?.isNotEmpty == true
                    ? abstractText!
                    : 'Abstract not available from OpenAlex for this publication.',
              ),
            ),
            if (publication.openAlexUrl.isNotEmpty)
              DetailSection(
                title: 'OpenAlex',
                icon: Icons.public_outlined,
                child: SelectableText(publication.openAlexUrl),
              ),
          ],
        ),
      ),
    );
  }
}
