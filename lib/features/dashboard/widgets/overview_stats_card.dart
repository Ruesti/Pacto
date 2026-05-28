import 'package:flutter/material.dart';

import '../../../shared/l10n/l10n_extension.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/theme/app_text_styles.dart';

class OverviewStatsCard extends StatelessWidget {
  final int contracts;
  final int cancellationsSoon;
  final int subscriptions;
  final int heirs;

  const OverviewStatsCard({
    super.key,
    required this.contracts,
    required this.cancellationsSoon,
    required this.subscriptions,
    required this.heirs,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.sectionOverview.toUpperCase(),
            style: AppTextStyles.sectionLabel,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.description_outlined,
                  fg: AppColors.primary,
                  bg: AppColors.primaryLight,
                  number: contracts,
                  label: l.statContracts,
                  hint: l.statContractsHint,
                ),
              ),
              Expanded(
                child: _StatTile(
                  icon: Icons.event_busy_outlined,
                  fg: AppColors.statusAmber,
                  bg: AppColors.statusAmberBg,
                  number: cancellationsSoon,
                  label: l.statCancellations,
                  hint: l.statCancellationsHint,
                ),
              ),
              Expanded(
                child: _StatTile(
                  icon: Icons.autorenew,
                  fg: AppColors.statusGreen,
                  bg: AppColors.statusGreenBg,
                  number: subscriptions,
                  label: l.statSubscriptions,
                  hint: l.statSubscriptionsHint,
                ),
              ),
              Expanded(
                child: _StatTile(
                  icon: Icons.group_outlined,
                  fg: AppColors.statusBlue,
                  bg: AppColors.statusBlueBg,
                  number: heirs,
                  label: l.statHeirs,
                  hint: l.statHeirsHint,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color fg;
  final Color bg;
  final int number;
  final String label;
  final String hint;

  const _StatTile({
    required this.icon,
    required this.fg,
    required this.bg,
    required this.number,
    required this.label,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: bg, borderRadius: AppRadius.icon),
          alignment: Alignment.center,
          child: Icon(icon, size: 22, color: fg),
        ),
        const SizedBox(height: 10),
        Text('$number', style: AppTextStyles.statNumber),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.statLabel.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          hint,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textTertiary,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
