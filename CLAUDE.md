# CLAUDE.md — Pacto

Dieses Dokument beschreibt Architektur, Entscheidungen und Konventionen für die Flutter-App **Pacto**.
Claude Code liest diese Datei automatisch beim Start jeder Session.

---

## Produkt-Übersicht

**Pacto** ist eine lokale Vertrags- und Abo-Verwaltung mit zwei gleichwertigen Nutzungsfällen:

1. **Persönliche Verwaltung** — Überblick über alle laufenden Abos und Verträge, monatliche Gesamtkosten, Kündigungsfristen im Blick behalten.
2. **Nachlasshilfe** — Im Sterbefall erhalten Hinterbliebene eine vollständige Übersicht aller Verträge inkl. Kündigungsanleitung.

**Positionierung:** "Weißt du wirklich was du jeden Monat zahlst?"
Das Legacy-Feature ist ruhiges Premium im Hintergrund — kein morbider Vordergrund.

**Monetarisierung:** Einmaliger Kauf ~2,99 € (kein Abo — thematisch unpassend).
Freemium: bis 5 Einträge kostenlos.

---

## Tech-Stack

| Layer | Technologie |
|---|---|
| Framework | Flutter (iOS + Android) |
| Lokale DB | Drift (SQLite) — local-first |
| Cloud-Sync (optional) | Supabase (verschlüsselt) |
| KI-Extraktion | Anthropic API — claude-haiku-4-5 |
| Share-Extension | receive_sharing_intent |
| PDF-Verarbeitung | flutter_pdfview, pdf_render |
| Export | pdf (dart package), qr_flutter |
| State Management | Riverpod |
| Navigation | go_router |
| Lokalisierung | flutter_localizations — DE + EN (ARB) |
| Web-Ansicht | webview_flutter — URL-Import via WebSearchScreen |

---

## Projektstruktur

```
lib/
  main.dart
  app.dart                        # GoRouter setup, Riverpod ProviderScope

  data/
    database/
      database.dart               # Drift AppDatabase
      tables/
        contracts_table.dart
        heirs_table.dart
        provider_library_table.dart
      daos/
        contracts_dao.dart
        heirs_dao.dart

  domain/
    models/
      contract.dart               # Drift-generiertes Model + Extensions
      heir.dart
      contract_category.dart      # Enum
      cancellation_method.dart    # Enum
    repositories/
      contracts_repository.dart
      heirs_repository.dart

  features/
    dashboard/
      dashboard_screen.dart       # Übersicht, Gesamtkosten, Kategorien
      widgets/
        cost_summary_card.dart
        contract_list_tile.dart

    contract_detail/
      contract_detail_screen.dart
      widgets/
        cancellation_info_card.dart
        document_attachment.dart

    add_contract/
      add_contract_screen.dart    # Formular (vorausgefüllt oder leer)
      add_contract_provider.dart
      widgets/
        entry_method_sheet.dart   # Bottom Sheet: Bibliothek / Scan / Kontoauszug

    scan/
      scan_controller.dart        # Kamera + Share-Intent Handling
      extraction_service.dart     # Claude Vision API Call
      extraction_result.dart      # Geparste KI-Antwort

    provider_library/
      provider_library_screen.dart
      provider_library_data.dart  # Statische Liste häufiger Anbieter

    heirs/
      heirs_screen.dart
      heir_detail_screen.dart
      share_export_service.dart   # PDF-Export, QR-Code, Tresor-Modus

    settings/
      settings_screen.dart
      supabase_sync_screen.dart

  shared/
    widgets/
      category_pill.dart
      cost_badge.dart
      status_badge.dart
    theme/
      app_theme.dart
      app_colors.dart
      app_text_styles.dart
      app_spacing.dart
    utils/
      currency_formatter.dart
      date_formatter.dart
    l10n/
      l10n_extension.dart         # context.l10n shortcut
      enum_labels.dart            # lokalisierte Enum-Labels
    locale_provider.dart          # Riverpod StateNotifier für Sprache

assets/
  images/
    hero_bg.jpg                 # Dunkle Berglandschaft — Dashboard-Header
```

---

## Datenmodell (Drift)

### contracts

```dart
class Contracts extends Table {
  TextColumn get id           => text().clientDefault(() => const Uuid().v4())();
  TextColumn get name         => text()();
  TextColumn get category     => textEnum<ContractCategory>()();
  TextColumn get provider     => text()();
  TextColumn get contactPhone => text().nullable()();
  TextColumn get contactEmail => text().nullable()();
  TextColumn get contactUrl   => text().nullable()();
  TextColumn get cancellationMethod => textEnum<CancellationMethod>()();
  TextColumn get cancellationInstructions => text().withDefault(const Constant(''))();
  TextColumn get noticePeriod => text().withDefault(const Constant(''))();
  // noticePeriod als Freitext: "3 Monate zum 31.12.", "monatlich", "jederzeit"
  RealColumn  get monthlyCost => real().withDefault(const Constant(0.0))();
  // Immer normalisiert auf Monatsbetrag. Jahresbetrag ÷ 12 beim Import.
  TextColumn get billingCycle => textEnum<BillingCycle>()();
  // monthly | quarterly | yearly | weekly — für Anzeige im UI
  TextColumn get documentPath => text().nullable()();
  // Lokaler Pfad zum angehängten PDF/Foto
  TextColumn get notes        => text().withDefault(const Constant(''))();
  DateTimeColumn get contractStart => dateTime().nullable()();
  DateTimeColumn get nextRenewal   => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();
  DateTimeColumn get updatedAt => dateTime().clientDefault(DateTime.now)();

  @override
  Set<Column> get primaryKey => {id};
}

enum ContractCategory { streaming, versicherung, handy, internet, software, fitness, zeitung, sonstiges }
enum CancellationMethod { brief, online, telefon, email, automatisch }
enum BillingCycle { monthly, quarterly, yearly, weekly }
```

### heirs

```dart
class Heirs extends Table {
  TextColumn get id          => text().clientDefault(() => const Uuid().v4())();
  TextColumn get name        => text()();
  TextColumn get email       => text()();
  TextColumn get pinHash     => text()();           // bcrypt-Hash des Zugangs-PIN
  TextColumn get accessLevel => textEnum<HeirAccess>()();
  BoolColumn  get isActive   => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();

  @override
  Set<Column> get primaryKey => {id};
}

enum HeirAccess { vollzugang, nurListe }
// vollzugang: alle Felder sichtbar inkl. Zugangsdaten
// nurListe:   nur Name, Anbieter, Kosten, Kündigungsanleitung
```

### provider_library (statisch, einmalig befüllt)

Vorbefüllte Einträge für ~40 häufige deutsche Anbieter:
Netflix, Spotify, Amazon Prime, Disney+, Apple One, DAZN,
GEZ/ARD ZDF Deutschlandradio, Telekom, Vodafone, O2, 1&1,
HUK-Coburg, ADAC, Fitnessstudio-Ketten, Adobe CC, Microsoft 365, etc.

Felder: name, category, provider, contactPhone, contactEmail,
cancellationMethod, cancellationInstructions, cancellationUrl

---

## KI-Extraktion (Weg 2 — Kernfeature)

### Eingabe-Quellen

| Quelle | Handling |
|---|---|
| Kamera (Foto Vertrag) | ImagePicker → JPEG → base64 |
| Screenshot teilen | receive_sharing_intent → SharedMediaType.image |
| PDF teilen | receive_sharing_intent → SharedMediaType.file → erste Seite rastern |
| URL teilen | SharedMediaType.url → optional: Preisseite laden |

### extraction_service.dart

```dart
class ExtractionService {
  static const _model = 'claude-haiku-4-5-20251001';

  static const _systemPrompt = '''
Du bist ein Datenextraktions-Assistent für Verträge und Abonnements.
Antworte AUSSCHLIESSLICH mit einem JSON-Objekt. Kein Kommentar, kein Markdown.
Felder:
{
  "name": "Produktname / Abo-Name",
  "provider": "Unternehmensname",
  "category": "streaming|versicherung|handy|internet|software|fitness|zeitung|sonstiges",
  "monthlyCost": 9.99,
  "billingCycle": "monthly|quarterly|yearly|weekly",
  "contactPhone": "+49...",
  "contactEmail": "kuendigung@...",
  "contactUrl": "https://...",
  "noticePeriod": "Freitext z.B. '3 Monate zum Quartalsende'",
  "cancellationMethod": "brief|online|telefon|email|automatisch",
  "cancellationInstructions": "Schritt-für-Schritt Anleitung auf Deutsch",
  "nextRenewal": "YYYY-MM-DD oder null",
  "notes": "Besonderheiten, Sonderkündigungsrecht etc."
}
Fehlende Felder als null. monthlyCost immer als Monatsbetrag (Jahresbetrag ÷ 12).
''';

  Future<ExtractionResult> extractFromImage(String base64Image) async {
    final response = await _callAnthropicApi(
      imageData: base64Image,
      mediaType: 'image/jpeg',
    );
    return _parseResponse(response);
  }

  Future<ExtractionResult> extractFromPdfPage(Uint8List pageImageBytes) async {
    final base64 = base64Encode(pageImageBytes);
    return extractFromImage(base64);
  }

  Future<Map<String, dynamic>> _callAnthropicApi({
    required String imageData,
    required String mediaType,
  }) async {
    // Aufruf geht an Supabase Edge Function — kein API-Key in der App
    final supabase = Supabase.instance.client;
    final result = await supabase.functions.invoke(
      'extract-contract',
      body: {'imageBase64': imageData, 'mediaType': mediaType},
    );
    return result.data as Map<String, dynamic>;
  }

  ExtractionResult _parseResponse(Map<String, dynamic> json) {
    return ExtractionResult(
      name: json['name'] as String? ?? '',
      provider: json['provider'] as String? ?? '',
      category: ContractCategory.values.byName(json['category'] as String? ?? 'sonstiges'),
      monthlyCost: (json['monthlyCost'] as num?)?.toDouble() ?? 0.0,
      // ... alle Felder mappen
      confidence: _assessConfidence(json),
    );
  }

  ExtractionConfidence _assessConfidence(Map<String, dynamic> json) {
    // Wie viele Pflichtfelder wurden gefüllt?
    final filled = ['name', 'provider', 'monthlyCost', 'cancellationMethod']
        .where((f) => json[f] != null).length;
    return switch (filled) {
      4     => ExtractionConfidence.high,
      2 || 3 => ExtractionConfidence.medium,
      _     => ExtractionConfidence.low,
    };
  }
}
```

### UX nach Extraktion

- Confidence HIGH → Formular vorausgefüllt, User scrollt und tippt "Speichern"
- Confidence MEDIUM → Formular vorausgefüllt, unsichere Felder gelb markiert
- Confidence LOW → Formular teils gefüllt, Toast: "Bitte prüfe die markierten Felder"
- User kann immer alle Felder manuell überschreiben

---

## Share-Extension Setup

### Android (AndroidManifest.xml)

```xml
<activity android:name=".MainActivity">
  <intent-filter>
    <action android:name="android.intent.action.SEND"/>
    <category android:name="android.intent.category.DEFAULT"/>
    <data android:mimeType="image/*"/>
  </intent-filter>
  <intent-filter>
    <action android:name="android.intent.action.SEND"/>
    <category android:name="android.intent.category.DEFAULT"/>
    <data android:mimeType="application/pdf"/>
  </intent-filter>
</activity>
```

### iOS (Info.plist)

```xml
<key>CFBundleDocumentTypes</key>
<array>
  <dict>
    <key>LSItemContentTypes</key>
    <array>
      <string>public.image</string>
      <string>com.adobe.pdf</string>
    </array>
  </dict>
</array>
```

---

## Provider-Bibliothek

Die Bibliothek ist eine statische Dart-Liste in `provider_library_data.dart`.
Kein API-Call, kein Netzwerk. Beim App-Start einmalig in die DB geschrieben (falls noch nicht vorhanden).

Format:
```dart
const providerLibrary = [
  ProviderTemplate(
    name: 'Netflix',
    category: ContractCategory.streaming,
    provider: 'Netflix International B.V.',
    contactUrl: 'https://www.netflix.com/cancelplan',
    cancellationMethod: CancellationMethod.online,
    cancellationInstructions:
        'Einloggen auf netflix.com → Konto → Mitgliedschaft kündigen. '
        'Kündigung wirkt zum Ende des aktuellen Abrechnungszeitraums.',
    noticePeriod: 'Jederzeit zum Ende des Abrechnungsmonats',
  ),
  // ... weitere Anbieter
];
```

User wählt Provider → tippt nur Preis ein → fertig.

---

## Erben & Teilen

### Tresor-Modus

Drei Freigabe-Varianten:

1. **Sofortzugang** — Erbe öffnet App, gibt PIN ein, sieht alles.
2. **Inaktivitäts-Tresor** — Automatische Weiterleitung wenn kein Lebenszeichen mehr erkannt wird. Siehe unten.
3. **Manueller Export** — User exportiert PDF / QR-Code und hinterlegt es physisch (Notar, Safe).

### Inaktivitäts-Tresor — Lebenszeichen-Modi

Der User wählt selbst welche Signale als "Lebenszeichen" gelten. Mehrere Modi sind kombinierbar —
jedes einzelne Signal reicht zum Zurücksetzen des Timers.

| Modus | Mechanismus | Zuverlässigkeit |
|---|---|---|
| Jährliche Bestätigungsmail | Pacto sendet 1× jährlich einen Link per E-Mail. Ein Klick reicht, kein App-Start nötig. | Hoch — empfohlen |
| Smartphone läuft | Flutter `workmanager` sendet alle 30 Tage einen stillen Hintergrund-Heartbeat | Android: gut · iOS: eingeschränkt (BGAppRefreshTask) |
| App öffnen | Jede App-Session schreibt `confirmed_at = now()` | Nur sinnvoll bei regelmäßiger Nutzung |
| Manuell | User löst Weitergabe bewusst selbst aus, kein automatischer Timer | Volle Kontrolle |

**Empfohlene Kombination:** Jahresmail + Smartphone-Heartbeat. Wer die App täglich nutzt,
merkt die Jahresmail nie. Wer nicht mehr reagiert, wird 14 Tage vorher gewarnt.

**Technischer Ablauf:**

```
Lebenszeichen eingehend → confirmed_at = now() in Supabase

pg_cron täglich 09:00 UTC:
  SELECT user WHERE confirmed_at < now() - interval AND tresor_enabled = true

  Bei 80% des Intervalls:
    → Vorwarnungs-E-Mail an User (Magic Link zum Reset, kein App-Start nötig)

  Bei 100% des Intervalls UND kein Reset in 14 Tagen:
    → PDF aus Supabase-Daten generieren
    → E-Mail mit PDF-Anhang an alle hinterlegten Erben
    → heir_notified = true  (verhindert tägliche Wiederholung)
```

**Wichtig:** PDF-Generierung läuft serverseitig (Supabase Edge Function), da das Gerät
des Users nicht mehr erreichbar sein könnte. Tresor-Modus setzt daher Supabase-Sync voraus —
im Onboarding klar kommunizieren.

**Einstellbares Intervall:** 30 / 60 / 90 / 180 Tage (Standard: 90 Tage)

### PDF-Export Inhalt

Deckblatt: Name, Datum, Hinweis "Vertraulich"
Pro Eintrag: Name, Anbieter, Kosten, Kündigungsfrist, Kündigungsanleitung, Kontaktdaten
Fußzeile: "Erstellt mit Pacto — softbrewstudio.com"

### Datenverschlüsselung

- Lokale DB: SQLCipher via `drift_sqflite` mit generiertem Key aus `flutter_secure_storage`
- Supabase-Sync: Felder vor Upload AES-256 verschlüsseln, Key niemals in Supabase speichern
- PIN für Erbenzugang: bcrypt-Hash, Min. 6 Stellen

---

## API-Architektur (kein BYOK)

Der Anthropic API-Key liegt **serverseitig** in einer Supabase Edge Function.
Die App schickt nur das Bild — der User sieht nie einen API-Key.

**Kostenrechnung:**
- Haiku: ~$0,002 pro Scan (Bild-Input + JSON-Output)
- 1.000 User × 30 Scans = 30.000 Scans = ~$60 Gesamtkosten
- Bei €2,99 Einmalkauf × 1.000 Verkäufe: API-Cost ist vernachlässigbar

**Abuse-Schutz via Rate-Limit:**

```typescript
// supabase/functions/extract-contract/index.ts
Deno.serve(async (req) => {
  // 1. Supabase Auth prüfen (anonyme Session reicht)
  const user = await getUser(req);
  if (!user) return new Response('Unauthorized', { status: 401 });

  // 2. Rate-Limit: max 100 Scans pro User-ID pro Monat
  // (kein echter User hat 100 Verträge — schützt vor Missbrauch)
  const count = await getScanCount(user.id);
  if (count >= 100) return new Response('Limit reached', { status: 429 });

  // 3. Bild entgegennehmen → Anthropic API (Key nur serverseitig)
  const { imageBase64 } = await req.json();
  const result = await callAnthropicHaiku(imageBase64);

  // 4. Scan-Count erhöhen
  await incrementScanCount(user.id);

  return new Response(JSON.stringify(result));
});
```

Die App authentifiziert sich mit einer anonymen Supabase-Session (wird beim ersten App-Start automatisch angelegt). Kein Account-Zwang für den User.

---

## Design-System

### Grundprinzipien (inhaltlich)
- **Ruhige Sprache** — kein "Tod", kein "Sterbefall" im UI. Stattdessen: "Für den Fall der Fälle", "Erben & Teilen", "Für deine Liebsten"
- **Keine eigene Cloud-Infrastruktur** — Daten bleiben lokal oder in Supabase des Users
- **Kein Abo für die App** — Einmalkauf, thematisch konsistent
- **Datensparsamkeit** — nur was für die Funktion nötig ist
- **Schnelle Ersteinrichtung** — User soll in unter 5 Minuten die ersten 3 Einträge haben

---

### Visuelles Design — Dark Premium

Die App hat ein durchgängig dunkles, hochwertiges Erscheinungsbild.
Referenz-Screenshot zeigt den finalen Designstand — jede Komponente orientiert sich daran.

#### Farben

```dart
// lib/shared/theme/app_colors.dart

class AppColors {
  // Hintergründe
  static const background       = Color(0xFF0A0A0F); // tiefschwarz, fast blau-schwarz
  static const surfaceCard      = Color(0xFF15151E); // Karten-Hintergrund
  static const surfaceElevated  = Color(0xFF1C1C28); // leicht erhöhte Elemente
  static const surfaceBorder    = Color(0x1AFFFFFF); // rgba(255,255,255,0.10) — Kartenrand

  // Primärfarbe
  static const primary          = Color(0xFF7C5CE7); // Violett — FAB, aktiver Nav-Tab, Links
  static const primaryLight     = Color(0x267C5CE7); // 15% Opacity — Highlights, Badges

  // Text
  static const textPrimary      = Color(0xFFFFFFFF);
  static const textSecondary    = Color(0x99FFFFFF); // 60% white
  static const textTertiary     = Color(0x4DFFFFFF); // 30% white — Labels, Hints

  // Status-Farben (für Badges, Icons, Status-Dots)
  static const statusGreen      = Color(0xFF00C896); // aktiv
  static const statusGreenBg    = Color(0x1A00C896);
  static const statusAmber      = Color(0xFFFFB020); // Warnung, nächste 30 Tage
  static const statusAmberBg    = Color(0x1AFFB020);
  static const statusBlue       = Color(0xFF4A9EFF); // Info, hinterlegt
  static const statusBlueBg     = Color(0x1A4A9EFF);
  static const statusRed        = Color(0xFFFF5A5A); // Fehler, abgelaufen
  static const statusRedBg      = Color(0x1AFF5A5A);

  // Hero-Overlay (Dashboard-Header)
  static const heroGradientTop    = Color(0x00000000); // transparent
  static const heroGradientBottom = Color(0xFF0A0A0F); // fließt in Background über
}
```

#### Typografie

```dart
// lib/shared/theme/app_text_styles.dart
// Systemschrift: SF Pro (iOS) / Roboto (Android) — kein Custom Font nötig

class AppTextStyles {
  // Dashboard Begrüßung
  static const heroTitle = TextStyle(
    fontSize: 28, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, letterSpacing: -0.5,
  );
  static const heroSubtitle = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // Section Labels (DEINE VERTRÄGE, ÜBERSICHT)
  static const sectionLabel = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w600,
    color: AppColors.textTertiary, letterSpacing: 1.2,
  );

  // Listeneintrag
  static const listTitle    = TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary);
  static const listSubtitle = TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textSecondary);
  static const listAmount   = TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static const listDate     = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textTertiary);

  // Stats-Karte (14 / Verträge / aktiv)
  static const statNumber   = TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static const statLabel    = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary);
}
```

#### Abstände & Radien

```dart
class AppSpacing {
  static const screenPadding   = EdgeInsets.symmetric(horizontal: 16);
  static const cardPadding      = EdgeInsets.all(16);
  static const listItemPadding  = EdgeInsets.symmetric(horizontal: 16, vertical: 14);
  static const sectionGap       = SizedBox(height: 24);
  static const itemGap          = SizedBox(height: 8);
}

class AppRadius {
  static const card     = BorderRadius.all(Radius.circular(16));
  static const listItem = BorderRadius.all(Radius.circular(12));
  static const badge    = BorderRadius.all(Radius.circular(20));
  static const icon     = BorderRadius.all(Radius.circular(10));
}
```

---

### Komponenten

#### Dashboard Hero (oberster Bereich)

```
Stack:
  ├── Hintergrundbild (dunkle Berglandschaft, assets/images/hero_bg.jpg)
  │     → BoxFit.cover, Höhe ~220px
  │     → LinearGradient Overlay: transparent oben → AppColors.background unten
  ├── SafeArea-Inhalt:
  │     ├── Row: Hamburger-Icon (links) + Glocken-Icon (rechts)  — beide in Card-Surface
  │     ├── SizedBox(height: 32)
  │     ├── "Hallo [Name] 👋"  — heroTitle
  │     └── "Deine Verträge. Deine Übersicht. Für deine Liebsten."  — heroSubtitle
```

Das Hintergrundbild ist ein statisches Asset (kein Netzwerk).
Empfohlen: dunkle Natur-/Landschafts-Fotografie, kein Text, kein Gesicht.
Alternative: generierter dunkler Gradient mit subtiler Textur.

#### Stats-Karte (Übersicht)

Vier gleichmäßige Spalten in einer Card (surfaceCard, border surfaceBorder):

```
┌─────────────────────────────────────────────┐
│  ÜBERSICHT                                  │
│  [Icon]  [Icon]  [Icon]  [Icon]             │
│    14      3       8       2                │
│  Verträge  Kündigung  Abos  Erben           │
│  aktiv  nächste 30T  aktiv  hinterlegt      │
│  (grün)   (amber)   (grün)   (blau)         │
└─────────────────────────────────────────────┘
```

Icon-Hintergründe: je Kategorie eigene statusXxxBg Farbe, Icon in statusXxx.

#### Vertrags-Liste (ContractListTile)

```
┌─────────────────────────────────────────────────┐
│  [App-Logo 40px]  Netflix          17,99€/Mo  › │
│                   Streaming-Abo                  │
│                   Nächste Zahlung: 15.06.2025    │
└─────────────────────────────────────────────────┘
```

- App-Logo: echtes Icon wenn in Provider-Bibliothek vorhanden (via `cached_network_image` von
  `https://logo.clearbit.com/{domain}`) — Fallback: farbiger Icon-Kreis mit Initiale
- Hintergrund: surfaceCard, keine sichtbare Trennlinie zwischen Items
- Chevron rechts: textTertiary

#### Notfall-Banner (Dashboard unten)

```
┌─────────────────────────────────────────────────┐
│  [Schild-Icon]  FÜR DEN NOTFALL                 │
│                 Deine Erben sind informiert      │
│                 Im Ernstfall werden deine...     │
│                              [Erben verwalten]  │
└─────────────────────────────────────────────────┘
```

Hintergrund: surfaceElevated mit grünem linken Rand (3px, statusGreen).
Nur sichtbar wenn mindestens ein Erbe hinterlegt ist.
Wenn kein Erbe: Banner "Noch niemand hinterlegt — jetzt einrichten" in amber.

#### Bottom Navigation Bar

```dart
BottomNavigationBar(
  backgroundColor: AppColors.surfaceCard,
  selectedItemColor: AppColors.primary,
  unselectedItemColor: AppColors.textTertiary,
  type: BottomNavigationBarType.fixed,
  // Items: Übersicht | Verträge | [FAB] | Erben | Mehr
)
```

Mittlerer Tab ist kein echtes NavItem — stattdessen ein FloatingActionButton:
```dart
FloatingActionButton(
  backgroundColor: AppColors.primary,
  shape: CircleBorder(),
  child: Icon(Icons.add, color: Colors.white, size: 28),
  onPressed: () => showAddContractSheet(context),
)
// Positioniert via bottomNavigationBar + floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked
```

#### Status-Badges

```dart
// Wiederverwendbar für alle Status-Anzeigen
Widget statusBadge(String label, Color color, Color bgColor) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
  decoration: BoxDecoration(color: bgColor, borderRadius: AppRadius.badge),
  child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
);

// Verwendung:
statusBadge('aktiv',           AppColors.statusGreen, AppColors.statusGreenBg)
statusBadge('nächste 30 Tage', AppColors.statusAmber, AppColors.statusAmberBg)
statusBadge('hinterlegt',      AppColors.statusBlue,  AppColors.statusBlueBg)
```

---

### ThemeData

```dart
// lib/shared/theme/app_theme.dart

ThemeData get darkTheme => ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.background,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.primary,
    surface: AppColors.surfaceCard,
    background: AppColors.background,
  ),
  cardTheme: CardTheme(
    color: AppColors.surfaceCard,
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.card,
      side: BorderSide(color: AppColors.surfaceBorder, width: 0.5),
    ),
    elevation: 0,
    margin: EdgeInsets.zero,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
  ),
  dividerTheme: const DividerThemeData(color: AppColors.surfaceBorder, thickness: 0.5),
);
```

**Nur Dark Mode.** Kein Light Mode — passt zum Produkt, reduziert Komplexität.

---

## Wichtige Flutter-Pakete (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  drift: ^2.x
  drift_sqflite: ^2.x          # mit SQLCipher Support
  riverpod: ^2.x
  flutter_riverpod: ^2.x
  go_router: ^13.x
  receive_sharing_intent: ^2.x
  image_picker: ^1.x
  supabase_flutter: ^2.x       # Auth + Edge Functions + optionaler Sync
  flutter_secure_storage: ^9.x
  pdf: ^3.x                    # PDF-Export
  qr_flutter: ^4.x
  flutter_pdfview: ^1.x
  uuid: ^4.x
  cached_network_image: ^3.x   # Provider-Logos via Clearbit
  intl: ^0.19.x

dev_dependencies:
  drift_dev: ^2.x
  build_runner: ^2.x
```

---

## Entwicklungsreihenfolge (MVP)

1. **Drift-Schema + DAO** — Datenbank aufsetzen, CRUD testen
2. **Provider-Bibliothek** — statische Liste, Suche, Auswahl → Formular
3. **Add/Edit Formular** — alle Felder, Validierung, Speichern
4. **Dashboard** — Liste, Gesamtkosten, Kategorien
5. **Detail-Screen** — Anzeige, Löschen
6. **KI-Extraktion** — Kamera + API-Call + Formular vorausfüllen
7. **Share-Extension** — Android + iOS konfigurieren
8. **Erben-Screen** — PIN-Schutz, PDF-Export
9. **Supabase-Sync** — optional, verschlüsselt
10. **Onboarding + API-Key** — letzter Schritt vor Store-Release

---

## Noch offen / zu entscheiden

- [ ] Kontoauszug-Import: CSV-Format variiert stark je Bank — vorerst weglassen oder nur als "kommt bald" ankündigen
- [ ] Inaktivitäts-Tresor: Supabase Edge Function für PDF-Generierung + E-Mail-Versand — MVP ohne, v1.1 mit. Lebenszeichen-Modus "Smartphone läuft" für MVP nur Android, iOS in v1.1.
- [x] Mehrsprachigkeit: Deutsch + Englisch implementiert (flutter_localizations, lib/l10n/, locale_provider.dart via shared_preferences)
- [ ] iPad / Desktop: vorerst nur Mobile
