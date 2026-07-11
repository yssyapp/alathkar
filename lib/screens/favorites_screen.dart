import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../core/theme.dart';
import '../models/dhikr_model.dart';
import '../providers/favorites_provider.dart';
import '../providers/theme_provider.dart';

/// شاشة تعرض كل الأذكار التي أضافها المستخدم إلى المفضلة، من كل الفئات.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final favorites = context.watch<FavoritesProvider>().favoriteDhikr;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient(isDark)),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context, isDark, favorites.length),
              Expanded(child: _buildList(context, favorites, isDark)),
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
              child: const Icon(Icons.arrow_forward_ios, color: AppTheme.gold, size: 20),
            ),
          ),
          const Spacer(),
          Text(
            'المفضلة',
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

  Widget _buildList(BuildContext context, List<DhikrModel> favorites, bool isDark) {
    if (favorites.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star_border, color: AppTheme.gold.withValues(alpha: 0.6), size: 48),
              const SizedBox(height: 12),
              Text(
                'لا توجد أذكار مفضّلة بعد',
                style: GoogleFonts.cairo(fontSize: 16, color: AppTheme.subTextColor(isDark)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'اضغط على أيقونة النجمة بجانب أي ذكر لإضافته هنا',
                style: GoogleFonts.cairo(fontSize: 13, color: AppTheme.subTextColor(isDark)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: favorites.length,
      itemBuilder: (context, index) => _buildDhikrCard(context, favorites[index], isDark),
    );
  }

  Widget _buildDhikrCard(BuildContext context, DhikrModel dhikr, bool isDark) {
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
                  child: const Icon(Icons.star, color: AppTheme.gold, size: 18),
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
                      '${dhikr.title} · ${dhikr.category.arabicName}',
                      style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.darkBackground),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppTheme.cardGradient(isDark),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3), width: 1),
            ),
            child: Text(
              dhikr.text,
              style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.textColor(isDark), height: 2.0),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
