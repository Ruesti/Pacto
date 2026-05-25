import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/l10n/l10n_extension.dart';
import '../../shared/locale_provider.dart';
import '../onboarding/onboarding_screen.dart';
import '../premium/premium_service.dart';
import 'supabase_sync_screen.dart';
import 'vault_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final purchased = ref.watch(premiumProvider);
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: ListView(
        children: [
          _section(l.settingsSectionData),
          ListTile(
            leading: const Icon(Icons.cloud_outlined),
            title: Text(l.settingsCloudSync),
            subtitle: Text(l.settingsCloudSyncSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const SupabaseSyncScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.lock_clock_outlined),
            title: Text(l.settingsVault),
            subtitle: Text(l.settingsVaultSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const VaultScreen())),
          ),
          _section(l.settingsSectionApp),
          ListTile(
            leading: const Icon(Icons.replay_outlined),
            title: Text(l.settingsReplay),
            onTap: () async {
              await markOnboardingDone(false);
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (ctx) => OnboardingScreen(
                      onDone: () =>
                          Navigator.of(ctx).popUntil((r) => r.isFirst),
                    ),
                  ),
                  (r) => false,
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: Text(l.settingsLanguage),
            subtitle: Text(_currentLocaleName(currentLocale, l)),
            onTap: () => _showLanguagePicker(context, ref, currentLocale, l),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l.settingsVersion),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l.settingsPrivacy),
            subtitle: Text(l.settingsPrivacySubtitle),
          ),
          _section(l.settingsSectionFreemium),
          if (purchased)
            ListTile(
              leading: const Icon(Icons.verified, color: Colors.green),
              title: Text(l.settingsFullAccess),
              subtitle: Text(l.settingsFullAccessSubtitle),
            )
          else
            ListTile(
              leading: const Icon(Icons.star_outline),
              title: Text(l.settingsUnlockFull),
              subtitle: Text(l.settingsUnlockSubtitle),
              trailing: OutlinedButton(
                onPressed: () async {
                  final unlocked = await showPurchaseDialog(context);
                  if (unlocked) {
                    await ref
                        .read(premiumProvider.notifier)
                        .setPurchased(true);
                  }
                },
                child: Text(l.settingsBuyButton),
              ),
            ),
          if (purchased)
            ListTile(
              leading: const Icon(Icons.restart_alt),
              title: Text(l.settingsResetPurchase),
              subtitle: Text(l.settingsResetSubtitle),
              onTap: () =>
                  ref.read(premiumProvider.notifier).setPurchased(false),
            ),
        ],
      ),
    );
  }

  String _currentLocaleName(Locale? locale, l) {
    if (locale == null) return l.langSystem;
    return switch (locale.languageCode) {
      'de' => l.langDe,
      'en' => l.langEn,
      _ => locale.languageCode,
    };
  }

  void _showLanguagePicker(
      BuildContext context, WidgetRef ref, Locale? current, l) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l.settingsLanguage,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            _langTile(context, ref, null, l.langSystem, current),
            _langTile(
                context, ref, const Locale('de'), l.langDe, current),
            _langTile(
                context, ref, const Locale('en'), l.langEn, current),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _langTile(BuildContext context, WidgetRef ref, Locale? locale,
      String label, Locale? current) {
    final selected = locale?.languageCode == current?.languageCode &&
        (locale == null) == (current == null);
    return ListTile(
      title: Text(label),
      trailing: selected
          ? Icon(Icons.check,
              color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: () {
        ref.read(localeProvider.notifier).setLocale(locale);
        Navigator.pop(context);
      },
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey),
      ),
    );
  }
}
