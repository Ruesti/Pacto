import 'package:flutter_test/flutter_test.dart';
import 'package:pacto/features/heirs/share_export_service.dart';

void main() {
  group('ShareExportService PIN-Hash (PBKDF2, gesalzen)', () {
    test('korrekter PIN verifiziert, falscher nicht', () {
      final hash = ShareExportService.hashPin('1234');
      expect(ShareExportService.verifyPin('1234', hash), isTrue);
      expect(ShareExportService.verifyPin('4321', hash), isFalse);
      expect(ShareExportService.verifyPin('', hash), isFalse);
    });

    test('zwei Hashes desselben PIN unterscheiden sich (zufaelliges Salt)', () {
      final a = ShareExportService.hashPin('0000');
      final b = ShareExportService.hashPin('0000');
      expect(a, isNot(equals(b)));
      // trotzdem beide gueltig
      expect(ShareExportService.verifyPin('0000', a), isTrue);
      expect(ShareExportService.verifyPin('0000', b), isTrue);
    });

    test('Format ist selbstbeschreibend (pbkdf2_sha256)', () {
      final hash = ShareExportService.hashPin('9999');
      final parts = hash.split(r'$');
      expect(parts.length, 4);
      expect(parts[0], 'pbkdf2_sha256');
      expect(int.parse(parts[1]), greaterThanOrEqualTo(100000));
    });

    test('kaputter/leerer gespeicherter Hash verifiziert nicht (kein Crash)', () {
      expect(ShareExportService.verifyPin('1234', ''), isFalse);
      expect(ShareExportService.verifyPin('1234', 'muell'), isFalse);
      expect(ShareExportService.verifyPin('1234', r'pbkdf2_sha256$abc$x$y'),
          isFalse);
    });
  });
}
