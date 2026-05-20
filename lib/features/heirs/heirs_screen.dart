import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/database.dart';
import '../../data/providers/database_provider.dart';
import 'heir_detail_screen.dart';
import 'share_export_service.dart';

class HeirsScreen extends ConsumerWidget {
  const HeirsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heirsAsync = ref.watch(heirsStreamProvider);
    final contractsAsync = ref.watch(contractsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Erben & Teilen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'PDF exportieren',
            onPressed: () => _exportPdf(context, contractsAsync.valueOrNull ?? []),
          ),
        ],
      ),
      body: heirsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Fehler: $e')),
        data: (heirs) => heirs.isEmpty
            ? _emptyState(context)
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _infoCard(context),
                  const SizedBox(height: 16),
                  ...heirs.map((h) => _heirTile(context, ref, h)),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const HeirDetailScreen())),
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Erbe hinzufügen'),
      ),
    );
  }

  Widget _infoCard(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(Icons.info_outline,
                color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Hinterbliebene erhalten Zugang zu deinen Verträgen. '
                'Für den Fall der Fälle.',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heirTile(BuildContext context, WidgetRef ref, Heir heir) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(heir.name.substring(0, 1).toUpperCase()),
        ),
        title: Text(heir.name),
        subtitle: Text('${heir.email} · ${heir.accessLevel.label}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => HeirDetailScreen(existing: heir))),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(context, ref, heir),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.family_restroom,
                size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              'Noch keine Erben hinterlegt',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Lege fest, wer im Fall der Fälle Zugang\nzu deinen Verträgen erhält.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, Heir heir) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Erbe löschen?'),
        content: Text('${heir.name} wirklich entfernen?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Abbrechen')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child:
                  const Text('Löschen', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(heirsDaoProvider).deleteHeir(heir.id);
    }
  }

  Future<void> _exportPdf(
      BuildContext context, List<Contract> contracts) async {
    if (contracts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keine Verträge zum Exportieren')),
      );
      return;
    }
    try {
      final file =
          await ShareExportService.exportToPdfText(contracts, 'Mein Haushalt');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exportiert: ${file.path}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e')),
        );
      }
    }
  }
}
