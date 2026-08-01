import 'package:flutter/foundation.dart';
import '../models/dhikr_model.dart';
import '../repositories/azkar_repository.dart';

/// إدارة حالة البحث عبر Provider بدل setState محلي داخل الشاشة — يقلّل
/// إعادة بناء الواجهة (تُعاد بناء الأجزاء المستمعة للنتائج فقط)، ويجعل
/// نتائج البحث قابلة للوصول من أي مكان بالتطبيق مستقبلاً بدون تمريرها
/// يدوياً بين الشاشات. الاستمرار على حزمة Provider نفسها (لا Riverpod ولا
/// Bloc) لأن المشروع يستخدمها أصلاً في كل مكان (١٠ مزوّدات حالياً).
class SearchProvider extends ChangeNotifier {
  static const AzkarRepository _repository = AzkarRepository();

  String _query = '';
  List<DhikrModel> _results = const [];

  String get query => _query;
  List<DhikrModel> get results => _results;
  bool get hasQuery => _query.trim().isNotEmpty;

  void search(String query) {
    _query = query;
    _results = _repository.search(query);
    notifyListeners();
  }

  void clear() {
    _query = '';
    _results = const [];
    notifyListeners();
  }
}
