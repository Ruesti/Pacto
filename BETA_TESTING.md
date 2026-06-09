# BETA_TESTING.md — Pacto

Praxis-Anleitung zum **Bauen & Aufspielen**, zur **Beta-Verteilung mit Vollzugang**
und zum **Testen des Erben-Mailversands**.

**Zwei Zielgruppen — nicht verwechseln:**
- **Du (Entwickler):** baust die App und spielst sie auf dein eigenes Testgerät (Abschnitt 1,
  adb/Flutter) bzw. deployst Edge Functions und testest den Erben-Versand (Abschnitte 3–4).
- **Der Beta-Tester (beliebiges Gerät):** bekommt nur eine fertige APK oder eine Play-Einladung
  und installiert ohne adb/Flutter — siehe **Abschnitt 0**.

Projekt-Referenzen:
- Supabase-Projekt: `dxsjgajavgvjlksjawer` → Basis-URL `https://dxsjgajavgvjlksjawer.supabase.co`
- Beispiel-Testgerät (deine S22, USB-Serial): `R5CTA24VVKT` — bei anderen Geräten den eigenen
  Serial via `adb devices` ermitteln und überall einsetzen.

---

## 0. Für den Beta-Tester (beliebiges Android-Gerät, ohne adb)

Der Tester braucht **kein** Flutter/adb. Du baust eine APK (Abschnitt 1) und gibst sie weiter.

1. **APK erhalten** (per Mail/Cloud-Link). Empfehlung: universelle APK (läuft auf jedem Gerät).
2. Datei auf dem Handy öffnen → Android fragt nach **„Unbekannte Apps installieren"** →
   für die jeweilige Quelle (z. B. Dateien/Browser) **erlauben** → installieren.
3. App öffnen.
4. **Vollzugang freischalten** (ohne Kauf): Einstellungen → Eintrag **„Version"** **7× antippen**.
   SnackBar bestätigt „Tester-Vollzugang aktiviert". (Erneutes 7×-Tippen schaltet wieder ab.)

> Alternative ohne APK-Datei: Tester über **Play Internal Testing** einladen (Abschnitt 2,
> Weg A) — nötig, wenn der echte Kauf-/RevenueCat-Flow getestet werden soll.

---

## 1. Build & Aufspielen auf DEIN Testgerät (Entwickler)

> Dieser Abschnitt ist für dich auf der Entwicklermaschine. Ein Beta-Tester macht das nicht —
> für ihn gilt Abschnitt 0.

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

### Weg B — Schnelle Tester-Freischaltung (ohne Store) ✅ implementiert

Setzt ein lokales Premium-Flag (alle Plattformen), das Premium ohne Store-Kauf
freischaltet — funktioniert auch per **sideloaded APK** (kein Play/RevenueCat nötig).

**Aktivieren am Gerät:** Einstellungen → Eintrag **„Version"** **7× antippen**.
Eine SnackBar bestätigt „Tester-Vollzugang aktiviert". Erneutes 7×-Tippen schaltet
wieder ab.

Technik: `PremiumNotifier.toggleTesterUnlock()` setzt `pacto.premium.tester_unlock`
in den SharedPreferences; `_isPurchased()` prüft dieses Flag mit Vorrang
(`lib/features/premium/premium_service.dart`). Versteckte Geste:
`lib/features/settings/settings_screen.dart`.

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
