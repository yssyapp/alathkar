import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../database/app_database.dart';

/// طبقة وصول موحّدة لإعدادات التطبيق (الوضع الليلي/النهاري، اللون الثانوي،
/// اللغة، ولاحقاً أي إعداد جديد) — تخزين مفتاح/قيمة في جدول `settings` من
/// قاعدة بيانات SQLite، بنفس نمط [FavoritesRepository] تماماً: مستقلة عن
/// الواجهة، ومع نقل تلقائي لمرة واحدة لأي قيم كانت محفوظة سابقاً بالطريقة
/// القديمة (shared_preferences) حتى لا يفقد المستخدمون الحاليون إعداداتهم.
class SettingsRepository {
  const SettingsRepository();

  static const String _migrationDoneKey = 'settingsMigratedToSqlite';

  /// أسماء المفاتيح القديمة في shared_preferences التي ننقلها مرة واحدة —
  /// نفس الأسماء بالضبط المستخدمة سابقاً في ThemeProvider و LanguageProvider.
  static const List<String> _legacyBoolKeys = ['isDarkMode'];
  static const List<String> _legacyIntKeys = ['accentIndex'];
  static const List<String> _legacyStringKeys = ['appLanguage'];

  Future<void> _ensureMigrated() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_migrationDoneKey) ?? false) return;

    final db = await AppDatabase.instance.database;
    final batch = db.batch();
    var hasAny = false;

    void queue(String key, Object? value) {
      if (value == null) return;
      hasAny = true;
      batch.insert(
        'settings',
        {'key': key, 'value': value.toString()},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    for (final key in _legacyBoolKeys) {
      queue(key, prefs.getBool(key));
    }
    for (final key in _legacyIntKeys) {
      queue(key, prefs.getInt(key));
    }
    for (final key in _legacyStringKeys) {
      queue(key, prefs.getString(key));
    }
    if (hasAny) {
      await batch.commit(noResult: true);
    }
    await prefs.setBool(_migrationDoneKey, true);
  }

  Future<String?> _getRaw(String key) async {
    await _ensureMigrated();
    final db = await AppDatabase.instance.database;
    final rows = await db.query('settings', columns: ['value'], where: 'key = ?', whereArgs: [key], limit: 1);
    if (rows.isEmpty) return null;
    return rows.first['value'] as String?;
  }

  Future<void> _setRaw(String key, String value) async {
    final db = await AppDatabase.instance.database;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool?> getBool(String key) async {
    final v = await _getRaw(key);
    if (v == null) return null;
    return v == 'true' || v == '1';
  }

  Future<void> setBool(String key, bool value) => _setRaw(key, value.toString());

  Future<int?> getInt(String key) async {
    final v = await _getRaw(key);
    if (v == null) return null;
    return int.tryParse(v);
  }

  Future<void> setInt(String key, int value) => _setRaw(key, value.toString());

  Future<String?> getString(String key) => _getRaw(key);

  Future<void> setString(String key, String value) => _setRaw(key, value);
}
