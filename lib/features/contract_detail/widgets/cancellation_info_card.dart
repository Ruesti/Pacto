import 'package:flutter/material.dart';
import '../../../data/database/database.dart';
import '../../../shared/l10n/enum_labels.dart';
import '../../../shared/l10n/l10n_extension.dart';
import '../../../shared/utils/date_formatter.dart';

class CancellationInfoCard extends StatelessWidget {
  final Contract contract;

  const CancellationInfoCard({super.key, required this.contract});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = context.l10n;
    return Card(
      color: cs.errorContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.cancel_outlined, color: cs.error, size: 20),
                const SizedBox(width: 8),
                Text(l.cancellationCardTitle,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: cs.error,
                        fontSize: 15)),
              ],
            ),
            const SizedBox(height: 12),
            _row(l.cancellationMethodLabel,
                contract.cancellationMethod.localizedLabel(l)),
            if (contract.noticePeriod.isNotEmpty)
              _row(l.cancellationPeriodLabel, contract.noticePeriod),
            if (contract.nextRenewal != null)
              _row(
                l.cancellationRenewalLabel,
                '${formatDate(contract.nextRenewal)} (${daysUntilL10n(contract.nextRenewal, l)})',
              ),
            if (contract.cancellationInstructions.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(l.cancellationInstructionsLabel,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 4),
              Text(contract.cancellationInstructions,
                  style: const TextStyle(fontSize: 13, height: 1.4)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text('$label:',
                style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
