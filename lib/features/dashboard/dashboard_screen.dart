import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/database.dart';
import '../../data/providers/database_provider.dart';
import '../../data/providers/user_name_provider.dart';
import '../../data/providers/verification_settings_provider.dart';
import '../../shared/l10n/l10n_extension.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_spacing.dart';
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

    final allEntries = contractsAsync.valueOrNull ?? const <Contract>[];
    final heirs = heirsAsync.valueOrNull ?? const [];

    // Das Dashboard ist die Kosten-/Vertragsuebersicht — Zugaenge zaehlen hier
    // nicht mit (sie haben keine Kosten/Verlaengerung).
    final contracts =
        allEntries.where((c) => c.entryType.isVertrag).toList();

    final now = DateTime.now();
    final cancellationsSoon = contracts.where((c) {
      final r = c.nextRenewal;
      if (r == null) return false;
      final diff = r.difference(now).inDays;
      return diff >= 0 && diff <= 30;
    }).length;
    // "Verträge" und "Abos" schließen sich gegenseitig aus und folgen der
    // Nutzer-Einordnung (contractKind), nicht mehr dem Abrechnungszyklus — eine
    // monatlich gezahlte Versicherung kann so ein Vertrag bleiben.
    final subscriptions =
        contracts.where((c) => c.contractKind.isAbo).length;
    final nonSubscriptionContracts = contracts.length - subscriptions;

    final recent = List<Contract>.of(contracts)
      ..sort((a, b) => (b.updatedAt).compareTo(a.updatedAt));
    final topRecent = recent.take(4).toList();

    // Ueberfaellige Logins (nur wenn die Bestaetigungs-Erinnerung aktiv ist).
    final verify = ref.watch(verificationSettingsProvider).valueOrNull ??
        const VerificationSettings();
    final overdueLogins = verify.manualReminderEnabled
        ? allEntries.where((c) {
            if (c.loginPasswordCt == null) return false;
            final v = c.loginLastVerifiedAt;
            return v == null ||
                now.difference(v).inDays > verify.staleThresholdDays;
          }).length
        : 0;

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
                contracts: nonSubscriptionContracts,
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
          if (overdueLogins > 0)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              sliver: SliverToBoxAdapter(
                child: _ReminderBanner(
                  title: l.verifyReminderBannerTitle,
                  body: l.verifyReminderBannerBody(overdueLogins),
                  onTap: onShowAllContracts,
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

/// Hinweis-Banner auf dem Dashboard, wenn gespeicherte Logins laenger nicht
/// bestaetigt wurden. Tippen fuehrt zur Vertragsliste.
class _ReminderBanner extends StatelessWidget {
  final String title;
  final String body;
  final VoidCallback onTap;

  const _ReminderBanner({
    required this.title,
    required this.body,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: AppRadius.card,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.statusAmberBg,
          borderRadius: AppRadius.card,
          border: const Border(
            left: BorderSide(color: AppColors.statusAmber, width: 3),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.lock_clock_outlined,
                color: AppColors.statusAmber, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(body,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
