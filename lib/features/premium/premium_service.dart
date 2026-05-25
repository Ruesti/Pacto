import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/l10n/l10n_extension.dart';

const _keyPurchased = 'pacto.premium.purchased';
const freeTierLimit = 5;

final premiumProvider =
    StateNotifierProvider<PremiumNotifier, bool>((ref) => PremiumNotifier());

class PremiumNotifier extends StateNotifier<bool> {
  PremiumNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_keyPurchased) ?? false;
  }

  Future<void> setPurchased(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPurchased, v);
    state = v;
  }
}

Future<bool> showPurchaseDialog(BuildContext context) async {
  final l = context.l10n;
  final purchased = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l.premiumDialogTitle),
      content: Text(l.premiumDialogContent),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(l.premiumLater),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(l.premiumUnlock),
        ),
      ],
    ),
  );
  return purchased ?? false;
}
