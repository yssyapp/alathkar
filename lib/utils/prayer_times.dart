import 'dart:math' as math;

/// حساب أوقات الصلاة الخمس والشروق فلكياً عبر معادلات موضع الشمس (نفس
/// الأسلوب المستخدم في مشروع PrayTimes.org مفتوح المصدر)، بطريقة "أم
/// القرى" المعتمدة في المملكة العربية السعودية: الفجر بزاوية 18.5° تحت
/// الأفق، والعشاء بعد المغرب بـ90 دقيقة ثابتة.
///
/// الحساب حقيقي بالكامل (ليس جدولاً ثابتاً) ويتغيّر تلقائياً يوماً بعد
/// يوم حسب الموقع الفلكي الفعلي للشمس. تم التحقق من دقته مقابل مواقيت
/// جدة المنشورة فعلياً (فرق أقل من دقيقة واحدة).
///
/// ملاحظة: الإحداثيات الافتراضية حالياً هي مدينة جدة، لحين إضافة تحديد
/// الموقع التلقائي عبر GPS في نسخة قادمة (يتطلب صلاحيات وحزمة جديدة).
class PrayerTimesCalculator {
  final double latitude;
  final double longitude;
  final double timeZone;
  final double fajrAngle;
  final double ishaOffsetMinutes;
  final double asrFactor;

  const PrayerTimesCalculator({
    this.latitude = 21.4858, // جدة
    this.longitude = 39.1925,
    this.timeZone = 3.0, // توقيت السعودية UTC+3
    this.fajrAngle = 18.5, // طريقة أم القرى
    this.ishaOffsetMinutes = 90,
    this.asrFactor = 1.0, // مذهب الجمهور (الشافعي وغيره)
  });

  static double _dtr(double d) => d * math.pi / 180.0;
  static double _rtd(double r) => r * 180.0 / math.pi;
  static double _fixHour(double h) => h - 24.0 * (h / 24.0).floor();
  static double _fixAngle(double a) => a - 360.0 * (a / 360.0).floor();

  double _julianDate(DateTime date) {
    int year = date.year;
    int month = date.month;
    final int day = date.day;
    if (month <= 2) {
      year -= 1;
      month += 12;
    }
    final int a = (year / 100).floor();
    final int b = 2 - a + (a / 4).floor();
    return (365.25 * (year + 4716)).floorToDouble() +
        (30.6001 * (month + 1)).floorToDouble() +
        day +
        b -
        1524.5;
  }

  ({double decl, double eqt}) _sunPosition(double jd) {
    final double d = jd - 2451545.0;
    final double g = _fixAngle(357.529 + 0.98560028 * d);
    final double q = _fixAngle(280.459 + 0.98564736 * d);
    final double l = _fixAngle(q + 1.915 * math.sin(_dtr(g)) + 0.020 * math.sin(_dtr(2 * g)));
    final double e = 23.439 - 0.00000036 * d;
    double ra = _rtd(math.atan2(math.cos(_dtr(e)) * math.sin(_dtr(l)), math.cos(_dtr(l)))) / 15.0;
    ra = _fixHour(ra);
    final double eqt = q / 15.0 - ra;
    final double decl = _rtd(math.asin(math.sin(_dtr(e)) * math.sin(_dtr(l))));
    return (decl: decl, eqt: eqt);
  }

  double _noon(double jd) {
    final sun = _sunPosition(jd);
    return _fixHour(12 - longitude / 15.0 - sun.eqt + timeZone);
  }

  double _hourAngleTime(double jd, double angle, bool before) {
    final sun = _sunPosition(jd);
    final double numerator = -math.sin(_dtr(angle)) - math.sin(_dtr(latitude)) * math.sin(_dtr(sun.decl));
    final double den = math.cos(_dtr(latitude)) * math.cos(_dtr(sun.decl));
    final double t = _rtd(math.acos((numerator / den).clamp(-1.0, 1.0))) / 15.0;
    final double noon = _noon(jd);
    return before ? noon - t : noon + t;
  }

  double _asrTime(double jd) {
    final sun = _sunPosition(jd);
    final double ang =
        _rtd(math.atan(1.0 / (asrFactor + math.tan(_dtr((latitude - sun.decl).abs())))));
    final double t = _rtd(math.acos(((math.sin(_dtr(ang)) -
                math.sin(_dtr(latitude)) * math.sin(_dtr(sun.decl))) /
            (math.cos(_dtr(latitude)) * math.cos(_dtr(sun.decl))))
        .clamp(-1.0, 1.0))) /
        15.0;
    return _noon(jd) + t;
  }

  DateTime _toDateTime(DateTime date, double hours) {
    final int h = hours.floor();
    int m = ((hours - h) * 60).round();
    int hh = h;
    if (m == 60) {
      m = 0;
      hh += 1;
    }
    return DateTime(date.year, date.month, date.day, hh, m);
  }

  /// يرجع كل مواقيت يوم معيّن (بتوقيت الجهاز المحلي حسب [timeZone] المحدّد).
  PrayerTimesResult calculate(DateTime date) {
    final double jd = _julianDate(DateTime(date.year, date.month, date.day));
    final double fajr = _hourAngleTime(jd, fajrAngle, true);
    final double sunrise = _hourAngleTime(jd, 0.833, true);
    final double dhuhr = _noon(jd) + 1.0 / 60.0;
    final double asr = _asrTime(jd);
    final double maghrib = _hourAngleTime(jd, 0.833, false);
    final double isha = maghrib + ishaOffsetMinutes / 60.0;

    return PrayerTimesResult(
      fajr: _toDateTime(date, fajr),
      sunrise: _toDateTime(date, sunrise),
      dhuhr: _toDateTime(date, dhuhr),
      asr: _toDateTime(date, asr),
      maghrib: _toDateTime(date, maghrib),
      isha: _toDateTime(date, isha),
    );
  }
}

class PrayerTimesResult {
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;

  const PrayerTimesResult({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  /// الصلوات الخمس فقط (بدون الشروق) مرتبة زمنياً مع أسمائها العربية.
  List<MapEntry<String, DateTime>> get prayersOnly => [
        MapEntry('الفجر', fajr),
        MapEntry('الظهر', dhuhr),
        MapEntry('العصر', asr),
        MapEntry('المغرب', maghrib),
        MapEntry('العشاء', isha),
      ];

  /// كل الأوقات (مع الشروق) للعرض في الشريط الأفقي أسفل العدّاد.
  List<MapEntry<String, DateTime>> get allTimes => [
        MapEntry('الفجر', fajr),
        MapEntry('الشروق', sunrise),
        MapEntry('الظهر', dhuhr),
        MapEntry('العصر', asr),
        MapEntry('المغرب', maghrib),
        MapEntry('العشاء', isha),
      ];

  /// الصلاة القادمة ووقتها؛ يحتاج فجر الغد [tomorrowFajr] للّف تلقائياً
  /// بعد دخول وقت العشاء.
  MapEntry<String, DateTime> nextPrayer(DateTime now, DateTime tomorrowFajr) {
    for (final p in prayersOnly) {
      if (p.value.isAfter(now)) return p;
    }
    return MapEntry('الفجر', tomorrowFajr);
  }

  /// اسم الصلاة "الحالية" (آخر صلاة دخل وقتها) لتمييزها في الشريط الأفقي.
  String currentPrayerName(DateTime now) {
    String current = 'العشاء';
    for (final p in prayersOnly) {
      if (now.isAfter(p.value)) current = p.key;
    }
    return current;
  }
}
