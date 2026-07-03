import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../sync/account_vault_service.dart';
import 'database_provider.dart';

final accountVaultServiceProvider = Provider<AccountVaultService>((ref) {
  return AccountVaultService(
    ref.watch(databaseProvider),
    ref.watch(cryptoServiceProvider),
  );
});

/// Aktuelle Supabase-Auth-Session, aktualisiert sich automatisch bei
/// Login/Logout/Token-Refresh. `null` bedeutet: kein Konto eingeloggt.
final authStateProvider = StreamProvider<Session?>((ref) async* {
  final client = Supabase.instance.client;
  yield client.auth.currentSession;
  yield* client.auth.onAuthStateChange.map((event) => event.session);
});
