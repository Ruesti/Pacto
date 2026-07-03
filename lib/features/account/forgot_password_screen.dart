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
