import 'package:flutter_test/flutter_test.dart';
import 'package:student_marketplace/src/models/listing.dart';
import 'package:student_marketplace/src/app.dart';
import 'package:student_marketplace/src/services/auth_service.dart';

void main() {
  testWidgets('shows marketplace onboarding', (tester) async {
    await tester.pumpWidget(
      StudentMarketplaceApp(
        authService: PrototypeAuthService(),
        store: MarketplaceStore.seeded(),
      ),
    );

    expect(find.text('Student Marketplace'), findsOneWidget);
    expect(find.text('Create your account'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Campus'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
  });
}
