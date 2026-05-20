import 'dart:io';
import 'package:flutter/material.dart';

class DocumentAttachment extends StatelessWidget {
  final String? documentPath;

  const DocumentAttachment({super.key, this.documentPath});

  @override
  Widget build(BuildContext context) {
    if (documentPath == null) return const SizedBox.shrink();
    final file = File(documentPath!);
    final isPdf = documentPath!.toLowerCase().endsWith('.pdf');

    return Card(
      child: ListTile(
        leading: Icon(
          isPdf ? Icons.picture_as_pdf : Icons.image_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          file.path.split('/').last,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: const Text('Angehängtes Dokument'),
        trailing: const Icon(Icons.open_in_new, size: 18),
        onTap: () => _openFile(context, documentPath!),
      ),
    );
  }

  void _openFile(BuildContext context, String path) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Dokument: $path')),
    );
  }
}
