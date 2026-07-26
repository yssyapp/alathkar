import 'dart:convert';

import 'package:http/http.dart' as http;

import '../utils/prayer_times.dart';

/// جلب مواقيت صلاة أدق عبر خدمة Aladhan (aladhan.com) — API مجاني بالكامل،
/// بدون مفتاح، بدون حساب، بدون إعلانات. تُستخدم فقط لو المستخدم فعّل
/// "مواقيت صلاة أدق عبر الإنترنت" يدوياً من الإعدادات؛ أي فشل (لا إنترنت،
/// تأخر الاستجابة، خطأ بالخادم) يرجع null فوراً بدل ما يعطّل الشاشة، وتستمر
/// الشاشة تعرض الحساب الفلكي المحلي (PrayerTimesCalculator) كخيار احتياطي
/// دائم — التطبيق لا يعتمد على الإنترنت إطلاقاً حتى مع هذي الميزة مفعّلة.
class OnlinePrayerService {
  /// method=4 يعني طريقة "أم القرى" (جامعة أم القرى بمكة المكرمة) — نفس
  /// الطريقة المستخدمة بالحساب المحلي، حتى تكون النتيجتان متقاربتين ومتوقّعتين
  /// للمستخدم بدل ما تختلف الأرقام بشكل مربك بين الوضعين.
  static Future<PrayerTimesResult?> fetch({
    required double latitude,
    required double longitude,
    required DateTime date,
  }) async {
    try {
      final dateStr = '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
      final uri = Uri.parse(
        'https://api.aladhan.com/v1/timings/$dateStr'
        '?latitude=$latitude&longitude=$longitude&method=4',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final timings = body['data']?['timings'] as Map<String, dynamic>?;
      if (timings == null) return null;

      DateTime? parse(String key) {
        final raw = timings[key] as String?;
        if (raw == null) return null;
        // الصيغة القادمة من الخدمة مثل "04:32 (+03)" — نأخذ الساعة:الدقيقة فقط.
        final clean = raw.split(' ').first;
        final parts = clean.split(':');
        if (parts.length != 2) return null;
        final h = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        if (h == null || m == null) return null;
        return DateTime(date.year, date.month, date.day, h, m);
      }

      final fajr = parse('Fajr');
      final sunrise = parse('Sunrise');
      final dhuhr = parse('Dhuhr');
      final asr = parse('Asr');
      final maghrib = parse('Maghrib');
      final isha = parse('Isha');
      if (fajr == null || sunrise == null || dhuhr == null || asr == null || maghrib == null || isha == null) {
        return null;
      }

      return PrayerTimesResult(
        fajr: fajr,
        sunrise: sunrise,
        dhuhr: dhuhr,
        asr: asr,
        maghrib: maghrib,
        isha: isha,
      );
    } catch (_) {
      // أي خطأ إطلاقاً (لا إنترنت، DNS، مهلة، JSON غير متوقع...) — نرجع null
      // بصمت، والشاشة تستمر بالحساب المحلي بدون ما يشعر المستخدم بأي انقطاع.
      return null;
    }
  }
}
