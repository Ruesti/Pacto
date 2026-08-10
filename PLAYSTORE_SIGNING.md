# PLAYSTORE_SIGNING.md — Agent-Brief

**Ziel:** Pacto release-signierfähig machen und ein hochladbares App Bundle (`.aab`) für den Internal-Testing-Track der Google Play Console erzeugen. Kein Console-Setup, kein Data-Safety-Formular — nur die lokale Build-Seite.

**Projekt:** Pacto — Flutter / Drift / Supabase. Play-Account existiert und ist verifiziert. Es geht ausschließlich darum, ein signiertes AAB zu produzieren.

---

## §0 — Interview (PFLICHT, vor jedem Code)

Beantworte / erfrage zuerst, schreibe nichts bis das geklärt ist:

1. **Gradle-Dialekt:** `android/app/build.gradle` (Groovy) oder `build.gradle.kts` (Kotlin DSL)? → selbst ermitteln, nicht raten.
2. **applicationId:** aktueller Wert auslesen. Zielwert bestätigen lassen (Vorschlag: `com.softbrewstudio.pacto`). **Final — nach Erst-Release nie mehr änderbar.** Nicht eigenmächtig setzen.
3. **Keystore:** Existiert bereits ein Upload-Keystore? Wenn ja: Pfad erfragen. Wenn nein → Phase 2 (Human-Step).
4. **SDK-Stand:** aktuelle `compileSdk` / `targetSdk` / `minSdk` auslesen und berichten.
5. **pubspec-Version:** aktuellen `version:`-String auslesen.

Erst nach Klärung weiter. Branch nennen, auf dem gearbeitet wird (Konvention: ein Branch pro Session).

---

## Invarianten (nicht verhandelbar)

- **Niemals** `key.properties` oder `*.jks` committen oder in Logs/Output ausgeben. Secrets werden vom Menschen gesetzt, nicht vom Agenten.
- **Keystore nicht autonom erzeugen** — `keytool` ist interaktiv und die Passwörter gehören dem Menschen. Agent liefert nur den exakten Befehl.
- Build-Output ist ein **AAB**, kein APK.
- Es wird **nur** angefasst: `android/`, `pubspec.yaml`, `.gitignore`. Nichts darüber hinaus. Jede berührte Datei explizit benennen.
- `targetSdk` / `compileSdk` = **36** (Android 16, ab 31.08.2026 Pflicht für neue Apps).

---

## Phasen (jede mit Gate — Bericht + Freigabe abwarten)

### Phase 1 — Recon
Auslesen und berichten: Gradle-Dialekt, aktuelle applicationId, SDK-Levels, pubspec-Version, ob `key.properties` / `*.jks` schon in `.gitignore` stehen, ob bereits eine `signingConfigs`-Sektion existiert. Keine Änderung. → **Gate.**

### Phase 2 — Keystore (HUMAN-STEP)
Wenn kein Keystore existiert: gib exakt diesen Befehl aus, lass ihn den Menschen ausführen:

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Lege `android/key.properties` als **Template mit Platzhaltern** an (keine echten Werte):

```properties
storePassword=
keyPassword=
keyAlias=upload
storeFile=/absoluter/pfad/zu/upload-keystore.jks
```

Warte auf Bestätigung des Menschen, dass (a) der Keystore liegt und (b) `key.properties` ausgefüllt ist. → **Gate.**

### Phase 3 — Signing-Wiring
Je nach Dialekt:

- **Groovy:** `Properties`-Loader oberhalb `android {}`, `signingConfigs.release` aus `key.properties`, `buildTypes.release.signingConfig = signingConfigs.release`.
- **Kotlin DSL:** `signingConfigs { create("release") { … as String } }`, `getByName("release").signingConfig = …`.

Defensiv: wenn `key.properties` fehlt, soll der Build nicht still auf Debug-Signatur zurückfallen — Loader nur greifen lassen, wenn Datei existiert, sonst nachvollziehbar. → **Gate.**

### Phase 4 — applicationId / SDK / Version
applicationId auf bestätigten Wert. `compileSdk`/`targetSdk` = 36, `minSdk` berichten (nicht ungefragt anheben). pubspec `version:` ggf. auf sauberen Start (`1.0.0+1`). → **Gate.**

### Phase 5 — .gitignore
Sicherstellen:
```
android/key.properties
*.jks
```
→ **Gate.**

### Phase 6 — Build + Verify
```bash
flutter build appbundle --release
```
Verifizieren: Output unter `build/app/outputs/bundle/release/app-release.aab` existiert, und das Gradle-Wiring referenziert nachweislich `signingConfigs.release` (nicht Debug-Fallback). Pfad zum AAB ausgeben.

---

## Definition of Done
- Signiertes `app-release.aab` liegt vor.
- Keine Secrets im Repo / in der History.
- Diff betrifft ausschließlich `android/`, `pubspec.yaml`, `.gitignore`.

## Out of Scope (NICHT Aufgabe des Agenten)
- Play-Console-Setup, Store-Listing, Data-Safety-Formular, Content-Rating.
- **Paid/Free-Entscheidung:** Free→Paid ist nach Veröffentlichung irreversibel. Falls Pacto je 2,99 € kosten soll, muss die App **vor** dem ersten Internal-Release in der Console als Paid angelegt werden (Payments-Profil nötig). Nur als Vorbedingung anmerken, nicht handeln.
