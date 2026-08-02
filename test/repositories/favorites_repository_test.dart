import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:athkari/database/app_database.dart';
import 'package:athkari/repositories/favorites_repository.dart';

/// اختبارات وحدة لطبقة تخزين المفضلة (SQLite) — تتأكد من أن الإضافة
/// والحذف والقراءة تعمل صح، وأن نقل بيانات shared_preferences القديمة
/// (لو موجودة من نسخة سابقة للتطبيق) يحصل تلقائياً بشكل صحيح.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  AppDatabase.useInMemoryForTests = true;

  const repository = FavoritesRepository();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppDatabase.instance.resetForTest();
  });

  test('يبدأ بدون أي مفضلة', () async {
    final favorites = await repository.loadAll();
    expect(favorites, isEmpty);
  });

  test('إضافة ذكر للمفضلة يظهر في loadAll', () async {
    await repository.add('morning__test1');
    final favorites = await repository.loadAll();
    expect(favorites, contains('morning__test1'));
  });

  test('حذف ذكر من المفضلة يزيله من loadAll', () async {
    await repository.add('morning__test1');
    await repository.remove('morning__test1');
    final favorites = await repository.loadAll();
    expect(favorites, isEmpty);
  });

  test('إضافة نفس الذكر مرتين لا تكرره', () async {
    await repository.add('morning__test1');
    await repository.add('morning__test1');
    final favorites = await repository.loadAll();
    expect(favorites.length, 1);
  });

  test('إضافة عدة أذكار مختلفة تحفظها كلها', () async {
    await repository.add('morning__a');
    await repository.add('evening__b');
    await repository.add('quran__c');
    final favorites = await repository.loadAll();
    expect(favorites, containsAll(['morning__a', 'evening__b', 'quran__c']));
    expect(favorites.length, 3);
  });

  test('ينقل المفضلة القديمة من shared_preferences تلقائياً مرة واحدة', () async {
    SharedPreferences.setMockInitialValues({
      'favoriteDhikrIds': ['morning__legacy1', 'evening__legacy2'],
    });
    final favorites = await repository.loadAll();
    expect(favorites, containsAll(['morning__legacy1', 'evening__legacy2']));
  });

  test('حذف ذكر غير موجود أصلاً لا يسبب أي خطأ', () async {
    await repository.remove('غير_موجود');
    final favorites = await repository.loadAll();
    expect(favorites, isEmpty);
  });
}
