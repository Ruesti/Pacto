import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/providers/database_provider.dart';

const _keyVaultEnabled = 'pacto.vault.enabled';
const _keyVaultIntervalDays = 'pacto.vault.interval_days';
const _keyVaultConfirmedAt = 'pacto.vault.confirmed_at';

class VaultScreen extends ConsumerStatefulWidget {
  const VaultScreen({super.key});

  @override
  ConsumerState<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends ConsumerState<VaultScreen> {
  bool _enabled = false;
  int _intervalDays = 90;
  DateTime? _confirmedAt;
  bool _loading = true;
  bool _busy = false;

  static const _intervals = [30, 60, 90, 180];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final millis = prefs.getInt(_keyVaultConfirmedAt);
    setState(() {
      _enabled = prefs.getBool(_keyVaultEnabled) ?? false;
      _intervalDays = prefs.getInt(_keyVaultIntervalDays) ?? 90;
      _confirmedAt =
          millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
      _loading = false;
    });
  }

  Future<void> _toggle(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyVaultEnabled, v);
    setState(() => _enabled = v);
  }

  Future<void> _setInterval(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyVaultIntervalDays, days);
    setState(() => _intervalDays = days);
  }

  Future<void> _confirmAlive() async {
    setState(() => _busy = true);
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyVaultConfirmedAt, now.millisecondsSinceEpoch);
    try {
      await ref.read(cloudSyncServiceProvider).sendHeartbeat();
    } catch (_) {
      // Lokales Lebenszeichen reicht, auch wenn Sync nicht erreichbar ist.
    }
    if (!mounted) return;
    setState(() {
      _confirmedAt = now;
      _busy = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lebenszeichen aktualisiert')),
    );
  }

  String _confirmedLabel() {
    if (_confirmedAt == null) return 'noch nie';
    final d = _confirmedAt!;
    return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
  }

  String? _expiryLabel() {
    if (_confirmedAt == null) return null;
    final expiry = _confirmedAt!.add(Duration(days: _intervalDays));
    return '${expiry.day.toString().padLeft(2, '0')}.${expiry.month.toString().padLeft(2, '0')}.${expiry.year}';
  }

  @override
  Widget build(BuildContext context) {
    final expiry = _expiryLabel();
    return Scaffold(
      appBar: AppBar(title: const Text('Lebenszeichen-Tresor')),
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
                            Icon(Icons.favorite_outline,
                                color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 8),
                            const Text('Für den Fall der Fälle',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Wenn du eine Weile nicht mehr aktiv warst, '
                          'erhalten deine hinterlegten Erben automatisch Zugang. '
                          'Jede App-Nutzung und der Button unten bestätigen, dass alles in Ordnung ist.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  value: _enabled,
                  onChanged: _toggle,
                  title: const Text('Tresor aktivieren'),
                  subtitle: const Text(
                      'Benötigt aktivierten Cloud-Sync für die Weitergabe'),
                  secondary: const Icon(Icons.lock_clock_outlined),
                ),
                const SizedBox(height: 8),
                if (_enabled) ...[
                  _intervalPicker(),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.history),
                    title: const Text('Letzte Bestätigung'),
                    subtitle: Text(_confirmedLabel()),
                  ),
                  if (expiry != null)
                    ListTile(
                      leading: const Icon(Icons.event_outlined),
                      title: const Text('Frist läuft ab'),
                      subtitle: Text(expiry),
                    ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: _busy ? null : _confirmAlive,
                    icon: _busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.check_circle_outline),
                    label: const Text('Mir geht es gut — Frist zurücksetzen'),
                  ),
                ],
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Server-seitiger Trigger',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text(
                          'Die automatische Weiterleitung an die Erben übernimmt eine Supabase-Edge-Function '
                          '(pg_cron + PDF-Generierung + E-Mail-Versand). Diese Komponente ist außerhalb '
                          'der App vorbereitet und nicht Teil der lokalen Installation.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _intervalPicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Intervall',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            children: [
              for (final d in _intervals)
                ChoiceChip(
                  label: Text('$d Tage'),
                  selected: _intervalDays == d,
                  onSelected: (sel) {
                    if (sel) _setInterval(d);
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}
