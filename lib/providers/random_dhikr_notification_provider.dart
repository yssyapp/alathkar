import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/random_reminders_data.dart';
import '../services/notification_service.dart';

/// يدير تفعيل/تعطيل تنبيهات "ذكر عشوائي" على مدار اليوم (زي ميزة معروفة في
/// تطبيق أذكاري) — يجدول عدداً من التنبيهات موزّعة على ساعات النهار
/// (٧ص - ١٠م) بنص ذكر عشوائي مختلف في كل مرة، لمدة ٧ أيام قادمة، ويعيد
/// الجدولة تلقائياً عند فتح التطبيق حتى تبقى النافذة ممتدة دائماً.
class RandomDhikrNotificationProvider extends ChangeNotifier {
  static const String _prefEnabledKey = 'randomDhikrEnabled';
  static const String _prefFrequencyKey = 'randomDhikrFrequency';
  static const int _baseId = 500;
  static const int _daysAhead = 7;
  static const int _maxPerDay = 8;
  static const int _startHour = 7;
  static const int _endHour = 22;

  /// مستويات التكرار المتاحة: عدد التنبيهات في اليوم الواحد.
  static const Map<String, int> frequencyLevels = {'قليل': 3, 'متوسط': 5, 'كثير': 8};

  bool _enabled = false;
  String _frequency = 'متوسط';
  final Random _random = Random();

  bool get enabled => _enabled;
  String get frequency => _frequency;

  RandomDhikrNotificationProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_prefEnabledKey) ?? false;
    _frequency = prefs.getString(_prefFrequencyKey) ?? 'متوسط';
    notifyListeners();
    if (_enabled) await _rescheduleAll();
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
      await NotificationService.instance.cancelRange(_baseId, _daysAhead * _maxPerDay);
    }
  }

  Future<void> setFrequency(String level) async {
    if (!frequencyLevels.containsKey(level)) return;
    _frequency = level;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefFrequencyKey, level);
    if (_enabled) await _rescheduleAll();
  }

  List<int> _hoursForCount(int count) {
    if (count <= 1) return [_startHour];
    final hours = <int>[];
    for (int i = 0; i < count; i++) {
      final h = _startHour + (i * (_endHour - _startHour) / (count - 1));
      hours.add(h.round());
    }
    return hours;
  }

  Future<void> _rescheduleAll() async {
    await NotificationService.instance.init();
    await NotificationService.instance.cancelRange(_baseId, _daysAhead * _maxPerDay);

    final count = frequencyLevels[_frequency] ?? 5;
    final hours = _hoursForCount(count);
    final now = DateTime.now();

    for (int dayOffset = 0; dayOffset < _daysAhead; dayOffset++) {
      final date = now.add(Duration(days: dayOffset));
      for (int i = 0; i < hours.length; i++) {
        final text = randomReminders[_random.nextInt(randomReminders.length)];
        final dateTime = DateTime(date.year, date.month, date.day, hours[i]);
        await NotificationService.instance.scheduleOneOff(
          id: _baseId + dayOffset * _maxPerDay + i,
          title: 'ذكر 📿',
          body: text,
          dateTime: dateTime,
          channelId: 'random_dhikr',
          channelName: 'تنبيهات ذكر عشوائي',
          channelDescription: 'تذكير عرضي بذكر قصير على مدار اليوم',
        );
      }
    }
  }

  /// يُستدعى عند كل فتح للتطبيق حتى تمتد نافذة الجدولة دائماً لأقرب ٧ أيام.
  Future<void> refreshIfEnabled() async {
    if (_enabled) await _rescheduleAll();
  }
}
