import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'providers/favorites_provider.dart';
import 'providers/habits_provider.dart';
import 'providers/khatma_provider.dart';
import 'providers/language_provider.dart';
import 'providers/online_features_provider.dart';
import 'providers/prayer_notification_provider.dart';
import 'providers/random_dhikr_notification_provider.dart';
import 'providers/reminder_provider.dart';
import 'providers/stats_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/tools_order_provider.dart';
import 'screens/dashboard_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // خط Cairo مُضمَّن محلياً بالكامل (راجع pubspec.yaml)، فنمنع GoogleFonts من
  // محاولة تحميله عبر الشبكة من خوادم قوقل — يضمن هذا عمل التطبيق بلا
  // إنترنت ١٠٠٪ من أول لحظة تشغيل، بدون أي تعديل على استدعاءات
  // GoogleFonts.cairo(...) الموجودة بكل الشاشات.
  GoogleFonts.config.allowRuntimeFetching = false;
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const AthkariApp());
}

class AthkariApp extends StatelessWidget {
  const AthkariApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => StatsProvider()),
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
        ChangeNotifierProvider(create: (_) => PrayerNotificationProvider()),
        ChangeNotifierProvider(create: (_) => RandomDhikrNotificationProvider()),
        ChangeNotifierProvider(create: (_) => KhatmaProvider()),
        ChangeNotifierProvider(create: (_) => HabitsProvider()),
        ChangeNotifierProvider(create: (_) => ToolsOrderProvider()),
        ChangeNotifierProvider(create: (_) => OnlineFeaturesProvider()),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, _) {
          return MaterialApp(
            title: 'الأذكار',
            debugShowCheckedModeBanner: false,
            locale: languageProvider.language.locale,
            theme: themeProvider.isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
            home: Directionality(
              textDirection: languageProvider.language.isRtl
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: const DashboardHomeScreen(),
            ),
          );
        },
      ),
    );
  }
}
