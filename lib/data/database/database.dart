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
import '../../domain/models/entry_type.dart';
import '../../domain/models/access_category.dart';
import 'tables/contracts_table.dart';
import 'tables/heirs_table.dart';
import 'tables/provider_library_table.dart';
import 'daos/contracts_dao.dart';
import 'daos/heirs_dao.dart';

export '../../domain/models/contract_category.dart';
export '../../domain/models/cancellation_method.dart';
export '../../domain/models/billing_cycle.dart';
export '../../domain/models/heir_access.dart';
export '../../domain/models/entry_type.dart';
export '../../domain/models/access_category.dart';
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
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // v2: Login-Daten pro Vertrag (Username + verschluesseltes Passwort
            // + Hinweis-Text + lastVerifiedAt).
            await m.addColumn(contracts, contracts.loginUsername);
            await m.addColumn(contracts, contracts.loginPasswordCt);
            await m.addColumn(contracts, contracts.loginHint);
            await m.addColumn(contracts, contracts.loginLastVerifiedAt);
          }
          if (from < 3) {
            // v3: Eigenstaendige Zugaenge. Default 'vertrag' macht alle
            // Bestandszeilen zu Vertraegen — kein Backfill noetig.
            await m.addColumn(contracts, contracts.entryType);
            await m.addColumn(contracts, contracts.accessCategory);
          }
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'pacto.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
