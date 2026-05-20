import 'package:flutter/material.dart';
import '../../../data/database/database.dart';
import '../../../shared/widgets/category_pill.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../../shared/utils/date_formatter.dart';

class ContractListTile extends StatelessWidget {
  final Contract contract;
  final VoidCallback onTap;

  const ContractListTile({
    super.key,
    required this.contract,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contract.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      contract.provider,
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        CategoryPill(category: contract.category),
                        if (contract.nextRenewal != null) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.event_outlined,
                              size: 12, color: Colors.grey[500]),
                          const SizedBox(width: 2),
                          Text(
                            daysUntil(contract.nextRenewal),
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[600]),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                formatMonthlyCost(contract.monthlyCost),
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
