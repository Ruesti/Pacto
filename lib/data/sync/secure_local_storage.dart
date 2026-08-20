import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// [LocalStorage] fuer die Supabase-Session, hinterlegt in
/// `flutter_secure_storage` (Android Keystore / iOS Keychain) statt im
/// Klartext-SharedPreferences.
///
/// Grund (BRIEF_PACTO_FIX.md §0.1, Option A): Die anonyme Session enthaelt das
/// Refresh-Token, mit dem das Geraet auf seine eigenen Serverzeilen zugreift.
/// Es darf das Geraet nicht unverschluesselt verlassen (siehe auch Phase 4,
/// Backup-Ausschluss).
class SecureLocalStorage extends LocalStorage {
  static const _sessionKey = 'pacto.supabase.session';

  final FlutterSecureStorage _storage;

  SecureLocalStorage([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
  }

  @override
  Future<bool> hasAccessToken() async {
    return _storage.containsKey(key: _sessionKey);
  }

  @override
  Future<String?> accessToken() async {
    return _storage.read(key: _sessionKey);
  }

  @override
  Future<void> removePersistedSession() async {
    await _storage.delete(key: _sessionKey);
  }

  @override
  Future<void> persistSession(String persistSessionString) async {
    await _storage.write(key: _sessionKey, value: persistSessionString);
  }
}
