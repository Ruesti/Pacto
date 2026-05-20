import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import '../../domain/models/contract_category.dart';
import '../../domain/models/cancellation_method.dart';
import '../../domain/models/billing_cycle.dart';
import '../../domain/models/heir_access.dart';
import 'tables/contracts_table.dart';
import 'tables/heirs_table.dart';
import 'tables/provider_library_table.dart';
import 'daos/contracts_dao.dart';
import 'daos/heirs_dao.dart';

export '../../domain/models/contract_category.dart';
export '../../domain/models/cancellation_method.dart';
export '../../domain/models/billing_cycle.dart';
export '../../domain/models/heir_access.dart';
export 'tables/contracts_table.dart';
export 'tables/heirs_table.dart';
export 'tables/provider_library_table.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [Contracts, Heirs, ProviderLibrary],
  daos: [ContractsDao, HeirsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'pacto.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
