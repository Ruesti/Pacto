import 'package:intl/intl.dart';

final _dateFormat = DateFormat('dd.MM.yyyy', 'de_DE');
final _monthYear = DateFormat('MMMM yyyy', 'de_DE');

String formatDate(DateTime? date) =>
    date == null ? '–' : _dateFormat.format(date);

String formatMonthYear(DateTime? date) =>
    date == null ? '–' : _monthYear.format(date);

String daysUntil(DateTime? date) {
  if (date == null) return '–';
  final diff = date.difference(DateTime.now()).inDays;
  if (diff < 0) return 'abgelaufen';
  if (diff == 0) return 'heute';
  if (diff == 1) return 'morgen';
  return 'in $diff Tagen';
}
