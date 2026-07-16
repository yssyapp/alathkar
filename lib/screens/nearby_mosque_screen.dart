import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme.dart';

/// شاشة "أقرب مسجد": تحدد موقع المستخدم الحالي (GPS) ثم تفتح تطبيق الخرائط
/// المثبّت على الجهاز (خرائط آبل على iOS، أو خرائط قوقل على أندرويد) مع بحث
/// جاهز عن "مسجد" حول موقعه — بلا حاجة لمفتاح API أو اشتراك أو عرض خريطة
/// داخل التطبيق نفسه، فقط تفويض المهمة لتطبيق الخرائط الأدق والأحدث بيانات.
class NearbyMosqueScreen extends StatefulWidget {
  const NearbyMosqueScreen({super.key});

  @override
  State<NearbyMosqueScreen> createState() => _NearbyMosqueScreenState();
}

enum _MosqueState { loading, serviceDisabled, permissionDenied, permissionDeniedForever, ready, error }

class _NearbyMosqueScreenState extends State<NearbyMosqueScreen> {
  _MosqueState _state = _MosqueState.loading;
  Position? _position;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() => _state = _MosqueState.loading);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) setState(() => _state = _MosqueState.serviceDisabled);
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) setState(() => _state = _MosqueState.permissionDeniedForever);
        return;
      }
      if (permission == LocationPermission.denied) {
        if (mounted) setState(() => _state = _MosqueState.permissionDenied);
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _position = position;
        _state = _MosqueState.ready;
      });
    } catch (_) {
      if (mounted) setState(() => _state = _MosqueState.error);
    }
  }

  Future<void> _openMaps() async {
    final position = _position;
    if (position == null) return;
    final lat = position.latitude;
    final lng = position.longitude;
    final query = Uri.encodeComponent('مسجد');

    final Uri primaryUri = Platform.isIOS
        ? Uri.parse('https://maps.apple.com/?q=$query&sll=$lat,$lng&z=15')
        : Uri.parse('geo:$lat,$lng?q=$query');

    var launched = false;
    try {
      launched = await launchUrl(primaryUri, mode: LaunchMode.externalApplication);
    } catch (_) {
      launched = false;
    }

    if (!launched) {
      final fallbackUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query+near+$lat,$lng');
      try {
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
      } catch (_) {
        // لا شيء إضافي نفعله هنا؛ المستخدم سيرى أن شيئاً لم يحدث ويمكنه المحاولة يدوياً.
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: Text('أقرب مسجد', style: GoogleFonts.cairo(fontWeight: FontWeight.w700))),
      body: SafeArea(child: _buildBody(isDark)),
    );
  }

  Widget _buildBody(bool isDark) {
    switch (_state) {
      case _MosqueState.loading:
        return const Center(child: CircularProgressIndicator());
      case _MosqueState.serviceDisabled:
        return _buildMessage(
          isDark,
          icon: Icons.location_disabled_outlined,
          title: 'خدمة الموقع غير مفعّلة',
          body: 'فعّل خدمة تحديد الموقع (GPS) من إعدادات جهازك ثم أعد المحاولة.',
          actionLabel: 'إعادة المحاولة',
        );
      case _MosqueState.permissionDenied:
        return _buildMessage(
          isDark,
          icon: Icons.location_off_outlined,
          title: 'صلاحية الموقع مطلوبة',
          body: 'نحتاج صلاحية الوصول لموقعك حتى نفتح لك تطبيق الخرائط مع البحث عن أقرب مسجد.',
          actionLabel: 'إعادة المحاولة',
        );
      case _MosqueState.permissionDeniedForever:
        return _buildMessage(
          isDark,
          icon: Icons.settings_outlined,
          title: 'صلاحية الموقع مرفوضة',
          body: 'تم رفض صلاحية الموقع بشكل دائم. فعّلها يدوياً من إعدادات الجهاز > الخصوصية > خدمات الموقع > الأذكار.',
        );
      case _MosqueState.error:
        return _buildMessage(
          isDark,
          icon: Icons.error_outline_rounded,
          title: 'تعذّر تحديد موقعك',
          body: 'حدث خطأ غير متوقع أثناء محاولة تحديد موقعك، حاول مرة أخرى.',
          actionLabel: 'إعادة المحاولة',
        );
      case _MosqueState.ready:
        return _buildReady(isDark);
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
                onPressed: _init,
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.gold, foregroundColor: Colors.black),
                child: Text(actionLabel, style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReady(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.cardGradient(isDark),
                border: Border.all(color: AppTheme.gold.withValues(alpha: 0.4), width: 2),
                boxShadow: AppTheme.softGlow(AppTheme.gold, opacity: 0.25, blur: 24),
              ),
              child: Icon(Icons.mosque_rounded, color: AppTheme.gold, size: 44),
            ),
            const SizedBox(height: 20),
            Text(
              'تم تحديد موقعك',
              style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textColor(isDark)),
            ),
            const SizedBox(height: 8),
            Text(
              'اضغط الزر لفتح تطبيق الخرائط والبحث عن أقرب مسجد إليك.',
              style: GoogleFonts.cairo(fontSize: 13, color: AppTheme.subTextColor(isDark), height: 1.7),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _openMaps,
              icon: const Icon(Icons.map_outlined),
              label: Text('فتح الخرائط والبحث عن مسجد', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.gold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
