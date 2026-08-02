import 'package:flutter_test/flutter_test.dart';

import 'package:athkari/models/dhikr_model.dart';
import 'package:athkari/providers/language_provider.dart';

/// اختبارات وحدة لمنطق DhikrModel: استخراج الراوي وتخريج الحديث، ورجوع
/// النص/المصدر التلقائي للعربية عند غياب الترجمة.
void main() {
  test('narrator يستخرج اسم الراوي من مصدر يبدأ بـ"عن"', () {
    const dhikr = DhikrModel(
      title: 't',
      text: 'x',
      source: 'عن أبي هريرة رضي الله عنه — رواه مسلم',
      bookSource: 'b',
      category: DhikrCategory.nawawi40,
    );
    expect(dhikr.narrator, 'عن أبي هريرة رضي الله عنه');
  });

  test('narrator يرجع null لمصدر لا يبدأ بـ"عن" (كآية قرآنية)', () {
    const dhikr = DhikrModel(
      title: 't',
      text: 'x',
      source: 'سورة البقرة: الآية 255',
      bookSource: 'b',
      category: DhikrCategory.quran,
    );
    expect(dhikr.narrator, isNull);
  });

  test('narrator يرجع null لمصدر بدون فاصل "—"', () {
    const dhikr = DhikrModel(
      title: 't',
      text: 'x',
      source: 'عن أبي هريرة رضي الله عنه',
      bookSource: 'b',
      category: DhikrCategory.nawawi40,
    );
    expect(dhikr.narrator, isNull);
  });

  test('attributionFor يحذف اسم الراوي المكرر من نص المصدر العربي', () {
    const dhikr = DhikrModel(
      title: 't',
      text: 'x',
      source: 'عن أبي هريرة رضي الله عنه — رواه البخاري ومسلم',
      bookSource: 'b',
      category: DhikrCategory.nawawi40,
    );
    expect(dhikr.attributionFor(AppLanguage.ar), 'رواه البخاري ومسلم');
  });

  test('attributionFor يرجع المصدر كاملاً لو لا يوجد راوي مستخرَج', () {
    const dhikr = DhikrModel(
      title: 't',
      text: 'x',
      source: 'سورة البقرة: الآية 255',
      bookSource: 'b',
      category: DhikrCategory.quran,
    );
    expect(dhikr.attributionFor(AppLanguage.ar), 'سورة البقرة: الآية 255');
  });

  test('textFor يرجع النص العربي عند غياب الترجمة', () {
    const dhikr = DhikrModel(
      title: 't',
      text: 'النص العربي',
      source: 's',
      bookSource: 'b',
      category: DhikrCategory.morning,
    );
    expect(dhikr.textFor(AppLanguage.en), 'النص العربي');
  });

  test('textFor يرجع الترجمة الفعلية عند توفرها', () {
    const dhikr = DhikrModel(
      title: 't',
      text: 'النص العربي',
      textEn: 'English text',
      source: 's',
      bookSource: 'b',
      category: DhikrCategory.morning,
    );
    expect(dhikr.textFor(AppLanguage.en), 'English text');
  });

  test('meaningFor يرجع null عند غياب المعنى بدون رجوع للعربي', () {
    const dhikr = DhikrModel(
      title: 't',
      text: 'x',
      source: 's',
      bookSource: 'b',
      category: DhikrCategory.quran,
      meaning: 'المعنى بالعربي',
    );
    expect(dhikr.meaningFor(AppLanguage.en), isNull);
  });

  test('id يتكوّن من اسم الفئة والعنوان', () {
    const dhikr = DhikrModel(
      title: 'عنوان الاختبار',
      text: 'x',
      source: 's',
      bookSource: 'b',
      category: DhikrCategory.morning,
    );
    expect(dhikr.id, 'morning__عنوان الاختبار');
  });
}
