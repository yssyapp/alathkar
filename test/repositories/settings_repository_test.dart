import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:athkari/database/app_database.dart';
import 'package:athkari/repositories/settings_repository.dart';

/// اختبارات وحدة لطبقة تخزين الإعدادات (SQLite) — الوضع الليلي، اللون
/// الثانوي، اللغة، وأي إعداد مستقبلي. تتأكد من صحة الحفظ/القراءة بكل نوع،
/// ومن نجاح النقل التلقائي من shared_preferences القديمة.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  AppDatabase.useInMemoryForTests = true;

  const repository = SettingsRepository();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppDatabase.instance.resetForTest();
  });

  test('getBool يرجع null لو الإعداد غير محفوظ بعد', () async {
    expect(await repository.getBool('isDarkMode'), isNull);
  });

  test('setBool/getBool يحفظان ويرجعان نفس القيمة', () async {
    await repository.setBool('isDarkMode', false);
    expect(await repository.getBool('isDarkMode'), false);
    await repository.setBool('isDarkMode', true);
    expect(await repository.getBool('isDarkMode'), true);
  });

  test('setInt/getInt يحفظان ويرجعان نفس القيمة', () async {
    await repository.setInt('accentIndex', 3);
    expect(await repository.getInt('accentIndex'), 3);
  });

  test('setString/getString يحفظان ويرجعان نفس القيمة', () async {
    await repository.setString('appLanguage', 'en');
    expect(await repository.getString('appLanguage'), 'en');
  });

  test('تحديث قيمة موجودة يستبدلها لا يكررها', () async {
    await repository.setInt('accentIndex', 1);
    await repository.setInt('accentIndex', 5);
    expect(await repository.getInt('accentIndex'), 5);
  });

  test('ينقل الإعدادات القديمة من shared_preferences تلقائياً', () async {
    SharedPreferences.setMockInitialValues({
      'isDarkMode': false,
      'accentIndex': 2,
      'appLanguage': 'ur',
    });
    expect(await repository.getBool('isDarkMode'), false);
    expect(await repository.getInt('accentIndex'), 2);
    expect(await repository.getString('appLanguage'), 'ur');
  });
}
