import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _keyEncryptionKey = 'pacto.sync.aes_key_b64';

class CryptoService {
  static const _macTagBits = 128;

  static final Random _rng = Random.secure();

  static Uint8List _randomBytes(int len) =>
      Uint8List.fromList(List.generate(len, (_) => _rng.nextInt(256)));

  Future<Uint8List> _loadOrCreateKey() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_keyEncryptionKey);
    if (existing != null && existing.isNotEmpty) {
      return base64Decode(existing);
    }
    final key = _randomBytes(32);
    await prefs.setString(_keyEncryptionKey, base64Encode(key));
    return key;
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEncryptionKey, base64Key);
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

  Uint8List _derivePinKey(String pin, Uint8List salt) {
    final params = Pbkdf2Parameters(salt, _pbkdf2Iterations, 32);
    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))..init(params);
    return pbkdf2.process(Uint8List.fromList(utf8.encode(pin)));
  }

  /// Verschluesselt `plaintext` mit einem aus `pin` abgeleiteten Schluessel.
  /// Der Envelope enthaelt das Salt mit, sodass der Erbe nur PIN + Envelope
  /// braucht — kein zusaetzliches Geheimnis.
  Future<String> encryptWithPin(String plaintext, String pin) async {
    final salt = _randomBytes(16);
    final key = _derivePinKey(pin, salt);
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
    final key = _derivePinKey(pin, salt);
    final inner = jsonEncode({
      'v': envelope['v'],
      'iv': envelope['iv'],
      'ct': envelope['ct'],
    });
    return _decryptStringWithKey(inner, key);
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
