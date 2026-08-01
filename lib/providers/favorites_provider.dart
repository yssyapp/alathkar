import 'package:flutter/material.dart';
import '../data/athkar_data.dart';
import '../models/dhikr_model.dart';
import '../repositories/favorites_repository.dart';

/// يدير قائمة الأذكار المفضّلة، ويحفظها الآن في قاعدة بيانات SQLite حقيقية
/// عبر [FavoritesRepository] بدل shared_preferences مباشرة — هذه الفئة لا
/// تعرف تفاصيل التخزين إطلاقاً، فقط تدير حالة الواجهة (Set في الذاكرة
/// لسرعة isFavorite) وتستدعي طبقة الوصول للبيانات عند أي تغيير.
class FavoritesProvider extends ChangeNotifier {
  static const FavoritesRepository _repository = FavoritesRepository();

  final Set<String> _favoriteIds = {};

  FavoritesProvider() {
    _loadFromDatabase();
  }

  Future<void> _loadFromDatabase() async {
    final saved = await _repository.loadAll();
    _favoriteIds
      ..clear()
      ..addAll(saved);
    notifyListeners();
  }

  bool isFavorite(DhikrModel dhikr) => _favoriteIds.contains(dhikr.id);

  Future<void> toggleFavorite(DhikrModel dhikr) async {
    if (_favoriteIds.contains(dhikr.id)) {
      _favoriteIds.remove(dhikr.id);
      notifyListeners();
      await _repository.remove(dhikr.id);
    } else {
      _favoriteIds.add(dhikr.id);
      notifyListeners();
      await _repository.add(dhikr.id);
    }
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
