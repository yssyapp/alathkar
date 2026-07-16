import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';

/// حاسبة زكاة مبسّطة (نقد + ذهب/فضة + عروض تجارة - ديون) × ٢٫٥٪ إذا بلغ
/// المجموع النصاب. حساب حسابي بحت بالكامل داخل الجهاز، بدون أي اتصال
/// إنترنت أو جلب أسعار — المستخدم يُدخل القيم بنفسه حسب علمه بالأسعار
/// الحالية. لا تغطي حالات خاصة (الأنعام والزروع)، يُنصح فيها بمراجعة
/// أهل العلم.
class ZakatCalculatorSheet extends StatefulWidget {
  const ZakatCalculatorSheet({super.key});

  static void show(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ZakatCalculatorSheet(),
    );
  }

  @override
  State<ZakatCalculatorSheet> createState() => _ZakatCalculatorSheetState();
}

class _ZakatCalculatorSheetState extends State<ZakatCalculatorSheet> {
  final _cashController = TextEditingController();
  final _goldController = TextEditingController();
  final _tradeController = TextEditingController();
  final _debtController = TextEditingController();
  final _nisabController = TextEditingController(text: '4900');

  double? _result;
  bool _belowNisab = false;

  @override
  void dispose() {
    _cashController.dispose();
    _goldController.dispose();
    _tradeController.dispose();
    _debtController.dispose();
    _nisabController.dispose();
    super.dispose();
  }

  double _parse(String s) => double.tryParse(s.trim()) ?? 0;

  void _calculate() {
    final cash = _parse(_cashController.text);
    final gold = _parse(_goldController.text);
    final trade = _parse(_tradeController.text);
    final debt = _parse(_debtController.text);
    final nisab = _parse(_nisabController.text);

    final total = (cash + gold + trade - debt).clamp(0.0, double.infinity).toDouble();
    setState(() {
      if (nisab > 0 && total >= nisab) {
        _result = total * 0.025;
        _belowNisab = false;
      } else {
        _result = 0;
        _belowNisab = true;
      }
    });
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: BoxDecoration(
          gradient: AppTheme.cardGradient(isDark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.savings_outlined, color: AppTheme.gold, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'حاسبة الزكاة',
                    style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textColor(isDark)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'أدخل القيم بالريال السعودي حسب علمك بالأسعار الحالية',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(fontSize: 12, color: AppTheme.subTextColor(isDark)),
              ),
              const SizedBox(height: 20),
              _field(isDark, 'المال النقدي (رصيد + مدخرات)', _cashController),
              const SizedBox(height: 12),
              _field(isDark, 'قيمة الذهب والفضة', _goldController),
              const SizedBox(height: 12),
              _field(isDark, 'عروض التجارة (إن وُجدت)', _tradeController),
              const SizedBox(height: 12),
              _field(isDark, 'الديون المستحقة عليك (تُطرح)', _debtController),
              const SizedBox(height: 12),
              _field(isDark, 'النصاب التقريبي بالريال', _nisabController, hint: 'حدّثه حسب سعر الذهب الحالي (~85غ)'),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _calculate,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: AppTheme.goldGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'احسب الزكاة',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.darkBackground),
                  ),
                ),
              ),
              if (_result != null) ...[
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.toolEmerald.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.toolEmerald.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _belowNisab ? 'المال لم يبلغ النصاب — لا زكاة عليك' : 'الزكاة الواجبة',
                        style: GoogleFonts.cairo(fontSize: 13, color: AppTheme.subTextColor(isDark)),
                      ),
                      if (!_belowNisab) ...[
                        const SizedBox(height: 6),
                        Text(
                          '${toArabicDigits(_result!.toStringAsFixed(2))} ريال',
                          style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.toolEmerald),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Text(
                'هذه حاسبة تقديرية للنقد والذهب/الفضة وعروض التجارة فقط، ولا تشمل زكاة الأنعام والزروع. للحالات الخاصة يُستحسن مراجعة أهل العلم.',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(fontSize: 11, color: AppTheme.subTextColor(isDark), height: 1.6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(bool isDark, String label, TextEditingController controller, {String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6, right: 4),
          child: Text(label, style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textColor(isDark))),
        ),
        TextField(
          controller: controller,
          textAlign: TextAlign.right,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: GoogleFonts.cairo(fontSize: 15, color: AppTheme.textColor(isDark)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.cairo(fontSize: 11, color: AppTheme.subTextColor(isDark)),
            filled: true,
            fillColor: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.04),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.gold.withValues(alpha: 0.25)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.gold.withValues(alpha: 0.25)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.gold, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
