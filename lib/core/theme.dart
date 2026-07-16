import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// وصف لون ثانوي (accent) واحد ضمن قائمة الاختيار بالإعدادات.
class AccentPreset {
  final String name;
  final Color main;
  final Color light;
  const AccentPreset({required this.name, required this.main, required this.light});
}

class AppTheme {
  // ألوان العلامة التجارية (مشتركة بين الوضعين)
  static const Color primaryGreen = Color(0xFF1B5E20);
  static const Color secondaryGreen = Color(0xFF2E7D32);
  static const Color lightGreenAccent = Color(0xFF4CAF50);

  // =============================================
  // اللون الثانوي (accent) القابل للتخصيص من قِبل المستخدم — الأخضر يبقى
  // دائماً اللون الرئيسي الثابت للتطبيق (primaryGreen وخلفياته)، لكن هذا
  // اللون الثانوي (المستخدم بالأيقونات والحدود والعناوين) يمكن تغييره من
  // الإعدادات. القيمة الافتراضية هي نفس الذهبي الأصلي للتطبيق.
  // =============================================
  static const List<AccentPreset> accentPresets = [
    AccentPreset(name: 'ذهبي', main: Color(0xFFD4AF37), light: Color(0xFFFFD700)),
    AccentPreset(name: 'أزرق', main: Color(0xFF2C7DA0), light: Color(0xFF61A5C2)),
    AccentPreset(name: 'بنفسجي', main: Color(0xFF6A4C93), light: Color(0xFF9D7FC9)),
    AccentPreset(name: 'عنّابي', main: Color(0xFFB5443E), light: Color(0xFFE0736C)),
    AccentPreset(name: 'فيروزي', main: Color(0xFF0E7C86), light: Color(0xFF3FB8C4)),
    AccentPreset(name: 'كهرماني', main: Color(0xFFC97A2B), light: Color(0xFFE5A15C)),
  ];

  static int accentIndex = 0;
  static Color gold = accentPresets[0].main;
  static Color lightGold = accentPresets[0].light;

  /// يغيّر اللون الثانوي لكل التطبيق فوراً — يكفي استدعاؤه مرة ثم عمل
  /// notifyListeners() من ThemeProvider لإعادة رسم كل الشاشات، لأن كل
  /// الشاشات تقرأ AppTheme.gold مباشرة عند كل build() ولا تخزّنه مسبقاً.
  static void setAccent(int index) {
    if (index < 0 || index >= accentPresets.length) return;
    accentIndex = index;
    gold = accentPresets[index].main;
    lightGold = accentPresets[index].light;
  }

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
          ? ColorScheme.dark(
              primary: primaryGreen,
              secondary: gold,
              surface: darkCardBackground,
            )
          : ColorScheme.light(
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
        iconTheme: IconThemeData(color: gold),
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

  static LinearGradient get goldGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gold, lightGold, gold],
  );

  // =============================================
  // لوحة الشاشة الرئيسية الجديدة (لوحة المعلومات)
  // تدرّج أخضر عصري (غامق ← وسط ← فاتح) + ألوان قريبة منه لإحساس حيوي
  // وجذاب دون كسر هوية التطبيق الأساسية (أخضر + ذهبي).
  // =============================================
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF07271A), Color(0xFF127A4C), Color(0xFF57D98C)],
  );

  static const LinearGradient heroGradientSoft = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0E3D26), Color(0xFF1B7A4C)],
  );

  // ألوان مساعدة لبطاقات "أدواتك اليوم" وأيقونات الشريط السفلي — درجات
  // قريبة من الأخضر (زمرّدي، نعناعي، فيروزي، زيتوني) لتنويع بصري متناسق.
  static const Color toolEmerald = Color(0xFF1FAA6D);
  static const Color toolTeal = Color(0xFF14A085);
  static const Color toolMint = Color(0xFF7FE0A8);
  static const Color toolOlive = Color(0xFF9CA83C);
  static const Color toolSage = Color(0xFF6FA37D);
  static const Color toolAmber = Color(0xFFE0A339);

  /// توهّج ناعم خلف الأيقونات (Soft Glow Minimalist Icons) بلون العنصر نفسه.
  static List<BoxShadow> softGlow(Color color, {double opacity = 0.35, double blur = 18}) {
    return [BoxShadow(color: color.withValues(alpha: opacity), blurRadius: blur, spreadRadius: 0.5)];
  }

  static Color textColor(bool isDark) => isDark ? darkTextPrimary : lightTextPrimary;
  static Color subTextColor(bool isDark) => isDark ? darkTextSecondary : lightTextSecondary;
  static Color surfaceColor(bool isDark) => isDark ? darkCardBackground : lightCardBackground;
}

/// تحويل الأرقام الإنجليزية (0-9) داخل أي نص إلى أرقام هندية عربية (٠-٩)
/// للعرض بالشكل التقليدي المألوف في الواجهات العربية (الوقت، التاريخ...).
String toArabicDigits(String input) {
  const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  String result = input;
  for (int i = 0; i < western.length; i++) {
    result = result.replaceAll(western[i], arabic[i]);
  }
  return result;
}
