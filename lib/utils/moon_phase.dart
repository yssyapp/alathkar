/// حساب تقريبي لطور القمر الحالي بالاعتماد على طول الدورة القمرية
/// الاصطناعية الثابت (29.53 يوماً تقريباً)، بدون أي حزمة خارجية أو
/// حاجة لاتصال بالإنترنت — مناسب لعرض تقديري (زخرفي/معلوماتي) للطور.
class MoonPhaseInfo {
  final String name;
  final String emoji;
  final double illumination; // 0.0 (محاق) → 1.0 (بدر)

  const MoonPhaseInfo({
    required this.name,
    required this.emoji,
    required this.illumination,
  });
}

class MoonPhaseCalculator {
  static const double _synodicMonth = 29.530588853;

  // قمر جديد (محاق) معروف بدقة: 6 يناير 2000 الساعة 18:14 بتوقيت UTC.
  static final DateTime _knownNewMoon = DateTime.utc(2000, 1, 6, 18, 14);

  static MoonPhaseInfo calculate(DateTime date) {
    final double daysSince =
        date.toUtc().difference(_knownNewMoon).inMinutes / (60 * 24);
    double phase = (daysSince % _synodicMonth) / _synodicMonth;
    if (phase < 0) phase += 1;
    final double illumination = 1 - (2 * phase - 1).abs();

    String name;
    String emoji;
    if (phase < 0.03 || phase > 0.97) {
      name = 'محاق';
      emoji = '🌑';
    } else if (phase < 0.22) {
      name = 'هلال متزايد';
      emoji = '🌒';
    } else if (phase < 0.28) {
      name = 'تربيع أول';
      emoji = '🌓';
    } else if (phase < 0.47) {
      name = 'أحدب متزايد';
      emoji = '🌔';
    } else if (phase < 0.53) {
      name = 'بدر (اكتمال القمر)';
      emoji = '🌕';
    } else if (phase < 0.72) {
      name = 'أحدب متناقص';
      emoji = '🌖';
    } else if (phase < 0.78) {
      name = 'تربيع أخير';
      emoji = '🌗';
    } else {
      name = 'هلال متناقص';
      emoji = '🌘';
    }

    return MoonPhaseInfo(name: name, emoji: emoji, illumination: illumination);
  }
}
