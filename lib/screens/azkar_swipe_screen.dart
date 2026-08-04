import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../core/app_strings.dart';
import '../core/theme.dart';
import '../data/athkar_data.dart';
import '../models/dhikr_model.dart';
import '../providers/favorites_provider.dart';
import '../providers/language_provider.dart';
import '../providers/stats_provider.dart';
import '../providers/theme_provider.dart';

/// عرض "متحرك باللمس" للأذكار: كل ذكر يملأ الشاشة كاملة بدون عنوان فوقه
/// (فقط النص والفضل والمصدر)، والتنقل بين الأذكار بالسحب بالإصبع لأعلى
/// (التالي) أو لأسفل (السابق) — بدل قائمة أكورديون تراكمية طويلة. هذا
/// يركّز الانتباه على ذكر واحد في كل مرة، وهو الشكل المطلوب خصيصاً لأذكار
/// الصباح والمساء.
///
/// [AzkarSwipeView] هو المحتوى القابل لإعادة الاستخدام (PageView + عدّاد
/// الموضع)، بينما [AzkarSwipeScreen] يغلّفه بشاشة كاملة (خلفية + شريط علوي
/// بزر رجوع واسم الفئة) عند فتح فئة واحدة بشكل مستقل. عند الاستخدام داخل
/// تبويبات (مثل شاشة الصباح/المساء السريعة) يُستخدم [AzkarSwipeView] وحده
/// بوضع [embedded] لتفادي ازدواج الشريط العلوي مع شريط التبويبات.
class AzkarSwipeScreen extends StatelessWidget {
  final DhikrCategory category;
  const AzkarSwipeScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient(isDark)),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
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
                        child: Icon(Icons.arrow_forward_ios, color: AppTheme.gold, size: 18),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      category.nameFor(context.watch<LanguageProvider>().language),
                      style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.gold),
                    ),
                    const Spacer(),
                    const SizedBox(width: 36),
                  ],
                ),
              ),
              Expanded(child: AzkarSwipeView(category: category)),
            ],
          ),
        ),
      ),
    );
  }
}

/// المحتوى القابل لإعادة الاستخدام: قائمة أذكار متحركة عمودياً بالسحب،
/// بدون عناوين، مع عدّاد صغير "الموضع / العدد" أعلى المحتوى.
class AzkarSwipeView extends StatefulWidget {
  final DhikrCategory category;

  /// عند true تُخفى الحشوة العلوية الإضافية لأن الشاشة الأم (مثل تبويبات
  /// الصباح/المساء) توفر شريطها العلوي الخاص بها.
  final bool embedded;

  const AzkarSwipeView({super.key, required this.category, this.embedded = false});

  @override
  State<AzkarSwipeView> createState() => _AzkarSwipeViewState();
}

class _AzkarSwipeViewState extends State<AzkarSwipeView> {
  final PageController _controller = PageController();
  int _index = 0;

  /// معرّفات الأذكار التي أكمل المستخدم عدّها بالكامل خلال هذه الجلسة —
  /// أساس عدّاد "أنجزت" أسفل شريط التقدم. تُعاد للصفر تلقائياً عند فتح
  /// الشاشة من جديد (لكل جلسة قراءة عدّها الخاص)، وتُستثنى منها الأذكار
  /// التي تُقال مرة واحدة بلا تكرار (count <= 1) لأنه لا يوجد لها عدّاد
  /// أصلاً لتمييز إنجازها عن مجرد المرور عليها.
  final Set<String> _completedIds = {};

  /// العدّاد التنازلي المتبقي لكل ذكر (مفتاحه معرّف الذكر)، محفوظ هنا في
  /// حالة الشاشة الأم لا داخل بطاقة الذكر نفسها — لأن [PageView.builder]
  /// يتخلّص من صفحات الأذكار البعيدة عن العرض ويعيد بناءها من جديد عند
  /// العودة إليها بالسحب، فلو بقي العدّاد حالة محلية للبطاقة لكان يُعاد
  /// ضبطه للعدد الكامل من جديد في كل مرة، فيبدو للمستخدم أن "الذكر الذي
  /// أنهاه عاد يُعدّ من البداية". بإبقائه هنا يستمر عند الصفر بعد اكتماله
  /// مهما تنقّل المستخدم بين الأذكار.
  final Map<String, int> _remaining = {};

  /// هذا الحفظ مطبّق فقط على أذكار الصباح والمساء بناءً على طلب المستخدم
  /// — بقية الفئات تحتفظ بسلوكها الأصلي (العدّاد يُعاد لكامل العدد عند
  /// إعادة بناء الصفحة، دون حفظ التقدّم بين التنقّلات).
  bool get _persistsRemaining => widget.category == DhikrCategory.morning || widget.category == DhikrCategory.evening;

  int _remainingFor(DhikrModel dhikr) {
    if (!_persistsRemaining) return dhikr.count;
    return _remaining.putIfAbsent(dhikr.id, () => dhikr.count);
  }

  @override
  void didUpdateWidget(covariant AzkarSwipeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // عند تبديل الفئة (مثلاً الانتقال بين تبويب الصباح والمساء) نعيد
    // الموضع لأول ذكر ونصفّر عدّاد الإنجاز، بدل الاحتفاظ بحالة فئة سابقة
    // لا علاقة لها بالفئة الجديدة أصلاً.
    if (oldWidget.category != widget.category) {
      _index = 0;
      _completedIds.clear();
      _remaining.clear();
      if (_controller.hasClients) _controller.jumpToPage(0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _markCompleted(String dhikrId) {
    if (_completedIds.add(dhikrId)) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final lang = context.watch<LanguageProvider>().language;
    final athkar = AthkarData.getByCategory(widget.category);

    if (athkar.isEmpty) {
      return Center(
        child: Text(
          context.tr('dhikrEmptyList'),
          style: GoogleFonts.cairo(fontSize: 18, color: AppTheme.subTextColor(isDark)),
        ),
      );
    }

    // كل ذكر الآن له عدّاد تنازلي خاص به (حتى لو تُقال مرة واحدة)، فمقام
    // نسبة "أنجزت" هو إجمالي عدد الأذكار في الفئة بالكامل.
    final countableTotal = athkar.length;
    final progress = (_index + 1) / athkar.length;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20, widget.embedded ? 10 : 2, 20, 8),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 5,
                  backgroundColor: AppTheme.gold.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.gold),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_index + 1} / ${athkar.length}',
                    style: GoogleFonts.cairo(fontSize: 12.5, color: AppTheme.subTextColor(isDark)),
                  ),
                  if (countableTotal > 0)
                    Row(
                      children: [
                        Icon(Icons.check_circle, size: 13, color: AppTheme.gold.withValues(alpha: 0.85)),
                        const SizedBox(width: 4),
                        Text(
                          '${context.tr('dhikrCompletedLabel')} ${_completedIds.length} / $countableTotal',
                          style: GoogleFonts.cairo(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppTheme.gold),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _controller,
            scrollDirection: Axis.vertical,
            itemCount: athkar.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) => _AzkarSwipePage(
              key: ValueKey(athkar[i].id),
              dhikr: athkar[i],
              lang: lang,
              isDark: isDark,
              remaining: _remainingFor(athkar[i]),
              onRemainingChanged: (value) {
                if (_persistsRemaining) _remaining[athkar[i].id] = value;
              },
              onCompleted: () {
                context.read<StatsProvider>().recordCompletion();
                _markCompleted(athkar[i].id);
              },
              // عند اكتمال عدّاد الذكر الحالي (وصل للصفر) ننتقل تلقائياً
              // للذكر التالي — إلا لو كان آخر ذكر في الفئة، فنبقى عليه.
              onAdvance: () {
                if (i < athkar.length - 1 && _controller.hasClients) {
                  _controller.nextPage(
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.easeOutCubic,
                  );
                }
              },
            ),
          ),
        ),
        if (athkar.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 10, top: 2),
            child: Icon(Icons.keyboard_double_arrow_up_rounded, color: AppTheme.gold.withValues(alpha: 0.5), size: 18),
          ),
      ],
    );
  }
}

/// محتوى ذكر واحد يملأ الصفحة: بدون عنوان، نص الذكر بارز في المنتصف،
/// وتحته عدّاد تنازلي خاص به، ثم الفضل (إن وُجد) والمصدر وأزرار
/// النسخ/المشاركة. قابل للتمرير الداخلي لو كان النص طويلاً جداً (كآية
/// الكرسي) على شاشة صغيرة.
class _AzkarSwipePage extends StatefulWidget {
  final DhikrModel dhikr;
  final AppLanguage lang;
  final bool isDark;
  final VoidCallback onCompleted;

  /// العدّاد المتبقي الحالي لهذا الذكر، كما تحفظه الشاشة الأم — يُستخدم
  /// كقيمة ابتدائية عند بناء هذه الصفحة (بما فيه إعادة بنائها بعد أن كان
  /// [PageView] قد تخلّص منها).
  final int remaining;

  /// يُستدعى في كل مرة يتغيّر فيها العدّاد المتبقي، ليُحفَظ في الشاشة
  /// الأم فيبقى العدّاد عند الصفر ولا يُعاد عدّه من جديد عند التنقّل.
  final ValueChanged<int> onRemainingChanged;

  /// يُستدعى تلقائياً بعد وصول العدّاد للصفر، للانتقال للذكر التالي.
  final VoidCallback onAdvance;

  const _AzkarSwipePage({
    super.key,
    required this.dhikr,
    required this.lang,
    required this.isDark,
    required this.remaining,
    required this.onRemainingChanged,
    required this.onCompleted,
    required this.onAdvance,
  });

  @override
  State<_AzkarSwipePage> createState() => _AzkarSwipePageState();
}

class _AzkarSwipePageState extends State<_AzkarSwipePage> {
  /// عدّاد تنازلي: يبدأ من عدد مرات تكرار الذكر كما ورد في الحديث الصحيح
  /// (dhikr.count) وينقص واحداً في كل ضغطة حتى يصل للصفر — بدل عدّاد
  /// تصاعدي يحتاج مقارنة ذهنية بالرقم المستهدف في كل مرة. عند وصوله للصفر
  /// ننتقل تلقائياً للذكر التالي (راجع [_decrement]).
  late int _remaining = widget.remaining;

  void _decrement() {
    if (_remaining <= 0) return;
    setState(() => _remaining--);
    widget.onRemainingChanged(_remaining);
    if (_remaining == 0) {
      HapticFeedback.mediumImpact();
      widget.onCompleted();
      // مهلة قصيرة يرى خلالها المستخدم وصول العدّاد للصفر فعلياً قبل
      // الانتقال التلقائي، بدل قفزة فورية قد تمر دون ملاحظتها.
      Future.delayed(const Duration(milliseconds: 450), () {
        if (mounted) widget.onAdvance();
      });
    } else {
      HapticFeedback.lightImpact();
    }
  }

  void _resetCounter() {
    setState(() => _remaining = widget.dhikr.count);
    widget.onRemainingChanged(_remaining);
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final dhikr = widget.dhikr;
    final isDark = widget.isDark;
    final lang = widget.lang;
    final bodyDir = lang.isRtl ? TextDirection.rtl : TextDirection.ltr;
    final isCompleted = _remaining == 0;
    final isFavorite = context.select<FavoritesProvider, bool>((p) => p.isFavorite(dhikr));
    // قاعدة ثابتة: النص الشرعي (آية أو حديث) يظهر عربياً كاملاً دائماً
    // أولاً، ثم ترجمته (إن وُجدت فعلاً) تحته كتوضيح لا كبديل عنه.
    final translated = dhikr.textFor(lang);
    final hasTranslation = lang != AppLanguage.ar && translated != dhikr.text;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height * 0.55),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => context.read<FavoritesProvider>().toggleFavorite(dhikr),
              child: Icon(isFavorite ? Icons.star : Icons.star_border, color: AppTheme.gold, size: 26),
            ),
            const SizedBox(height: 16),
            if (dhikr.narrator != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_outline_rounded, color: AppTheme.gold, size: 15),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      dhikr.narrator!,
                      style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.gold),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            // بطاقة موحّدة: نص الذكر أعلاها، وشريط العدّاد التنازلي ملتصق
            // بأسفلها بعرض كامل ولون معبّأ (بدل شارة صغيرة منفصلة) — تصميم
            // أوضح وأسهل للمس، والضغط على أي من الجزءين ينقص العدّاد.
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.cardGradient(isDark),
                  border: Border.all(
                    color: isCompleted ? AppTheme.gold : AppTheme.gold.withValues(alpha: 0.3),
                    width: isCompleted ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _decrement,
                      onLongPress: _resetCounter,
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Text(
                          dhikr.text,
                          style: GoogleFonts.cairo(fontSize: 21, fontWeight: FontWeight.w600, color: AppTheme.textColor(isDark), height: 2.0),
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                    ),
                    // عدّاد تنازلي تحت كل ذكر بلا استثناء: يبدأ بعدد مرات
                    // التكرار الصحيحة (dhikr.count) وينقص بالضغط عليه حتى
                    // الصفر، ثم ينتقل تلقائياً للذكر التالي.
                    GestureDetector(
                      onTap: _decrement,
                      onLongPress: _resetCounter,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        color: isCompleted ? AppTheme.gold : AppTheme.primaryGreen,
                        child: Text(
                          localizedDigits('$_remaining', lang),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: isCompleted ? AppTheme.darkBackground : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (hasTranslation) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.gold.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: lang.isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('translationLabel'),
                      style: GoogleFonts.cairo(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppTheme.gold.withValues(alpha: 0.85)),
                      textDirection: bodyDir,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      translated,
                      style: GoogleFonts.cairo(fontSize: 15.5, color: AppTheme.textColor(isDark), height: 1.7),
                      textAlign: lang.isRtl ? TextAlign.right : TextAlign.left,
                      textDirection: bodyDir,
                    ),
                  ],
                ),
              ),
            ],
            if (dhikr.virtue != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🌟', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        dhikr.virtue!,
                        style: GoogleFonts.cairo(fontSize: 12.5, color: AppTheme.gold, height: 1.8),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: lang.isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(dhikr.attributionFor(lang), style: GoogleFonts.cairo(fontSize: 11.5, color: AppTheme.subTextColor(isDark)), textDirection: bodyDir),
                  Text(dhikr.bookSource, style: GoogleFonts.cairo(fontSize: 11.5, color: AppTheme.gold.withValues(alpha: 0.7)), textDirection: TextDirection.rtl),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _actionButton(
                  icon: Icons.copy,
                  isDark: isDark,
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: dhikr.textFor(lang)));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.tr('dhikrCopiedMsg'), style: GoogleFonts.cairo(), textDirection: bodyDir),
                        backgroundColor: AppTheme.primaryGreen,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 10),
                _actionButton(
                  icon: Icons.share,
                  isDark: isDark,
                  onTap: () => SharePlus.instance.share(
                    ShareParams(text: '${dhikr.textFor(lang)}\n\n${dhikr.sourceFor(lang)}\n${dhikr.bookSource}'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({required IconData icon, required bool isDark, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: AppTheme.cardGradient(isDark),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3)),
        ),
        child: Icon(icon, color: AppTheme.gold, size: 18),
      ),
    );
  }
}
