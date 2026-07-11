import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../models/dhikr_model.dart';
import '../providers/favorites_provider.dart';
import '../providers/theme_provider.dart';
import 'dhikr_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient(isDark),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, isDark),
              Expanded(child: _buildCategoryGrid(context, isDark)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    final favoritesCount = context.watch<FavoritesProvider>().count;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildIconButton(
                icon: Icons.favorite,
                isDark: isDark,
                badgeCount: favoritesCount,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                  );
                },
              ),
              _buildIconButton(
                icon: isDark ? Icons.light_mode : Icons.dark_mode,
                isDark: isDark,
                onTap: () => context.read<ThemeProvider>().toggleTheme(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'بسم الله الرحمن الرحيم',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.gold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'الأذكار',
            style: GoogleFonts.cairo(
              fontSize: 42,
              fontWeight: FontWeight.w900,
              color: AppTheme.textColor(isDark),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.gold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'سورة الرعد: الآية (28)',
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: AppTheme.subTextColor(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
    int badgeCount = 0,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: AppTheme.cardGradient(isDark),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: AppTheme.gold, size: 20),
          ),
          if (badgeCount > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  gradient: AppTheme.goldGradient,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Text(
                  '$badgeCount',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.darkBackground,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context, bool isDark) {
    final categories = DhikrCategory.values.toList();
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return _buildCategoryCard(context, categories[index], isDark);
      },
    );
  }

  Widget _buildCategoryCard(BuildContext context, DhikrCategory category, bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DhikrScreen(category: category),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.cardGradient(isDark),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.gold.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(category.icon, style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 8),
            Text(
              category.arabicName,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.textColor(isDark),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
