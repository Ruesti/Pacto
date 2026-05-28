import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/database.dart';
import '../../../data/providers/database_provider.dart';
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

  @override
  void dispose() {
    _plainPassword = null;
    super.dispose();
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
    final hasUsername = (c.loginUsername ?? '').isNotEmpty;
    final hasPassword = c.loginPasswordCt != null;
    final hasHint = (c.loginHint ?? '').isNotEmpty;
    final lastVerified = c.loginLastVerifiedAt;
    final isStale = lastVerified != null &&
        DateTime.now().difference(lastVerified).inDays > 180;

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
