import 'package:intl/intl.dart';

class DateHelpers {
  DateHelpers._();

  static String formatDate(DateTime date, {bool nepaliScript = false}) {
    if (nepaliScript) {
      return '${date.year}-${_pad(date.month)}-${_pad(date.day)}';
    }
    return DateFormat('MMM d, yyyy').format(date);
  }

  static String formatTime(String time24) {
    final parts = time24.split(':');
    if (parts.length < 2) return time24;
    final hour = int.parse(parts[0]);
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$displayHour:$minute $period';
  }

  static String formatDateTime(DateTime dt) {
    return DateFormat('MMM d, yyyy • h:mm a').format(dt);
  }

  static String formatChatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'अहिले';
    if (diff.inMinutes < 60) return '${diff.inMinutes} मिनेट अघि';
    if (diff.inHours < 24) return DateFormat('h:mm a').format(dt);
    if (diff.inDays < 7) return DateFormat('EEE h:mm a').format(dt);
    return DateFormat('MMM d').format(dt);
  }

  static String formatMessageTime(DateTime dt) {
    return DateFormat('h:mm a').format(dt);
  }

  /// Convert AD year to approximate Bikram Sambat (BS) year.
  /// Note: Full BS conversion requires a lookup table; this is an approximation.
  static int adToBsYear(int adYear) => adYear + 56;

  static String formatBsDate(DateTime adDate) {
    final bsYear = adToBsYear(adDate.year);
    return '$bsYear-${_pad(adDate.month)}-${_pad(adDate.day)} BS';
  }

  /// Returns "Jan 2024" style string for member since display
  static String formatMemberSince(DateTime dt) {
    return DateFormat('MMMM yyyy').format(dt);
  }

  static String _pad(int n) => n.toString().padLeft(2, '0');

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  static bool isFuture(DateTime date) => date.isAfter(DateTime.now());

  static List<DateTime> getNextDays(int count) {
    return List.generate(count, (i) => DateTime.now().add(Duration(days: i)));
  }
}
