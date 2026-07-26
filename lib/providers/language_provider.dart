import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// اللغات المدعومة حالياً. الإندونيسية والأردية أُضيفتا لاحقاً زي ما طلب
/// صاحب التطبيق — الهدف إيصال الأذكار لأكبر عدد ممكن من المسلمين حول العالم.
enum AppLanguage { ar, en, id, ur }

extension AppLanguageCode on AppLanguage {
  String get code {
    switch (this) {
      case AppLanguage.ar:
        return 'ar';
      case AppLanguage.en:
        return 'en';
      case AppLanguage.id:
        return 'id';
      case AppLanguage.ur:
        return 'ur';
    }
  }

  /// اسم اللغة كما يُعرض داخل قائمة اختيار اللغة نفسها — مكتوب دائماً بلغته
  /// الأصلية (مو مترجم) حتى يتعرف عليه أي مستخدم بغض النظر عن اللغة الحالية.
  String get nativeName {
    switch (this) {
      case AppLanguage.ar:
        return 'العربية';
      case AppLanguage.en:
        return 'English';
      case AppLanguage.id:
        return 'Bahasa Indonesia';
      case AppLanguage.ur:
        return 'اردو';
    }
  }

  /// الأردية تُكتب بخط عربي وتُقرأ من اليمين لليسار مثل العربية تماماً.
  bool get isRtl => this == AppLanguage.ar || this == AppLanguage.ur;

  Locale get locale => Locale(code);
}

/// يتحكم باللغة الحالية للتطبيق ويحفظها محلياً، بنفس نمط ThemeProvider
/// الموجود مسبقاً في المشروع. يبقى التطبيق يعمل بلا إنترنت ١٠٠٪ لأن كل
/// الترجمات مُضمَّنة داخل الكود نفسه (app_strings.dart)، بدون أي تحميل
/// شبكي لملفات لغة.
class LanguageProvider extends ChangeNotifier {
  static const String _prefKey = 'appLanguage';

  AppLanguage _language = AppLanguage.ar;
  AppLanguage get language => _language;

  LanguageProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey);
    if (saved != null) {
      _language = AppLanguage.values.firstWhere(
        (l) => l.code == saved,
        orElse: () => AppLanguage.ar,
      );
      notifyListeners();
    }
  }

  Future<void> setLanguage(AppLanguage lang) async {
    if (_language == lang) return;
    _language = lang;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, lang.code);
  }
}
