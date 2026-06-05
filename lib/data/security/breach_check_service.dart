import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

/// Prueft ein Passwort gegen die HaveIBeenPwned "Pwned Passwords"-Datenbank
/// per **k-Anonymity**: Nur die ersten 5 Zeichen des SHA-1-Hashes verlassen
/// das Geraet. Der Server kennt weder das Passwort noch den vollen Hash und
/// kann aus dem 5-Zeichen-Praefix nicht auf das konkrete Passwort schliessen.
///
/// `Add-Padding: true` laesst die API die Antwort auf eine einheitliche Groesse
/// auffuellen, damit auch die Antwortlaenge nichts verraet.
class BreachCheckService {
  final http.Client _client;

  BreachCheckService([http.Client? client]) : _client = client ?? http.Client();

  /// Liefert, wie oft das Passwort in bekannten Datenlecks auftaucht.
  /// 0 = in keinem bekannten Leck. Wirft bei Netzwerk-/Serverfehlern.
  Future<int> pwnedCount(String password) async {
    final hash =
        sha1.convert(utf8.encode(password)).toString().toUpperCase();
    final prefix = hash.substring(0, 5);
    final suffix = hash.substring(5);

    final resp = await _client.get(
      Uri.parse('https://api.pwnedpasswords.com/range/$prefix'),
      headers: const {'Add-Padding': 'true'},
    );
    if (resp.statusCode != 200) {
      throw Exception('HIBP HTTP ${resp.statusCode}');
    }

    for (final line in const LineSplitter().convert(resp.body)) {
      final idx = line.indexOf(':');
      if (idx <= 0) continue;
      if (line.substring(0, idx) == suffix) {
        // Gepaddete Eintraege haben count 0 — die ignorieren wir implizit, da
        // ein echter Treffer auf unser Suffix immer den realen Count traegt.
        return int.tryParse(line.substring(idx + 1).trim()) ?? 0;
      }
    }
    return 0;
  }
}
