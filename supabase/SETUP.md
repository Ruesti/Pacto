# Supabase-Einrichtung — Pacto

Schritt-für-Schritt-Anleitung für das Supabase-Backend (KI-Scan + Cloud-Sync).
Voraussetzung: Supabase-Account vorhanden. Die Supabase CLI ist bereits unter
`~/.local/bin/supabase` installiert (v2.101.0).

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

In der App eintragen unter:
- **Einstellungen → KI-Scan** (`scan_config_screen`) — für die Extraktion
- **Einstellungen → Cloud-Sync** (`supabase_sync_screen`) — für Backup & Tresor

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

## ⚠️ Bekannte Lücke: KI-Scan braucht noch eine Code-Änderung

Cloud-Sync und der Tresor-Heartbeat funktionieren nach dieser Einrichtung
sofort (die App spricht `sync_data`/`heartbeats` direkt mit dem anon-Key an,
die RLS-Policies erlauben das).

Der **KI-Scan** funktioniert noch nicht end-to-end: `extraction_service.dart`
sendet aktuell den anon-Key als Bearer-Token. Die Edge Function erwartet aber
eine echte **anonyme User-Session** (für die User-ID des Rate-Limits) und
antwortet sonst mit `401`. Nötig ist eine kleine Ergänzung: beim App-Start
anonym anmelden (`signInAnonymously`) und das Session-Token statt des
anon-Keys an die Function schicken.
