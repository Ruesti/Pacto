import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Wie geht Pacto im Erbfall mit den gespeicherten Login-Passwoertern um?
///
/// Drei klar abgestufte Stufen — pro App-Installation eine Wahl. Wechselt der
/// User die Policy, werden alle bereits gespeicherten Passwoerter beim
/// naechsten Vertrag-Speichern entsprechend re-encrypted.
enum HeirPasswordPolicy {
  /// Keine Passwoerter in Pacto speichern. Nur das `loginHint`-Feld ist
  /// verfuegbar ("siehe 1Password", "Notizbuch im Schreibtisch").
  /// Maximale Datensparsamkeit, kein Aktualisierungsdruck.
  none,

  /// Pacto-Server kann im Erbfall entschluesseln und im Klartext an die
  /// Erben mailen. Erbe muss nichts vorab wissen. Vertrauensmodell: User
  /// vertraut dem Pacto-Anbieter (vergleichbar mit iCloud / Google).
  komfort,

  /// Passwort wird mit einem aus dem Erben-PIN abgeleiteten Schluessel
  /// verschluesselt. Server kennt den PIN nicht — Erbe braucht den PIN
  /// vorab (Brief, SMS, Notar). Kryptographisch maximale Sicherheit.
  maximum,
}

const _prefsKey = 'pacto.heir.password_policy';

Future<HeirPasswordPolicy> getHeirPasswordPolicy() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_prefsKey);
  if (raw == null) return HeirPasswordPolicy.none;
  return HeirPasswordPolicy.values
          .where((e) => e.name == raw)
          .firstOrNull ??
      HeirPasswordPolicy.none;
}

Future<void> setHeirPasswordPolicy(HeirPasswordPolicy policy) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_prefsKey, policy.name);
}

final heirPasswordPolicyProvider =
    AsyncNotifierProvider<HeirPasswordPolicyNotifier, HeirPasswordPolicy>(
  HeirPasswordPolicyNotifier.new,
);

class HeirPasswordPolicyNotifier extends AsyncNotifier<HeirPasswordPolicy> {
  @override
  Future<HeirPasswordPolicy> build() => getHeirPasswordPolicy();

  Future<void> set(HeirPasswordPolicy policy) async {
    await setHeirPasswordPolicy(policy);
    state = AsyncData(policy);
  }
}
