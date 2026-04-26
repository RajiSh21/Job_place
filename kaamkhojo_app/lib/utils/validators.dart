class Validators {
  Validators._();

  static bool isValidNepalPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'\s|-'), '');
    return RegExp(r'^(\+977)?[9][6-9]\d{8}$').hasMatch(cleaned);
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'फोन नम्बर आवश्यक छ।';
    if (!isValidNepalPhone(value)) return 'वैध नेपाली फोन नम्बर प्रविष्ट गर्नुहोस्।\nजस्तै: 98XXXXXXXX';
    return null;
  }

  static String? validateOtp(String? value) {
    if (value == null || value.isEmpty) return 'OTP आवश्यक छ।';
    if (value.length != 6) return 'OTP ६ अंकको हुनुपर्छ।';
    if (!RegExp(r'^\d{6}$').hasMatch(value)) return 'OTP मा केवल अंक हुनुपर्छ।';
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'नाम आवश्यक छ।';
    if (value.trim().length < 2) return 'नाम कम्तिमा २ अक्षर हुनुपर्छ।';
    return null;
  }

  static String? validateRequired(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null ? '$fieldName आवश्यक छ।' : 'यो क्षेत्र आवश्यक छ।';
    }
    return null;
  }

  static String? validateNid(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Optional
    if (value.trim().length < 5) return 'मान्य NID नम्बर प्रविष्ट गर्नुहोस्।';
    return null;
  }

  static String? validateRate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final n = double.tryParse(value);
    if (n == null || n < 0) return 'मान्य मूल्य प्रविष्ट गर्नुहोस्।';
    return null;
  }

  static String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) return 'काम विवरण आवश्यक छ।';
    if (value.trim().length < 10) return 'काम विवरण कम्तिमा १० अक्षर हुनुपर्छ।';
    return null;
  }
}
