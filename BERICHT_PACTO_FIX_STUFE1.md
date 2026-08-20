# BERICHT — Pacto Launch Fix, Stufe 1 (Schaden)

> **Auftrag:** `BRIEF_PACTO_FIX.md`, Stufe 1.
> **Branch:** `fix/launch-stufe1` (aus HEAD `be827f9`).
> **Commits:** Phase 1 `2d8d396` · Phase 2 `5d1e428` · Phase 3 `e6c2351` · Phase 4 `24b1626`.
> **Ergebnis:** Alle vier Phasen umgesetzt. Verifikation, soweit in dieser
> Umgebung moeglich, gruen. Danach **Stopp** vor Stufe 2 (Brief-Vorgabe).

---

## Ausgangskorrektur gegenueber dem Brief

Zwei Dinge, die der Brief nicht wissen konnte, wurden vor der ersten Codezeile
geklaert (siehe `## §0 Antworten` im Brief):

1. **Der referenzierte Audit-Bericht `BERICHT_PACTO_LAUNCH_AUDIT.md` liegt nicht
   im Repo.** Die Befunde wurden direkt am aktuellen Code (HEAD `be827f9`)
   nachgeprueft. Die `file:line`-Angaben des Briefs stammen aus einem aelteren
   Stand (`1ace87d`) und waren teils verschoben — es gelten die aktuellen.
2. **Seit dem Audit kam das Account-Recovery-Feature hinzu** (E-Mail/Passwort,
   `account_vaults` mit `auth.uid()`-RLS). Es setzt „Option A" bereits fuer den
   Account-Pfad um, liess die vier anfaelligen Anon-Tabellen aber unangetastet.
   Die gewaehlte Loesung (anonyme Sessions + RLS) komponiert damit: die anonyme
   Identitaet ist die Basis, der Account die optionale Upgrade-Schicht.

### §0-Entscheidungen (wie umgesetzt)

| Frage | Entscheidung | Umsetzung |
|---|---|---|
| §0.1 Identitaetsmodell | **Option A** — anonyme Sessions + RLS (Nutzer) | Migration `20260820120000`, anonyme Anmeldung in `main.dart` |
| §0.2 Verwaiste Zeilen | (a) Vorwarnung + Widerruf als Netz | Phase 3 (`vault-postpone`, zwei Warnungen) |
| §0.3 „Deaktivieren" | **Vollstaendig loeschen** (Nutzer) | `VaultService.deleteAllServerData`, Phase 2 |
| §0.4 Maximum-Modus | Stufe 2 / Phase 7 (nicht vorgegriffen) | — |
| §0.5 Anon-Key | Keine Rotation noetig (bestaetigt) | nach RLS gewaehrt der Key allein keinen Datenzugriff |

---

## Umgebungs-Rahmen der Verifikation (wichtig)

Diese Session laeuft auf einer headless-Linux-Maschine **ohne Docker-Zugriff**
(kein sudo, Nutzer nicht in der `docker`-Gruppe). Daher:

- **`supabase start` war nicht ausfuehrbar** — der vom Brief geforderte E2E-Lauf
  gegen eine lokale Supabase-Instanz konnte hier nicht gefahren werden.
- **Ersatz-Nachweis der RLS-Logik:** Ein eigenstaendiges PostgreSQL 16 (ohne
  Docker/sudo bereitgestellt) fuehrt die **echten** Migrationen aus und prueft
  die Policies real. Ergebnis unten. Das deckt das Kern-Sicherheitsversprechen
  von Phase 1 vollstaendig ab.
- **Dart** wurde mit `flutter analyze` + `flutter test` verifiziert.
- **Edge Functions** mit `deno check` (Typpruefung).
- **Was hier NICHT verifizierbar war:** der volle E2E-Fluss gegen `supabase
  start` (echtes gotrue/anon-Login + Edge-Function-Gateway), die App auf einem
  Geraet, und der iOS-Native-Teil. Diese Punkte sind unten als „offen" markiert
  und mit lauffaehigen Skripten hinterlegt.

### Verifikationsausgabe (reproduzierbar)

**RLS/Loeschpfad/Token — `supabase/tests/verify_vault_rls_pg.sql` gegen echtes Postgres:**

```
OK  positiv  — A sieht 1 eigene Zeile
OK  TC1      — B sieht 0 Zeilen
OK  TC2      — anon: permission denied (kein Tabellenrecht)
OK  TC3 (1/2) — B aendert 0 Zeilen
OK  TC3 (2/2) — A heir_email unveraendert (a-heir@example.com)
OK  TC4      — B aendert 0 vault_settings
OK  TC5 (1/2) — B loescht 0 Fremdzeilen
OK  TC5 (2/2) — A loescht die eigene Zeile
OK  TC6      — authenticated: kein Zugriff auf vault_reset_tokens
Alle Assertions gruen — Phase 1 RLS + Phase 2 Loeschpfad + Phase 3 Token bestanden.
(psql exit 0)
```

Das sind exakt die vier vom Brief geforderten Phase-1-Testfaelle (TC1–TC4) plus
der Phase-2-Loeschpfad (TC5) und die Phase-3-Token-Isolierung (TC6).

**Dart:** `flutter analyze lib/` → 2 Issues (beide die vorbestehende
`anonKey`-Deprecation, keine Fehler/Warnungen). `flutter test` → **16/16 gruen**.
**Edge Functions:** `deno check` aller fuenf Functions → gruen.

> Reproduktion der Dart-Tests auf dieser Maschine: `libsqlite3.so` fehlt
> systemweit (bekannte NUC-Falle). Mit einem Symlink
> `libsqlite3.so -> libsqlite3.so.0` im `LD_LIBRARY_PATH` laufen alle Tests
> gruen. Auf einer Dev-Maschine mit installiertem libsqlite3/sqlcipher entfaellt
> das.

---

## Phase 1 — Zugriffskontrolle (Blocker B-1)

**Problem:** `sync_data`, `heartbeats`, `vault_settings`, `vault_payloads` waren
per `using (true)` fuer `anon` welt-les- und -schreibbar; der anon-Key liegt im
App-Binary. `vault-heartbeat`/`vault-sync` prueften nur die Existenz einer
`deviceId` — keine Auth.

**Umgesetzt:**
- **Neue Migration `20260820120000_vault_rls_userid.sql`** (ersetzt die alten
  Policies, ergaenzt sie nicht): jede der vier Tabellen bekommt
  `user_id uuid default auth.uid()` und Policies
  `using ((select auth.uid()) = user_id)` fuer select/insert/update/**delete**;
  der `anon`-Rolle wird jeder Zugriff entzogen (`revoke`).
- **Edge Functions** `vault-heartbeat` und `vault-sync` verlangen jetzt eine
  gueltige Session (`_shared/auth.ts` → `getUser`, bloßer anon-Key = 401) und
  schreiben mit dem **Caller-Token**; damit greift RLS, kein Service-Role mehr.
- **`config.toml`:** `verify_jwt` fuer `vault-heartbeat`, `vault-sync` und
  `vault-trigger` **explizit** deklariert (Audit-Punkt 4). `vault-postpone`
  bewusst `verify_jwt = false` (oeffentlicher Link, Token = Nachweis).
- **Client (Option A):** anonyme Supabase-Session beim Start (`main.dart`),
  Session verschluesselt in `flutter_secure_storage` (`SecureLocalStorage`).
  `vault_service` nutzt `functions.invoke` (Session-JWT automatisch);
  `cloud_sync_service.pushAll` unterscheidet **anonym vs. echter Account**
  (`session.user.isAnonymous`) — vorher haette die immer vorhandene anonyme
  Session faelschlich den Account-Pfad ausgeloest. `sync_data`/`heartbeats`
  laufen ueber den authentifizierten Client.
- **Falsche Migrationskommentare korrigiert** (device_id-als-Token,
  „Service-Key-Envelope").

**Done when (Brief):** Die vier Testfaelle sind reproduzierbar gruen — siehe
Ausgabe oben (TC1–TC4).

**Offen (Docker/Geraet):** E2E gegen `supabase start` als
`supabase/tests/verify_vault_rls.sh` hinterlegt (legt zwei echte anonyme
Sessions an, testet ueber PostgREST). Auf einer Docker-Maschine ausfuehren:
`bash supabase/tests/verify_vault_rls.sh`.

---

## Phase 2 — Deaktivierung und Loeschung (Blocker B-2)

**Problem:** Der Tresor-Schalter wurde nur lokal gespeichert; der Server lief
weiter → Abschalten garantierte die Ausloesung. `enabled` war hartkodiert `true`,
Heartbeats ohne Statuspruefung.

**Umgesetzt:**
- **`VaultService.deleteAllServerData()`** loescht synchron `vault_payloads`,
  `vault_settings`, `sync_data`, `heartbeats` dieses Geraets (RLS-scoped, wirft
  bei Fehler). Ist zugleich der DSGVO-Art.-17-Loeschpfad (§0.3).
- **`vault_screen`:** Deaktivieren fragt nach und loescht dann **synchron mit
  Erfolgspruefung** — schlaegt es fehl, bleibt der Schalter AN + klare
  Fehlermeldung (kein stilles Scheitern). Zusaetzlich ein sichtbarer **„Alle
  Serverdaten loeschen"**-Button, unabhaengig vom Schalter.
- **Heartbeat-Statuspruefung:** `heartbeat()` erfasst Erfolg/Fehler; ein
  dauerhaft scheiternder Heartbeat wird als **Warn-Banner** in der Tresor-UI
  angezeigt.
- **`enabled`** wird aus dem tatsaechlichen Zustand abgeleitet (nicht
  hartkodiert). Fehlende `owner_email`: Pflicht beim Aktivieren (bestand) +
  sichtbarer Warnzustand, wenn aktiv aber leer.
- l10n (DE/EN) ergaenzt.

**Done when (Brief):** Loeschpfad real belegt — TC5 (A loescht eigene Zeile, B
kann keine Fremdzeile loeschen). Die drei UI-Durchspielungen (Deaktivieren,
Loeschen, fehlgeschlagener Heartbeat) sind **Geraet/Docker-gebunden** und daher
hier nicht durchgespielt; die dahinterliegende Server-Semantik (RLS-Delete) ist
per TC5 nachgewiesen.

---

## Phase 3 — Widerruf nach Deinstallation

**Problem:** Die Vorwarnung enthielt keinen Widerrufs-Link; der einzige Weg
zurueck war „App oeffnen" — nach Deinstallation ausgeschlossen.

**Umgesetzt:**
- **Migration `20260820130000_vault_reset_tokens.sql`:** Reset-Token nur als
  SHA-256-Hash, an genau eine `vault_settings`-Zeile gebunden (FK
  `on delete cascade`), mit Ablauf. RLS an, keine Policy → nur service_role
  (TC6 bestaetigt: `authenticated` hat keinen Zugriff). Token-Entropie ≥256 Bit.
- **Neue Edge Function `vault-postpone`:** oeffentlicher Widerrufs-Link.
  **GET** zeigt nur eine Bestaetigungsseite (keine Aenderung), erst **POST**
  schiebt auf (`confirmed_at = now()`, Vorwarnungen zurueck). Liest/aendert/
  loescht **keine** Nutzer-/Vertrags-/Erbendaten. Idempotent bis Ablauf.
- **Zwei Vorwarnungen statt einer** (`vault-trigger`): bei 80 % und 100 %, jede
  mit Widerrufs-Link in einfacher Sprache (was passiert, was der Klick bewirkt).
  Die Ausloesung feuert **erst ab `warning_count >= 2`** — ohne zwei Vorwarnungen
  geht nichts raus.

**Bewusst akzeptiert (Brief):** Wer Zugriff auf das Postfach des Nutzers hat,
kann die Ausloesung aufschieben. Das ist hinnehmbar, weil `owner_email` ohnehin
der Vertrauensanker des gesamten Mechanismus ist.

**Commit-Security-Review (dieser Phase) adressiert:**
- *unauth-get-prefetch-bypass* / *auth-token-replay:* geloest durch das
  GET-bestaetigen / POST-ausfuehren-Muster — ein Mail-Scanner (GET-Prefetch)
  loest nichts mehr aus.
- *sensitive-to-observability:* meine neuen Vorwarnungs-Logs enthalten keinen
  rohen Fehlertext mehr (koennte die Empfaengeradresse spiegeln).

---

## Phase 4 — Geraetedaten (Befund 1-E)

**Problem:** `AndroidManifest.xml` setzte weder `allowBackup="false"` noch
`dataExtractionRules` → `pacto.sqlite` konnte ins Google-Backup wandern.

**Umgesetzt:**
- **Android:** `android:allowBackup="false"` + `fullBackupContent="false"` +
  `data_extraction_rules.xml` (schliesst alle App-Daten aus Cloud-Backup UND
  Android-12+-Geraeteuebertragung aus).
- **iOS:** DB-Schluessel und Supabase-Session an das Geraet gebunden
  (`KeychainAccessibility.first_unlock_this_device`). Da die DB SQLCipher-
  verschluesselt ist, ist ein evtl. gesichertes DB-File **ohne den
  geraetegebundenen Schluessel wertlos** — der Backup-Vektor ist damit auch auf
  iOS neutralisiert.

**Offen (iOS-Build noetig):** Das explizit im Brief genannte Datei-Flag
`NSURLIsExcludedFromBackupKey` auf `pacto.sqlite` ist **noch nicht** gesetzt. Es
braucht nativen Swift-Code im `AppDelegate` (neuer Implicit-Engine-API-Stil),
den ich hier **nicht compile-verifizieren** kann (kein macOS/Xcode); ein
Compile-Fehler dort wuerde den gesamten iOS-Build brechen, daher bewusst **nicht
blind** hinzugefuegt. Die o. g. Geraetebindung des Schluessels deckt das
Sicherheitsziel bereits ab; das Datei-Flag ist als kleiner Follow-up auf einer
Dev-Maschine mit iOS-Toolchain nachzuziehen.

---

## Waehrend der Arbeit aufgefallen — NICHT angefasst (Brief-Regel)

Diese Punkte gehoeren zu Stufe 2 bzw. lagen ausserhalb des Auftrags und wurden
bewusst nur vermerkt:

- **Befund 2-D (Phase 6, Stufe 2):** `vault-heartbeat` setzt `heir_notified_at`
  bedingungslos auf `null` zurueck — auch nachdem Mails raus sind. Unangetastet.
  (Die **neue** `vault-postpone` macht das bewusst **nicht** — sie setzt nur
  `confirmed_at`/Vorwarnungen zurueck.)
- **Befund 2-A (Phase 9, Stufe 2):** Der 30-Tage-`workmanager`-Heartbeat
  schreibt in `heartbeats`, eine Tabelle, die `vault-trigger` nie liest. Der
  Schreibpfad ist jetzt zwar authentifiziert (RLS), die Tabelle bleibt aber
  „read-by-nobody". Fate der Tabelle: Stufe 2.
- **Sensitive Logs (Bestand):** `vault-trigger` protokolliert beim Erben-Versand
  `heir_email` in der Fehlermeldung ins `vault_log`. Vorbestehend, nicht vom
  Audit erfasst → nicht angefasst, hier vermerkt.
- **Hintergrund-Isolate:** `CloudSyncService.sendHeartbeat()` initialisiert
  Supabase im workmanager-Isolate neu (Secure-Storage-Session). Statisch
  plausibel und typgeprueft, aber **nicht geraeteverifiziert** (kein Geraet in
  dieser Session).

---

## Definition of Done (Stufe 1) — Status

- [x] Es existiert kein Codepfad mehr, der Nutzerdaten fuer Inhaber des reinen
      anon-Keys erreichbar macht. **(TC1–TC4 gruen.)**
- [x] Es existiert kein Zustand mehr, in dem eine Nutzeraktion eine ungewollte
      Ausloesung garantiert. **(Deaktivieren = synchrones Loeschen mit
      Erfolgspruefung; Widerrufs-Link + zwei Vorwarnungen.)**
- [x] Der Nutzer kann seine Serverdaten loeschen. **(TC5; „Alle Serverdaten
      loeschen"-Button.)**
- [x] Daten verlassen das Geraet nicht ueber Backups. **(Android allowBackup;
      iOS geraetegebundener Schluessel.)** *iOS-Datei-Flag offen (s. o.).*
- [~] E2E gegen `supabase start`: als Skript hinterlegt, **auf Docker-Maschine
      auszufuehren** (hier nicht moeglich).

---

## Was du (Nutzer) noch tun / gegenpruefen solltest

1. **`supabase start` + `bash supabase/tests/verify_vault_rls.sh`** auf einer
   Docker-Maschine — E2E-Bestaetigung mit echten gotrue-Sessions.
2. **Deploy:** Migrationen `20260820120000` + `20260820130000` einspielen,
   `config.toml` + die Functions deployen. Sicherstellen, dass **anonyme
   Anmeldung** im Supabase-Dashboard aktiv ist (config.toml hat sie schon).
3. **iOS-Datei-Flag** `NSURLIsExcludedFromBackupKey` auf einer Dev-Maschine mit
   Xcode nachziehen (kleiner Native-Hook).
4. **On-Device-Smoke-Test** des Tresors: Aktivieren → Sync → „Ich bin noch da"
   → Deaktivieren (loescht) → „Alle Serverdaten loeschen".

---

## STOPP

Gemaess Brief endet Stufe 1 hier. **Stufe 2 (Ehrlichkeit — Phasen 5–9) wurde
nicht begonnen.** Sie beginnt erst nach deiner Rueckmeldung; am Checkpoint ist
auch §0.4 (Maximum-Modus) zu entscheiden.
