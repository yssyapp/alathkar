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

/// شاشة عرض أذكار فئة واحدة، كلها في صفحة واحدة قابلة للتمرير، مع بطاقات
/// أكورديون (فتح/غلق) لتسريع التنقل بين عدد كبير من الأذكار، وزر "فتح
/// الكل / طي الكل" أعلى الشاشة.
class DhikrScreen extends StatefulWidget {
  final DhikrCategory category;
  const DhikrScreen({super.key, required this.category});

  @override
  State<DhikrScreen> createState() => _DhikrScreenState();
}

class _DhikrScreenState extends State<DhikrScreen> {
  int _expandEpoch = 0;
  bool _forceExpanded = false;

  void _toggleExpandAll() {
    setState(() {
      _forceExpanded = !_forceExpanded;
      _expandEpoch++;
    });
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final athkar = AthkarData.getByCategory(widget.category);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient(isDark)),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context, isDark, athkar.length),
              Expanded(child: _buildList(context, isDark, athkar)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark, int count) {
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
          const SizedBox(width: 8),
          GestureDetector(
            onTap: count > 0 ? _toggleExpandAll : null,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppTheme.cardGradient(isDark),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3)),
              ),
              child: Icon(
                _forceExpanded ? Icons.unfold_less_rounded : Icons.unfold_more_rounded,
                color: AppTheme.gold,
                size: 20,
              ),
            ),
          ),
          const Spacer(),
          Text(
            widget.category.nameFor(context.watch<LanguageProvider>().language),
            style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.gold),
          ),
          const Spacer(),
          Text(
            '$count',
            style: GoogleFonts.cairo(fontSize: 14, color: AppTheme.subTextColor(isDark)),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, bool isDark, List<DhikrModel> athkar) {
    if (athkar.isEmpty) {
      return Center(
        child: Text(
          context.tr('dhikrEmptyList'),
          style: GoogleFonts.cairo(fontSize: 18, color: AppTheme.subTextColor(isDark)),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: athkar.length,
      itemBuilder: (context, index) => DhikrCard(
        key: ValueKey(athkar[index].id),
        dhikr: athkar[index],
        initiallyExpanded: _forceExpanded,
        expandEpoch: _expandEpoch,
        forceExpanded: _forceExpanded,
        onCompleted: () => context.read<StatsProvider>().recordCompletion(),
      ),
    );
  }
}
