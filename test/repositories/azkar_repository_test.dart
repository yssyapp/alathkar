import 'package:flutter_test/flutter_test.dart';

import 'package:athkari/models/dhikr_model.dart';
import 'package:athkari/repositories/azkar_repository.dart';

/// اختبارات وحدة لطبقة الوصول لبيانات الأذكار — لا تحتاج قاعدة بيانات
/// (تُغلّف فقط AthkarData الثابتة)، لذا تعمل بسرعة بدون أي تهيئة.
void main() {
  const repository = AzkarRepository();

  test('byCategory يرجع أذكار الصباح فقط لهذه الفئة', () {
    final morning = repository.byCategory(DhikrCategory.morning);
    expect(morning, isNotEmpty);
    expect(morning.every((d) => d.category == DhikrCategory.morning), isTrue);
  });

  test('كل فئة من DhikrCategory ترجع قائمة غير فارغة', () {
    for (final category in DhikrCategory.values) {
      final list = repository.byCategory(category);
      expect(list, isNotEmpty, reason: 'الفئة ${category.name} فاضية!');
    }
  });

  test('all تجمع أذكار كل الفئات', () {
    final all = repository.all;
    final morningCount = repository.byCategory(DhikrCategory.morning).length;
    expect(all.length, greaterThanOrEqualTo(morningCount));
    expect(all.any((d) => d.category == DhikrCategory.evening), isTrue);
    expect(all.any((d) => d.category == DhikrCategory.nawawi40), isTrue);
  });

  test('search بنص فارغ أو مسافات فقط يرجع قائمة فارغة', () {
    expect(repository.search(''), isEmpty);
    expect(repository.search('   '), isEmpty);
  });

  test('search يجد ذكراً بجزء من نصه العربي', () {
    final results = repository.search('سبحان الله');
    expect(results, isNotEmpty);
  });

  test('search لا يتحسس لحالة الأحرف بالترجمة الإنجليزية', () {
    final lower = repository.search('allah');
    final upper = repository.search('ALLAH');
    expect(lower.length, upper.length);
    expect(lower, isNotEmpty);
  });

  test('search لنص غير موجود إطلاقاً يرجع قائمة فارغة', () {
    final results = repository.search('xyzxyzxyz123لا_يوجد_شيء_كذا');
    expect(results, isEmpty);
  });

  test('rotatingContent يرجع ذكراً واحداً صالحاً دائماً', () {
    final dhikr = repository.rotatingContent(DateTime(2026, 1, 1, 8));
    expect(dhikr.text, isNotEmpty);
  });
}
