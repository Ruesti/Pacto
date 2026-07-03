import 'package:flutter_test/flutter_test.dart';
import 'package:pacto/data/database/database.dart';
import 'package:pacto/data/sync/backup_payload_mapper.dart';

Contract _sampleContract() => Contract(
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

Heir _sampleHeir() => Heir(
      id: 'h1',
      name: 'Alex',
      email: 'alex@example.com',
      pinHash: 'somehash',
      accessLevel: HeirAccess.vollzugang,
      isActive: true,
      createdAt: DateTime.utc(2026, 1, 1),
    );

void main() {
  test('contractToMap contains the expected keys and values', () {
    final map = contractToMap(_sampleContract());
    expect(map['id'], 'c1');
    expect(map['name'], 'Netflix');
    expect(map['category'], 'streaming');
    expect(map['billingCycle'], 'monthly');
    expect(map['monthlyCost'], 17.99);
    expect(map['nextRenewal'], '2026-08-01T00:00:00.000Z');
  });

  test('heirToMap contains the expected keys and values', () {
    final map = heirToMap(_sampleHeir());
    expect(map['id'], 'h1');
    expect(map['accessLevel'], 'vollzugang');
    expect(map['isActive'], true);
  });

  test('buildBackupPayload wraps contracts and heirs with a version', () {
    final payload = buildBackupPayload(
      contracts: [_sampleContract()],
      heirs: [_sampleHeir()],
    );
    expect(payload['version'], 1);
    expect(payload['contracts'], hasLength(1));
    expect(payload['heirs'], hasLength(1));
  });
}
