import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/app_strings.dart';
import '../data/athkar_data.dart';
import '../data/daily_reflection_data.dart';
import '../providers/favorites_provider.dart';
import '../providers/khatma_provider.dart';
import '../providers/language_provider.dart';
import '../providers/online_features_provider.dart';
import '../providers/prayer_notification_provider.dart';
import '../providers/random_dhikr_notification_provider.dart';
import '../providers/theme_provider.dart';
import '../services/online_prayer_service.dart';
import '../utils/moon_phase.dart';
import '../utils/prayer_times.dart';
import '../widgets/dhikr_card.dart';
import '../widgets/zakat_calculator_sheet.dart';
import 'asma_allah_screen.dart';
import 'athkar_categories_screen.dart';
import 'azkar_tabs_screen.dart';
import 'counters_screen.dart';
import 'favorites_screen.dart';
import 'habits_screen.dart';
import 'hijri_calendar_screen.dart';
import 'nearby_mosque_screen.dart';
import 'qibla_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';

const _arMonths = [
  'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
  'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
];

String _formatTime12(DateTime t, AppLanguage lang) {
  final h12 = t.hour % 12 == 0 ? 12 : t.hour % 12;
  final String period;
  switch (lang) {
    case AppLanguage.ar:
      period = t.hour < 12 ? 'ص' : 'م';
      break;
    case AppLanguage.ur:
      period = t.hour < 12 ? 'صبح' : 'شام';
      break;
    case AppLanguage.en:
    case AppLanguage.id:
      period = t.hour < 12 ? 'AM' : 'PM';
      break;
  }
  return '${localizedDigits('$h12:${t.minute.toString().padLeft(2, '0')}', lang)} $period';
}

/// نفس [_formatTime12] لكن بدون لاحقة ص/م أو AM/PM — تُستخدم في الأماكن
/// الضيقة (شريط أوقات الصلاة) اللي ما فيها مساحة كافية لعرضها.
String _formatTime12NoPeriod(DateTime t, AppLanguage lang) {
  final h12 = t.hour % 12 == 0 ? 12 : t.hour % 12;
  return localizedDigits('$h12:${t.minute.toString().padLeft(2, '0')}', lang);
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
  late PrayerTimesResult _todayTimes;
  late DateTime _tomorrowFajr;
  // true فقط لو نجح جلب مواقيت أونلاين فعلاً وحلّت محل الحساب المحلي —
  // تُستخدم لعرض إشارة صغيرة "مواقيت أونلاين" بدل ما يبقى المستخدم غير
  // متأكد أي مصدر يُعرض له حالياً.
  bool _usingOnlinePrayerTimes = false;
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
      _tryLoadOnlinePrayerTimes();
    });
  }

  /// لو المستخدم فعّل "مواقيت صلاة أدق عبر الإنترنت" من الإعدادات وعنده
  /// موقع محفوظ، نحاول نجلب مواقيت اليوم وغد من خدمة Aladhan المجانية في
  /// الخلفية بدون ما نعطّل عرض الحساب المحلي أصلاً (يظهر فوراً كالمعتاد).
  /// أي فشل بالجلب (لا إنترنت، انقطاع، مهلة) يُتجاهل بصمت ويستمر الحساب
  /// المحلي كما هو — هذي الميزة إضافة اختيارية فقط، لا اعتماد عليها إطلاقاً.
  Future<void> _tryLoadOnlinePrayerTimes() async {
    final onlineSettings = context.read<OnlineFeaturesProvider>();
    if (!onlineSettings.onlinePrayerTimesEnabled || !onlineSettings.hasLocation) return;
    final lat = onlineSettings.latitude!;
    final lng = onlineSettings.longitude!;

    final results = await Future.wait([
      OnlinePrayerService.fetch(latitude: lat, longitude: lng, date: _today),
      OnlinePrayerService.fetch(latitude: lat, longitude: lng, date: _today.add(const Duration(days: 1))),
    ]);
    if (!mounted) return;
    final todayOnline = results[0];
    final tomorrowOnline = results[1];
    if (todayOnline != null) {
      setState(() {
        _todayTimes = todayOnline;
        if (tomorrowOnline != null) _tomorrowFajr = tomorrowOnline.fajr;
        _usingOnlinePrayerTimes = true;
      });
    }
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
                  _sectionTitle(isDark, context.tr('dashSectionAyahHadith'), null),
                  const SizedBox(height: 10),
                  _buildDailyAyahCard(isDark),
                  const SizedBox(height: 12),
                  _buildDailyHadithCard(isDark),
                  const SizedBox(height: 20),
                  _sectionTitle(isDark, context.tr('dashSectionToolsToday'), context.tr('dashToolsSectionCount')),
                  const SizedBox(height: 10),
                  _buildToolsGrid(context, isDark),
                  const SizedBox(height: 20),
                  _buildKhatmaCard(context, isDark),
                  const SizedBox(height: 20),
                  _sectionTitle(isDark, context.tr('dashSectionFreshContent'), null),
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
    final gDate = '${toArabicDigits('${_today.day}')} ${_arMonths[_today.month - 1]}، ${toArabicDigits('${_today.year}')}';
    final hDate = '${toArabicDigits('${hijri.hDay}')} ${hijri.getLongMonthName()}، ${toArabicDigits('${hijri.hYear}')} هـ';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: AppTheme.toolEmerald.withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          _buildDateBadge(gDate: gDate, hDate: hDate),
          const SizedBox(height: 18),
          _PrayerCountdownLive(todayTimes: _todayTimes, tomorrowFajr: _tomorrowFajr, isOnlineSource: _usingOnlinePrayerTimes),
          const SizedBox(height: 8),
          Text(context.tr('dashPrayerTimesFooterNote'),
              style: GoogleFonts.cairo(fontSize: 9.5, color: Colors.white.withValues(alpha: 0.55))),
        ],
      ),
    );
  }

  Widget _buildDateBadge({required String gDate, required String hDate}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.darkBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.toolEmerald.withValues(alpha: 0.25), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(gDate, textAlign: TextAlign.center,
              style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.3)),
          const SizedBox(height: 8),
          Text(hDate, textAlign: TextAlign.center,
              style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.toolEmerald, letterSpacing: 0.3)),
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
        _toolCard(isDark, icon: Icons.auto_stories_rounded, accent: AppTheme.gold, title: context.tr('dashToolAthkarTitle'), subtitle: context.tr('dashToolAthkarSubtitle'), onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AthkarCategoriesScreen()));
        }),
        _toolCard(isDark, icon: Icons.wb_twilight, accent: AppTheme.toolEmerald, title: 'الصباح والمساء', subtitle: 'عرض سريع بتبويبين', onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AzkarTabsScreen()));
        }),
        _toolCard(isDark, icon: Icons.explore_outlined, accent: AppTheme.toolTeal, title: context.tr('dashToolQiblaTitle'), subtitle: context.tr('dashToolQiblaSubtitle'), onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const QiblaScreen()));
        }),
        _toolCard(isDark, icon: Icons.savings_outlined, accent: AppTheme.toolAmber, title: context.tr('dashToolZakatTitle'), subtitle: context.tr('dashToolZakatSubtitle'), onTap: () {
          ZakatCalculatorSheet.show(context, isDark);
        }),
        _toolCard(isDark, icon: Icons.menu_book_outlined, accent: AppTheme.toolSage, title: context.tr('dashToolKhatmaTitle'),
            subtitle: 'اليوم ${toArabicDigits('${khatma.currentDay}')} من ٣٠', onTap: () async {
          if (khatma.completedToday) {
            _snack(context.tr('dashKhatmaAlreadyDoneMsg'));
          } else {
            await context.read<KhatmaProvider>().markTodayDone();
            if (!context.mounted) return;
            _snack(context.tr('dashKhatmaDoneMsg'));
          }
        }),
        _toolCard(isDark, icon: Icons.calendar_month_outlined, accent: AppTheme.toolMint, title: context.tr('dashToolHijriCalendarTitle'),
            subtitle: _hijriToday.getLongMonthName(), onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const HijriCalendarScreen()));
        }),
        _toolCard(isDark, icon: Icons.fingerprint, accent: AppTheme.toolEmerald, title: context.tr('dashToolCountersTitle'), subtitle: context.tr('dashToolCountersSubtitle'), onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const CountersScreen()));
        }),
        _toolCard(isDark, icon: Icons.checklist_rounded, accent: AppTheme.toolOlive, title: context.tr('dashToolHabitsTitle'), subtitle: context.tr('dashToolHabitsSubtitle'), onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const HabitsScreen()));
        }),
        _toolCard(isDark, icon: Icons.auto_awesome_outlined, accent: AppTheme.gold, title: context.tr('dashToolAsmaAllahTitle'), subtitle: context.tr('dashToolAsmaAllahSubtitle'), onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AsmaAllahScreen()));
        }),
        _toolCard(isDark, icon: Icons.mosque_rounded, accent: AppTheme.toolMint, title: context.tr('dashToolNearbyMosqueTitle'), subtitle: context.tr('dashToolNearbyMosqueSubtitle'), onTap: () {
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
                      child: Text(context.tr('dashComingSoonBadge'), style: GoogleFonts.cairo(fontSize: 7.5, color: AppTheme.subTextColor(isDark), fontWeight: FontWeight.w700)),
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

  /// تفسير الآية بنفس التفسير المعتمد (تفسير السعدي) مترجماً للغة الحالية،
  /// مع بقاء النص القرآني نفسه بالعربية دوماً دون أي تغيير.
  String _ayahTafsirFor(DailyAyah ayah, AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ar:
        return ayah.tafsir;
      case AppLanguage.en:
        return ayah.tafsirEn ?? ayah.tafsir;
      case AppLanguage.id:
        return ayah.tafsirId ?? ayah.tafsir;
      case AppLanguage.ur:
        return ayah.tafsirUr ?? ayah.tafsir;
    }
  }

  Widget _buildDailyAyahCard(bool isDark) {
    final ayah = ayahOfTheDay(_today);
    final lang = context.watch<LanguageProvider>().language;
    final tafsir = _ayahTafsirFor(ayah, lang);
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
              Text(context.tr('dashAyahOfDayLabel'), style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.gold)),
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
          Text(context.tr('dashTafsirLabel'), style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.toolEmerald)),
          const SizedBox(height: 6),
          Text(tafsir, style: GoogleFonts.cairo(fontSize: 12.5, color: AppTheme.subTextColor(isDark), height: 1.7)),
          const SizedBox(height: 6),
          Text('(${ayah.tafsirSource})', style: GoogleFonts.cairo(fontSize: 10.5, color: AppTheme.subTextColor(isDark))),
        ],
      ),
    );
  }

  /// معنى الحديث المترجم للغة الحالية (يبقى null للعربية، لأن نص الحديث
  /// الأصلي يُعرض دوماً بالعربية ولا يُستبدل بترجمة).
  String? _hadithMeaningFor(DailyHadith hadith, AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ar:
        return null;
      case AppLanguage.en:
        return hadith.textEn;
      case AppLanguage.id:
        return hadith.textId;
      case AppLanguage.ur:
        return hadith.textUr;
    }
  }

  /// شرح الحديث بلغة الواجهة الحالية، مع الرجوع للشرح العربي إذا لم تتوفر
  /// ترجمة بعد لتلك اللغة (بدل ترك القسم فارغاً).
  String _hadithSharhFor(DailyHadith hadith, AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ar:
        return hadith.sharh;
      case AppLanguage.en:
        return hadith.sharhEn ?? hadith.sharh;
      case AppLanguage.id:
        return hadith.sharhId ?? hadith.sharh;
      case AppLanguage.ur:
        return hadith.sharhUr ?? hadith.sharh;
    }
  }

  Widget _buildDailyHadithCard(bool isDark) {
    final hadith = hadithOfTheDay(_today);
    final lang = context.watch<LanguageProvider>().language;
    final meaning = _hadithMeaningFor(hadith, lang);
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
              Text(context.tr('dashHadithOfDayLabel'), style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.toolEmerald)),
            ],
          ),
          const SizedBox(height: 12),
          // راوي الحديث (الصحابي) يُذكر أولاً فوق نص الحديث، تماماً كما
          // يُقدَّم في كتب الحديث ("عن فلان قال...")، ثم يأتي التخريج
          // (الراوي/المصدر) أسفل الحديث بدل خلطهما معاً في سطر واحد.
          Text('عن ${hadith.narrator}',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.toolEmerald)),
          const SizedBox(height: 8),
          Text(
            hadith.text,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textColor(isDark), height: 1.9),
          ),
          // نص الحديث نفسه يبقى دائماً بالعربية (لا يُترجم حرفياً كنص شرعي)،
          // لكن معناه المترجم يُعرض تحته لغير الناطقين بالعربية.
          if (meaning != null) ...[
            const SizedBox(height: 8),
            Text(meaning,
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(fontSize: 12.5, fontStyle: FontStyle.italic, color: AppTheme.subTextColor(isDark), height: 1.7)),
          ],
          const SizedBox(height: 6),
          Text(hadith.source,
              textAlign: TextAlign.center, style: GoogleFonts.cairo(fontSize: 11.5, color: AppTheme.subTextColor(isDark))),
          const SizedBox(height: 14),
          Divider(color: AppTheme.toolEmerald.withValues(alpha: 0.15), height: 1),
          const SizedBox(height: 12),
          Text(context.tr('dashExplanationLabel'), style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.gold)),
          const SizedBox(height: 6),
          Text(_hadithSharhFor(hadith, lang), style: GoogleFonts.cairo(fontSize: 12.5, color: AppTheme.subTextColor(isDark), height: 1.7)),
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
                _tabButton(isDark, context.tr('dashTabDailyWird'), 0),
                _tabButton(isDark, context.tr('dashTabListenQuran'), 1),
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
            Text(context.tr('dashToolKhatmaTitle'), style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textColor(isDark))),
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
                Text(khatma.completedToday ? context.tr('dashKhatmaCompletedLabel') : context.tr('dashKhatmaCompleteButtonLabel'),
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
                  Text(context.tr('dashListenQuranTitle'), style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textColor(isDark))),
                  const SizedBox(height: 2),
                  Text(context.tr('dashListenQuranComingSoonDesc'),
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
                Text(context.tr('dashFridayTitle'), style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textColor(isDark))),
                const SizedBox(height: 6),
                Text(
                  context.tr('dashFridayDesc'),
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
    final lang = context.watch<LanguageProvider>().language;
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
              Text(context.tr('dashRamadanTitle'), style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _ramadanTimeBox(context.tr('dashRamadanImsakLabel'), _formatTime12(_todayTimes.fajr, lang))),
              const SizedBox(width: 10),
              Expanded(child: _ramadanTimeBox(context.tr('dashRamadanIftarLabel'), _formatTime12(_todayTimes.maghrib, lang))),
            ],
          ),
          const SizedBox(height: 12),
          Text(context.tr('dashRamadanDuaText'),
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
        Expanded(child: _quickIconTile(isDark, icon: Icons.savings_outlined, accent: AppTheme.toolAmber, label: context.tr('dashQuickZakatLabel'), onTap: () => ZakatCalculatorSheet.show(context, isDark))),
        const SizedBox(width: 12),
        Expanded(child: _quickIconTile(isDark, icon: Icons.dark_mode_outlined, accent: AppTheme.toolMint, label: context.tr('dashQuickMoonPhaseLabel'), onTap: () => _showMoonPhase(isDark))),
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
            Text(context.tr('dashMoonPhaseDisclaimer'),
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
              _navIcon(isDark, Icons.more_horiz_rounded, 'المزيد', () {
                _showMoreSheet(context, isDark);
              }),
              _navIcon(isDark, Icons.settings_outlined, 'الإعدادات', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
              }),
              _navIcon(isDark, Icons.calendar_month_outlined, context.tr('dashNavCalendar'), () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const HijriCalendarScreen()));
              }),
              _navIcon(isDark, Icons.auto_stories_rounded, context.tr('dashToolAthkarTitle'), () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AthkarCategoriesScreen()));
              }, highlighted: true),
              _navIcon(isDark, Icons.explore_outlined, context.tr('dashNavQibla'), () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const QiblaScreen()));
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

  /// قائمة "المزيد" — ورقة سفلية تجمع بقية أدوات التطبيق التي لا تملك
  /// أيقونة ثابتة في الشريط السفلي (المفضلة، الإحصائيات، العادات، البحث،
  /// حاسبة الزكاة، أسماء الله الحسنى، المسجد القريب، العدّادات).
  void _showMoreSheet(BuildContext context, bool isDark) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        final items = <_MoreItem>[
          _MoreItem(Icons.favorite_border_rounded, 'المفضلة', AppTheme.toolTeal, () {
            Navigator.push(sheetContext, MaterialPageRoute(builder: (_) => const FavoritesScreen()));
          }),
          _MoreItem(Icons.search_rounded, 'البحث', AppTheme.toolAmber, () {
            Navigator.push(sheetContext, MaterialPageRoute(builder: (_) => const SearchScreen()));
          }),
          _MoreItem(Icons.bar_chart_rounded, 'الإحصائيات', AppTheme.toolEmerald, () {
            Navigator.push(sheetContext, MaterialPageRoute(builder: (_) => const StatsScreen()));
          }),
          _MoreItem(Icons.checklist_rounded, 'العادات', AppTheme.toolOlive, () {
            Navigator.push(sheetContext, MaterialPageRoute(builder: (_) => const HabitsScreen()));
          }),
          _MoreItem(Icons.auto_awesome_outlined, 'أسماء الله الحسنى', AppTheme.gold, () {
            Navigator.push(sheetContext, MaterialPageRoute(builder: (_) => const AsmaAllahScreen()));
          }),
          _MoreItem(Icons.fingerprint, 'العدّادات', AppTheme.toolSage, () {
            Navigator.push(sheetContext, MaterialPageRoute(builder: (_) => const CountersScreen()));
          }),
          _MoreItem(Icons.savings_outlined, 'حاسبة الزكاة', AppTheme.toolAmber, () {
            Navigator.pop(sheetContext);
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const ZakatCalculatorSheet(),
            );
          }),
          _MoreItem(Icons.mosque_rounded, 'المسجد القريب', AppTheme.toolMint, () {
            Navigator.push(sheetContext, MaterialPageRoute(builder: (_) => const NearbyMosqueScreen()));
          }),
        ];
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor(isDark),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.gold.withValues(alpha: 0.25)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.gold.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 14),
                Text('المزيد', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.gold)),
                const SizedBox(height: 14),
                GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.8,
                  children: items.map((item) {
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        item.onTap();
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(shape: BoxShape.circle, color: item.color.withValues(alpha: 0.14)),
                            child: Icon(item.icon, size: 20, color: item.color),
                          ),
                          const SizedBox(height: 6),
                          Text(item.label, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.cairo(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppTheme.textColor(isDark))),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
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

/// عنصر واحد داخل ورقة "المزيد" السفلية.
class _MoreItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _MoreItem(this.icon, this.label, this.color, this.onTap);
}

/// عدّاد حيّ (يتحدّث كل ثانية) للصلاة القادمة + شريط أوقات اليوم — مُعزول
/// في ودجت خاص به حتى لا تُعاد بناء الشاشة الرئيسية كاملة كل ثانية
/// (تحسين أداء: التحديث الدوري محصور في أصغر جزء ممكن من الشجرة).
class _PrayerCountdownLive extends StatefulWidget {
  final PrayerTimesResult todayTimes;
  final DateTime tomorrowFajr;
  final bool isOnlineSource;

  const _PrayerCountdownLive({required this.todayTimes, required this.tomorrowFajr, this.isOnlineSource = false});

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

  /// صندوق رقم واحد (ساعة/دقيقة/ثانية) بتصميم بطاقة زجاجية شفافة.
  Widget _timeBox(int value, AppLanguage lang) {
    return Container(
      width: 58,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white24),
      ),
      alignment: Alignment.center,
      child: Text(
        localizedDigits(value.toString().padLeft(2, '0'), lang),
        style: GoogleFonts.cairo(
          fontSize: 30,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _timeLabel(String text) {
    return Text(text,
        style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.65)));
  }

  /// يبني عرض العدّاد التنازلي بشكل صناديق أرقام احترافية (ساعة/دقيقة/ثانية)
  /// مع حركة انتقال ناعمة (تلاشي + تكبير) عند اختفاء/ظهور خانة الساعة.
  Widget _buildCountdownDisplay(BuildContext context, Duration remaining, AppLanguage lang) {
    final showHours = remaining.inHours > 0;
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes.remainder(60);
    final seconds = remaining.inSeconds.remainder(60);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            );
          },
          child: Row(
            key: ValueKey(showHours),
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showHours) _timeBox(hours, lang),
              if (showHours) const SizedBox(width: 10),
              _timeBox(minutes, lang),
              const SizedBox(width: 10),
              _timeBox(seconds, lang),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showHours) _timeLabel('ساعة'),
            if (showHours) const SizedBox(width: 40),
            _timeLabel('دقيقة'),
            const SizedBox(width: 40),
            _timeLabel('ثانية'),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().language;
    final next = widget.todayTimes.nextPrayer(_now, widget.tomorrowFajr);
    final remaining = next.value.difference(_now);
    final currentName = widget.todayTimes.currentPrayerName(_now);

    return Column(
      children: [
        Text('الوقت المتبقي لأذان ${next.key}',
            style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.85))),
        if (widget.isOnlineSource) ...[
          const SizedBox(height: 3),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.toolEmerald)),
              const SizedBox(width: 4),
              Text(context.tr('dashOnlinePrayerTimesBadge'),
                  style: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.6))),
            ],
          ),
        ],
        const SizedBox(height: 10),
        _buildCountdownDisplay(context, remaining, lang),
        const SizedBox(height: 4),
        Text('${next.key} ${_formatTime12(next.value, lang)}',
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
                  Text(_formatTime12NoPeriod(p.value, lang),
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
