import 'package:flutter/material.dart';

enum EntryMethod { library, manual, scan }

class EntryMethodSheet extends StatelessWidget {
  final bool scanAvailable;

  const EntryMethodSheet({super.key, this.scanAvailable = false});

  static Future<EntryMethod?> show(BuildContext context) {
    return showModalBottomSheet<EntryMethod>(
      context: context,
      builder: (_) => const EntryMethodSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Vertrag hinzufügen',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _tile(
              context,
              icon: Icons.list_alt,
              label: 'Aus Bibliothek wählen',
              subtitle: 'Netflix, Spotify, Telekom & mehr',
              value: EntryMethod.library,
            ),
            _tile(
              context,
              icon: Icons.edit_outlined,
              label: 'Manuell eingeben',
              subtitle: 'Alle Felder selbst ausfüllen',
              value: EntryMethod.manual,
            ),
            _tile(
              context,
              icon: Icons.document_scanner_outlined,
              label: 'Dokument scannen (KI)',
              subtitle: 'Foto oder PDF → automatisch ausfüllen',
              value: EntryMethod.scan,
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(BuildContext ctx,
      {required IconData icon,
      required String label,
      required String subtitle,
      required EntryMethod value}) {
    return ListTile(
      leading: Icon(icon,
          color: Theme.of(ctx).colorScheme.primary, size: 28),
      title: Text(label),
      subtitle: Text(subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey)),
      onTap: () => Navigator.of(ctx).pop(value),
    );
  }
}
