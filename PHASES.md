# Phasenmodell — Pacto MVP

Basierend auf der Entwicklungsreihenfolge in CLAUDE.md.
Jede Phase endet mit einem lauffähigen, testbaren Zwischenstand.

---

## Phase 1 — Drift-Schema + DAO ✅

**Ziel:** Datenbank steht, CRUD funktioniert, kein UI nötig.

**Aufgaben:**
- [x] `contracts_table.dart` — alle Spalten gemäß Datenmodell
- [x] `heirs_table.dart`
- [x] `provider_library_table.dart`
- [x] Enums anlegen: `ContractCategory`, `CancellationMethod`, `BillingCycle`, `HeirAccess`
- [x] `database.dart` — `AppDatabase` mit Drift aufsetzen, alle Tables registrieren
- [x] `contracts_dao.dart` — CRUD: insert, update, delete, watchAll, findById
- [x] `heirs_dao.dart` — CRUD analog
- [x] `pubspec.yaml` — Drift, uuid, supabase_flutter etc. eintragen
- [x] `build_runner` ausgeführt, generierte Dateien geprüft
- [x] Unit-Test: Vertrag anlegen → lesen → löschen

**Abnahme:** `flutter test` grün ✅

---

## Phase 2 — Provider-Bibliothek ✅

**Ziel:** User kann aus 20+ Anbietern wählen, Formular wird vorausgefüllt.

**Aufgaben:**
- [x] `provider_library_data.dart` — 20 Einträge (Netflix, Spotify, Telekom, ADAC, etc.)
- [x] `ProviderTemplate`-Modell anlegen
- [x] `provider_library_screen.dart` — Suchliste mit Filter nach Kategorie
- [x] Navigation: Auswahl → `add_contract_screen` mit vorausgefüllten Feldern

**Abnahme:** Bibliothek öffnen → Anbieter wählen → Formular öffnet vorausgefüllt.

---

## Phase 3 — Add/Edit Formular ✅

**Ziel:** Vollständiges Formular für manuellen Vertragseintrag.

**Aufgaben:**
- [x] `add_contract_screen.dart` — alle Felder aus Datenmodell
- [x] `add_contract_provider.dart` — Riverpod StateNotifier für Formularstate
- [x] `entry_method_sheet.dart` — Bottom Sheet: "Bibliothek / Scan / Manuell"
- [x] Validierung: Name und Anbieter Pflichtfelder
- [x] Monatsbetrag-Normalisierung: Jahresbetrag ÷ 12
- [x] Edit-Modus: bestehenden Vertrag laden und speichern

**Abnahme:** Vertrag anlegen, speichern, wieder öffnen und bearbeiten.

---

## Phase 4 — Dashboard ✅

**Ziel:** Hauptansicht mit Übersicht aller Verträge und Gesamtkosten.

**Aufgaben:**
- [x] `dashboard_screen.dart` — Liste aller Verträge
- [x] `cost_summary_card.dart` — monatliche Gesamtkosten, Anzahl Verträge
- [x] `contract_list_tile.dart` — Name, Anbieter, Kosten, Kategorie-Pill
- [x] Sortierung: nach Kosten / alphabetisch / Kategorie / Verlängerung
- [x] Filter: nach Kategorie
- [x] FAB → `entry_method_sheet`
- [x] `category_pill.dart` + `cost_badge.dart` in shared/widgets
- [x] `app_theme.dart` — Basis-Theme (Farben, grüner Akzent)
- [x] `currency_formatter.dart`, `date_formatter.dart`

**Abnahme:** 3 Verträge anlegen → Dashboard zeigt korrekte Summe und Kategorie-Filter.

---

## Phase 5 — Detail-Screen ✅

**Ziel:** Vollansicht eines Vertrags, Löschen möglich.

**Aufgaben:**
- [x] `contract_detail_screen.dart` — alle Felder anzeigen
- [x] `cancellation_info_card.dart` — Kündigungsanleitung, Frist, Methode prominent
- [x] `document_attachment.dart` — Dokumentvorschau wenn vorhanden
- [x] Bearbeiten-Button → Edit-Modus Phase 3
- [x] Löschen mit Bestätigungs-Dialog
- [x] Navigation: Dashboard ↔ Detail ↔ Add/Edit

**Abnahme:** Vollständiger CRUD-Flow ohne Abstürze.

---

## Phase 6 — KI-Extraktion ✅ (Code fertig, Supabase-Deploy ausstehend)

**Ziel:** Foto oder PDF scannen → Formular automatisch vorausfüllen.

**Aufgaben:**
- [x] Edge Function `extract-contract` vorbereitet (TypeScript, Anthropic claude-haiku-4-5, Rate-Limit)
- [ ] Supabase-Projekt anlegen, anonyme Auth aktivieren
- [ ] Edge Function deployen
- [x] `extraction_service.dart` — API-Call an Edge Function
- [x] `extraction_result.dart` — Modell + `ExtractionConfidence` enum
- [x] `scan_controller.dart` — FilePicker (Galerie + Datei)
- [x] `prefillFromExtractionResult` im AddContractNotifier
- [x] Confidence-Banner im Formular (grün/gelb/rot)
- [x] Dashboard-Flow: Scan → Result → AddContractScreen mit Prefill
- [x] `scan_config_screen.dart` — URL + Anon Key in SharedPreferences, Setup-Anleitung
- [x] `main.dart` ruft `applyStoredScanConfig()` beim Start

**Abnahme:** Supabase-Projekt erstellen, Edge Function deployen, URL+Key in App eintragen, Dokument scannen.

---

## Phase 7 — Share-Extension ✅ (Code fertig)

**Ziel:** App aus anderen Apps heraus öffnen (PDF oder Bild teilen).

**Aufgaben:**
- [x] Android `AndroidManifest.xml` — Intent-Filter für `image/*` und `application/pdf`
- [x] iOS `Info.plist` — `CFBundleDocumentTypes` für `public.image` und `com.adobe.pdf`
- [x] `scan_controller.dart` — FilePicker verarbeitet geteilte Dateien

**Abnahme:** Datei aus Dateimanager an Pacto teilen (benötigt echtes Gerät).

---

## Phase 8 — Erben & Teilen ✅

**Ziel:** Hinterbliebene erhalten Zugang zu allen Verträgen.

**Aufgaben:**
- [x] `heirs_screen.dart` — Liste der Erben, Erben hinzufügen/löschen
- [x] `heir_detail_screen.dart` — Name, E-Mail, Zugangsstufe, PIN setzen
- [x] PIN-Hash: SHA-256, mind. 6 Stellen
- [x] `share_export_service.dart` — Textexport (PDF-Paket: TODO für Phase 10)
- [x] Zugangsstufen: `vollzugang` vs. `nurListe`

**Abnahme:** Erbe anlegen, Export starten.

---

## Phase 9 — Supabase-Sync ✅ (Code fertig, Supabase-Projekt ausstehend)

**Ziel:** Verschlüsseltes Cloud-Backup, Basis für Tresor-Modus.

**Aufgaben:**
- [x] `supabase_sync_screen.dart` — URL/Key-Eingabe, Sync-Now, Last-Sync
- [x] `crypto_service.dart` — AES-256-GCM via pointycastle, Schlüssel in SharedPreferences
- [x] `cloud_sync_service.dart` — Contracts + Heirs als verschlüsseltes Blob hochladen
- [x] `vault_screen.dart` — Lebenszeichen-Tresor mit Intervall, Bestätigungs-Button, Heartbeat
- [x] Unit-Test: AES-Round-Trip
- [ ] Supabase-Projekt erstellen, `sync_data` und `heartbeats` Tabellen anlegen
- [ ] Schlüssel zu zweitem Gerät übertragen (Pull-Sync — v1.1)

**Abnahme:** Daten verschlüsselt in Supabase-Tabelle `sync_data` sichtbar.

---

## Phase 10 — Onboarding + Store-Release 🔶 (Code fertig, Store-Schritte offen)

**Ziel:** App ist store-ready.

**Aufgaben:**
- [x] Onboarding-Flow (3 Screens): Verträge / KI-Scan / Erben-Feature
- [x] First-Run-Detection in `app.dart` via SharedPreferences
- [x] Freemium-Gate: ab dem 6. Eintrag → Kauf-Dialog
- [x] Premium-Provider (Riverpod) — lokaler Test-Unlock
- [x] `settings_screen.dart` — KI-Scan, Sync, Tresor, Onboarding wiederholen, Kauf-Status
- [ ] In-App-Purchase echte Integration (Google Play Billing / StoreKit)
- [ ] App-Icon, Splash-Screen (PNG-Assets erzeugen lassen)
- [ ] Android: App Bundle, Signing-Key
- [ ] iOS: Xcode Archive, App Store Connect
- [ ] Store-Listings: Screenshots, Beschreibung (DE), Keywords

**Abnahme:** Interne Testversion auf echtem Gerät lauffähig, Onboarding + Freemium-Gate testbar.

---

## Meilensteine auf einen Blick

| Phase | Inhalt | Status |
|---|---|---|
| 1 | Drift-Schema + DAO | ✅ fertig (Tests grün) |
| 2 | Provider-Bibliothek | ✅ fertig |
| 3 | Add/Edit Formular | ✅ fertig |
| 4 | Dashboard | ✅ fertig |
| 5 | Detail-Screen | ✅ fertig |
| 6 | KI-Extraktion | ✅ Code fertig — Supabase ausstehend |
| 7 | Share-Extension | ✅ Code fertig — Gerätetest ausstehend |
| 8 | Erben & Teilen | ✅ fertig |
| 9 | Supabase-Sync | ✅ Code fertig — Supabase-Tabellen ausstehend |
| 10 | Onboarding + Release | 🔶 Code fertig — Store-Release ausstehend |

## Nächste Schritte

**Sofort machbar (lokal):**
- Auf Android/iOS starten: `flutter run` und Onboarding + Freemium-Gate testen
- App-Icon und Splash-Screen-Assets erzeugen

**Benötigt externe Konfiguration:**
- Supabase-Projekt anlegen (kostenlos auf supabase.com)
- Edge Function deployen (`supabase functions deploy extract-contract`)
- `ANTHROPIC_API_KEY` in Supabase-Secrets hinterlegen
- Tabellen `sync_data (device_id uuid pk, encrypted_payload text, updated_at timestamptz)` und
  `heartbeats (device_id uuid pk, confirmed_at timestamptz)` anlegen
- URL + Anon-Key in den Pacto-Einstellungen (KI-Scan + Cloud-Sync) eintragen

**Für Store-Release:**
- In-App-Purchase echte Integration (Google Play Billing / StoreKit)
- Android Signing-Key + App Bundle
- iOS Xcode Archive + App Store Connect
- Store-Listings (Screenshots, Texte DE)
