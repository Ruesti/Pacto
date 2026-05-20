import 'dart:convert';
import 'package:http/http.dart' as http;
import 'extraction_result.dart';

class ExtractionService {
  // Supabase Edge Function URL — set via app configuration
  static String? _edgeFunctionUrl;
  static String? _supabaseAnonKey;

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

  Future<ExtractionResult> extractFromBase64Image(
      String base64Image, String mediaType) async {
    final url = _edgeFunctionUrl;
    if (url == null) throw Exception('ExtractionService not configured');

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_supabaseAnonKey',
      },
      body: jsonEncode({
        'imageBase64': base64Image,
        'mediaType': mediaType,
        'systemPrompt': _systemPrompt,
      }),
    );

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
