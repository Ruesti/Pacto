import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../config/supabase_config.dart';
import '../database/database.dart';
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

  CloudSyncService(this._db, this._crypto);

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

  Map<String, dynamic> _contractToMap(Contract c) => {
        'id': c.id,
        'name': c.name,
        'category': c.category.name,
        'provider': c.provider,
        'contactPhone': c.contactPhone,
        'contactEmail': c.contactEmail,
        'contactUrl': c.contactUrl,
        'cancellationMethod': c.cancellationMethod.name,
        'cancellationInstructions': c.cancellationInstructions,
        'noticePeriod': c.noticePeriod,
        'monthlyCost': c.monthlyCost,
        'billingCycle': c.billingCycle.name,
        'documentPath': c.documentPath,
        'notes': c.notes,
        'contractStart': c.contractStart?.toIso8601String(),
        'nextRenewal': c.nextRenewal?.toIso8601String(),
        'createdAt': c.createdAt.toIso8601String(),
        'updatedAt': c.updatedAt.toIso8601String(),
      };

  Map<String, dynamic> _heirToMap(Heir h) => {
        'id': h.id,
        'name': h.name,
        'email': h.email,
        'pinHash': h.pinHash,
        'accessLevel': h.accessLevel.name,
        'isActive': h.isActive,
        'createdAt': h.createdAt.toIso8601String(),
      };

  Future<void> pushAll() async {
    final cfg = await loadConfig();
    if (!cfg.isComplete) {
      throw Exception('Sync nicht konfiguriert — bitte Supabase-URL und Anon Key hinterlegen.');
    }

    final contracts = await _db.contractsDao.getAll();
    final heirs = await _db.heirsDao.getAll();

    final payload = {
      'version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'contracts': contracts.map(_contractToMap).toList(),
      'heirs': heirs.map(_heirToMap).toList(),
    };

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
