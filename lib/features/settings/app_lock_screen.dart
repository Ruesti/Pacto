import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/l10n/l10n_extension.dart';
import '../security/app_lock_service.dart';

/// Einstellungen der App-Sperre: aktivieren (mit PIN), PIN aendern, optional
/// Biometrie/PIN auch beim Aufdecken gespeicherter Passwoerter verlangen.
class AppLockScreen extends ConsumerWidget {
  const AppLockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final state = ref.watch(appLockStateProvider).valueOrNull ??
        const AppLockState();
    final notifier = ref.read(appLockStateProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l.appLockTitle)),
      body: ListView(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.lock_outline),
            title: Text(l.appLockEnable),
            subtitle: Text(l.appLockEnableSubtitle),
            value: state.enabled,
            onChanged: (v) async {
              if (v) {
                final pin = await _promptNewPin(context, l);
                if (pin != null) await notifier.enableWithPin(pin);
              } else {
                await notifier.disable();
              }
            },
          ),
          if (state.enabled) ...[
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.pin_outlined),
              title: Text(l.appLockChangePin),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final pin = await _promptNewPin(context, l);
                if (pin != null) await notifier.changePin(pin);
              },
            ),
            const Divider(height: 1),
            SwitchListTile(
              secondary: const Icon(Icons.visibility_outlined),
              title: Text(l.appLockBiometricReveal),
              subtitle: Text(l.appLockBiometricRevealSubtitle),
              value: state.biometricReveal,
              onChanged: notifier.setBiometricReveal,
            ),
          ],
        ],
      ),
    );
  }

  /// Zwei-Schritt-PIN-Dialog (setzen + bestaetigen). Liefert den PIN oder null
  /// bei Abbruch.
  Future<String?> _promptNewPin(
      BuildContext context, AppLocalizations l) async {
    final first = await _pinDialog(context, l, l.appLockSetPinTitle);
    if (first == null || !context.mounted) return null;
    if (first.length < 4) {
      _toast(context, l.appLockPinTooShort);
      return null;
    }
    final second = await _pinDialog(context, l, l.appLockConfirmPinTitle);
    if (second == null) return null;
    if (first != second) {
      if (context.mounted) _toast(context, l.appLockPinMismatch);
      return null;
    }
    return first;
  }

  Future<String?> _pinDialog(
      BuildContext context, AppLocalizations l, String title) {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          obscureText: true,
          autofocus: true,
          textAlign: TextAlign.center,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(labelText: l.appLockPinPrompt),
          onSubmitted: (v) => Navigator.of(ctx).pop(v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.cancelButton),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(ctrl.text),
            child: Text(l.saveButton),
          ),
        ],
      ),
    );
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}
