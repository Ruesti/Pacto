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

## Phase 6 — KI-Extraktion ✅ (Code fertig, Supabase ausstehend)

**Ziel:** Foto oder PDF scannen → Formular automatisch vorausfüllen.

**Aufgaben:**
- [x] Edge Function `extract-contract` vorbereitet (TypeScript, Anthropic claude-haiku-4-5, Rate-Limit)
- [ ] Supabase-Projekt anlegen, anonyme Auth aktivieren
- [ ] Edge Function deployen
- [x] `extraction_service.dart` — API-Call an Edge Function
- [x] `extraction_result.dart` — Modell + `ExtractionConfidence` enum
- [x] `scan_controller.dart` — FilePicker (Galerie + Datei)
- [x] Confidence-Handling: HIGH/MEDIUM/LOW → Toast-Feedback

**Abnahme:** Supabase-Projekt erstellen, Edge Function deployen, Dokument scannen.

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

## Phase 9 — Supabase-Sync ⬜ (Code-Gerüst fertig)

**Ziel:** Verschlüsseltes Cloud-Backup, Basis für Tresor-Modus.

**Aufgaben:**
- [x] `supabase_sync_screen.dart` — Sync aktivieren/deaktivieren (UI)
- [ ] Supabase-Projekt erstellen, URL + Anon-Key konfigurieren
- [ ] AES-256-Verschlüsselung der Felder vor Upload
- [ ] Sync-Logik: lokal → Supabase bei Änderung
- [ ] Lebenszeichen-Tresor: `confirmed_at` in Supabase schreiben

**Abnahme:** Daten verschlüsselt in Supabase sehen.

---

## Phase 10 — Onboarding + Store-Release ⬜

**Ziel:** App ist store-ready.

**Aufgaben:**
- [ ] Onboarding-Flow (3 Screens): Was ist Pacto? / Erben-Feature / Scan-Feature
- [ ] Freemium-Gate: ab dem 6. Eintrag → Kauf-Dialog
- [ ] In-App-Purchase (einmaliger Kauf ~2,99 €)
- [ ] App-Icon, Splash-Screen
- [ ] `settings_screen.dart` — Sync, Tresor-Modus, Kauf wiederherstellen
- [ ] Android: App Bundle, Signing
- [ ] iOS: Xcode Archive, App Store Connect
- [ ] Store-Listings: Screenshots, Beschreibung (DE), Keywords

**Abnahme:** Interne Testversion auf echtem Gerät lauffähig, Kauf testbar.

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
| 9 | Supabase-Sync | 🔶 Gerüst fertig — Supabase-Konfiguration ausstehend |
| 10 | Onboarding + Release | ⬜ offen |

## Nächste Schritte

**Sofort machbar (lokal):**
- Auf einem Android/iOS-Gerät starten: `flutter run`
- Phase 10: Onboarding-Screens und Freemium-Gate implementieren

**Benötigt externe Konfiguration:**
- Supabase-Projekt anlegen (kostenlos auf supabase.com)
- Edge Function deployen (`supabase functions deploy extract-contract`)
- Anthropic API-Key in Supabase-Secrets hinterlegen (`ANTHROPIC_API_KEY`)
- App-URL und Anon-Key in `extraction_service.dart` konfigurieren
