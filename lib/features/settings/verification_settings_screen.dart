import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/verification_settings_provider.dart';
import '../../shared/l10n/l10n_extension.dart';
import '../../shared/theme/app_colors.dart';

/// Wahl der optionalen Passwort-Pruef-Features (Erinnerung, Datenleck-Check,
/// Staerke). Alles laeuft lokal bzw. via k-Anonymity — keine Passwoerter
/// verlassen das Geraet.
class VerificationSettingsScreen extends ConsumerWidget {
  const VerificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final settings = ref.watch(verificationSettingsProvider).valueOrNull ??
        const VerificationSettings();
    final notifier = ref.read(verificationSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l.verifyTitle)),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(l.verifyIntro,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary)),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active_outlined),
            title: Text(l.verifyManualReminder),
            subtitle: Text(l.verifyManualReminderSubtitle),
            value: settings.manualReminderEnabled,
            onChanged: notifier.setManualReminder,
          ),
          if (settings.manualReminderEnabled)
            ListTile(
              leading: const Icon(Icons.schedule_outlined),
              title: Text(l.verifyReminderInterval),
              trailing: DropdownButton<int>(
                value: settings.reminderMonths,
                underline: const SizedBox.shrink(),
                items: const [3, 6, 12, 24]
                    .map((m) => DropdownMenuItem(
                        value: m, child: Text(l.verifyReminderMonths(m))))
                    .toList(),
                onChanged: (v) {
                  if (v != null) notifier.setReminderMonths(v);
                },
              ),
            ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.shield_outlined),
            title: Text(l.verifyBreachCheck),
            subtitle: Text(l.verifyBreachCheckSubtitle),
            value: settings.breachCheckEnabled,
            onChanged: notifier.setBreachCheck,
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.bar_chart_outlined),
            title: Text(l.verifyStrengthCheck),
            subtitle: Text(l.verifyStrengthCheckSubtitle),
            value: settings.strengthCheckEnabled,
            onChanged: notifier.setStrengthCheck,
          ),
        ],
      ),
    );
  }
}
