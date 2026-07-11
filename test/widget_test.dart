import 'package:flutter_test/flutter_test.dart';

import 'package:athkari/main.dart';

void main() {
  testWidgets('App loads home screen with title', (WidgetTester tester) async {
    await tester.pumpWidget(const AthkariApp());
    await tester.pumpAndSettle();

    expect(find.text('أذكاري'), findsOneWidget);
  });
}
