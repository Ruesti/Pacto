import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bgColor;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  factory StatusBadge.active(String label) => StatusBadge(
        label: label,
        color: AppColors.statusGreen,
        bgColor: AppColors.statusGreenBg,
      );

  factory StatusBadge.warning(String label) => StatusBadge(
        label: label,
        color: AppColors.statusAmber,
        bgColor: AppColors.statusAmberBg,
      );

  factory StatusBadge.info(String label) => StatusBadge(
        label: label,
        color: AppColors.statusBlue,
        bgColor: AppColors.statusBlueBg,
      );

  factory StatusBadge.error(String label) => StatusBadge(
        label: label,
        color: AppColors.statusRed,
        bgColor: AppColors.statusRedBg,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bgColor, borderRadius: AppRadius.badge),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
