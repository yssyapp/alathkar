import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../core/theme.dart';
import '../data/athkar_data.dart';
import '../models/dhikr_model.dart';
import '../providers/favorites_provider.dart';
import '../providers/theme_provider.dart';

class DhikrScreen extends StatefulWidget {
  final DhikrCategory category;
  const DhikrScreen({super.key, required this.category});

  @override
  State<DhikrScreen> createState() => _DhikrScreenState();
}

class _DhikrScreenState extends State<DhikrScreen> {
  late List<DhikrModel> _athkar;
  late List<int> _counters;

  @override
  void initState() {
    super.initState();
    _athkar = AthkarData.getByCategory(widget.category);
    _counters = List.filled(_athkar.length, 0);
  }

  void _incrementCounter(int index) {
    final dhikr = _athkar[index];
    if (dhikr.count <= 1) return;
    if (_counters[index] >= dhikr.count) {
      HapticFeedback.mediumImpact();
      return;
    }
    setState(() {
      _counters[index]++;
    });
    if (_counters[index] >= dhikr.count) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }
  }

  void _resetCounter(int index) {
    setState(() {
      _counters[index] = 0;
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
              Expanded(child: _buildList(isDark)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
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
              child: const Icon(Icons.arrow_forward_ios, color: AppTheme.gold, size: 20),
            ),
          ),
          const Spacer(),
          Text(
            widget.category.arabicName,
            style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.gold),
          ),
          const Spacer(),
          Text(
            '${_athkar.length}',
            style: GoogleFonts.cairo(fontSize: 14, color: AppTheme.subTextColor(isDark)),
          ),
        ],
      ),
    );
  }

  Widget _buildList(bool isDark) {
    if (_athkar.isEmpty) {
      return Center(
        child: Text(
          'لا توجد أذكار',
          style: GoogleFonts.cairo(fontSize: 18, color: AppTheme.subTextColor(isDark)),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: _athkar.length,
      itemBuilder: (context, index) => _buildDhikrCard(index, isDark),
    );
  }

  Widget _buildDhikrCard(int index, bool isDark) {
    final dhikr = _athkar[index];
    final counter = _counters[index];
    final isCompleted = dhikr.count > 1 && counter >= dhikr.count;
    final isFavorite = context.watch<FavoritesProvider>().isFavorite(dhikr);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => context.read<FavoritesProvider>().toggleFavorite(dhikr),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppTheme.cardGradient(isDark),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3)),
                  ),
                  child: Icon(
                    isFavorite ? Icons.star : Icons.star_border,
                    color: AppTheme.gold,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: AppTheme.goldGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      dhikr.title,
                      style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.darkBackground),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: dhikr.count > 1 ? () => _incrementCounter(index) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppTheme.cardGradient(isDark),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isCompleted ? AppTheme.gold : AppTheme.gold.withValues(alpha: 0.3),
                  width: isCompleted ? 2 : 1,
                ),
              ),
              child: Text(
                dhikr.text,
                style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.textColor(isDark), height: 2.0),
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.gold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🌟', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      dhikr.virtue!,
                      style: GoogleFonts.cairo(fontSize: 13, color: AppTheme.gold, height: 1.8),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ],
              ),
            ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(dhikr.source, style: GoogleFonts.cairo(fontSize: 12, color: AppTheme.subTextColor(isDark)), textDirection: TextDirection.rtl),
                Text(dhikr.bookSource, style: GoogleFonts.cairo(fontSize: 12, color: AppTheme.gold.withValues(alpha: 0.7)), textDirection: TextDirection.rtl),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (dhikr.count > 1) ...[
                GestureDetector(
                  onTap: () => _incrementCounter(index),
                  child: Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: isCompleted ? AppTheme.goldGradient : AppTheme.cardGradient(isDark),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.gold, width: 1),
                    ),
                    child: Text(
                      '$counter / ${dhikr.count}',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isCompleted ? AppTheme.darkBackground : AppTheme.textColor(isDark),
                      ),
                    ),
                  ),
                ),
                if (counter > 0) ...[
                  const SizedBox(width: 8),
                  _buildActionButton(
                    icon: Icons.refresh,
                    isDark: isDark,
                    onTap: () => _resetCounter(index),
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
            ],
          ),
          const SizedBox(height: 8),
          Divider(color: AppTheme.gold.withValues(alpha: 0.15)),
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
