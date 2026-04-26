import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const _key = 'locale';

  String _languageCode = 'en';
  String get languageCode => _languageCode;
  bool get isNepali => _languageCode == 'ne';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _languageCode = prefs.getString(_key) ?? 'en';
    notifyListeners();
  }

  Future<void> setLocale(String code) async {
    if (_languageCode == code) return;
    _languageCode = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, code);
    notifyListeners();
  }

  Future<void> toggle() async {
    await setLocale(_languageCode == 'en' ? 'ne' : 'en');
  }
}
