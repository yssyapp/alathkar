import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

/// يدير تفعيل/تعطيل تذكيرات الصباح والمساء وتوقيتها، ويحفظها محلياً،
/// ويطلب من NotificationService جدولة الإشعارات فعلياً.
class ReminderProvider extends ChangeNotifier {
  static const String _prefEnabledKey = 'remindersEnabled';
  static const String _prefMorningHourKey = 'morningHour';
  static const String _prefMorningMinuteKey = 'morningMinute';
  static const String _prefEveningHourKey = 'eveningHour';
  static const String _prefEveningMinuteKey = 'eveningMinute';

  bool _enabled = false;
  TimeOfDay _morningTime = const TimeOfDay(hour: 6, minute: 0);
  TimeOfDay _eveningTime = const TimeOfDay(hour: 17, minute: 0);

  bool get enabled => _enabled;
  TimeOfDay get morningTime => _morningTime;
  TimeOfDay get eveningTime => _eveningTime;

  ReminderProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_prefEnabledKey) ?? false;
    _morningTime = TimeOfDay(
      hour: prefs.getInt(_prefMorningHourKey) ?? 6,
      minute: prefs.getInt(_prefMorningMinuteKey) ?? 0,
    );
    _eveningTime = TimeOfDay(
      hour: prefs.getInt(_prefEveningHourKey) ?? 17,
      minute: prefs.getInt(_prefEveningMinuteKey) ?? 0,
    );
    notifyListeners();
    if (_enabled) {
      await _applySchedule();
    }
  }

  Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value) {
      final granted = await NotificationService.instance.requestPermissions();
      if (!granted) {
        // ما وافق المستخدم على الإذن: نخلي المفتاح مطفي ونوقف هنا.
        _enabled = false;
        notifyListeners();
        await prefs.setBool(_prefEnabledKey, false);
        return;
      }
      _enabled = true;
      notifyListeners();
      await prefs.setBool(_prefEnabledKey, true);
      await _applySchedule();
    } else {
      _enabled = false;
      notifyListeners();
      await prefs.setBool(_prefEnabledKey, false);
      await NotificationService.instance.cancel(NotificationService.morningNotificationId);
      await NotificationService.instance.cancel(NotificationService.eveningNotificationId);
    }
  }

  Future<void> setMorningTime(TimeOfDay time) async {
    _morningTime = time;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefMorningHourKey, time.hour);
    await prefs.setInt(_prefMorningMinuteKey, time.minute);
    if (_enabled) await _applySchedule();
  }

  Future<void> setEveningTime(TimeOfDay time) async {
    _eveningTime = time;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefEveningHourKey, time.hour);
    await prefs.setInt(_prefEveningMinuteKey, time.minute);
    if (_enabled) await _applySchedule();
  }

  Future<void> _applySchedule() async {
    await NotificationService.instance.init();
    await NotificationService.instance.scheduleDaily(
      id: NotificationService.morningNotificationId,
      title: 'أذكار الصباح 🌅',
      body: 'حان وقت أذكار الصباح، لا تنساها',
      hour: _morningTime.hour,
      minute: _morningTime.minute,
    );
    await NotificationService.instance.scheduleDaily(
      id: NotificationService.eveningNotificationId,
      title: 'أذكار المساء 🌙',
      body: 'حان وقت أذكار المساء، لا تنساها',
      hour: _eveningTime.hour,
      minute: _eveningTime.minute,
    );
  }
}
