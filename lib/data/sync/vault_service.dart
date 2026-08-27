import 'dart:convert';
import 'package:drift/drift.dart' show Value;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../data/providers/heir_password_policy_provider.dart';
import '../../features/heirs/share_export_service.dart';
import '../database/database.dart';
import 'crypto_service.dart';

const _kDeviceId = 'pacto.sync.device_id';
const _kVaultEnabled = 'pacto.vault.enabled';
const _kVaultIntervalDays = 'pacto.vault.interval_days';
const _kVaultOwnerEmail = 'pacto.vault.owner_email';
const _kVaultLastSync = 'pacto.vault.last_sync_at';
const _kVaultHeartbeatFailed = 'pacto.vault.heartbeat_failed';
const _kVaultHeartbeatLastOk = 'pacto.vault.heartbeat_last_ok';

class VaultSettings {
  final bool enabled;
  final int intervalDays;
  final String ownerEmail;

  const VaultSettings({
    required this.enabled,
    required this.intervalDays,
    required this.ownerEmail,
  });

  static const empty =
      VaultSettings(enabled: false, intervalDays: 90, ownerEmail: '');
}

class VaultService {
  final AppDatabase _db;
  final CryptoService _crypto;

  VaultService(this._db, this._crypto);

  static Future<String> deviceId() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_kDeviceId);
    if (id == null) {
      id = const Uuid().v4();
      await prefs.setString(_kDeviceId, id);
    }
    return id;
  }

  static Future<VaultSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return VaultSettings(
      enabled: prefs.getBool(_kVaultEnabled) ?? false,
      intervalDays: prefs.getInt(_kVaultIntervalDays) ?? 90,
      ownerEmail: prefs.getString(_kVaultOwnerEmail) ?? '',
    );
  }

  static Future<void> saveSettings(VaultSettings s) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kVaultEnabled, s.enabled);
    await prefs.setInt(_kVaultIntervalDays, s.intervalDays);
    await prefs.setString(_kVaultOwnerEmail, s.ownerEmail);
  }

  static Future<DateTime?> lastSyncAt() async {
    final prefs = await SharedPreferences.getInstance();
    final millis = prefs.getInt(_kVaultLastSync);
    return millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
  }

  /// True, wenn das letzte Lebenszeichen NICHT uebertragen werden konnte. Die
  /// Tresor-UI zeigt das als Warnzustand an (Phase 2).
  static Future<bool> heartbeatFailed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kVaultHeartbeatFailed) ?? false;
  }

  static Future<void> _setHeartbeatHealthy(bool ok) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kVaultHeartbeatFailed, !ok);
    if (ok) {
      await prefs.setInt(
          _kVaultHeartbeatLastOk, DateTime.now().millisecondsSinceEpoch);
    }
  }

  /// Loescht saemtliche Serverdaten dieses Geraets: vault_payloads,
  /// vault_settings, sync_data, heartbeats. Row Level Security begrenzt jede
  /// Loeschung zusaetzlich auf die eigenen Zeilen. Wirft bei einem Fehler —
  /// der Aufrufer MUSS das behandeln (kein stilles Scheitern). Ist zugleich der
  /// DSGVO-Art.-17-Loeschpfad (BRIEF_PACTO_FIX.md §0.3).
  static Future<void> deleteAllServerData() async {
    final client = Supabase.instance.client;
    final id = await deviceId();
    await client.from('vault_payloads').delete().eq('device_id', id);
    await client.from('vault_settings').delete().eq('device_id', id);
    await client.from('sync_data').delete().eq('device_id', id);
    await client.from('heartbeats').delete().eq('device_id', id);

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kVaultHeartbeatFailed);
    await prefs.remove(_kVaultHeartbeatLastOk);
    await prefs.remove(_kVaultLastSync);
  }

  /// "Ich-bin-noch-da"-Signal. Setzt confirmed_at = now() im Tresor und
  /// uebertraegt zugleich die aktuellen Owner-Settings (Email, Intervall,
  /// enabled). Kann gefahrlos bei jedem App-Resume gerufen werden.
  static Future<void> heartbeat({String? ownerName}) async {
    final settings = await loadSettings();
    if (!settings.enabled) return;
    if (settings.ownerEmail.isEmpty) return;
    final id = await deviceId();
    try {
      // functions.invoke haengt automatisch das Session-JWT an und wirft bei
      // Nicht-2xx eine FunctionException — das ist die Statuscode-Pruefung.
      final res = await Supabase.instance.client.functions.invoke(
        'vault-heartbeat',
        body: {
          'deviceId': id,
          'ownerName': ownerName ?? '',
          'ownerEmail': settings.ownerEmail,
          'intervalDays': settings.intervalDays,
          'enabled': settings.enabled,
        },
      );
      await _setHeartbeatHealthy(res.status >= 200 && res.status < 300);
    } catch (_) {
      // Kein Absturz beim Resume, aber den Fehlzustand merken — die Tresor-UI
      // zeigt ihn an, damit ein dauerhaft scheiternder Heartbeat nicht
      // unbemerkt bleibt.
      await _setHeartbeatHealthy(false);
    }
  }

  /// Rendert pro Erbe einen Brief (Text-Body) gem. seiner Access-Stufe und
  /// der globalen HeirPasswordPolicy und ueberschreibt damit die fuer dieses
  /// Geraet auf dem Server hinterlegten Payloads.
  Future<int> syncPayloads({required String ownerName}) async {
    final settings = await loadSettings();
    if (!settings.enabled) return 0;
    final heirs = await _db.heirsDao.getAll();
    if (heirs.isEmpty) return 0;
    final contracts = await _db.contractsDao.getAll();
    final policy = await getHeirPasswordPolicy();

    // Der automatische Tresor kennt den Erben-PIN nicht (nur dessen Hash) und
    // kann den Maximum-Modus daher NICHT liefern. Statt still auf 'none' zu
    // fallen, wird das bewusst gemacht: fuer den automatischen Versand gilt
    // eine passwortlose Variante (nur Vertragsliste + Hinweise, keine
    // Login-Passwoerter). Der Maximum-Modus bleibt fuer den MANUELLEN Export
    // erhalten, wo der PIN verfuegbar ist. In der UI ist das ausgewiesen
    // (heir_password_policy_screen).
    final vaultPolicy =
        policy == HeirPasswordPolicy.maximum ? HeirPasswordPolicy.none : policy;

    final payloads = <Map<String, dynamic>>[];
    for (final h in heirs) {
      if (!h.isActive) continue;
      final visibleContracts = h.accessLevel == HeirAccess.nurListe
          ? contracts.map(_redactSensitive).toList()
          : contracts;

      // Body (Mail-Inhalt) und PDF (Anhang) nutzen dieselbe vaultPolicy, damit
      // beide konsistent sind. heirPin: null — im automatischen Versand nie
      // verfuegbar.
      final String body;
      final List<int> pdfBytes;
      try {
        body = await ShareExportService.buildHeirExportText(
          contracts: visibleContracts,
          ownerName: ownerName,
          heir: h,
          policy: vaultPolicy,
          crypto: _crypto,
          heirPin: null,
        );
        pdfBytes = await ShareExportService.buildHeirExportPdfBytes(
          contracts: visibleContracts,
          ownerName: ownerName,
          heir: h,
          policy: vaultPolicy,
          crypto: _crypto,
          heirPin: null,
        );
      } catch (_) {
        // Einzelnes Rendering darf das ganze Sync nicht killen.
        continue;
      }

      payloads.add({
        'heirId': h.id,
        'heirName': h.name,
        'heirEmail': h.email,
        'policy': vaultPolicy.name,
        'body': body,
        'pdfB64': base64Encode(pdfBytes),
      });
    }

    final id = await deviceId();
    // functions.invoke haengt das Session-JWT an und wirft FunctionException
    // bei Nicht-2xx (z. B. 401 ohne Session) — der Aufrufer erfaehrt den Fehler.
    final resp = await Supabase.instance.client.functions.invoke(
      'vault-sync',
      body: {'deviceId': id, 'payloads': payloads},
    );
    if (resp.status < 200 || resp.status >= 300) {
      throw Exception('vault-sync fehlgeschlagen (HTTP ${resp.status})');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kVaultLastSync, DateTime.now().millisecondsSinceEpoch);
    return payloads.length;
  }

  /// Reduziert einen Vertrag fuer Erben mit Stufe `nurListe`: Login-Daten,
  /// Kontaktdaten und Notizen werden geleert.
  Contract _redactSensitive(Contract c) => c.copyWith(
        contactPhone: const Value(null),
        contactEmail: const Value(null),
        contactUrl: const Value(null),
        loginUsername: const Value(null),
        loginPasswordCt: const Value(null),
        loginHint: const Value(null),
        notes: '',
      );
}
