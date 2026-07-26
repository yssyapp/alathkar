import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// يدير إعدادات الميزات الاختيارية اللي تحتاج إنترنت (مواقيت صلاة أدق حالياً،
/// وقابلة للتوسّع لاحقاً). كل شيء هنا معطّل افتراضياً (false) — التطبيق يبقى
/// يعمل ١٠٠٪ بدون إنترنت طالما المستخدم ما فعّلها بنفسه من الإعدادات، ولا
/// يوجد أي إعلانات أو اشتراك مدفوع مرتبط بأي ميزة هنا.
class OnlineFeaturesProvider extends ChangeNotifier {
  static const String _prefOnlinePrayerTimesKey = 'onlinePrayerTimesEnabled';
  static const String _prefLatKey = 'onlineFeaturesLat';
  static const String _prefLngKey = 'onlineFeaturesLng';

  bool _onlinePrayerTimesEnabled = false;
  double? _latitude;
  double? _longitude;

  bool get onlinePrayerTimesEnabled => _onlinePrayerTimesEnabled;
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  bool get hasLocation => _latitude != null && _longitude != null;

  OnlineFeaturesProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _onlinePrayerTimesEnabled = prefs.getBool(_prefOnlinePrayerTimesKey) ?? false;
    _latitude = prefs.getDouble(_prefLatKey);
    _longitude = prefs.getDouble(_prefLngKey);
    notifyListeners();
  }

  Future<void> setOnlinePrayerTimesEnabled(bool value) async {
    _onlinePrayerTimesEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefOnlinePrayerTimesKey, value);
  }

  Future<void> setLocation(double lat, double lng) async {
    _latitude = lat;
    _longitude = lng;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_prefLatKey, lat);
    await prefs.setDouble(_prefLngKey, lng);
  }
}
