import 'package:flutter_test/flutter_test.dart';
import 'package:lezatos_food_delivery/core/session.dart';
import 'package:lezatos_food_delivery/data/catalog.dart';
import 'package:lezatos_food_delivery/data/design.dart';

void main() {
  test(
    'cart quantity, integer-cent discounts and checkout stay consistent',
    () {
      final session = Session(Screen.homeOne);
      addTearDown(session.dispose);

      session.selectFood(steak);
      session.setQuantity(2);
      session.addFood();
      session.voucherPercent = 20;

      expect(session.subtotal, 1934);
      expect(session.discount, 386);
      expect(session.total, 1648);

      session.open(Screen.payment);
      session.placeOrder();
      expect(session.screen, Screen.tracking);
      expect(session.orders, [1648]);
      expect(session.cart, isEmpty);
      expect(session.total, 0);
    },
  );
}
