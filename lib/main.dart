import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'providers/favorites_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'الأذكار',
            debugShowCheckedModeBanner: false,
            locale: const Locale('ar'),
            theme: themeProvider.isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
