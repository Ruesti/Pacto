import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../config/supabase_config.dart';
import '../database/database.dart';
import 'account_vault_service.dart';
import 'backup_payload_mapper.dart';
import 'crypto_service.dart';
import 'secure_local_storage.dart';

const _keyDeviceId = 'pacto.sync.device_id';
const _keyLastSync = 'pacto.sync.last_sync';

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

  static Future<DateTime?> lastSyncAt() async {
    final prefs = await SharedPreferences.getInstance();
    final millis = prefs.getInt(_keyLastSync);
    return millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
  }

  Future<void> pushAll() async {
    final session = Supabase.instance.client.auth.currentSession;

    // Eingeloggter Account (nicht anonym): Backup laeuft ueber das Account-Vault
    // (siehe AccountVaultService), nicht ueber den anonymen device_id-Pfad.
    if (session != null && !session.user.isAnonymous) {
      await _accountVault.pushPayloadOnly();
      return;
    }

    // Sonst: anonymer, device_id-basierter Pfad. Braucht eine (anonyme) Session,
    // damit RLS den sync_data-Upsert dem Geraet zuordnet.
    if (session == null) {
      throw Exception(
        'Kein Cloud-Zugriff — keine aktive Sitzung. Bitte die App neu starten.',
      );
    }

    final contracts = await _db.contractsDao.getAll();
    final heirs = await _db.heirsDao.getAll();

    final payload = buildBackupPayload(contracts: contracts, heirs: heirs);
    final encrypted = await _crypto.encryptJson(payload);
    final deviceId = await _deviceId();

    // Upsert ueber den Supabase-Client: haengt das Session-JWT an, RLS
    // ((select auth.uid()) = user_id) schuetzt die Zeile.
    await Supabase.instance.client.from('sync_data').upsert(
      {
        'device_id': deviceId,
        'user_id': session.user.id,
        'encrypted_payload': encrypted,
        'updated_at': DateTime.now().toIso8601String(),
      },
      onConflict: 'device_id',
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLastSync, DateTime.now().millisecondsSinceEpoch);
  }

  /// Sendet ein Lebenszeichen fuer den Inaktivitaets-Tresor.
  /// Statisch, damit der Hintergrund-Heartbeat (workmanager) die Methode aus
  /// einem eigenen Isolate aufrufen kann. Dort ist Supabase noch nicht
  /// initialisiert — wir ziehen es mit derselben Secure-Storage-LocalStorage
  /// nach, damit die persistierte (anonyme) Session wiederhergestellt und
  /// aufgefrischt wird und der Schreibzugriff RLS-konform laeuft.
  ///
  /// Schreibt in `vault_settings.confirmed_at` — DAS liest der Trigger. (Frueher
  /// in die Tabelle `heartbeats`, die der Trigger nie las: Befund 2-A.) Der
  /// Vorwarn-/Zustell-Zyklus wird zurueckgesetzt, `heir_notified_at` bleibt
  /// unangetastet. Aktualisiert nur eine bestehende Zeile (Tresor aktiv);
  /// existiert keine, passiert nichts.
  static Future<void> sendHeartbeat() async {
    SupabaseClient client;
    try {
      client = Supabase.instance.client;
    } catch (_) {
      await Supabase.initialize(
        url: SupabaseConfig.projectUrl,
        anonKey: SupabaseConfig.anonKey,
        authOptions: FlutterAuthClientOptions(localStorage: SecureLocalStorage()),
      );
      client = Supabase.instance.client;
    }

    final session = client.auth.currentSession;
    if (session == null) return; // keine Identitaet -> nichts zu bestaetigen

    final deviceId = await _deviceId();
    final now = DateTime.now().toIso8601String();
    await client.from('vault_settings').update({
      'confirmed_at': now,
      'warning_sent_at': null,
      'warning_count': 0,
      'notify_attempts': 0,
      'owner_alerted_at': null,
      'updated_at': now,
    }).eq('device_id', deviceId);
  }
}
