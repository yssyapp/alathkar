import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// نسخ احتياطي/استعادة محلي بالكامل: يصدّر كل بيانات المستخدم (المفضلة،
/// الإحصائيات، العادات، تقدّم الختمة، اللغة، الثيم...) كملف JSON واحد
/// يقدر يشاركه لنفسه (AirDrop، البريد، تطبيق الملفات، واتساب...) وينقله
/// لجهاز ثاني. لا يحتاج حساباً ولا خادماً خاصاً بنا — الملف يبقى بالكامل
/// بحوزة المستخدم، ولا تُرسل أي بيانات لأي خادم تابع للتطبيق (لأنه لا يوجد
/// خادم خلفي أصلاً؛ هذا اتصال اختياري فقط عبر قنوات المشاركة القياسية
/// بالجهاز، وقد يعمل حتى بدون إنترنت لو كانت الوجهة محلية مثل AirDrop
/// أو حفظ الملف في تطبيق الملفات).
class BackupService {
  static const int _formatVersion = 1;

  /// يجمع كل مفاتيح SharedPreferences الحالية (بغض النظر عن أي مزوّد
  /// أضافها) في نسخة احتياطية واحدة — بهذا الشكل النسخة الاحتياطية تبقى
  /// شاملة تلقائياً حتى لو أُضيفت ميزات/مزوّدات جديدة للتطبيق مستقبلاً.
  static Future<Map<String, dynamic>> _collectAll() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> data = {};
    for (final key in prefs.getKeys()) {
      data[key] = prefs.get(key);
    }
    return {
      'app': 'athkari',
      'formatVersion': _formatVersion,
      'prefs': data,
    };
  }

  /// يصدّر النسخة الاحتياطية كملف ويفتح نافذة المشاركة القياسية بالجهاز.
  static Future<void> exportAndShare() async {
    final backup = await _collectAll();
    final jsonStr = const JsonEncoder.withIndent('  ').convert(backup);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/athkari_backup.json');
    await file.writeAsString(jsonStr, encoding: utf8);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/json')],
        text: 'نسخة احتياطية من تطبيق الأذكار',
      ),
    );
  }

  /// يفتح منتقي الملفات، يقرأ ملف JSON اختاره المستخدم، ويستعيد كل القيم
  /// إلى SharedPreferences. يرجع true لو نجحت الاستعادة، و false لو ألغى
  /// المستخدم الاختيار أو كان الملف غير صالح (بدون رمي استثناء يكسر الواجهة).
  static Future<bool> pickAndRestore() async {
    // منذ file_picker 11.0.0 صارت الدوال static مباشرة على الكلاس
    // (FilePicker.pickFiles) بدل FilePicker.platform.pickFiles القديمة.
    // ونتجنب withData/bytes (تُحمّل الملف كاملاً بالذاكرة وأصبحتا مهملتين)
    // لصالح readAsBytes() التي تقرأ من القرص مباشرة وأأمن للملفات الكبيرة.
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.isEmpty) return false;

    final pickedPath = result.files.single.path;
    if (pickedPath == null) return false;
    final fileData = await File(pickedPath).readAsBytes();

    try {
      final decoded = jsonDecode(utf8.decode(fileData)) as Map<String, dynamic>;
      if (decoded['app'] != 'athkari') return false;
      final restoredPrefs = decoded['prefs'] as Map<String, dynamic>?;
      if (restoredPrefs == null) return false;

      final prefs = await SharedPreferences.getInstance();
      for (final entry in restoredPrefs.entries) {
        final value = entry.value;
        if (value is bool) {
          await prefs.setBool(entry.key, value);
        } else if (value is int) {
          await prefs.setInt(entry.key, value);
        } else if (value is double) {
          await prefs.setDouble(entry.key, value);
        } else if (value is String) {
          await prefs.setString(entry.key, value);
        } else if (value is List) {
          await prefs.setStringList(entry.key, value.map((e) => e.toString()).toList());
        }
        // أي نوع غير معروف يُتجاهل بأمان بدل ما يوقف الاستعادة كاملة.
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}
