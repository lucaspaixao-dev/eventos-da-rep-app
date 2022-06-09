import 'package:intl/intl.dart';

String formatDate(DateTime dateTime) {
  final DateFormat formatter = DateFormat('dd/MM/yyyy');
  final String formatted = formatter.format(dateTime);
  return formatted;
}

String formatTime(DateTime dateTime) {
  final DateFormat formatter = DateFormat('HH:mm');
  final String formatted = formatter.format(dateTime);
  return formatted;
}
