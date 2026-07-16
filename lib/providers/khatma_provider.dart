import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// يتتبّع تقدّم "ورد الختمة" اليومي (٣٠ يوماً لختمة كاملة)، محفوظاً محلياً
/// عبر shared_preferences. يبدأ تلقائياً ختمة جديدة بعد إتمام اليوم ٣٠.
class KhatmaProvider extends ChangeNotifier {
  static const String _dayKey = 'khatma_current_day';
  static const String _lastDoneKey = 'khatma_last_done_date';
  static const int totalDays = 30;

  int _currentDay = 1;
  String? _lastDoneDateStr;
  bool _loaded = false;

  int get currentDay => _currentDay;
  double get progress => _currentDay / totalDays;
  bool get isLoaded => _loaded;

  bool get completedToday {
    if (_lastDoneDateStr == null) return false;
    return _lastDoneDateStr == _dateKey(DateTime.now());
  }

  KhatmaProvider() {
    _load();
  }

  String _dateKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _currentDay = prefs.getInt(_dayKey) ?? 1;
    _lastDoneDateStr = prefs.getString(_lastDoneKey);
    _loaded = true;
    notifyListeners();
  }

  /// يسجّل إتمام ورد اليوم (مرة واحدة فقط في اليوم) وينتقل لليوم التالي.
  Future<void> markTodayDone() async {
    if (completedToday) return;
    final prefs = await SharedPreferences.getInstance();
    _lastDoneDateStr = _dateKey(DateTime.now());
    await prefs.setString(_lastDoneKey, _lastDoneDateStr!);
    _currentDay = _currentDay >= totalDays ? 1 : _currentDay + 1;
    await prefs.setInt(_dayKey, _currentDay);
    notifyListeners();
  }

  Future<void> resetCycle() async {
    _currentDay = 1;
    _lastDoneDateStr = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_dayKey, 1);
    await prefs.remove(_lastDoneKey);
    notifyListeners();
  }
}
