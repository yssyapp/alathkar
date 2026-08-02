import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_strings.dart';
import '../models/dhikr_model.dart';
import '../providers/language_provider.dart';
import 'azkar_swipe_screen.dart';

/// شاشة سريعة تعرض أذكار الصباح والمساء في تبويبين. كل تبويب يعرض الأذكار
/// بشكل "متحرك باللمس" (ذكر واحد يملأ الشاشة، بدون عنوان فوقه، والتنقل
/// بينها بالسحب لأعلى/لأسفل) عبر [AzkarSwipeView] بدل قائمة أكورديون
/// طويلة. كل النصوص هنا (العنوان وتبويبا الصباح/المساء) مترجمة بحسب لغة
/// الواجهة المختارة — بلا نص عربي ثابت — تماماً مثل بقية الشاشات.
class AzkarTabsScreen extends StatelessWidget {
  const AzkarTabsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().language;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xff0d3d2f),
        appBar: AppBar(
          backgroundColor: const Color(0xff0d3d2f),
          elevation: 0,
          title: Text(context.tr('athkarCatTitle')),
          bottom: TabBar(
            indicatorColor: Colors.amber,
            labelColor: Colors.amber,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: DhikrCategory.morning.nameFor(lang)),
              Tab(text: DhikrCategory.evening.nameFor(lang)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AzkarSwipeView(category: DhikrCategory.morning, embedded: true),
            AzkarSwipeView(category: DhikrCategory.evening, embedded: true),
          ],
        ),
      ),
    );
  }
}
