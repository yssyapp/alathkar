import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/app_strings.dart';
import '../core/theme.dart';
import '../data/athkar_data.dart';
import '../models/dhikr_model.dart';
import '../providers/language_provider.dart';
import '../providers/stats_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/dhikr_card.dart';

/// شاشة الأذكار الموحّدة: كل الفئات الاثنتي عشرة في صفحة واحدة قابلة
/// للتمرير، كل فئة رأسها عبارة عن "قائمة منسدلة" (أيقونة + اسم + سهم)
/// تُفتح وتُغلق باللمس المباشر لتكشف أذكار تلك الفئة أسفلها فوراً — بدون
/// الانتقال لصفحة جديدة. يمكن فتح أكثر من فئة بنفس الوقت، وكل واحدة
/// تحتفظ بحالتها الخاصة بشكل مستقل. كل ذكر بداخلها يحتفظ بنظام الأكورديون
/// والعدّاد باللمس نفسه (راجع widgets/dhikr_card.dart).
class AthkarCategoriesScreen extends StatefulWidget {
  const AthkarCategoriesScreen({super.key});

  @override
  State<AthkarCategoriesScreen> createState() => _AthkarCategoriesScreenState();
}

class _AthkarCategoriesScreenState extends State<AthkarCategoriesScreen> {
  final Set<DhikrCategory> _expandedCategories = {};

  void _toggleCategory(DhikrCategory category) {
    setState(() {
      if (_expandedCategories.contains(category)) {
        _expandedCategories.remove(category);
      } else {
        _expandedCategories.add(category);
      }
    });
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient(isDark)),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context, isDark),
              Expanded(child: _buildCategoryList(context, isDark)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
            context.tr('athkarCatTitle'),
            style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textColor(isDark)),
          ),
          const Spacer(),
          const SizedBox(width: 36),
        ],
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context, bool isDark) {
    final categories = DhikrCategory.values.toList();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: categories.length,
      itemBuilder: (context, index) => _buildCategorySection(context, categories[index], isDark),
    );
  }

  /// قسم فئة واحدة: رأس "قائمة منسدلة" (أيقونة + اسم + عدد + سهم يدور)
  /// يُفتح ويُغلق باللمس، وتحته أذكار الفئة عند الفتح. كل فئة تحتفظ بحالة
  /// فتحها الخاصة في [_expandedCategories]، فيمكن فتح عدة فئات معاً.
  Widget _buildCategorySection(BuildContext context, DhikrCategory category, bool isDark) {
    final expanded = _expandedCategories.contains(category);
    final athkar = AthkarData.getByCategory(category);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.gold.withValues(alpha: expanded ? 0.5 : 0.3), width: expanded ? 1.5 : 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: () => _toggleCategory(category),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 220),
                    turns: expanded ? 0.5 : 0,
                    child: Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.gold, size: 24),
                  ),
                  const SizedBox(width: 8),
                  Text(category.icon, style: const TextStyle(fontSize: 26)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      category.nameFor(context.watch<LanguageProvider>().language),
                      style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textColor(isDark)),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${athkar.length}',
                    style: GoogleFonts.cairo(fontSize: 12, color: AppTheme.subTextColor(isDark)),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: expanded ? _buildAthkarList(context, isDark, athkar) : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _buildAthkarList(BuildContext context, bool isDark, List<DhikrModel> athkar) {
    if (athkar.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
        child: Text(
          context.tr('athkarCatEmptyCategory'),
          style: GoogleFonts.cairo(fontSize: 13, color: AppTheme.subTextColor(isDark)),
          textAlign: TextAlign.center,
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Column(
        children: athkar
            .map((d) => DhikrCard(
                  key: ValueKey(d.id),
                  dhikr: d,
                  onCompleted: () => context.read<StatsProvider>().recordCompletion(),
                ))
            .toList(),
      ),
    );
  }
}
