# BETA_TESTING.md — Pacto

Praxis-Anleitung zum **Bauen & Aufspielen**, zur **Beta-Verteilung mit Vollzugang**
und zum **Testen des Erben-Mailversands**.

Projekt-Referenzen:
- Supabase-Projekt: `dxsjgajavgvjlksjawer` → Basis-URL `https://dxsjgajavgvjlksjawer.supabase.co`
- S22-Test-Gerät (USB-Serial): `R5CTA24VVKT`

---

## 1. Build & Aufspielen aufs Testgerät

```bash
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools
```

### APK-Varianten

| Variante | Befehl | Größe | Läuft auf |
|---|---|---|---|
| **arm64-only** (Standard zum Testen) | `flutter build apk --release --target-platform android-arm64` | ~48 MB | Alle modernen Handys (seit ~2017, inkl. S22) |
| **universell** (für beliebige Geräte) | `flutter build apk --release` | ~89 MB | Alle ABIs: arm64-v8a, armeabi-v7a, x86_64 (auch alte 32-bit-Geräte, Emulatoren) |

Ausgabe jeweils: `build/app/outputs/flutter-apk/app-release.apk`

### Installieren (USB — bevorzugt)

```bash
adb devices                                  # R5CTA24VVKT muss als "device" auftauchen
flutter install -d R5CTA24VVKT
# oder direkt:
adb -s R5CTA24VVKT install -r build/app/outputs/flutter-apk/app-release.apk
```

**Stolperfalle S22:** Fliegt bei gesperrtem Bildschirm aus adb. Während Build/Install
wach halten (`adb shell svc power stayon true` hilft). Bei Drop: Kabel neu, entsperren,
`adb devices` prüfen.

### Installieren (WiFi — Fallback ohne Kabel, Android 13+)

```bash
# 1. Am Handy: Entwickleroptionen → Drahtloses Debugging → AN
#    → "Gerät über Kopplungscode koppeln" zeigt IP:PORT + 6-stelligen Code
adb pair <ip>:<PAIR-port> <code>
# 2. Hauptbildschirm "Drahtloses Debugging" zeigt einen ANDEREN Port:
adb connect <ip>:<CONNECT-port>
adb -s <ip>:<CONNECT-port> install -r build/app/outputs/flutter-apk/app-release.apk
```
Hinweis: Großes APK streamt über WiFi instabil — bei `device offline` einfach erneut
versuchen. Die schlanke arm64-APK ist deutlich zuverlässiger.

---

## 2. Beta-Tester mit Vollzugang

Premium läuft über **RevenueCat** + Store-Kauf. Das Limit ist `freeTierLimit = 5`
(`lib/features/premium/premium_service.dart`).

> **Wichtig:** Echte Play-Käufe (und damit der RevenueCat-Unlock) funktionieren **nur,
> wenn die App über Play installiert wurde** (Internal-Testing-Track) — **nicht** bei
> einer sideloaded APK. Wer den echten Kauf-/Unlock-Flow testen will, muss die App über
> Play Internal Testing beziehen.

### Weg A — RevenueCat + Play (echter Flow)

1. **Play Console**: App anlegen → In-App-Produkt (managed / one-time) mit ID
   **`pacto_pro`** (~2,99 €) anlegen → App in den **Internal-Testing**-Track hochladen →
   Tester per E-Mail einladen.
2. **License Tester** in der Play Console hinzufügen → Käufe beim Testen sind kostenlos.
3. **RevenueCat** (app.revenuecat.com): Projekt + Play-App (mit Play-Service-Account-JSON)
   → **Entitlement `pro`** → Produkt `pacto_pro` einem **Offering** zuordnen.
4. **Google Public API-Key** (`goog_…`) aus RevenueCat in `lib/config/revenuecat_config.dart`
   → `googleApiKey` eintragen (aktuell Platzhalter). iOS analog mit `appl_…`.

Konfig-Stelle:
```dart
// lib/config/revenuecat_config.dart
static const entitlementId = 'pro';
static const productId     = 'pacto_pro';
static const googleApiKey  = 'goog_…';   // ← echter Key
static const appleApiKey   = 'appl_…';   // ← echter Key
```

### Weg B — Schnelle Tester-Freischaltung (ohne Store)

Noch **nicht** implementiert. Bei Bedarf: lokales Premium-Flag (analog zum bestehenden
Desktop-Fallback `setDesktopPurchased` in `premium_service.dart`) auch auf Mobile
zulassen, ausgelöst über eine versteckte Geste in den Einstellungen. Vorteil: Vollzugang
per sideloaded APK, ohne Play/RevenueCat.

---

## 3. Erben-Mailversand testen

### Architektur

| Edge Function | Rolle |
|---|---|
| `vault-sync` | App lädt fertig gerenderte Erben-Briefe (`body` + optional `pdf_b64`) je Erbe hoch. |
| `vault-heartbeat` | App meldet Lebenszeichen → setzt `confirmed_at`, inkl. `owner_email`. |
| `vault-trigger` | Täglich per pg_cron: bei **80 %** des Intervalls Vorwarnung an Owner, bei **Intervall + 14 Tagen** Mail an alle Erben (PDF-Anhang). Versand über **Resend**. |

### Voraussetzungen

1. **Resend-Secrets** in Supabase setzen (ohne Key → Dry-Run: es wird nichts versendet,
   nur ins `vault_log` geschrieben):
   ```bash
   supabase secrets set RESEND_API_KEY=<dein_key> VAULT_FROM_EMAIL=<verifizierter_absender>
   ```
2. In der App **Tresor aktivieren** + mindestens **einen Erben mit E-Mail** anlegen
   → die App lädt die Payloads via `vault-sync` hoch.

### Sofort-Test (Force-Modus)

`vault-trigger` akzeptiert einen Test-Body `{force:true, deviceId?}`: sendet **sofort**
an die Erben, unabhängig vom Intervall, und setzt `heir_notified_at` **nicht** →
beliebig wiederholbar.

```bash
curl -X POST https://dxsjgajavgvjlksjawer.supabase.co/functions/v1/vault-trigger \
  -H "Authorization: Bearer <SERVICE_ROLE_KEY>" \
  -H "Content-Type: application/json" \
  -d '{"force":true}'
```

- `<SERVICE_ROLE_KEY>`: Supabase → Project Settings → API → `service_role`.
- Optional `"deviceId":"…"` → nur dieses Gerät (sonst alle aktiven Tresore). Die
  `device_id` steht in der Tabelle `vault_settings`.
- Antwort z. B.: `{"ok":true,"processed":1,"summary":{"<device>":"test_heirs_notified (1/1)"}}`.
- Verlauf prüfen: Tabelle `vault_log` (Event `heir_test`).

### Echten Ablauf simulieren (ohne Force)

In `vault_settings` für das Gerät `confirmed_at` auf vor (Intervall + 15) Tagen setzen
und `heir_notified_at = NULL`, dann den Trigger **ohne** Body aufrufen — so läuft die
echte Cron-Logik (inkl. einmaligem Setzen von `heir_notified_at`).

---

## 4. Edge Functions deployen

```bash
supabase functions deploy extract-contract   # KI-Extraktion
supabase functions deploy vault-trigger       # Erben-Trigger
supabase functions deploy vault-sync
supabase functions deploy vault-heartbeat
```

Die Warnung „Docker is not running" ist harmlos — Docker wird nur fürs lokale Testen
gebraucht, nicht fürs Deployen. **Deploys sind Produktiv-Aktionen** auf die Live-Supabase.
