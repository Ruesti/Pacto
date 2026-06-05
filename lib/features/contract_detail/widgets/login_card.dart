import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/database.dart';
import '../../../data/providers/database_provider.dart';
import '../../../data/providers/verification_settings_provider.dart';
import '../../../data/security/password_strength.dart';
import '../../../features/security/app_lock_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/l10n/l10n_extension.dart';
import '../../../shared/theme/app_colors.dart';

/// Anzeigt Login-Daten zu einem Vertrag in der Detail-Ansicht.
/// Username wird im Klartext gerendert. Das Passwort bleibt zunaechst
/// verborgen — der User klickt das Augen-Icon, dann wird per
/// CryptoService entschluesselt und in den Speicher geholt. Beim Schliessen
/// (oder Widget-Dispose) wird der Klartext aktiv ueberschrieben.
class LoginCard extends ConsumerStatefulWidget {
  final Contract contract;

  const LoginCard({super.key, required this.contract});

  @override
  ConsumerState<LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends ConsumerState<LoginCard> {
  String? _plainPassword;
  bool _busy = false;
  String? _revealError;
  // Datenleck-Pruefung: null = noch nicht geprueft, -2 = laeuft, -1 = Fehler,
  // >=0 = Trefferzahl.
  int? _breachState;

  @override
  void dispose() {
    _plainPassword = null;
    super.dispose();
  }

  Future<void> _markVerifiedNow() async {
    await ref.read(contractsDaoProvider).markVerified(widget.contract.id);
    // Der Detail-Screen watcht den Vertrags-Stream → Karte baut sich mit
    // frischem loginLastVerifiedAt neu auf.
  }

  Future<void> _runBreachCheck() async {
    final ct = widget.contract.loginPasswordCt;
    if (ct == null) return;
    // Wenn wir den Klartext erst entschluesseln muessen, gilt derselbe Guard
    // wie beim Aufdecken.
    if (_plainPassword == null && !await _passRevealGuard()) return;
    setState(() => _breachState = -2);
    try {
      final plain =
          _plainPassword ?? await ref.read(cryptoServiceProvider).decryptString(ct);
      final count =
          await ref.read(breachCheckServiceProvider).pwnedCount(plain);
      if (!mounted) return;
      setState(() => _breachState = count);
    } catch (_) {
      if (!mounted) return;
      setState(() => _breachState = -1);
    }
  }

  /// Wenn App-Sperre + "beim Aufdecken erneut prüfen" aktiv sind, vor dem
  /// Entschluesseln Biometrie/PIN verlangen.
  Future<bool> _passRevealGuard() async {
    final svc = ref.read(appLockServiceProvider);
    if (!await svc.isEnabled() || !await svc.isBiometricRevealEnabled()) {
      return true;
    }
    if (!await svc.canUseBiometrics()) return true;
    if (!mounted) return false;
    return svc.authenticateBiometric(context.l10n.revealReason);
  }

  Future<void> _toggleReveal() async {
    if (_plainPassword != null) {
      setState(() {
        _plainPassword = null;
        _revealError = null;
      });
      return;
    }
    final ct = widget.contract.loginPasswordCt;
    if (ct == null) return;
    if (!await _passRevealGuard()) return;
    setState(() {
      _busy = true;
      _revealError = null;
    });
    try {
      final plain = await ref.read(cryptoServiceProvider).decryptString(ct);
      if (!mounted) return;
      setState(() => _plainPassword = plain);
    } catch (_) {
      if (!mounted) return;
      setState(() => _revealError = context.l10n.loginRevealError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _copyToClipboard(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.loginCopied)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = widget.contract;
    final settings = ref.watch(verificationSettingsProvider).valueOrNull ??
        const VerificationSettings();
    final hasUsername = (c.loginUsername ?? '').isNotEmpty;
    final hasPassword = c.loginPasswordCt != null;
    final hasHint = (c.loginHint ?? '').isNotEmpty;
    final lastVerified = c.loginLastVerifiedAt;
    final staleDays = settings.manualReminderEnabled
        ? settings.staleThresholdDays
        : 180;
    final isStale = lastVerified != null &&
        DateTime.now().difference(lastVerified).inDays > staleDays;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.key_outlined,
                    size: 18, color: AppColors.statusBlue),
                const SizedBox(width: 8),
                Text(l.loginCardTitle,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
            const SizedBox(height: 12),
            if (hasUsername)
              _row(
                icon: Icons.person_outline,
                value: c.loginUsername!,
                onCopy: () => _copyToClipboard(c.loginUsername!),
              ),
            if (hasPassword) ...[
              if (hasUsername) const SizedBox(height: 6),
              _passwordRow(l),
              if (_revealError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(_revealError!,
                      style: const TextStyle(
                          color: AppColors.statusRed, fontSize: 12)),
                ),
              if (settings.strengthCheckEnabled && _plainPassword != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _strengthBar(l, _plainPassword!),
                ),
              if (settings.breachCheckEnabled) ...[
                const SizedBox(height: 4),
                _breachRow(l),
              ],
            ],
            if (lastVerified != null) ...[
              const SizedBox(height: 8),
              Text(
                l.loginLastVerifiedRecent(_formatDate(lastVerified)),
                style: TextStyle(
                  fontSize: 12,
                  color: isStale
                      ? AppColors.statusAmber
                      : AppColors.textTertiary,
                ),
              ),
              if (isStale)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(l.loginStaleWarning,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.statusAmber)),
                ),
            ],
            if (settings.manualReminderEnabled &&
                (hasPassword || hasUsername || hasHint)) ...[
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _markVerifiedNow,
                  icon: const Icon(Icons.check, size: 16),
                  label: Text(l.loginConfirmNowButton,
                      style: const TextStyle(fontSize: 12)),
                ),
              ),
            ],
            if (hasHint) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline,
                      size: 16, color: AppColors.textTertiary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(c.loginHint!,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textSecondary)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _passwordRow(AppLocalizations l) {
    final displayed = _plainPassword ?? '••••••••';
    return Row(
      children: [
        const Icon(Icons.lock_outline, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            displayed,
            style: TextStyle(
              fontSize: 14,
              letterSpacing: _plainPassword == null ? 2 : null,
              fontFamily:
                  _plainPassword != null ? 'monospace' : null,
            ),
          ),
        ),
        if (_busy)
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else ...[
          IconButton(
            icon: Icon(_plainPassword == null
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined),
            tooltip: l.loginPasswordStored,
            visualDensity: VisualDensity.compact,
            onPressed: _toggleReveal,
          ),
          if (_plainPassword != null)
            IconButton(
              icon: const Icon(Icons.copy_outlined),
              visualDensity: VisualDensity.compact,
              onPressed: () => _copyToClipboard(_plainPassword!),
            ),
        ],
      ],
    );
  }

  Widget _strengthBar(AppLocalizations l, String password) {
    final strength = assessPasswordStrength(password);
    final (color, label, fraction) = switch (strength) {
      PasswordStrength.weak => (AppColors.statusRed, l.strengthWeak, 0.33),
      PasswordStrength.medium =>
        (AppColors.statusAmber, l.strengthMedium, 0.66),
      PasswordStrength.strong =>
        (AppColors.statusGreen, l.strengthStrong, 1.0),
    };
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 4,
              backgroundColor: AppColors.surfaceBorder,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('${l.strengthLabel}: $label',
            style: TextStyle(fontSize: 11, color: color)),
      ],
    );
  }

  Widget _breachRow(AppLocalizations l) {
    if (_breachState == -2) {
      return Row(
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Text(l.breachChecking,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textTertiary)),
        ],
      );
    }
    if (_breachState == null) {
      return Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: _runBreachCheck,
          icon: const Icon(Icons.shield_outlined, size: 16),
          label: Text(l.breachCheckButton,
              style: const TextStyle(fontSize: 12)),
        ),
      );
    }
    final (icon, color, text) = switch (_breachState!) {
      -1 => (Icons.error_outline, AppColors.statusAmber, l.breachError),
      0 => (Icons.verified_user_outlined, AppColors.statusGreen, l.breachClean),
      final n => (Icons.warning_amber_outlined, AppColors.statusRed,
          l.breachFound(n)),
    };
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text,
                style: TextStyle(fontSize: 12, color: color)),
          ),
        ],
      ),
    );
  }

  Widget _row({
    required IconData icon,
    required String value,
    required VoidCallback onCopy,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        IconButton(
          icon: const Icon(Icons.copy_outlined),
          visualDensity: VisualDensity.compact,
          onPressed: onCopy,
        ),
      ],
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}
