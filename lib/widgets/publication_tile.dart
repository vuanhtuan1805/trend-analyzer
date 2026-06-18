import 'package:flutter/material.dart';

import '../models/publication.dart';
import '../screens/publication_detail_screen.dart';

class PublicationTile extends StatelessWidget {
  const PublicationTile({super.key, required this.publication});

  final Publication publication;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => PublicationDetailScreen(publication: publication),
            ),
          );
        },
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(_yearBadge(publication.year)),
        ),
        title: Text(publication.title),
        subtitle: Text(
          [
            publication.authors.take(3).join(', '),
            publication.source,
            publication.year?.toString(),
            publication.type,
          ].whereType<String>().where((value) => value.isNotEmpty).join(' . '),
        ),
        isThreeLine: publication.authors.isNotEmpty,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              publication.citations.toString(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Text('cites'),
          ],
        ),
      ),
    );
  }

  String _yearBadge(int? year) {
    if (year == null) {
      return '--';
    }
    return year.toString().substring(0, 2);
  }
}
