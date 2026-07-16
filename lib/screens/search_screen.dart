import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../data/athkar_data.dart';
import '../models/dhikr_model.dart';
import '../providers/stats_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/dhikr_card.dart';

/// شاشة بحث تفلتر كل الأذكار (بكل الفئات) بعنوان الذكر أو نصه أو فضله.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<DhikrModel> _results = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      setState(() => _results = []);
      return;
    }
    final all = <DhikrModel>[];
    for (final category in DhikrCategory.values) {
      all.addAll(AthkarData.getByCategory(category));
    }
    setState(() {
      _results = all
          .where((d) =>
              d.title.contains(trimmed) ||
              d.text.contains(trimmed) ||
              (d.virtue?.contains(trimmed) ?? false))
          .toList();
    });
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
            'البحث بالأذكار',
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
          onChanged: _search,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(color: AppTheme.textColor(isDark), fontSize: 16),
          decoration: InputDecoration(
            hintText: 'ابحث بعنوان الذكر أو نصه...',
            hintStyle: GoogleFonts.cairo(color: AppTheme.subTextColor(isDark), fontSize: 14),
            prefixIcon: Icon(Icons.search, color: AppTheme.gold),
            suffixIcon: _controller.text.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _controller.clear();
                      _search('');
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
    if (_controller.text.trim().isEmpty) {
      return Center(
        child: Text(
          'اكتب كلمة للبحث بين كل الأذكار',
          style: GoogleFonts.cairo(fontSize: 15, color: AppTheme.subTextColor(isDark)),
        ),
      );
    }
    if (_results.isEmpty) {
      return Center(
        child: Text(
          'لا توجد نتائج',
          style: GoogleFonts.cairo(fontSize: 15, color: AppTheme.subTextColor(isDark)),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: _results.length,
      itemBuilder: (context, index) => DhikrCard(
        key: ValueKey(_results[index].id),
        dhikr: _results[index],
        subtitle: _results[index].category.arabicName,
        initiallyExpanded: true,
        onCompleted: () => context.read<StatsProvider>().recordCompletion(),
      ),
    );
  }
}
