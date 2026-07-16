import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme.dart';

/// يتحكم بالتبديل بين الوضع الداكن (الافتراضي) والوضع الفاتح، وباللون
/// الثانوي (accent) الذي يختاره المستخدم من الإعدادات — الأخضر يبقى دائماً
/// اللون الرئيسي الثابت للتطبيق ولا يتأثر بهذا الاختيار. يحفظ كل ذلك محلياً
/// بحيث يبقى بعد إغلاق التطبيق.
class ThemeProvider extends ChangeNotifier {
  static const String _prefKey = 'isDarkMode';
  static const String _accentPrefKey = 'accentIndex';

  bool _isDark = true;
  bool get isDark => _isDark;

  int get accentIndex => AppTheme.accentIndex;

  ThemeProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool(_prefKey) ?? true;
    final savedAccent = prefs.getInt(_accentPrefKey);
    if (savedAccent != null) {
      AppTheme.setAccent(savedAccent);
    }
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDark = !_isDark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, _isDark);
  }

  Future<void> setAccent(int index) async {
    AppTheme.setAccent(index);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_accentPrefKey, index);
  }
}
