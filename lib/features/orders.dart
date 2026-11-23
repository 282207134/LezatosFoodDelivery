import 'package:flutter/material.dart';

import '../core/session.dart';
import '../core/ui.dart';
import '../data/catalog.dart';
import '../data/design.dart';

class Orders extends StatelessWidget {
  const Orders(this.session, {super.key});
  final Session session;

  @override
  Widget build(BuildContext context) => switch (session.screen) {
    Screen.cart => _cart(context),
    Screen.tracking => _tracking(context),
    _ => _checkout(context),
  };

  Widget _cart(BuildContext context) => Column(
    children: [
      toolbar('Cart', session.back),
      Expanded(
        child: verticalBody([
          const SizedBox(height: 21),
          Center(
            child: label(
              'Total',
              size: 16,
              color: muted,
              weight: FontWeight.w400,
            ),
          ),
          Center(child: heading(money(session.subtotal), size: 36)),
          const SizedBox(height: 36),
          if (session.cart.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 66),
              child: Column(
                children: [
                  const Icon(
                    Icons.shopping_bag_outlined,
                    size: 64,
                    color: muted,
                  ),
                  const SizedBox(height: 14),
                  heading('Your cart is empty', size: 20),
                ],
              ),
            ),
          for (final entry in session.cart.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: InkWell(
                onTap: () => _editQuantity(context, entry.key),
                borderRadius: BorderRadius.circular(14),
                child: panel(
                  color: soft,
                  radius: 14,
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      ClipOval(
                        child: art(entry.key.image, width: 60, height: 60),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            label(
                              entry.key.name,
                              weight: FontWeight.w700,
                              maxLines: 2,
                            ),
                            const SizedBox(height: 5),
                            label('x${entry.value}', size: 12, color: muted),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      heading(money(entry.key.price * entry.value), size: 14),
                    ],
                  ),
                ),
              ),
            ),
        ]),
      ),
      footer(
        action(
          'Checkout',
          session.cart.isEmpty ? null : () => session.open(Screen.payment),
        ),
        secondary: link(
          'Add more items',
          () => session.open(session.home, reset: true),
        ),
      ),
    ],
  );

  void _editQuantity(BuildContext context, Food item) =>
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (context) => SafeArea(
          child: ListenableBuilder(
            listenable: session,
            builder: (context, _) {
              final count = session.cart[item] ?? 0;
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    heading(item.name, size: 18, align: TextAlign.center),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        iconAction(Icons.remove, 'Decrease cart quantity', () {
                          session.updateCart(item, count - 1);
                          if (count == 1) Navigator.pop(context);
                        }),
                        heading('$count'),
                        iconAction(
                          Icons.add,
                          'Increase cart quantity',
                          () => session.updateCart(item, count + 1),
                        ),
                      ],
                    ),
                    link('Remove item', () {
                      session.updateCart(item, 0);
                      Navigator.pop(context);
                    }),
                  ],
                ),
              );
            },
          ),
        ),
      );

  Widget _checkout(BuildContext context) {
    final card = session.paymentCards.isEmpty
        ? null
        : session.paymentCards[session.defaultCard];
    final page = Column(
      children: [
        toolbar('Payment', session.back),
        Expanded(
          child: verticalBody([
            const SizedBox(height: 20),
            heading('Address', size: 18),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => session.open(Screen.location),
              child: Row(
                children: [
                  photo('address_map', width: 120, height: 80, radius: 12),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        label('Home', size: 16, weight: FontWeight.w700),
                        const SizedBox(height: 6),
                        label(
                          session.address,
                          color: muted,
                          weight: FontWeight.w400,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            heading('Payment Method', size: 18),
            const SizedBox(height: 16),
            _cardRow(
              card?.$1 ?? 'Add a payment method',
              card?.$2 ?? '',
              onTap: () => session.open(Screen.selectPayment),
              trailing: const Icon(Icons.chevron_right_rounded, color: muted),
            ),
            const SizedBox(height: 26),
            heading('Voucher', size: 18),
            const SizedBox(height: 5),
            InkWell(
              onTap: () => session.open(Screen.voucher),
              child: Row(
                children: [
                  const Icon(Icons.discount_outlined, color: orange),
                  const SizedBox(width: 10),
                  Expanded(
                    child: label(
                      session.voucherPercent == 0
                          ? 'Add Voucher or Promo Code'
                          : '${session.voucherPercent}% voucher applied',
                      weight: FontWeight.w400,
                    ),
                  ),
                  iconAction(
                    Icons.add,
                    'Choose voucher',
                    () => session.open(Screen.voucher),
                    color: orange,
                    background: const Color(0xffffede4),
                    size: 20,
                  ),
                ],
              ),
            ),
            const Divider(height: 28, color: line),
            _amount('Shipping cost', session.shipping),
            const SizedBox(height: 13),
            _amount('Sub total', session.subtotal),
            if (session.voucherPercent > 0) ...[
              const SizedBox(height: 13),
              _amount('Voucher', -session.discount),
            ],
            const Divider(height: 28, color: line),
            _amount('Total', session.total, strong: true),
          ]),
        ),
        footer(
          action(
            'Pay ${money(session.total)}',
            session.cart.isEmpty || session.paymentCards.isEmpty
                ? null
                : session.placeOrder,
          ),
        ),
      ],
    );
    if (session.screen == Screen.voucher) {
      return designSheet(
        body: page,
        title: 'Select Voucher',
        cancel: session.back,
        children: [
          for (final discount in const [20, 10])
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: panel(
                border: line,
                radius: 12,
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0xfffff0e2),
                      child: Icon(
                        Icons.confirmation_number_outlined,
                        color: Color(0xffffb950),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          heading('Get $discount% off for 1 week!', size: 14),
                          const SizedBox(height: 4),
                          label(
                            'Valid for this demo order',
                            size: 12,
                            color: muted,
                            weight: FontWeight.w400,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 45,
                      height: 30,
                      child: FilledButton(
                        onPressed: () {
                          session.voucherPercent = discount;
                          session.back();
                        },
                        style: FilledButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: const Text(
                          'Use',
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (session.voucherPercent > 0)
            link('Remove voucher', () {
              session.voucherPercent = 0;
              session.back();
            }),
        ],
      );
    }
    if (session.screen == Screen.selectPayment) {
      return designSheet(
        body: page,
        title: 'Select Payment',
        cancel: session.back,
        children: [
          for (var index = 0; index < session.paymentCards.length; index++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _cardRow(
                session.paymentCards[index].$1,
                session.paymentCards[index].$2,
                onTap: () {
                  session.defaultCard = index;
                  session.back();
                },
                trailing: Icon(
                  index == session.defaultCard
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: index == session.defaultCard
                      ? const Color(0xff157ace)
                      : muted,
                ),
              ),
            ),
          Center(
            child: link('⊕  Add Card', () => session.open(Screen.addCard)),
          ),
        ],
      );
    }
    return page;
  }

  Widget _amount(String title, int cents, {bool strong = false}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      label(
        title,
        color: strong ? ink : muted,
        size: 16,
        weight: strong ? FontWeight.w700 : FontWeight.w400,
      ),
      label(
        cents < 0 ? '-${money(-cents)}' : money(cents),
        size: 16,
        weight: strong ? FontWeight.w700 : FontWeight.w600,
      ),
    ],
  );

  Widget _cardRow(
    String card,
    String digits, {
    required VoidCallback onTap,
    required Widget trailing,
  }) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: panel(
      border: line,
      radius: 14,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          cardLogo(card),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                heading(card, size: 14),
                if (digits.isNotEmpty)
                  label(
                    '••••  ••••  ••••  $digits',
                    size: 12,
                    color: muted,
                    weight: FontWeight.w400,
                  ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    ),
  );

  Widget _tracking(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: constraints.maxHeight * .65,
          child: art('tracking_map'),
        ),
        Positioned(
          left: constraints.maxWidth * .22,
          top: 12,
          width: constraints.maxWidth * .74,
          height: constraints.maxHeight * .52,
          child: art('tracking_path', fit: BoxFit.fill),
        ),
        Positioned(
          top: 4,
          left: 14,
          child: iconAction(
            Icons.arrow_back_ios_new_rounded,
            'Back',
            () => session.canBack
                ? session.back()
                : session.open(session.home, reset: true),
            background: Colors.white,
            size: 18,
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            heightFactor: .49,
            widthFactor: 1,
            child: panel(
              radius: 24,
              child: Column(
                children: [
                  Expanded(
                    child: verticalBody([
                      const SizedBox(height: 18),
                      _trackingRow(
                        'Restaurant',
                        restaurant,
                        Icons.restaurant_menu_rounded,
                        orange,
                      ),
                      const SizedBox(height: 12),
                      _trackingRow(
                        'Delivery',
                        '10 minutes',
                        Icons.schedule_rounded,
                        const Color(0xff5369ec),
                      ),
                      const SizedBox(height: 12),
                      _trackingRow(
                        'Your Delivery Address',
                        session.address,
                        Icons.location_on_rounded,
                        const Color(0xffffb950),
                      ),
                      const SizedBox(height: 12),
                    ]),
                  ),
                  panel(
                    color: ink,
                    radius: 24,
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        ClipOval(child: art('courier', width: 60, height: 60)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              label(
                                'Yoel Hartono',
                                size: 16,
                                color: Colors.white,
                                weight: FontWeight.w700,
                              ),
                              const SizedBox(height: 4),
                              label(
                                'Courier  ·  ⭐  4.6',
                                size: 12,
                                color: muted,
                              ),
                            ],
                          ),
                        ),
                        iconAction(
                          Icons.call_outlined,
                          'Call courier',
                          () => info(
                            context,
                            'Yoel Hartono',
                            'Courier contact is available in the demo order preview.',
                          ),
                          color: Colors.white,
                          background: orange,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _trackingRow(
    String caption,
    String value,
    IconData icon,
    Color color,
  ) => Row(
    children: [
      CircleAvatar(
        radius: 19,
        backgroundColor: color.withValues(alpha: .11),
        child: Icon(icon, color: color, size: 20),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            label(caption, size: 13, color: muted, weight: FontWeight.w400),
            const SizedBox(height: 3),
            heading(value, size: 16),
          ],
        ),
      ),
    ],
  );
}

Widget cardLogo(String card) {
  if (card == 'Master Card') {
    return const SizedBox(
      width: 47,
      height: 30,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 6,
            child: CircleAvatar(radius: 10, backgroundColor: Color(0xffed2427)),
          ),
          Positioned(
            right: 6,
            child: CircleAvatar(radius: 10, backgroundColor: Color(0xeaffab00)),
          ),
        ],
      ),
    );
  }
  return panel(
    color: const Color(0xfff0f5fc),
    radius: 5,
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
    child: label(
      card == 'Visa'
          ? 'VISA'
          : card == 'American Express'
          ? 'AMEX'
          : 'CARD',
      size: 12,
      color: const Color(0xff144d9e),
      weight: FontWeight.w700,
    ),
  );
}

Widget designSheet({
  required Widget body,
  required String title,
  required VoidCallback cancel,
  required List<Widget> children,
}) => Stack(
  children: [
    Positioned.fill(
      child: ExcludeSemantics(child: IgnorePointer(child: body)),
    ),
    Positioned.fill(
      child: GestureDetector(
        onTap: cancel,
        child: const ColoredBox(color: Color(0x421e2739)),
      ),
    ),
    Align(
      alignment: Alignment.bottomCenter,
      child: LayoutBuilder(
        builder: (context, constraints) => ConstrainedBox(
          constraints: BoxConstraints(maxHeight: constraints.maxHeight * .92),
          child: SizedBox(
            width: double.infinity,
            child: Material(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(26),
              ),
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                children: [
                  Center(
                    child: panel(
                      color: line,
                      radius: 4,
                      child: const SizedBox(width: 62, height: 4),
                    ),
                  ),
                  SizedBox(
                    height: 55,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        heading(title, size: 18),
                        Positioned(right: 0, child: link('Cancel', cancel)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...children,
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  ],
);
