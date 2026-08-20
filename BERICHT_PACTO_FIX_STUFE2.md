# BERICHT — Pacto Launch Fix, Stufe 2 (Ehrlichkeit)

> **Auftrag:** `BRIEF_PACTO_FIX.md`, Stufe 2 (Phasen 5–9).
> **Branch:** `fix/launch-stufe2` (gestapelt auf `fix/launch-stufe1`).
> **Commits:** Phase 6 `79df72c` · Phase 9 `28b8dc6` · Phase 5 `04da22a`
> · Phase 7 `d65da64` · Phase 8 `f7a0a0e`.
> **Ergebnis:** Alle fünf Phasen umgesetzt. Verifikation, soweit hier möglich,
> grün. Zwei Produktentscheidungen wurden am Checkpoint mit dir getroffen.

---

## Entscheidungen am Checkpoint

| Phase | Frage | Entscheidung (Nutzer) | Umsetzung |
|---|---|---|---|
| **7 (§0.4)** | Maximum-Modus | **(a)** behalten + ehrlich einschränken | Silent-Fallback raus, bewusste `vaultPolicy`, UI-Hinweis |
| **8 (1-D)** | „Backup" | **(b)** ehrlich benennen + auf Account verweisen | Wortlaut entschärft, Nicht-Backup-Hinweis (ohne Konto) |

---

## Verifikations-Rahmen

Wie in Stufe 1: **kein Docker** in dieser Session, daher kein `supabase start`.
Ersatzweise laufen die **echten** Migrationen (jetzt inkl. der beiden neuen,
`…140000`) gegen ein eigenständiges PostgreSQL; die Dart-Seite über
`flutter analyze`/`flutter test`, die Edge Functions über `deno check`.

**Ausgabe (final):**
- `deno check` aller **5** Edge Functions → grün.
- pg-Harness (`verify_vault_rls_pg.sql`, alle 4 Fix-Migrationen + TC1–TC6) →
  `Alle Assertions gruen` (**psql exit 0**).
- `flutter analyze lib/` → 2 Issues (beide die vorbestehende
  `anonKey`-Deprecation). `flutter test` → **20/20 grün** (inkl. neuem
  `pin_hash_test`).

**Nicht hier verifizierbar** (Docker/Gerät): der reale E2E-Versandpfad
(Resend-Mails, Cron-Ablauf), der workmanager-Hintergrund-Isolate und die GUI —
das braucht `supabase start` + ein Gerät.

---

## Phase 5 — Der Tresor bekommt automatisch Daten (2-E)

**Problem:** `syncPayloads` hatte genau einen Aufrufer (den Button). Wer den
Tresor aktivierte, aber nie synchronisierte, löste im Ernstfall `no_payloads`
aus.

**Umgesetzt:**
- Neuer **`VaultAutoSyncService`**: lauscht auf Änderungen an Verträgen **und**
  Erben (`watchAll`, initiale Emission übersprungen) und synchronisiert
  entprellt (3 s), sofern der Tresor aktiv ist. Fängt auch den
  Account-Restore (`replaceAll`). Als `vaultAutoSyncServiceProvider` am
  App-Root beobachtet (lebt die ganze App-Laufzeit).
- **Aktivieren** löst sofort einen Erst-Sync aus (`syncNow`), damit der Tresor
  nicht leer bleibt.
- Tresor-UI: **„Hinterlegte Briefe: N"** (live = aktive Erben) und ein
  deutlicher **Warnzustand bei null Briefen**; Hinweis auf den Auto-Sync.

## Phase 6 — Versand darf nicht still scheitern (2-D)

**Problem:** `vault-trigger` setzte `heir_notified_at` unabhängig vom
Zustellerfolg und verhinderte danach jeden weiteren Versuch. `vault-heartbeat`
setzte `heir_notified_at` bedingungslos zurück.

**Umgesetzt:**
- Migration `…140000`: `vault_payloads.sent_at` (Zustellung pro Erbe),
  `vault_settings.notify_attempts` + `owner_alerted_at`.
- `vault-trigger`: `heir_notified_at` wird **nur** gesetzt, wenn **alle** offenen
  Briefe zugestellt sind. Pro Erbe erst bei Erfolg `sent_at` → Wiederholungen
  mailen bereits erreichte Erben **nicht doppelt** an. Teil-/Fehlschlag lässt
  `heir_notified_at` null → der tägliche Cron versucht die offenen erneut
  (Kadenz = Backoff). Nach `MAX_NOTIFY_ATTEMPTS` (5) wird der Owner **einmalig**
  per Mail informiert.
- `vault-heartbeat` / `vault-postpone`: setzen den Vorwarn-/Zustell-Zyklus
  zurück, fassen `heir_notified_at` aber **nicht** mehr an.

## Phase 7 — Maximum-Modus (2-B) — §0.4 (a)

**Umgesetzt:**
- Der **stille Fallback** `maximum → none` in `syncPayloads` ist entfernt.
  Stattdessen eine **bewusste** `vaultPolicy`: der automatische Tresor kennt nur
  den **Hash** des Erben-PIN (nicht den Klartext) und kann `maximum` daher nie
  liefern → für den automatischen Versand gilt explizit die passwortlose
  Variante (Vertragsliste + Hinweise). Der Maximum-Modus **bleibt** für den
  **manuellen** Export erhalten.
- `heir_password_policy_screen`: dauerhaft sichtbarer Info-Hinweis am
  Maximum-Modus, dass er nur den manuellen Export betrifft.

## Phase 8 — Cloud-Sync ist kein Backup (1-D) — (b)

**Umgesetzt:**
- Wortlaute im Cloud-Sync-Screen entschärft: nicht mehr „Backup", sondern
  „verschlüsselte Cloud-Kopie".
- Neuer, deutlicher **Nicht-Backup-Hinweis** (nur **ohne** Konto sichtbar): die
  Kopie ist nach Geräteverlust nicht wiederherstellbar (gerätegebundener
  Schlüssel); für echte Wiederherstellung ein Konto anlegen (der `AccountScreen`
  steht bereits oben im selben Screen). Mit Konto läuft der Push über das
  wiederherstellbare `account_vaults`.

## Phase 9 — Kleinbefunde

- **1-A:** SharedPreferences→secure-storage-Migrationspfad in `crypto_service`
  **ersatzlos entfernt** (keine Bestandsnutzer).
- **1-B:** Erben-PIN nicht mehr als ungesalzenes SHA-256, sondern gesalzen mit
  **PBKDF2-HMAC-SHA256** (100k Iter.) über die zentrale `CryptoService.deriveKey`
  — selbstbeschreibendes Format, Konstantzeit-Vergleich (Test: `pin_hash_test`,
  4/4 grün).
- **2-A:** Der workmanager-Heartbeat schreibt jetzt in
  `vault_settings.confirmed_at` (das der Trigger liest) statt in die tote
  Tabelle `heartbeats`.
- **In-Memory-Key (Entscheidung dokumentiert):** Der gecachte AES-Key wird beim
  Verlassen/Sperren der App geleert (`clearCachedKey`, aufgerufen in `app.dart`).
  Bewusst als **Ja** entschieden — der Zusatznutzen ist marginal (der Key liegt
  ohnehin gerätegebunden in secure storage und wird nicht durch den App-Lock-PIN
  geschützt), aber die Maßnahme ist billig und reduziert das Zeitfenster im Heap.

---

## Während der Arbeit aufgefallen — NICHT angefasst (Brief-Regel)

- **`heartbeats`-Tabelle jetzt ungenutzt:** Nach 2-A schreibt/liest niemand mehr
  in/aus `heartbeats`. Die (RLS-gesperrte, leere) Tabelle bleibt bestehen; ein
  späteres `drop table` wäre die saubere Endstufe, ist aber nicht Teil des
  Auftrags.
- **Sensitive Logs (Bestand):** `vault-trigger` protokolliert beim Erben-Versand
  weiterhin `heir_email` in Fehlermeldungen ins `vault_log` (vorbestehend, nicht
  vom Audit erfasst). Meine **neuen** Logs enthalten das nicht.
- **komfort-Modus:** sendet Login-Passwörter im Klartext per Mail (bewusstes
  Vertrauensmodell laut Enum-Doku) — unverändert, nicht im Audit-Scope.

---

## Definition of Done (gesamt, Brief) — Status

- [x] Beide Berichte liegen vor (Stufe 1 + Stufe 2).
- [x] Die vier Testfälle aus Phase 1 sind reproduzierbar grün (TC1–TC4, +TC5/6).
- [x] Kein Codepfad macht Nutzerdaten für Inhaber des anon-Keys erreichbar.
- [x] Kein Zustand garantiert eine ungewollte Auslösung.
- [x] Der Nutzer kann seine Serverdaten löschen.
- [x] Store-Aussagen sind durch den Code gedeckt: „verschlüsselt übertragen und
      gespeichert", **kein** E2EE-Claim; „Backup" nur noch dort, wo eine
      Wiederherstellung existiert (Account).
- [~] E2E gegen `supabase start` + Gerätetest: offen (Docker/Gerät fehlen hier).

---

## Was du noch tun / gegenprüfen solltest

1. **Deploy Stufe 1 + 2:** Migrationen `…120000/130000/140000` einspielen,
   `config.toml` + alle Functions (inkl. neuer `vault-postpone`) deployen,
   anonyme Anmeldung im Dashboard aktiv lassen, Resend-Secrets prüfen.
2. **E2E** auf einer Docker-Maschine: `supabase start` +
   `bash supabase/tests/verify_vault_rls.sh`.
3. **On-Device-Smoke-Test:** Tresor aktivieren (Erst-Sync) → Vertrag ändern
   (Auto-Sync) → „Ich bin noch da" → Deaktivieren (löscht). Maximum-Modus-Hinweis
   und Nicht-Backup-Hinweis sichtbar prüfen.
4. **iOS-Datei-Flag** `NSURLIsExcludedFromBackupKey` (Stufe-1-Follow-up) auf
   einer Maschine mit Xcode nachziehen.

## PRs

- Stufe 1: `fix/launch-stufe1 → release/signing-setup` (Draft-PR #2).
- Stufe 2: `fix/launch-stufe2 → fix/launch-stufe1` (gestapelt) — dieser Bericht.

Beide sind erst nach dem Deploy + On-Device-Test „fertig" im Produktsinn.
