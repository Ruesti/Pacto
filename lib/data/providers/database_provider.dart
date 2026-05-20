import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import '../database/daos/contracts_dao.dart';
import '../database/daos/heirs_dao.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final contractsDaoProvider = Provider<ContractsDao>((ref) {
  return ref.watch(databaseProvider).contractsDao;
});

final heirsDaoProvider = Provider<HeirsDao>((ref) {
  return ref.watch(databaseProvider).heirsDao;
});

final contractsStreamProvider = StreamProvider((ref) {
  return ref.watch(contractsDaoProvider).watchAll();
});

final heirsStreamProvider = StreamProvider((ref) {
  return ref.watch(heirsDaoProvider).watchAll();
});
