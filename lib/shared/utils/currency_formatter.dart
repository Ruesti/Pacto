import 'package:intl/intl.dart';

import '../../domain/models/billing_cycle.dart';

final _euroFormat = NumberFormat.currency(locale: 'de_DE', symbol: '€');

String formatCurrency(double amount) => _euroFormat.format(amount);

String formatMonthlyCost(double monthlyCost) =>
    '${_euroFormat.format(monthlyCost)}/Monat';

/// Formatiert den Betrag "wie gezahlt" (pro Abrechnungsintervall), also den
/// gespeicherten Monatsbetrag zurueckgerechnet auf den Zyklus. Ohne Suffix —
/// das Zyklus-Label haengt der Aufrufer lokalisiert an.
String formatBilledAmount(double monthlyCost, BillingCycle cycle) =>
    _euroFormat.format(cycle.billedFrom(monthlyCost));
