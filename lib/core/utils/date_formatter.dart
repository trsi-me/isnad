import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final DateFormat _display = DateFormat('yyyy-MM-dd HH:mm', 'ar');

  static String formatIsoOrRaw(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    try {
      final dt = DateTime.parse(iso);
      return _display.format(dt.toLocal());
    } catch (_) {
      return iso;
    }
  }

  static String nowIso() => DateTime.now().toUtc().toIso8601String();
}
