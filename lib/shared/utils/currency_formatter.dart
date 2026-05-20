import 'package:intl/intl.dart';

final _euroFormat = NumberFormat.currency(locale: 'de_DE', symbol: '€');

String formatCurrency(double amount) => _euroFormat.format(amount);

String formatMonthlyCost(double monthlyCost) =>
    '${_euroFormat.format(monthlyCost)}/Monat';
