// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:cafe/models/coffee_shop.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:cafe/main.dart';

void main() {
  testWidgets('Intro page smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => CoffeeShop(),
        child: const MyApp(),
      ),
    );

    // Verify that our intro page is shown.
    expect(find.text('JAVA CAFE'), findsOneWidget);
    expect(find.text('THE BEST COFFEE IN TOWN'), findsOneWidget);
  });
}
