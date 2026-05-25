import 'package:flutter/material.dart';
import '../../../shared/l10n/l10n_extension.dart';

enum EntryMethod { library, manual, scan, webSearch }

class EntryMethodSheet extends StatelessWidget {
  const EntryMethodSheet({super.key});

  static Future<EntryMethod?> show(BuildContext context) {
    return showModalBottomSheet<EntryMethod>(
      context: context,
      builder: (_) => const EntryMethodSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                l.entrySheetTitle,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _tile(
              context,
              icon: Icons.list_alt,
              label: l.entryLibrary,
              subtitle: l.entryLibrarySubtitle,
              value: EntryMethod.library,
            ),
            _tile(
              context,
              icon: Icons.edit_outlined,
              label: l.entryManual,
              subtitle: l.entryManualSubtitle,
              value: EntryMethod.manual,
            ),
            _tile(
              context,
              icon: Icons.document_scanner_outlined,
              label: l.entryScan,
              subtitle: l.entryScanSubtitle,
              value: EntryMethod.scan,
            ),
            _tile(
              context,
              icon: Icons.public_outlined,
              label: l.entryWebSearch,
              subtitle: l.entryWebSearchSubtitle,
              value: EntryMethod.webSearch,
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
      leading:
          Icon(icon, color: Theme.of(ctx).colorScheme.primary, size: 28),
      title: Text(label),
      subtitle: Text(subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey)),
      onTap: () => Navigator.of(ctx).pop(value),
    );
  }
}
