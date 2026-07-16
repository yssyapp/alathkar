import 'package:flutter_test/flutter_test.dart';

import 'package:athkari/main.dart';

void main() {
  testWidgets('App loads home screen with title', (WidgetTester tester) async {
    await tester.pumpWidget(const AthkariApp());
    await tester.pumpAndSettle();

    // ملاحظة: كانت هذه الاختبار تبحث عن نص "أذكاري" وهو نص قديم لم يعد
    // موجوداً منذ إعادة تصميم الشاشة الرئيسية إلى لوحة معلومات (Dashboard).
    // "أدواتك اليوم" عنوان القسم الرئيسي في الشاشة الحالية ويظهر مرة واحدة
    // فقط، فهو مؤشر موثوق على أن الشاشة الرئيسية بُنيت بنجاح.
    expect(find.text('أدواتك اليوم'), findsOneWidget);
  });
}
