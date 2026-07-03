import 'package:drift/drift.dart';
import '../database.dart';

part 'contracts_dao.g.dart';

@DriftAccessor(tables: [Contracts])
class ContractsDao extends DatabaseAccessor<AppDatabase>
    with _$ContractsDaoMixin {
  ContractsDao(super.db);

  Stream<List<Contract>> watchAll() => select(contracts).watch();

  Future<List<Contract>> getAll() => select(contracts).get();

  Future<Contract?> findById(String id) =>
      (select(contracts)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> insertContract(ContractsCompanion entry) =>
      into(contracts).insert(entry);

  /// Loescht alle vorhandenen Vertraege und ersetzt sie durch [entries] —
  /// genutzt beim Account-Recovery-Restore (siehe AccountVaultService).
  /// Laeuft in einer Transaktion, damit ein Fehler mitten im Import nicht
  /// eine halb-geleerte Tabelle hinterlaesst.
  Future<void> replaceAll(List<ContractsCompanion> entries) {
    return transaction(() async {
      await delete(contracts).go();
      for (final entry in entries) {
        await into(contracts).insert(entry);
      }
    });
  }

  Future<bool> updateContract(ContractsCompanion entry) =>
      update(contracts).replace(entry);

  Future<int> deleteContract(String id) =>
      (delete(contracts)..where((t) => t.id.equals(id))).go();

  Stream<List<Contract>> watchByCategory(String category) =>
      (select(contracts)..where((t) => t.category.equals(category))).watch();

  Future<double> getTotalMonthlyCost() async {
    final all = await getAll();
    return all.fold<double>(0.0, (sum, c) => sum + c.monthlyCost);
  }

  /// Loescht alle gespeicherten Login-Passwoerter (Username + Hint bleiben).
  /// Genutzt beim Wechsel der HeirPasswordPolicy auf `none`, wenn der User
  /// die bereits abgelegten Passwoerter explizit purgen will.
  Future<int> clearAllLoginPasswords() async {
    return (update(contracts)
          ..where((t) => t.loginPasswordCt.isNotNull()))
        .write(const ContractsCompanion(
      loginPasswordCt: Value(null),
    ));
  }

  /// Setzt `loginLastVerifiedAt` auf jetzt — der User hat bestaetigt, dass das
  /// gespeicherte Login noch stimmt.
  Future<int> markVerified(String id) =>
      (update(contracts)..where((t) => t.id.equals(id))).write(
        ContractsCompanion(loginLastVerifiedAt: Value(DateTime.now())),
      );

  Future<int> countStoredLoginPasswords() async {
    final query = selectOnly(contracts)
      ..addColumns([contracts.id.count()])
      ..where(contracts.loginPasswordCt.isNotNull());
    final row = await query.getSingle();
    return row.read(contracts.id.count()) ?? 0;
  }
}
