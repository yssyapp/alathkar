import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// يتحكم بالتبديل بين الوضع الداكن (الافتراضي) والوضع الفاتح،
/// ويحفظ اختيار المستخدم محلياً بحيث يبقى بعد إغلاق التطبيق.
class ThemeProvider extends ChangeNotifier {
  static const String _prefKey = 'isDarkMode';

  bool _isDark = true;
  bool get isDark => _isDark;

  ThemeProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool(_prefKey) ?? true;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDark = !_isDark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, _isDark);
  }
}
