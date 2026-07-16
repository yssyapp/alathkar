import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/stats_provider.dart';
import '../providers/theme_provider.dart';

/// شاشة إحصائيات بسيطة: سلسلة الأيام المتتالية، أفضل سلسلة، أذكار اليوم، والإجمالي.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final stats = context.watch<StatsProvider>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient(isDark)),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context, isDark),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            isDark: isDark,
                            icon: '🔥',
                            value: '${stats.streak}',
                            label: 'يوم متتالي',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            isDark: isDark,
                            icon: '🏆',
                            value: '${stats.bestStreak}',
                            label: 'أفضل سلسلة',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            isDark: isDark,
                            icon: '📿',
                            value: '${stats.todayCount}',
                            label: 'أذكار اليوم',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            isDark: isDark,
                            icon: '✨',
                            value: '${stats.totalAllTime}',
                            label: 'إجمالي كل الأوقات',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.gold.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.25)),
                      ),
                      child: Text(
                        'يُحسب "الذكر المكتمل" لما تخلّص عدّ التكرار المطلوب لذكر معيّن (زي التسبيح 33 مرة). واصل يومياً عشان تحافظ على سلسلتك 🔥',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(fontSize: 13, color: AppTheme.subTextColor(isDark), height: 1.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppTheme.cardGradient(isDark),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3)),
              ),
              child: Icon(Icons.arrow_forward_ios, color: AppTheme.gold, size: 20),
            ),
          ),
          const Spacer(),
          Text(
            'إحصائياتي',
            style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.gold),
          ),
          const Spacer(),
          const SizedBox(width: 36),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required bool isDark,
    required String icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.cairo(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.gold)),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.cairo(fontSize: 13, color: AppTheme.subTextColor(isDark))),
        ],
      ),
    );
  }
}
