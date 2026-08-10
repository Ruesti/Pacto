import 'package:flutter_test/flutter_test.dart';
import 'package:pacto/data/sync/crypto_service.dart';

void main() {
  group('CryptoService password escrow', () {
    late CryptoService crypto;

    setUp(() {
      crypto = CryptoService();
    });

    test('encrypts and decrypts a key with the correct secret', () async {
      const aesKeyB64 = 'dGhpc2lzYXRlc3RrZXlvZjMyYnl0ZXNsb25nISE=';
      final escrow = await crypto.encryptKeyForEscrow(aesKeyB64, 'correct horse battery');
      final recovered = await crypto.decryptEscrowKey(
        saltBase64: escrow.saltBase64,
        encryptedKeyJson: escrow.encryptedKeyJson,
        secret: 'correct horse battery',
      );
      expect(recovered, aesKeyB64);
    });

    test('throws WrongPasswordException for a wrong secret', () async {
      const aesKeyB64 = 'dGhpc2lzYXRlc3RrZXlvZjMyYnl0ZXNsb25nISE=';
      final escrow = await crypto.encryptKeyForEscrow(aesKeyB64, 'correct horse battery');
      expect(
        () => crypto.decryptEscrowKey(
          saltBase64: escrow.saltBase64,
          encryptedKeyJson: escrow.encryptedKeyJson,
          secret: 'wrong password',
        ),
        throwsA(isA<WrongPasswordException>()),
      );
    });

    test('two escrows of the same key use different salts', () async {
      const aesKeyB64 = 'dGhpc2lzYXRlc3RrZXlvZjMyYnl0ZXNsb25nISE=';
      final a = await crypto.encryptKeyForEscrow(aesKeyB64, 'pw');
      final b = await crypto.encryptKeyForEscrow(aesKeyB64, 'pw');
      expect(a.saltBase64, isNot(b.saltBase64));
    });
  });
}
