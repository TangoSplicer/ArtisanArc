import 'package:intl/intl.dart';

class DateHelpers {
  static final DateFormat _displayFormat = DateFormat('MMM dd, yyyy');
  static final DateFormat _shortFormat = DateFormat('dd/MM/yy');
  static final DateFormat _csvFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _fullFormat = DateFormat('MMM dd, yyyy HH:mm');

  static String formatForDisplay(DateTime date) {
    return _displayFormat.format(date);
  }

  static String formatShort(DateTime date) {
    return _shortFormat.format(date);
  }

  static String formatForCsv(DateTime date) {
    return _csvFormat.format(date);
  }

  static String formatTime(DateTime date) {
    return _timeFormat.format(date);
  }

  static String formatFull(DateTime date) {
    return _fullFormat.format(date);
  }

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? '1 year ago' : '$years years ago';
    }
  }

  static bool isOverdue(DateTime dueDate) {
    return DateTime.now().isAfter(dueDate);
  }

  static bool isDueSoon(DateTime dueDate, {int daysThreshold = 7}) {
    final now = DateTime.now();
    final difference = dueDate.difference(now);
    return difference.inDays <= daysThreshold && difference.inDays >= 0;
  }

  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }
}