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
