import 'package:intl/intl.dart';

class AppDateUtils {
  /// Normalize a DateTime to device local date with time set to 00:00:00.000
  static DateTime toLocalDateOnly(DateTime dateTime) {
    final local = dateTime.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  /// Format date strictly to YYYY-MM-DD for reliable key matching and streak calculation
  static String formatDateKey(DateTime dateTime) {
    final local = dateTime.toLocal();
    return '${local.year.toString().padLeft(4, '0')}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
  }

  /// Parse YYYY-MM-DD back to local DateTime
  static DateTime parseDateKey(String key) {
    final parts = key.split('-');
    if (parts.length == 3) {
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      return DateTime(year, month, day);
    }
    return DateTime.now();
  }

  /// Format to human readable (e.g. 22 Nov 2026)
  static String formatDisplay(DateTime dateTime, [String pattern = 'dd MMM yyyy', String? locale]) {
    return DateFormat(pattern, locale).format(dateTime.toLocal());
  }

  /// Format to display with time (e.g. 22 Nov 2026, 09:47)
  static String formatDateTimeDisplay(DateTime dateTime, [String? locale]) {
    return DateFormat('dd MMM yyyy, HH:mm', locale).format(dateTime.toLocal());
  }

  /// Relative date label (Today, Yesterday, or formatted date)
  static String formatRelative(DateTime dateTime, [String? locale]) {
    final today = toLocalDateOnly(DateTime.now());
    final target = toLocalDateOnly(dateTime);
    final diff = today.difference(target).inDays;

    final isId = locale == 'id';

    if (diff == 0) return isId ? 'Hari Ini' : 'Today';
    if (diff == 1) return isId ? 'Kemarin' : 'Yesterday';
    if (diff == -1) return isId ? 'Besok' : 'Tomorrow';
    if (diff > 1 && diff < 7) {
      return DateFormat('EEEE', locale).format(dateTime.toLocal());
    }
    return DateFormat('dd MMM yyyy', locale).format(dateTime.toLocal());
  }

  /// Get time greeting: Morning, Afternoon, Evening, Night
  static String getTimeGreeting([DateTime? now, String? locale]) {
    final current = (now ?? DateTime.now()).toLocal();
    final hour = current.hour;

    if (locale == 'id') {
      if (hour >= 5 && hour < 11) {
        return 'Selamat pagi';
      } else if (hour >= 11 && hour < 15) {
        return 'Selamat siang';
      } else if (hour >= 15 && hour < 18) {
        return 'Selamat sore';
      } else {
        return 'Selamat malam';
      }
    }

    if (hour >= 5 && hour < 12) {
      return 'Good morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'Good evening';
    } else {
      return 'Good night';
    }
  }

  /// Check if two dates are on the same local calendar day
  static bool isSameDay(DateTime a, DateTime b) {
    final la = a.toLocal();
    final lb = b.toLocal();
    return la.year == lb.year && la.month == lb.month && la.day == lb.day;
  }
}
