import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../core/theme.dart';
import '../models/dhikr_model.dart';
import '../data/athkar_data.dart';

class DhikrScreen extends StatefulWidget {
  final DhikrCategory category;
  const DhikrScreen({super.key, required this.category});

  @override
  State<DhikrScreen> createState() => _DhikrScreenState();
}

class _DhikrScreenState extends State<DhikrScreen> {
  late List<DhikrModel> _athkar;
  late List<int> _counters;

  @override
  void initState() {
    super.initState();
    _athkar = AthkarData.getByCategory(widget.category);
    _counters = List.filled(_athkar.length, 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(child: _buildList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.arrow_forward_ios, color: AppTheme.gold, size: 20),
            ),
          ),
          const Spacer(),
          Text(
            widget.category.arabicName,
            style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.gold),
          ),
          const Spacer(),
          Text(
            '${_athkar.length}',
            style: GoogleFonts.cairo(fontSize: 14, color: AppTheme.textGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_athkar.isEmpty) {
      return Center(
        child: Text('لا توجد أذكار', style: GoogleFonts.cairo(fontSize: 18, color: AppTheme.textGrey)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: _athkar.length,
      itemBuilder: (context, index) => _buildDhikrCard(index),
    );
  }

  Widget _buildDhikrCard(int index) {
    final dhikr = _athkar[index];
    final counter = _counters[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppTheme.goldGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                dhikr.title,
                style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.darkBackground),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppTheme.cardGradient,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3), width: 1),
            ),
            child: Text(
              dhikr.text,
              style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.textWhite, height: 2.0),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
          ),
          const SizedBox(height: 12),
          if (dhikr.virtue != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.gold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🌟', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      dhikr.virtue!,
                      style: GoogleFonts.cairo(fontSize: 13, color: AppTheme.gold, height: 1.8),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ],
              ),
            ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(dhikr.source, style: GoogleFonts.cairo(fontSize: 12, color: AppTheme.textGrey), textDirection: TextDirection.rtl),
                Text(dhikr.bookSource, style: GoogleFonts.cairo(fontSize: 12, color: AppTheme.gold.withValues(alpha: 0.7)), textDirection: TextDirection.rtl),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (dhikr.count > 1)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_counters[index] < dhikr.count) _counters[index]++;
                    });
                    HapticFeedback.lightImpact();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(left: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: counter >= dhikr.count ? AppTheme.goldGradient : AppTheme.cardGradient,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.gold, width: 1),
                    ),
                    child: Text(
                      '$counter / ${dhikr.count}',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: counter >= dhikr.count ? AppTheme.darkBackground : AppTheme.textWhite,
                      ),
                    ),
                  ),
                ),
              _buildActionButton(
                icon: Icons.copy,
                onTap: () {
                  Clipboard.setData(ClipboardData(text: dhikr.text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم نسخ الذكر', style: GoogleFonts.cairo(), textDirection: TextDirection.rtl),
                      backgroundColor: AppTheme.primaryGreen,
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.share,
                onTap: () => SharePlus.instance.share(
                  ShareParams(
                    text: '${dhikr.text}\n\n${dhikr.source}\n${dhikr.bookSource}',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(color: AppTheme.gold.withValues(alpha: 0.15)),
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3)),
        ),
        child: Icon(icon, color: AppTheme.gold, size: 18),
      ),
    );
  }
}
