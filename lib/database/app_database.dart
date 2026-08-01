import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// نقطة وصول واحدة لقاعدة بيانات SQLite الخاصة بالتطبيق (Singleton) — يفتحها
/// أول من يطلبها ويعيد استخدام نفس الاتصال بعدها. الهدف فصل تخزين
/// المفضلة (ولاحقاً الإعدادات وآخر موضع قراءة) عن shared_preferences،
/// بشكل علائقي قابل للاستعلام والتوسّع، مع إبقاء طبقة الوصول للبيانات
/// (lib/repositories) مستقلة تماماً عن الواجهة.
class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  static const _dbName = 'athkari.db';
  static const _dbVersion = 1;

  Database? _db;

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE favorites (
            dhikr_id TEXT PRIMARY KEY,
            added_at INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE settings (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
        ''');
      },
    );
  }
}
