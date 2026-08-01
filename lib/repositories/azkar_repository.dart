import '../data/athkar_data.dart';
import '../models/dhikr_model.dart';

/// طبقة وصول موحّدة لبيانات الأذكار — الخطوة الأولى من خطة فصل "الخدمات"
/// عن الشاشات (إعادة هيكلة تدريجية، بدون نقل مجلدات أو كسر أي استيراد
/// حالي). حالياً تُغلّف [AthkarData] الثابتة كما هي دون تعديلها؛ لاحقاً
/// يمكن نقل منطق AthkarData بالكامل إلى هنا كخطوة تالية منفصلة.
class AzkarRepository {
  const AzkarRepository();

  List<DhikrModel> byCategory(DhikrCategory category) => AthkarData.getByCategory(category);

  /// كل الأذكار من كل الفئات مجمّعة في قائمة واحدة — تُستخدم في البحث
  /// وأي شاشة تحتاج عرضاً شاملاً بلا فلترة حسب الفئة.
  List<DhikrModel> get all => [for (final c in DhikrCategory.values) ...AthkarData.getByCategory(c)];

  /// الذكر الدوّار المعروض في الشاشة الرئيسية حسب الوقت الحالي.
  DhikrModel rotatingContent([DateTime? at]) => AthkarData.rotatingContent(at);

  /// بحث نصّي يشمل العنوان والنص والفضل بكل اللغات المتوفرة لكل ذكر —
  /// نفس منطق البحث الذي كان مكرراً داخل شاشة البحث سابقاً، أُخرج هنا
  /// حتى يصير قابلاً لإعادة الاستخدام في أي شاشة أخرى بلا تكرار.
  List<DhikrModel> search(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];
    final q = trimmed.toLowerCase();
    return all
        .where((d) =>
            d.title.contains(trimmed) ||
            d.text.contains(trimmed) ||
            (d.virtue?.contains(trimmed) ?? false) ||
            (d.textEn?.toLowerCase().contains(q) ?? false) ||
            (d.textId?.toLowerCase().contains(q) ?? false) ||
            (d.textUr?.contains(trimmed) ?? false) ||
            (d.titleEn?.toLowerCase().contains(q) ?? false) ||
            (d.titleId?.toLowerCase().contains(q) ?? false) ||
            (d.titleUr?.contains(trimmed) ?? false))
        .toList();
  }
}
