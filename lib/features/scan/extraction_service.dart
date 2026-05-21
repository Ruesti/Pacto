import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'extraction_result.dart';

class ExtractionService {
  // Supabase Edge Function URL — set via app configuration
  static String? _edgeFunctionUrl;
  static String? _supabaseAnonKey;

  // Persistierte anonyme Supabase-Session. Die Edge Function leitet aus dem
  // Session-Token die user_id fuer das Scan-Rate-Limit ab — daher muss
  // dieselbe Session ueber Monate hinweg stabil bleiben.
  static const _keyAccessToken = 'pacto.scan.session_access_token';
  static const _keyRefreshToken = 'pacto.scan.session_refresh_token';
  static const _keyExpiresAt = 'pacto.scan.session_expires_at';

  static void configure({
    required String edgeFunctionUrl,
    required String anonKey,
  }) {
    _edgeFunctionUrl = edgeFunctionUrl;
    _supabaseAnonKey = anonKey;
  }

  static const _systemPrompt = '''
Du bist ein Datenextraktions-Assistent für Verträge und Abonnements.
Antworte AUSSCHLIESSLICH mit einem JSON-Objekt. Kein Kommentar, kein Markdown.
Felder: {
  "name": "Produktname / Abo-Name",
  "provider": "Unternehmensname",
  "category": "streaming|versicherung|handy|internet|software|fitness|zeitung|sonstiges",
  "monthlyCost": 9.99,
  "billingCycle": "monthly|quarterly|yearly|weekly",
  "contactPhone": "+49...",
  "contactEmail": "kuendigung@...",
  "contactUrl": "https://...",
  "noticePeriod": "Freitext z.B. 3 Monate zum Quartalsende",
  "cancellationMethod": "brief|online|telefon|email|automatisch",
  "cancellationInstructions": "Schritt-für-Schritt Anleitung auf Deutsch",
  "nextRenewal": "YYYY-MM-DD oder null",
  "notes": "Besonderheiten, Sonderkündigungsrecht etc."
}
Fehlende Felder als null. monthlyCost immer als Monatsbetrag (Jahresbetrag ÷ 12).
''';

  // Basis-URL des Supabase-Projekts, abgeleitet aus der Edge-Function-URL
  // (https://<ref>.supabase.co/functions/v1/extract-contract -> https://<ref>.supabase.co).
  String _authBaseUrl() => Uri.parse(_edgeFunctionUrl!).origin;

  // Liefert ein gueltiges Access-Token der anonymen Session.
  // Legt die Session beim ersten Aufruf an und erneuert sie bei Ablauf per
  // Refresh-Token — die user_id bleibt dabei stabil.
  Future<String> _ensureSessionToken() async {
    final prefs = await SharedPreferences.getInstance();
    final anonKey = _supabaseAnonKey!;
    final baseUrl = _authBaseUrl();

    final accessToken = prefs.getString(_keyAccessToken);
    final refreshToken = prefs.getString(_keyRefreshToken);
    final expiresAt = prefs.getInt(_keyExpiresAt) ?? 0;
    final nowSecs = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Gueltiges Token vorhanden (60 s Puffer gegen Uhren-Drift)?
    if (accessToken != null && nowSecs < expiresAt - 60) {
      return accessToken;
    }

    // Abgelaufen, aber Refresh-Token vorhanden -> Session erneuern.
    if (refreshToken != null) {
      final refreshed = await _postAuth(
        '$baseUrl/auth/v1/token?grant_type=refresh_token',
        anonKey,
        {'refresh_token': refreshToken},
      );
      if (refreshed != null) return _storeSession(prefs, refreshed);
    }

    // Keine/ungueltige Session -> einmalig anonym anmelden.
    final created = await _postAuth('$baseUrl/auth/v1/signup', anonKey, const {});
    if (created == null) {
      throw Exception(
          'Anonyme Anmeldung an Supabase fehlgeschlagen — sind anonyme '
          'Anmeldungen im Projekt aktiviert?');
    }
    return _storeSession(prefs, created);
  }

  // POST gegen die GoTrue-Auth-API. Gibt das Session-JSON zurueck oder null
  // bei Fehlern (z.B. abgelaufener Refresh-Token).
  Future<Map<String, dynamic>?> _postAuth(
    String url,
    String anonKey,
    Map<String, dynamic> body,
  ) async {
    final resp = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'apikey': anonKey,
        'Authorization': 'Bearer $anonKey',
      },
      body: jsonEncode(body),
    );
    if (resp.statusCode < 200 || resp.statusCode >= 300) return null;
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  Future<String> _storeSession(
    SharedPreferences prefs,
    Map<String, dynamic> session,
  ) async {
    final accessToken = session['access_token'] as String;
    final refreshToken = session['refresh_token'] as String?;
    final expiresIn = (session['expires_in'] as num?)?.toInt() ?? 3600;
    final expiresAt =
        DateTime.now().millisecondsSinceEpoch ~/ 1000 + expiresIn;

    await prefs.setString(_keyAccessToken, accessToken);
    if (refreshToken != null) {
      await prefs.setString(_keyRefreshToken, refreshToken);
    }
    await prefs.setInt(_keyExpiresAt, expiresAt);
    return accessToken;
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyExpiresAt);
  }

  Future<http.Response> _callFunction(
    String url,
    String base64Image,
    String mediaType,
  ) async {
    final sessionToken = await _ensureSessionToken();
    return http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'apikey': _supabaseAnonKey!,
        'Authorization': 'Bearer $sessionToken',
      },
      body: jsonEncode({
        'imageBase64': base64Image,
        'mediaType': mediaType,
        'systemPrompt': _systemPrompt,
      }),
    );
  }

  Future<ExtractionResult> extractFromBase64Image(
      String base64Image, String mediaType) async {
    final url = _edgeFunctionUrl;
    if (url == null || (_supabaseAnonKey ?? '').isEmpty) {
      throw Exception('ExtractionService not configured');
    }

    var response = await _callFunction(url, base64Image, mediaType);

    // 401 => Session abgelaufen/ungueltig: einmal verwerfen, neu anmelden,
    // erneut versuchen.
    if (response.statusCode == 401) {
      await _clearSession();
      response = await _callFunction(url, base64Image, mediaType);
    }

    if (response.statusCode == 429) {
      throw Exception('Scan-Limit erreicht (max. 100/Monat)');
    }
    if (response.statusCode != 200) {
      throw Exception('Extraktionsfehler: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return ExtractionResult.fromJson(json);
  }
}
