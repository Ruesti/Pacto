import 'package:supabase_flutter/supabase_flutter.dart';
import '../database/database.dart';
import 'backup_payload_mapper.dart';
import 'crypto_service.dart';

class NoBackupFoundException implements Exception {
  const NoBackupFoundException();
  @override
  String toString() => 'Kein Cloud-Backup fuer dieses Konto vorhanden.';
}

/// Optionale, Account-gebundene Backup-Ebene (E-Mail/Passwort) fuer echte
/// Wiederherstellung nach Geraeteverlust. Laeuft komplett getrennt vom
/// anonymen, `device_id`-basierten Sync in [CloudSyncService] — beide koennen
/// nebeneinander bestehen.
class AccountVaultService {
  final AppDatabase _db;
  final CryptoService _crypto;

  AccountVaultService(this._db, this._crypto);

  SupabaseClient get _client => Supabase.instance.client;

  Session? get currentSession => _client.auth.currentSession;
  bool get isLoggedIn => currentSession != null;

  Future<AuthResponse> signUp(String email, String password) {
    return _client.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> signIn(String email, String password) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() => _client.auth.signOut();

  Future<void> requestPasswordReset(String email) {
    return _client.auth.resetPasswordForEmail(email);
  }

  /// Verifiziert den 6-stelligen Code aus der Reset-Mail, setzt das neue
  /// Passwort und verpackt den Escrow neu. Danach ist eine Session aktiv, wie
  /// nach einem normalen Login.
  Future<void> confirmPasswordReset({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    await _client.auth.verifyOTP(
      type: OtpType.recovery,
      email: email,
      token: otp,
    );
    await _client.auth.updateUser(UserAttributes(password: newPassword));
    await rotateEscrow(newPassword);
  }

  Future<String> _buildEncryptedPayload() async {
    final contracts = await _db.contractsDao.getAll();
    final heirs = await _db.heirsDao.getAll();
    final payload = buildBackupPayload(contracts: contracts, heirs: heirs);
    return _crypto.encryptJson(payload);
  }

  /// Legt beim ersten Login/Signup dieses Kontos einen Backup-Eintrag an,
  /// falls noch keiner existiert. Idempotent — kann nach jedem Login
  /// gefahrlos aufgerufen werden (repariert auch einen abgebrochenen ersten
  /// Push nach). Braucht das Passwort nur fuer den Escrow, nicht fuer den
  /// Payload selbst.
  Future<void> ensureVaultPushed(String password) async {
    final userId = currentSession?.user.id;
    if (userId == null) return;
    final existing = await _client
        .from('account_vaults')
        .select('user_id')
        .eq('user_id', userId)
        .maybeSingle();
    if (existing != null) return;

    final aesKeyB64 = await _crypto.exportKeyBase64();
    final escrow = await _crypto.encryptKeyForEscrow(aesKeyB64, password);
    await _client.from('account_vaults').insert({
      'user_id': userId,
      'encrypted_payload': await _buildEncryptedPayload(),
      'key_salt': escrow.saltBase64,
      'encrypted_key': escrow.encryptedKeyJson,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  /// Aktualisiert nur den verschluesselten Contracts+Heirs-Payload — kein
  /// Passwort noetig, da der echte AES-Key bereits lokal vorliegt. Das ist
  /// der Pfad, den der bestehende "Jetzt synchronisieren"-Button fuer
  /// eingeloggte Nutzer verwendet (siehe CloudSyncService.pushAll).
  Future<void> pushPayloadOnly() async {
    final userId = currentSession?.user.id;
    if (userId == null) return;
    await _client.from('account_vaults').update({
      'encrypted_payload': await _buildEncryptedPayload(),
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('user_id', userId);
  }

  /// Laedt das Backup fuer das eingeloggte Konto herunter, entschluesselt den
  /// Sync-Key mit [password] und importiert Contracts+Heirs in die lokale DB
  /// — bestehende lokale Eintraege werden dabei ERSETZT (siehe
  /// [ContractsDao.replaceAll]/[HeirsDao.replaceAll]). Wirft
  /// [NoBackupFoundException], wenn (noch) kein Backup existiert, und
  /// [WrongPasswordException] (aus crypto_service.dart) bei falschem Passwort.
  Future<void> restoreFromAccount(String password) async {
    final userId = currentSession?.user.id;
    if (userId == null) {
      throw StateError('restoreFromAccount erfordert eine aktive Session.');
    }
    final row = await _client
        .from('account_vaults')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    if (row == null) throw const NoBackupFoundException();

    final aesKeyB64 = await _crypto.decryptEscrowKey(
      saltBase64: row['key_salt'] as String,
      encryptedKeyJson: row['encrypted_key'] as String,
      secret: password,
    );
    await _crypto.importKeyBase64(aesKeyB64);
    final payload =
        await _crypto.decryptJson(row['encrypted_payload'] as String);
    await _applyRestoredPayload(payload);
  }

  Future<void> _applyRestoredPayload(Map<String, dynamic> payload) async {
    final contracts = (payload['contracts'] as List)
        .cast<Map<String, dynamic>>()
        .map(contractCompanionFromMap)
        .toList();
    final heirs = (payload['heirs'] as List)
        .cast<Map<String, dynamic>>()
        .map(heirCompanionFromMap)
        .toList();
    await _db.contractsDao.replaceAll(contracts);
    await _db.heirsDao.replaceAll(heirs);
  }

  /// Verpackt den lokal aktuell vorhandenen AES-Key neu mit [newPassword] und
  /// schreibt Escrow + Payload per Upsert. Existiert lokal (noch) kein
  /// urspruenglicher Sync-Key mehr (Geraet UND Passwort verloren), erzeugt
  /// `CryptoService.exportKeyBase64()` automatisch einen frischen Key — die
  /// Zeile wird dann faktisch als neuer, leerer Tresor unter dem neuen
  /// Passwort angelegt. Das ist der bewusste Trade-off aus dem Design-Doc.
  Future<void> rotateEscrow(String newPassword) async {
    final userId = currentSession?.user.id;
    if (userId == null) return;
    final aesKeyB64 = await _crypto.exportKeyBase64();
    final escrow = await _crypto.encryptKeyForEscrow(aesKeyB64, newPassword);
    await _client.from('account_vaults').upsert({
      'user_id': userId,
      'key_salt': escrow.saltBase64,
      'encrypted_key': escrow.encryptedKeyJson,
      'encrypted_payload': await _buildEncryptedPayload(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
