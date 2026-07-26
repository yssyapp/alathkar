import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// يتحكم بترتيب "الأدوات" المعروضة في الشاشة الرئيسية (مثل: القبلة،
/// المفضلة، الأذكار، البحث...) ويحفظ الترتيب الذي يختاره المستخدم محلياً،
/// بنفس نمط ThemeProvider/LanguageProvider الموجود مسبقاً في المشروع.
///
/// ملاحظة: هذا الملف كان مفقوداً من المشروع (مرجّع في main.dart لكن غير
/// موجود فعلياً على القرص)، مما كان يمنع التطبيق من البناء بالكامل. أُعيد
/// إنشاؤه هنا بأقل تطبيق ممكن وآمن — قائمة معرّفات نصية قابلة لإعادة الترتيب
/// - حتى لا يكسر أي كود موجود يعتمد على وجود هذا المزوّد، ويبقى قابلاً
/// للتوسعة لاحقاً حسب الأدوات الفعلية في الشاشة الرئيسية.
class ToolsOrderProvider extends ChangeNotifier {
  static const String _prefKey = 'toolsOrder';

  /// الترتيب الافتراضي لو المستخدم ما غيّر شيء بعد.
  static const List<String> defaultOrder = [
    'qibla',
    'favorites',
    'athkar',
    'search',
    'habits',
    'stats',
  ];

  List<String> _order = List.of(defaultOrder);
  List<String> get order => List.unmodifiable(_order);

  ToolsOrderProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_prefKey);
    if (saved != null && saved.isNotEmpty) {
      _order = saved;
      notifyListeners();
    }
  }

  Future<void> setOrder(List<String> newOrder) async {
    _order = List.of(newOrder);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefKey, _order);
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final updated = List.of(_order);
    if (oldIndex < newIndex) newIndex -= 1;
    final item = updated.removeAt(oldIndex);
    updated.insert(newIndex, item);
    await setOrder(updated);
  }

  Future<void> resetToDefault() async {
    await setOrder(defaultOrder);
  }
}
