import 'dart:io';
import 'dart:math';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart';
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

// ─── SQLCipher: verschluesselte DB at-rest ───
// Der 32-Byte-DB-Key liegt als Hex in flutter_secure_storage (iOS Keychain /
// Android Keystore), NICHT in der DB oder in SharedPreferences.
const _dbKeyName = 'pacto.db.key';
const _dbSecure = FlutterSecureStorage();
final _dbRng = Random.secure();

String _randomHex(int bytes) {
  final b = List.generate(bytes, (_) => _dbRng.nextInt(256));
  return b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // SQLCipher als sqlite-Implementierung erzwingen (Android: ueberschreibt
    // die System-libsqlite; iOS/macOS linken sqlcipher direkt).
    await applyWorkaroundToOpenSqlCipherOnOldAndroidVersions();
    open.overrideFor(OperatingSystem.android, openCipherOnAndroid);

    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'pacto.sqlite'));

    var keyHex = await _dbSecure.read(key: _dbKeyName);
    if (keyHex == null || keyHex.isEmpty) {
      // Noch kein Key → entweder Erststart oder eine alte, unverschluesselte
      // pacto.sqlite aus einer Vorversion. Key wird erst NACH erfolgreicher
      // Migration persistiert, damit ein Fehlschlag beim naechsten Start
      // wiederholt werden kann.
      final candidate = _randomHex(32);
      if (file.existsSync()) {
        await _migratePlaintextDb(file, candidate);
      }
      await _dbSecure.write(key: _dbKeyName, value: candidate);
      keyHex = candidate;
    }

    final key = keyHex;
    return NativeDatabase(file, setup: (rawDb) {
      rawDb.execute('PRAGMA key = "x\'$key\'";');
      // Erzwingt sofortige Schluesselpruefung — falscher Key wirft hier.
      rawDb.execute('SELECT count(*) FROM sqlite_master;');
    });
  });
}

/// Verschluesselt eine bestehende Klartext-`pacto.sqlite` einmalig per
/// `sqlcipher_export`: Klartext-DB oeffnen → verschluesselte Kopie attachen →
/// exportieren → Klartext ersetzen. Idempotent ueber die "Key vorhanden?"-
/// Pruefung des Aufrufers.
Future<void> _migratePlaintextDb(File file, String keyHex) async {
  final tmpPath = '${file.path}.enc';
  final tmp = File(tmpPath);
  if (tmp.existsSync()) tmp.deleteSync();

  final plain = sqlite3.open(file.path);
  try {
    // sqlcipher_export kopiert Schema + Daten, aber NICHT die user_version.
    // Ohne sie wuerde die verschluesselte DB als Version 0 gelten und Drifts
    // onUpgrade (das z.B. entry_type ergaenzt) liefe nie. Darum manuell
    // uebertragen.
    final version =
        plain.select('PRAGMA user_version;').first.values.first as int;
    plain.execute('ATTACH DATABASE \'$tmpPath\' AS encrypted KEY "x\'$keyHex\'";');
    plain.execute("SELECT sqlcipher_export('encrypted');");
    plain.execute('PRAGMA encrypted.user_version = $version;');
    plain.execute('DETACH DATABASE encrypted;');
  } finally {
    plain.dispose();
  }

  file.deleteSync();
  tmp.renameSync(file.path);
}
