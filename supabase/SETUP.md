# Supabase-Einrichtung — Pacto

Schritt-für-Schritt-Anleitung für das Supabase-Backend (KI-Scan + Cloud-Sync).
Voraussetzung: Supabase-Account vorhanden. Die Supabase CLI ist per npm
installiert (`~/.npm-global/bin/supabase`).

> **Live-Status (verifiziert 2026-08-10):** Das produktive Backend ist bereits
> eingerichtet und läuft. Project-Ref `dxsjgajavgvjlksjawer`
> (`https://dxsjgajavgvjlksjawer.supabase.co`), fest verdrahtet in
> `lib/config/supabase_config.dart`. Deployt & geprüft:
> - Edge Functions `extract-contract`, `vault-heartbeat`, `vault-sync`,
>   `vault-trigger` (alle erreichbar, verlangen Auth).
> - Tabellen `sync_data`, `heartbeats`, `scan_counts`, `account_vaults`
>   (per REST + RLS erreichbar).
> - Anonyme Anmeldung aktiv, `ANTHROPIC_API_KEY`-Secret gesetzt. Scan-Happy-Path
>   getestet: anonyme Session → `extract-contract` → `400` bei leerem Body, d. h.
>   Auth-Prüfung, Rate-Limit-Tabelle und Secret greifen.
>
> Die Schritte 1–9 unten sind die Referenz, um ein **frisches** Projekt neu
> aufzusetzen — für den Normalbetrieb ist nichts davon nötig.

Was hier eingerichtet wird:

| Komponente | Zweck |
|---|---|
| Tabelle `sync_data` | verschlüsseltes Voll-Backup pro Gerät |
| Tabelle `heartbeats` | Lebenszeichen für den Inaktivitäts-Tresor |
| Tabelle `scan_counts` | Rate-Limit der KI-Extraktion (100 Scans/User/Monat) |
| Edge Function `extract-contract` | ruft die Anthropic-API auf (API-Key bleibt serverseitig) |
| Anonyme Auth | jede App-Session bekommt eine User-ID fürs Rate-Limit |

---

## 1. Anmelden (interaktiv)

Öffnet den Browser zur Bestätigung:

```bash
supabase login
```

In Claude Code: `! supabase login` in die Eingabezeile tippen.

## 2. Organisation ermitteln

```bash
supabase orgs list
```

Die `ID` aus der Ausgabe für den nächsten Schritt notieren.

## 3. Projekt anlegen

```bash
supabase projects create Pacto \
  --org-id   <ORG-ID> \
  --region   eu-central-1 \
  --db-password "<STARKES-DB-PASSWORT>"
```

- `eu-central-1` = Frankfurt (DSGVO-freundlich).
- DB-Passwort sicher notieren — wird in Schritt 4 erneut gebraucht.
- Die Ausgabe enthält die **Project-Ref** (z. B. `abcdefgh1234...`).

## 4. Lokales Repo mit dem Projekt verknüpfen

```bash
supabase link --project-ref <PROJECT-REF>
```

## 5. Datenbank-Schema einspielen

Wendet `supabase/migrations/20260521120000_init_pacto_schema.sql` auf die
Cloud-Datenbank an (legt alle drei Tabellen inkl. RLS an):

```bash
supabase db push
```

## 6. Edge Function deployen

```bash
supabase functions deploy extract-contract
```

(Kein Docker nötig — Deploy läuft über die Supabase-API.)

## 7. Anthropic-API-Key als Secret hinterlegen

```bash
supabase secrets set ANTHROPIC_API_KEY=sk-ant-...
```

`SUPABASE_URL` und `SUPABASE_SERVICE_ROLE_KEY` werden von Supabase automatisch
in die Edge Function injiziert — nicht selbst setzen.

## 8. Anonyme Anmeldung aktivieren

In `supabase/config.toml` ist `enable_anonymous_sign_ins = true` bereits gesetzt.
Auf das Cloud-Projekt anwenden — eine der beiden Varianten:

```bash
supabase config push          # überträgt die Auth-Konfiguration
```

oder im Dashboard: **Authentication → Sign In / Providers → Anonymous → Enable**.

## 9. Zugangsdaten in die App eintragen

URL und anon-Key abrufen:

```bash
supabase projects api-keys --project-ref <PROJECT-REF>
```

- **Project-URL:** `https://<PROJECT-REF>.supabase.co`
- **anon / publishable key:** aus der Ausgabe von `api-keys`

Im Code hinterlegen — die veröffentlichte App liest URL und anon-Key fest aus
`lib/config/supabase_config.dart` (`SupabaseConfig.projectUrl` /
`SupabaseConfig.anonKey`), damit KI-Scan und Cloud-Sync ohne jede Einrichtung
durch den Nutzer sofort funktionieren. Nur beim Wechsel auf ein neues Projekt
müssen diese beiden Konstanten aktualisiert werden.

---

## Verifizieren

```bash
# Tabellen vorhanden?
supabase db push --dry-run            # sollte "no changes" melden

# Function-Logs live mitlesen (während eines Scans aus der App)
supabase functions logs extract-contract
```

Im Dashboard unter **Table Editor** sollten `sync_data`, `heartbeats` und
`scan_counts` sichtbar sein. Nach einem Sync aus der App erscheint eine Zeile
in `sync_data` mit verschlüsseltem `encrypted_payload`.

---

## Inaktivitäts-Tresor deployen (v1.1)

Zusätzlich zu den bisherigen Komponenten ergänzt die App einen automatischen
Erbenversand, falls der Nutzer länger kein Lebenszeichen mehr abgegeben hat.

Die App rendert pro Erbe Brief **und** PDF bereits lokal vor und legt beides
verschlüsselt im Tresor ab (`vault_payloads.body` + `vault_payloads.pdf_b64`).
Die Erbenmail trägt das PDF (`pacto.pdf`) als Anhang — der Server generiert
nichts selbst, da das Gerät zum Versandzeitpunkt offline sein kann.

1. **Migration einspielen** — fügt `vault_settings`, `vault_payloads`,
   `vault_log` hinzu und versucht einen `pg_cron`-Job zu registrieren:
   ```bash
   supabase db push
   ```

2. **Project-URL und Service-Key als Postgres-GUC setzen** (einmalig, damit
   der Cron-Job die Trigger-Function erreichen kann):
   ```sql
   alter database postgres
     set "app.settings.project_url" = 'https://<PROJECT-REF>.supabase.co';
   alter database postgres
     set "app.settings.service_role_key" = '<SERVICE-ROLE-KEY>';
   ```
   Danach den `do $$ ... $$;`-Block am Ende der Migration erneut ausführen,
   damit der Cron-Job registriert wird.

3. **Edge Functions deployen**:
   ```bash
   supabase functions deploy vault-heartbeat
   supabase functions deploy vault-sync
   supabase functions deploy vault-trigger
   ```

4. **Resend-API-Key als Secret hinterlegen** (für Vorwarnungen und
   Erbenmails). Ohne diesen Key schreibt die Trigger-Function die geplanten
   Mails nur ins `vault_log`:
   ```bash
   supabase secrets set RESEND_API_KEY=re_...
   supabase secrets set VAULT_FROM_EMAIL=no-reply@<deine-domain>
   ```
   Die Absender-Domain in Resend muss verifiziert sein.

5. **Cron-Job prüfen**:
   ```sql
   select jobname, schedule, command from cron.job;
   ```
   `vault-daily` sollte sichtbar sein (`0 9 * * *`).

6. **Trigger einmal manuell auslösen** (sanity check, ohne dass wirklich
   Mails versendet werden – setze `RESEND_API_KEY` vorher leer):
   ```bash
   curl -X POST https://<PROJECT-REF>.functions.supabase.co/vault-trigger \
        -H "Authorization: Bearer <SERVICE-ROLE-KEY>"
   ```
   Antwort: `{"ok":true,"processed":N,"summary":{...}}`.

---

## KI-Scan-Authentifizierung (implementiert)

Cloud-Sync und Tresor-Heartbeat sprechen `sync_data`/`heartbeats` direkt mit dem
anon-Key an (die RLS-Policies erlauben das). Der **KI-Scan** braucht dagegen eine
echte anonyme User-Session, damit die Edge Function aus dem JWT eine stabile
`user_id` für das Scan-Rate-Limit ableiten kann.

Das ist in `lib/features/scan/extraction_service.dart` umgesetzt und end-to-end
verifiziert:

- `_ensureSessionToken()` legt beim ersten Scan per `/auth/v1/signup` eine
  anonyme Session an, persistiert Access- und Refresh-Token in
  `SharedPreferences` und erneuert sie bei Ablauf über den Refresh-Token — die
  `user_id` bleibt dadurch über Monate stabil.
- Die Function-Aufrufe senden `Authorization: Bearer <session-token>` (nicht den
  anon-Key). Bei `401` wird die Session einmal verworfen und neu angemeldet.

Damit ist die frühere Lücke geschlossen — es ist keine weitere Code-Änderung
nötig.

## Passwort-Reset-E-Mail-Template fuer OTP-Flow

Damit "Passwort vergessen" ohne Deep-Link funktioniert (App zeigt ein Eingabefeld fuer
einen 6-stelligen Code statt einen Klick-Link zu erwarten), muss das Supabase-
E-Mail-Template angepasst werden:

Supabase Dashboard → Authentication → Email Templates → **Reset Password** →
sicherstellen, dass der Text `{{ .Token }}` enthaelt (z.B. "Dein Code: {{ .Token }}"),
zusaetzlich zum Standard-Link. Ohne diese Anpassung sieht der Nutzer keinen Code in der
Mail und der OTP-Flow in `ForgotPasswordScreen` schlaegt fehl.
