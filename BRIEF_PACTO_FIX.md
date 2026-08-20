# BRIEF — Pacto Launch Fix

> **Grundlage:** `BERICHT_PACTO_LAUNCH_AUDIT.md`, Commit `1ace87d`.
> **Status:** Implementierungsauftrag, zweistufig.
> **Kontext:** Die App ist **nicht** veröffentlicht und **nicht** bei Testern. Es gibt keine
> Fremddaten in der Produktivinstanz. Kein Zeitdruck, keine Meldepflicht — aber auch keine
> Notwendigkeit für Rückwärtskompatibilität. Breaking Changes am Serverschema sind erlaubt
> und in Zweifelsfällen der saubereren Lösung vorzuziehen.

---

## §0 Antworten

> Ermittelt am 2026-08-19. Verifiziert gegen den **aktuellen** Codestand (HEAD `be827f9`,
> Branch `release/signing-setup`) — nicht gegen `1ace87d`. Wichtig: Der als „Grundlage"
> genannte Bericht `BERICHT_PACTO_LAUNCH_AUDIT.md` liegt nicht im Repo; die Befunde wurden
> direkt am Code nachgeprüft. Seit dem Audit kam das **Account-Recovery-Feature** hinzu
> (E-Mail/Passwort-Accounts, `account_vaults` mit `auth.uid()`-RLS, passwort-eskrowter
> AES-Key). Es setzt Option A **nur** für den neuen Account-Pfad um; die vier anfälligen
> Anon-Tabellen sind unverändert. Zeilennummern im Brief sind teils verschoben — im Code
> gelten die aktuellen.

**1. Identitätsmodell → Option A (anonyme Supabase-Sessions + RLS).** *(Nutzerentscheidung
2026-08-19.)* Jede Installation erhält eine anonyme Session (echte `auth.uid`). Alle vier
Tabellen bekommen `user_id uuid references auth.users` mit `using (auth.uid() = user_id)`.
Kein Account-Zwang (deckt sich mit CLAUDE.md). Das bestehende Account-Feature wird zur
optionalen Upgrade-Schicht auf derselben `uid` (anon → E-Mail per `linkIdentity`/
`updateUser`, `uid` bleibt bestehen). Session inkl. Refresh-Token wird in
`flutter_secure_storage` persistiert.

**2. Verwaiste Serverzeilen → (a) Vorwarnung + Widerruf als alleiniges Netz (Phase 3).**
*Annahme, gemäß „Kein Scope Creep".* Ein separater Wiederanknüpfungspfad über `owner_email`
wird **nicht** gebaut — der Account-Pfad (Login auf neuem Gerät → Restore) deckt den
Account-Fall bereits ab. Für Geräte ohne Account bleibt die Vorwarnung mit Widerrufs-Link
das Netz.

**3. „Tresor deaktivieren" → vollständiges Löschen aller Serverdaten dieses Geräts.**
*(Nutzerentscheidung 2026-08-19.)* Deaktivieren löscht synchron `vault_payloads`,
`vault_settings`, `sync_data`, `heartbeats` dieses Geräts. Löst Befund 2-C und liefert den
DSGVO-Art.-17-Löschpfad in einem. Bei Fehler bleibt der Schalter an + klare Fehlermeldung.

**4. Maximum-Modus → Stufe 2 / Phase 7.** Der Brief mandatiert Stopp vor Stufe 2; diese
Entscheidung wird am Stufe-1-Checkpoint mit dem Nutzer getroffen. Vorläufige Tendenz: (a)
umbenennen + in der UI ehrlich einschränken. Wird hier nicht vorgegriffen.

**5. Anon-Key im Repo → keine Rotation nötig.** *Bestätigt.* Der anon-Key ist per Design
öffentlich; nach Phase 1 (RLS) gewährt er allein keinen Datenzugriff mehr.

---

## Schnittprinzip der beiden Stufen

Nicht nach Schweregrad geschnitten, sondern nach Art des Mangels:

- **Stufe 1 — Schaden.** Alles, was Nutzerdaten preisgibt oder aktiv Schaden anrichtet.
  **Muss fertig sein, bevor die App den ersten Tester erreicht.**
- **Stufe 2 — Ehrlichkeit.** Alles, was still nicht funktioniert, obwohl die App es
  verspricht. **Muss fertig sein, bevor die App in Production geht.**

Stufe 2 wird **nicht** begonnen, solange Stufe 1 nicht abgeschlossen und berichtet ist.

---

## §0 Pre-Implementation Interview

**Vor der ersten Codezeile zu beantworten.** Antworten oben in dieser Datei unter
`## §0 Antworten` festhalten. Bei „entscheide du": Annahme explizit benennen und fortfahren.

### 1. Identitätsmodell — die Grundsatzentscheidung

Der Audit zeigt: Die Annahme „`device_id` wirkt als Zugriffstoken" (Migration 1:10-11)
trägt nicht, weil keine Policy sie prüft. Es gibt zwei saubere Auswege, und die Wahl
bestimmt den gesamten Zuschnitt von Phase 1.

**Option A — Anonyme Supabase-Sessions.**
Die App meldet sich anonym an (`config.toml:175` ist bereits aktiv), erhält ein JWT, und
alle Tabellen bekommen eine `user_id uuid references auth.users` mit Policies
`using (auth.uid() = user_id)`. RLS erledigt die Zugriffskontrolle, kein Handrolling.
*Preis:* Session inkl. Refresh-Token muss persistiert werden (`flutter_secure_storage`).
Geht die Session verloren, verliert das Gerät den Zugriff auf seine eigenen Zeilen —
und die alte Zeile läuft serverseitig weiter. Siehe Frage 2.

**Option B — Edge-Function-Gateway mit Geräte-Secret.**
Alle Tabellen werden für `anon` komplett gesperrt (`revoke`, keine Policy). Sämtlicher
Zugriff läuft über Edge Functions, die ein hochentropes `device_secret` prüfen
(erzeugt bei Erstinstallation, Ablage in `flutter_secure_storage`, serverseitig nur als
Hash). Die direkten PostgREST-Aufrufe in `cloud_sync_service.dart:101-115` und
`vault_service.dart:83-84` entfallen.
*Preis:* Selbstgebaute Authentifizierung, mehr Code, mehr Fehlerfläche.

**Empfehlung: Option A.** Idiomatisch für Supabase, RLS statt Anwendungslogik, weniger
selbst zu verantwortender Sicherheitscode. Option B ist der kleinere Diff, aber die
größere Dauerlast.

### 2. Verwaiste Serverzeilen

Unabhängig von Option A/B: Was passiert mit der Serverzeile, wenn ein Gerät seine
Identität verliert (Gerätewechsel, Neuinstallation, Session-Verlust)? Der Audit belegt,
dass die alte Zeile heute aktiv weiterläuft und nach `interval_days + 14` feuert
(Befund 2-C). Zulässige Antworten:

- (a) Vorwarnung mit Widerrufs-Link ist das alleinige Netz (siehe Phase 3), oder
- (b) zusätzlich ein Wiederanknüpfungspfad über `owner_email` (E-Mail-Bestätigung
  verknüpft ein neues Gerät mit der bestehenden Zeile).

(b) ist deutlich freundlicher, aber ein eigenes Feature. Entscheiden, nicht ableiten.

### 3. Bedeutung von „Tresor deaktivieren"

Vorschlag: **Deaktivieren = vollständiges Löschen aller Serverdaten dieses Geräts**
(`vault_payloads`, `vault_settings`, `sync_data`, `heartbeats`). Das löst Befund 2-C und
liefert gleichzeitig den nach Art. 17 DSGVO nötigen Löschpfad. Alternative wäre ein
serverseitiges `enabled = false` mit Datenerhalt — dann braucht es einen **zweiten**,
separaten Löschbefehl. Welche Semantik?

### 4. Umgang mit dem Maximum-Modus

Befund 2-B: Über den automatischen Tresor liefert `maximum` nie ein Passwort, weil der
Server den PIN nicht kennt und nicht kennen soll. Das ist kryptographisch korrekt und
technisch nicht auflösbar. Zwei ehrliche Wege:

- (a) Modus umbenennen und in der UI klar sagen, dass er **nur** für den manuellen
  Export gilt, im Ernstfall aber nur die Vertragsliste übermittelt wird.
- (b) Modus aus dem Tresor-Kontext entfernen.

Nicht zulässig: den stillen Fallback auf `none` beibehalten.

### 5. Anon-Key im Repo

`lib/config/supabase_config.dart:19` ist eingecheckt. Der anon-Key ist per Design
öffentlich — nach Behebung von Phase 1 ist das unproblematisch und **keine Rotation
nötig**. Bestätigen, dass das so gesehen wird, oder Gegenposition begründen.

---

# STUFE 1 — Schaden

*Ziel: Die App gibt keine Daten preis und richtet keinen Schaden an.
Danach ist Verteilung an Tester zulässig.*

## Phase 1 — Zugriffskontrolle (Blocker B-1)

**Ausgangslage:** `vault_payloads`, `vault_settings`, `sync_data` und `heartbeats` sind
über `using (true)` für `anon` vollständig les- und schreibbar (Migration 2:58-60, 2:31-33,
Migration 1:21-26, 1:40-45). Der anon-Key liegt im App-Binary.

**Aufgabe:** Umsetzung des in §0.1 gewählten Modells.

- Neue Migration, die die bestehenden Policies **ersetzt** — nicht ergänzt.
- Jede Tabelle einzeln: `vault_payloads`, `vault_settings`, `sync_data`, `heartbeats`.
- Die drei Vault-Edge-Functions entsprechend anpassen. `vault-heartbeat/index.ts:24-42`
  prüft heute nur die Existenz einer `deviceId` — das ist keine Prüfung.
- `supabase/config.toml`: `verify_jwt` für `vault-heartbeat`, `vault-sync` und
  `vault-trigger` **explizit** deklarieren, nicht dem Plattform-Default überlassen
  (offener Punkt 4 des Audits).
- Die falsche Aussage im Migrationskommentar (Migration 2:9-11, „mit dem Pacto-Service-Key
  entschlüsselbarer Envelope") korrigieren.

**Verifikation, verpflichtend:** Gegen eine **lokale** Supabase-Instanz
(`supabase start`), nicht gegen die Produktivinstanz. Testfälle:
1. Gerät A schreibt, Gerät B liest → muss leer sein.
2. `select=*` mit reinem anon-Key ohne Session → muss 0 Zeilen oder 401 liefern.
3. Fremdes Überschreiben von `vault_payloads.heir_email` → muss scheitern.
4. Fremdes Setzen von `vault_settings.confirmed_at` → muss scheitern.

**Done when:** Die vier Testfälle sind reproduzierbar grün und im Bericht mit Ausgabe belegt.

## Phase 2 — Deaktivierung und Löschung (Blocker B-2)

**Ausgangslage:** `vault_screen.dart:63-78` speichert den Schalter nur lokal.
`vault_service.dart:76` kehrt bei deaktiviertem Tresor sofort zurück, `:91` sendet
`enabled` hartkodiert als `true`. Es existiert kein Codepfad, der eine Deaktivierung an
den Server überträgt — Abschalten garantiert damit die Auslösung.

**Aufgabe:**
- Deaktivieren löst die in §0.3 gewählte Serveroperation aus, **synchron und mit
  Erfolgsprüfung**. Schlägt sie fehl, bleibt der Schalter in der UI an und der Nutzer
  bekommt eine klare Fehlermeldung. Kein stilles Scheitern.
- `vault_service.dart:91`: `enabled` aus dem tatsächlichen Zustand ableiten, nicht hartkodieren.
- `heartbeat()` (`vault_service.dart:79`) bekommt eine Statuscode-Prüfung. Dauerhaft
  fehlschlagende Heartbeats werden dem Nutzer in der Tresor-UI angezeigt.
- Sichtbare Funktion „Alle Serverdaten löschen", unabhängig vom Tresor-Schalter erreichbar.
- Leere `owner_email` darf nicht länger stillschweigend jeden Heartbeat unterdrücken
  (`vault_service.dart:77`) — entweder Pflichtfeld beim Aktivieren oder sichtbarer Warnzustand.

**Done when:** Deaktivieren, Löschen und ein fehlgeschlagener Heartbeat sind je einmal
gegen die lokale Instanz durchgespielt und im Bericht belegt.

## Phase 3 — Widerruf nach Deinstallation

**Ausgangslage:** Die Vorwarnung bei 80 % des Intervalls (`vault-trigger:178-196`) enthält
keinen Widerrufs-Link; der einzige Weg zurück ist „App öffnen" (`:187-188`) — nach einer
Deinstallation ausgeschlossen. Der in `vault-heartbeat/index.ts:2` erwähnte Magic-Link
existiert nicht.

**Aufgabe:**
- Widerrufs-Token: mindestens 128 Bit Entropie, serverseitig nur als Hash, an genau eine
  `vault_settings`-Zeile gebunden, mit Ablaufdatum.
- Neue Edge Function, die per Link `confirmed_at` auf `now()` setzt. Sie darf **nur**
  aufschieben — niemals Daten lesen, ändern oder löschen.
- Link in jede Vorwarnung. Text in einfacher Sprache: was passiert, wenn nichts geschieht,
  und was der Klick bewirkt.
- Mindestens zwei Vorwarnungen vor der Auslösung, nicht eine.

**Bewusst akzeptiert:** Wer Zugriff auf das Postfach des Nutzers hat, kann die Auslösung
aufschieben. Das ist hinnehmbar, weil `owner_email` ohnehin der Vertrauensanker des
gesamten Mechanismus ist. Im Bericht als bewusste Entscheidung vermerken.

## Phase 4 — Gerätedaten (Befund 1-E)

`android/app/src/main/AndroidManifest.xml` setzt weder `allowBackup="false"` noch
`dataExtractionRules`. Damit gilt der Android-Default und `pacto.sqlite` wandert in das
Google-Backup.

- `android:allowBackup="false"` setzen, alternativ `dataExtractionRules` mit Ausschluss
  der DB-Datei.
- iOS: `NSURLIsExcludedFromBackupKey` für die DB-Datei prüfen und setzen
  (offener Punkt 6 des Audits).

Einzeilig, aber es gehört in Stufe 1, weil Daten sonst das Gerät verlassen.

## Berichtspflicht Stufe 1

`BERICHT_PACTO_FIX_STUFE1.md`: je Phase, was geändert wurde, welche Tests grün sind,
welche Entscheidungen aus §0 wie umgesetzt wurden. **Danach Stopp** und Rückmeldung an
den Nutzer, bevor Stufe 2 beginnt.

---

# STUFE 2 — Ehrlichkeit

*Ziel: Was die App verspricht, tut sie auch. Danach ist Production zulässig.*

## Phase 5 — Der Tresor bekommt überhaupt Daten (Befund 2-E)

`syncPayloads` hat genau einen Aufrufer: den Button in `vault_screen.dart:131`. Wer den
Tresor aktiviert, aber nie synchronisiert, löst im Ernstfall `no_payloads` aus — der
Trigger feuert, nichts geht raus, niemand erfährt davon.

- Automatischer Sync bei jeder Änderung an Verträgen oder Erben, sofern der Tresor aktiv ist.
- In der Tresor-UI sichtbar: Zeitpunkt des letzten Syncs und Anzahl der hinterlegten Briefe.
  Bei null Briefen ein deutlicher Warnzustand.

## Phase 6 — Versand darf nicht still scheitern (Befund 2-D)

`vault-trigger/index.ts:166-168` setzt `heir_notified_at` unabhängig vom Zustellerfolg;
`:142` verhindert danach jeden weiteren Versuch.

- `heir_notified_at` **nur** bei `sent == true` setzen.
- Fehlgeschlagene Versuche zählen und mit Backoff wiederholen.
- Nach mehreren Fehlversuchen den Nutzer über `owner_email` informieren.
- `vault-heartbeat/index.ts:36` setzt `heir_notified_at` bedingungslos zurück — auch wenn
  die Mails bereits raus sind. Korrigieren.

## Phase 7 — Maximum-Modus (Befund 2-B)

Umsetzung der in §0.4 gewählten Variante. Der stille Fallback in
`vault_service.dart:139-140` verschwindet in jedem Fall.

## Phase 8 — Cloud-Sync ist kein Backup (Befund 1-D)

`CloudSyncService` kennt nur `pushAll`; es existiert kein Lesepfad. Geht das Gerät
verloren, ist der Blob dauerhaft unlesbar — auch für den Nutzer. Zwei Wege:

- (a) Wiederherstellung bauen. Braucht einen exportierbaren Recovery-Key
  (`crypto_service.dart:77-89` ist bereits vorhanden, aber toter Code) und einen
  Lesepfad. Der Nutzer muss den Schlüssel sichern, sonst nützt es nichts.
- (b) Feature ehrlich benennen. Nicht „Backup", sondern das, was es ist.

**Nicht zulässig:** weiterhin „Backup" nennen, ohne dass eine Wiederherstellung existiert.

## Phase 9 — Kleinbefunde

- **1-A:** `crypto_service.dart:36-42` migriert einen Schlüssel aus `SharedPreferences`.
  Da es keine Bestandsnutzer gibt: Migrationspfad ersatzlos entfernen.
- **1-B:** `share_export_service.dart:14-17` hasht die Erben-PIN als ungesalzenes SHA-256.
  Auf PBKDF2 mit Salt umstellen, konsistent zu `crypto_service.dart:111-123`.
- **2-A:** Der 30-Tage-`workmanager`-Heartbeat (`main.dart:43-49`) schreibt in `heartbeats`,
  eine Tabelle, die `vault-trigger` nie liest. Entweder auf `vault_settings.confirmed_at`
  umstellen oder entfernen. Nicht als wirkungslose Scheinabsicherung belassen.
- **In-Memory:** Der Sync-Key bleibt unbegrenzt im Provider-Singleton
  (`crypto_service.dart:18, 28`) und ist nicht an den App-Lock gebunden. Bewerten,
  ob eine Bindung an `app_lock_service` sinnvoll ist. Entscheidung dokumentieren, auch
  wenn sie „nein" lautet.

## Berichtspflicht Stufe 2

`BERICHT_PACTO_FIX_STUFE2.md`, gleiche Struktur wie Stufe 1.

---

## Arbeitsregeln

- **Ein Branch pro Stufe**, nicht pro Phase. `fix/launch-stufe1`, `fix/launch-stufe2`.
- **Commit-on-green.** Kein Commit mit rotem Testlauf.
- **Die 10 uncommitteten Dateien** im Working Tree (§0.1 des Audits) vor Beginn klären —
  committen oder stashen. Nicht mit vermischtem Stand arbeiten.
- **Kein Scope Creep.** Kein Refactor, keine UI-Überarbeitung, kein neues Feature.
  Was im Audit nicht steht, gehört nicht in diesen Auftrag. Ideen landen in
  `docs/backlog.md`, nicht im Code.
- **Keine Verifikation gegen die Produktivinstanz.** Alles gegen `supabase start`.
- **Nichts stillschweigend beheben, was der Audit nicht gefunden hat.** Fällt bei der
  Arbeit ein weiterer Mangel auf: im Bericht vermerken, nicht anfassen.

## Definition of Done, gesamt

- Beide Berichte liegen vor.
- Die vier Testfälle aus Phase 1 sind reproduzierbar grün.
- Es existiert kein Codepfad mehr, der Nutzerdaten für Inhaber des anon-Keys erreichbar macht.
- Es existiert kein Zustand mehr, in dem eine Nutzeraktion eine ungewollte Auslösung garantiert.
- Der Nutzer kann seine Serverdaten löschen.
- Die Aussagen im Store-Listing sind durch den Code gedeckt: „verschlüsselt übertragen und
  gespeichert", **kein** E2EE-Claim.
