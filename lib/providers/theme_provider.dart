import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../repositories/settings_repository.dart';

/// يتحكم بالتبديل بين الوضع الداكن (الافتراضي) والوضع الفاتح، وباللون
/// الثانوي (accent) الذي يختاره المستخدم من الإعدادات — الأخضر يبقى دائماً
/// اللون الرئيسي الثابت للتطبيق ولا يتأثر بهذا الاختيار. يحفظ كل ذلك الآن
/// عبر [SettingsRepository] (قاعدة بيانات SQLite) بدل shared_preferences
/// مباشرة — نفس أسماء المفاتيح القديمة محفوظة للتوافق مع النقل التلقائي.
class ThemeProvider extends ChangeNotifier {
  static const SettingsRepository _repository = SettingsRepository();
  static const String _prefKey = 'isDarkMode';
  static const String _accentPrefKey = 'accentIndex';

  bool _isDark = true;
  bool get isDark => _isDark;

  int get accentIndex => AppTheme.accentIndex;

  ThemeProvider() {
    _loadFromDatabase();
  }

  Future<void> _loadFromDatabase() async {
    _isDark = await _repository.getBool(_prefKey) ?? true;
    final savedAccent = await _repository.getInt(_accentPrefKey);
    if (savedAccent != null) {
      AppTheme.setAccent(savedAccent);
    }
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDark = !_isDark;
    notifyListeners();
    await _repository.setBool(_prefKey, _isDark);
  }

  Future<void> setAccent(int index) async {
    AppTheme.setAccent(index);
    notifyListeners();
    await _repository.setInt(_accentPrefKey, index);
  }
}
