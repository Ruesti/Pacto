import 'package:flutter/material.dart';
import '../../domain/models/contract_category.dart';
import '../../shared/widgets/category_pill.dart';
import 'provider_library_data.dart';

class ProviderLibraryScreen extends StatefulWidget {
  const ProviderLibraryScreen({super.key});

  @override
  State<ProviderLibraryScreen> createState() => _ProviderLibraryScreenState();
}

class _ProviderLibraryScreenState extends State<ProviderLibraryScreen> {
  String _query = '';
  ContractCategory? _filterCategory;

  List<ProviderTemplate> get _filtered {
    return providerLibrary.where((p) {
      final matchQuery = _query.isEmpty ||
          p.name.toLowerCase().contains(_query.toLowerCase()) ||
          p.provider.toLowerCase().contains(_query.toLowerCase());
      final matchCat =
          _filterCategory == null || p.category == _filterCategory;
      return matchQuery && matchCat;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Anbieter-Bibliothek')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Suchen…',
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          _categoryFilter(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _filtered.length,
              itemBuilder: (ctx, i) => _tile(_filtered[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryFilter() {
    final categories = ContractCategory.values;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          _filterChip(null, 'Alle'),
          ...categories.map((c) => _filterChip(c, c.label)),
        ],
      ),
    );
  }

  Widget _filterChip(ContractCategory? cat, String label) {
    final selected = _filterCategory == cat;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(
            () => _filterCategory = selected ? null : cat),
      ),
    );
  }

  Widget _tile(ProviderTemplate t) {
    return ListTile(
      title: Text(t.name),
      subtitle: Row(
        children: [
          CategoryPill(category: t.category),
          const SizedBox(width: 8),
          Text(t.cancellationMethod.label,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).pop(t),
    );
  }
}
