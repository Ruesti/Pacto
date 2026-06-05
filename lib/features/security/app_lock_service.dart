import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

/// App-Sperre: Biometrie (Face/Touch ID, Fingerabdruck) mit PIN-Fallback.
/// Schuetzt das Oeffnen der App und optional das Aufdecken gespeicherter
/// Passwoerter. PIN wird nur als gesalzener SHA-256-Hash in secure storage
/// abgelegt — nie im Klartext.
class AppLockService {
  static const _kEnabled = 'pacto.lock.enabled';
  static const _kBiometricReveal = 'pacto.lock.biometric_reveal';
  static const _kPinHash = 'pacto.lock.pin_hash';
  static const _kPinSalt = 'pacto.lock.pin_salt';

  static const _secure = FlutterSecureStorage();
  final LocalAuthentication _auth = LocalAuthentication();
  static final Random _rng = Random.secure();

  Future<bool> isEnabled() async =>
      (await _secure.read(key: _kEnabled)) == 'true';

  Future<bool> isBiometricRevealEnabled() async =>
      (await _secure.read(key: _kBiometricReveal)) == 'true';

  Future<bool> hasPin() async =>
      (await _secure.read(key: _kPinHash)) != null;

  Future<void> setBiometricReveal(bool v) =>
      _secure.write(key: _kBiometricReveal, value: v ? 'true' : 'false');

  /// Aktiviert/deaktiviert die Sperre. Aktivieren ist nur sinnvoll, wenn vorher
  /// ein PIN gesetzt wurde (siehe [setPin]).
  Future<void> setEnabled(bool v) =>
      _secure.write(key: _kEnabled, value: v ? 'true' : 'false');

  Future<void> setPin(String pin) async {
    final salt = _randomBytes(16);
    final hash = _hash(pin, salt);
    await _secure.write(key: _kPinSalt, value: base64Encode(salt));
    await _secure.write(key: _kPinHash, value: hash);
  }

  Future<bool> verifyPin(String pin) async {
    final saltB64 = await _secure.read(key: _kPinSalt);
    final stored = await _secure.read(key: _kPinHash);
    if (saltB64 == null || stored == null) return false;
    return _hash(pin, base64Decode(saltB64)) == stored;
  }

  /// Komplett zuruecksetzen (z.B. beim Deaktivieren der Sperre).
  Future<void> clear() async {
    await _secure.delete(key: _kEnabled);
    await _secure.delete(key: _kBiometricReveal);
    await _secure.delete(key: _kPinHash);
    await _secure.delete(key: _kPinSalt);
  }

  /// True, wenn das Geraet Biometrie oder eine Geraete-PIN/-Sperre anbietet.
  Future<bool> canUseBiometrics() async {
    try {
      return await _auth.isDeviceSupported() &&
          await _auth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  /// Loest den Biometrie-Prompt aus. Liefert true bei Erfolg.
  Future<bool> authenticateBiometric(String reason) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }

  static Uint8List _randomBytes(int len) =>
      Uint8List.fromList(List.generate(len, (_) => _rng.nextInt(256)));

  static String _hash(String pin, List<int> salt) =>
      sha256.convert([...salt, ...utf8.encode(pin)]).toString();
}

final appLockServiceProvider =
    Provider<AppLockService>((ref) => AppLockService());

/// Zustand der App-Sperre fuer die UI (Settings + Reveal-Guard).
class AppLockState {
  final bool enabled;
  final bool biometricReveal;
  final bool hasPin;
  const AppLockState({
    this.enabled = false,
    this.biometricReveal = false,
    this.hasPin = false,
  });
}

final appLockStateProvider =
    AsyncNotifierProvider<AppLockNotifier, AppLockState>(AppLockNotifier.new);

class AppLockNotifier extends AsyncNotifier<AppLockState> {
  AppLockService get _svc => ref.read(appLockServiceProvider);

  @override
  Future<AppLockState> build() async => AppLockState(
        enabled: await _svc.isEnabled(),
        biometricReveal: await _svc.isBiometricRevealEnabled(),
        hasPin: await _svc.hasPin(),
      );

  Future<void> _refresh() async {
    state = AsyncData(AppLockState(
      enabled: await _svc.isEnabled(),
      biometricReveal: await _svc.isBiometricRevealEnabled(),
      hasPin: await _svc.hasPin(),
    ));
  }

  /// Setzt einen (neuen) PIN und aktiviert die Sperre.
  Future<void> enableWithPin(String pin) async {
    await _svc.setPin(pin);
    await _svc.setEnabled(true);
    await _refresh();
  }

  Future<void> changePin(String pin) async {
    await _svc.setPin(pin);
    await _refresh();
  }

  Future<void> disable() async {
    await _svc.clear();
    await _refresh();
  }

  Future<void> setBiometricReveal(bool v) async {
    await _svc.setBiometricReveal(v);
    await _refresh();
  }
}
