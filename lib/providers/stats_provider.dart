import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// يتتبع عدد الأذكار المكتملة يومياً (عند وصول العدّاد لعدد التكرار المطلوب)،
/// ويحسب سلسلة الأيام المتتالية (streak) ويحفظ كل شيء محلياً.
class StatsProvider extends ChangeNotifier {
  static const String _prefTodayCountKey = 'statsTodayCount';
  static const String _prefLastDateKey = 'statsLastCompletionDate';
  static const String _prefStreakKey = 'statsStreak';
  static const String _prefBestStreakKey = 'statsBestStreak';
  static const String _prefTotalKey = 'statsTotalAllTime';

  int _todayCount = 0;
  int _streak = 0;
  int _bestStreak = 0;
  int _totalAllTime = 0;
  String? _lastDate;

  int get todayCount => _todayCount;
  int get bestStreak => _bestStreak;
  int get totalAllTime => _totalAllTime;

  /// السلسلة الحالية كما تظهر للمستخدم: ترجع صفراً تلقائياً لو انقطع يوم
  /// كامل بدون إكمال أي ذكر، حتى لو لسا محفوظ رقم أعلى بالتخزين المحلي.
  int get streak {
    if (_lastDate == null) return 0;
    final today = _todayKey();
    final yesterday = _dateKeyFor(DateTime.now().subtract(const Duration(days: 1)));
    if (_lastDate == today || _lastDate == yesterday) return _streak;
    return 0;
  }

  StatsProvider() {
    _load();
  }

  String _dateKeyFor(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _todayKey() => _dateKeyFor(DateTime.now());

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _lastDate = prefs.getString(_prefLastDateKey);
    _streak = prefs.getInt(_prefStreakKey) ?? 0;
    _bestStreak = prefs.getInt(_prefBestStreakKey) ?? 0;
    _totalAllTime = prefs.getInt(_prefTotalKey) ?? 0;
    _todayCount = (_lastDate == _todayKey()) ? (prefs.getInt(_prefTodayCountKey) ?? 0) : 0;
    notifyListeners();
  }

  /// يُستدعى في كل مرة يكتمل فيها عدّاد ذكر (يوصل لعدد التكرار المطلوب).
  Future<void> recordCompletion() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    final yesterday = _dateKeyFor(DateTime.now().subtract(const Duration(days: 1)));

    if (_lastDate == today) {
      _todayCount++;
    } else if (_lastDate == yesterday) {
      _streak++;
      _todayCount = 1;
    } else {
      _streak = 1;
      _todayCount = 1;
    }
    _lastDate = today;
    _totalAllTime++;
    if (_streak > _bestStreak) _bestStreak = _streak;

    await prefs.setString(_prefLastDateKey, _lastDate!);
    await prefs.setInt(_prefTodayCountKey, _todayCount);
    await prefs.setInt(_prefStreakKey, _streak);
    await prefs.setInt(_prefBestStreakKey, _bestStreak);
    await prefs.setInt(_prefTotalKey, _totalAllTime);

    notifyListeners();
  }
}
