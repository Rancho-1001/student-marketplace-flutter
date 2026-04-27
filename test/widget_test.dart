import 'package:flutter_test/flutter_test.dart';
import 'package:student_marketplace/src/app.dart';

void main() {
  testWidgets('shows marketplace onboarding', (tester) async {
    await tester.pumpWidget(const StudentMarketplaceApp());

    expect(find.text('Student Marketplace'), findsOneWidget);
    expect(find.text('Display name'), findsOneWidget);
    expect(find.text('Campus'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });
}
