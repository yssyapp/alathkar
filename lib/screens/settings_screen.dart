import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/app_strings.dart';
import '../providers/language_provider.dart';
import '../providers/online_features_provider.dart';
import '../providers/prayer_notification_provider.dart';
import '../providers/random_dhikr_notification_provider.dart';
import '../providers/reminder_provider.dart';
import '../providers/theme_provider.dart';
import '../services/backup_service.dart';

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
    final prayerNotifs = context.watch<PrayerNotificationProvider>();
    final randomDhikr = context.watch<RandomDhikrNotificationProvider>();

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
                        Text(
                          context.tr('language_section_title'),
                          textAlign: TextAlign.right,
                          style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textColor(isDark)),
                        ),
                        const SizedBox(height: 14),
                        _buildLanguagePicker(context, isDark),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      isDark: isDark,
                      children: [
                        Text(
                          'لون التطبيق الثانوي',
                          textAlign: TextAlign.right,
                          style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textColor(isDark)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'الأخضر يبقى دائماً اللون الأساسي للتطبيق — هذا فقط للون الثانوي (الحدود والأيقونات والعناوين).',
                          textAlign: TextAlign.right,
                          style: GoogleFonts.cairo(fontSize: 11.5, color: AppTheme.subTextColor(isDark), height: 1.6),
                        ),
                        const SizedBox(height: 14),
                        _buildAccentPicker(context, isDark),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      isDark: isDark,
                      children: [
                        _buildSwitchTile(
                          isDark: isDark,
                          title: 'تفعيل تنبيهات أذان الصلاة',
                          value: prayerNotifs.enabled,
                          onChanged: (v) => context.read<PrayerNotificationProvider>().setEnabled(v),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'تنبيه فور دخول وقت كل صلاة من الصلوات الخمس، بناءً على حساب فلكي حقيقي لمواقيت جدة.',
                          textAlign: TextAlign.right,
                          style: GoogleFonts.cairo(fontSize: 11.5, color: AppTheme.subTextColor(isDark), height: 1.6),
                        ),
                        if (prayerNotifs.enabled) ...[
                          const SizedBox(height: 14),
                          _buildPrayerMutePicker(context, isDark, prayerNotifs),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      isDark: isDark,
                      children: [
                        _buildSwitchTile(
                          isDark: isDark,
                          title: 'تفعيل تنبيهات ذكر عشوائي',
                          value: randomDhikr.enabled,
                          onChanged: (v) => context.read<RandomDhikrNotificationProvider>().setEnabled(v),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'تذكير عرضي بذكر قصير مختلف على مدار اليوم (بين ٧ص و١٠م)، زي تطبيق أذكاري.',
                          textAlign: TextAlign.right,
                          style: GoogleFonts.cairo(fontSize: 11.5, color: AppTheme.subTextColor(isDark), height: 1.6),
                        ),
                        if (randomDhikr.enabled) ...[
                          const SizedBox(height: 14),
                          _buildFrequencyPicker(context, isDark, randomDhikr),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 16),
                    _buildSectionCard(isDark: isDark, children: const [_OnlineFeaturesSection()]),
                    const SizedBox(height: 16),
                    _buildSectionCard(isDark: isDark, children: const [_BackupSection()]),
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

  Widget _buildLanguagePicker(BuildContext context, bool isDark) {
    final languageProvider = context.watch<LanguageProvider>();
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 10,
      runSpacing: 10,
      children: AppLanguage.values.map((lang) {
        final selected = languageProvider.language == lang;
        return GestureDetector(
          onTap: () => context.read<LanguageProvider>().setLanguage(lang),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? AppTheme.gold.withValues(alpha: 0.14) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: selected ? AppTheme.gold.withValues(alpha: 0.5) : AppTheme.subTextColor(isDark).withValues(alpha: 0.3)),
            ),
            child: Text(
              lang.nativeName,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? AppTheme.gold : AppTheme.subTextColor(isDark),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAccentPicker(BuildContext context, bool isDark) {
    final theme = context.watch<ThemeProvider>();
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 14,
      runSpacing: 10,
      children: List.generate(AppTheme.accentPresets.length, (index) {
        final preset = AppTheme.accentPresets[index];
        final selected = theme.accentIndex == index;
        return GestureDetector(
          onTap: () => context.read<ThemeProvider>().setAccent(index),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [preset.main, preset.light]),
                  border: Border.all(color: selected ? AppTheme.textColor(isDark) : Colors.transparent, width: 2.5),
                ),
                child: selected ? const Icon(Icons.check_rounded, color: Colors.white, size: 20) : null,
              ),
              const SizedBox(height: 4),
              Text(preset.name, style: GoogleFonts.cairo(fontSize: 10.5, color: AppTheme.subTextColor(isDark))),
            ],
          ),
        );
      }),
    );
  }

  /// شرائح (chips) لاختيار أي صلاة تريد كتم تنبيهها — كل الصلوات مفعّلة
  /// افتراضياً، والضغط على أي شريحة يطفئ/يشعّل تنبيه تلك الصلاة فقط.
  Widget _buildPrayerMutePicker(BuildContext context, bool isDark, PrayerNotificationProvider prayerNotifs) {
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 8,
      runSpacing: 8,
      children: PrayerNotificationProvider.allPrayerNames.map((name) {
        final muted = prayerNotifs.isMuted(name);
        return GestureDetector(
          onTap: () => context.read<PrayerNotificationProvider>().toggleMuted(name),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: muted ? Colors.transparent : AppTheme.gold.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: muted ? AppTheme.subTextColor(isDark).withValues(alpha: 0.3) : AppTheme.gold.withValues(alpha: 0.5)),
            ),
            child: Text(
              name,
              style: GoogleFonts.cairo(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: muted ? AppTheme.subTextColor(isDark) : AppTheme.gold,
                decoration: muted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// شرائح لاختيار عدد تنبيهات الذكر العشوائي يومياً (قليل / متوسط / كثير).
  Widget _buildFrequencyPicker(BuildContext context, bool isDark, RandomDhikrNotificationProvider randomDhikr) {
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 8,
      runSpacing: 8,
      children: RandomDhikrNotificationProvider.frequencyLevels.entries.map((entry) {
        final level = entry.key;
        final count = entry.value;
        final selected = randomDhikr.frequency == level;
        return GestureDetector(
          onTap: () => context.read<RandomDhikrNotificationProvider>().setFrequency(level),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? AppTheme.gold.withValues(alpha: 0.14) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: selected ? AppTheme.gold.withValues(alpha: 0.5) : AppTheme.subTextColor(isDark).withValues(alpha: 0.3)),
            ),
            child: Text(
              '$level (${toArabicDigits('$count')})',
              style: GoogleFonts.cairo(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: selected ? AppTheme.gold : AppTheme.subTextColor(isDark),
              ),
            ),
          ),
        );
      }).toList(),
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
        Switch(value: value, onChanged: onChanged, activeThumbColor: AppTheme.gold),
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

/// قسم "الميزات الاختيارية عبر الإنترنت" — معطّل افتراضياً بالكامل، ومجاني
/// ١٠٠٪ بدون إعلانات ولا اشتراك. تفعيله الوحيد المتاح حالياً: مواقيت صلاة
/// أدق عبر خدمة Aladhan المجانية (تحتاج صلاحية الموقع مرة واحدة فقط). أي
/// فشل بالاتصال يرجع التطبيق تلقائياً للحساب الفلكي المحلي بدون أي انقطاع.
class _OnlineFeaturesSection extends StatefulWidget {
  const _OnlineFeaturesSection();

  @override
  State<_OnlineFeaturesSection> createState() => _OnlineFeaturesSectionState();
}

class _OnlineFeaturesSectionState extends State<_OnlineFeaturesSection> {
  bool _loading = false;

  Future<void> _handleToggle(bool value) async {
    final provider = context.read<OnlineFeaturesProvider>();
    if (!value) {
      await provider.setOnlinePrayerTimesEnabled(false);
      return;
    }
    setState(() => _loading = true);
    try {
      var serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showError('onlineLocationServiceDisabled');
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        _showError('onlineLocationPermissionDenied');
        return;
      }
      final position = await Geolocator.getCurrentPosition().timeout(const Duration(seconds: 12));
      if (!mounted) return;
      await provider.setLocation(position.latitude, position.longitude);
      await provider.setOnlinePrayerTimesEnabled(true);
    } catch (_) {
      _showError('onlineLocationGenericError');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// يستقبل مفتاح الترجمة (وليس النص الجاهز) حتى يقدر يتحقق من [mounted]
  /// بنفسه مباشرة قبل استخدام context — بدل ما يعتمد على فحص يصير في مكان
  /// الاستدعاء (المحلّل الساكن static analyzer ما يقدر يربط بينهم عبر دالتين).
  void _showError(String messageKey) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr(messageKey), style: GoogleFonts.cairo())));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final online = context.watch<OnlineFeaturesProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.tr('onlineFeaturesSectionTitle'),
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textColor(isDark)),
        ),
        const SizedBox(height: 4),
        Text(
          context.tr('onlineFeaturesSectionSubtitle'),
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(fontSize: 11.5, color: AppTheme.subTextColor(isDark), height: 1.6),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _loading
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5)),
                  )
                : Switch(
                    value: online.onlinePrayerTimesEnabled,
                    onChanged: _handleToggle,
                    activeThumbColor: AppTheme.gold,
                  ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                context.tr('onlinePrayerTimesToggleLabel'),
                textAlign: TextAlign.right,
                style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textColor(isDark)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          context.tr('onlinePrayerTimesToggleSubtitle'),
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(fontSize: 11.5, color: AppTheme.subTextColor(isDark), height: 1.6),
        ),
      ],
    );
  }
}

/// قسم "النسخ الاحتياطي" — تصدير/استيراد محلي بالكامل عبر ملف JSON يشاركه
/// المستخدم بنفسه (لا يوجد أي خادم أو حساب سحابي تابع للتطبيق). يشمل
/// المفضلة والإحصائيات والعادات وتقدّم الختمة واللغة والثيم وكل الإعدادات.
class _BackupSection extends StatefulWidget {
  const _BackupSection();

  @override
  State<_BackupSection> createState() => _BackupSectionState();
}

class _BackupSectionState extends State<_BackupSection> {
  bool _busy = false;

  /// يستقبل مفتاح الترجمة (وليس النص الجاهز) حتى يقدر يتحقق من [mounted]
  /// بنفسه مباشرة قبل استخدام context — بدل ما يعتمد على فحص يصير في مكان
  /// الاستدعاء (المحلّل الساكن static analyzer ما يقدر يربط بينهم عبر دالتين).
  void _showMessage(String messageKey) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr(messageKey), style: GoogleFonts.cairo())));
  }

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      await BackupService.exportAndShare();
    } catch (_) {
      _showMessage('backupExportError');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    setState(() => _busy = true);
    try {
      final success = await BackupService.pickAndRestore();
      if (success) {
        _showMessage('backupImportSuccess');
      } else {
        _showMessage('backupImportError');
      }
    } catch (_) {
      _showMessage('backupImportError');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.tr('backupSectionTitle'),
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textColor(isDark)),
        ),
        const SizedBox(height: 4),
        Text(
          context.tr('backupSectionSubtitle'),
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(fontSize: 11.5, color: AppTheme.subTextColor(isDark), height: 1.6),
        ),
        const SizedBox(height: 14),
        if (_busy)
          const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator(strokeWidth: 2.5)))
        else
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _import,
                  icon: const Icon(Icons.file_open_outlined, size: 18),
                  label: Text(context.tr('backupImportButton'), style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 12.5)),
                  style: OutlinedButton.styleFrom(foregroundColor: AppTheme.gold, side: BorderSide(color: AppTheme.gold.withValues(alpha: 0.5))),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _export,
                  icon: const Icon(Icons.ios_share_outlined, size: 18),
                  label: Text(context.tr('backupExportButton'), style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 12.5)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.gold, foregroundColor: Colors.black),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
