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
