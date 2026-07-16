import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../models/dhikr_model.dart';
import '../providers/favorites_provider.dart';
import '../providers/stats_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/dhikr_card.dart';

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
              child: Icon(Icons.arrow_forward_ios, color: AppTheme.gold, size: 20),
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
      itemBuilder: (context, index) => DhikrCard(
        key: ValueKey(favorites[index].id),
        dhikr: favorites[index],
        subtitle: favorites[index].category.arabicName,
        initiallyExpanded: true,
        onCompleted: () => context.read<StatsProvider>().recordCompletion(),
      ),
    );
  }
}
