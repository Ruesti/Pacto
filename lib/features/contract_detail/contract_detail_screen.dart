import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/database/database.dart';
import '../../data/providers/database_provider.dart';
import '../../shared/widgets/category_pill.dart';
import '../../shared/utils/currency_formatter.dart';
import '../../shared/utils/date_formatter.dart';
import '../add_contract/add_contract_screen.dart';
import 'widgets/cancellation_info_card.dart';
import 'widgets/document_attachment.dart';

class ContractDetailScreen extends ConsumerWidget {
  final String contractId;

  const ContractDetailScreen({super.key, required this.contractId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contractsAsync = ref.watch(contractsStreamProvider);

    return contractsAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Fehler: $e'))),
      data: (contracts) {
        final contract =
            contracts.where((c) => c.id == contractId).firstOrNull;
        if (contract == null) {
          return const Scaffold(
              body: Center(child: Text('Vertrag nicht gefunden')));
        }
        return _DetailView(contract: contract);
      },
    );
  }
}

class _DetailView extends ConsumerWidget {
  final Contract contract;

  const _DetailView({required this.contract});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(contract.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => AddContractScreen(existing: contract))),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _headerCard(context),
          const SizedBox(height: 12),
          CancellationInfoCard(contract: contract),
          const SizedBox(height: 12),
          _contactCard(context),
          const SizedBox(height: 12),
          DocumentAttachment(documentPath: contract.documentPath),
          if (contract.notes.isNotEmpty) ...[
            const SizedBox(height: 12),
            _notesCard(context),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _headerCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(contract.name,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(contract.provider,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 14)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(formatMonthlyCost(contract.monthlyCost),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(contract.billingCycle.label,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            CategoryPill(category: contract.category),
            if (contract.contractStart != null ||
                contract.nextRenewal != null) ...[
              const Divider(height: 20),
              if (contract.contractStart != null)
                _row('Beginn', formatDate(contract.contractStart)),
              if (contract.nextRenewal != null)
                _row('Verlängerung',
                    '${formatDate(contract.nextRenewal)} (${daysUntil(contract.nextRenewal)})'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _contactCard(BuildContext context) {
    final hasContact = contract.contactPhone != null ||
        contract.contactEmail != null ||
        contract.contactUrl != null;
    if (!hasContact) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Kontakt',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            if (contract.contactPhone != null)
              _contactRow(
                context,
                icon: Icons.phone_outlined,
                label: contract.contactPhone!,
                onTap: () => launchUrl(
                    Uri.parse('tel:${contract.contactPhone}')),
              ),
            if (contract.contactEmail != null)
              _contactRow(
                context,
                icon: Icons.email_outlined,
                label: contract.contactEmail!,
                onTap: () => launchUrl(
                    Uri.parse('mailto:${contract.contactEmail}')),
              ),
            if (contract.contactUrl != null)
              _contactRow(
                context,
                icon: Icons.link_outlined,
                label: contract.contactUrl!,
                onTap: () =>
                    launchUrl(Uri.parse(contract.contactUrl!)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _contactRow(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      decoration: TextDecoration.underline)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _notesCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notizen',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            Text(contract.notes,
                style: const TextStyle(fontSize: 13, height: 1.4)),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text('$label:',
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Vertrag löschen?'),
        content: Text(
            '"${contract.name}" wirklich dauerhaft löschen?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Abbrechen')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Löschen',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(contractsDaoProvider).deleteContract(contract.id);
      if (context.mounted) Navigator.of(context).pop();
    }
  }
}
