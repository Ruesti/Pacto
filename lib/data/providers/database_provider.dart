import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import '../database/daos/contracts_dao.dart';
import '../database/daos/heirs_dao.dart';
import '../sync/cloud_sync_service.dart';
import '../sync/crypto_service.dart';
import '../sync/vault_auto_sync_service.dart';
import 'account_provider.dart';

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

final cryptoServiceProvider = Provider<CryptoService>((ref) => CryptoService());

final cloudSyncServiceProvider = Provider<CloudSyncService>((ref) {
  return CloudSyncService(
    ref.watch(databaseProvider),
    ref.watch(cryptoServiceProvider),
    ref.watch(accountVaultServiceProvider),
  );
});

/// Haelt die serverseitig hinterlegten Erben-Briefe automatisch aktuell.
/// Muss am App-Root beobachtet werden (siehe app.dart), damit der Listener
/// waehrend der gesamten App-Laufzeit lebt.
final vaultAutoSyncServiceProvider = Provider<VaultAutoSyncService>((ref) {
  final service = VaultAutoSyncService(
    ref.watch(databaseProvider),
    ref.watch(cryptoServiceProvider),
  );
  service.start();
  ref.onDispose(service.dispose);
  return service;
});
