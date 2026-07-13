import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/reminder_provider.dart';
import '../providers/theme_provider.dart';

/// شاشة إعدادات تذكيرات أذكار الصباح والمساء (تفعيل/تعطيل واختيار الوقت).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'ص' : 'م';
    return '$hour:$minute $period';
  }

  Future<void> _pickTime(
    BuildContext context,
    TimeOfDay initial,
    ValueChanged<TimeOfDay> onPicked,
  ) async {
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) onPicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final reminders = context.watch<ReminderProvider>();

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
                    _buildSectionCard(
                      isDark: isDark,
                      children: [
                        _buildSwitchTile(
                          isDark: isDark,
                          title: 'تفعيل تذكيرات الصباح والمساء',
                          value: reminders.enabled,
                          onChanged: (v) => context.read<ReminderProvider>().setEnabled(v),
                        ),
                        if (reminders.enabled) ...[
                          const SizedBox(height: 14),
                          _buildTimeTile(
                            context: context,
                            isDark: isDark,
                            icon: '🌅',
                            label: 'وقت تذكير الصباح',
                            time: reminders.morningTime,
                            onTap: () => _pickTime(
                              context,
                              reminders.morningTime,
                              (t) => context.read<ReminderProvider>().setMorningTime(t),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildTimeTile(
                            context: context,
                            isDark: isDark,
                            icon: '🌙',
                            label: 'وقت تذكير المساء',
                            time: reminders.eveningTime,
                            onTap: () => _pickTime(
                              context,
                              reminders.eveningTime,
                              (t) => context.read<ReminderProvider>().setEveningTime(t),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'لو ما وصلك التذكير، تأكد إن إذن الإشعارات مفعّل للتطبيق من إعدادات الجهاز.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(fontSize: 12, color: AppTheme.subTextColor(isDark), height: 1.8),
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
              child: const Icon(Icons.arrow_forward_ios, color: AppTheme.gold, size: 20),
            ),
          ),
          const Spacer(),
          Text(
            'الإعدادات والتذكيرات',
            style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.gold),
          ),
          const Spacer(),
          const SizedBox(width: 36),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required bool isDark, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
    );
  }

  Widget _buildSwitchTile({
    required bool isDark,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Switch(value: value, onChanged: onChanged, activeColor: AppTheme.gold),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textColor(isDark)),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeTile({
    required BuildContext context,
    required bool isDark,
    required String icon,
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.gold.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.gold.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Text(
              _formatTime(time),
              style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.gold),
            ),
            const Spacer(),
            Text(label, style: GoogleFonts.cairo(fontSize: 14, color: AppTheme.textColor(isDark))),
            const SizedBox(width: 8),
            Text(icon, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
