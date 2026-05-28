// Generates a Pacto Maximum-mode envelope WITHOUT depending on Flutter — only
// pointycastle. Used to verify byte-compat with the WebCrypto-based
// `heir-decrypt.html` and `test_envelope_decrypt.mjs`.
//
// Run: dart tools/test_envelope_gen.dart "secret" "1234"
//
// Note: this duplicates the algorithm from CryptoService intentionally so it
// can run as a plain Dart script. Keep both sides aligned if you change one.

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';

Uint8List randomBytes(int n) {
  final r = Random.secure();
  return Uint8List.fromList(List.generate(n, (_) => r.nextInt(256)));
}

Uint8List derivePinKey(String pin, Uint8List salt) {
  final params = Pbkdf2Parameters(salt, 100000, 32);
  final kdf = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))..init(params);
  return kdf.process(Uint8List.fromList(utf8.encode(pin)));
}

String encryptWithPin(String plaintext, String pin) {
  final salt = randomBytes(16);
  final iv = randomBytes(12);
  final key = derivePinKey(pin, salt);
  final cipher = GCMBlockCipher(AESEngine())
    ..init(true, AEADParameters(KeyParameter(key), 128, iv, Uint8List(0)));
  final ct = cipher.process(Uint8List.fromList(utf8.encode(plaintext)));
  return jsonEncode({
    'v': 1,
    'mode': 'pin',
    'salt': base64Encode(salt),
    'iv': base64Encode(iv),
    'ct': base64Encode(ct),
  });
}

String decryptWithPin(String blob, String pin) {
  final env = jsonDecode(blob) as Map<String, dynamic>;
  final salt = base64Decode(env['salt'] as String);
  final iv = base64Decode(env['iv'] as String);
  final ct = base64Decode(env['ct'] as String);
  final key = derivePinKey(pin, salt);
  final cipher = GCMBlockCipher(AESEngine())
    ..init(false, AEADParameters(KeyParameter(key), 128, iv, Uint8List(0)));
  return utf8.decode(cipher.process(ct));
}

void main(List<String> args) {
  if (args.length != 2) {
    stderr.writeln('Usage: dart test_envelope_gen.dart <plaintext> <pin>');
    exit(1);
  }
  final env = encryptWithPin(args[0], args[1]);
  // ignore: avoid_print
  print(env);
  final back = decryptWithPin(env, args[1]);
  stderr.writeln('Dart self-roundtrip: ${back == args[0] ? "OK" : "FAIL"}');
}
