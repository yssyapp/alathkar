import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_strings.dart';
import '../core/theme.dart';

/// شاشة العدادات: تسبيح، حمد، استغفار (بأهداف يومية تُصفَّر تلقائياً كل يوم
/// جديد)، بالإضافة لمسبحة عامة حرة بدون هدف ولا تصفير تلقائي. كل عداد يُحفظ
/// محلياً عبر SharedPreferences فيبقى محفوظاً بعد إغلاق التطبيق.
class CountersScreen extends StatefulWidget {
  const CountersScreen({super.key});

  @override
  State<CountersScreen> createState() => _CountersScreenState();
}

class _CounterConfig {
  final String key;
  final String titleKey;
  final String subtitleKey;
  final Color accent;
  final int? dailyTarget;
  final bool resetsDaily;

  const _CounterConfig({
    required this.key,
    required this.titleKey,
    required this.subtitleKey,
    required this.accent,
    this.dailyTarget,
    this.resetsDaily = true,
  });
}

class _CountersScreenState extends State<CountersScreen> {
  static const List<_CounterConfig> _counters = [
    _CounterConfig(key: 'tasbih', titleKey: 'countersTasbihTitle', subtitleKey: 'countersTasbihSubtitle', accent: AppTheme.toolEmerald, dailyTarget: 33),
    _CounterConfig(key: 'hamd', titleKey: 'countersHamdTitle', subtitleKey: 'countersHamdSubtitle', accent: AppTheme.toolAmber, dailyTarget: 33),
    _CounterConfig(key: 'istighfar', titleKey: 'countersIstighfarTitle', subtitleKey: 'countersIstighfarSubtitle', accent: AppTheme.toolTeal, dailyTarget: 100),
    _CounterConfig(key: 'misbaha', titleKey: 'countersMisbahaTitle', subtitleKey: 'countersMisbahaSubtitle', accent: AppTheme.toolSage, resetsDaily: false),
  ];

  final Map<String, int> _counts = {};
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = _todayKey();
    for (final c in _counters) {
      if (c.resetsDaily) {
        final storedDate = prefs.getString('counter_${c.key}_date');
        _counts[c.key] = storedDate == todayKey ? (prefs.getInt('counter_${c.key}_count') ?? 0) : 0;
      } else {
        _counts[c.key] = prefs.getInt('counter_${c.key}_count') ?? 0;
      }
    }
    if (mounted) setState(() => _loaded = true);
  }

  Future<void> _increment(_CounterConfig c) async {
    HapticFeedback.selectionClick();
    final newCount = (_counts[c.key] ?? 0) + 1;
    setState(() => _counts[c.key] = newCount);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('counter_${c.key}_count', newCount);
    if (c.resetsDaily) {
      await prefs.setString('counter_${c.key}_date', _todayKey());
    }
    if (c.dailyTarget != null && newCount == c.dailyTarget) {
      HapticFeedback.mediumImpact();
    }
  }

  Future<void> _reset(_CounterConfig c) async {
    HapticFeedback.mediumImpact();
    setState(() => _counts[c.key] = 0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('counter_${c.key}_count', 0);
    if (c.resetsDaily) {
      await prefs.setString('counter_${c.key}_date', _todayKey());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('countersTitle'), style: GoogleFonts.cairo(fontWeight: FontWeight.w700))),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _counters.length,
                itemBuilder: (context, index) => _buildCounterCard(context, isDark, _counters[index]),
              ),
            ),
    );
  }

  Widget _buildCounterCard(BuildContext context, bool isDark, _CounterConfig c) {
    final count = _counts[c.key] ?? 0;
    final hasTarget = c.dailyTarget != null;
    final progress = hasTarget ? (count / c.dailyTarget!).clamp(0.0, 1.0) : 0.0;
    final reachedTarget = hasTarget && count >= c.dailyTarget!;
    final title = context.tr(c.titleKey);
    final subtitle = context.tr(c.subtitleKey);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient(isDark),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: c.accent.withValues(alpha: 0.28)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textColor(isDark))),
                  const SizedBox(height: 2),
                  Text(
                    hasTarget ? '$subtitle · ${context.tr('countersTargetLabel')} ${toArabicDigits('${c.dailyTarget}')}' : subtitle,
                    style: GoogleFonts.cairo(fontSize: 12, color: AppTheme.subTextColor(isDark)),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => _reset(c),
                icon: Icon(Icons.refresh_rounded, color: AppTheme.subTextColor(isDark)),
                tooltip: context.tr('countersResetTooltip'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _increment(c),
            behavior: HitTestBehavior.opaque,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (hasTarget)
                  SizedBox(
                    width: 130,
                    height: 130,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 6,
                      backgroundColor: c.accent.withValues(alpha: 0.12),
                      valueColor: AlwaysStoppedAnimation(c.accent),
                    ),
                  ),
                Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.cardGradient(isDark),
                    boxShadow: AppTheme.softGlow(c.accent, opacity: reachedTarget ? 0.6 : 0.3),
                  ),
                  child: Center(
                    child: Text(
                      toArabicDigits('$count'),
                      style: GoogleFonts.cairo(fontSize: 30, fontWeight: FontWeight.w900, color: c.accent),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (reachedTarget) ...[
            const SizedBox(height: 10),
            Text(context.tr('countersTargetReached'), style: GoogleFonts.cairo(fontSize: 12, color: c.accent, fontWeight: FontWeight.w600)),
          ],
        ],
      ),
    );
  }
}
