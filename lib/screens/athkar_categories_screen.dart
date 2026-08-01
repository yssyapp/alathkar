import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/app_strings.dart';
import '../core/theme.dart';
import '../data/athkar_data.dart';
import '../models/dhikr_model.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/prayer_times.dart';
import 'azkar_swipe_screen.dart';
import 'favorites_screen.dart';
import 'settings_screen.dart';

/// شاشة الأذكار — تصميم جديد: شريط علوي بسيط جداً (اسم التطبيق + الوقت
/// المتبقي للفجر) بدل الرأس القديم، وتحته "ورقة" قابلة للسحب
/// (DraggableScrollableSheet) تبدأ صغيرة وتتمدد بالسحب للأعلى لتكشف كل
/// فئات الأذكار كبطاقات، بدل القائمة الطويلة الثابتة القديمة.
class AthkarCategoriesScreen extends StatefulWidget {
  const AthkarCategoriesScreen({super.key});

  @override
  State<AthkarCategoriesScreen> createState() => _AthkarCategoriesScreenState();
}

/// الفئات المميّزة تظهر أولاً وبأيقونات مطابقة للتصميم المطلوب؛ بقية
/// الفئات (الرقية، الأربعون النووية، أسماء الله...) تظهر بعدها تحت فاصل
/// "المزيد" حتى لا تُفقد أي وظيفة كانت متاحة سابقاً.
const List<DhikrCategory> _featuredCategories = [
  DhikrCategory.morning,
  DhikrCategory.evening,
  DhikrCategory.prayer,
  DhikrCategory.quran,
  DhikrCategory.sleep,
  DhikrCategory.wakeup,
  DhikrCategory.travel,
  DhikrCategory.food,
];

class _AthkarCategoriesScreenState extends State<AthkarCategoriesScreen> {
  static const PrayerTimesCalculator _calculator = PrayerTimesCalculator();
  late final PrayerTimesResult _todayTimes = _calculator.calculate(DateTime.now());
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

  String get _remainingToFajr {
    var diff = _todayTimes.fajr.difference(_now);
    if (diff.isNegative) diff = Duration.zero;
    final h = diff.inHours.toString().padLeft(2, '0');
    final m = diff.inMinutes.remainder(60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _openCategory(DhikrCategory category) {
    HapticFeedback.selectionClick();
    // كل الفئات الآن تُعرض بشكل "متحرك باللمس" (ذكر واحد يملأ الشاشة،
    // بدون عنوان فوقه، تنقّل بالسحب عمودياً) بدل قائمة الأكورديون القديمة،
    // ليكون الشكل موحّداً في كل تبويبات/فئات الأذكار.
    Navigator.push(context, _fadeScaleRoute(AzkarSwipeScreen(category: category)));
  }

  /// انتقال بسيط بتلاشي + تكبير خفيف (بديل عن Hero Animation كاملة) بدون
  /// إضافة أي حزمة خارجية جديدة للمشروع، تفادياً لأي مخاطرة إضافية بالبناء.
  Route _fadeScaleRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, animation, _, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(scale: Tween(begin: 0.96, end: 1.0).animate(curved), child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient(isDark)),
        child: Stack(
          children: [
            SafeArea(child: _buildTopBar(context, isDark)),
            DraggableScrollableSheet(
              initialChildSize: .18,
              minChildSize: .12,
              maxChildSize: .90,
              snap: true,
              snapSizes: const [.18, .50, .90],
              builder: (context, controller) => _buildSheet(context, isDark, controller),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.arrow_forward_ios, color: AppTheme.gold, size: 18),
              ),
              const Spacer(),
              const Text('🕌', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(context.tr('athkarCatTitle'),
                  style: GoogleFonts.cairo(fontSize: 19, fontWeight: FontWeight.w800, color: AppTheme.textColor(isDark))),
              const Spacer(),
              const SizedBox(width: 18),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('المتبقي للفجر', style: GoogleFonts.cairo(fontSize: 12.5, color: AppTheme.subTextColor(isDark))),
              const SizedBox(width: 8),
              Text(_remainingToFajr,
                  style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.gold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSheet(BuildContext context, bool isDark, ScrollController controller) {
    final lang = context.watch<LanguageProvider>().language;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff0f2318) : Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 20, offset: const Offset(0, -6))],
      ),
      child: ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
        children: [
          Center(
            child: Container(
              width: 42,
              height: 4,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(color: AppTheme.gold.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(4)),
            ),
          ),
          Center(
            child: Text('اسحب للأعلى', style: GoogleFonts.cairo(fontSize: 11.5, color: AppTheme.subTextColor(isDark))),
          ),
          const SizedBox(height: 12),
          for (final category in _featuredCategories)
            _CategoryCard(category: category, lang: lang, onTap: () => _openCategory(category)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(children: [
              Expanded(child: Divider(color: AppTheme.gold.withValues(alpha: 0.25))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text('المزيد', style: GoogleFonts.cairo(fontSize: 12, color: AppTheme.subTextColor(isDark))),
              ),
              Expanded(child: Divider(color: AppTheme.gold.withValues(alpha: 0.25))),
            ]),
          ),
          for (final category in DhikrCategory.values.where((c) => !_featuredCategories.contains(c)))
            _CategoryCard(category: category, lang: lang, onTap: () => _openCategory(category)),
          _ActionCard(
            emoji: '⭐',
            label: 'المفضلة',
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.push(context, _fadeScaleRoute(const FavoritesScreen()));
            },
          ),
          _ActionCard(
            emoji: '⚙️',
            label: 'الإعدادات',
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.push(context, _fadeScaleRoute(const SettingsScreen()));
            },
          ),
        ],
      ),
    );
  }
}

/// بطاقة فئة ذكر واحدة — أيقونة + عنوان + سهم، بخلفية متدرّجة خضراء
/// وحركة ضغط بسيطة (تكبير خفيف + Ripple ذهبي) بدل الانتقال الفوري الجاف.
class _CategoryCard extends StatefulWidget {
  final DhikrCategory category;
  final AppLanguage lang;
  final VoidCallback onTap;
  const _CategoryCard({required this.category, required this.lang, required this.onTap});

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final count = AthkarData.getByCategory(widget.category).length;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(colors: [Color(0xff23422d), Color(0xff31553d)]),
          ),
          clipBehavior: Clip.antiAlias,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              splashColor: Colors.amber.withValues(alpha: 0.18),
              highlightColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Text(widget.category.icon, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        widget.category.nameFor(widget.lang),
                        style: GoogleFonts.cairo(fontSize: 15.5, fontWeight: FontWeight.w700, color: Colors.white),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('$count', style: GoogleFonts.cairo(fontSize: 11.5, color: Colors.white60)),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_left_rounded, color: Colors.amber, size: 22),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// بطاقة إجراء عامة (المفضلة، الإعدادات...) بنفس تصميم بطاقة الفئة.
class _ActionCard extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;
  const _ActionCard({required this.emoji, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(colors: [Color(0xff23422d), Color(0xff31553d)]),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: Colors.amber.withValues(alpha: 0.18),
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(label,
                      style: GoogleFonts.cairo(fontSize: 15.5, fontWeight: FontWeight.w700, color: Colors.white),
                      textAlign: TextAlign.right),
                ),
                const Icon(Icons.chevron_left_rounded, color: Colors.amber, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
