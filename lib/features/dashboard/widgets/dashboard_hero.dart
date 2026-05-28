import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';

class DashboardHero extends StatelessWidget {
  final String greeting;
  final String subtitle;
  final VoidCallback onMenu;
  final VoidCallback onBell;

  const DashboardHero({
    super.key,
    required this.greeting,
    required this.subtitle,
    required this.onMenu,
    required this.onBell,
  });

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return SizedBox(
      height: topPad + 220,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, topPad + 8, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _CircleIconButton(icon: Icons.menu, onTap: onMenu),
                const Spacer(),
                _CircleIconButton(
                  icon: Icons.notifications_none,
                  onTap: onBell,
                ),
              ],
            ),
            const Spacer(),
            Text(greeting, style: AppTextStyles.heroTitle),
            const SizedBox(height: 6),
            Text(subtitle, style: AppTextStyles.heroSubtitle),
          ],
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceCard.withValues(alpha: 0.55),
      shape: const CircleBorder(
        side: BorderSide(color: AppColors.surfaceBorder, width: 0.5),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 20, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
