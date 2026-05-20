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
}
