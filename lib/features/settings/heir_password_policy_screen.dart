import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/heir_password_policy_provider.dart';
import '../../shared/l10n/l10n_extension.dart';
import '../../shared/theme/app_colors.dart';

class HeirPasswordPolicyScreen extends ConsumerWidget {
  const HeirPasswordPolicyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final policyAsync = ref.watch(heirPasswordPolicyProvider);
    final current = policyAsync.valueOrNull ?? HeirPasswordPolicy.none;

    return Scaffold(
      appBar: AppBar(title: Text(l.heirPolicyTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              l.heirPolicyIntro,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 16),
          _PolicyCard(
            icon: Icons.do_not_disturb_alt_outlined,
            iconColor: AppColors.textTertiary,
            title: l.heirPolicyNoneTitle,
            body: l.heirPolicyNoneBody,
            selected: current == HeirPasswordPolicy.none,
            onTap: () => _select(context, ref, HeirPasswordPolicy.none),
          ),
          const SizedBox(height: 12),
          _PolicyCard(
            icon: Icons.mail_outline,
            iconColor: AppColors.statusBlue,
            title: l.heirPolicyKomfortTitle,
            body: l.heirPolicyKomfortBody,
            selected: current == HeirPasswordPolicy.komfort,
            onTap: () => _select(context, ref, HeirPasswordPolicy.komfort),
          ),
          const SizedBox(height: 12),
          _PolicyCard(
            icon: Icons.lock_outline,
            iconColor: AppColors.statusGreen,
            title: l.heirPolicyMaximumTitle,
            body: l.heirPolicyMaximumBody,
            selected: current == HeirPasswordPolicy.maximum,
            warning: current == HeirPasswordPolicy.maximum
                ? l.heirPolicyWarnPinShared
                : null,
            onTap: () => _select(context, ref, HeirPasswordPolicy.maximum),
          ),
        ],
      ),
    );
  }

  Future<void> _select(
    BuildContext context,
    WidgetRef ref,
    HeirPasswordPolicy policy,
  ) async {
    await ref.read(heirPasswordPolicyProvider.notifier).set(policy);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.heirPolicySaved)),
    );
  }
}

class _PolicyCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final String? warning;
  final bool selected;
  final VoidCallback onTap;

  const _PolicyCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.selected,
    required this.onTap,
    this.warning,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor =
        selected ? AppColors.primary : AppColors.surfaceBorder;
    return Material(
      color: AppColors.surfaceCard,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: borderColor, width: selected ? 1.5 : 0.5),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 20, color: iconColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (selected)
                    const Icon(Icons.check_circle,
                        size: 22, color: AppColors.primary),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                body,
                style: const TextStyle(
                    color: AppColors.textSecondary, height: 1.35),
              ),
              if (warning != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.statusAmberBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          size: 18, color: AppColors.statusAmber),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          warning!,
                          style: const TextStyle(
                              color: AppColors.statusAmber, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
