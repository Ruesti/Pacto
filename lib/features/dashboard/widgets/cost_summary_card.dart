import 'package:flutter/material.dart';
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
    final cs = Theme.of(context).colorScheme;
    return Card(
      color: cs.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monatliche Ausgaben',
                    style: TextStyle(
                        color: cs.onPrimary.withValues(alpha: 0.8), fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatCurrency(totalMonthlyCost),
                    style: TextStyle(
                      color: cs.onPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${formatCurrency(totalMonthlyCost * 12)} pro Jahr',
                    style: TextStyle(
                        color: cs.onPrimary.withValues(alpha: 0.7), fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$contractCount',
                  style: TextStyle(
                    color: cs.onPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  contractCount == 1 ? 'Vertrag' : 'Verträge',
                  style: TextStyle(
                      color: cs.onPrimary.withValues(alpha: 0.8), fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
