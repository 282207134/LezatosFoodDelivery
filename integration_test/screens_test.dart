import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lezatos_food_delivery/app.dart';
import 'package:lezatos_food_delivery/data/design.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));

  Future<void> open(
    WidgetTester tester,
    Screen screen, {
    bool preview = false,
  }) async {
    await tester.pumpWidget(
      LezatosApp(key: UniqueKey(), initialScreen: screen, preview: preview),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(ValueKey(screen)), findsOneWidget);
  }

  Future<void> tap(WidgetTester tester, Finder target) async {
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  testWidgets('sign in, find a dish, apply a voucher and place an order', (
    tester,
  ) async {
    await open(tester, Screen.login);
    await tester.enterText(find.byType(TextField).at(0), 'demo@lezatos.app');
    await tester.enterText(find.byType(TextField).at(1), 'demo123');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey(Screen.homeOne)), findsOneWidget);
    await tap(tester, find.text('What would you like to eat?'));
    final search = find.byType(TextField);
    await tester.enterText(search, 'pecel');
    await tester.pumpAndSettle();
    expect(find.text('No result for “pecel”'), findsOneWidget);
    await tester.enterText(search, 'grilled beef');
    await tester.pumpAndSettle();
    await tap(tester, find.text('Grilled Beef Steak with Sauce ABC'));
    await tap(tester, find.byTooltip('Increase quantity'));
    await tap(tester, find.byTooltip('Add to Cart'));
    expect(find.text('\$19.34'), findsNWidgets(2));

    await tap(tester, find.text('Checkout'));
    await tap(tester, find.byTooltip('Choose voucher'));
    await tap(tester, find.text('Use').first);
    expect(find.text('20% voucher applied'), findsOneWidget);
    await tap(tester, find.text('Pay \$16.48'));
    expect(find.text('Yoel Hartono'), findsOneWidget);
    await tap(tester, find.byTooltip('Back'));
    expect(find.byKey(const ValueKey(Screen.homeOne)), findsOneWidget);
  });

  testWidgets('all Pixso boards render on Android', (tester) async {
    await binding.convertFlutterSurfaceToImage();
    for (final screen in Screen.values) {
      await open(tester, screen, preview: true);
      await tester.pump(const Duration(milliseconds: 330));
      expect(tester.takeException(), isNull, reason: screen.title);
      await binding.takeScreenshot(screen.slug);
    }
  });
}
