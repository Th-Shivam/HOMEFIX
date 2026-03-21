import 'package:flutter_test/flutter_test.dart';
import 'package:homefix_pro/app.dart';

void main() {
  testWidgets('App launches and reaches onboarding flow',
      (WidgetTester tester) async {
    await tester.pumpWidget(const HomefixProApp());

    expect(find.text('HomeFix Pro'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Expert Home Services'), findsOneWidget);
  });
}
