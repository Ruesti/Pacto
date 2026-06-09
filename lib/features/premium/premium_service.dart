import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/revenuecat_config.dart';
import '../../shared/l10n/l10n_extension.dart';

const freeTierLimit = 5;

// Auf Desktop/Linux kein IAP verfügbar — SharedPreferences-Fallback.
bool get iapSupported => Platform.isAndroid || Platform.isIOS;

const _keyDesktopPurchased = 'pacto.premium.purchased';

// Lokale Tester-Freischaltung (alle Plattformen) — schaltet Premium ohne
// Store-Kauf frei. Per versteckter Geste in den Einstellungen umschaltbar.
// Nur fuer Beta/Tests gedacht.
const _keyTesterUnlock = 'pacto.premium.tester_unlock';

// ─────────────────────────────────────────────────────────────────────────────

/// Initialisiert das RevenueCat SDK. Nur auf Android/iOS aufrufen.
Future<void> initRevenueCat() async {
  if (!iapSupported) return;
  final apiKey = Platform.isAndroid
      ? RevenueCatConfig.googleApiKey
      : RevenueCatConfig.appleApiKey;
  await Purchases.setLogLevel(LogLevel.warn);
  await Purchases.configure(PurchasesConfiguration(apiKey));
}

// ─────────────────────────────────────────────────────────────────────────────

final premiumProvider =
    AsyncNotifierProvider<PremiumNotifier, bool>(PremiumNotifier.new);

class PremiumNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => _isPurchased();

  /// Löst den Kauf aus. Gibt true zurück wenn erfolgreich.
  Future<bool> purchase() async {
    state = const AsyncLoading();
    try {
      final purchased = await _doPurchase();
      state = AsyncData(purchased);
      return purchased;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  /// Stellt frühere Käufe wieder her (App Store / Play Store).
  Future<bool> restore() async {
    state = const AsyncLoading();
    try {
      final purchased = await _doRestore();
      state = AsyncData(purchased);
      return purchased;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  // Desktop-only: manuell setzen (für Test/Debug).
  Future<void> setDesktopPurchased(bool v) async {
    if (iapSupported) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDesktopPurchased, v);
    state = AsyncData(v);
  }

  /// Schaltet die lokale Tester-Freischaltung um (alle Plattformen) und gibt den
  /// neuen Zustand zurück. Versteckte Geste in den Einstellungen ruft das auf.
  Future<bool> toggleTesterUnlock() async {
    final prefs = await SharedPreferences.getInstance();
    final next = !(prefs.getBool(_keyTesterUnlock) ?? false);
    await prefs.setBool(_keyTesterUnlock, next);
    state = AsyncData(await _isPurchased());
    return next;
  }
}

// ─────────────────────────────────────────────────────────────────────────────

Future<bool> _isPurchased() async {
  // Lokale Tester-Freischaltung hat Vorrang (alle Plattformen).
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getBool(_keyTesterUnlock) ?? false) return true;
  if (!iapSupported) {
    // Desktop: lokales Flag aus SharedPreferences
    return prefs.getBool(_keyDesktopPurchased) ?? false;
  }
  try {
    final info = await Purchases.getCustomerInfo();
    return info.entitlements.active
        .containsKey(RevenueCatConfig.entitlementId);
  } catch (_) {
    return false;
  }
}

Future<bool> _doPurchase() async {
  if (!iapSupported) {
    // Desktop: direkt freischalten (Testmodus)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDesktopPurchased, true);
    return true;
  }
  final offerings = await Purchases.getOfferings();
  final pkg = offerings.current?.availablePackages.firstWhere(
    (p) => p.storeProduct.identifier == RevenueCatConfig.productId,
    orElse: () => offerings.current!.availablePackages.first,
  );
  if (pkg == null) throw Exception('Kein Angebot verfügbar');
  final result = await Purchases.purchase(PurchaseParams.package(pkg));
  return result.customerInfo.entitlements.active
      .containsKey(RevenueCatConfig.entitlementId);
}

Future<bool> _doRestore() async {
  if (!iapSupported) return false;
  final info = await Purchases.restorePurchases();
  return info.entitlements.active
      .containsKey(RevenueCatConfig.entitlementId);
}

// ─────────────────────────────────────────────────────────────────────────────

/// Zeigt den Kauf-Dialog. Gibt true zurück wenn der Kauf abgeschlossen wurde.
Future<bool> showPurchaseDialog(BuildContext context, WidgetRef ref) async {
  final l = context.l10n;
  final confirmed = await showDialog<bool>(
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
  if (confirmed != true) return false;

  final success = await ref.read(premiumProvider.notifier).purchase();
  if (!success && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.premiumPurchaseFailed)),
    );
  }
  return success;
}
