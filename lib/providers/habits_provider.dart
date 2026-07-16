import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// عادة يومية يتابعها المستخدم (اسم ثابت داخل الكود + عنوان عربي وأيقونة
/// للعرض).
class Habit {
  final String id;
  final String title;
  final String emoji;
  const Habit(this.id, this.title, this.emoji);
}

const List<Habit> kHabits = [
  Habit('morning_athkar', 'أذكار الصباح', '🌅'),
  Habit('evening_athkar', 'أذكار المساء', '🌙'),
  Habit('five_prayers', 'الصلوات الخمس', '🕌'),
  Habit('quran_wird', 'ورد من القرآن', '📖'),
  Habit('sadaqah', 'صدقة أو عمل خير', '🤲'),
];

/// يتتبع إنجاز عادات يومية ثابتة (أذكار الصباح/المساء، الصلوات، ورد القرآن،
/// الصدقة)، بحيث تُصفَّر حالة "اليوم" تلقائياً كل يوم جديد، مع سلسلة أيام
/// متتالية (streak) مستقلة لكل عادة، محفوظة محلياً.
class HabitsProvider extends ChangeNotifier {
  final Map<String, bool> _todayChecked = {};
  final Map<String, int> _streaks = {};
  bool _loaded = false;

  bool get loaded => _loaded;
  bool isChecked(String id) => _todayChecked[id] ?? false;
  int streakFor(String id) => _streaks[id] ?? 0;

  int get completedTodayCount => _todayChecked.values.where((v) => v).length;

  HabitsProvider() {
    _load();
  }

  String _dateKeyFor(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  String _todayKey() => _dateKeyFor(DateTime.now());
  String _yesterdayKey() => _dateKeyFor(DateTime.now().subtract(const Duration(days: 1)));

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    for (final h in kHabits) {
      final lastDate = prefs.getString('habit_${h.id}_lastDate');
      _streaks[h.id] = prefs.getInt('habit_${h.id}_streak') ?? 0;
      _todayChecked[h.id] = lastDate == today && (prefs.getBool('habit_${h.id}_doneToday') ?? false);
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> toggle(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    final yesterday = _yesterdayKey();
    final currentlyChecked = _todayChecked[id] ?? false;
    final newChecked = !currentlyChecked;
    _todayChecked[id] = newChecked;

    final lastDate = prefs.getString('habit_${id}_lastDate');
    var streak = _streaks[id] ?? 0;

    if (newChecked) {
      if (lastDate == yesterday) {
        streak += 1;
      } else if (lastDate != today) {
        streak = 1;
      }
      await prefs.setString('habit_${id}_lastDate', today);
      await prefs.setBool('habit_${id}_doneToday', true);
    } else {
      // إلغاء التحديد بنفس اليوم: نتراجع عن الزيادة لو كانت صارت اليوم فقط.
      if (lastDate == today) {
        streak = streak > 0 ? streak - 1 : 0;
      }
      await prefs.setBool('habit_${id}_doneToday', false);
    }

    _streaks[id] = streak;
    await prefs.setInt('habit_${id}_streak', streak);
    notifyListeners();
  }
}
