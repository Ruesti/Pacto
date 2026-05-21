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
}
