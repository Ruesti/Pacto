import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../security/breach_check_service.dart';

/// Welche (optionalen) Pruef-Features fuer gespeicherte Logins aktiv sind.
/// Alle standardmaessig AUS — Datensparsamkeit, kein Aktualisierungsdruck.
class VerificationSettings {
  /// Erinnert daran, gespeicherte Logins regelmaessig zu bestaetigen.
  final bool manualReminderEnabled;

  /// Nach wie vielen Monaten ohne Bestaetigung ein Login als "ueberfaellig"
  /// gilt.
  final int reminderMonths;

  /// Datenleck-Pruefung via HaveIBeenPwned (k-Anonymity).
  final bool breachCheckEnabled;

  /// Lokale Passwort-Staerke-Anzeige.
  final bool strengthCheckEnabled;

  const VerificationSettings({
    this.manualReminderEnabled = false,
    this.reminderMonths = 6,
    this.breachCheckEnabled = false,
    this.strengthCheckEnabled = false,
  });

  VerificationSettings copyWith({
    bool? manualReminderEnabled,
    int? reminderMonths,
    bool? breachCheckEnabled,
    bool? strengthCheckEnabled,
  }) =>
      VerificationSettings(
        manualReminderEnabled:
            manualReminderEnabled ?? this.manualReminderEnabled,
        reminderMonths: reminderMonths ?? this.reminderMonths,
        breachCheckEnabled: breachCheckEnabled ?? this.breachCheckEnabled,
        strengthCheckEnabled:
            strengthCheckEnabled ?? this.strengthCheckEnabled,
      );

  /// Schwelle in Tagen, ab der ein Login als ueberfaellig gilt (Monate × 30).
  int get staleThresholdDays => reminderMonths * 30;
}

const _kManualReminder = 'pacto.verify.manual_reminder';
const _kReminderMonths = 'pacto.verify.reminder_months';
const _kBreachCheck = 'pacto.verify.breach_check';
const _kStrengthCheck = 'pacto.verify.strength_check';

Future<VerificationSettings> getVerificationSettings() async {
  final prefs = await SharedPreferences.getInstance();
  return VerificationSettings(
    manualReminderEnabled: prefs.getBool(_kManualReminder) ?? false,
    reminderMonths: prefs.getInt(_kReminderMonths) ?? 6,
    breachCheckEnabled: prefs.getBool(_kBreachCheck) ?? false,
    strengthCheckEnabled: prefs.getBool(_kStrengthCheck) ?? false,
  );
}

final verificationSettingsProvider = AsyncNotifierProvider<
    VerificationSettingsNotifier, VerificationSettings>(
  VerificationSettingsNotifier.new,
);

class VerificationSettingsNotifier
    extends AsyncNotifier<VerificationSettings> {
  @override
  Future<VerificationSettings> build() => getVerificationSettings();

  Future<void> _persist(VerificationSettings next) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kManualReminder, next.manualReminderEnabled);
    await prefs.setInt(_kReminderMonths, next.reminderMonths);
    await prefs.setBool(_kBreachCheck, next.breachCheckEnabled);
    await prefs.setBool(_kStrengthCheck, next.strengthCheckEnabled);
    state = AsyncData(next);
  }

  Future<void> setManualReminder(bool v) async =>
      _persist((state.valueOrNull ?? const VerificationSettings())
          .copyWith(manualReminderEnabled: v));

  Future<void> setReminderMonths(int v) async =>
      _persist((state.valueOrNull ?? const VerificationSettings())
          .copyWith(reminderMonths: v));

  Future<void> setBreachCheck(bool v) async =>
      _persist((state.valueOrNull ?? const VerificationSettings())
          .copyWith(breachCheckEnabled: v));

  Future<void> setStrengthCheck(bool v) async =>
      _persist((state.valueOrNull ?? const VerificationSettings())
          .copyWith(strengthCheckEnabled: v));
}

final breachCheckServiceProvider =
    Provider<BreachCheckService>((ref) => BreachCheckService());
