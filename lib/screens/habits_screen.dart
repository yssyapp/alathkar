import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../providers/habits_provider.dart';

/// شاشة متعقب العادات اليومية: قائمة عادات ثابتة (أذكار الصباح/المساء،
/// الصلوات الخمس، ورد القرآن، الصدقة) يعلّم المستخدم عليها كل يوم، مع سلسلة
/// أيام متتالية (streak) لكل عادة كتحفيز.
class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final habits = context.watch<HabitsProvider>();

    return Scaffold(
      appBar: AppBar(title: Text('متعقب العادات', style: GoogleFonts.cairo(fontWeight: FontWeight.w700))),
      body: !habits.loaded
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildProgressHeader(isDark, habits),
                  const SizedBox(height: 20),
                  ...kHabits.map((h) => _buildHabitTile(context, isDark, habits, h)),
                ],
              ),
            ),
    );
  }

  Widget _buildProgressHeader(bool isDark, HabitsProvider habits) {
    final done = habits.completedTodayCount;
    final total = kHabits.length;
    final progress = total == 0 ? 0.0 : done / total;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient(isDark),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text(
            'أنجزت ${toArabicDigits('$done')} من ${toArabicDigits('$total')} اليوم',
            style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textColor(isDark)),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppTheme.gold.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation(AppTheme.gold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitTile(BuildContext context, bool isDark, HabitsProvider habits, Habit h) {
    final checked = habits.isChecked(h.id);
    final streak = habits.streakFor(h.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          HapticFeedback.selectionClick();
          context.read<HabitsProvider>().toggle(h.id);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: AppTheme.cardGradient(isDark),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: checked ? AppTheme.toolEmerald.withValues(alpha: 0.5) : AppTheme.gold.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Text(h.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      h.title,
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textColor(isDark),
                        decoration: checked ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (streak > 0) ...[
                      const SizedBox(height: 3),
                      Text('🔥 ${toArabicDigits('$streak')} يوم متتالي', style: GoogleFonts.cairo(fontSize: 11, color: AppTheme.subTextColor(isDark))),
                    ],
                  ],
                ),
              ),
              Icon(
                checked ? Icons.check_circle_rounded : Icons.circle_outlined,
                color: checked ? AppTheme.toolEmerald : AppTheme.subTextColor(isDark),
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
