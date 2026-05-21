# iOS — verbleibende Native-Schritte

KI-Scan und Cloud-Sync funktionieren auf iOS sofort (reiner Dart/HTTPS-Code,
Supabase-Konfiguration ist fest eingebaut). Zwei Funktionen brauchen noch
Xcode-Konfiguration — nur auf einem Mac möglich.

## 1. Teilen-Empfang (receive_sharing_intent)

Damit Pacto im iOS-Teilen-Menü anderer Apps erscheint, ist eine **Share
Extension** nötig:

1. In Xcode: `File → New → Target → "Share Extension"`.
2. App Group anlegen (z. B. `group.com.softbrewstudio.pacto`) und sowohl der
   App als auch der Extension zuweisen.
3. `Info.plist` von App + Extension sowie die Extension-Dateien gemäß der
   Paket-Anleitung anpassen — Abschnitt iOS:
   https://pub.dev/packages/receive_sharing_intent

Android funktioniert bereits ohne weitere Schritte — die `SEND`-Intent-Filter
für `image/*` und `application/pdf` stehen in `AndroidManifest.xml`.

## 2. Hintergrund-Heartbeat (workmanager)

Der Lebenszeichen-Heartbeat des Tresors läuft auf Android automatisch
(`registerPeriodicTask` in `lib/main.dart`). Für iOS zusätzlich:

1. `ios/Runner/Info.plist`:
   - `BGTaskSchedulerPermittedIdentifiers` → Array mit `pacto-heartbeat`
   - `UIBackgroundModes` → `fetch` und `processing`
2. `ios/Runner/AppDelegate.swift`: Task registrieren mit
   `WorkmanagerPlugin.registerPeriodicTask(withIdentifier: "pacto-heartbeat", ...)`.
3. Details — Abschnitt iOS: https://pub.dev/packages/workmanager

Laut CLAUDE.md ist der iOS-Heartbeat ohnehin erst für v1.1 vorgesehen — für
einen Android-First-Release ist dieser Schritt optional.

## Grundvoraussetzung

iOS-Builds brauchen generell macOS + Xcode. Auf einem Linux-Rechner lässt sich
die iOS-App nicht bauen — dafür einen Mac oder einen Cloud-Build-Dienst nutzen
(z. B. Codemagic oder GitHub Actions mit macOS-Runner).
