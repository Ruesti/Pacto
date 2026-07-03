# Account-basierte Recovery (E-Mail/Passwort) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add an optional E-Mail/Passwort-Konto, mit dem Nutzer ihre Vertrags- und
Erben-Daten nach Geraeteverlust auf einem neuen Geraet wiederherstellen koennen, ohne
die bestehende anonyme `device_id`-Nutzung anzutasten.

**Architecture:** Neue, isolierte Supabase-Tabelle `account_vaults` (RLS auf
`auth.uid()`), `supabase_flutter` fuer Auth/Session-Management, ein aus dem
Account-Passwort abgeleiteter Escrow-Key verpackt den bestehenden lokalen AES-256-
Sync-Key. Restore ist immer ein separater, bestaetigter Schritt — Login allein
ueberschreibt nie lokale Daten.

**Tech Stack:** Flutter/Dart, Riverpod, Drift (SQLite), `supabase_flutter`, PointyCastle
(PBKDF2 + AES-256-GCM, bereits vorhanden).

## Global Constraints

- Bestehende anonyme `sync_data`/`heartbeats`-Tabellen und ihr `device_id`-Flow bleiben
  unveraendert — kein Account-Zwang fuer Cloud-Sync/Tresor.
- Der AES-256-Sync-Key verlaesst das Geraet nie im Klartext; Supabase kann zu keinem
  Zeitpunkt entschluesseln (kein Server-Master-Key).
- Login ueberschreibt nie lokale Daten. Restore ist immer ein separater, bestaetigter
  Schritt (Ausnahme: Onboarding-Einstieg, da dort die lokale DB per Definition leer ist).
- Passwort-Reset ohne Deep-Link: OTP-Code aus der E-Mail, kein Custom-URL-Scheme.
- Verliert ein Nutzer Passwort UND das Geraet mit dem lokalen Key gleichzeitig, ist das
  alte Backup unwiederbringlich verloren — das ist gewollt (echte Ende-zu-Ende-
  Verschluesselung) und muss der App klar kommunizieren, statt still zu scheitern.
- Neue l10n-Strings immer in `lib/l10n/app_de.arb` UND `lib/l10n/app_en.arb` ergaenzen,
  danach `flutter gen-l10n` laufen lassen.
- Referenz-Design-Doc: `docs/superpowers/specs/2026-07-03-account-recovery-design.md`.

---

### Task 1: Supabase-Migration `account_vaults`

**Files:**
- Create: `supabase/migrations/20260703130000_account_vaults.sql`
- Modify: `supabase/SETUP.md`

**Interfaces:**
- Produces: Tabelle `public.account_vaults(user_id, encrypted_payload, key_salt, encrypted_key, updated_at)` mit RLS nur fuer `auth.uid() = user_id`.

- [ ] **Step 1: Migration schreiben**

```sql
-- supabase/migrations/20260703130000_account_vaults.sql
-- account_vaults — optionales, Account-gebundenes Voll-Backup fuer Recovery.
-- Getrennt von sync_data (anonym, device_id-basiert), das unveraendert bestehen
-- bleibt. Der echte AES-256-Sync-Key wird zusaetzlich mit einem aus dem
-- Account-Passwort abgeleiteten Schluessel verschluesselt mitgesichert
-- (key_salt + encrypted_key) — siehe crypto_service.dart.
create table if not exists public.account_vaults (
  user_id           uuid        primary key references auth.users(id) on delete cascade,
  encrypted_payload text        not null,
  key_salt          text        not null,
  encrypted_key     text        not null,
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

- [ ] **Step 2: Migration anwenden**

```bash
supabase db push
```
Erwartet: `account_vaults` erscheint in der Tabellenliste des Supabase-Projekts.

- [ ] **Step 3: Dokumentations-Hinweis fuer den OTP-Passwort-Reset-Flow ergaenzen**

An `supabase/SETUP.md` anhaengen:

```markdown

## Passwort-Reset-E-Mail-Template fuer OTP-Flow

Damit "Passwort vergessen" ohne Deep-Link funktioniert (App zeigt ein Eingabefeld fuer
einen 6-stelligen Code statt einen Klick-Link zu erwarten), muss das Supabase-
E-Mail-Template angepasst werden:

Supabase Dashboard → Authentication → Email Templates → **Reset Password** →
sicherstellen, dass der Text `{{ .Token }}` enthaelt (z.B. "Dein Code: {{ .Token }}"),
zusaetzlich zum Standard-Link. Ohne diese Anpassung sieht der Nutzer keinen Code in der
Mail und der OTP-Flow in `ForgotPasswordScreen` schlaegt fehl.
```

- [ ] **Step 4: Commit**

```bash
git add supabase/migrations/20260703130000_account_vaults.sql supabase/SETUP.md
git commit -m "Add account_vaults table for optional account-based recovery"
```

---

### Task 2: `supabase_flutter`-Abhaengigkeit + Initialisierung

**Files:**
- Modify: `pubspec.yaml`
- Modify: `lib/main.dart`

**Interfaces:**
- Produces: `Supabase.instance.client` ist ab App-Start verfuegbar (Auth + Postgrest).

- [ ] **Step 1: Abhaengigkeit ergaenzen**

In `pubspec.yaml` unter `dependencies:` (nach `http: ^1.2.0`) ergaenzen:

```yaml
  supabase_flutter: ^2.8.0
```

- [ ] **Step 2: Packages installieren**

```bash
flutter pub get
```
Erwartet: kein Fehler, `supabase_flutter` erscheint in `pubspec.lock`.

- [ ] **Step 3: Initialisierung in `main.dart` ergaenzen**

In `lib/main.dart` den Import ergaenzen:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
```

und in `main()` direkt nach `WidgetsFlutterBinding.ensureInitialized();` einfuegen:

```dart
  await Supabase.initialize(
    url: SupabaseConfig.projectUrl,
    anonKey: SupabaseConfig.anonKey,
  );
```

- [ ] **Step 4: Build verifizieren**

```bash
flutter analyze lib/main.dart
```
Erwartet: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add pubspec.yaml pubspec.lock lib/main.dart
git commit -m "Add supabase_flutter and initialize Supabase Auth client"
```

---

### Task 3: Passwort-Escrow in `CryptoService`

**Files:**
- Modify: `lib/data/sync/crypto_service.dart`
- Test: `test/data/sync/crypto_service_escrow_test.dart`

**Interfaces:**
- Consumes: nichts Neues (nutzt bestehende private `_randomBytes`, `_encryptStringWithKey`, `_decryptStringWithKey`).
- Produces:
  - `class EscrowEnvelope { final String saltBase64; final String encryptedKeyJson; }`
  - `class WrongPasswordException implements Exception {}`
  - `CryptoService.encryptKeyForEscrow(String aesKeyBase64, String secret) -> Future<EscrowEnvelope>`
  - `CryptoService.decryptEscrowKey({required String saltBase64, required String encryptedKeyJson, required String secret}) -> Future<String>` (wirft `WrongPasswordException` bei falschem Secret)

- [ ] **Step 1: Fehlschlagenden Test schreiben**

```dart
// test/data/sync/crypto_service_escrow_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:pacto/data/sync/crypto_service.dart';

void main() {
  group('CryptoService password escrow', () {
    late CryptoService crypto;

    setUp(() {
      crypto = CryptoService();
    });

    test('encrypts and decrypts a key with the correct secret', () async {
      const aesKeyB64 = 'dGhpc2lzYXRlc3RrZXlvZjMyYnl0ZXNsb25nISE=';
      final escrow = await crypto.encryptKeyForEscrow(aesKeyB64, 'correct horse battery');
      final recovered = await crypto.decryptEscrowKey(
        saltBase64: escrow.saltBase64,
        encryptedKeyJson: escrow.encryptedKeyJson,
        secret: 'correct horse battery',
      );
      expect(recovered, aesKeyB64);
    });

    test('throws WrongPasswordException for a wrong secret', () async {
      const aesKeyB64 = 'dGhpc2lzYXRlc3RrZXlvZjMyYnl0ZXNsb25nISE=';
      final escrow = await crypto.encryptKeyForEscrow(aesKeyB64, 'correct horse battery');
      expect(
        () => crypto.decryptEscrowKey(
          saltBase64: escrow.saltBase64,
          encryptedKeyJson: escrow.encryptedKeyJson,
          secret: 'wrong password',
        ),
        throwsA(isA<WrongPasswordException>()),
      );
    });

    test('two escrows of the same key use different salts', () async {
      const aesKeyB64 = 'dGhpc2lzYXRlc3RrZXlvZjMyYnl0ZXNsb25nISE=';
      final a = await crypto.encryptKeyForEscrow(aesKeyB64, 'pw');
      final b = await crypto.encryptKeyForEscrow(aesKeyB64, 'pw');
      expect(a.saltBase64, isNot(b.saltBase64));
    });
  });
}
```

- [ ] **Step 2: Test ausfuehren, Fehlschlag bestaetigen**

```bash
flutter test test/data/sync/crypto_service_escrow_test.dart
```
Erwartet: FAIL — `encryptKeyForEscrow` ist nicht definiert.

- [ ] **Step 3: `_derivePinKey` zu `_deriveKeyFromSecret` verallgemeinern**

In `lib/data/sync/crypto_service.dart` die bestehende Methode umbenennen (sie leitet
bereits generisch einen Schluessel aus einem beliebigen Geheimnis + Salt ab — der Name
war nur historisch auf PIN zugeschnitten, wird jetzt auch fuer Passwort-Escrow
wiederverwendet):

```dart
  Uint8List _deriveKeyFromSecret(String secret, Uint8List salt) {
    final params = Pbkdf2Parameters(salt, _pbkdf2Iterations, 32);
    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))..init(params);
    return pbkdf2.process(Uint8List.fromList(utf8.encode(secret)));
  }
```

Die beiden bestehenden Aufrufstellen in `encryptWithPin`/`decryptWithPin` von
`_derivePinKey(pin, salt)` auf `_deriveKeyFromSecret(pin, salt)` umstellen.

- [ ] **Step 4: Escrow-Klassen und -Methoden ergaenzen**

Am Ende der Klasse `CryptoService` (vor der schliessenden `}`) ergaenzen, und die zwei
neuen Top-Level-Klassen ans Ende der Datei:

```dart
  // ────────── Passwort-Escrow (Account-Recovery) ──────────
  // Verpackt den echten AES-Sync-Key zusaetzlich mit einem aus dem
  // Account-Passwort abgeleiteten Schluessel, damit er nach Kontowechsel auf
  // einem neuen Geraet mit dem Passwort zurueckgewonnen werden kann. Nutzt
  // dieselbe PBKDF2-Ableitung wie der PIN-Modus, nur mit dem Passwort als
  // Geheimnis statt dem Erben-PIN.

  Future<EscrowEnvelope> encryptKeyForEscrow(
      String aesKeyBase64, String secret) async {
    final salt = _randomBytes(16);
    final key = _deriveKeyFromSecret(secret, salt);
    final encryptedKeyJson = _encryptStringWithKey(aesKeyBase64, key);
    return EscrowEnvelope(
      saltBase64: base64Encode(salt),
      encryptedKeyJson: encryptedKeyJson,
    );
  }

  Future<String> decryptEscrowKey({
    required String saltBase64,
    required String encryptedKeyJson,
    required String secret,
  }) async {
    final salt = base64Decode(saltBase64);
    final key = _deriveKeyFromSecret(secret, salt);
    try {
      return _decryptStringWithKey(encryptedKeyJson, key);
    } catch (_) {
      throw const WrongPasswordException();
    }
  }
```

Und ganz am Dateiende:

```dart
class EscrowEnvelope {
  final String saltBase64;
  final String encryptedKeyJson;
  const EscrowEnvelope(
      {required this.saltBase64, required this.encryptedKeyJson});
}

class WrongPasswordException implements Exception {
  const WrongPasswordException();
  @override
  String toString() => 'Falsches Passwort.';
}
```

- [ ] **Step 5: Test ausfuehren, Erfolg bestaetigen**

```bash
flutter test test/data/sync/crypto_service_escrow_test.dart
```
Erwartet: `00:0X +3: All tests passed!`

- [ ] **Step 6: Restlichen Code auf Konsistenz pruefen**

```bash
flutter analyze lib/data/sync/crypto_service.dart
```
Erwartet: `No issues found!`

- [ ] **Step 7: Commit**

```bash
git add lib/data/sync/crypto_service.dart test/data/sync/crypto_service_escrow_test.dart
git commit -m "Add password-based key escrow to CryptoService"
```

---

### Task 4: Gemeinsamer Backup-Payload-Mapper

**Files:**
- Create: `lib/data/sync/backup_payload_mapper.dart`
- Modify: `lib/data/sync/cloud_sync_service.dart`
- Test: `test/data/sync/backup_payload_mapper_test.dart`

**Interfaces:**
- Consumes: `Contract`, `Heir` aus `lib/data/database/database.dart`.
- Produces:
  - `Map<String, dynamic> contractToMap(Contract c)`
  - `Map<String, dynamic> heirToMap(Heir h)`
  - `Map<String, dynamic> buildBackupPayload({required List<Contract> contracts, required List<Heir> heirs})`
  - `ContractsCompanion contractCompanionFromMap(Map<String, dynamic> m)`
  - `HeirsCompanion heirCompanionFromMap(Map<String, dynamic> m)`

Hinweis: `contractToMap` spiegelt bewusst exakt das bestehende (unvollstaendige)
Mapping aus dem bisherigen `CloudSyncService._contractToMap` — `contractKind` fehlt dort
bereits heute und wird hier nicht nebenbei repariert (separates, nicht Teil dieses
Recovery-Features).

- [ ] **Step 1: Fehlschlagenden Test schreiben**

```dart
// test/data/sync/backup_payload_mapper_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:pacto/data/database/database.dart';
import 'package:pacto/data/sync/backup_payload_mapper.dart';

Contract _sampleContract() => Contract(
      id: 'c1',
      name: 'Netflix',
      entryType: EntryType.vertrag,
      contractKind: ContractKind.abo,
      accessCategory: null,
      category: ContractCategory.streaming,
      provider: 'Netflix International B.V.',
      contactPhone: null,
      contactEmail: null,
      contactUrl: null,
      cancellationMethod: CancellationMethod.online,
      cancellationInstructions: '',
      noticePeriod: '',
      monthlyCost: 17.99,
      billingCycle: BillingCycle.monthly,
      documentPath: null,
      notes: '',
      loginUsername: null,
      loginPasswordCt: null,
      loginHint: null,
      loginLastVerifiedAt: null,
      contractStart: null,
      nextRenewal: DateTime.utc(2026, 8, 1),
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 2),
    );

Heir _sampleHeir() => Heir(
      id: 'h1',
      name: 'Alex',
      email: 'alex@example.com',
      pinHash: 'somehash',
      accessLevel: HeirAccess.vollzugang,
      isActive: true,
      createdAt: DateTime.utc(2026, 1, 1),
    );

void main() {
  test('contractToMap contains the expected keys and values', () {
    final map = contractToMap(_sampleContract());
    expect(map['id'], 'c1');
    expect(map['name'], 'Netflix');
    expect(map['category'], 'streaming');
    expect(map['billingCycle'], 'monthly');
    expect(map['monthlyCost'], 17.99);
    expect(map['nextRenewal'], '2026-08-01T00:00:00.000Z');
  });

  test('heirToMap contains the expected keys and values', () {
    final map = heirToMap(_sampleHeir());
    expect(map['id'], 'h1');
    expect(map['accessLevel'], 'vollzugang');
    expect(map['isActive'], true);
  });

  test('buildBackupPayload wraps contracts and heirs with a version', () {
    final payload = buildBackupPayload(
      contracts: [_sampleContract()],
      heirs: [_sampleHeir()],
    );
    expect(payload['version'], 1);
    expect(payload['contracts'], hasLength(1));
    expect(payload['heirs'], hasLength(1));
  });
}
```

- [ ] **Step 2: Test ausfuehren, Fehlschlag bestaetigen**

```bash
flutter test test/data/sync/backup_payload_mapper_test.dart
```
Erwartet: FAIL — Datei `backup_payload_mapper.dart` existiert nicht.

- [ ] **Step 3: Mapper-Datei anlegen**

```dart
// lib/data/sync/backup_payload_mapper.dart
import 'package:drift/drift.dart' show Value;
import '../database/database.dart';

/// Wandelt einen [Contract] in die serialisierbare Form fuer verschluesselte
/// Cloud-Backups um (anonymer `sync_data`-Pfad UND Account-`account_vaults`-
/// Pfad nutzen dasselbe Format). Bekannte Luecke, nicht Teil dieses Mappers:
/// `contractKind` und die Login-Felder werden bewusst nicht mitgesichert —
/// das spiegelt das bestehende Verhalten von vor diesem Refactor.
Map<String, dynamic> contractToMap(Contract c) => {
      'id': c.id,
      'name': c.name,
      'entryType': c.entryType.name,
      'accessCategory': c.accessCategory?.name,
      'category': c.category.name,
      'provider': c.provider,
      'contactPhone': c.contactPhone,
      'contactEmail': c.contactEmail,
      'contactUrl': c.contactUrl,
      'cancellationMethod': c.cancellationMethod.name,
      'cancellationInstructions': c.cancellationInstructions,
      'noticePeriod': c.noticePeriod,
      'monthlyCost': c.monthlyCost,
      'billingCycle': c.billingCycle.name,
      'documentPath': c.documentPath,
      'notes': c.notes,
      'contractStart': c.contractStart?.toIso8601String(),
      'nextRenewal': c.nextRenewal?.toIso8601String(),
      'createdAt': c.createdAt.toIso8601String(),
      'updatedAt': c.updatedAt.toIso8601String(),
    };

Map<String, dynamic> heirToMap(Heir h) => {
      'id': h.id,
      'name': h.name,
      'email': h.email,
      'pinHash': h.pinHash,
      'accessLevel': h.accessLevel.name,
      'isActive': h.isActive,
      'createdAt': h.createdAt.toIso8601String(),
    };

Map<String, dynamic> buildBackupPayload({
  required List<Contract> contracts,
  required List<Heir> heirs,
}) =>
    {
      'version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'contracts': contracts.map(contractToMap).toList(),
      'heirs': heirs.map(heirToMap).toList(),
    };

/// Rueckrichtung von [contractToMap] — baut aus einem entschluesselten
/// Backup-Eintrag eine einfuegbare [ContractsCompanion], inkl. der
/// urspruenglichen `id` (Restore ersetzt, statt neue IDs zu vergeben).
ContractsCompanion contractCompanionFromMap(Map<String, dynamic> m) =>
    ContractsCompanion(
      id: Value(m['id'] as String),
      name: Value(m['name'] as String),
      entryType: Value(EntryType.values.byName(m['entryType'] as String)),
      accessCategory: Value(m['accessCategory'] == null
          ? null
          : AccessCategory.values.byName(m['accessCategory'] as String)),
      category: Value(ContractCategory.values.byName(m['category'] as String)),
      provider: Value(m['provider'] as String),
      contactPhone: Value(m['contactPhone'] as String?),
      contactEmail: Value(m['contactEmail'] as String?),
      contactUrl: Value(m['contactUrl'] as String?),
      cancellationMethod: Value(
          CancellationMethod.values.byName(m['cancellationMethod'] as String)),
      cancellationInstructions: Value(m['cancellationInstructions'] as String),
      noticePeriod: Value(m['noticePeriod'] as String),
      monthlyCost: Value((m['monthlyCost'] as num).toDouble()),
      billingCycle:
          Value(BillingCycle.values.byName(m['billingCycle'] as String)),
      documentPath: Value(m['documentPath'] as String?),
      notes: Value(m['notes'] as String),
      contractStart: Value(m['contractStart'] == null
          ? null
          : DateTime.parse(m['contractStart'] as String)),
      nextRenewal: Value(m['nextRenewal'] == null
          ? null
          : DateTime.parse(m['nextRenewal'] as String)),
      createdAt: Value(DateTime.parse(m['createdAt'] as String)),
      updatedAt: Value(DateTime.parse(m['updatedAt'] as String)),
    );

HeirsCompanion heirCompanionFromMap(Map<String, dynamic> m) => HeirsCompanion(
      id: Value(m['id'] as String),
      name: Value(m['name'] as String),
      email: Value(m['email'] as String),
      pinHash: Value(m['pinHash'] as String),
      accessLevel: Value(HeirAccess.values.byName(m['accessLevel'] as String)),
      isActive: Value(m['isActive'] as bool),
      createdAt: Value(DateTime.parse(m['createdAt'] as String)),
    );
```

- [ ] **Step 4: Test ausfuehren, Erfolg bestaetigen**

```bash
flutter test test/data/sync/backup_payload_mapper_test.dart
```
Erwartet: `00:0X +3: All tests passed!`

- [ ] **Step 5: `CloudSyncService` auf den Mapper umstellen**

In `lib/data/sync/cloud_sync_service.dart`:
- Import ergaenzen: `import 'backup_payload_mapper.dart';`
- Die privaten Methoden `_contractToMap` und `_heirToMap` (Zeilen 49–80) komplett entfernen.
- In `pushAll()` die Payload-Konstruktion ersetzen:

```dart
    final payload = buildBackupPayload(contracts: contracts, heirs: heirs);
```

(ersetzt den bisherigen mehrzeiligen `payload = { 'version': 1, ... }`-Block, der
`contracts.map(_contractToMap)`/`heirs.map(_heirToMap)` nutzte).

- [ ] **Step 6: Bestehendes Verhalten pruefen**

```bash
flutter analyze lib/data/sync/cloud_sync_service.dart
```
Erwartet: `No issues found!` — keine funktionale Aenderung, nur Extraktion.

- [ ] **Step 7: Commit**

```bash
git add lib/data/sync/backup_payload_mapper.dart lib/data/sync/cloud_sync_service.dart test/data/sync/backup_payload_mapper_test.dart
git commit -m "Extract shared backup payload mapper from CloudSyncService"
```

---

### Task 5: `replaceAll` in den DAOs fuer Restore

**Files:**
- Modify: `lib/data/database/daos/contracts_dao.dart`
- Modify: `lib/data/database/daos/heirs_dao.dart`
- Test: `test/data/database/daos/replace_all_test.dart`

**Interfaces:**
- Produces:
  - `ContractsDao.replaceAll(List<ContractsCompanion> entries) -> Future<void>`
  - `HeirsDao.replaceAll(List<HeirsCompanion> entries) -> Future<void>`

- [ ] **Step 1: Fehlschlagenden Test schreiben**

```dart
// test/data/database/daos/replace_all_test.dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacto/data/database/database.dart';
import 'package:pacto/data/sync/backup_payload_mapper.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  test('replaceAll round-trips a contract through the backup mapper', () async {
    final original = Contract(
      id: 'c1',
      name: 'Netflix',
      entryType: EntryType.vertrag,
      contractKind: ContractKind.abo,
      accessCategory: null,
      category: ContractCategory.streaming,
      provider: 'Netflix International B.V.',
      contactPhone: null,
      contactEmail: null,
      contactUrl: null,
      cancellationMethod: CancellationMethod.online,
      cancellationInstructions: '',
      noticePeriod: '',
      monthlyCost: 17.99,
      billingCycle: BillingCycle.monthly,
      documentPath: null,
      notes: '',
      loginUsername: null,
      loginPasswordCt: null,
      loginHint: null,
      loginLastVerifiedAt: null,
      contractStart: null,
      nextRenewal: DateTime.utc(2026, 8, 1),
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 2),
    );

    final companion = contractCompanionFromMap(contractToMap(original));
    await db.contractsDao.replaceAll([companion]);

    final restored = await db.contractsDao.getAll();
    expect(restored, hasLength(1));
    expect(restored.single.id, 'c1');
    expect(restored.single.category, ContractCategory.streaming);
    expect(restored.single.monthlyCost, 17.99);
    expect(restored.single.nextRenewal, DateTime.utc(2026, 8, 1));
  });

  test('replaceAll clears previously existing contracts first', () async {
    await db.contractsDao.insertContract(ContractsCompanion.insert(
      name: 'Old entry',
      provider: 'Old GmbH',
    ));
    expect(await db.contractsDao.getAll(), hasLength(1));

    await db.contractsDao.replaceAll([]);

    expect(await db.contractsDao.getAll(), isEmpty);
  });

  test('heirs replaceAll round-trips through the mapper', () async {
    final original = Heir(
      id: 'h1',
      name: 'Alex',
      email: 'alex@example.com',
      pinHash: 'somehash',
      accessLevel: HeirAccess.vollzugang,
      isActive: true,
      createdAt: DateTime.utc(2026, 1, 1),
    );

    final companion = heirCompanionFromMap(heirToMap(original));
    await db.heirsDao.replaceAll([companion]);

    final restored = await db.heirsDao.getAll();
    expect(restored, hasLength(1));
    expect(restored.single.name, 'Alex');
    expect(restored.single.accessLevel, HeirAccess.vollzugang);
  });
}
```

- [ ] **Step 2: Test ausfuehren, Fehlschlag bestaetigen**

```bash
flutter test test/data/database/daos/replace_all_test.dart
```
Erwartet: FAIL — `replaceAll` ist auf `ContractsDao`/`HeirsDao` nicht definiert.

- [ ] **Step 3: `replaceAll` in `ContractsDao` ergaenzen**

In `lib/data/database/daos/contracts_dao.dart`, direkt nach `insertContract`:

```dart
  /// Loescht alle vorhandenen Vertraege und ersetzt sie durch [entries] —
  /// genutzt beim Account-Recovery-Restore (siehe AccountVaultService).
  /// Laeuft in einer Transaktion, damit ein Fehler mitten im Import nicht
  /// eine halb-geleerte Tabelle hinterlaesst.
  Future<void> replaceAll(List<ContractsCompanion> entries) {
    return transaction(() async {
      await delete(contracts).go();
      for (final entry in entries) {
        await into(contracts).insert(entry);
      }
    });
  }
```

- [ ] **Step 4: `replaceAll` in `HeirsDao` ergaenzen**

In `lib/data/database/daos/heirs_dao.dart`, direkt nach `insertHeir`:

```dart
  /// Loescht alle vorhandenen Erben und ersetzt sie durch [entries] — genutzt
  /// beim Account-Recovery-Restore (siehe AccountVaultService).
  Future<void> replaceAll(List<HeirsCompanion> entries) {
    return transaction(() async {
      await delete(heirs).go();
      for (final entry in entries) {
        await into(heirs).insert(entry);
      }
    });
  }
```

- [ ] **Step 5: Test ausfuehren, Erfolg bestaetigen**

```bash
flutter test test/data/database/daos/replace_all_test.dart
```
Erwartet: `00:0X +3: All tests passed!`

- [ ] **Step 6: Commit**

```bash
git add lib/data/database/daos/contracts_dao.dart lib/data/database/daos/heirs_dao.dart test/data/database/daos/replace_all_test.dart
git commit -m "Add replaceAll to ContractsDao/HeirsDao for account restore"
```

---

### Task 6: `AccountVaultService` + Riverpod-Provider

**Files:**
- Create: `lib/data/sync/account_vault_service.dart`
- Create: `lib/data/providers/account_provider.dart`

**Interfaces:**
- Consumes: `CryptoService` (Task 3), `buildBackupPayload`/`contractCompanionFromMap`/`heirCompanionFromMap` (Task 4), `ContractsDao.replaceAll`/`HeirsDao.replaceAll` (Task 5), `Supabase.instance.client` (Task 2).
- Produces:
  - `class NoBackupFoundException implements Exception {}`
  - `class AccountVaultService { ... }` mit `signUp`, `signIn`, `signOut`, `requestPasswordReset`, `confirmPasswordReset`, `ensureVaultPushed`, `pushPayloadOnly`, `restoreFromAccount`, `rotateEscrow`, `isLoggedIn`, `currentSession`.
  - `accountVaultServiceProvider -> Provider<AccountVaultService>`
  - `authStateProvider -> StreamProvider<Session?>`

- [ ] **Step 1: `AccountVaultService` schreiben**

```dart
// lib/data/sync/account_vault_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../database/database.dart';
import 'backup_payload_mapper.dart';
import 'crypto_service.dart';

class NoBackupFoundException implements Exception {
  const NoBackupFoundException();
  @override
  String toString() => 'Kein Cloud-Backup fuer dieses Konto vorhanden.';
}

/// Optionale, Account-gebundene Backup-Ebene (E-Mail/Passwort) fuer echte
/// Wiederherstellung nach Geraeteverlust. Laeuft komplett getrennt vom
/// anonymen, `device_id`-basierten Sync in [CloudSyncService] — beide koennen
/// nebeneinander bestehen.
class AccountVaultService {
  final AppDatabase _db;
  final CryptoService _crypto;

  AccountVaultService(this._db, this._crypto);

  SupabaseClient get _client => Supabase.instance.client;

  Session? get currentSession => _client.auth.currentSession;
  bool get isLoggedIn => currentSession != null;

  Future<AuthResponse> signUp(String email, String password) {
    return _client.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> signIn(String email, String password) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() => _client.auth.signOut();

  Future<void> requestPasswordReset(String email) {
    return _client.auth.resetPasswordForEmail(email);
  }

  /// Verifiziert den 6-stelligen Code aus der Reset-Mail, setzt das neue
  /// Passwort und verpackt den Escrow neu. Danach ist eine Session aktiv, wie
  /// nach einem normalen Login.
  Future<void> confirmPasswordReset({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    await _client.auth.verifyOTP(
      type: OtpType.recovery,
      email: email,
      token: otp,
    );
    await _client.auth.updateUser(UserAttributes(password: newPassword));
    await rotateEscrow(newPassword);
  }

  Future<String> _buildEncryptedPayload() async {
    final contracts = await _db.contractsDao.getAll();
    final heirs = await _db.heirsDao.getAll();
    final payload = buildBackupPayload(contracts: contracts, heirs: heirs);
    return _crypto.encryptJson(payload);
  }

  /// Legt beim ersten Login/Signup dieses Kontos einen Backup-Eintrag an,
  /// falls noch keiner existiert. Idempotent — kann nach jedem Login
  /// gefahrlos aufgerufen werden (repariert auch einen abgebrochenen ersten
  /// Push nach). Braucht das Passwort nur fuer den Escrow, nicht fuer den
  /// Payload selbst.
  Future<void> ensureVaultPushed(String password) async {
    final userId = currentSession?.user.id;
    if (userId == null) return;
    final existing = await _client
        .from('account_vaults')
        .select('user_id')
        .eq('user_id', userId)
        .maybeSingle();
    if (existing != null) return;

    final aesKeyB64 = await _crypto.exportKeyBase64();
    final escrow = await _crypto.encryptKeyForEscrow(aesKeyB64, password);
    await _client.from('account_vaults').insert({
      'user_id': userId,
      'encrypted_payload': await _buildEncryptedPayload(),
      'key_salt': escrow.saltBase64,
      'encrypted_key': escrow.encryptedKeyJson,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  /// Aktualisiert nur den verschluesselten Contracts+Heirs-Payload — kein
  /// Passwort noetig, da der echte AES-Key bereits lokal vorliegt. Das ist
  /// der Pfad, den der bestehende "Jetzt synchronisieren"-Button fuer
  /// eingeloggte Nutzer verwendet (siehe CloudSyncService.pushAll).
  Future<void> pushPayloadOnly() async {
    final userId = currentSession?.user.id;
    if (userId == null) return;
    await _client.from('account_vaults').update({
      'encrypted_payload': await _buildEncryptedPayload(),
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('user_id', userId);
  }

  /// Laedt das Backup fuer das eingeloggte Konto herunter, entschluesselt den
  /// Sync-Key mit [password] und importiert Contracts+Heirs in die lokale DB
  /// — bestehende lokale Eintraege werden dabei ERSETZT (siehe
  /// [ContractsDao.replaceAll]/[HeirsDao.replaceAll]). Wirft
  /// [NoBackupFoundException], wenn (noch) kein Backup existiert, und
  /// [WrongPasswordException] (aus crypto_service.dart) bei falschem Passwort.
  Future<void> restoreFromAccount(String password) async {
    final userId = currentSession?.user.id;
    if (userId == null) {
      throw StateError('restoreFromAccount erfordert eine aktive Session.');
    }
    final row = await _client
        .from('account_vaults')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    if (row == null) throw const NoBackupFoundException();

    final aesKeyB64 = await _crypto.decryptEscrowKey(
      saltBase64: row['key_salt'] as String,
      encryptedKeyJson: row['encrypted_key'] as String,
      secret: password,
    );
    await _crypto.importKeyBase64(aesKeyB64);
    final payload =
        await _crypto.decryptJson(row['encrypted_payload'] as String);
    await _applyRestoredPayload(payload);
  }

  Future<void> _applyRestoredPayload(Map<String, dynamic> payload) async {
    final contracts = (payload['contracts'] as List)
        .cast<Map<String, dynamic>>()
        .map(contractCompanionFromMap)
        .toList();
    final heirs = (payload['heirs'] as List)
        .cast<Map<String, dynamic>>()
        .map(heirCompanionFromMap)
        .toList();
    await _db.contractsDao.replaceAll(contracts);
    await _db.heirsDao.replaceAll(heirs);
  }

  /// Verpackt den lokal aktuell vorhandenen AES-Key neu mit [newPassword] und
  /// schreibt Escrow + Payload per Upsert. Existiert lokal (noch) kein
  /// urspruenglicher Sync-Key mehr (Geraet UND Passwort verloren), erzeugt
  /// `CryptoService.exportKeyBase64()` automatisch einen frischen Key — die
  /// Zeile wird dann faktisch als neuer, leerer Tresor unter dem neuen
  /// Passwort angelegt. Das ist der bewusste Trade-off aus dem Design-Doc.
  Future<void> rotateEscrow(String newPassword) async {
    final userId = currentSession?.user.id;
    if (userId == null) return;
    final aesKeyB64 = await _crypto.exportKeyBase64();
    final escrow = await _crypto.encryptKeyForEscrow(aesKeyB64, newPassword);
    await _client.from('account_vaults').upsert({
      'user_id': userId,
      'key_salt': escrow.saltBase64,
      'encrypted_key': escrow.encryptedKeyJson,
      'encrypted_payload': await _buildEncryptedPayload(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
```

- [ ] **Step 2: Provider-Datei schreiben**

```dart
// lib/data/providers/account_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../sync/account_vault_service.dart';
import 'database_provider.dart';

final accountVaultServiceProvider = Provider<AccountVaultService>((ref) {
  return AccountVaultService(
    ref.watch(databaseProvider),
    ref.watch(cryptoServiceProvider),
  );
});

/// Aktuelle Supabase-Auth-Session, aktualisiert sich automatisch bei
/// Login/Logout/Token-Refresh. `null` bedeutet: kein Konto eingeloggt.
final authStateProvider = StreamProvider<Session?>((ref) async* {
  final client = Supabase.instance.client;
  yield client.auth.currentSession;
  yield* client.auth.onAuthStateChange.map((event) => event.session);
});
```

- [ ] **Step 3: Analyse**

```bash
flutter analyze lib/data/sync/account_vault_service.dart lib/data/providers/account_provider.dart
```
Erwartet: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/data/sync/account_vault_service.dart lib/data/providers/account_provider.dart
git commit -m "Add AccountVaultService and its Riverpod providers"
```

---

### Task 7: `CloudSyncService.pushAll()` an Account-Login koppeln

**Files:**
- Modify: `lib/data/sync/cloud_sync_service.dart`
- Modify: `lib/data/providers/database_provider.dart`

**Interfaces:**
- Consumes: `AccountVaultService.pushPayloadOnly()` (Task 6).
- Produces: `CloudSyncService.pushAll()` schreibt bei aktiver Session nach `account_vaults` statt `sync_data`.

- [ ] **Step 1: `CloudSyncService` um `AccountVaultService`-Abhaengigkeit erweitern**

In `lib/data/sync/cloud_sync_service.dart`:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'account_vault_service.dart';
```

Konstruktor und Feld ergaenzen:

```dart
class CloudSyncService {
  final AppDatabase _db;
  final CryptoService _crypto;
  final AccountVaultService _accountVault;

  CloudSyncService(this._db, this._crypto, this._accountVault);
```

- [ ] **Step 2: `pushAll()` verzweigen**

Am Anfang von `pushAll()` (vor der bestehenden Logik) ergaenzen:

```dart
  Future<void> pushAll() async {
    if (Supabase.instance.client.auth.currentSession != null) {
      // Eingeloggt: Backup laeuft ueber das Account-Vault (siehe
      // AccountVaultService), nicht ueber den anonymen device_id-Pfad.
      await _accountVault.pushPayloadOnly();
      return;
    }

    final cfg = await loadConfig();
    // ... Rest der bestehenden Methode unveraendert ...
```

- [ ] **Step 3: Provider anpassen**

In `lib/data/providers/database_provider.dart` Import ergaenzen:

```dart
import 'account_provider.dart';
```

und `cloudSyncServiceProvider` erweitern:

```dart
final cloudSyncServiceProvider = Provider<CloudSyncService>((ref) {
  return CloudSyncService(
    ref.watch(databaseProvider),
    ref.watch(cryptoServiceProvider),
    ref.watch(accountVaultServiceProvider),
  );
});
```

- [ ] **Step 4: Analyse**

```bash
flutter analyze lib/data/sync/cloud_sync_service.dart lib/data/providers/database_provider.dart
```
Erwartet: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add lib/data/sync/cloud_sync_service.dart lib/data/providers/database_provider.dart
git commit -m "Route CloudSyncService.pushAll through account vault when logged in"
```

---

### Task 8: `RegisterScreen`

**Files:**
- Create: `lib/features/account/register_screen.dart`
- Modify: `lib/l10n/app_de.arb`
- Modify: `lib/l10n/app_en.arb`

**Interfaces:**
- Consumes: `accountVaultServiceProvider.signUp`, `.ensureVaultPushed` (Task 6).
- Produces: `class RegisterScreen extends ConsumerStatefulWidget`.

- [ ] **Step 1: l10n-Strings ergaenzen**

In `lib/l10n/app_de.arb` (nach `"fieldLoginHint"`, Zeile ~346) ergaenzen:

```json
  "registerTitle": "Konto erstellen",
  "registerPasswordLabel": "Passwort",
  "registerPasswordConfirmLabel": "Passwort bestätigen",
  "registerSubmitButton": "Registrieren",
  "registerPasswordMismatch": "Passwörter stimmen nicht überein",
  "registerPasswordTooShort": "Mindestens 8 Zeichen",
  "registerSuccessMessage": "Bestätige deine E-Mail über den Link, den wir dir geschickt haben — danach kannst du dich einloggen.",
```

In `lib/l10n/app_en.arb` an der entsprechenden Stelle:

```json
  "registerTitle": "Create account",
  "registerPasswordLabel": "Password",
  "registerPasswordConfirmLabel": "Confirm password",
  "registerSubmitButton": "Register",
  "registerPasswordMismatch": "Passwords do not match",
  "registerPasswordTooShort": "At least 8 characters",
  "registerSuccessMessage": "Confirm your email using the link we sent you — then you can log in.",
```

- [ ] **Step 2: l10n generieren**

```bash
flutter gen-l10n
```
Erwartet: kein Fehler, `lib/l10n/app_localizations_de.dart`/`_en.dart` enthalten die neuen Getter.

- [ ] **Step 3: `RegisterScreen` schreiben**

```dart
// lib/features/account/register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/account_provider.dart';
import '../../shared/l10n/l10n_extension.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l = context.l10n;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final service = ref.read(accountVaultServiceProvider);
      final response =
          await service.signUp(_emailCtrl.text.trim(), _passwordCtrl.text);
      if (response.session != null) {
        // "Confirm email" ist im Supabase-Projekt deaktiviert — Session ist
        // sofort aktiv, Vault kann direkt angelegt werden.
        await service.ensureVaultPushed(_passwordCtrl.text);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.registerSuccessMessage)));
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.errorMessage(e.toString()))));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.registerTitle)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  labelText: l.fieldEmail,
                  prefixIcon: const Icon(Icons.email_outlined)),
              validator: (v) =>
                  v?.isEmpty ?? true ? l.validationEmailRequired : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordCtrl,
              obscureText: true,
              decoration: InputDecoration(
                  labelText: l.registerPasswordLabel,
                  prefixIcon: const Icon(Icons.lock_outline)),
              validator: (v) =>
                  (v == null || v.length < 8) ? l.registerPasswordTooShort : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirmCtrl,
              obscureText: true,
              decoration: InputDecoration(
                  labelText: l.registerPasswordConfirmLabel,
                  prefixIcon: const Icon(Icons.lock_outline)),
              validator: (v) =>
                  v != _passwordCtrl.text ? l.registerPasswordMismatch : null,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(l.registerSubmitButton),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Analyse**

```bash
flutter analyze lib/features/account/register_screen.dart
```
Erwartet: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add lib/features/account/register_screen.dart lib/l10n/app_de.arb lib/l10n/app_en.arb lib/l10n/app_localizations*.dart
git commit -m "Add RegisterScreen for account-based recovery"
```

---

### Task 9: `LoginScreen`

**Files:**
- Create: `lib/features/account/login_screen.dart`
- Modify: `lib/l10n/app_de.arb`
- Modify: `lib/l10n/app_en.arb`

**Interfaces:**
- Consumes: `accountVaultServiceProvider.signIn`, `.ensureVaultPushed`, `.restoreFromAccount` (Task 6); `NoBackupFoundException`, `WrongPasswordException`.
- Produces: `class LoginScreen extends ConsumerStatefulWidget { final bool autoRestoreOnSuccess; final VoidCallback? onRestoredAndDone; }`

- [ ] **Step 1: l10n-Strings ergaenzen**

In `lib/l10n/app_de.arb`:

```json
  "loginTitle": "Einloggen",
  "loginSubmitButton": "Einloggen",
  "loginForgotPasswordLink": "Passwort vergessen?",
  "loginNoAccountLink": "Noch kein Konto? Registrieren",
  "loginRestoringMessage": "Daten werden wiederhergestellt …",
  "loginRestoreSuccess": "Daten wiederhergestellt.",
  "loginNoBackupFound": "Noch kein Backup für dieses Konto vorhanden.",
```

In `lib/l10n/app_en.arb`:

```json
  "loginTitle": "Log in",
  "loginSubmitButton": "Log in",
  "loginForgotPasswordLink": "Forgot password?",
  "loginNoAccountLink": "No account yet? Register",
  "loginRestoringMessage": "Restoring your data …",
  "loginRestoreSuccess": "Data restored.",
  "loginNoBackupFound": "No backup found for this account yet.",
```

- [ ] **Step 2: l10n generieren**

```bash
flutter gen-l10n
```

- [ ] **Step 3: `LoginScreen` schreiben**

```dart
// lib/features/account/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/account_provider.dart';
import '../../data/sync/account_vault_service.dart';
import '../../data/sync/crypto_service.dart';
import '../../shared/l10n/l10n_extension.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  // true beim Onboarding-Einstieg: nach erfolgreichem Login wird sofort ohne
  // Rueckfrage wiederhergestellt, weil die lokale DB dort per Definition leer
  // ist. false aus den Einstellungen: Login allein ueberschreibt nichts, ein
  // separater Restore-Button uebernimmt das (siehe AccountScreen).
  final bool autoRestoreOnSuccess;

  const LoginScreen({super.key, this.autoRestoreOnSuccess = false});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l = context.l10n;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final service = ref.read(accountVaultServiceProvider);
    try {
      await service.signIn(_emailCtrl.text.trim(), _passwordCtrl.text);
      await service.ensureVaultPushed(_passwordCtrl.text);

      if (widget.autoRestoreOnSuccess) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l.loginRestoringMessage)));
        try {
          await service.restoreFromAccount(_passwordCtrl.text);
          if (!mounted) return;
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(l.loginRestoreSuccess)));
        } on NoBackupFoundException {
          // Kein Fehler: neues Konto ohne bisheriges Backup — normal weiter.
        }
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on WrongPasswordException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.errorMessage(e.toString()))));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.errorMessage(e.toString()))));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.loginTitle)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  labelText: l.fieldEmail,
                  prefixIcon: const Icon(Icons.email_outlined)),
              validator: (v) =>
                  v?.isEmpty ?? true ? l.validationEmailRequired : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordCtrl,
              obscureText: true,
              decoration: InputDecoration(
                  labelText: l.fieldLoginPassword,
                  prefixIcon: const Icon(Icons.lock_outline)),
              validator: (v) => v?.isEmpty ?? true ? l.registerPasswordTooShort : null,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const ForgotPasswordScreen())),
                child: Text(l.loginForgotPasswordLink),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(l.loginSubmitButton),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const RegisterScreen())),
              child: Text(l.loginNoAccountLink),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Analyse**

```bash
flutter analyze lib/features/account/login_screen.dart
```
Erwartet: Fehler wegen fehlendem `forgot_password_screen.dart` (kommt in Task 10) — das
ist an dieser Stelle im Plan erwartet. Nach Abschluss von Task 10 erneut pruefen und dann
erst committen (siehe Step 5).

- [ ] **Step 5: Commit (nach Task 10)**

```bash
git add lib/features/account/login_screen.dart lib/l10n/app_de.arb lib/l10n/app_en.arb lib/l10n/app_localizations*.dart
git commit -m "Add LoginScreen with auto-restore-on-success support"
```

---

### Task 10: `ForgotPasswordScreen`

**Files:**
- Create: `lib/features/account/forgot_password_screen.dart`
- Modify: `lib/l10n/app_de.arb`
- Modify: `lib/l10n/app_en.arb`

**Interfaces:**
- Consumes: `accountVaultServiceProvider.requestPasswordReset`, `.confirmPasswordReset` (Task 6).
- Produces: `class ForgotPasswordScreen extends ConsumerStatefulWidget`.

- [ ] **Step 1: l10n-Strings ergaenzen**

In `lib/l10n/app_de.arb`:

```json
  "forgotPasswordTitle": "Passwort vergessen",
  "forgotPasswordEmailStepBody": "Gib deine E-Mail ein, wir schicken dir einen Code.",
  "forgotPasswordSendCodeButton": "Code senden",
  "forgotPasswordCodeSentMessage": "Code verschickt — bitte E-Mail prüfen.",
  "forgotPasswordOtpLabel": "Code aus der E-Mail",
  "forgotPasswordNewPasswordLabel": "Neues Passwort",
  "forgotPasswordSubmitButton": "Passwort setzen",
  "forgotPasswordSuccessMessage": "Passwort geändert.",
```

In `lib/l10n/app_en.arb`:

```json
  "forgotPasswordTitle": "Forgot password",
  "forgotPasswordEmailStepBody": "Enter your email, we'll send you a code.",
  "forgotPasswordSendCodeButton": "Send code",
  "forgotPasswordCodeSentMessage": "Code sent — please check your email.",
  "forgotPasswordOtpLabel": "Code from the email",
  "forgotPasswordNewPasswordLabel": "New password",
  "forgotPasswordSubmitButton": "Set password",
  "forgotPasswordSuccessMessage": "Password changed.",
```

- [ ] **Step 2: l10n generieren**

```bash
flutter gen-l10n
```

- [ ] **Step 3: `ForgotPasswordScreen` schreiben**

```dart
// lib/features/account/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/account_provider.dart';
import '../../shared/l10n/l10n_extension.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  bool _codeSent = false;
  bool _submitting = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _otpCtrl.dispose();
    _newPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final l = context.l10n;
    if (_emailCtrl.text.trim().isEmpty) return;
    setState(() => _submitting = true);
    try {
      await ref
          .read(accountVaultServiceProvider)
          .requestPasswordReset(_emailCtrl.text.trim());
      if (!mounted) return;
      setState(() => _codeSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.forgotPasswordCodeSentMessage)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.errorMessage(e.toString()))));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _submitNewPassword() async {
    final l = context.l10n;
    if (_otpCtrl.text.trim().isEmpty || _newPasswordCtrl.text.length < 8) return;
    setState(() => _submitting = true);
    try {
      await ref.read(accountVaultServiceProvider).confirmPasswordReset(
            email: _emailCtrl.text.trim(),
            otp: _otpCtrl.text.trim(),
            newPassword: _newPasswordCtrl.text,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.forgotPasswordSuccessMessage)));
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.errorMessage(e.toString()))));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.forgotPasswordTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l.forgotPasswordEmailStepBody),
          const SizedBox(height: 12),
          TextField(
            controller: _emailCtrl,
            enabled: !_codeSent,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
                labelText: l.fieldEmail,
                prefixIcon: const Icon(Icons.email_outlined)),
          ),
          const SizedBox(height: 12),
          if (!_codeSent)
            FilledButton(
              onPressed: _submitting ? null : _sendCode,
              child: Text(l.forgotPasswordSendCodeButton),
            ),
          if (_codeSent) ...[
            TextField(
              controller: _otpCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: l.forgotPasswordOtpLabel,
                  prefixIcon: const Icon(Icons.pin_outlined)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _newPasswordCtrl,
              obscureText: true,
              decoration: InputDecoration(
                  labelText: l.forgotPasswordNewPasswordLabel,
                  prefixIcon: const Icon(Icons.lock_outline)),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _submitting ? null : _submitNewPassword,
              child: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(l.forgotPasswordSubmitButton),
            ),
          ],
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Analyse (Login- und Forgot-Password-Screen zusammen)**

```bash
flutter analyze lib/features/account/
```
Erwartet: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add lib/features/account/forgot_password_screen.dart lib/features/account/login_screen.dart lib/l10n/app_de.arb lib/l10n/app_en.arb lib/l10n/app_localizations*.dart
git commit -m "Add ForgotPasswordScreen (OTP flow) and finish LoginScreen"
```

---

### Task 11: `AccountScreen` + Einbindung in Settings

**Files:**
- Create: `lib/features/account/account_screen.dart`
- Modify: `lib/features/settings/supabase_sync_screen.dart`
- Modify: `lib/l10n/app_de.arb`
- Modify: `lib/l10n/app_en.arb`

**Interfaces:**
- Consumes: `authStateProvider`, `accountVaultServiceProvider` (Task 6), `LoginScreen`/`RegisterScreen` (Task 8/9).
- Produces: `class AccountScreen extends ConsumerWidget`, eingebunden als neuer Abschnitt in `SupabaseSyncScreen`.

- [ ] **Step 1: l10n-Strings ergaenzen**

In `lib/l10n/app_de.arb`:

```json
  "accountSectionTitle": "Konto",
  "accountNotLoggedInText": "Sichere deine Daten mit einem Konto, um sie nach einem Geräteverlust wiederherzustellen.",
  "accountRegisterButton": "Registrieren",
  "accountLoginButton": "Einloggen",
  "accountLoggedInAs": "Eingeloggt als {email}",
  "@accountLoggedInAs": {
    "placeholders": {
      "email": {"type": "String"}
    }
  },
  "accountLogoutButton": "Abmelden",
  "accountRestoreButton": "Cloud-Backup wiederherstellen",
  "accountRestoreConfirmTitle": "Backup wiederherstellen?",
  "accountRestoreConfirmBody": "Ersetzt deine aktuellen lokalen Daten durch das Cloud-Backup. Das kann nicht rückgängig gemacht werden.",
  "accountRestoreNeedsPasswordTitle": "Passwort bestätigen",
  "accountRestoreNeedsPasswordBody": "Gib dein Passwort erneut ein, um den Cloud-Schlüssel zu entschlüsseln.",
```

In `lib/l10n/app_en.arb`:

```json
  "accountSectionTitle": "Account",
  "accountNotLoggedInText": "Secure your data with an account so you can restore it after losing your device.",
  "accountRegisterButton": "Register",
  "accountLoginButton": "Log in",
  "accountLoggedInAs": "Logged in as {email}",
  "@accountLoggedInAs": {
    "placeholders": {
      "email": {"type": "String"}
    }
  },
  "accountLogoutButton": "Log out",
  "accountRestoreButton": "Restore cloud backup",
  "accountRestoreConfirmTitle": "Restore backup?",
  "accountRestoreConfirmBody": "Replaces your current local data with the cloud backup. This cannot be undone.",
  "accountRestoreNeedsPasswordTitle": "Confirm password",
  "accountRestoreNeedsPasswordBody": "Enter your password again to decrypt the cloud key.",
```

- [ ] **Step 2: l10n generieren**

```bash
flutter gen-l10n
```

- [ ] **Step 3: `AccountScreen` schreiben**

```dart
// lib/features/account/account_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/account_provider.dart';
import '../../data/sync/account_vault_service.dart';
import '../../data/sync/crypto_service.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/l10n/l10n_extension.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  Future<String?> _promptPassword(BuildContext context, AppLocalizations l) {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.accountRestoreNeedsPasswordTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.accountRestoreNeedsPasswordBody,
                style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              obscureText: true,
              decoration: InputDecoration(labelText: l.fieldLoginPassword),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l.cancelButton)),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text),
            child: Text(l.accountRestoreButton),
          ),
        ],
      ),
    );
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.accountRestoreConfirmTitle),
        content: Text(l.accountRestoreConfirmBody),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.cancelButton)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
                Text(l.deleteButton, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final password = await _promptPassword(context, l);
    if (password == null || password.isEmpty || !context.mounted) return;

    try {
      await ref
          .read(accountVaultServiceProvider)
          .restoreFromAccount(password);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.loginRestoreSuccess)));
    } on NoBackupFoundException {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.loginNoBackupFound)));
    } on WrongPasswordException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.errorMessage(e.toString()))));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.errorMessage(e.toString()))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final sessionAsync = ref.watch(authStateProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.accountSectionTitle,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            sessionAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text(l.errorMessage(e.toString())),
              data: (session) {
                if (session == null) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.accountNotLoggedInText,
                          style: const TextStyle(fontSize: 13)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => const LoginScreen())),
                              child: Text(l.accountLoginButton),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton(
                              onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => const RegisterScreen())),
                              child: Text(l.accountRegisterButton),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.accountLoggedInAs(session.user.email ?? '')),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () => _restore(context, ref),
                      icon: const Icon(Icons.cloud_download_outlined),
                      label: Text(l.accountRestoreButton),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () =>
                          ref.read(accountVaultServiceProvider).signOut(),
                      child: Text(l.accountLogoutButton),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: In `SupabaseSyncScreen` einbinden**

In `lib/features/settings/supabase_sync_screen.dart` Import ergaenzen:

```dart
import '../account/account_screen.dart';
```

und in der `ListView` von `build()` direkt vor dem bestehenden `Card(color: primaryContainer, ...)`-Widget (dem allerersten Kind) ergaenzen:

```dart
                const AccountScreen(),
                const SizedBox(height: 20),
```

- [ ] **Step 5: Analyse**

```bash
flutter analyze lib/features/account/account_screen.dart lib/features/settings/supabase_sync_screen.dart
```
Erwartet: `No issues found!`

- [ ] **Step 6: Commit**

```bash
git add lib/features/account/account_screen.dart lib/features/settings/supabase_sync_screen.dart lib/l10n/app_de.arb lib/l10n/app_en.arb lib/l10n/app_localizations*.dart
git commit -m "Add AccountScreen and wire it into the Cloud-Sync settings screen"
```

---

### Task 12: Onboarding-Einstieg ("Schon ein Konto?")

**Files:**
- Modify: `lib/features/onboarding/onboarding_screen.dart`
- Modify: `lib/l10n/app_de.arb`
- Modify: `lib/l10n/app_en.arb`

**Interfaces:**
- Consumes: `LoginScreen(autoRestoreOnSuccess: true)` (Task 9).
- Produces: Link auf der Namens-Seite des Onboardings, der direkt in den Recovery-Login fuehrt und danach das Onboarding abschliesst.

- [ ] **Step 1: l10n-String ergaenzen**

In `lib/l10n/app_de.arb`:

```json
  "onboardingHaveAccountLink": "Schon ein Pacto-Konto? Daten wiederherstellen",
```

In `lib/l10n/app_en.arb`:

```json
  "onboardingHaveAccountLink": "Already have a Pacto account? Restore your data",
```

- [ ] **Step 2: l10n generieren**

```bash
flutter gen-l10n
```

- [ ] **Step 3: Onboarding-Screen anpassen**

`OnboardingScreen` ist aktuell ein `StatelessWidget`-artiges `ConsumerWidget`-freies
Widget ohne Riverpod — `LoginScreen` braucht aber `WidgetRef`, das ist unproblematisch,
da `LoginScreen` selbst ein `ConsumerStatefulWidget` ist und ueber `Navigator.push` als
eigene Route geoeffnet wird (kein `ref` im Onboarding-Screen selbst noetig).

In `lib/features/onboarding/onboarding_screen.dart`:
- Import ergaenzen: `import '../account/login_screen.dart';`
- In `_namePage(...)`, direkt vor dem letzten `TextButton` (`onboardingNameSkip`)
  ergaenzen:

```dart
          TextButton(
            onPressed: () async {
              final restored = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) =>
                      const LoginScreen(autoRestoreOnSuccess: true),
                ),
              );
              if (restored == true) {
                _finish(name: _nameCtrl.text.isNotEmpty ? _nameCtrl.text : null);
              }
            },
            child: Text(l.onboardingHaveAccountLink),
          ),
```

(direkt oberhalb der bestehenden `TextButton(onPressed: () => _finish(), child: Text(l.onboardingNameSkip))`-Zeile einfuegen, sodass beide Links untereinander stehen).

- [ ] **Step 4: Analyse**

```bash
flutter analyze lib/features/onboarding/onboarding_screen.dart
```
Erwartet: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add lib/features/onboarding/onboarding_screen.dart lib/l10n/app_de.arb lib/l10n/app_en.arb lib/l10n/app_localizations*.dart
git commit -m "Add onboarding entry point for account-based data recovery"
```

---

### Task 13: Manueller QA-Durchlauf

**Files:**
- Keine Code-Aenderungen — reine Verifikation auf einem echten Geraet gegen das
  Live-Supabase-Projekt, analog zum bestehenden Vorgehen in `BETA_TESTING.md`.

- [ ] **Step 1: Build & Installation**

```bash
flutter build apk --debug
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

- [ ] **Step 2: Signup + Bestaetigung**

Registrieren (Settings → Konto → Registrieren) mit einer echten, erreichbaren Test-
E-Mail-Adresse. Bestaetigungsmail abwarten, Link anklicken.

- [ ] **Step 3: Login + automatischer Erst-Push**

In der App einloggen. Erwartet: kein Fehler, `account_vaults`-Tabelle im Supabase-
Dashboard zeigt eine neue Zeile fuer den Nutzer mit nicht-leerem `encrypted_payload`.

- [ ] **Step 4: Restore auf "Zweitgeraet" simulieren**

App-Daten loeschen (`adb shell pm clear com.softbrewstudio.pacto`) oder neu
installieren. Onboarding durchlaufen bis zur Namens-Seite → "Schon ein Pacto-Konto?"
antippen → einloggen. Erwartet: Contracts/Heirs aus Schritt 2/3 erscheinen im
Dashboard, kein Datenverlust.

- [ ] **Step 5: Passwort aendern**

Eingeloggt in Settings → Passwort aendern (ueber Supabase-Auth-Flow, sofern eine
UI dafuer existiert, sonst per `auth.updateUser` testen) → erneut ausloggen/einloggen
mit neuem Passwort → Restore erneut ausloesen. Erwartet: Restore funktioniert weiterhin.

- [ ] **Step 6: Passwort vergessen**

"Passwort vergessen?" auf dem Login-Screen → Code aus Mail eingeben → neues Passwort
setzen. Erwartet: Login mit neuem Passwort funktioniert danach.

- [ ] **Step 7: Restore ohne Backup**

Neues, frisches Konto registrieren, das noch nie synchronisiert hat, dann in den
Einstellungen "Cloud-Backup wiederherstellen" antippen. Erwartet: verstaendliche
Meldung "Noch kein Backup vorhanden", kein Absturz.

- [ ] **Step 8: Anonymer Pfad unveraendert**

Ohne jemals ein Konto anzulegen: Cloud-Sync in den Einstellungen aktivieren, "Jetzt
synchronisieren" antippen. Erwartet: funktioniert exakt wie vor diesem Feature (schreibt
weiterhin nach `sync_data`, nicht nach `account_vaults`).
