import 'package:flutter/material.dart';

import '../../../data/database/database.dart';
import '../../../shared/l10n/enum_labels.dart';
import '../../../shared/l10n/l10n_extension.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/theme/app_text_styles.dart';
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
    final l = context.l10n;
    final isZugang = contract.entryType.isZugang;
    final accessCat = contract.accessCategory ?? AccessCategory.sonstiges;

    final fg = isZugang
        ? (AppColors.accessCatFg[accessCat.name] ?? AppColors.primary)
        : (AppColors.categoryFg[contract.category.name] ?? AppColors.primary);
    final bg = isZugang
        ? (AppColors.accessCatBg[accessCat.name] ?? AppColors.primaryLight)
        : (AppColors.categoryBg[contract.category.name] ??
            AppColors.primaryLight);
    final subtitle = isZugang
        ? '${accessCat.localizedLabel(l)} · ${contract.provider}'
        : '${contract.contractKind.localizedLabel(l)} · ${contract.category.localizedLabel(l)} · ${contract.provider}';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _Logo(
                name: contract.name,
                fg: fg,
                bg: bg,
                icon: isZugang ? Icons.vpn_key : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contract.name,
                      style: AppTextStyles.listTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.listSubtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Zugaenge haben keine Kosten/Verlaengerung — rechts steht nur
              // ein Chevron-aehnlicher Hinweis bzw. nichts.
              if (isZugang)
                Icon(
                  contract.loginPasswordCt != null
                      ? Icons.lock_outline
                      : Icons.chevron_right,
                  size: 18,
                  color: AppColors.textTertiary,
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: formatBilledAmount(
                                contract.monthlyCost, contract.billingCycle),
                            style: AppTextStyles.listAmount,
                          ),
                          TextSpan(
                            text: ' ${contract.billingCycle.amountSuffix(l)}',
                            style: AppTextStyles.listDate,
                          ),
                        ],
                      ),
                    ),
                    if (contract.nextRenewal != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        l.nextPayment(formatDate(contract.nextRenewal)),
                        style: AppTextStyles.listDate,
                      ),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  final String name;
  final Color fg;
  final Color bg;
  // Wenn gesetzt, wird statt der Initiale dieses Icon gezeigt (z.B. fuer
  // Zugaenge ein Schluessel).
  final IconData? icon;

  const _Logo({
    required this.name,
    required this.fg,
    required this.bg,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name.characters.first.toUpperCase() : '?';
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.icon,
      ),
      alignment: Alignment.center,
      child: icon != null
          ? Icon(icon, color: fg, size: 20)
          : Text(
              initial,
              style: TextStyle(
                color: fg,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }
}

/// Card-style list wrapping a sequence of [ContractListTile]s with subtle
/// dividers, matching the dashboard "Deine Verträge" group.
class ContractListCard extends StatelessWidget {
  final List<Widget> children;

  const ContractListCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      items.add(children[i]);
      if (i != children.length - 1) {
        items.add(const Divider(
          height: 0.5,
          thickness: 0.5,
          indent: 68,
          endIndent: 16,
          color: AppColors.surfaceBorder,
        ));
      }
    }
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: items),
    );
  }
}
