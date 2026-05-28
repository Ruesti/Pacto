import 'dart:convert';
import 'package:drift/drift.dart' show Value;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../config/supabase_config.dart';
import '../../data/providers/heir_password_policy_provider.dart';
import '../../features/heirs/share_export_service.dart';
import '../database/database.dart';
import 'crypto_service.dart';

const _kDeviceId = 'pacto.sync.device_id';
const _kVaultEnabled = 'pacto.vault.enabled';
const _kVaultIntervalDays = 'pacto.vault.interval_days';
const _kVaultOwnerEmail = 'pacto.vault.owner_email';
const _kVaultLastSync = 'pacto.vault.last_sync_at';

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

  /// "Ich-bin-noch-da"-Signal. Setzt confirmed_at = now() im Tresor und
  /// uebertraegt zugleich die aktuellen Owner-Settings (Email, Intervall,
  /// enabled). Kann gefahrlos bei jedem App-Resume gerufen werden.
  static Future<void> heartbeat({String? ownerName}) async {
    final settings = await loadSettings();
    if (!settings.enabled) return;
    if (settings.ownerEmail.isEmpty) return;
    final id = await deviceId();
    await http.post(
      Uri.parse('${SupabaseConfig.projectUrl}/functions/v1/vault-heartbeat'),
      headers: {
        'Content-Type': 'application/json',
        'apikey': SupabaseConfig.anonKey,
        'Authorization': 'Bearer ${SupabaseConfig.anonKey}',
      },
      body: jsonEncode({
        'deviceId': id,
        'ownerName': ownerName ?? '',
        'ownerEmail': settings.ownerEmail,
        'intervalDays': settings.intervalDays,
        'enabled': true,
      }),
    );
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

    final payloads = <Map<String, dynamic>>[];
    for (final h in heirs) {
      if (!h.isActive) continue;
      final visibleContracts = h.accessLevel == HeirAccess.nurListe
          ? contracts.map(_redactSensitive).toList()
          : contracts;
      try {
        // Im Maximum-Modus weiss der Server den PIN nicht — Erbe muss ihn
        // vorab kennen. Wir rendern hier nur die *Klartext-Anteile* (Name,
        // Anbieter, Kuendigung, Hinweise) ohne Passwoerter.
        // Im Komfort-Modus wandern die Klartext-Passwoerter in den Body,
        // den der Server in die Mail kopiert.
        final body = await ShareExportService.buildHeirExportText(
          contracts: visibleContracts,
          ownerName: ownerName,
          heir: h,
          policy: policy,
          crypto: _crypto,
          heirPin: null,
        ).catchError((_) async {
          // Maximum ohne PIN wirft — wir liefern dann nur den
          // Hinweis-Body ohne Login-Daten ab.
          return await ShareExportService.buildHeirExportText(
            contracts: visibleContracts,
            ownerName: ownerName,
            heir: h,
            policy: HeirPasswordPolicy.none,
            crypto: _crypto,
          );
        });
        payloads.add({
          'heirId': h.id,
          'heirName': h.name,
          'heirEmail': h.email,
          'policy': policy.name,
          'body': body,
        });
      } catch (_) {
        // Einzelnes Rendering darf das ganze Sync nicht killen.
        continue;
      }
    }

    final id = await deviceId();
    final resp = await http.post(
      Uri.parse('${SupabaseConfig.projectUrl}/functions/v1/vault-sync'),
      headers: {
        'Content-Type': 'application/json',
        'apikey': SupabaseConfig.anonKey,
        'Authorization': 'Bearer ${SupabaseConfig.anonKey}',
      },
      body: jsonEncode({'deviceId': id, 'payloads': payloads}),
    );
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('vault-sync HTTP ${resp.statusCode}: ${resp.body}');
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
