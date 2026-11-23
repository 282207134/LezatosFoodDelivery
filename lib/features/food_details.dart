import 'package:flutter/material.dart';

import '../core/session.dart';
import '../core/ui.dart';
import '../data/catalog.dart';
import '../data/design.dart';
import 'discovery.dart';

class FoodDetails extends StatelessWidget {
  const FoodDetails(this.session, {super.key});
  final Session session;

  Food get food => session.food;

  @override
  Widget build(BuildContext context) => switch (session.screen) {
    Screen.foodOne => _sidePlate(context),
    Screen.foodTwo => _centerPlate(context),
    _ => _heroSheet(context),
  };

  Widget _toolbar({bool white = false}) => toolbar(
    '',
    session.back,
    color: white ? Colors.white : ink,
    trailing: heart(session, food, inactive: white ? Colors.white : ink),
  );

  Widget _title({bool centered = false, bool stats = true}) => Column(
    crossAxisAlignment: centered
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start,
    children: [
      heading(food.name, size: 24, align: centered ? TextAlign.center : null),
      const SizedBox(height: 8),
      label('By ${food.restaurant}', color: muted, weight: FontWeight.w400),
      if (stats) ...[const SizedBox(height: 16), _stats()],
    ],
  );

  Widget _stats({bool vertical = false}) {
    final values = [
      _stat(Icons.star_rounded, '4.9', const Color(0xffffb950)),
      _stat(Icons.delivery_dining_rounded, '20 min', const Color(0xff315b79)),
    ];
    return vertical
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [values[0], const SizedBox(height: 12), values[1]],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [values[0], const SizedBox(width: 12), values[1]],
          );
  }

  Widget _stat(IconData icon, String text, Color color) => panel(
    radius: 22,
    border: line,
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 17),
        const SizedBox(width: 7),
        label(text, size: 13),
      ],
    ),
  );

  Widget _description(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      heading('Description', size: 18),
      const SizedBox(height: 10),
      label(
        'Freshly prepared by ${food.restaurant} and served with the house accompaniments. Select a quantity to add this dish to your order.',
        color: muted,
        weight: FontWeight.w400,
        size: 14,
      ),
    ],
  );

  Widget _sidePlate(BuildContext context) => Column(
    children: [
      _toolbar(),
      Expanded(
        child: ListView(
          padding: const EdgeInsets.only(top: 24),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 26, 0),
              child: _title(stats: false),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 314,
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  Positioned(
                    right: -74,
                    top: 0,
                    child: ClipOval(
                      child: art(food.image, width: 318, height: 318),
                    ),
                  ),
                  Positioned(left: 20, top: 25, child: _stats(vertical: true)),
                  Positioned(
                    left: 20,
                    bottom: 10,
                    child: _quantity(vertical: true),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(padding: gutter, child: _description(context)),
            const SizedBox(height: 18),
          ],
        ),
      ),
      Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: flame,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 13, 20, 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            label(
              '${session.quantity} ${session.quantity == 1 ? 'Item' : 'Items'}',
              color: Colors.white,
              size: 16,
            ),
            label(
              money(food.price * session.quantity),
              size: 30,
              color: Colors.white,
              weight: FontWeight.w700,
            ),
            _cartButton(() => _add(context, openCart: true), 'Add to Cart'),
          ],
        ),
      ),
    ],
  );

  Widget _centerPlate(BuildContext context) => Column(
    children: [
      _toolbar(),
      Expanded(
        child: verticalBody([
          const SizedBox(height: 14),
          _title(centered: true),
          const SizedBox(height: 22),
          photo(food.image, height: 220),
          const SizedBox(height: 18),
          _priceRow(),
          const SizedBox(height: 18),
          _description(context),
          const SizedBox(height: 16),
        ]),
      ),
      _addFooter(context),
    ],
  );

  Widget _heroSheet(BuildContext context) {
    final expanded = session.screen == Screen.foodExpanded;
    return Stack(
      children: [
        _toolbar(white: true),
        Align(
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            heightFactor: expanded ? .675 : .27,
            widthFactor: 1,
            child: panel(
              radius: 26,
              child: Column(
                children: [
                  GestureDetector(
                    onVerticalDragEnd: (details) {
                      final direction = details.primaryVelocity ?? 0;
                      if (!expanded && direction < 0) {
                        session.open(Screen.foodExpanded);
                      }
                      if (expanded && direction > 0) session.back();
                    },
                    child: Semantics(
                      button: true,
                      label: expanded ? 'Collapse details' : 'Expand details',
                      child: InkWell(
                        onTap: expanded
                            ? session.back
                            : () => session.open(Screen.foodExpanded),
                        borderRadius: BorderRadius.circular(24),
                        child: SizedBox(
                          height: 36,
                          child: Center(
                            child: panel(
                              color: line,
                              radius: 4,
                              child: const SizedBox(width: 60, height: 4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: verticalBody([
                      _title(centered: true),
                      if (expanded) ...[
                        const SizedBox(height: 20),
                        _priceRow(),
                        const SizedBox(height: 18),
                        _description(context),
                      ],
                    ]),
                  ),
                  if (expanded) _addFooter(context),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _priceRow() => Row(
    children: [
      _quantity(),
      const SizedBox(width: 8),
      Spacer(),
      heading(money(food.price * session.quantity), size: 24),
    ],
  );

  Widget _quantity({bool vertical = false}) {
    final less = iconAction(
      Icons.remove,
      'Decrease quantity',
      () => session.setQuantity(session.quantity - 1),
      color: Colors.white,
      size: 20,
    );
    final more = iconAction(
      Icons.add,
      'Increase quantity',
      () => session.setQuantity(session.quantity + 1),
      color: Colors.white,
      background: const Color(0xff2d303e),
      size: 20,
    );
    final amount = label(
      '${session.quantity}',
      color: vertical ? Colors.white : ink,
      size: 16,
    );
    return vertical
        ? panel(
            color: ink,
            radius: 32,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Column(
              children: [
                more,
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: amount,
                ),
                if (session.quantity > 1) less,
              ],
            ),
          )
        : Row(
            children: [
              panel(
                color: ink,
                radius: 32,
                padding: const EdgeInsets.all(3),
                child: Row(children: [less, more]),
              ),
              const SizedBox(width: 12),
              CircleAvatar(radius: 20, backgroundColor: soft, child: amount),
            ],
          );
  }

  Widget _cartButton(VoidCallback tap, String tooltip) => iconAction(
    Icons.shopping_bag_outlined,
    tooltip,
    tap,
    color: Colors.white,
    background: ink,
  );

  void _add(BuildContext context, {bool openCart = false}) {
    session.addFood();
    if (openCart) {
      session.open(Screen.cart);
    } else {
      notice(context, 'Added ${food.name} to cart');
    }
  }

  Widget _addFooter(BuildContext context) => footer(
    Row(
      children: [
        Expanded(child: action('Add to Cart', () => _add(context))),
        const SizedBox(width: 12),
        _cartButton(() => session.open(Screen.cart), 'View cart'),
      ],
    ),
  );
}
