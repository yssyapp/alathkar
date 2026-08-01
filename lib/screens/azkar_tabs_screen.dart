import 'package:flutter/material.dart';
import '../data/athkar_data.dart';
import '../models/dhikr_model.dart';

/// شاشة سريعة تعرض أذكار الصباح والمساء في تبويبين، كل ذكر في بطاقة
/// قابلة للطي/الفتح (أكورديون) بتصميم أخضر داكن وذهبي مبسّط. عند الفتح
/// يظهر النص كاملاً مع المصدر والفضل (إن وُجد).
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
        body: TabBarView(
          children: [
            AzkarPage(azkar: AthkarData.getByCategory(DhikrCategory.morning)),
            AzkarPage(azkar: AthkarData.getByCategory(DhikrCategory.evening)),
          ],
        ),
      ),
    );
  }
}

/// قائمة أذكار فئة واحدة، كل ذكر في بطاقة ExpansionTile خضراء/ذهبية.
/// العنوان مخفي كما في التصميم الأصلي — عند الطي تظهر أول كلمات النص
/// كمعاينة سريعة (بدل خانة فارغة تمامًا)، وعند الفتح يظهر النص كاملاً
/// مع المصدر والفضل.
class AzkarPage extends StatelessWidget {
  final List<DhikrModel> azkar;
  const AzkarPage({super.key, required this.azkar});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: azkar.length,
      itemBuilder: (context, index) {
        final dhikr = azkar[index];
        final preview = dhikr.text.length > 40 ? '${dhikr.text.substring(0, 40)}...' : dhikr.text;
        return Card(
          color: const Color(0xff1d5a44),
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          clipBehavior: Clip.antiAlias,
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 18),
            childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            title: Text(
              preview,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            iconColor: Colors.amber,
            collapsedIconColor: Colors.amber,
            children: [
              SelectableText(
                dhikr.text,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 21, height: 2),
              ),
              if (dhikr.count > 1) ...[
                const SizedBox(height: 10),
                Text('التكرار: ${dhikr.count}',
                    textAlign: TextAlign.center, style: const TextStyle(color: Colors.amber, fontSize: 13)),
              ],
              if (dhikr.virtue != null) ...[
                const SizedBox(height: 14),
                Text(dhikr.virtue!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 13.5, fontStyle: FontStyle.italic)),
              ],
              const SizedBox(height: 14),
              Divider(color: Colors.white.withValues(alpha: 0.15)),
              const SizedBox(height: 6),
              Text(dhikr.source,
                  textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54, fontSize: 11.5)),
            ],
          ),
        );
      },
    );
  }
}
