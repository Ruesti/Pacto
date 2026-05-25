import 'package:flutter/material.dart';
import '../../domain/models/contract_category.dart';
import '../l10n/enum_labels.dart';
import '../l10n/l10n_extension.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class CategoryPill extends StatelessWidget {
  final ContractCategory category;

  const CategoryPill({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final fg =
        AppColors.categoryFg[category.name] ?? AppColors.textSecondary;
    final bg =
        AppColors.categoryBg[category.name] ?? AppColors.surfaceElevated;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.badge),
      child: Text(
        category.localizedLabel(context.l10n),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
