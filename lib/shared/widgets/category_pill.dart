import 'package:flutter/material.dart';
import '../../domain/models/contract_category.dart';
import '../theme/app_theme.dart';

class CategoryPill extends StatelessWidget {
  final ContractCategory category;

  const CategoryPill({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.categoryColors[category.name] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        category.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
