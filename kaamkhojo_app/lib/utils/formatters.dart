class Formatters {
  Formatters._();

  /// Format amount as NPR currency: "रू 1,500"
  static String formatNPR(double amount) {
    if (amount >= 100000) {
      return 'रू ${(amount / 100000).toStringAsFixed(1)} लाख';
    }
    if (amount >= 1000) {
      final parts = amount.toStringAsFixed(0).split('');
      final reversed = parts.reversed.toList();
      final withCommas = <String>[];
      for (var i = 0; i < reversed.length; i++) {
        if (i > 0 && i % 3 == 0) withCommas.add(',');
        withCommas.add(reversed[i]);
      }
      return 'रू ${withCommas.reversed.join()}';
    }
    return 'रू ${amount.toStringAsFixed(0)}';
  }

  /// Format distance: "2.5 km" or "500 m"
  static String formatDistance(double? km) {
    if (km == null) return '';
    if (km < 1) return '${(km * 1000).toStringAsFixed(0)} m';
    return '${km.toStringAsFixed(1)} km';
  }

  /// Format Nepal phone number for display: "98XX-XXXXXX"
  static String formatPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    final local = digits.startsWith('977') ? digits.substring(3) : digits;
    if (local.length == 10) {
      return '${local.substring(0, 4)}-${local.substring(4)}';
    }
    return phone;
  }

  /// Normalize phone number to +977XXXXXXXXXX
  static String normalizePhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('977')) return '+$digits';
    if (digits.startsWith('0')) return '+977${digits.substring(1)}';
    return '+977$digits';
  }

  /// Truncate text with ellipsis
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
