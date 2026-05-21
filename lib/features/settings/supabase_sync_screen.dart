import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/providers/database_provider.dart';
import '../../data/sync/cloud_sync_service.dart';

const _keySyncEnabled = 'pacto.sync.enabled';

class SupabaseSyncScreen extends ConsumerStatefulWidget {
  const SupabaseSyncScreen({super.key});

  @override
  ConsumerState<SupabaseSyncScreen> createState() => _SupabaseSyncScreenState();
}

class _SupabaseSyncScreenState extends ConsumerState<SupabaseSyncScreen> {
  final _urlCtrl = TextEditingController();
  final _keyCtrl = TextEditingController();
  bool _syncEnabled = false;
  bool _loading = true;
  bool _busy = false;
  DateTime? _lastSync;
  String? _statusMessage;
  bool _statusIsError = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    _keyCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final cfg = await CloudSyncService.loadConfig();
    final last = await CloudSyncService.lastSyncAt();
    _urlCtrl.text = cfg.supabaseUrl;
    _keyCtrl.text = cfg.anonKey;
    setState(() {
      _syncEnabled = prefs.getBool(_keySyncEnabled) ?? false;
      _lastSync = last;
      _loading = false;
    });
  }

  Future<void> _saveConfig() async {
    await CloudSyncService.saveConfig(SyncConfig(
      supabaseUrl: _urlCtrl.text.trim(),
      anonKey: _keyCtrl.text.trim(),
    ));
    if (!mounted) return;
    setState(() {
      _statusMessage = 'Konfiguration gespeichert';
      _statusIsError = false;
    });
  }

  Future<void> _toggle(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySyncEnabled, val);
    setState(() => _syncEnabled = val);
  }

  Future<void> _syncNow() async {
    setState(() {
      _busy = true;
      _statusMessage = null;
    });
    try {
      await ref.read(cloudSyncServiceProvider).pushAll();
      final last = await CloudSyncService.lastSyncAt();
      if (!mounted) return;
      setState(() {
        _lastSync = last;
        _statusMessage = 'Sync erfolgreich';
        _statusIsError = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusMessage = e.toString();
        _statusIsError = true;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _lastSyncLabel() {
    if (_lastSync == null) return 'noch nie';
    final d = _lastSync!;
    return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
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
                            const Text('AES-256 verschlüsselt',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Deine Daten werden vor dem Upload mit AES-256-GCM verschlüsselt. '
                          'Der Schlüssel bleibt lokal auf deinem Gerät.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _sectionHeader('Supabase'),
                TextField(
                  controller: _urlCtrl,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'Supabase Projekt-URL',
                    hintText: 'https://<projekt>.supabase.co',
                    prefixIcon: Icon(Icons.link_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _keyCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Supabase Anon Key',
                    prefixIcon: Icon(Icons.key_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  onPressed: _busy ? null : _saveConfig,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Konfiguration speichern'),
                ),
                const SizedBox(height: 24),
                SwitchListTile(
                  value: _syncEnabled,
                  onChanged: _toggle,
                  title: const Text('Sync aktivieren'),
                  subtitle: const Text('Manuell oder automatisch beim Speichern'),
                  secondary: const Icon(Icons.cloud_outlined),
                ),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Letzter Sync'),
                  subtitle: Text(_lastSyncLabel()),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: _busy ? null : _syncNow,
                  icon: _busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.sync),
                  label: const Text('Jetzt synchronisieren'),
                ),
                if (_statusMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _statusIsError
                          ? Theme.of(context).colorScheme.errorContainer
                          : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _statusIsError
                              ? Icons.error_outline
                              : Icons.check_circle_outline,
                          color: _statusIsError
                              ? Theme.of(context).colorScheme.error
                              : Colors.green.shade800,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _statusMessage!,
                            style: TextStyle(
                              color: _statusIsError
                                  ? Theme.of(context).colorScheme.onErrorContainer
                                  : Colors.green.shade900,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Supabase-Schema',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text(
                          'Folgende Tabelle muss im Supabase-Projekt existieren:\n\n'
                          'create table sync_data (\n'
                          '  device_id uuid primary key,\n'
                          '  encrypted_payload text not null,\n'
                          '  updated_at timestamptz default now()\n'
                          ');\n\n'
                          'RLS so konfigurieren, dass jeder Inhaber des Anon-Keys '
                          'lesen/schreiben darf — die Daten sind ohnehin verschlüsselt.',
                          style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
