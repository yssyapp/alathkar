import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hijri/hijri_calendar.dart';

import '../core/app_strings.dart';
import '../core/theme.dart';

/// شاشة التقويم الهجري التفصيلي: عرض شهري كامل مع أهم المناسبات الإسلامية،
/// وإمكانية التنقل بين الشهور (بحساب هجري حسابي تقريبي، لا يعتمد رؤية هلال
/// فعلية — قد يختلف يوم أو يومين عن الإعلان الرسمي المحلي).
class HijriCalendarScreen extends StatefulWidget {
  const HijriCalendarScreen({super.key});

  @override
  State<HijriCalendarScreen> createState() => _HijriCalendarScreenState();
}

class _HijriEvent {
  final int month;
  final int day;
  final String title;
  const _HijriEvent(this.month, this.day, this.title);
}

// قائمة أبرز المناسبات الإسلامية المعروفة (بالتقويم الهجري: الشهر ثم اليوم).
// المناسبات ذات الخلاف العلمي بتاريخها الدقيق (كالمولد النبوي والإسراء
// والمعراج) وُسمت بـ"المشهور" لتوضيح أنه التاريخ الأكثر تداولاً لا حكماً قطعياً.
const List<_HijriEvent> _events = [
  _HijriEvent(1, 1, 'رأس السنة الهجرية'),
  _HijriEvent(1, 10, 'يوم عاشوراء'),
  _HijriEvent(3, 12, 'ذكرى المولد النبوي الشريف ﷺ (المشهور)'),
  _HijriEvent(7, 27, 'ذكرى الإسراء والمعراج (المشهور)'),
  _HijriEvent(8, 15, 'ليلة النصف من شعبان'),
  _HijriEvent(9, 1, 'بداية شهر رمضان المبارك'),
  _HijriEvent(9, 27, 'من أرجى ليالي القدر (العشر الأواخر من رمضان)'),
  _HijriEvent(10, 1, 'عيد الفطر المبارك'),
  _HijriEvent(12, 8, 'بداية أيام الحج'),
  _HijriEvent(12, 9, 'يوم عرفة'),
  _HijriEvent(12, 10, 'عيد الأضحى المبارك'),
  _HijriEvent(12, 13, 'نهاية أيام التشريق'),
];

const _hijriMonthsAr = [
  'محرم', 'صفر', 'ربيع الأول', 'ربيع الآخر', 'جمادى الأولى', 'جمادى الآخرة',
  'رجب', 'شعبان', 'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة',
];

const _arWeekdaysShort = ['اثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة', 'سبت', 'أحد'];

class _HijriCalendarScreenState extends State<HijriCalendarScreen> {
  late int _year;
  late int _month;
  late final int _todayHYear, _todayHMonth, _todayHDay;

  @override
  void initState() {
    super.initState();
    HijriCalendar.setLocal('ar');
    final today = HijriCalendar.fromDate(DateTime.now());
    _todayHYear = today.hYear;
    _todayHMonth = today.hMonth;
    _todayHDay = today.hDay;
    _year = _todayHYear;
    _month = _todayHMonth;
  }

  void _changeMonth(int delta) {
    setState(() {
      var newMonth = _month + delta;
      var newYear = _year;
      if (newMonth > 12) {
        newMonth = 1;
        newYear++;
      } else if (newMonth < 1) {
        newMonth = 12;
        newYear--;
      }
      _month = newMonth;
      _year = newYear;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cal = HijriCalendar();
    final daysInMonth = cal.getDaysInMonth(_year, _month);
    final firstDayGregorian = cal.hijriToGregorian(_year, _month, 1);
    // weekday: 1=Monday..7=Sunday (معيار DateTime)؛ نبني الشبكة بحيث الاثنين أول عمود.
    final leadingBlanks = firstDayGregorian.weekday - 1;

    final monthEvents = _events.where((e) => e.month == _month).toList();

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('hijriTitle'), style: GoogleFonts.cairo(fontWeight: FontWeight.w700))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildRamadanCard(context, isDark, cal),
            _buildMonthHeader(isDark),
            const SizedBox(height: 16),
            _buildWeekdayRow(isDark),
            const SizedBox(height: 6),
            _buildGrid(isDark, daysInMonth, leadingBlanks),
            if (monthEvents.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(context.tr('hijriEventsThisMonth'), style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textColor(isDark))),
              const SizedBox(height: 10),
              ...monthEvents.map((e) => _buildEventTile(isDark, e)),
            ],
            const SizedBox(height: 16),
            Text(
              context.tr('hijriApproxNote'),
              style: GoogleFonts.cairo(fontSize: 11, color: AppTheme.subTextColor(isDark), height: 1.6),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// بطاقة رمضان: أثناء الشهر تعرض رقم اليوم الحالي والأيام المتبقية لعيد
  /// الفطر، وقبل الشهر تعرض عدّاداً تنازلياً لعدد الأيام المتبقية لاستقباله.
  /// الحساب حسابي تقريبي مبني على نفس تحويل hijriToGregorian المستخدم في
  /// بقية الشاشة، فيخضع لنفس هامش الاختلاف عن رؤية الهلال الرسمية.
  Widget _buildRamadanCard(BuildContext context, bool isDark, HijriCalendar cal) {
    late final String title;
    late final String subtitle;
    late final IconData icon;

    if (_todayHMonth == 9) {
      final daysInRamadan = cal.getDaysInMonth(_todayHYear, 9);
      final remaining = daysInRamadan - _todayHDay;
      title = '${context.tr('hijriRamadanDayPrefix')} ${toArabicDigits('$_todayHDay')} ${context.tr('hijriRamadanDaySuffix')}';
      subtitle = remaining > 0
          ? '${context.tr('hijriRemainingPrefix')} ${toArabicDigits('$remaining')} ${remaining == 1 ? context.tr('hijriDaySingular') : context.tr('hijriDaysPlural')} ${context.tr('hijriEidSuffix')}'
          : context.tr('hijriEidTomorrow');
      icon = Icons.nightlight_round;
    } else {
      final targetYear = _todayHMonth < 9 ? _todayHYear : _todayHYear + 1;
      final ramadanStart = cal.hijriToGregorian(targetYear, 9, 1);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final daysLeft = ramadanStart.difference(today).inDays;
      title = context.tr('hijriRamadanMonthTitle');
      subtitle = daysLeft > 0
          ? '${context.tr('hijriDaysLeftPrefix')} ${toArabicDigits('$daysLeft')} ${daysLeft == 1 ? context.tr('hijriDaySingular') : context.tr('hijriDayAccusativePlural')} ${context.tr('hijriRamadanComingSuffix')}'
          : context.tr('hijriRamadanSoon');
      icon = Icons.mosque_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.toolEmerald.withValues(alpha: 0.35)),
        boxShadow: AppTheme.softGlow(AppTheme.toolEmerald, opacity: 0.2, blur: 20),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.toolEmerald.withValues(alpha: 0.15)),
            child: Icon(icon, color: AppTheme.toolEmerald, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textColor(isDark))),
                const SizedBox(height: 4),
                Text(subtitle, style: GoogleFonts.cairo(fontSize: 12.5, color: AppTheme.subTextColor(isDark), height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(onPressed: () => _changeMonth(-1), icon: Icon(Icons.chevron_right_rounded, color: AppTheme.gold)),
          Text(
            '${_hijriMonthsAr[_month - 1]} ${toArabicDigits('$_year')} هـ',
            style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.textColor(isDark)),
          ),
          IconButton(onPressed: () => _changeMonth(1), icon: Icon(Icons.chevron_left_rounded, color: AppTheme.gold)),
        ],
      ),
    );
  }

  Widget _buildWeekdayRow(bool isDark) {
    return Row(
      children: _arWeekdaysShort
          .map((d) => Expanded(
                child: Center(
                  child: Text(d, style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.subTextColor(isDark))),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildGrid(bool isDark, int daysInMonth, int leadingBlanks) {
    final totalCells = leadingBlanks + daysInMonth;
    final rows = (totalCells / 7).ceil();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rows * 7,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 0.85),
      itemBuilder: (context, index) {
        final dayNum = index - leadingBlanks + 1;
        if (dayNum < 1 || dayNum > daysInMonth) return const SizedBox.shrink();

        final isToday = _year == _todayHYear && _month == _todayHMonth && dayNum == _todayHDay;
        final hasEvent = _events.any((e) => e.month == _month && e.day == dayNum);

        return Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isToday ? AppTheme.gold : Colors.transparent,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  toArabicDigits('$dayNum'),
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                    color: isToday ? Colors.black : AppTheme.textColor(isDark),
                  ),
                ),
                if (hasEvent)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: isToday ? Colors.black : AppTheme.toolEmerald),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventTile(bool isDark, _HijriEvent e) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient(isDark),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.toolEmerald.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.toolEmerald.withValues(alpha: 0.15)),
            child: Text(toArabicDigits('${e.day}'), style: GoogleFonts.cairo(fontWeight: FontWeight.w800, color: AppTheme.toolEmerald, fontSize: 13)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(e.title, style: GoogleFonts.cairo(fontSize: 13, color: AppTheme.textColor(isDark), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
