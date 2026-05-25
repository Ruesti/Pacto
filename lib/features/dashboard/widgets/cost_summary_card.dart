import 'package:flutter/material.dart';
import '../../../shared/l10n/l10n_extension.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/utils/currency_formatter.dart';

class CostSummaryCard extends StatelessWidget {
  final double totalMonthlyCost;
  final int contractCount;

  const CostSummaryCard({
    super.key,
    required this.totalMonthlyCost,
    required this.contractCount,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.monthlyCosts, style: AppTextStyles.costSub),
                const SizedBox(height: 4),
                Text(
                  formatCurrency(totalMonthlyCost),
                  style: AppTextStyles.costHero,
                ),
                const SizedBox(height: 2),
                Text(
                  l.perYear(formatCurrency(totalMonthlyCost * 12)),
                  style: AppTextStyles.costSub,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$contractCount', style: AppTextStyles.statNumber),
              Text(
                l.contractsLabel(contractCount),
                style: AppTextStyles.statLabel,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
