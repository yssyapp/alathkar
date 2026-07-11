import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ألوان العلامة التجارية (مشتركة بين الوضعين)
  static const Color primaryGreen = Color(0xFF1B5E20);
  static const Color secondaryGreen = Color(0xFF2E7D32);
  static const Color lightGreenAccent = Color(0xFF4CAF50);
  static const Color gold = Color(0xFFD4AF37);
  static const Color lightGold = Color(0xFFFFD700);

  // الوضع الداكن (التصميم الأصلي للتطبيق)
  static const Color darkBackground = Color(0xFF0A1F0A);
  static const Color darkCardBackground = Color(0xFF1A3A1A);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0BEC5);

  // الوضع الفاتح
  static const Color lightBackground = Color(0xFFFBF8F1);
  static const Color lightCardBackground = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF14331A);
  static const Color lightTextSecondary = Color(0xFF5F6F63);

  // إبقاء الأسماء القديمة للتوافق مع أي كود يشير إليها مباشرة (تشير للوضع الداكن)
  static const Color textWhite = darkTextPrimary;
  static const Color textGrey = darkTextSecondary;
  static const Color cardBackground = darkCardBackground;

  static ThemeData get darkTheme => _buildTheme(isDark: true);
  static ThemeData get lightTheme => _buildTheme(isDark: false);

  static ThemeData _buildTheme({required bool isDark}) {
    final Color bg = isDark ? darkBackground : lightBackground;
    final Color textPrimary = isDark ? darkTextPrimary : lightTextPrimary;
    final Color textSecondary = isDark ? darkTextSecondary : lightTextSecondary;
    final Color surface = isDark ? darkCardBackground : lightCardBackground;

    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primaryColor: primaryGreen,
      scaffoldBackgroundColor: bg,
      colorScheme: isDark
          ? const ColorScheme.dark(
              primary: primaryGreen,
              secondary: gold,
              surface: darkCardBackground,
            )
          : const ColorScheme.light(
              primary: primaryGreen,
              secondary: gold,
              surface: lightCardBackground,
            ),
      textTheme: GoogleFonts.cairoTextTheme(
        TextTheme(
          displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: textPrimary),
          displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: textPrimary),
          bodyLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: textPrimary, height: 2.0),
          bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: textSecondary),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.w700, color: gold),
        iconTheme: const IconThemeData(color: gold),
      ),
      cardColor: surface,
    );
  }

  static LinearGradient backgroundGradient(bool isDark) {
    return isDark
        ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A1F0A), Color(0xFF1B5E20), Color(0xFF0A1F0A)],
          )
        : const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFBF8F1), Color(0xFFF1E9D8), Color(0xFFFBF8F1)],
          );
  }

  static LinearGradient cardGradient(bool isDark) {
    return isDark
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A3A1A), Color(0xFF0D2B0D)],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFFFFF), Color(0xFFF3EEDF)],
          );
  }

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD4AF37), Color(0xFFFFD700), Color(0xFFD4AF37)],
  );

  static Color textColor(bool isDark) => isDark ? darkTextPrimary : lightTextPrimary;
  static Color subTextColor(bool isDark) => isDark ? darkTextSecondary : lightTextSecondary;
  static Color surfaceColor(bool isDark) => isDark ? darkCardBackground : lightCardBackground;
}
