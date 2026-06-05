import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/l10n/l10n_extension.dart';
import '../../shared/theme/app_colors.dart';
import 'app_lock_service.dart';

/// Sperrbildschirm beim App-Start (und nach Rueckkehr aus dem Hintergrund).
/// Versucht zuerst Biometrie, faellt auf PIN-Eingabe zurueck.
class LockScreen extends ConsumerStatefulWidget {
  final VoidCallback onUnlocked;

  const LockScreen({super.key, required this.onUnlocked});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  final _pinCtrl = TextEditingController();
  bool _error = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryBiometric());
  }

  @override
  void dispose() {
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _tryBiometric() async {
    final svc = ref.read(appLockServiceProvider);
    if (!await svc.canUseBiometrics()) return;
    if (!mounted) return;
    final ok = await svc.authenticateBiometric(context.l10n.lockReason);
    if (ok && mounted) widget.onUnlocked();
  }

  Future<void> _submitPin() async {
    setState(() {
      _busy = true;
      _error = false;
    });
    final ok = await ref.read(appLockServiceProvider).verifyPin(_pinCtrl.text);
    if (!mounted) return;
    if (ok) {
      widget.onUnlocked();
    } else {
      setState(() {
        _busy = false;
        _error = true;
        _pinCtrl.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline,
                    size: 56, color: AppColors.primary),
                const SizedBox(height: 16),
                Text(l.lockScreenTitle,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w600)),
                const SizedBox(height: 32),
                TextField(
                  controller: _pinCtrl,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: l.appLockPinPrompt,
                    errorText: _error ? l.lockWrongPin : null,
                  ),
                  onSubmitted: (_) => _submitPin(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _busy ? null : _submitPin,
                    child: _busy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(l.lockUnlockButton),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: _tryBiometric,
                  icon: const Icon(Icons.fingerprint),
                  label: Text(l.lockUseBiometrics),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
