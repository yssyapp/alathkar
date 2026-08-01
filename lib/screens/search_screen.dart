import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/app_strings.dart';
import '../core/theme.dart';
import '../models/dhikr_model.dart';
import '../providers/language_provider.dart';
import '../providers/search_provider.dart';
import '../providers/stats_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/dhikr_card.dart';

/// شاشة بحث تفلتر كل الأذكار (بكل الفئات) بعنوان الذكر أو نصه أو فضله.
///
/// حالة البحث (النص + النتائج) تعيش في [SearchProvider] بدل setState محلي
/// — بهذا الشكل تُعاد بناء أجزاء الواجهة المستمعة فقط عند تغيّر النتائج
/// فعلياً، ونفس الحالة تبقى متاحة عبر Provider لأي شاشة أخرى مستقبلاً
/// بدون تمريرها يدوياً.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    // مراقبة SearchProvider تتم داخل _buildResults، وبما أنها تُستدعى من
    // نفس build() فهذا يكفي لإعادة بناء الشاشة كاملة (شاملاً زر المسح)
    // عند تغيّر نص أو نتائج البحث، بدون حاجة لمراقبة مكررة هنا.
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient(isDark)),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context, isDark),
              _buildSearchField(isDark),
              Expanded(child: _buildResults(isDark)),
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
            context.tr('searchTitle'),
            style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.gold),
          ),
          const Spacer(),
          const SizedBox(width: 36),
        ],
      ),
    );
  }

  Widget _buildSearchField(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.cardGradient(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3)),
        ),
        child: TextField(
          controller: _controller,
          onChanged: (q) => context.read<SearchProvider>().search(q),
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(color: AppTheme.textColor(isDark), fontSize: 16),
          decoration: InputDecoration(
            hintText: context.tr('searchHint'),
            hintStyle: GoogleFonts.cairo(color: AppTheme.subTextColor(isDark), fontSize: 14),
            prefixIcon: Icon(Icons.search, color: AppTheme.gold),
            suffixIcon: _controller.text.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _controller.clear();
                      context.read<SearchProvider>().clear();
                    },
                    child: Icon(Icons.close, color: AppTheme.subTextColor(isDark)),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildResults(bool isDark) {
    final lang = context.watch<LanguageProvider>().language;
    final search = context.watch<SearchProvider>();
    if (!search.hasQuery) {
      return Center(
        child: Text(
          context.tr('searchEmptyPrompt'),
          style: GoogleFonts.cairo(fontSize: 15, color: AppTheme.subTextColor(isDark)),
        ),
      );
    }
    if (search.results.isEmpty) {
      return Center(
        child: Text(
          context.tr('searchNoResults'),
          style: GoogleFonts.cairo(fontSize: 15, color: AppTheme.subTextColor(isDark)),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: search.results.length,
      itemBuilder: (context, index) => DhikrCard(
        key: ValueKey(search.results[index].id),
        dhikr: search.results[index],
        subtitle: search.results[index].category.nameFor(lang),
        initiallyExpanded: true,
        onCompleted: () => context.read<StatsProvider>().recordCompletion(),
      ),
    );
  }
}
