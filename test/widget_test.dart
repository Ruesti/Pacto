import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacto/data/database/database.dart';
import 'package:pacto/data/security/password_strength.dart';
import 'package:pacto/data/sync/crypto_service.dart';
import 'package:drift/drift.dart' show Value;
import 'package:shared_preferences/shared_preferences.dart';

AppDatabase openTestDatabase() => AppDatabase(NativeDatabase.memory());

/// In-Memory-Mock fuer flutter_secure_storage, damit CryptoService den
/// AES-Key im Unit-Test laden/schreiben kann (kein nativer Keystore).
void _mockSecureStorage() {
  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final store = <String, String>{};
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (call) async {
    switch (call.method) {
      case 'read':
        return store[call.arguments['key'] as String];
      case 'write':
        store[call.arguments['key'] as String] =
            call.arguments['value'] as String;
        return null;
      case 'delete':
        store.remove(call.arguments['key'] as String);
        return null;
      case 'readAll':
        return Map<String, String>.from(store);
      case 'deleteAll':
        store.clear();
        return null;
      case 'containsKey':
        return store.containsKey(call.arguments['key'] as String);
      default:
        return null;
    }
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  _mockSecureStorage();

  late AppDatabase db;

  setUp(() => db = openTestDatabase());
  tearDown(() => db.close());

  test('Phase 1 – Vertrag anlegen, lesen, löschen', () async {
    final dao = db.contractsDao;

    await dao.insertContract(ContractsCompanion.insert(
      name: 'Netflix',
      provider: 'Netflix International B.V.',
      category: const Value(ContractCategory.streaming),
      monthlyCost: const Value(12.99),
      billingCycle: const Value(BillingCycle.monthly),
      cancellationMethod: const Value(CancellationMethod.online),
      cancellationInstructions:
          const Value('Einloggen → Kündigen'),
      noticePeriod: const Value('Jederzeit'),
    ));

    final all = await dao.getAll();
    expect(all.length, 1);
    expect(all.first.name, 'Netflix');
    expect(all.first.monthlyCost, 12.99);
    expect(all.first.category, ContractCategory.streaming);

    await dao.deleteContract(all.first.id);

    final afterDelete = await dao.getAll();
    expect(afterDelete, isEmpty);
  });

  test('Phase 1 – Mehrere Verträge, Gesamtkosten', () async {
    final dao = db.contractsDao;

    for (final entry in [
      ('Netflix', 12.99),
      ('Spotify', 9.99),
      ('Amazon Prime', 8.99),
    ]) {
      await dao.insertContract(ContractsCompanion.insert(
        name: entry.$1,
        provider: 'Anbieter',
        category: const Value(ContractCategory.streaming),
        monthlyCost: Value(entry.$2),
        billingCycle: const Value(BillingCycle.monthly),
        cancellationMethod: const Value(CancellationMethod.online),
        cancellationInstructions: const Value(''),
        noticePeriod: const Value(''),
      ));
    }

    final total = await dao.getTotalMonthlyCost();
    expect(total, closeTo(31.97, 0.01));
  });

  test('Phase 9 – AES-256 encrypt/decrypt round-trip', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    final crypto = CryptoService();
    final payload = {
      'contracts': [
        {'name': 'Netflix', 'cost': 12.99},
        {'name': 'Spotify', 'cost': 9.99},
      ],
      'heirs': [
        {'name': 'Max'},
      ],
    };
    final blob = await crypto.encryptJson(payload);
    expect(blob, isNot(contains('Netflix')));
    final decoded = await crypto.decryptJson(blob);
    expect(decoded['contracts'], payload['contracts']);
    expect(decoded['heirs'], payload['heirs']);
  });

  test('Phase 1 – Erbe anlegen und lesen', () async {
    final dao = db.heirsDao;

    await dao.insertHeir(HeirsCompanion.insert(
      name: 'Max Mustermann',
      email: 'max@example.com',
      pinHash: 'hash123',
    ));

    final heirs = await dao.getAll();
    expect(heirs.length, 1);
    expect(heirs.first.name, 'Max Mustermann');
    expect(heirs.first.isActive, true);
  });

  test('Phase 2 – Zugang traegt entryType + accessCategory, keine Kosten',
      () async {
    final dao = db.contractsDao;
    await dao.insertContract(ContractsCompanion.insert(
      name: 'WLAN-Router',
      provider: 'FRITZ!Box',
      entryType: const Value(EntryType.zugang),
      accessCategory: const Value(AccessCategory.router),
    ));
    final all = await dao.getAll();
    expect(all.single.entryType, EntryType.zugang);
    expect(all.single.accessCategory, AccessCategory.router);
    expect(all.single.monthlyCost, 0.0);
  });

  test('Phase 3 – Passwort-Staerke-Heuristik', () {
    expect(assessPasswordStrength('password'), PasswordStrength.weak);
    expect(assessPasswordStrength('abc'), PasswordStrength.weak);
    expect(assessPasswordStrength('Sommer2024'), PasswordStrength.medium);
    expect(assessPasswordStrength(r'9xL!qT#7vR2&mZ'), PasswordStrength.strong);
  });
}
