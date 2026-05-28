import 'package:flutter/material.dart';

import '../../../shared/l10n/l10n_extension.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/theme/app_text_styles.dart';

class EmergencyBanner extends StatelessWidget {
  final bool hasHeirs;
  final VoidCallback onManage;

  const EmergencyBanner({
    super.key,
    required this.hasHeirs,
    required this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final accent = hasHeirs ? AppColors.statusGreen : AppColors.statusAmber;
    final accentBg =
        hasHeirs ? AppColors.statusGreenBg : AppColors.statusAmberBg;
    final headline =
        hasHeirs ? l.emergencyHeadlineNotified : l.emergencyHeadlineEmpty;
    final body = hasHeirs ? l.emergencyBodyNotified : l.emergencyBodyEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 3, color: accent),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: accentBg,
                        borderRadius: AppRadius.icon,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.shield_outlined,
                        size: 22,
                        color: accent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.emergencyLabel.toUpperCase(),
                            style: AppTextStyles.sectionLabel,
                          ),
                          const SizedBox(height: 4),
                          Text(headline, style: AppTextStyles.listTitle),
                          const SizedBox(height: 4),
                          Text(
                            body,
                            style: AppTextStyles.listSubtitle,
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: accentBg,
                                foregroundColor: accent,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: AppRadius.badge,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onPressed: onManage,
                              child: Text(l.emergencyAction),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
