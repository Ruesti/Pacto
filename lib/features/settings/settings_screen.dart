import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../onboarding/onboarding_screen.dart';
import '../premium/premium_service.dart';
import 'scan_config_screen.dart';
import 'supabase_sync_screen.dart';
import 'vault_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchased = ref.watch(premiumProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Einstellungen')),
      body: ListView(
        children: [
          _section('Daten & Sync'),
          ListTile(
            leading: const Icon(Icons.document_scanner_outlined),
            title: const Text('KI-Scan'),
            subtitle: const Text('Supabase Edge Function konfigurieren'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const ScanConfigScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.cloud_outlined),
            title: const Text('Cloud-Sync (Supabase)'),
            subtitle: const Text('Verschlüsseltes Backup, AES-256'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const SupabaseSyncScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.lock_clock_outlined),
            title: const Text('Lebenszeichen-Tresor'),
            subtitle: const Text('Automatische Weitergabe an Erben'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const VaultScreen())),
          ),
          _section('App'),
          ListTile(
            leading: const Icon(Icons.replay_outlined),
            title: const Text('Einführung wiederholen'),
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
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
          const ListTile(
            leading: Icon(Icons.privacy_tip_outlined),
            title: Text('Datenschutz'),
            subtitle: Text('Daten bleiben lokal auf deinem Gerät'),
          ),
          _section('Freemium'),
          if (purchased)
            const ListTile(
              leading: Icon(Icons.verified, color: Colors.green),
              title: Text('Vollzugang freigeschaltet'),
              subtitle: Text('Unbegrenzt viele Verträge'),
            )
          else
            ListTile(
              leading: const Icon(Icons.star_outline),
              title: const Text('Vollzugang freischalten'),
              subtitle:
                  const Text('Mehr als 5 Verträge · einmalig ~2,99 €'),
              trailing: OutlinedButton(
                onPressed: () async {
                  final unlocked = await showPurchaseDialog(context);
                  if (unlocked) {
                    await ref
                        .read(premiumProvider.notifier)
                        .setPurchased(true);
                  }
                },
                child: const Text('Kaufen'),
              ),
            ),
          if (purchased)
            ListTile(
              leading: const Icon(Icons.restart_alt),
              title: const Text('Kauf zurücksetzen (Test)'),
              subtitle: const Text(
                  'Nur für Entwickler — entfernt den Vollzugang lokal'),
              onTap: () =>
                  ref.read(premiumProvider.notifier).setPurchased(false),
            ),
        ],
      ),
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
