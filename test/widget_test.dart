// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:cafe/main.dart';
import 'package:cafe/models/coffee_shop.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Intro page smoke test', (WidgetTester tester) async {
    // Build app with a fake coffee shop to avoid hitting the network.
    await tester.pumpWidget(MyApp(coffeeShop: _FakeCoffeeShop()));

    // Verify that our intro page is shown.
    expect(find.text('JAVA CAFÉ'), findsOneWidget);
    expect(find.text('Brewed perfection. Crafted for you.'), findsOneWidget);
  });
}

class _FakeCoffeeShop extends CoffeeShop {
  _FakeCoffeeShop();

  @override
  Future<void> load({bool forceRefresh = false}) async {
    // No-op to keep tests offline.
  }
}
