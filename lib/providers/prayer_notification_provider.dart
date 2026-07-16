import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/notification_service.dart';
import '../utils/prayer_times.dart';

/// يدير تفعيل/تعطيل تنبيهات دخول أوقات الصلاة الخمس (مثل تطبيق "مؤذن")،
/// مع إمكانية كتم أي صلاة بعينها. لأن مواقيت الصلاة تتغيّر فلكياً كل يوم
/// (على عكس تذكيرات الأذكار ذات الوقت الثابت)، يجدول هذا المزود إشعارات
/// "لمرة واحدة" لأقرب ٧ أيام قادمة، ويعيد الجدولة تلقائياً عند فتح
/// التطبيق أو تغيير الإعدادات حتى تبقى التنبيهات محدّثة باستمرار.
class PrayerNotificationProvider extends ChangeNotifier {
  static const String _prefEnabledKey = 'prayerNotificationsEnabled';
  static const String _prefMutedKey = 'prayerNotificationsMuted';
  static const int _baseId = 300;
  static const int _daysAhead = 7;

  static const List<String> allPrayerNames = ['الفجر', 'الظهر', 'العصر', 'المغرب', 'العشاء'];

  bool _enabled = false;
  final Set<String> _muted = {};
  static const PrayerTimesCalculator _calculator = PrayerTimesCalculator();

  bool get enabled => _enabled;
  bool isMuted(String prayerName) => _muted.contains(prayerName);

  PrayerNotificationProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_prefEnabledKey) ?? false;
    _muted.addAll(prefs.getStringList(_prefMutedKey) ?? const []);
    notifyListeners();
    if (_enabled) {
      await _rescheduleAll();
    }
  }

  Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value) {
      final granted = await NotificationService.instance.requestPermissions();
      if (!granted) {
        _enabled = false;
        notifyListeners();
        await prefs.setBool(_prefEnabledKey, false);
        return;
      }
      _enabled = true;
      notifyListeners();
      await prefs.setBool(_prefEnabledKey, true);
      await _rescheduleAll();
    } else {
      _enabled = false;
      notifyListeners();
      await prefs.setBool(_prefEnabledKey, false);
      await NotificationService.instance.cancelRange(_baseId, _daysAhead * allPrayerNames.length);
    }
  }

  Future<void> toggleMuted(String prayerName) async {
    if (_muted.contains(prayerName)) {
      _muted.remove(prayerName);
    } else {
      _muted.add(prayerName);
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefMutedKey, _muted.toList());
    if (_enabled) await _rescheduleAll();
  }

  /// يعيد جدولة كل تنبيهات أوقات الصلاة القادمة (يُستحسن استدعاؤه أيضاً عند
  /// كل فتح للتطبيق حتى تبقى نافذة الـ٧ أيام محدّثة باستمرار).
  Future<void> _rescheduleAll() async {
    await NotificationService.instance.init();
    await NotificationService.instance.cancelRange(_baseId, _daysAhead * allPrayerNames.length);

    final now = DateTime.now();
    for (int dayOffset = 0; dayOffset < _daysAhead; dayOffset++) {
      final date = now.add(Duration(days: dayOffset));
      final times = _calculator.calculate(date);
      final prayers = times.prayersOnly;
      for (int i = 0; i < prayers.length; i++) {
        final name = prayers[i].key;
        if (_muted.contains(name)) continue;
        await NotificationService.instance.scheduleOneOff(
          id: _baseId + dayOffset * allPrayerNames.length + i,
          title: 'حان وقت أذان $name 🕌',
          body: 'حي على الصلاة، حي على الفلاح',
          dateTime: prayers[i].value,
          channelId: 'prayer_adhan',
          channelName: 'تنبيهات أذان الصلاة',
          channelDescription: 'تنبيه عند دخول وقت كل صلاة من الصلوات الخمس',
        );
      }
    }
  }

  /// يُستدعى من الشاشة الرئيسية عند كل فتح للتطبيق حتى تمتد نافذة الجدولة
  /// دائماً لأقرب ٧ أيام قادمة (بدون هذا، تتوقف التنبيهات بعد أسبوع من عدم فتح التطبيق).
  Future<void> refreshIfEnabled() async {
    if (_enabled) await _rescheduleAll();
  }
}
