import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacto/data/database/database.dart';
import 'package:drift/drift.dart' show Value;

AppDatabase openTestDatabase() => AppDatabase(NativeDatabase.memory());

void main() {
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
}
