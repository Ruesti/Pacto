import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final purchased = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Vollzugang freischalten'),
      content: const Text(
        'Du hast die kostenlose Grenze von 5 Verträgen erreicht.\n\n'
        'Mit dem Vollzugang verwaltest du beliebig viele Verträge — '
        'einmaliger Kauf, kein Abo.\n\n'
        'Im finalen Release: ~2,99 €',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Später'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Freischalten (Test)'),
        ),
      ],
    ),
  );
  return purchased ?? false;
}
