import '../../domain/models/billing_cycle.dart';
import '../../domain/models/cancellation_method.dart';
import '../provider_library/provider_library_data.dart';
import 'extraction_result.dart';

/// Reichert die rohe Claude-Extraktion mit drei Datenquellen an, jeweils nur
/// für Felder die im Original leer oder leer-ähnlich sind:
///   1. Provider-Bibliothek (Domain-Match) — kuratierte Kündigungs- und
///      Kontaktdaten für bekannte Anbieter.
///   2. URL-Fallback — wenn weder Claude noch Library eine `contactUrl` haben,
///      wird die Domain selbst verwendet.
///   3. SaaS-Defaults — `online`-Kündigung + „monatlich kündbar" wenn
///      sonst nichts da ist. Ehrlich für ~90 % aller Web-Abos.
///
/// Claude-Werte gewinnen IMMER, wenn vorhanden — die App soll keine echten
/// Daten überschreiben.
ExtractionResult enrichExtraction(ExtractionResult raw, String url) {
  final template = findTemplateForUrl(url);
  final host = _hostOf(url);

  String pickStr(String original, String? fromTemplate, String? saasDefault) {
    if (original.trim().isNotEmpty) return original;
    if (fromTemplate != null && fromTemplate.trim().isNotEmpty) {
      return fromTemplate;
    }
    return saasDefault ?? '';
  }

  String? pickNullable(String? original, String? fromTemplate) {
    if (original != null && original.trim().isNotEmpty) return original;
    if (fromTemplate != null && fromTemplate.trim().isNotEmpty) {
      return fromTemplate;
    }
    return null;
  }

  final mergedProvider = pickStr(raw.provider, template?.provider, null);
  final mergedCancelMethod = raw.cancellationMethod == CancellationMethod.online
      // Claude defaultet auf online wenn unsicher — Library-Wert hat Vorrang,
      // sofern die Library für die Domain etwas anderes weiß.
      ? (template?.cancellationMethod ?? CancellationMethod.online)
      : raw.cancellationMethod;
  final mergedCancelInstructions = pickStr(
    raw.cancellationInstructions,
    template?.cancellationInstructions,
    null,
  );
  final mergedNotice = pickStr(
    raw.noticePeriod,
    template?.noticePeriod,
    // SaaS-Default: monatlich kündbar — gilt für ~90 % aller Web-Abos.
    'Monatlich zum Ende des Abrechnungszeitraums',
  );

  final mergedPhone = pickNullable(raw.contactPhone, template?.contactPhone);
  final mergedEmail = pickNullable(raw.contactEmail, template?.contactEmail);
  final mergedUrl = pickNullable(
        raw.contactUrl,
        template?.contactUrl,
      ) ??
      (host.isEmpty ? null : 'https://$host');

  // Bibliotheks-Treffer hebt unsichere Extraktionen auf medium an, sodass die
  // Anbieter-Spalte im Formular nicht mehr gelb markiert wird.
  final boostedConfidence =
      template != null && raw.confidence == ExtractionConfidence.low
          ? ExtractionConfidence.medium
          : raw.confidence;

  return ExtractionResult(
    name: raw.name,
    provider: mergedProvider,
    category: template?.category ?? raw.category,
    monthlyCost: raw.monthlyCost,
    billingCycle: raw.billingCycle == BillingCycle.monthly && raw.monthlyCost == 0
        ? BillingCycle.monthly
        : raw.billingCycle,
    contactPhone: mergedPhone,
    contactEmail: mergedEmail,
    contactUrl: mergedUrl,
    noticePeriod: mergedNotice,
    cancellationMethod: mergedCancelMethod,
    cancellationInstructions: mergedCancelInstructions,
    nextRenewal: raw.nextRenewal,
    notes: raw.notes,
    confidence: boostedConfidence,
  );
}

String _hostOf(String url) {
  try {
    final host = Uri.parse(url).host.toLowerCase();
    return host.startsWith('www.') ? host.substring(4) : host;
  } catch (_) {
    return '';
  }
}
