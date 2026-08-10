import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/export.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _keyEncryptionKey = 'pacto.sync.aes_key_b64';

class CryptoService {
  static const _macTagBits = 128;

  static final Random _rng = Random.secure();
  static const _secure = FlutterSecureStorage();

  // Einmal geladener AES-Key, danach im Speicher gecacht (CryptoService ist ein
  // Provider-Singleton). Vermeidet wiederholte secure-storage-Reads.
  Uint8List? _cachedKey;

  static Uint8List _randomBytes(int len) =>
      Uint8List.fromList(List.generate(len, (_) => _rng.nextInt(256)));

  /// Laedt den AES-Sync-Key. Liegt er noch in den (unsicheren)
  /// SharedPreferences einer aelteren Version, wird sein **Wert unveraendert**
  /// in flutter_secure_storage uebernommen — sonst liessen sich bereits
  /// gespeicherte `loginPasswordCt` nicht mehr entschluesseln.
  Future<Uint8List> _loadOrCreateKey() async {
    if (_cachedKey != null) return _cachedKey!;

    final fromSecure = await _secure.read(key: _keyEncryptionKey);
    if (fromSecure != null && fromSecure.isNotEmpty) {
      return _cachedKey = base64Decode(fromSecure);
    }

    // Migration: alten Wert aus SharedPreferences uebernehmen (Wert erhalten!).
    final prefs = await SharedPreferences.getInstance();
    final legacy = prefs.getString(_keyEncryptionKey);
    if (legacy != null && legacy.isNotEmpty) {
      await _secure.write(key: _keyEncryptionKey, value: legacy);
      await prefs.remove(_keyEncryptionKey);
      return _cachedKey = base64Decode(legacy);
    }

    // Frischer Key.
    final key = _randomBytes(32);
    await _secure.write(key: _keyEncryptionKey, value: base64Encode(key));
    return _cachedKey = key;
  }

  Future<String> encryptJson(Map<String, dynamic> payload) async {
    final key = await _loadOrCreateKey();
    final iv = _randomBytes(12);
    final plaintext = Uint8List.fromList(utf8.encode(jsonEncode(payload)));

    final cipher = GCMBlockCipher(AESEngine())
      ..init(true, AEADParameters(KeyParameter(key), _macTagBits, iv, Uint8List(0)));
    final cipherText = cipher.process(plaintext);

    return jsonEncode({
      'v': 1,
      'iv': base64Encode(iv),
      'ct': base64Encode(cipherText),
    });
  }

  Future<Map<String, dynamic>> decryptJson(String blob) async {
    final key = await _loadOrCreateKey();
    final envelope = jsonDecode(blob) as Map<String, dynamic>;
    final iv = base64Decode(envelope['iv'] as String);
    final ct = base64Decode(envelope['ct'] as String);
    final cipher = GCMBlockCipher(AESEngine())
      ..init(false, AEADParameters(KeyParameter(key), _macTagBits, iv, Uint8List(0)));
    final plain = cipher.process(ct);
    return jsonDecode(utf8.decode(plain)) as Map<String, dynamic>;
  }

  Future<String> exportKeyBase64() async {
    final key = await _loadOrCreateKey();
    return base64Encode(key);
  }

  Future<void> importKeyBase64(String base64Key) async {
    final bytes = base64Decode(base64Key);
    if (bytes.length != 32) {
      throw const FormatException('Schlüssel muss 32 Byte / 256 Bit lang sein');
    }
    await _secure.write(key: _keyEncryptionKey, value: base64Key);
    _cachedKey = bytes;
  }

  // ────────── String-Helpers ──────────
  // AES-256-GCM auf einen einzelnen String mit dem App-Key. Wird fuer das
  // Vertrags-Passwort verwendet — das landet im selben verschluesselten
  // {v, iv, ct}-Envelope wie der Cloud-Sync, sodass derselbe Key gilt.

  Future<String> encryptString(String plaintext) async {
    final key = await _loadOrCreateKey();
    return _encryptStringWithKey(plaintext, key);
  }

  Future<String> decryptString(String blob) async {
    final key = await _loadOrCreateKey();
    return _decryptStringWithKey(blob, key);
  }

  // ────────── PIN-derived Key (Maximum-Modus) ──────────
  // Im Maximum-Modus wird das Passwort fuer den Erben mit einem Key
  // verschluesselt, der aus dessen vorab geteiltem PIN abgeleitet wird.
  // Server kann nichts entschluesseln — Erbe braucht den PIN.

  static const _pbkdf2Iterations = 100000;

  Uint8List _deriveKeyFromSecret(String secret, Uint8List salt) {
    final params = Pbkdf2Parameters(salt, _pbkdf2Iterations, 32);
    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))..init(params);
    return pbkdf2.process(Uint8List.fromList(utf8.encode(secret)));
  }

  /// Verschluesselt `plaintext` mit einem aus `pin` abgeleiteten Schluessel.
  /// Der Envelope enthaelt das Salt mit, sodass der Erbe nur PIN + Envelope
  /// braucht — kein zusaetzliches Geheimnis.
  Future<String> encryptWithPin(String plaintext, String pin) async {
    final salt = _randomBytes(16);
    final key = _deriveKeyFromSecret(pin, salt);
    final cipherEnvelope = _encryptStringWithKey(plaintext, key);
    final inner = jsonDecode(cipherEnvelope) as Map<String, dynamic>;
    return jsonEncode({
      'v': 1,
      'mode': 'pin',
      'salt': base64Encode(salt),
      'iv': inner['iv'],
      'ct': inner['ct'],
    });
  }

  /// Entschluesselt ein per `encryptWithPin` erzeugtes Envelope.
  /// Wirft `Exception` wenn der PIN falsch ist (GCM-Tag-Mismatch).
  Future<String> decryptWithPin(String blob, String pin) async {
    final envelope = jsonDecode(blob) as Map<String, dynamic>;
    final salt = base64Decode(envelope['salt'] as String);
    final key = _deriveKeyFromSecret(pin, salt);
    final inner = jsonEncode({
      'v': envelope['v'],
      'iv': envelope['iv'],
      'ct': envelope['ct'],
    });
    return _decryptStringWithKey(inner, key);
  }

  // ────────── Passwort-Escrow (Account-Recovery) ──────────
  // Verpackt den echten AES-Sync-Key zusaetzlich mit einem aus dem
  // Account-Passwort abgeleiteten Schluessel, damit er nach Kontowechsel auf
  // einem neuen Geraet mit dem Passwort zurueckgewonnen werden kann. Nutzt
  // dieselbe PBKDF2-Ableitung wie der PIN-Modus, nur mit dem Passwort als
  // Geheimnis statt dem Erben-PIN.

  Future<EscrowEnvelope> encryptKeyForEscrow(
      String aesKeyBase64, String secret) async {
    final salt = _randomBytes(16);
    final key = _deriveKeyFromSecret(secret, salt);
    final encryptedKeyJson = _encryptStringWithKey(aesKeyBase64, key);
    return EscrowEnvelope(
      saltBase64: base64Encode(salt),
      encryptedKeyJson: encryptedKeyJson,
    );
  }

  Future<String> decryptEscrowKey({
    required String saltBase64,
    required String encryptedKeyJson,
    required String secret,
  }) async {
    final salt = base64Decode(saltBase64);
    final key = _deriveKeyFromSecret(secret, salt);
    try {
      return _decryptStringWithKey(encryptedKeyJson, key);
    } catch (_) {
      throw const WrongPasswordException();
    }
  }

  // ────────── intern ──────────

  String _encryptStringWithKey(String plaintext, Uint8List key) {
    final iv = _randomBytes(12);
    final bytes = Uint8List.fromList(utf8.encode(plaintext));
    final cipher = GCMBlockCipher(AESEngine())
      ..init(true,
          AEADParameters(KeyParameter(key), _macTagBits, iv, Uint8List(0)));
    final cipherText = cipher.process(bytes);
    return jsonEncode({
      'v': 1,
      'iv': base64Encode(iv),
      'ct': base64Encode(cipherText),
    });
  }

  String _decryptStringWithKey(String blob, Uint8List key) {
    final envelope = jsonDecode(blob) as Map<String, dynamic>;
    final iv = base64Decode(envelope['iv'] as String);
    final ct = base64Decode(envelope['ct'] as String);
    final cipher = GCMBlockCipher(AESEngine())
      ..init(false,
          AEADParameters(KeyParameter(key), _macTagBits, iv, Uint8List(0)));
    final plain = cipher.process(ct);
    return utf8.decode(plain);
  }
}

class EscrowEnvelope {
  final String saltBase64;
  final String encryptedKeyJson;
  const EscrowEnvelope(
      {required this.saltBase64, required this.encryptedKeyJson});
}

class WrongPasswordException implements Exception {
  const WrongPasswordException();
  @override
  String toString() => 'Falsches Passwort.';
}
