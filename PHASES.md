# Phasenmodell — Pacto MVP

Basierend auf der Entwicklungsreihenfolge in CLAUDE.md.
Jede Phase endet mit einem lauffähigen, testbaren Zwischenstand.

---

## Phase 1 — Drift-Schema + DAO

**Ziel:** Datenbank steht, CRUD funktioniert, kein UI nötig.

**Aufgaben:**
- [ ] `contracts_table.dart` — alle Spalten gemäß Datenmodell
- [ ] `heirs_table.dart`
- [ ] `provider_library_table.dart`
- [ ] Enums anlegen: `ContractCategory`, `CancellationMethod`, `BillingCycle`, `HeirAccess`
- [ ] `database.dart` — `AppDatabase` mit Drift aufsetzen, alle Tables registrieren
- [ ] `contracts_dao.dart` — CRUD: insert, update, delete, watchAll, findById
- [ ] `heirs_dao.dart` — CRUD analog
- [ ] `pubspec.yaml` — Drift, uuid, flutter_secure_storage eintragen
- [ ] `build_runner` ausführen, generierte Dateien prüfen
- [ ] Unit-Test: Vertrag anlegen → lesen → löschen

**Abnahme:** `flutter test` grün, kein UI nötig.

---

## Phase 2 — Provider-Bibliothek

**Ziel:** User kann aus ~40 Anbietern wählen, Formular wird vorausgefüllt.

**Aufgaben:**
- [ ] `provider_library_data.dart` — mind. 10 Einträge (Netflix, Spotify, Telekom, etc.)
- [ ] `ProviderTemplate`-Modell anlegen
- [ ] Beim App-Start: Templates einmalig in DB schreiben (falls nicht vorhanden)
- [ ] `provider_library_screen.dart` — Suchliste mit Filter
- [ ] Navigation: Auswahl → `add_contract_screen` mit vorausgefüllten Feldern

**Abnahme:** Netflix auswählen → Formular öffnet mit korrekten Daten.

---

## Phase 3 — Add/Edit Formular

**Ziel:** Vollständiges Formular für manuellen Vertragseintrag.

**Aufgaben:**
- [ ] `add_contract_screen.dart` — alle Felder aus Datenmodell
  - Name, Anbieter, Kategorie (Dropdown), Kosten, Abrechnungszyklus
  - Kündigungsmethode, Kündigungsanleitung, Kündigungsfrist
  - Kontaktdaten (Telefon, E-Mail, URL)
  - Vertragsbeginn, nächste Verlängerung
  - Notizen
- [ ] `add_contract_provider.dart` — Riverpod StateNotifier für Formularstate
- [ ] `entry_method_sheet.dart` — Bottom Sheet: "Bibliothek / Scan / Manuell"
- [ ] Validierung: Name und Anbieter Pflichtfelder
- [ ] Monatsbetrag-Normalisierung: Jahresbetrag ÷ 12
- [ ] Edit-Modus: bestehenden Vertrag laden und speichern

**Abnahme:** Vertrag anlegen, speichern, wieder öffnen und bearbeiten.

---

## Phase 4 — Dashboard

**Ziel:** Hauptansicht mit Übersicht aller Verträge und Gesamtkosten.

**Aufgaben:**
- [ ] `dashboard_screen.dart` — Liste aller Verträge
- [ ] `cost_summary_card.dart` — monatliche Gesamtkosten, Anzahl Verträge
- [ ] `contract_list_tile.dart` — Name, Anbieter, Kosten, Kategorie-Pill
- [ ] Sortierung: nach Kosten / alphabetisch / Kategorie
- [ ] Filter: nach Kategorie
- [ ] FAB → `entry_method_sheet`
- [ ] `category_pill.dart` + `cost_badge.dart` in shared/widgets
- [ ] `app_theme.dart` — Basis-Theme (Farben, Typography)
- [ ] `currency_formatter.dart`, `date_formatter.dart`

**Abnahme:** 3 Verträge anlegen → Dashboard zeigt korrekte Summe und Kategorie-Filter.

---

## Phase 5 — Detail-Screen

**Ziel:** Vollansicht eines Vertrags, Löschen möglich.

**Aufgaben:**
- [ ] `contract_detail_screen.dart` — alle Felder anzeigen
- [ ] `cancellation_info_card.dart` — Kündigungsanleitung, Frist, Methode prominent
- [ ] `document_attachment.dart` — Dokumentvorschau (PDF/Bild) wenn vorhanden
- [ ] Bearbeiten-Button → Edit-Modus Phase 3
- [ ] Löschen mit Bestätigungs-Dialog
- [ ] Navigation via go_router einrichten (Dashboard ↔ Detail ↔ Add/Edit)

**Abnahme:** Vollständiger CRUD-Flow ohne Abstürze.

---

## Phase 6 — KI-Extraktion

**Ziel:** Foto oder PDF scannen → Formular automatisch vorausfüllen.

**Aufgaben:**
- [ ] Supabase-Projekt anlegen, anonyme Auth aktivieren
- [ ] Edge Function `extract-contract` deployen (TypeScript, Anthropic API, Rate-Limit)
- [ ] `supabase_flutter` in pubspec.yaml, Supabase initialisieren
- [ ] `extraction_service.dart` — API-Call an Edge Function
- [ ] `extraction_result.dart` — Modell + `ExtractionConfidence` enum
- [ ] `scan_controller.dart` — ImagePicker (Kamera + Galerie)
- [ ] PDF: erste Seite rastern → als Bild senden
- [ ] Confidence-Handling:
  - HIGH → Felder grün, direkt speichern
  - MEDIUM → unsichere Felder gelb markiert
  - LOW → Toast "Bitte prüfe die markierten Felder"

**Abnahme:** Foto eines Vertrags → mind. Name und Kosten korrekt extrahiert.

---

## Phase 7 — Share-Extension

**Ziel:** App aus anderen Apps heraus öffnen (PDF oder Bild teilen).

**Aufgaben:**
- [ ] `receive_sharing_intent` in pubspec.yaml
- [ ] Android `AndroidManifest.xml` — Intent-Filter für `image/*` und `application/pdf`
- [ ] iOS `Info.plist` — `CFBundleDocumentTypes` für `public.image` und `com.adobe.pdf`
- [ ] `scan_controller.dart` — SharedMediaType.image / .file verarbeiten
- [ ] Geteilte Datei → Extraktion → Formular

**Abnahme:** PDF aus Dateimanager an Pacto teilen → Formular öffnet mit extrahierten Daten.

---

## Phase 8 — Erben & Teilen

**Ziel:** Hinterbliebene erhalten Zugang zu allen Verträgen.

**Aufgaben:**
- [ ] `heirs_screen.dart` — Liste der Erben, Erben hinzufügen/löschen
- [ ] `heir_detail_screen.dart` — Name, E-Mail, Zugangsstufe, PIN setzen
- [ ] PIN-Hash: bcrypt, mind. 6 Stellen
- [ ] `share_export_service.dart` — PDF generieren
  - Deckblatt: Name, Datum, "Vertraulich"
  - Pro Vertrag: alle relevanten Felder
  - Fußzeile: "Erstellt mit Pacto — softbrewstudio.com"
- [ ] QR-Code-Export via `qr_flutter`
- [ ] Zugangsstufen: `vollzugang` vs. `nurListe`
- [ ] PIN-Schutzansicht: Erbe gibt PIN ein → sieht freigegebene Daten

**Abnahme:** PDF exportieren, öffnen, alle Verträge vollständig lesbar.

---

## Phase 9 — Supabase-Sync (optional)

**Ziel:** Verschlüsseltes Cloud-Backup, Basis für Tresor-Modus.

**Aufgaben:**
- [ ] `supabase_sync_screen.dart` — Sync aktivieren/deaktivieren
- [ ] AES-256-Verschlüsselung der Felder vor Upload
- [ ] Encryption-Key in `flutter_secure_storage`, niemals in Supabase
- [ ] Sync-Logik: lokal → Supabase bei Änderung
- [ ] Konflikt-Strategie: last-write-wins (MVP)
- [ ] Inaktivitäts-Tresor Grundstruktur:
  - `confirmed_at` in Supabase schreiben (App-Start als Lebenszeichen)
  - Intervall wählen: 30 / 60 / 90 / 180 Tage

**Abnahme:** Sync ein- und ausschalten, Daten erscheinen verschlüsselt in Supabase.

---

## Phase 10 — Onboarding + Store-Release

**Ziel:** App ist store-ready.

**Aufgaben:**
- [ ] Onboarding-Flow (3 Screens): Was ist Pacto? / Erben-Feature / Scan-Feature
- [ ] Freemium-Gate: ab dem 6. Eintrag → Kauf-Dialog
- [ ] In-App-Purchase (einmaliger Kauf ~2,99 €) einbinden
- [ ] App-Icon, Splash-Screen finalisieren
- [ ] `settings_screen.dart` — Sprache, Sync, Tresor-Modus, Kauf wiederherstellen
- [ ] Android: App Bundle erstellen, Signing konfigurieren
- [ ] iOS: Xcode Archive, App Store Connect hochladen
- [ ] Store-Listings: Screenshots, Beschreibung (DE), Keywords

**Abnahme:** Interne Testversion auf echtem Gerät lauffähig, Kauf testbar.

---

## Meilensteine auf einen Blick

| Phase | Inhalt | Status |
|---|---|---|
| 1 | Drift-Schema + DAO | ⬜ offen |
| 2 | Provider-Bibliothek | ⬜ offen |
| 3 | Add/Edit Formular | ⬜ offen |
| 4 | Dashboard | ⬜ offen |
| 5 | Detail-Screen | ⬜ offen |
| 6 | KI-Extraktion | ⬜ offen |
| 7 | Share-Extension | ⬜ offen |
| 8 | Erben & Teilen | ⬜ offen |
| 9 | Supabase-Sync | ⬜ offen |
| 10 | Onboarding + Release | ⬜ offen |
