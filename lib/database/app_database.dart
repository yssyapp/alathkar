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

  /// يُفعَّل فقط من ملفات الاختبار (test/) — يجعل كل ملف اختبار يفتح قاعدة
  /// بيانات مستقلة داخل الذاكرة بدل ملف مشترك على القرص. مهم جداً لأن
  /// `flutter test` يشغّل كل ملف اختبار في عملية/isolate منفصلة بالتوازي،
  /// فمشاركة نفس ملف athkari.db بينها تسبب أخطاء قفل/قراءة القرص
  /// (database is locked / disk I/O error) دون أي علاقة بصحة الكود نفسه.
  static bool useInMemoryForTests = false;

  Database? _db;

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final path = useInMemoryForTests
        ? inMemoryDatabasePath
        : p.join(await getDatabasesPath(), _dbName);
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

  /// يغلق الاتصال الحالي ويحذف ملف القاعدة بالكامل — يُستخدم فقط داخل
  /// الاختبارات الآلية (test/) لضمان بداية نظيفة قبل كل اختبار، بدون أي
  /// تأثير على سلوك التطبيق الفعلي (لا يُستدعى أبداً من كود الإنتاج).
  Future<void> resetForTest() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
    if (!useInMemoryForTests) {
      final dbPath = await getDatabasesPath();
      final path = p.join(dbPath, _dbName);
      await deleteDatabase(path);
    }
  }
}
