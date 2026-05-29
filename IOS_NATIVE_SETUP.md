# iOS — verbleibende Native-Schritte

KI-Scan und Cloud-Sync funktionieren auf iOS sofort (reiner Dart/HTTPS-Code,
Supabase-Konfiguration ist fest eingebaut). Zwei Funktionen brauchen noch
Xcode-Konfiguration — **nur auf einem Mac möglich** (oder via Cloud-Build mit
macOS-Runner, siehe unten).

Die Dart-Seite ist für beide Funktionen bereits vollständig verdrahtet:
- Teilen-Empfang wird in `lib/app.dart` konsumiert
  (`ReceiveSharingIntent.instance.getMediaStream()` / `getInitialMedia()`).
- Der Heartbeat wird in `lib/main.dart` registriert
  (`Workmanager().registerPeriodicTask('pacto-heartbeat', …)`), plattform-
  gegated und in `try/catch` — die App startet auf iOS also auch ohne den
  nativen Teil problemlos.

| Eckdaten | Wert |
|---|---|
| Bundle-ID (App) | `com.softbrewstudio.pacto` |
| Empfohlene App Group | `group.com.softbrewstudio.pacto` |
| receive_sharing_intent | `1.8.1` |
| workmanager | `0.9.0+3` |
| Heartbeat-Task-ID | `pacto-heartbeat` |

---

## ⚠️ Klarstellung: `CFBundleDocumentTypes` ≠ Share Extension

In `ios/Runner/Info.plist` steht bereits ein `CFBundleDocumentTypes`-Block
(Bilder / PDF / URL). **Das ist NICHT die Share Extension.** Dieser Block
bewirkt nur „**Öffnen in Pacto**" — z. B. wenn man in der Dateien-App eine PDF
auswählt und Pacto als Ziel-App anbietet.

Damit Pacto im **System-Teilen-Menü** anderer Apps (Foto teilen, Screenshot
teilen) auftaucht, ist ein eigenes **Share-Extension-Target** zwingend nötig
(Abschnitt 1). Der Document-Types-Block bleibt zusätzlich sinnvoll, ersetzt die
Extension aber nicht.

---

## 1. Teilen-Empfang (receive_sharing_intent 1.8.1) — erforderlich

Maßgeblich ist die offizielle Anleitung, Abschnitt **iOS**:
https://pub.dev/packages/receive_sharing_intent

### 1.1 App Group anlegen
1. Xcode → Target **Runner** → *Signing & Capabilities* → **+ Capability** →
   *App Groups* → Gruppe `group.com.softbrewstudio.pacto` hinzufügen.
2. Dieselbe Gruppe später auch dem Extension-Target zuweisen (Schritt 1.3).

### 1.2 Share Extension Target anlegen
1. Xcode → `File → New → Target… → Share Extension`.
   - Name z. B. `Share Extension`, Bundle-ID
     `com.softbrewstudio.pacto.ShareExtension`.
   - Aktivieren, wenn Xcode danach fragt.
2. **Deployment Target** der Extension auf denselben Wert wie Runner setzen.

### 1.3 Extension konfigurieren (gemäß Paket-Anleitung)
1. Im Extension-Target ebenfalls *App Groups* aktivieren und
   `group.com.softbrewstudio.pacto` zuweisen.
2. `ShareViewController` durch die Variante aus der `receive_sharing_intent`-
   Anleitung ersetzen (`RSIShareViewController` o. Ä.).
3. `Info.plist` der **Extension**: `NSExtensionActivationRule` so setzen, dass
   Bilder und PDFs akzeptiert werden
   (`NSExtensionActivationSupportsImageWithMaxCount`,
   `NSExtensionActivationSupportsFileWithMaxCount`).
4. In der **App**-`Info.plist` ist der vorhandene `CFBundleDocumentTypes`-Block
   für „Öffnen in" ausreichend — nicht entfernen.

### 1.4 Verifizieren
- Build auf Gerät/Simulator → in Fotos ein Bild teilen → Pacto erscheint im
  Share-Sheet → Tippen öffnet Pacto mit vorausgefülltem Scan.

> Android funktioniert bereits ohne weitere Schritte — die `SEND`-Intent-Filter
> für `image/*`, `application/pdf` und `text/plain` stehen in
> `android/app/src/main/AndroidManifest.xml`.

---

## 2. Hintergrund-Heartbeat (workmanager 0.9.0+3) — optional, v1.1

Laut CLAUDE.md ist der iOS-Heartbeat erst für **v1.1** vorgesehen. Für einen
**Android-First-Release ist dieser Abschnitt überspringbar** — der Dart-Code
fängt das fehlende native Setup bereits ab.

Wenn umgesetzt:
1. `ios/Runner/Info.plist`:
   - `BGTaskSchedulerPermittedIdentifiers` → Array mit `pacto-heartbeat`
   - `UIBackgroundModes` → `fetch` und `processing`
2. Heartbeat-Task im App-Start registrieren.

### ⚠️ Achtung: neues AppDelegate-/Scene-Lifecycle
`ios/Runner/AppDelegate.swift` nutzt das **neue** Flutter-Lifecycle
(`FlutterImplicitEngineDelegate` / `SceneDelegate`), nicht das klassische
`didFinishLaunchingWithOptions`-Muster. Die `workmanager`-iOS-Anleitung geht vom
alten Muster aus — die `WorkmanagerPlugin.registerTask(...)`-Aufrufe müssen an
das neue Lifecycle angepasst und gegen die zum Zeitpunkt der Umsetzung aktuelle
Paket-Doku abgeglichen werden:
https://pub.dev/packages/workmanager (Abschnitt iOS)

### ⚠️ App-Store-Review-Hinweis
`UIBackgroundModes` erst dann deklarieren, **wenn der Heartbeat tatsächlich
registriert wird**. Deklarierte, aber ungenutzte Background-Modes führen
regelmäßig zu Rückfragen im App-Review. Daher diese Plist-Keys nicht vorab,
sondern gemeinsam mit der Registrierung hinzufügen.

---

## 3. Status-Übersicht

| Schritt | Android | iOS |
|---|---|---|
| Dart-Verdrahtung (Share + Heartbeat) | ✅ erledigt | ✅ erledigt |
| Teilen-Empfang nativ | ✅ Manifest gesetzt | ⚠️ Share Extension fehlt (Abschnitt 1) |
| Hintergrund-Heartbeat nativ | ✅ `registerPeriodicTask` aktiv | ⏳ v1.1 (Abschnitt 2) |

---

## Grundvoraussetzung

iOS-Builds brauchen generell macOS + Xcode. Auf einem Linux-Rechner lässt sich
die iOS-App nicht bauen — dafür einen Mac oder einen Cloud-Build-Dienst nutzen
(z. B. Codemagic oder GitHub Actions mit macOS-Runner). Die Schritte in
Abschnitt 1 (Target/Capabilities/Plist) erfordern die Xcode-GUI und lassen sich
nicht zuverlässig durch reines Editieren von `project.pbxproj` ersetzen.
