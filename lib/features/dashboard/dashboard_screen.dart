import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/database.dart';
import '../../data/providers/database_provider.dart';
import '../../data/providers/user_name_provider.dart';
import '../../shared/l10n/l10n_extension.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../contract_detail/contract_detail_screen.dart';
import 'widgets/contract_list_tile.dart';
import 'widgets/dashboard_hero.dart';
import 'widgets/emergency_banner.dart';
import 'widgets/overview_stats_card.dart';

/// The "Übersicht" tab. Renders the hero, the 4-stat overview card,
/// the most recent contracts and the emergency banner.
class DashboardScreen extends ConsumerWidget {
  final VoidCallback onMenu;
  final VoidCallback onBell;
  final VoidCallback onShowAllContracts;
  final VoidCallback onManageHeirs;

  const DashboardScreen({
    super.key,
    required this.onMenu,
    required this.onBell,
    required this.onShowAllContracts,
    required this.onManageHeirs,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final userName = ref.watch(userNameProvider).valueOrNull;
    final contractsAsync = ref.watch(contractsStreamProvider);
    final heirsAsync = ref.watch(heirsStreamProvider);

    final greeting = (userName != null && userName.isNotEmpty)
        ? l.dashboardGreeting(userName)
        : l.dashboardGreetingAnon;

    final contracts = contractsAsync.valueOrNull ?? const <Contract>[];
    final heirs = heirsAsync.valueOrNull ?? const [];

    final now = DateTime.now();
    final cancellationsSoon = contracts.where((c) {
      final r = c.nextRenewal;
      if (r == null) return false;
      final diff = r.difference(now).inDays;
      return diff >= 0 && diff <= 30;
    }).length;
    final subscriptions = contracts
        .where((c) => c.billingCycle == BillingCycle.monthly)
        .length;

    final recent = List<Contract>.of(contracts)
      ..sort((a, b) => (b.updatedAt).compareTo(a.updatedAt));
    final topRecent = recent.take(4).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: DashboardHero(
              greeting: greeting,
              subtitle: l.dashboardSubtitle,
              onMenu: onMenu,
              onBell: onBell,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            sliver: SliverToBoxAdapter(
              child: OverviewStatsCard(
                contracts: contracts.length,
                cancellationsSoon: cancellationsSoon,
                subscriptions: subscriptions,
                heirs: heirs.length,
              ),
            ),
          ),
          if (topRecent.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l.sectionYourContracts.toUpperCase(),
                        style: AppTextStyles.sectionLabel,
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: onShowAllContracts,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 4),
                        child: Row(
                          children: [
                            Text(
                              l.sectionShowAll,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(
                              Icons.chevron_right,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (topRecent.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              sliver: SliverToBoxAdapter(
                child: ContractListCard(
                  children: [
                    for (final c in topRecent)
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
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            sliver: SliverToBoxAdapter(
              child: EmergencyBanner(
                hasHeirs: heirs.isNotEmpty,
                onManage: onManageHeirs,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
