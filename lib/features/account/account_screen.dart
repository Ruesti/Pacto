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
