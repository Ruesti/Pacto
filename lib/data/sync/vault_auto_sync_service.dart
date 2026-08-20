import 'dart:async';
import '../../features/onboarding/onboarding_screen.dart';
import '../database/database.dart';
import 'crypto_service.dart';
import 'vault_service.dart';

/// Haelt die serverseitig hinterlegten Erben-Briefe automatisch aktuell
/// (Befund 2-E): lauscht auf Aenderungen an Vertraegen und Erben und
/// synchronisiert — sofern der Tresor aktiv ist — mit kurzer Entprellung.
///
/// Ohne das musste der Nutzer nach jeder Aenderung manuell „Jetzt
/// synchronisieren" tippen; wer das vergass, loeste im Ernstfall `no_payloads`
/// aus.
class VaultAutoSyncService {
  final AppDatabase _db;
  final CryptoService _crypto;

  StreamSubscription<void>? _contractsSub;
  StreamSubscription<void>? _heirsSub;
  Timer? _debounce;

  VaultAutoSyncService(this._db, this._crypto);

  void start() {
    // skip(1): die erste (initiale) Emission ist der Ist-Zustand beim Abonnieren
    // — wir wollen nur auf echte Aenderungen reagieren.
    _contractsSub = _db.contractsDao.watchAll().skip(1).listen((_) => _schedule());
    _heirsSub = _db.heirsDao.watchAll().skip(1).listen((_) => _schedule());
  }

  void _schedule() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 3), _run);
  }

  Future<void> _run() async {
    final settings = await VaultService.loadSettings();
    if (!settings.enabled) return;
    try {
      final ownerName = (await getUserName()) ?? 'Pacto-User';
      await VaultService(_db, _crypto).syncPayloads(ownerName: ownerName);
    } catch (_) {
      // Best-effort — die Tresor-UI zeigt den letzten erfolgreichen Sync an.
    }
  }

  /// Sofort synchronisieren (z. B. direkt nach dem Aktivieren des Tresors),
  /// ohne auf die Entprellung zu warten.
  Future<void> syncNow() => _run();

  void dispose() {
    _contractsSub?.cancel();
    _heirsSub?.cancel();
    _debounce?.cancel();
  }
}
