import '../providers/language_provider.dart';

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
  // عناوين مترجمة اختيارية — تُستخدم في البحث لمطابقة العنوان بلغة أخرى غير
  // العربية؛ لو لم تتوفر بعد لذكر معيّن يبقى البحث يعمل بالنص العربي فقط.
  final String? titleEn;
  final String? titleId;
  final String? titleUr;
  // معنى/تفسير مبسّط اختياري (يُستخدم غالباً للأذكار القرآنية) — يظهر فقط
  // عند توفره لتلك اللغة تحديداً، بدون أي رجوع تلقائي للعربي (خلافاً لـ
  // textFor/sourceFor)، لأن غيابه يعني ببساطة "لا تعرض هذا القسم بعد".
  final String? meaning;
  final String? meaningEn;
  final String? meaningId;
  final String? meaningUr;

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
    this.titleEn,
    this.titleId,
    this.titleUr,
    this.meaning,
    this.meaningEn,
    this.meaningId,
    this.meaningUr,
  });

  /// معرّف ثابت للذكر (فئة + عنوان) يُستخدم في المفضلة والتخزين المحلي.
  /// لا يعتمد على ترتيب العناصر في القائمة حتى لا يتغير عند إضافة أذكار جديدة.
  String get id => '${category.name}__$title';

  /// عنوان الذكر باللغة المطلوبة، مع رجوع تلقائي للعنوان العربي إذا لم
  /// تتوفر ترجمة العنوان بعد لهذه اللغة.
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

  /// نص الذكر باللغة المطلوبة، ويرجع تلقائياً للنص العربي الأصلي إذا لم
  /// تتوفر ترجمة لهذا الذكر بعد باللغة المختارة (حتى لا يظهر نص فارغ).
  String textFor(AppLanguage lang) {
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

  /// مصدر/تخريج الذكر باللغة المطلوبة، مع نفس منطق الرجوع للعربي عند
  /// غياب الترجمة.
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

  /// المعنى/التفسير المبسّط باللغة المطلوبة، أو null لو غير متوفر بعد لهذه
  /// اللغة تحديداً (بدون رجوع تلقائي للعربي — غياب القيمة يعني إخفاء القسم).
  String? meaningFor(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ar:
        return meaning;
      case AppLanguage.en:
        return meaningEn;
      case AppLanguage.id:
        return meaningId;
      case AppLanguage.ur:
        return meaningUr;
    }
  }

  /// اسم راوي الحديث، مستخرَج تلقائياً من [source] لو كان يتبع الصيغة
  /// المعتادة في كل نصوص الأحاديث بالمشروع: "عن فلان رضي الله عنه —
  /// رواه ...". يرجع null لأي نص لا يبدأ بـ"عن " (كالآيات القرآنية أو
  /// أذكار غير مسندة لصحابي) حتى لا يظهر سطر "الراوي" في غير مكانه.
  String? get narrator {
    if (!source.startsWith('عن ')) return null;
    final dashIndex = source.indexOf('—');
    if (dashIndex == -1) return null;
    final name = source.substring(0, dashIndex).trim();
    return name.isEmpty ? null : name;
  }

  /// نص التخريج (مَن دوّن الحديث في كتابه: البخاري، مسلم، الترمذي...)
  /// باللغة المطلوبة، بعد حذف اسم الراوي (الصحابي) من بدايته لو استُخرج
  /// عبر [narrator] — لأنه يُعرض أصلاً في سطر مستقل فوق نص الحديث، فلا
  /// داعي لتكراره هنا. هذا هو الترتيب المعتاد في كتب الحديث: اسم الصحابي
  /// (الراوي) مع النص، ثم مَن خرّجه (البخاري/مسلم/الترمذي...) تحته.
  String attributionFor(AppLanguage lang) {
    final displayed = sourceFor(lang);
    if (narrator == null || displayed != source) return displayed;
    final dashIndex = displayed.indexOf('—');
    if (dashIndex == -1) return displayed;
    return displayed.substring(dashIndex + 1).trim();
  }
}

enum DhikrCategory {
  morning, evening, sleep, wakeup, prayer,
  afterPrayer, mosque, food, travel, quran, names, misc, ruqyah, nawawi40,
  dailySunnah, fridaySunnah, prophetsDua,
  adhan, home, wudu, toilet,
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
      case DhikrCategory.adhan: return 'أذكار الآذان';
      case DhikrCategory.home: return 'أذكار المنزل';
      case DhikrCategory.wudu: return 'أذكار الوضوء';
      case DhikrCategory.toilet: return 'أذكار الخلاء';
    }
  }

  /// اسم الفئة مترجمًا حسب اللغة الحالية للتطبيق — يُستخدم في شاشات الفئات
  /// والبحث والمفضلة بدل الاعتماد دائمًا على الاسم العربي.
  String nameFor(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ar:
        return arabicName;
      case AppLanguage.en:
        switch (this) {
          case DhikrCategory.morning: return 'Morning Remembrance';
          case DhikrCategory.evening: return 'Evening Remembrance';
          case DhikrCategory.sleep: return 'Sleep Remembrance';
          case DhikrCategory.wakeup: return 'Waking Up Remembrance';
          case DhikrCategory.prayer: return 'Prayer Remembrance';
          case DhikrCategory.afterPrayer: return 'After Prayer Remembrance';
          case DhikrCategory.mosque: return 'Mosque Remembrance';
          case DhikrCategory.food: return 'Food Remembrance';
          case DhikrCategory.travel: return 'Travel Remembrance';
          case DhikrCategory.quran: return 'Quranic Supplications';
          case DhikrCategory.names: return 'The 99 Names of Allah';
          case DhikrCategory.misc: return 'Miscellaneous Remembrance';
          case DhikrCategory.ruqyah: return 'Legislative Ruqyah';
          case DhikrCategory.nawawi40: return "An-Nawawi's 40 Hadiths";
          case DhikrCategory.dailySunnah: return "Prophet's Daily Sunnah";
          case DhikrCategory.fridaySunnah: return 'Friday Sunnah';
          case DhikrCategory.prophetsDua: return "Prophets' Supplications";
          case DhikrCategory.adhan: return 'Adhan Remembrance';
          case DhikrCategory.home: return 'Home Remembrance';
          case DhikrCategory.wudu: return 'Ablution (Wudu) Remembrance';
          case DhikrCategory.toilet: return 'Restroom Remembrance';
        }
      case AppLanguage.id:
        switch (this) {
          case DhikrCategory.morning: return 'Dzikir Pagi';
          case DhikrCategory.evening: return 'Dzikir Petang';
          case DhikrCategory.sleep: return 'Dzikir Sebelum Tidur';
          case DhikrCategory.wakeup: return 'Dzikir Bangun Tidur';
          case DhikrCategory.prayer: return 'Dzikir Shalat';
          case DhikrCategory.afterPrayer: return 'Dzikir Setelah Shalat';
          case DhikrCategory.mosque: return 'Dzikir Masjid';
          case DhikrCategory.food: return 'Doa Makan';
          case DhikrCategory.travel: return 'Doa Safar';
          case DhikrCategory.quran: return 'Doa-doa dari Al-Qur\'an';
          case DhikrCategory.names: return 'Asmaul Husna';
          case DhikrCategory.misc: return 'Dzikir Lainnya';
          case DhikrCategory.ruqyah: return 'Ruqyah Syar\'iyyah';
          case DhikrCategory.nawawi40: return 'Hadits Arbain An-Nawawi';
          case DhikrCategory.dailySunnah: return 'Sunnah Harian Nabi ﷺ';
          case DhikrCategory.fridaySunnah: return 'Sunnah Hari Jumat';
          case DhikrCategory.prophetsDua: return 'Doa Para Nabi';
          case DhikrCategory.adhan: return 'Dzikir Adzan';
          case DhikrCategory.home: return 'Dzikir Rumah';
          case DhikrCategory.wudu: return 'Dzikir Wudhu';
          case DhikrCategory.toilet: return 'Dzikir Kamar Mandi';
        }
      case AppLanguage.ur:
        switch (this) {
          case DhikrCategory.morning: return 'صبح کے اذکار';
          case DhikrCategory.evening: return 'شام کے اذکار';
          case DhikrCategory.sleep: return 'سونے کے اذکار';
          case DhikrCategory.wakeup: return 'بیدار ہونے کے اذکار';
          case DhikrCategory.prayer: return 'نماز کے اذکار';
          case DhikrCategory.afterPrayer: return 'نماز کے بعد کے اذکار';
          case DhikrCategory.mosque: return 'مسجد کے اذکار';
          case DhikrCategory.food: return 'کھانے کی دعائیں';
          case DhikrCategory.travel: return 'سفر کی دعائیں';
          case DhikrCategory.quran: return 'قرآنی دعائیں';
          case DhikrCategory.names: return 'اللہ کے 99 نام';
          case DhikrCategory.misc: return 'متفرق اذکار';
          case DhikrCategory.ruqyah: return 'شرعی رقیہ';
          case DhikrCategory.nawawi40: return 'اربعین نووی';
          case DhikrCategory.dailySunnah: return 'نبی ﷺ کی روزمرہ سنتیں';
          case DhikrCategory.fridaySunnah: return 'جمعہ کی سنتیں';
          case DhikrCategory.prophetsDua: return 'انبیاء کی دعائیں';
          case DhikrCategory.adhan: return 'اذان کے اذکار';
          case DhikrCategory.home: return 'گھر کے اذکار';
          case DhikrCategory.wudu: return 'وضو کے اذکار';
          case DhikrCategory.toilet: return 'بیت الخلاء کے اذکار';
        }
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
      case DhikrCategory.adhan: return '📢';
      case DhikrCategory.home: return '🏠';
      case DhikrCategory.wudu: return '💧';
      case DhikrCategory.toilet: return '🚪';
    }
  }
}
