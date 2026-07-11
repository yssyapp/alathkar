import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/athkar_data.dart';
import '../models/dhikr_model.dart';

/// يدير قائمة الأذكار المفضّلة ويحفظها محلياً باستخدام shared_preferences.
class FavoritesProvider extends ChangeNotifier {
  static const String _prefKey = 'favoriteDhikrIds';

  final Set<String> _favoriteIds = {};

  FavoritesProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_prefKey) ?? <String>[];
    _favoriteIds
      ..clear()
      ..addAll(saved);
    notifyListeners();
  }

  bool isFavorite(DhikrModel dhikr) => _favoriteIds.contains(dhikr.id);

  Future<void> toggleFavorite(DhikrModel dhikr) async {
    if (_favoriteIds.contains(dhikr.id)) {
      _favoriteIds.remove(dhikr.id);
    } else {
      _favoriteIds.add(dhikr.id);
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefKey, _favoriteIds.toList());
  }

  /// يرجع كل الأذكار المفضّلة من جميع الفئات، بترتيب الفئات نفسه المستخدم في الرئيسية.
  List<DhikrModel> get favoriteDhikr {
    final List<DhikrModel> result = [];
    for (final category in DhikrCategory.values) {
      final athkar = AthkarData.getByCategory(category);
      result.addAll(athkar.where((d) => _favoriteIds.contains(d.id)));
    }
    return result;
  }

  int get count => _favoriteIds.length;
}
