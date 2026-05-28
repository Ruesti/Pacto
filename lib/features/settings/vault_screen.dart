import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/providers/database_provider.dart';
import '../../data/providers/user_name_provider.dart';
import '../../data/sync/cloud_sync_service.dart';
import '../../data/sync/vault_service.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/l10n/l10n_extension.dart';

const _keyVaultConfirmedAt = 'pacto.vault.confirmed_at';

class VaultScreen extends ConsumerStatefulWidget {
  const VaultScreen({super.key});

  @override
  ConsumerState<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends ConsumerState<VaultScreen> {
  late VaultSettings _settings;
  final _emailCtrl = TextEditingController();
  DateTime? _confirmedAt;
  DateTime? _lastSyncAt;
  bool _loading = true;
  bool _busyAlive = false;
  bool _busySync = false;

  static const _intervals = [30, 60, 90, 180];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final settings = await VaultService.loadSettings();
    final prefs = await SharedPreferences.getInstance();
    final confirmedMillis = prefs.getInt(_keyVaultConfirmedAt);
    final lastSync = await VaultService.lastSyncAt();
    setState(() {
      _settings = settings;
      _emailCtrl.text = settings.ownerEmail;
      _confirmedAt = confirmedMillis == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(confirmedMillis);
      _lastSyncAt = lastSync;
      _loading = false;
    });
  }

  Future<void> _persist() async {
    await VaultService.saveSettings(_settings);
  }

  Future<void> _toggle(bool v) async {
    if (v && _emailCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.vaultOwnerEmailRequired)),
      );
      return;
    }
    setState(() {
      _settings = VaultSettings(
        enabled: v,
        intervalDays: _settings.intervalDays,
        ownerEmail: _emailCtrl.text.trim(),
      );
    });
    await _persist();
  }

  Future<void> _setInterval(int days) async {
    setState(() {
      _settings = VaultSettings(
        enabled: _settings.enabled,
        intervalDays: days,
        ownerEmail: _settings.ownerEmail,
      );
    });
    await _persist();
  }

  Future<void> _saveEmail() async {
    setState(() {
      _settings = VaultSettings(
        enabled: _settings.enabled,
        intervalDays: _settings.intervalDays,
        ownerEmail: _emailCtrl.text.trim(),
      );
    });
    await _persist();
  }

  Future<void> _confirmAlive() async {
    final l = context.l10n;
    setState(() => _busyAlive = true);
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyVaultConfirmedAt, now.millisecondsSinceEpoch);
    final ownerName = ref.read(userNameProvider).valueOrNull;
    try {
      await CloudSyncService.sendHeartbeat();
      await VaultService.heartbeat(ownerName: ownerName);
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _confirmedAt = now;
      _busyAlive = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.vaultConfirmSnackbar)),
    );
  }

  Future<void> _syncNow() async {
    final l = context.l10n;
    setState(() => _busySync = true);
    final ownerName = ref.read(userNameProvider).valueOrNull ?? 'Pacto-User';
    final db = ref.read(databaseProvider);
    final crypto = ref.read(cryptoServiceProvider);
    final vault = VaultService(db, crypto);
    try {
      final count = await vault.syncPayloads(ownerName: ownerName);
      _lastSyncAt = DateTime.now();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.vaultSyncSuccess(count))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.errorMessage(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _busySync = false);
    }
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  String _confirmedLabel(AppLocalizations l) =>
      _confirmedAt == null ? l.vaultNever : _formatDate(_confirmedAt!);

  String _lastSyncLabel(AppLocalizations l) =>
      _lastSyncAt == null ? l.vaultLastSyncNever : _formatDate(_lastSyncAt!);

  String? _expiryLabel() {
    if (_confirmedAt == null) return null;
    final expiry = _confirmedAt!.add(Duration(days: _settings.intervalDays));
    return _formatDate(expiry);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final expiry = _expiryLabel();
    return Scaffold(
      appBar: AppBar(title: Text(l.vaultTitle)),
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
                                color:
                                    Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(l.vaultInfoTitle,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(l.vaultInfoDesc,
                            style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    onSubmitted: (_) => _saveEmail(),
                    onEditingComplete: _saveEmail,
                    decoration: InputDecoration(
                      labelText: l.vaultOwnerEmailLabel,
                      helperText: l.vaultOwnerEmailHint,
                      helperMaxLines: 2,
                      prefixIcon: const Icon(Icons.mark_email_unread_outlined),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  value: _settings.enabled,
                  onChanged: _toggle,
                  title: Text(l.vaultToggle),
                  subtitle: Text(l.vaultToggleSubtitle),
                  secondary: const Icon(Icons.lock_clock_outlined),
                ),
                const SizedBox(height: 8),
                if (_settings.enabled) ...[
                  _intervalPicker(l),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(l.vaultLastConfirmed),
                    subtitle: Text(_confirmedLabel(l)),
                  ),
                  if (expiry != null)
                    ListTile(
                      leading: const Icon(Icons.event_outlined),
                      title: Text(l.vaultExpiry),
                      subtitle: Text(expiry),
                    ),
                  ListTile(
                    leading: const Icon(Icons.cloud_upload_outlined),
                    title: Text(l.vaultLastSyncLabel),
                    subtitle: Text(_lastSyncLabel(l)),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: _busyAlive ? null : _confirmAlive,
                    icon: _busyAlive
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child:
                                CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.check_circle_outline),
                    label: Text(l.vaultConfirmButton),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _busySync ? null : _syncNow,
                    icon: _busySync
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child:
                                CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.upload_outlined),
                    label: Text(l.vaultSyncNowButton),
                  ),
                ],
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.vaultServerTitle,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(
                          l.vaultServerDesc,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _intervalPicker(AppLocalizations l) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.vaultIntervalLabel,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            children: [
              for (final d in _intervals)
                ChoiceChip(
                  label: Text(l.vaultIntervalDays(d)),
                  selected: _settings.intervalDays == d,
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
