import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacto/data/database/database.dart';
import 'package:pacto/data/sync/backup_payload_mapper.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  test('replaceAll round-trips a contract through the backup mapper', () async {
    final original = Contract(
      id: 'c1',
      name: 'Netflix',
      entryType: EntryType.vertrag,
      contractKind: ContractKind.abo,
      accessCategory: null,
      category: ContractCategory.streaming,
      provider: 'Netflix International B.V.',
      contactPhone: null,
      contactEmail: null,
      contactUrl: null,
      cancellationMethod: CancellationMethod.online,
      cancellationInstructions: '',
      noticePeriod: '',
      monthlyCost: 17.99,
      billingCycle: BillingCycle.monthly,
      documentPath: null,
      notes: '',
      loginUsername: null,
      loginPasswordCt: null,
      loginHint: null,
      loginLastVerifiedAt: null,
      contractStart: null,
      nextRenewal: DateTime.utc(2026, 8, 1),
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 2),
    );

    final companion = contractCompanionFromMap(contractToMap(original));
    await db.contractsDao.replaceAll([companion]);

    final restored = await db.contractsDao.getAll();
    expect(restored, hasLength(1));
    expect(restored.single.id, 'c1');
    expect(restored.single.category, ContractCategory.streaming);
    expect(restored.single.monthlyCost, 17.99);
    expect(restored.single.nextRenewal, DateTime.utc(2026, 8, 1));
  });

  test('replaceAll clears previously existing contracts first', () async {
    await db.contractsDao.insertContract(ContractsCompanion.insert(
      name: 'Old entry',
      provider: 'Old GmbH',
    ));
    expect(await db.contractsDao.getAll(), hasLength(1));

    await db.contractsDao.replaceAll([]);

    expect(await db.contractsDao.getAll(), isEmpty);
  });

  test('heirs replaceAll round-trips through the mapper', () async {
    final original = Heir(
      id: 'h1',
      name: 'Alex',
      email: 'alex@example.com',
      pinHash: 'somehash',
      accessLevel: HeirAccess.vollzugang,
      isActive: true,
      createdAt: DateTime.utc(2026, 1, 1),
    );

    final companion = heirCompanionFromMap(heirToMap(original));
    await db.heirsDao.replaceAll([companion]);

    final restored = await db.heirsDao.getAll();
    expect(restored, hasLength(1));
    expect(restored.single.name, 'Alex');
    expect(restored.single.accessLevel, HeirAccess.vollzugang);
  });
}
