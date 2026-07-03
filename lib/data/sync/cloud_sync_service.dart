import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../config/supabase_config.dart';
import '../database/database.dart';
import 'account_vault_service.dart';
import 'backup_payload_mapper.dart';
import 'crypto_service.dart';

const _keyDeviceId = 'pacto.sync.device_id';
const _keyLastSync = 'pacto.sync.last_sync';

class SyncConfig {
  final String supabaseUrl;
  final String anonKey;
  const SyncConfig({required this.supabaseUrl, required this.anonKey});

  bool get isComplete => supabaseUrl.isNotEmpty && anonKey.isNotEmpty;
}

class CloudSyncService {
  final AppDatabase _db;
  final CryptoService _crypto;
  final AccountVaultService _accountVault;

  CloudSyncService(this._db, this._crypto, this._accountVault);

  static Future<String> _deviceId() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_keyDeviceId);
    if (id == null) {
      id = const Uuid().v4();
      await prefs.setString(_keyDeviceId, id);
    }
    return id;
  }

  // Fest eingebaute Projekt-Konfiguration — KI-Scan und Cloud-Sync laufen
  // ohne jede Einrichtung durch den Nutzer ueber das Pacto-Supabase-Projekt.
  static Future<SyncConfig> loadConfig() async => const SyncConfig(
        supabaseUrl: SupabaseConfig.projectUrl,
        anonKey: SupabaseConfig.anonKey,
      );

  static Future<DateTime?> lastSyncAt() async {
    final prefs = await SharedPreferences.getInstance();
    final millis = prefs.getInt(_keyLastSync);
    return millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
  }

  Future<void> pushAll() async {
    if (Supabase.instance.client.auth.currentSession != null) {
      // Eingeloggt: Backup laeuft ueber das Account-Vault (siehe
      // AccountVaultService), nicht ueber den anonymen device_id-Pfad.
      await _accountVault.pushPayloadOnly();
      return;
    }

    final cfg = await loadConfig();
    if (!cfg.isComplete) {
      throw Exception('Sync nicht konfiguriert — bitte Supabase-URL und Anon Key hinterlegen.');
    }

    final contracts = await _db.contractsDao.getAll();
    final heirs = await _db.heirsDao.getAll();

    final payload = buildBackupPayload(contracts: contracts, heirs: heirs);

    final encrypted = await _crypto.encryptJson(payload);
    final deviceId = await _deviceId();

    final url = '${cfg.supabaseUrl}/rest/v1/sync_data?on_conflict=device_id';
    final resp = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'apikey': cfg.anonKey,
        'Authorization': 'Bearer ${cfg.anonKey}',
        'Prefer': 'resolution=merge-duplicates,return=minimal',
      },
      body: jsonEncode({
        'device_id': deviceId,
        'encrypted_payload': encrypted,
        'updated_at': DateTime.now().toIso8601String(),
      }),
    );

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Sync-Fehler: HTTP ${resp.statusCode} — ${resp.body}');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLastSync, DateTime.now().millisecondsSinceEpoch);
  }

  /// Sendet ein Lebenszeichen fuer den Inaktivitaets-Tresor.
  /// Statisch, damit der Hintergrund-Heartbeat (workmanager) die Methode aus
  /// einem eigenen Isolate ohne Datenbank-/CryptoService-Instanz aufrufen kann.
  static Future<void> sendHeartbeat() async {
    final cfg = await loadConfig();
    if (!cfg.isComplete) return;
    final deviceId = await _deviceId();
    await http.post(
      Uri.parse('${cfg.supabaseUrl}/rest/v1/heartbeats?on_conflict=device_id'),
      headers: {
        'Content-Type': 'application/json',
        'apikey': cfg.anonKey,
        'Authorization': 'Bearer ${cfg.anonKey}',
        'Prefer': 'resolution=merge-duplicates,return=minimal',
      },
      body: jsonEncode({
        'device_id': deviceId,
        'confirmed_at': DateTime.now().toIso8601String(),
      }),
    );
  }
}
