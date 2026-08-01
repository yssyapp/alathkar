import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../database/app_database.dart';

/// طبقة وصول بيانات المفضلة — تخزين حقيقي في SQLite بدل قائمة نصوص داخل
/// shared_preferences. مستقلة تماماً عن الواجهة (FavoritesProvider لا يعرف
/// كيف تُخزَّن البيانات، فقط يستدعي هذه الطبقة).
///
/// عند أول استخدام تنقل تلقائياً أي مفضلة محفوظة سابقاً بالطريقة القديمة
/// (shared_preferences) إلى الجدول الجديد، حتى لا يفقد المستخدمون الحاليون
/// مفضلاتهم بعد هذا التحديث.
class FavoritesRepository {
  const FavoritesRepository();

  static const String _legacyPrefKey = 'favoriteDhikrIds';
  static const String _migrationDoneKey = 'favoritesMigratedToSqlite';

  Future<Set<String>> loadAll() async {
    await _migrateFromSharedPreferencesIfNeeded();
    final db = await AppDatabase.instance.database;
    final rows = await db.query('favorites', columns: ['dhikr_id']);
    return rows.map((r) => r['dhikr_id'] as String).toSet();
  }

  Future<void> add(String dhikrId) async {
    final db = await AppDatabase.instance.database;
    await db.insert(
      'favorites',
      {'dhikr_id': dhikrId, 'added_at': DateTime.now().millisecondsSinceEpoch},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> remove(String dhikrId) async {
    final db = await AppDatabase.instance.database;
    await db.delete('favorites', where: 'dhikr_id = ?', whereArgs: [dhikrId]);
  }

  /// ينقل بيانات shared_preferences القديمة مرة واحدة فقط (عبر علامة في
  /// shared_preferences نفسها لتفادي تكرار النقل عند كل تشغيل).
  Future<void> _migrateFromSharedPreferencesIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_migrationDoneKey) ?? false) return;

    final legacyIds = prefs.getStringList(_legacyPrefKey) ?? const <String>[];
    if (legacyIds.isNotEmpty) {
      final db = await AppDatabase.instance.database;
      final batch = db.batch();
      final now = DateTime.now().millisecondsSinceEpoch;
      for (final id in legacyIds) {
        batch.insert(
          'favorites',
          {'dhikr_id': id, 'added_at': now},
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
      await batch.commit(noResult: true);
    }
    await prefs.setBool(_migrationDoneKey, true);
  }
}
