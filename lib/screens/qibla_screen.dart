import 'dart:math' show pi;

import 'package:flutter/material.dart';
import '../core/app_strings.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geolocator/geolocator.dart' show LocationPermission;
import 'package:google_fonts/google_fonts.dart';

import '../core/theme.dart';

/// شاشة اتجاه القبلة: تعرض بوصلة تفاعلية تحدد اتجاه الكعبة المشرّفة بالاعتماد
/// على موقع المستخدم (GPS) وحساس البوصلة بالجهاز. ملاحظة مهمة: لا تعمل على
/// محاكي iOS (Simulator) لعدم وجود حساس بوصلة افتراضي — تحتاج جهاز حقيقي.
class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

enum _QiblaState { loading, noCompass, permissionDenied, permissionDeniedForever, ready }

class _QiblaScreenState extends State<QiblaScreen> {
  _QiblaState _state = _QiblaState.loading;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final hasCompass = await FlutterQiblah.androidDeviceSensorSupport() ?? true;
      if (!hasCompass) {
        if (mounted) setState(() => _state = _QiblaState.noCompass);
        return;
      }

      var status = await FlutterQiblah.checkLocationStatus();
      if (!status.enabled || status.status == LocationPermission.denied) {
        // requestPermissions() تُرجع LocationPermission فقط (تُشغّل نافذة
        // النظام)، فنعيد جلب الحالة الكاملة (LocationStatus) بعدها.
        await FlutterQiblah.requestPermissions();
        status = await FlutterQiblah.checkLocationStatus();
      }

      if (status.status == LocationPermission.deniedForever) {
        if (mounted) setState(() => _state = _QiblaState.permissionDeniedForever);
        return;
      }
      if (status.status == LocationPermission.denied || !status.enabled) {
        if (mounted) setState(() => _state = _QiblaState.permissionDenied);
        return;
      }
      if (mounted) setState(() => _state = _QiblaState.ready);
    } catch (_) {
      if (mounted) setState(() => _state = _QiblaState.noCompass);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('qibla_title'), style: GoogleFonts.cairo(fontWeight: FontWeight.w700))),
      body: SafeArea(child: _buildBody(isDark)),
    );
  }

  Widget _buildBody(bool isDark) {
    switch (_state) {
      case _QiblaState.loading:
        return const Center(child: CircularProgressIndicator());
      case _QiblaState.noCompass:
        return _buildMessage(
          isDark,
          icon: Icons.explore_off_outlined,
          title: context.tr('qibla_no_compass_title'),
          body:
              'هذا الجهاز ما فيه حساس بوصلة، أو إنك تجرّب على محاكي (Simulator) — بوصلة القبلة تحتاج جهاز حقيقي فيه حساس بوصلة فعلي.',
        );
      case _QiblaState.permissionDenied:
        return _buildMessage(
          isDark,
          icon: Icons.location_off_outlined,
          title: context.tr('qibla_location_required_title'),
          body: 'نحتاج صلاحية الوصول لموقعك لحساب اتجاه القبلة بدقة.',
          actionLabel: 'إعادة المحاولة',
        );
      case _QiblaState.permissionDeniedForever:
        return _buildMessage(
          isDark,
          icon: Icons.settings_outlined,
          title: 'صلاحية الموقع مرفوضة',
          body: 'تم رفض صلاحية الموقع بشكل دائم. فعّلها يدوياً من إعدادات الجهاز > الخصوصية > خدمات الموقع > الأذكار.',
        );
      case _QiblaState.ready:
        return _buildCompass(isDark);
    }
  }

  Widget _buildMessage(bool isDark, {required IconData icon, required String title, required String body, String? actionLabel}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppTheme.subTextColor(isDark)),
            const SizedBox(height: 16),
            Text(title, style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textColor(isDark)), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(body, style: GoogleFonts.cairo(fontSize: 13, color: AppTheme.subTextColor(isDark), height: 1.7), textAlign: TextAlign.center),
            if (actionLabel != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _init();
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.gold, foregroundColor: Colors.black),
                child: Text(actionLabel, style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompass(bool isDark) {
    return StreamBuilder<QiblahDirection>(
      stream: FlutterQiblah.qiblahStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final direction = snapshot.data!;
        final aligned = direction.offset.abs() < 5;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              aligned ? context.tr('qibla_aligned') : context.tr('qibla_align_hint'),
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: aligned ? AppTheme.toolEmerald : AppTheme.subTextColor(isDark),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 280,
              height: 280,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // قرص البوصلة الدوّار (يدور عكس اتجاه الجهاز حتى تبقى جهة
                  // الشمال صحيحة دائماً بالنسبة للواقع)
                  Transform.rotate(
                    angle: (direction.direction * (pi / 180) * -1),
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.cardGradient(isDark),
                        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.4), width: 2),
                        boxShadow: AppTheme.softGlow(AppTheme.gold, opacity: 0.25, blur: 24),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Text('ش', style: GoogleFonts.cairo(color: AppTheme.gold, fontWeight: FontWeight.w900, fontSize: 16)),
                      ),
                    ),
                  ),
                  // مؤشر اتجاه القبلة (يدور نحو الكعبة)
                  Transform.rotate(
                    angle: (direction.qiblah * (pi / 180) * -1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.mosque_rounded, color: aligned ? AppTheme.toolEmerald : AppTheme.gold, size: 34),
                        const SizedBox(height: 210),
                      ],
                    ),
                  ),
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.gold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              '${toArabicDigits(direction.offset.abs().toStringAsFixed(0))}° عن اتجاه القبلة',
              style: GoogleFonts.cairo(fontSize: 13, color: AppTheme.subTextColor(isDark)),
            ),
          ],
        );
      },
    );
  }
}
