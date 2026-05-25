import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';

final _dateFormat = DateFormat('dd.MM.yyyy', 'de_DE');
final _monthYear = DateFormat('MMMM yyyy', 'de_DE');

String formatDate(DateTime? date) =>
    date == null ? '–' : _dateFormat.format(date);

String formatMonthYear(DateTime? date) =>
    date == null ? '–' : _monthYear.format(date);

String daysUntilL10n(DateTime? date, AppLocalizations l) {
  if (date == null) return '–';
  final diff = date.difference(DateTime.now()).inDays;
  if (diff < 0) return l.daysExpired;
  if (diff == 0) return l.daysToday;
  if (diff == 1) return l.daysTomorrow;
  return l.daysIn(diff);
}
