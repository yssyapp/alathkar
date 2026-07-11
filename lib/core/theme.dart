import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryGreen = Color(0xFF1B5E20);
  static const Color secondaryGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFF4CAF50);
  static const Color gold = Color(0xFFD4AF37);
  static const Color lightGold = Color(0xFFFFD700);
  static const Color darkBackground = Color(0xFF0A1F0A);
  static const Color cardBackground = Color(0xFF1A3A1A);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGrey = Color(0xFFB0BEC5);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryGreen,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: primaryGreen,
        secondary: gold,
        surface: cardBackground,
      ),
      textTheme: GoogleFonts.cairoTextTheme(
        const TextTheme(
          displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: textWhite),
          displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: textWhite),
          bodyLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: textWhite, height: 2.0),
          bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: textGrey),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.w700, color: gold),
        iconTheme: const IconThemeData(color: gold),
      ),
    );
  }

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0A1F0A), Color(0xFF1B5E20), Color(0xFF0A1F0A)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A3A1A), Color(0xFF0D2B0D)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD4AF37), Color(0xFFFFD700), Color(0xFFD4AF37)],
  );
}
