// Widget smoke test for Flutter MVVM app.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_hackathon/app/app.dart';

void main() {
  testWidgets('App launches without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    // Just verify the app renders without throwing
    expect(find.byType(MyApp), findsOneWidget);
  });
}
