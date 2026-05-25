/// RevenueCat API-Konfiguration.
///
/// Die API-Keys sind öffentliche Client-Keys (kein Geheimnis).
/// Sie werden im RevenueCat-Dashboard unter Project → API Keys gepflegt.
///
/// Schritte vor dem Store-Release:
///   1. RevenueCat-Projekt anlegen: app.revenuecat.com
///   2. App Store Connect / Google Play Console: Produkt "pacto_pro" anlegen
///      (Non-Consumable / One-Time Purchase, ~2,99 €)
///   3. Produkt in RevenueCat als Entitlement "pro" verknüpfen
///   4. Reale Keys hier eintragen
class RevenueCatConfig {
  const RevenueCatConfig._();

  /// Identifier der Berechtigung im RevenueCat-Dashboard.
  static const entitlementId = 'pro';

  /// Produkt-ID in App Store Connect und Google Play Console.
  static const productId = 'pacto_pro';

  /// iOS/macOS API-Key (RevenueCat Dashboard → API Keys → App-specific keys)
  /// Placeholder — vor Release durch echten Key ersetzen.
  static const appleApiKey = 'appl_PLACEHOLDER_REPLACE_BEFORE_RELEASE';

  /// Android API-Key
  /// Placeholder — vor Release durch echten Key ersetzen.
  static const googleApiKey = 'goog_PLACEHOLDER_REPLACE_BEFORE_RELEASE';
}
