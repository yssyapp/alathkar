import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../data/athkar_data.dart';
import '../data/daily_reflection_data.dart';
import '../providers/favorites_provider.dart';
import '../providers/khatma_provider.dart';
import '../providers/prayer_notification_provider.dart';
import '../providers/random_dhikr_notification_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/moon_phase.dart';
import '../utils/prayer_times.dart';
import '../widgets/dhikr_card.dart';
import '../widgets/zakat_calculator_sheet.dart';
import 'asma_allah_screen.dart';
import 'athkar_categories_screen.dart';
import 'counters_screen.dart';
import 'favorites_screen.dart';
import 'habits_screen.dart';
import 'hijri_calendar_screen.dart';
import 'nearby_mosque_screen.dart';
import 'qibla_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';

const _arWeekdays = ['الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
const _arMonths = [
  'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
  'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
];

String _formatDuration(Duration d) {
  if (d.isNegative) return toArabicDigits('٠٠:٠٠:٠٠');
  final h = d.inHours.remainder(24).toString().padLeft(2, '0');
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return toArabicDigits('$h:$m:$s');
}

String _formatTime12(DateTime t) {
  final h12 = t.hour % 12 == 0 ? 12 : t.hour % 12;
  final period = t.hour < 12 ? 'ص' : 'م';
  return '${toArabicDigits('$h12:${t.minute.toString().padLeft(2, '0')}')} $period';
}

/// الشاشة الرئيسية الجديدة: لوحة معلومات ديناميكية بصفحة واحدة (Dashboard)
/// تتغيّر محتوياتها تلقائياً حسب الوقت الحالي والمناسبة (الجمعة، رمضان).
///
/// النطاق المُنجَز فعلياً في هذه النسخة: عدّاد ومواقيت صلاة محسوبة فلكياً
/// حقيقياً (موقع افتراضي: جدة)، تاريخ هجري حقيقي، متتبّع ورد يومي محفوظ
/// محلياً، حاسبة زكاة، طور القمر، عدّادات تسبيح/حمد/استغفار ومسبحة حرة،
/// اتجاه قبلة حقيقي عبر GPS وبوصلة الجهاز (يحتاج جهاز حقيقي، لا يعمل على
/// محاكي iOS)، ومحتوى متجدد من محتوى التطبيق المُتحقَّق منه، وبطاقات
/// الجمعة/رمضان الظرفية. أما الاستماع الصوتي فيحتاج حزمة وصلاحيات إضافية
/// ويظهر حالياً كبطاقة "قريباً" أنيقة تمهيداً لبنائها لاحقاً. ميزة المصحف حُذفت بالكامل من هذه النسخة (راجع
/// pubspec.yaml) وستُبنى من جديد لاحقاً بشكل مستقل ونظيف.
class DashboardHomeScreen extends StatefulWidget {
  const DashboardHomeScreen({super.key});

  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen> {
  static const PrayerTimesCalculator _calculator = PrayerTimesCalculator();

  late final DateTime _today;
  late final PrayerTimesResult _todayTimes;
  late final DateTime _tomorrowFajr;
  late final HijriCalendar _hijriToday;
  int _khatmaTab = 0;

  @override
  void initState() {
    super.initState();
    HijriCalendar.setLocal('ar');
    _today = DateTime.now();
    _todayTimes = _calculator.calculate(_today);
    _tomorrowFajr = _calculator.calculate(_today.add(const Duration(days: 1))).fajr;
    _hijriToday = HijriCalendar.fromDate(_today);
    // نمدّد نافذة جدولة تنبيهات أذان الصلاة لأقرب ٧ أيام قادمة في كل مرة
    // يُفتح فيها التطبيق (لو كانت مفعّلة أصلاً)، حتى لا تتوقف التنبيهات.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PrayerNotificationProvider>().refreshIfEnabled();
      context.read<RandomDhikrNotificationProvider>().refreshIfEnabled();
    });
  }

  bool get _isFriday => _today.weekday == DateTime.friday;
  bool get _isRamadan => _hijriToday.hMonth == 9;

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient(isDark)),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 118),
                children: [
                  _buildTopIconsRow(context, isDark),
                  const SizedBox(height: 10),
                  _buildPrayerHeroCard(isDark),
                  const SizedBox(height: 20),
                  _sectionTitle(isDark, 'آية وحديث اليوم', null),
                  const SizedBox(height: 10),
                  _buildDailyAyahCard(isDark),
                  const SizedBox(height: 12),
                  _buildDailyHadithCard(isDark),
                  const SizedBox(height: 20),
                  _sectionTitle(isDark, 'أدواتك اليوم', '٩ أقسام'),
                  const SizedBox(height: 10),
                  _buildToolsGrid(context, isDark),
                  const SizedBox(height: 20),
                  _buildKhatmaCard(context, isDark),
                  const SizedBox(height: 20),
                  _sectionTitle(isDark, 'محتوى متجدد', null),
                  const SizedBox(height: 10),
                  DhikrCard(
                    key: ValueKey('rotating-${_today.hour ~/ 4}-${_today.day}'),
                    dhikr: AthkarData.rotatingContent(_today),
                    initiallyExpanded: true,
                  ),
                  if (_isFriday) ...[
                    const SizedBox(height: 16),
                    _buildFridayCard(isDark),
                  ],
                  if (_isRamadan) ...[
                    const SizedBox(height: 16),
                    _buildRamadanCard(isDark),
                  ],
                  const SizedBox(height: 20),
                  _buildQuickIconsRow(context, isDark),
                ],
              ),
              Positioned(left: 16, right: 16, bottom: 14, child: _buildBottomNav(context, isDark)),
            ],
          ),
        ),
      ),
    );
  }

  // ============== الشريط العلوي (بحث/إحصائيات/مفضلة/وضع العرض) ==============

  Widget _buildTopIconsRow(BuildContext context, bool isDark) {
    final favoritesCount = context.watch<FavoritesProvider>().count;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            _iconButton(icon: Icons.search_rounded, isDark: isDark, onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
            }),
            const SizedBox(width: 8),
            _iconButton(icon: Icons.bar_chart_rounded, isDark: isDark, onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const StatsScreen()));
            }),
          ],
        ),
        Row(
          children: [
            _iconButton(icon: Icons.settings_outlined, isDark: isDark, onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            }),
            const SizedBox(width: 8),
            _iconButton(icon: Icons.favorite_rounded, isDark: isDark, badgeCount: favoritesCount, onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen()));
            }),
            const SizedBox(width: 8),
            _iconButton(icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined, isDark: isDark, onTap: () {
              context.read<ThemeProvider>().toggleTheme();
            }),
          ],
        ),
      ],
    );
  }

  Widget _iconButton({required IconData icon, required bool isDark, required VoidCallback onTap, int badgeCount = 0}) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: AppTheme.cardGradient(isDark),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: AppTheme.gold, size: 19),
          ),
          if (badgeCount > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(gradient: AppTheme.goldGradient, shape: BoxShape.circle),
                constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
                child: Text('$badgeCount', textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.darkBackground)),
              ),
            ),
        ],
      ),
    );
  }

  // ============== بطاقة العدّاد ومواقيت الصلاة ==============

  Widget _buildPrayerHeroCard(bool isDark) {
    final hijri = _hijriToday;
    final gDayName = _arWeekdays[_today.weekday - 1];
    final gDate = '${toArabicDigits('${_today.day}')} ${_arMonths[_today.month - 1]} ${toArabicDigits('${_today.year}')}';
    final hDate = '$gDayName ${toArabicDigits('${hijri.hDay}')} ${hijri.getLongMonthName()} ${toArabicDigits('${hijri.hYear}')} هـ';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: AppTheme.toolEmerald.withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.nightlight_round, color: Colors.white70, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(hDate, textAlign: TextAlign.right,
                    style: GoogleFonts.cairo(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.92))),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Align(
            alignment: Alignment.centerRight,
            child: Text('$gDate · جدة', style: GoogleFonts.cairo(fontSize: 11, color: Colors.white.withValues(alpha: 0.65))),
          ),
          const SizedBox(height: 16),
          _PrayerCountdownLive(todayTimes: _todayTimes, tomorrowFajr: _tomorrowFajr),
          const SizedBox(height: 8),
          Text('مواقيت جدة (حساب فلكي حقيقي) — تحديد الموقع تلقائياً قريباً',
              style: GoogleFonts.cairo(fontSize: 9.5, color: Colors.white.withValues(alpha: 0.55))),
        ],
      ),
    );
  }

  // ============== أدواتك اليوم ==============

  Widget _sectionTitle(bool isDark, String title, String? trailing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (trailing != null) Text(trailing, style: GoogleFonts.cairo(fontSize: 11.5, color: AppTheme.subTextColor(isDark))),
        Text(title, style: GoogleFonts.cairo(fontSize: 16.5, fontWeight: FontWeight.w800, color: AppTheme.textColor(isDark))),
      ],
    );
  }

  Widget _buildToolsGrid(BuildContext context, bool isDark) {
    final khatma = context.watch<KhatmaProvider>();
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 0.92,
      children: [
        _toolCard(isDark, icon: Icons.auto_stories_rounded, accent: AppTheme.gold, title: 'الأذكار', subtitle: 'صباح · مساء', onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AthkarCategoriesScreen()));
        }),
        _toolCard(isDark, icon: Icons.explore_outlined, accent: AppTheme.toolTeal, title: 'القبلة', subtitle: 'اتجاه دقيق', onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const QiblaScreen()));
        }),
        _toolCard(isDark, icon: Icons.savings_outlined, accent: AppTheme.toolAmber, title: 'الزكاة', subtitle: 'مال · ذهب', onTap: () {
          ZakatCalculatorSheet.show(context, isDark);
        }),
        _toolCard(isDark, icon: Icons.menu_book_outlined, accent: AppTheme.toolSage, title: 'ورد الختمة',
            subtitle: 'اليوم ${toArabicDigits('${khatma.currentDay}')} من ٣٠', onTap: () async {
          if (khatma.completedToday) {
            _snack('أتممت ورد اليوم بالفعل، جزاك الله خيراً 🌙');
          } else {
            await context.read<KhatmaProvider>().markTodayDone();
            if (mounted) _snack('بارك الله فيك، تم تسجيل ورد اليوم ✅');
          }
        }),
        _toolCard(isDark, icon: Icons.calendar_month_outlined, accent: AppTheme.toolMint, title: 'التقويم الهجري',
            subtitle: _hijriToday.getLongMonthName(), onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const HijriCalendarScreen()));
        }),
        _toolCard(isDark, icon: Icons.fingerprint, accent: AppTheme.toolEmerald, title: 'العدادات', subtitle: 'تسبيح · حمد · استغفار', onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const CountersScreen()));
        }),
        _toolCard(isDark, icon: Icons.checklist_rounded, accent: AppTheme.toolOlive, title: 'العادات', subtitle: 'تعقّب يومي', onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const HabitsScreen()));
        }),
        _toolCard(isDark, icon: Icons.auto_awesome_outlined, accent: AppTheme.gold, title: 'أسماء الله', subtitle: 'الحسنى', onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AsmaAllahScreen()));
        }),
        _toolCard(isDark, icon: Icons.mosque_rounded, accent: AppTheme.toolMint, title: 'أقرب مسجد', subtitle: 'عبر الخرائط', onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const NearbyMosqueScreen()));
        }),
      ],
    );
  }

  Widget _toolCard(bool isDark, {
    required IconData icon,
    required Color accent,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool comingSoon = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: AppTheme.cardGradient(isDark),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accent.withValues(alpha: 0.28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: accent.withValues(alpha: 0.14), boxShadow: AppTheme.softGlow(accent)),
                  child: Icon(icon, color: accent, size: 20),
                ),
                if (comingSoon)
                  Positioned(
                    top: -6,
                    right: -10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(color: AppTheme.subTextColor(isDark).withValues(alpha: 0.25), borderRadius: BorderRadius.circular(6)),
                      child: Text('قريباً', style: GoogleFonts.cairo(fontSize: 7.5, color: AppTheme.subTextColor(isDark), fontWeight: FontWeight.w700)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center,
                style: GoogleFonts.cairo(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppTheme.textColor(isDark))),
            const SizedBox(height: 2),
            Text(subtitle, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(fontSize: 9.5, color: AppTheme.subTextColor(isDark))),
          ],
        ),
      ),
    );
  }

  // ============== آية وحديث اليوم ==============

  Widget _buildDailyAyahCard(bool isDark) {
    final ayah = ayahOfTheDay(_today);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient(isDark),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.menu_book_outlined, color: AppTheme.gold, size: 18),
              const SizedBox(width: 8),
              Text('آية اليوم', style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.gold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            ayah.text,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textColor(isDark), height: 1.9),
          ),
          const SizedBox(height: 6),
          Text(ayah.reference, textAlign: TextAlign.center, style: GoogleFonts.cairo(fontSize: 11.5, color: AppTheme.subTextColor(isDark))),
          const SizedBox(height: 14),
          Divider(color: AppTheme.gold.withValues(alpha: 0.15), height: 1),
          const SizedBox(height: 12),
          Text('التفسير الميسّر:', style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.toolEmerald)),
          const SizedBox(height: 6),
          Text(ayah.tafsir, style: GoogleFonts.cairo(fontSize: 12.5, color: AppTheme.subTextColor(isDark), height: 1.7)),
          const SizedBox(height: 6),
          Text('(${ayah.tafsirSource})', style: GoogleFonts.cairo(fontSize: 10.5, color: AppTheme.subTextColor(isDark))),
        ],
      ),
    );
  }

  Widget _buildDailyHadithCard(bool isDark) {
    final hadith = hadithOfTheDay(_today);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient(isDark),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.toolEmerald.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.record_voice_over_outlined, color: AppTheme.toolEmerald, size: 18),
              const SizedBox(width: 8),
              Text('حديث اليوم', style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.toolEmerald)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            hadith.text,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textColor(isDark), height: 1.9),
          ),
          const SizedBox(height: 6),
          Text('عن ${hadith.narrator} — ${hadith.source}',
              textAlign: TextAlign.center, style: GoogleFonts.cairo(fontSize: 11.5, color: AppTheme.subTextColor(isDark))),
          const SizedBox(height: 14),
          Divider(color: AppTheme.toolEmerald.withValues(alpha: 0.15), height: 1),
          const SizedBox(height: 12),
          Text('الشرح:', style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.gold)),
          const SizedBox(height: 6),
          Text(hadith.sharh, style: GoogleFonts.cairo(fontSize: 12.5, color: AppTheme.subTextColor(isDark), height: 1.7)),
        ],
      ),
    );
  }

  // ============== بطاقة الورد اليومي / الاستماع ==============

  Widget _buildKhatmaCard(BuildContext context, bool isDark) {
    final khatma = context.watch<KhatmaProvider>();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient(isDark),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.toolEmerald.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05), borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                _tabButton(isDark, 'الورد اليومي', 0),
                _tabButton(isDark, 'استماع للقرآن', 1),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_khatmaTab == 0) _buildWirdTab(context, isDark, khatma) else _buildListenTab(isDark),
        ],
      ),
    );
  }

  Widget _tabButton(bool isDark, String label, int index) {
    final selected = _khatmaTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _khatmaTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: selected ? AppTheme.heroGradientSoft : null,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Text(label, textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppTheme.subTextColor(isDark))),
        ),
      ),
    );
  }

  Widget _buildWirdTab(BuildContext context, bool isDark, KhatmaProvider khatma) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('ورد الختمة', style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textColor(isDark))),
            Text('اليوم ${toArabicDigits('${khatma.currentDay}')} من ٣٠',
                style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.toolEmerald)),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: khatma.progress.clamp(0.0, 1.0).toDouble(),
            minHeight: 9,
            backgroundColor: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
            valueColor: const AlwaysStoppedAnimation(AppTheme.toolEmerald),
          ),
        ),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: khatma.completedToday ? null : () => context.read<KhatmaProvider>().markTodayDone(),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              gradient: khatma.completedToday ? null : AppTheme.heroGradientSoft,
              color: khatma.completedToday ? AppTheme.toolEmerald.withValues(alpha: 0.15) : null,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(khatma.completedToday ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
                    color: khatma.completedToday ? AppTheme.toolEmerald : Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(khatma.completedToday ? 'تم إتمام ورد اليوم' : 'أتممت هذا الورد',
                    style: GoogleFonts.cairo(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: khatma.completedToday ? AppTheme.toolEmerald : Colors.white)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListenTab(bool isDark) {
    return Opacity(
      opacity: 0.6,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.subTextColor(isDark).withValues(alpha: 0.15)),
              child: Icon(Icons.play_arrow_rounded, color: AppTheme.subTextColor(isDark), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('الاستماع للقرآن', style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textColor(isDark))),
                  const SizedBox(height: 2),
                  Text('مشغّل صوتي بأصوات القرّاء — قريباً بإذن الله',
                      style: GoogleFonts.cairo(fontSize: 10.5, color: AppTheme.subTextColor(isDark))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============== بطاقات الجمعة ورمضان ==============

  Widget _buildFridayCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.toolTeal.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.toolTeal.withValues(alpha: 0.14), boxShadow: AppTheme.softGlow(AppTheme.toolTeal)),
            child: const Icon(Icons.mosque_outlined, color: AppTheme.toolTeal, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('يوم الجمعة — سيد الأيام', style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textColor(isDark))),
                const SizedBox(height: 6),
                Text(
                  'يُستحبّ اليوم الإكثار من الصلاة على النبي ﷺ، وقراءة سورة الكهف، وتحرّي ساعة الإجابة في آخر ساعة قبل المغرب.',
                  style: GoogleFonts.cairo(fontSize: 12, color: AppTheme.subTextColor(isDark), height: 1.7),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRamadanCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradientSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.nights_stay_outlined, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text('رمضان مبارك', style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _ramadanTimeBox('الإمساك (الفجر)', _formatTime12(_todayTimes.fajr))),
              const SizedBox(width: 10),
              Expanded(child: _ramadanTimeBox('الإفطار (المغرب)', _formatTime12(_todayTimes.maghrib))),
            ],
          ),
          const SizedBox(height: 12),
          Text('من أدعية الإفطار المأثورة: «اللهم لك صمت، وعلى رزقك أفطرت»، و«ذهب الظمأ وابتلت العروق وثبت الأجر إن شاء الله».',
              style: GoogleFonts.cairo(fontSize: 11.5, color: Colors.white.withValues(alpha: 0.85), height: 1.7)),
        ],
      ),
    );
  }

  Widget _ramadanTimeBox(String label, String time) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          Text(label, style: GoogleFonts.cairo(fontSize: 10.5, color: Colors.white.withValues(alpha: 0.75))),
          const SizedBox(height: 4),
          Text(time, style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.lightGold)),
        ],
      ),
    );
  }

  // ============== أدوات سريعة (زكاة / طور القمر) ==============

  Widget _buildQuickIconsRow(BuildContext context, bool isDark) {
    return Row(
      children: [
        Expanded(child: _quickIconTile(isDark, icon: Icons.savings_outlined, accent: AppTheme.toolAmber, label: 'حساب الزكاة', onTap: () => ZakatCalculatorSheet.show(context, isDark))),
        const SizedBox(width: 12),
        Expanded(child: _quickIconTile(isDark, icon: Icons.dark_mode_outlined, accent: AppTheme.toolMint, label: 'حالة القمر', onTap: () => _showMoonPhase(isDark))),
      ],
    );
  }

  Widget _quickIconTile(bool isDark, {required IconData icon, required Color accent, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: AppTheme.cardGradient(isDark),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accent.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: accent, size: 22),
            const SizedBox(height: 6),
            Text(label, style: GoogleFonts.cairo(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppTheme.textColor(isDark))),
          ],
        ),
      ),
    );
  }

  void _showMoonPhase(bool isDark) {
    final info = MoonPhaseCalculator.calculate(DateTime.now());
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: AppTheme.cardGradient(isDark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(info.emoji, style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text(info.name, style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textColor(isDark))),
            const SizedBox(height: 6),
            Text('نسبة الإضاءة التقريبية: ${toArabicDigits((info.illumination * 100).round().toString())}٪',
                style: GoogleFonts.cairo(fontSize: 12.5, color: AppTheme.subTextColor(isDark))),
            const SizedBox(height: 4),
            Text('حساب تقريبي بالدورة القمرية — للتقويم الهجري الدقيق راجع مصادر الرؤية الشرعية',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(fontSize: 10.5, color: AppTheme.subTextColor(isDark))),
          ],
        ),
      ),
    );
  }

  // ============== الشريط السفلي العائم ==============

  Widget _buildBottomNav(BuildContext context, bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor(isDark).withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AppTheme.gold.withValues(alpha: 0.25)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navIcon(isDark, Icons.explore_outlined, 'القبلة', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const QiblaScreen()));
              }),
              _navIcon(isDark, Icons.auto_stories_rounded, 'الأذكار', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AthkarCategoriesScreen()));
              }, highlighted: true),
              _navIcon(isDark, Icons.calendar_month_outlined, 'التقويم', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const HijriCalendarScreen()));
              }),
              _navIcon(isDark, Icons.settings_outlined, 'الإعدادات', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navIcon(bool isDark, IconData icon, String label, VoidCallback onTap, {bool highlighted = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: highlighted ? AppTheme.goldGradient : null,
              boxShadow: highlighted ? AppTheme.softGlow(AppTheme.gold, opacity: 0.5) : null,
            ),
            child: Icon(icon, size: 20, color: highlighted ? AppTheme.darkBackground : AppTheme.subTextColor(isDark)),
          ),
          const SizedBox(height: 3),
          Text(label, style: GoogleFonts.cairo(fontSize: 9, fontWeight: FontWeight.w600, color: highlighted ? AppTheme.gold : AppTheme.subTextColor(isDark))),
        ],
      ),
    );
  }

  // ============== مساعدات عامة ==============

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.cairo(), textDirection: TextDirection.rtl),
        backgroundColor: AppTheme.toolEmerald,
      ),
    );
  }
}

/// عدّاد حيّ (يتحدّث كل ثانية) للصلاة القادمة + شريط أوقات اليوم — مُعزول
/// في ودجت خاص به حتى لا تُعاد بناء الشاشة الرئيسية كاملة كل ثانية
/// (تحسين أداء: التحديث الدوري محصور في أصغر جزء ممكن من الشجرة).
class _PrayerCountdownLive extends StatefulWidget {
  final PrayerTimesResult todayTimes;
  final DateTime tomorrowFajr;

  const _PrayerCountdownLive({required this.todayTimes, required this.tomorrowFajr});

  @override
  State<_PrayerCountdownLive> createState() => _PrayerCountdownLiveState();
}

class _PrayerCountdownLiveState extends State<_PrayerCountdownLive> {
  Timer? _ticker;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final next = widget.todayTimes.nextPrayer(_now, widget.tomorrowFajr);
    final remaining = next.value.difference(_now);
    final currentName = widget.todayTimes.currentPrayerName(_now);

    return Column(
      children: [
        Text('الوقت المتبقي لأذان ${next.key}',
            style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.85))),
        const SizedBox(height: 10),
        Text(_formatDuration(remaining),
            style: GoogleFonts.cairo(fontSize: 44, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text('${next.key} ${_formatTime12(next.value)}',
            style: GoogleFonts.cairo(fontSize: 12.5, color: AppTheme.lightGold, fontWeight: FontWeight.w700)),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(18)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: widget.todayTimes.allTimes.map((p) {
              final isCurrent = p.key == currentName;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCurrent ? AppTheme.lightGold.withValues(alpha: 0.22) : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(p.key,
                        style: GoogleFonts.cairo(
                            fontSize: 10.5,
                            fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
                            color: isCurrent ? AppTheme.lightGold : Colors.white.withValues(alpha: 0.75))),
                  ),
                  const SizedBox(height: 3),
                  Text(_formatTime12(p.value).replaceAll(RegExp(r' [صم]'), ''),
                      style: GoogleFonts.cairo(
                          fontSize: 11.5,
                          fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                          color: isCurrent ? Colors.white : Colors.white.withValues(alpha: 0.8))),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
