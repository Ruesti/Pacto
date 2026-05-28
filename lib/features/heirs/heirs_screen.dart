import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import '../../data/database/database.dart';
import '../../data/providers/database_provider.dart';
import '../../data/providers/user_name_provider.dart';
import '../../shared/l10n/enum_labels.dart';
import '../../shared/l10n/l10n_extension.dart';
import 'heir_detail_screen.dart';
import 'share_export_service.dart';

class HeirsScreen extends ConsumerWidget {
  const HeirsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final heirsAsync = ref.watch(heirsStreamProvider);
    final contractsAsync = ref.watch(contractsStreamProvider);
    final ownerName = ref.watch(userNameProvider).valueOrNull ?? 'Pacto-User';

    return Scaffold(
      appBar: AppBar(
        title: Text(l.heirsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: l.exportPdfTooltip,
            onPressed: () => _exportPdf(
                context, contractsAsync.valueOrNull ?? [], ownerName, l),
          ),
        ],
      ),
      body: heirsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l.errorMessage(e.toString()))),
        data: (heirs) => heirs.isEmpty
            ? _emptyState(context, l)
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _infoCard(context, l),
                  const SizedBox(height: 16),
                  ...heirs.map((h) => _heirTile(context, ref, h, l)),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const HeirDetailScreen())),
        icon: const Icon(Icons.person_add_outlined),
        label: Text(l.heirAddFab),
      ),
    );
  }

  Widget _infoCard(BuildContext context, l) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(Icons.info_outline,
                color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l.heirsInfoText,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heirTile(
      BuildContext context, WidgetRef ref, Heir heir, l) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(heir.name.substring(0, 1).toUpperCase()),
        ),
        title: Text(heir.name),
        subtitle:
            Text('${heir.email} · ${heir.accessLevel.localizedLabel(l)}'),
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
              onPressed: () => _confirmDelete(context, ref, heir, l),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context, l) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.family_restroom, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              l.heirsEmptyTitle,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              l.heirsEmptySubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, Heir heir, l) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.deleteHeirTitle),
        content: Text(l.deleteHeirContent(heir.name)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l.cancelButton)),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l.deleteButton,
                  style: const TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(heirsDaoProvider).deleteHeir(heir.id);
    }
  }

  Future<void> _exportPdf(BuildContext context, List<Contract> contracts,
      String ownerName, l) async {
    if (contracts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.noContractsToExport)),
      );
      return;
    }
    try {
      final file = await ShareExportService.exportToPdf(contracts, ownerName);
      final bytes = await file.readAsBytes();
      if (!context.mounted) return;
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'pacto_vertraege.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.errorMessage(e.toString()))),
        );
      }
    }
  }
}
