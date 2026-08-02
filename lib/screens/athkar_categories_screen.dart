import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/app_strings.dart';
import '../core/theme.dart';
import '../data/athkar_data.dart';
import '../models/dhikr_model.dart';
import '../providers/language_provider.dart';
import 'azkar_swipe_screen.dart';
import 'favorites_screen.dart';
import 'settings_screen.dart';

/// شاشة "أذكار المسلم" — شبكة من بطاقتين بكل صف تعرض جميع فئات الأذكار
/// بترتيب ثابت مطابق للتصميم المرجعي، بخلفية خضراء داكنة وكتابة ذهبية في
/// كل مكان، وكل فئة تُفتح بنفس تجربة "السحب لأعلى/أسفل" الموحّدة
/// (AzkarSwipeScreen) بلا استثناء.
class AthkarCategoriesScreen extends StatelessWidget {
  const AthkarCategoriesScreen({super.key});

  /// ترتيب الفئات في الشبكة تماماً كالتصميم المرجعي: صفوف من بطاقتين،
  /// أول عنصر يظهر أعلى اليمين وثانيه أعلى اليسار (لأن اتجاه الواجهة
  /// العربية RTL)، وهكذا صفاً بعد صف.
  static const List<DhikrCategory> _gridOrder = [
    DhikrCategory.evening,
    DhikrCategory.morning,
    DhikrCategory.mosque,
    DhikrCategory.adhan,
    DhikrCategory.wakeup,
    DhikrCategory.sleep,
    DhikrCategory.afterPrayer,
    DhikrCategory.prayer,
    DhikrCategory.home,
    DhikrCategory.wudu,
    DhikrCategory.toilet,
    DhikrCategory.food,
    DhikrCategory.misc,
    DhikrCategory.travel,
  ];

  void _openCategory(BuildContext context, DhikrCategory category) {
    HapticFeedback.selectionClick();
    Navigator.push(context, _fadeScaleRoute(AzkarSwipeScreen(category: category)));
  }

  static Route _fadeScaleRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, animation, _, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(scale: Tween(begin: 0.96, end: 1.0).animate(curved), child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().language;
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.darkBackground, Color(0xFF0F2318)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(context),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // نحسب حجم كل بطاقة ديناميكياً بحيث تملأ كل الفئات
                      // الشاشة كاملة في صفحة واحدة بدون أي سحب رأسي، مهما
                      // كان حجم الشاشة (7 صفوف × عمودين لكل الفئات الحالية).
                      const crossAxisCount = 2;
                      const spacing = 10.0;
                      final rows = (_gridOrder.length / crossAxisCount).ceil();
                      final cardWidth = (constraints.maxWidth - spacing * (crossAxisCount - 1)) / crossAxisCount;
                      final cardHeight = (constraints.maxHeight - spacing * (rows - 1)) / rows;
                      final aspectRatio = cardWidth / cardHeight;
                      return GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _gridOrder.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: spacing,
                          crossAxisSpacing: spacing,
                          childAspectRatio: aspectRatio,
                        ),
                        itemBuilder: (context, index) {
                          final category = _gridOrder[index];
                          return _CategoryTile(
                            category: category,
                            lang: lang,
                            onTap: () => _openCategory(context, category),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    // إذا فُتحت هذه الشاشة عبر Navigator.push (من الصفحة الرئيسية) نعرض زر
    // رجوع إلى جانب زر "+"، حتى لا يبقى المستخدم عالقاً بدون طريقة للعودة
    // لصفحة "آية وحديث اليوم" الرئيسية.
    final canPop = Navigator.canPop(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Row(
        children: [
          if (canPop) ...[
            _RoundIconButton(
              icon: Icons.arrow_forward_ios_rounded,
              iconSize: 16,
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.pop(context);
              },
            ),
            const SizedBox(width: 8),
          ],
          _RoundIconButton(
            icon: Icons.add_rounded,
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.push(context, _fadeScaleRoute(const FavoritesScreen()));
            },
          ),
          Expanded(
            child: Text(
              context.tr('athkarCatTitle'),
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(fontSize: 21, fontWeight: FontWeight.w800, color: AppTheme.gold),
            ),
          ),
          _RoundIconButton(
            icon: Icons.settings_rounded,
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.push(context, _fadeScaleRoute(const SettingsScreen()));
            },
          ),
        ],
      ),
    );
  }
}

/// زر دائري صغير بحدود ذهبية فوق خلفية شفافة، يُستخدم لزري "المفضلة"
/// (أيقونة +) و"الإعدادات" أعلى الشاشة.
class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double iconSize;
  const _RoundIconButton({required this.icon, required this.onTap, this.iconSize = 22});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.gold.withValues(alpha: 0.6), width: 1.4),
          ),
          child: Icon(icon, color: AppTheme.gold, size: iconSize),
        ),
      ),
    );
  }
}

/// بطاقة فئة واحدة في الشبكة — خلفية خضراء داكنة، حدود وكتابة ذهبية،
/// وحركة ضغط بسيطة، بنفس أسلوب بقية التطبيق.
class _CategoryTile extends StatefulWidget {
  final DhikrCategory category;
  final AppLanguage lang;
  final VoidCallback onTap;
  const _CategoryTile({required this.category, required this.lang, required this.onTap});

  @override
  State<_CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<_CategoryTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final hasContent = AthkarData.getByCategory(widget.category).isNotEmpty;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: hasContent ? widget.onTap : null,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: const Color(0xFF12291A),
            border: Border.all(color: AppTheme.gold.withValues(alpha: 0.35), width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: hasContent ? widget.onTap : null,
              splashColor: AppTheme.gold.withValues(alpha: 0.15),
              highlightColor: Colors.transparent,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    widget.category.nameFor(widget.lang),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.gold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
