# Account-basierte Recovery (E-Mail/Passwort) — Design

Status: Entwurf, vom Nutzer freigegeben (2026-07-03).

## Ziel

Aktuell hängt jede Installation an einer zufälligen, lokalen `device_id` — verliert man
das Handy, sind sowohl die Daten in Supabase (`sync_data`) als auch der lokale AES-256-
Sync-Key unwiederbringlich weg. Dieses Feature fügt eine **optionale** Account-Ebene
(E-Mail + Passwort) hinzu, mit der Nutzer ihre komplette Vertrags- und Erben-Daten auf
einem neuen Gerät wiederherstellen können.

**Nicht-Ziel:** Account-Pflicht für die App oder für Cloud-Sync/Tresor generell. Die
bestehende anonyme, `device_id`-basierte Nutzung (`sync_data`, `heartbeats`,
`vault_settings`) bleibt exakt wie heute bestehen — ein Konto ist rein additiv für alle,
die eine bewusste Wiederherstellungs-Garantie wollen.

## Architektur-Prinzip: echte Ende-zu-Ende-Verschlüsselung

Der AES-256-Sync-Key verlässt das Gerät nie im Klartext. Für Recovery wird er zusätzlich
mit einem aus dem Account-Passwort abgeleiteten Schlüssel verschlüsselt ("Escrow") und
mitgesichert. Das bedeutet:

- Supabase kann die Daten zu keinem Zeitpunkt entschlüsseln (kein Master-Key auf dem Server).
- **Explizit akzeptierter Trade-off:** Verliert ein Nutzer gleichzeitig sein Passwort UND
  das Gerät mit dem lokalen Key, ist das alte Backup unwiederbringlich verloren. Ein
  Passwort-Reset gewährt neuen Account-Zugriff, aber keinen Zugriff auf das alte,
  verschlüsselte Backup — die App muss das dem Nutzer klar kommunizieren und einen neuen,
  leeren Tresor unter dem neuen Passwort anlegen. Ein separater Recovery-Code (wie bei
  Bitwarden) wurde bewusst nicht gewählt, um die Nutzer-Erfahrung einfach zu halten.

## Datenmodell

Neue, isolierte Supabase-Tabelle (Migration `supabase/migrations/<timestamp>_account_vaults.sql`):

```sql
create table public.account_vaults (
  user_id           uuid primary key references auth.users(id) on delete cascade,
  encrypted_payload text not null,   -- gleicher {v,iv,ct}-Envelope wie sync_data (Contracts+Heirs)
  key_salt          text not null,   -- PBKDF2-Salt zur Ableitung des Escrow-Keys aus dem Passwort
  encrypted_key     text not null,   -- der echte AES-256 Sync-Key, verschluesselt mit dem Escrow-Key
  updated_at        timestamptz not null default now()
);

alter table public.account_vaults enable row level security;

create policy "account_vaults own select" on public.account_vaults
  for select to authenticated using (auth.uid() = user_id);
create policy "account_vaults own insert" on public.account_vaults
  for insert to authenticated with check (auth.uid() = user_id);
create policy "account_vaults own update" on public.account_vaults
  for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
```

`sync_data` und `heartbeats` bleiben unveraendert (anonymer Fallback-Pfad). Keine
Migration von Bestandsdaten noetig — komplett neue, isolierte Tabelle.

## Abhängigkeit

Neu: `supabase_flutter` (Auth-Client mit Session-Management, Token-Refresh,
Passwort-Reset via OTP) statt handgerollter GoTrue-REST-Aufrufe.

## Crypto-Flow (`crypto_service.dart`)

Erweiterung um generische Passwort-Escrow-Funktionen (gleiches PBKDF2-Muster wie das
bestehende `encryptWithPin`):

- `encryptKeyForEscrow(realAesKey, password)` → Salt generieren, Escrow-Key per PBKDF2 aus
  dem Passwort ableiten, echten AES-Key damit verschluesseln → `{salt, encrypted_key}`.
- `decryptEscrowKey(salt, encryptedKey, password)` → Escrow-Key erneut ableiten, echten
  AES-Key zurueckgewinnen.

**Sign-up (Geraet mit den Originaldaten):**
1. `supabase.auth.signUp(email, password)` → Supabase schickt Bestaetigungsmail
   (Standard-GoTrue-Flow, kein Deep-Link im Code — Bestaetigung per Klick im Mail-Client).
2. Nach erfolgreichem Login (erst dann existiert eine `authenticated`-Session): existiert
   noch kein `account_vaults`-Eintrag fuer `auth.uid()` → aktuellen lokalen AES-Key +
   Passwort → Escrow erzeugen, aktuellen Contracts+Heirs-Payload verschluesseln, Zeile
   einfuegen. Automatisch, ohne Extra-Klick.

**Login auf neuem Geraet (Recovery):**
1. Login → `account_vaults`-Zeile per RLS automatisch nur die eigene sichtbar.
2. **Restore ist ein separater, bestaetigter Schritt** (siehe UI-Abschnitt), kein
   automatisches Ueberschreiben beim blossen Einloggen.
3. Bei ausgeloestem Restore: Escrow mit dem Passwort entschluesseln → echten AES-Key
   gewinnen → lokal importieren (ueberschreibt ggf. den frisch generierten Zufalls-Key der
   Neuinstallation) → `encrypted_payload` damit entschluesseln → Contracts+Heirs in die
   lokale Drift-DB einspielen.

**Passwort aendern (eingeloggt):** AES-Key ist lokal bereits bekannt → nach
`auth.updateUser(password: neu)` Escrow mit neuem Passwort neu verpacken (`key_salt` +
`encrypted_key` aktualisieren, Payload bleibt unveraendert).

**Passwort vergessen (OTP-Flow, kein Deep-Link):** `resetPasswordForEmail` + 6-stelliger
Code aus der Mail, `verifyOTP` + neues Passwort setzen. Ist der urspruengliche AES-Key auf
diesem Geraet noch vorhanden, wird er einfach neu escrowed (Passwort-Aenderungs-Pfad).
Ist er nicht mehr vorhanden (Geraet UND Passwort verloren), legt die App unter dem neuen
Passwort einen neuen, leeren Tresor an und kommuniziert das explizit — bewusster
Trade-off, siehe oben.

## Screens & Flows

- **`AccountScreen`** (in Settings, erweitert `supabase_sync_screen.dart`): zeigt je nach
  Login-Status entweder „Registrieren" / „Einloggen" oder E-Mail + „Passwort aendern" +
  „Abmelden".
- **`RegisterScreen`**: E-Mail + Passwort + Bestaetigung → `signUp` → Hinweis „Bestaetige
  deine E-Mail, dann einloggen".
- **`LoginScreen`**: E-Mail + Passwort → `signInWithPassword`. Wiederverwendet aus Settings
  UND aus dem Onboarding-Einstieg.
- **`ForgotPasswordScreen`**: Schritt 1 E-Mail → OTP anfordern; Schritt 2 Code + neues
  Passwort → `verifyOTP` + `updateUser`.

**Login ≠ Restore:**
- Onboarding-Einstieg ("Schon ein Konto? Daten wiederherstellen"): Login direkt gefolgt
  von automatischem Restore — unkritisch, da lokale DB bei Neuinstallation leer ist.
- Settings-Einstieg (bestehendes Geraet mit evtl. vorhandenen Daten): nach Login erscheint
  ein separater Button „Cloud-Backup wiederherstellen" mit Bestaetigungsdialog („Ersetzt
  deine aktuellen lokalen Daten"), bevor irgendwas ueberschrieben wird.

## Integration in bestehenden Sync

`CloudSyncService.pushAll()` verzweigt: ist eine Supabase-Auth-Session aktiv, geht der
Push nach `account_vaults` (authenticated, RLS-geschuetzt) statt nach `sync_data` (anonym,
`device_id`). Der bestehende „Jetzt synchronisieren"-Button in `supabase_sync_screen.dart`
bleibt unveraendert sichtbar — er schreibt nur automatisch ans richtige Ziel.

## Fehlerfaelle

- Falsches Passwort beim Login → Supabase-Fehler klar anzeigen.
- E-Mail schon registriert → verstaendliche Meldung, Link zu Login.
- Restore ohne vorhandene `account_vaults`-Zeile → „Noch kein Backup vorhanden" statt
  Absturz.
- Netzwerkfehler bei jedem Schritt → Snackbar mit Fehlertext, kein stiller Fail.
- Session abgelaufen → `supabase_flutter` refresht automatisch; nur bei komplett
  ungueltiger Session zurueck zum Login.

## Testing

Unit-Tests fuer die neuen, reinen Krypto-Funktionen in `crypto_service.dart` (Escrow
verschluesseln/entschluesseln, falsches Passwort → Fehler). Fuer die Auth-Screens selbst:
manueller QA-Durchlauf auf echtem Geraet gegen das Live-Supabase-Projekt (wie bisher in
`BETA_TESTING.md` beschrieben) — Signup, Bestaetigung, Login auf Zweit-„Geraet" (App-Daten
loeschen + neu installieren), Restore, Passwort aendern, Passwort vergessen.
