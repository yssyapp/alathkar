import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_strings.dart';
import '../core/theme.dart';
import '../data/athkar_data.dart';
import '../models/dhikr_model.dart';

/// شاشة أسماء الله الحسنى: عرض تفصيلي للأسماء التسعة والتسعين مع معانيها
/// ومصدرها، بالاعتماد على نفس بيانات فئة "أسماء الله الحسنى" الموجودة أصلاً
/// ضمن شاشة الأذكار (AthkarData) — مصدر واحد موثوق ومُتحقّق منه، لتفادي أي
/// تعارض أو خطأ بين شاشتين مختلفتين لنفس المحتوى الديني.
class AsmaAllahScreen extends StatelessWidget {
  const AsmaAllahScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final names = AthkarData.getByCategory(DhikrCategory.names);

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('asmaTitle'), style: GoogleFonts.cairo(fontWeight: FontWeight.w700))),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.gold.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.gold.withValues(alpha: 0.25)),
              ),
              child: Text(
                context.tr('asmaIntroDescription'),
                style: GoogleFonts.cairo(fontSize: 11, color: AppTheme.subTextColor(isDark), height: 1.6),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: names.length,
                itemBuilder: (context, index) => _buildNameCard(isDark, index + 1, names[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameCard(bool isDark, int number, DhikrModel name) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.gold.withValues(alpha: 0.14)),
            child: Text(
              toArabicDigits('$number'),
              style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.gold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.text,
                  style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.textColor(isDark)),
                  textAlign: TextAlign.right,
                ),
                if (name.virtue != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    name.virtue!,
                    style: GoogleFonts.cairo(fontSize: 12.5, color: AppTheme.subTextColor(isDark), height: 1.5),
                    textAlign: TextAlign.right,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
