import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/database_provider.dart';
import '../../domain/models/contract_category.dart';
import '../add_contract/add_contract_screen.dart';
import '../add_contract/widgets/entry_method_sheet.dart';
import '../contract_detail/contract_detail_screen.dart';
import '../heirs/heirs_screen.dart';
import '../premium/premium_service.dart';
import '../scan/extraction_result.dart';
import '../scan/scan_controller.dart';
import '../settings/settings_screen.dart';
import 'widgets/contract_list_tile.dart';
import 'widgets/cost_summary_card.dart';

enum _SortOrder { cost, name, category, renewal }

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  ContractCategory? _filterCategory;
  _SortOrder _sortOrder = _SortOrder.name;

  @override
  Widget build(BuildContext context) {
    final contractsAsync = ref.watch(contractsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pacto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortMenu,
          ),
          IconButton(
            icon: const Icon(Icons.family_restroom),
            onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HeirsScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: contractsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Fehler: $e')),
        data: (allContracts) {
          final filtered = _filterCategory == null
              ? allContracts
              : allContracts
                  .where((c) => c.category == _filterCategory)
                  .toList();

          final sorted = List.of(filtered)
            ..sort((a, b) => switch (_sortOrder) {
                  _SortOrder.cost => b.monthlyCost.compareTo(a.monthlyCost),
                  _SortOrder.name => a.name.compareTo(b.name),
                  _SortOrder.category =>
                    a.category.name.compareTo(b.category.name),
                  _SortOrder.renewal => (a.nextRenewal ?? DateTime(2100))
                      .compareTo(b.nextRenewal ?? DateTime(2100)),
                });

          final total = allContracts.fold(
              0.0, (s, c) => s + c.monthlyCost);

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: CostSummaryCard(
                    totalMonthlyCost: total,
                    contractCount: allContracts.length,
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _categoryFilter()),
              if (sorted.isEmpty)
                SliverFillRemaining(child: _emptyState()),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => ContractListTile(
                    contract: sorted[i],
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => ContractDetailScreen(
                            contractId: sorted[i].id))),
                  ),
                  childCount: sorted.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addContract,
        icon: const Icon(Icons.add),
        label: const Text('Vertrag'),
      ),
    );
  }

  Widget _categoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          _filterChip(null, 'Alle'),
          ...ContractCategory.values.map((c) => _filterChip(c, c.label)),
        ],
      ),
    );
  }

  Widget _filterChip(ContractCategory? cat, String label) {
    final selected = _filterCategory == cat;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: selected,
        onSelected: (_) => setState(
            () => _filterCategory = selected ? null : cat),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              'Noch keine Verträge',
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _filterCategory != null
                  ? 'Kein Vertrag in dieser Kategorie'
                  : 'Füge deinen ersten Vertrag hinzu.\nWeißt du wirklich was du zahlst?',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _ensureCanAdd() async {
    final purchased = ref.read(premiumProvider);
    if (purchased) return true;
    final contracts = ref.read(contractsStreamProvider).value ?? const [];
    if (contracts.length < freeTierLimit) return true;
    if (!mounted) return false;
    final unlocked = await showPurchaseDialog(context);
    if (unlocked) {
      await ref.read(premiumProvider.notifier).setPurchased(true);
    }
    return unlocked;
  }

  Future<void> _addContract() async {
    if (!await _ensureCanAdd()) return;
    if (!mounted) return;
    final method = await EntryMethodSheet.show(context);
    if (method == null || !mounted) return;

    switch (method) {
      case EntryMethod.library:
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const AddContractScreen()));
        break;
      case EntryMethod.manual:
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const AddContractScreen()));
        break;
      case EntryMethod.scan:
        final result = await Navigator.of(context).push<ExtractionResult>(
            MaterialPageRoute(builder: (_) => const ScanScreen()));
        if (result != null && mounted) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) =>
                  AddContractScreen(initialExtraction: result)));
        }
        break;
    }
  }

  void _showSortMenu() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ListTile(
              title: Text('Sortieren nach',
                  style: TextStyle(fontWeight: FontWeight.bold))),
          for (final order in _SortOrder.values)
            ListTile(
              leading: Radio<_SortOrder>(
                value: order,
                groupValue: _sortOrder,
                onChanged: (v) {
                  setState(() => _sortOrder = v!);
                  Navigator.pop(context);
                },
              ),
              title: Text(switch (order) {
                _SortOrder.cost => 'Kosten (höchste zuerst)',
                _SortOrder.name => 'Name (A-Z)',
                _SortOrder.category => 'Kategorie',
                _SortOrder.renewal => 'Nächste Verlängerung',
              }),
              onTap: () {
                setState(() => _sortOrder = order);
                Navigator.pop(context);
              },
            ),
        ],
      ),
    );
  }
}
