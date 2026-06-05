import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/database_provider.dart';
import '../../domain/models/access_category.dart';
import '../../domain/models/contract_category.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/l10n/enum_labels.dart';
import '../../shared/l10n/l10n_extension.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../contract_detail/contract_detail_screen.dart';
import '../dashboard/widgets/contract_list_tile.dart';

enum _SortOrder { cost, name, category, renewal }

class ContractsScreen extends ConsumerStatefulWidget {
  const ContractsScreen({super.key});

  @override
  ConsumerState<ContractsScreen> createState() => _ContractsScreenState();
}

class _ContractsScreenState extends ConsumerState<ContractsScreen> {
  ContractCategory? _filterCategory;
  AccessCategory? _filterAccessCategory;
  // false = Verträge, true = Zugänge.
  bool _showAccesses = false;
  _SortOrder _sortOrder = _SortOrder.name;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _searchVisible = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final contractsAsync = ref.watch(contractsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.navContracts),
        actions: [
          IconButton(
            icon: Icon(_searchVisible ? Icons.search_off : Icons.search),
            onPressed: () => setState(() {
              _searchVisible = !_searchVisible;
              if (!_searchVisible) {
                _searchQuery = '';
                _searchController.clear();
              }
            }),
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortMenu,
          ),
        ],
      ),
      body: contractsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l.errorMessage(e.toString()))),
        data: (allContracts) {
          final pool = allContracts
              .where((c) => _showAccesses
                  ? c.entryType.isZugang
                  : c.entryType.isVertrag)
              .toList();
          final filtered = pool
              .where((c) => _showAccesses
                  ? (_filterAccessCategory == null ||
                      c.accessCategory == _filterAccessCategory)
                  : (_filterCategory == null ||
                      c.category == _filterCategory))
              .where((c) {
                if (_searchQuery.isEmpty) return true;
                return c.name.toLowerCase().contains(_searchQuery) ||
                    c.provider.toLowerCase().contains(_searchQuery);
              })
              .toList();

          final sorted = List.of(filtered)
            ..sort((a, b) => switch (_sortOrder) {
                  _SortOrder.cost => b.monthlyCost.compareTo(a.monthlyCost),
                  _SortOrder.name => a.name.compareTo(b.name),
                  _SortOrder.category => _showAccesses
                      ? (a.accessCategory?.name ?? '')
                          .compareTo(b.accessCategory?.name ?? '')
                      : a.category.name.compareTo(b.category.name),
                  _SortOrder.renewal => (a.nextRenewal ?? DateTime(2100))
                      .compareTo(b.nextRenewal ?? DateTime(2100)),
                });

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _segmentControl(l)),
              if (_searchVisible)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: l.searchHint,
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () => setState(() {
                                  _searchQuery = '';
                                  _searchController.clear();
                                }),
                              )
                            : null,
                      ),
                      onChanged: (v) => setState(
                          () => _searchQuery = v.trim().toLowerCase()),
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                  child: _showAccesses
                      ? _accessCategoryFilter(l)
                      : _categoryFilter(l)),
              if (sorted.isEmpty)
                SliverFillRemaining(child: _emptyState(l))
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  sliver: SliverToBoxAdapter(
                    child: ContractListCard(
                      children: [
                        for (final c in sorted)
                          ContractListTile(
                            contract: c,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    ContractDetailScreen(contractId: c.id),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _segmentControl(AppLocalizations l) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: SegmentedButton<bool>(
        segments: [
          ButtonSegment(
            value: false,
            label: Text(l.segmentContracts),
            icon: const Icon(Icons.description_outlined, size: 18),
          ),
          ButtonSegment(
            value: true,
            label: Text(l.segmentAccesses),
            icon: const Icon(Icons.vpn_key_outlined, size: 18),
          ),
        ],
        selected: {_showAccesses},
        onSelectionChanged: (s) => setState(() => _showAccesses = s.first),
        showSelectedIcon: false,
      ),
    );
  }

  Widget _categoryFilter(AppLocalizations l) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          _filterChip(null, l.filterAll),
          ...ContractCategory.values
              .map((c) => _filterChip(c, c.localizedLabel(l))),
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
        onSelected: (_) =>
            setState(() => _filterCategory = selected ? null : cat),
      ),
    );
  }

  Widget _accessCategoryFilter(AppLocalizations l) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          _accessFilterChip(null, l.filterAll),
          ...AccessCategory.values
              .map((c) => _accessFilterChip(c, c.localizedLabel(l))),
        ],
      ),
    );
  }

  Widget _accessFilterChip(AccessCategory? cat, String label) {
    final selected = _filterAccessCategory == cat;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: selected,
        onSelected: (_) =>
            setState(() => _filterAccessCategory = selected ? null : cat),
      ),
    );
  }

  Widget _emptyState(AppLocalizations l) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_showAccesses ? Icons.vpn_key_outlined : Icons.receipt_long_outlined,
                size: 64, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              _showAccesses ? l.noAccessesTitle : l.noContractsTitle,
              style: AppTextStyles.heroTitle.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? l.noContractsSearch(_searchQuery)
                  : _showAccesses
                      ? (_filterAccessCategory != null
                          ? l.noContractsCategory
                          : l.noAccessesDefault)
                      : (_filterCategory != null
                          ? l.noContractsCategory
                          : l.noContractsDefault),
              textAlign: TextAlign.center,
              style: AppTextStyles.listSubtitle,
            ),
          ],
        ),
      ),
    );
  }

  void _showSortMenu() {
    final l = context.l10n;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => RadioGroup<_SortOrder>(
        groupValue: _sortOrder,
        onChanged: (v) {
          if (v != null) {
            setState(() => _sortOrder = v);
            Navigator.pop(context);
          }
        },
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l.sortByTitle,
                  style: AppTextStyles.heroTitle.copyWith(fontSize: 18),
                ),
              ),
              for (final order in _SortOrder.values)
                ListTile(
                  leading: Radio<_SortOrder>(value: order),
                  title: Text(switch (order) {
                    _SortOrder.cost => l.sortCost,
                    _SortOrder.name => l.sortName,
                    _SortOrder.category => l.sortCategory,
                    _SortOrder.renewal => l.sortRenewal,
                  }),
                  onTap: () {
                    setState(() => _sortOrder = order);
                    Navigator.pop(context);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
