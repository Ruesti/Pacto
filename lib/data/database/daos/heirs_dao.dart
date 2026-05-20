import 'package:drift/drift.dart';
import '../database.dart';

part 'heirs_dao.g.dart';

@DriftAccessor(tables: [Heirs])
class HeirsDao extends DatabaseAccessor<AppDatabase> with _$HeirsDaoMixin {
  HeirsDao(super.db);

  Stream<List<Heir>> watchAll() => select(heirs).watch();

  Future<List<Heir>> getAll() => select(heirs).get();

  Future<Heir?> findById(String id) =>
      (select(heirs)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> insertHeir(HeirsCompanion entry) =>
      into(heirs).insert(entry);

  Future<bool> updateHeir(HeirsCompanion entry) =>
      update(heirs).replace(entry);

  Future<int> deleteHeir(String id) =>
      (delete(heirs)..where((t) => t.id.equals(id))).go();
}
