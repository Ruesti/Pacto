import 'package:flutter/material.dart';
import '../utils/currency_formatter.dart';

class CostBadge extends StatelessWidget {
  final double monthlyCost;

  const CostBadge({super.key, required this.monthlyCost});

  @override
  Widget build(BuildContext context) {
    return Text(
      formatMonthlyCost(monthlyCost),
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 13,
      ),
    );
  }
}
