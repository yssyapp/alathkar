import '../providers/language_provider.dart';

class DhikrModel {
  final String text;
  final String? virtue;
  final String source;
  final String bookSource;
  final int count;
  final String title;
  final DhikrCategory category;

  // الحقول التالية اختيارية بالكامل — تُضاف تدريجياً لكل ذكر بعد ترجمته من
  // مصدر معتمد (راجع athkar_localization_plan.md). أي ذكر ما زال بدون
  // ترجمة يستمر يعرض نصه العربي بشكل طبيعي (fallback في DhikrModel.textFor
  // وما شابه)، فلا شيء ينكسر أثناء إضافة الترجمات دفعة دفعة.
  final String? textEn;
  final String? sourceEn;
  final String? textId;
  final String? sourceId;
  final String? textUr;
  final String? sourceUr;

  /// علامة على أن هذا الذكر آية قرآنية حرفية (وليس دعاءً أو حديثاً). النص
  /// القرآني نفسه لا يُترجم أبداً ويبقى عربياً دائماً بكل اللغات — الترجمة
  /// تُعرض فقط كـ"معنى/تفسير مبسّط" منفصل تحت النص، لا كبديل عنه.
  final bool isQuran;
  final String? meaningEn;
  final String? meaningId;
  final String? meaningUr;

  // ترجمة عنوان الذكر (تسمية فقط، وليست ترجمة نص شرعي) — آمنة ومباشرة مثل
  // أسماء التصنيفات. تُضاف تدريجياً وتتساقط تلقائياً للعربي لو غير متوفرة.
  final String? titleEn;
  final String? titleId;
  final String? titleUr;

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
    this.isQuran = false,
    this.meaningEn,
    this.meaningId,
    this.meaningUr,
    this.titleEn,
    this.titleId,
    this.titleUr,
  });

  /// معرّف ثابت للذكر (فئة + عنوان) يُستخدم في المفضلة والتخزين المحلي.
  /// لا يعتمد على ترتيب العناصر في القائمة حتى لا يتغير عند إضافة أذكار جديدة.
  String get id => '${category.name}__$title';

  /// نص الذكر بحسب اللغة الحالية. لو الترجمة غير متوفرة بعد لهذا الذكر
  /// تحديداً، يرجع النص العربي الأصلي بدل ما يعرض فراغاً — كل الأذكار تبقى
  /// صحيحة ومقروءة بأي لغة، والنص المترجم يظهر تلقائياً أول ما يُضاف.
  ///
  /// الآيات القرآنية (isQuran) استثناء: تبقى عربية دائماً بكل اللغات —
  /// راجع [meaningFor] للمعنى المترجم المعروض بشكل منفصل.
  String textFor(AppLanguage lang) {
    if (isQuran) return text;
    switch (lang) {
      case AppLanguage.ar:
        return text;
      case AppLanguage.en:
        return textEn ?? text;
      case AppLanguage.id:
        return textId ?? text;
      case AppLanguage.ur:
        return textUr ?? text;
    }
  }

  /// معنى/تفسير مبسّط للآية بلغة العرض الحالية — يُعرض بجانب النص العربي
  /// الأصلي (وليس بديلاً عنه)، ويُستخدم فقط للأذكار المعلّمة بـ[isQuran].
  /// يرجع null لو ما فيه ترجمة للمعنى بعد، أو لو الذكر عربي أصلاً.
  String? meaningFor(AppLanguage lang) {
    if (!isQuran) return null;
    switch (lang) {
      case AppLanguage.ar:
        return null;
      case AppLanguage.en:
        return meaningEn;
      case AppLanguage.id:
        return meaningId;
      case AppLanguage.ur:
        return meaningUr;
    }
  }

  /// عنوان الذكر بحسب اللغة الحالية — تسمية وصفية قصيرة (وليست ترجمة نص
  /// شرعي)، فتُترجم مباشرة مثل أسماء التصنيفات. يرجع العربي لو غير متوفر.
  String titleFor(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ar:
        return title;
      case AppLanguage.en:
        return titleEn ?? title;
      case AppLanguage.id:
        return titleId ?? title;
      case AppLanguage.ur:
        return titleUr ?? title;
    }
  }

  String sourceFor(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ar:
        return source;
      case AppLanguage.en:
        return sourceEn ?? source;
      case AppLanguage.id:
        return sourceId ?? source;
      case AppLanguage.ur:
        return sourceUr ?? source;
    }
  }

  /// هل هذا الذكر مترجم فعلاً للغة المحددة؟ تُستخدم لو أردنا لاحقاً نعرض
  /// تنبيهاً بسيطاً ("ترجمة هذا الذكر لسا ما وصلت") بدل عرض العربي بصمت.
  bool hasTranslation(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ar:
        return true;
      case AppLanguage.en:
        return textEn != null;
      case AppLanguage.id:
        return textId != null;
      case AppLanguage.ur:
        return textUr != null;
    }
  }
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

  /// اسم التصنيف بالإنجليزية. هذي ترجمة أسماء تصنيفات فقط (وليست ترجمة
  /// للنصوص الشرعية نفسها) — لذلك آمنة ومباشرة، بعكس محتوى الأذكار الذي
  /// يحتاج مصدراً معتمداً (راجع athkar_localization_plan.md).
  String get englishName {
    switch (this) {
      case DhikrCategory.morning: return 'Morning Adhkar';
      case DhikrCategory.evening: return 'Evening Adhkar';
      case DhikrCategory.sleep: return 'Sleep Adhkar';
      case DhikrCategory.wakeup: return 'Waking Up Adhkar';
      case DhikrCategory.prayer: return 'Prayer Adhkar';
      case DhikrCategory.afterPrayer: return 'After-Prayer Adhkar';
      case DhikrCategory.mosque: return 'Mosque Adhkar';
      case DhikrCategory.food: return 'Food Adhkar';
      case DhikrCategory.travel: return 'Travel Adhkar';
      case DhikrCategory.quran: return 'Quranic Supplications';
      case DhikrCategory.names: return 'The 99 Names of Allah';
      case DhikrCategory.misc: return 'Miscellaneous Adhkar';
      case DhikrCategory.ruqyah: return 'Legislated Ruqyah';
      case DhikrCategory.nawawi40: return 'The Forty Hadith of An-Nawawi';
      case DhikrCategory.dailySunnah: return 'The Prophet\'s ﷺ Daily Sunnah';
      case DhikrCategory.fridaySunnah: return 'Friday Sunnah';
      case DhikrCategory.prophetsDua: return 'Supplications of the Prophets';
    }
  }

  String get indonesianName {
    switch (this) {
      case DhikrCategory.morning: return 'Dzikir Pagi';
      case DhikrCategory.evening: return 'Dzikir Petang';
      case DhikrCategory.sleep: return 'Dzikir Sebelum Tidur';
      case DhikrCategory.wakeup: return 'Dzikir Bangun Tidur';
      case DhikrCategory.prayer: return 'Dzikir Salat';
      case DhikrCategory.afterPrayer: return 'Dzikir Setelah Salat';
      case DhikrCategory.mosque: return 'Dzikir Masjid';
      case DhikrCategory.food: return 'Dzikir Makan';
      case DhikrCategory.travel: return 'Dzikir Perjalanan';
      case DhikrCategory.quran: return 'Doa-Doa dari Al-Qur\'an';
      case DhikrCategory.names: return 'Asmaul Husna';
      case DhikrCategory.misc: return 'Dzikir Lainnya';
      case DhikrCategory.ruqyah: return 'Ruqyah Syar\'iyyah';
      case DhikrCategory.nawawi40: return 'Hadits Arbain An-Nawawi';
      case DhikrCategory.dailySunnah: return 'Sunnah Harian Nabi ﷺ';
      case DhikrCategory.fridaySunnah: return 'Sunnah Hari Jumat';
      case DhikrCategory.prophetsDua: return 'Doa Para Nabi';
    }
  }

  String get urduName {
    switch (this) {
      case DhikrCategory.morning: return 'صبح کے اذکار';
      case DhikrCategory.evening: return 'شام کے اذکار';
      case DhikrCategory.sleep: return 'سونے کے اذکار';
      case DhikrCategory.wakeup: return 'بیدار ہونے کے اذکار';
      case DhikrCategory.prayer: return 'نماز کے اذکار';
      case DhikrCategory.afterPrayer: return 'نماز کے بعد کے اذکار';
      case DhikrCategory.mosque: return 'مسجد کے اذکار';
      case DhikrCategory.food: return 'کھانے کے اذکار';
      case DhikrCategory.travel: return 'سفر کے اذکار';
      case DhikrCategory.quran: return 'قرآنی دعائیں';
      case DhikrCategory.names: return 'اللہ کے ننانوے نام';
      case DhikrCategory.misc: return 'متفرق اذکار';
      case DhikrCategory.ruqyah: return 'شرعی رقیہ';
      case DhikrCategory.nawawi40: return 'اربعین نووی';
      case DhikrCategory.dailySunnah: return 'نبی ﷺ کی روزمرہ سنتیں';
      case DhikrCategory.fridaySunnah: return 'جمعہ کی سنتیں';
      case DhikrCategory.prophetsDua: return 'انبیاء کی دعائیں';
    }
  }

  /// الاسم بحسب اللغة الحالية — يُستخدم بدل `arabicName` مباشرة في أي شاشة
  /// تعرض قائمة التصنيفات، حتى تتبدل تلقائياً مع تبديل اللغة.
  String nameFor(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ar:
        return arabicName;
      case AppLanguage.en:
        return englishName;
      case AppLanguage.id:
        return indonesianName;
      case AppLanguage.ur:
        return urduName;
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
