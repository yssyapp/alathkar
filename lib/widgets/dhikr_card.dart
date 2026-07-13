import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../core/theme.dart';
import '../models/dhikr_model.dart';
import '../providers/favorites_provider.dart';
import '../providers/theme_provider.dart';

/// بطاقة عرض ذكر واحد بنظام أكورديون (فتح/غلق) لسهولة وسرعة التنقل بين
/// عدد كبير من الأذكار في صفحة واحدة: تبدأ مطوية (عنوان + مُلخّص سريع)،
/// وتفتح بالنقر لعرض النص الكامل والفضل والمصدر والعدّاد.
///
/// مستقلة بحالتها الخاصة (العدّاد + حالة الفتح) حتى تصلح للاستخدام بأي
/// قائمة (شاشة الفئة، نتائج البحث، المفضّلة...) بدون تضارب. تدعم أيضاً
/// إشارة "فتح الكل / طي الكل" قادمة من الشاشة الأم عبر [expandEpoch]
/// و [forceExpanded].
class DhikrCard extends StatefulWidget {
  final DhikrModel dhikr;
  final VoidCallback? onCompleted;

  /// نص إضافي صغير يظهر فوق العنوان (مثال: اسم الفئة في نتائج البحث
  /// أو المفضّلة). اختياري.
  final String? subtitle;

  /// هل تبدأ البطاقة مفتوحة؟ الافتراضي مطوية لعرض أكبر عدد من الأذكار
  /// دفعة واحدة وتسهيل المسح السريع بينها.
  final bool initiallyExpanded;

  /// يزداد رقمه من الشاشة الأم عند الضغط على "فتح الكل" أو "طي الكل"؛
  /// أي تغيّر في القيمة يجعل البطاقة تتبع [forceExpanded] فوراً.
  final int expandEpoch;

  /// الحالة المطلوبة (مفتوح/مطوي) عند تغيّر [expandEpoch].
  final bool forceExpanded;

  const DhikrCard({
    super.key,
    required this.dhikr,
    this.onCompleted,
    this.subtitle,
    this.initiallyExpanded = false,
    this.expandEpoch = 0,
    this.forceExpanded = false,
  });

  @override
  State<DhikrCard> createState() => _DhikrCardState();
}

class _DhikrCardState extends State<DhikrCard> {
  int _counter = 0;
  late bool _expanded;
  late int _lastEpoch;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
    _lastEpoch = widget.expandEpoch;
  }

  @override
  void didUpdateWidget(covariant DhikrCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expandEpoch != _lastEpoch) {
      _lastEpoch = widget.expandEpoch;
      setState(() => _expanded = widget.forceExpanded);
    }
  }

  void _toggleExpanded() {
    setState(() => _expanded = !_expanded);
    HapticFeedback.selectionClick();
  }

  void _incrementCounter() {
    final dhikr = widget.dhikr;
    if (dhikr.count <= 1) return;
    if (_counter >= dhikr.count) {
      HapticFeedback.mediumImpact();
      return;
    }
    setState(() {
      _counter++;
    });
    if (_counter >= dhikr.count) {
      HapticFeedback.mediumImpact();
      widget.onCompleted?.call();
    } else {
      HapticFeedback.lightImpact();
    }
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
    });
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final dhikr = widget.dhikr;
    final isCompleted = dhikr.count > 1 && _counter >= dhikr.count;
    // select بدل watch: هذه البطاقة تُعاد بناؤها فقط عند تغيّر حالة
    // "مفضّلة" هذا الذكر تحديداً، لا عند أي تغيير في مزوّد المفضّلة كاملاً.
    final isFavorite = context.select<FavoritesProvider, bool>((p) => p.isFavorite(dhikr));

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted ? AppTheme.gold : AppTheme.gold.withValues(alpha: 0.3),
          width: isCompleted ? 1.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildHeader(context, isDark, isFavorite, isCompleted),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _expanded ? _buildExpandedBody(context, isDark, isCompleted) : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  /// رأس البطاقة: ظاهر دائماً (مطوية أو مفتوحة) — عنوان + مفضّلة +
  /// شارة تقدّم مصغّرة + سهم يدور مع حالة الفتح. النقر عليه يفتح/يطوي.
  Widget _buildHeader(BuildContext context, bool isDark, bool isFavorite, bool isCompleted) {
    final dhikr = widget.dhikr;
    return InkWell(
      onTap: _toggleExpanded,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Row(
          children: [
            AnimatedRotation(
              duration: const Duration(milliseconds: 220),
              turns: _expanded ? 0.5 : 0,
              child: Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.gold, size: 22),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => context.read<FavoritesProvider>().toggleFavorite(dhikr),
              child: Icon(
                isFavorite ? Icons.star : Icons.star_border,
                color: AppTheme.gold,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (widget.subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        widget.subtitle!,
                        style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.gold.withValues(alpha: 0.8)),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  Text(
                    dhikr.title,
                    style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textColor(isDark)),
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  if (!_expanded)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        dhikr.text,
                        style: GoogleFonts.cairo(fontSize: 12, color: AppTheme.subTextColor(isDark)),
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (dhikr.count > 1) _buildCountBadge(isDark, isCompleted),
          ],
        ),
      ),
    );
  }

  Widget _buildCountBadge(bool isDark, bool isCompleted) {
    final dhikr = widget.dhikr;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: isCompleted ? AppTheme.goldGradient : null,
        color: isCompleted ? null : AppTheme.gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: isCompleted
          ? const Icon(Icons.check_rounded, color: AppTheme.darkBackground, size: 14)
          : Text(
              '$_counter/${dhikr.count}',
              style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.gold),
            ),
    );
  }

  /// المحتوى الكامل: يظهر فقط عند الفتح (النص، الفضل، المصدر، الإجراءات).
  Widget _buildExpandedBody(BuildContext context, bool isDark, bool isCompleted) {
    final dhikr = widget.dhikr;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Column(
        children: [
          Divider(color: AppTheme.gold.withValues(alpha: 0.15), height: 1),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: dhikr.count > 1 ? _incrementCounter : null,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                dhikr.text,
                style: GoogleFonts.cairo(fontSize: 19, fontWeight: FontWeight.w600, color: AppTheme.textColor(isDark), height: 2.0),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (dhikr.virtue != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
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
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(dhikr.source, style: GoogleFonts.cairo(fontSize: 11.5, color: AppTheme.subTextColor(isDark)), textDirection: TextDirection.rtl),
                Text(dhikr.bookSource, style: GoogleFonts.cairo(fontSize: 11.5, color: AppTheme.gold.withValues(alpha: 0.7)), textDirection: TextDirection.rtl),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (dhikr.count > 1) ...[
                GestureDetector(
                  onTap: _incrementCounter,
                  child: Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: isCompleted ? AppTheme.goldGradient : AppTheme.cardGradient(isDark),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.gold, width: 1),
                    ),
                    child: Text(
                      '$_counter / ${dhikr.count}',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isCompleted ? AppTheme.darkBackground : AppTheme.textColor(isDark),
                      ),
                    ),
                  ),
                ),
                if (_counter > 0) ...[
                  const SizedBox(width: 8),
                  _buildActionButton(
                    icon: Icons.refresh,
                    isDark: isDark,
                    onTap: _resetCounter,
                  ),
                ],
                const SizedBox(width: 8),
              ],
              _buildActionButton(
                icon: Icons.copy,
                isDark: isDark,
                onTap: () {
                  Clipboard.setData(ClipboardData(text: dhikr.text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم نسخ الذكر', style: GoogleFonts.cairo(), textDirection: TextDirection.rtl),
                      backgroundColor: AppTheme.primaryGreen,
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.share,
                isDark: isDark,
                onTap: () => SharePlus.instance.share(
                  ShareParams(
                    text: '${dhikr.text}\n\n${dhikr.source}\n${dhikr.bookSource}',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.keyboard_arrow_up_rounded,
                isDark: isDark,
                onTap: _toggleExpanded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required bool isDark, required VoidCallback onTap}) {
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
