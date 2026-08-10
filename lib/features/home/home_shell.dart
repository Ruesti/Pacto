import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/database.dart';
import '../../data/providers/database_provider.dart';
import '../../shared/l10n/l10n_extension.dart';
import '../../shared/theme/app_colors.dart';
import '../add_contract/add_contract_screen.dart';
import '../add_contract/widgets/entry_method_sheet.dart';
import '../provider_library/provider_library_data.dart';
import '../provider_library/provider_library_screen.dart';
import '../contracts/contracts_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../heirs/heir_detail_screen.dart';
import '../heirs/heirs_screen.dart';
import '../premium/premium_service.dart';
import '../scan/extraction_result.dart';
import '../scan/scan_controller.dart';
import '../scan/web_search_screen.dart';
import '../settings/settings_screen.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _tab = 0;

  void _setTab(int i) => setState(() => _tab = i);

  void _openHeirs() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const HeirsScreen()),
    );
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  Future<bool> _ensureCanAdd() async {
    if (ref.read(premiumProvider).valueOrNull ?? false) return true;
    final contracts = ref.read(contractsStreamProvider).value ?? const [];
    if (contracts.length < freeTierLimit) return true;
    if (!mounted) return false;
    return showPurchaseDialog(context, ref);
  }

  Future<void> _onFabPressed() async {
    // Auf dem Erben-Tab hat der eingebettete HeirsScreen keinen erreichbaren
    // eigenen FAB (liegt hinter der aeusseren BottomAppBar) — das globale "+"
    // uebernimmt hier deshalb das Hinzufuegen eines Erben statt eines Vertrags.
    if (_tab == 2) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const HeirDetailScreen()),
      );
      return;
    }
    await _addContract();
  }

  Future<void> _addContract() async {
    if (!await _ensureCanAdd()) return;
    if (!mounted) return;
    final method = await EntryMethodSheet.show(context);
    if (method == null || !mounted) return;

    switch (method) {
      case EntryMethod.library:
        // Direkt die Bibliotheks-Liste zeigen; nach Auswahl oeffnet sich das
        // bereits vorgefuellte Formular. Bricht der User ab, passiert nichts.
        final template = await Navigator.of(context).push<ProviderTemplate>(
          MaterialPageRoute(builder: (_) => const ProviderLibraryScreen()),
        );
        if (template != null && mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AddContractScreen(initialTemplate: template),
            ),
          );
        }
        break;
      case EntryMethod.manual:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddContractScreen()),
        );
        break;
      case EntryMethod.scan:
        final result = await Navigator.of(context).push<ExtractionResult>(
          MaterialPageRoute(builder: (_) => const ScanScreen()),
        );
        if (result != null && mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AddContractScreen(initialExtraction: result),
            ),
          );
        }
        break;
      case EntryMethod.webSearch:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const WebSearchScreen()),
        );
        break;
      case EntryMethod.access:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                const AddContractScreen(entryType: EntryType.zugang),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    final tabs = <Widget>[
      DashboardScreen(
        onMenu: _openSettings,
        onBell: _openHeirs,
        onShowAllContracts: () => _setTab(1),
        onManageHeirs: _openHeirs,
      ),
      const ContractsScreen(),
      const HeirsScreen(showFab: false),
      const SettingsScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _tab, children: tabs),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: _onFabPressed,
        backgroundColor: AppColors.primary,
        elevation: 0,
        highlightElevation: 0,
        shape: const CircleBorder(),
        child: Icon(
          _tab == 2 ? Icons.person_add_outlined : Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
      bottomNavigationBar: _BottomBar(
        index: _tab,
        onTap: _setTab,
        labels: _BottomBarLabels(
          overview: l.navOverview,
          contracts: l.navContracts,
          heirs: l.navHeirs,
          more: l.navMore,
        ),
      ),
    );
  }
}

class _BottomBarLabels {
  final String overview;
  final String contracts;
  final String heirs;
  final String more;

  const _BottomBarLabels({
    required this.overview,
    required this.contracts,
    required this.heirs,
    required this.more,
  });
}

class _BottomBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  final _BottomBarLabels labels;

  const _BottomBar({
    required this.index,
    required this.onTap,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: AppColors.surfaceCard,
      elevation: 0,
      padding: EdgeInsets.zero,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      height: 64,
      child: Row(
        children: [
          Expanded(
            child: _BarItem(
              icon: Icons.grid_view_rounded,
              label: labels.overview,
              selected: index == 0,
              onTap: () => onTap(0),
            ),
          ),
          Expanded(
            child: _BarItem(
              icon: Icons.description_outlined,
              label: labels.contracts,
              selected: index == 1,
              onTap: () => onTap(1),
            ),
          ),
          // Spacer for the FAB notch
          const SizedBox(width: 64),
          Expanded(
            child: _BarItem(
              icon: Icons.favorite_outline,
              label: labels.heirs,
              selected: index == 2,
              onTap: () => onTap(2),
            ),
          ),
          Expanded(
            child: _BarItem(
              icon: Icons.more_horiz,
              label: labels.more,
              selected: index == 3,
              onTap: () => onTap(3),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _BarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textTertiary;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
