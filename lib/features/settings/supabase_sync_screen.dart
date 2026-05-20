import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SupabaseSyncScreen extends StatefulWidget {
  const SupabaseSyncScreen({super.key});

  @override
  State<SupabaseSyncScreen> createState() => _SupabaseSyncScreenState();
}

class _SupabaseSyncScreenState extends State<SupabaseSyncScreen> {
  bool _syncEnabled = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _syncEnabled = prefs.getBool('supabase_sync_enabled') ?? false;
      _loading = false;
    });
  }

  Future<void> _toggle(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('supabase_sync_enabled', val);
    setState(() => _syncEnabled = val);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cloud-Sync')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.lock_outlined,
                                color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 8),
                            const Text('Verschlüsseltes Backup',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Deine Daten werden vor dem Upload AES-256 verschlüsselt. '
                          'Der Schlüssel verlässt niemals dein Gerät.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  value: _syncEnabled,
                  onChanged: _toggle,
                  title: const Text('Sync aktivieren'),
                  subtitle: const Text(
                      'Benötigt Supabase-Konfiguration (Phase 9)'),
                  secondary: const Icon(Icons.cloud_outlined),
                ),
                const SizedBox(height: 16),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Lebenszeichen-Tresor',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text(
                          'Wenn du eine Zeit lang kein Lebenszeichen gibst, '
                          'erhalten deine Erben automatisch alle Vertragsdaten. '
                          'Konfiguration folgt in Phase 9.',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
