class DhikrModel {
  final String text;
  final String? virtue;
  final String source;
  final String bookSource;
  final int count;
  final String title;
  final DhikrCategory category;
  // ترجمات اختيارية (تُعرض عند توفرها فقط) — كل لغة لها نص المعنى ومصدره
  final String? textEn;
  final String? sourceEn;
  final String? textId;
  final String? sourceId;
  final String? textUr;
  final String? sourceUr;

  const DhikrModel({
    required this.text,
    required this.source,
    required this.bookSource,
    required this.title,
    required this.category,
    this.virtue,
    this.count = 1,
    this.textEn,
    this.sourceEn,
    this.textId,
    this.sourceId,
    this.textUr,
    this.sourceUr,
  });

  /// معرّف ثابت للذكر (فئة + عنوان) يُستخدم في المفضلة والتخزين المحلي.
  /// لا يعتمد على ترتيب العناصر في القائمة حتى لا يتغير عند إضافة أذكار جديدة.
  String get id => '${category.name}__$title';
}

enum DhikrCategory {
  morning, evening, sleep, wakeup, prayer,
  afterPrayer, mosque, food, travel, quran, names, misc, ruqyah, nawawi40,
  dailySunnah, fridaySunnah, prophetsDua,
}

extension DhikrCategoryExtension on DhikrCategory {
  String get arabicName {
    switch (this) {
      case DhikrCategory.morning: return 'أذكار الصباح';
      case DhikrCategory.evening: return 'أذكار المساء';
      case DhikrCategory.sleep: return 'أذكار النوم';
      case DhikrCategory.wakeup: return 'أذكار الاستيقاظ';
      case DhikrCategory.prayer: return 'أذكار الصلاة';
      case DhikrCategory.afterPrayer: return 'أذكار بعد الصلاة';
      case DhikrCategory.mosque: return 'أذكار المسجد';
      case DhikrCategory.food: return 'أذكار الطعام';
      case DhikrCategory.travel: return 'أذكار السفر';
      case DhikrCategory.quran: return 'أدعية قرآنية';
      case DhikrCategory.names: return 'أسماء الله الحسنى';
      case DhikrCategory.misc: return 'أذكار متفرقة';
      case DhikrCategory.ruqyah: return 'الرقية الشرعية';
      case DhikrCategory.nawawi40: return 'الأربعون النووية';
      case DhikrCategory.dailySunnah: return 'سنن النبي ﷺ اليومية';
      case DhikrCategory.fridaySunnah: return 'سنن يوم الجمعة';
      case DhikrCategory.prophetsDua: return 'أدعية الأنبياء';
    }
  }

  String get icon {
    switch (this) {
      case DhikrCategory.morning: return '🌅';
      case DhikrCategory.evening: return '🌙';
      case DhikrCategory.sleep: return '😴';
      case DhikrCategory.wakeup: return '☀️';
      case DhikrCategory.prayer: return '🕌';
      case DhikrCategory.afterPrayer: return '📿';
      case DhikrCategory.mosque: return '🕋';
      case DhikrCategory.food: return '🍽️';
      case DhikrCategory.travel: return '✈️';
      case DhikrCategory.quran: return '📖';
      case DhikrCategory.names: return '✨';
      case DhikrCategory.misc: return '🤲';
      case DhikrCategory.ruqyah: return '🛡️';
      case DhikrCategory.nawawi40: return '📜';
      case DhikrCategory.dailySunnah: return '🌿';
      case DhikrCategory.fridaySunnah: return '📅';
      case DhikrCategory.prophetsDua: return '🌟';
    }
  }
}
