import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'supabase_sync_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Einstellungen')),
      body: ListView(
        children: [
          _section('Daten & Sync'),
          ListTile(
            leading: const Icon(Icons.cloud_outlined),
            title: const Text('Cloud-Sync (Supabase)'),
            subtitle: const Text('Optionales verschlüsseltes Backup'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const SupabaseSyncScreen())),
          ),
          _section('App'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Version'),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Datenschutz'),
            subtitle: const Text(
                'Daten bleiben lokal auf deinem Gerät'),
          ),
          _section('Freemium'),
          ListTile(
            leading: const Icon(Icons.star_outline),
            title: const Text('Vollzugang freischalten'),
            subtitle:
                const Text('Mehr als 5 Verträge · einmalig ~2,99 €'),
            trailing: OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'In-App-Kauf kommt in Phase 10 (Store-Release)'),
                  ),
                );
              },
              child: const Text('Kaufen'),
            ),
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
