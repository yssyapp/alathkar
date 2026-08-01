import 'package:flutter/material.dart';
import '../models/dhikr_model.dart';
import 'azkar_swipe_screen.dart';

/// شاشة سريعة تعرض أذكار الصباح والمساء في تبويبين. كل تبويب يعرض الأذكار
/// بشكل "متحرك باللمس" (ذكر واحد يملأ الشاشة، بدون عنوان فوقه، والتنقل
/// بينها بالسحب لأعلى/لأسفل) عبر [AzkarSwipeView] بدل قائمة أكورديون
/// طويلة.
class AzkarTabsScreen extends StatelessWidget {
  const AzkarTabsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xff0d3d2f),
        appBar: AppBar(
          backgroundColor: const Color(0xff0d3d2f),
          elevation: 0,
          title: const Text('الأذكار'),
          bottom: const TabBar(
            indicatorColor: Colors.amber,
            labelColor: Colors.amber,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'أذكار الصباح'),
              Tab(text: 'أذكار المساء'),
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
