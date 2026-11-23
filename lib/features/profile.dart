import 'package:flutter/material.dart';

import '../core/session.dart';
import '../core/ui.dart';
import '../data/design.dart';
import 'orders.dart';

class Profile extends StatelessWidget {
  const Profile(this.session, {super.key});
  final Session session;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          heading('Profile', size: 32),
          iconAction(Icons.search, 'Search food', session.openSearch),
        ],
      ),
      const SizedBox(height: 12),
      InkWell(
        onTap: () => session.open(Screen.editProfile),
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            ClipOval(child: art('avatar', width: 62, height: 62)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  heading(session.name, size: 16),
                  const SizedBox(height: 4),
                  label(session.email, color: muted, weight: FontWeight.w400),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 30),
      label('General', size: 18, color: muted),
      const SizedBox(height: 6),
      _row(
        Icons.person_outline,
        'Account Information',
        'Change your account information',
        onTap: () => session.open(Screen.editProfile),
      ),
      _row(
        Icons.credit_card_outlined,
        'Payment Methods',
        'Add your credit or debit card',
        onTap: () => session.open(Screen.paymentSettings),
      ),
      _row(
        Icons.location_on_outlined,
        'Delivery Location',
        'Change your delivery location',
        onTap: () => session.open(Screen.deliveryLocation),
      ),
      _row(
        Icons.person_add_alt_1_outlined,
        'Invite your friends',
        'Get \$10 each invitation!',
        onTap: () => info(
          context,
          'Invite your friends',
          'Demo invitation code LEZATOS10',
        ),
      ),
      const SizedBox(height: 22),
      label('Notifications', size: 18, color: muted),
      const SizedBox(height: 6),
      _row(
        Icons.notifications_none,
        'Notifications',
        'You will receive daily updates',
        onTap: () => session.open(Screen.notification),
        trailing: Switch(
          value: session.notifications,
          onChanged: (value) =>
              session.change(() => session.notifications = value),
        ),
      ),
      _row(
        Icons.local_offer_outlined,
        'Promotional Notifications',
        'Get notified when promotions',
        trailing: Switch(
          value: session.promotions,
          onChanged: (value) =>
              session.change(() => session.promotions = value),
        ),
      ),
      _row(
        Icons.notifications_active_outlined,
        'Notification history',
        'View new and previous notifications',
        onTap: () => session.open(Screen.notification),
      ),
      const SizedBox(height: 22),
      label('Appearance', size: 18, color: muted),
      const SizedBox(height: 6),
      _row(
        Icons.dashboard_outlined,
        'Home layout',
        'Choose from three Pixso home layouts',
        onTap: () => _layout(context, home: true),
      ),
      _row(
        Icons.view_agenda_outlined,
        'Food detail layout',
        'Choose from three food detail layouts',
        onTap: () => _layout(context, home: false),
      ),
      _row(
        Icons.grid_view_outlined,
        'Favourite layout',
        'Switch the favourites list and grid',
        onTap: () => _favouriteLayout(context),
      ),
      _row(
        Icons.logout,
        'Sign out',
        'Return to the sign-in screen',
        onTap: () => session.open(Screen.login, reset: true),
      ),
    ],
  );

  Widget _row(
    IconData icon,
    String title,
    String description, {
    VoidCallback? onTap,
    Widget? trailing,
  }) => Column(
    children: [
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: soft,
          child: Icon(icon, color: muted, size: 19),
        ),
        title: heading(title, size: 14),
        subtitle: label(
          description,
          size: 12,
          color: muted,
          weight: FontWeight.w400,
        ),
        trailing:
            trailing ??
            const Icon(Icons.chevron_right_rounded, color: muted, size: 18),
        onTap: onTap,
      ),
      const Divider(color: line, height: 10),
    ],
  );

  Future<void> _layout(BuildContext context, {required bool home}) async {
    final screens = [Screen.homeOne, Screen.homeTwo, Screen.homeThree];
    final chosen = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(home ? 'Home layout' : 'Food detail layout'),
        children: [
          for (var index = 0; index < 3; index++)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, index),
              child: Row(
                children: [
                  Icon(
                    (home
                            ? session.home == screens[index]
                            : session.detailLayout == index)
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                  ),
                  const SizedBox(width: 12),
                  Text('Variant 0${index + 1}'),
                ],
              ),
            ),
        ],
      ),
    );
    if (chosen == null || !context.mounted) return;
    session.change(() {
      if (home) {
        session.home = screens[chosen];
      } else {
        session.detailLayout = chosen;
      }
    });
    if (home) session.open(session.home, reset: true);
  }

  Future<void> _favouriteLayout(BuildContext context) async {
    final selected = await showDialog<Screen>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Favourite layout'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, Screen.favouriteList),
            child: const Text('List'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, Screen.favouriteGrid),
            child: const Text('Grid'),
          ),
        ],
      ),
    );
    if (selected == null || !context.mounted) return;
    session.favourites = selected;
    session.open(selected);
  }
}

class ProfileEditor extends StatefulWidget {
  const ProfileEditor(this.session, {super.key});
  final Session session;

  @override
  State<ProfileEditor> createState() => _ProfileEditorState();
}

class _ProfileEditorState extends State<ProfileEditor> {
  Session get session => widget.session;
  bool get delivery => session.screen == Screen.deliveryLocation;
  late final name = TextEditingController(
    text: delivery ? session.location : session.name,
  );
  late final email = TextEditingController(text: delivery ? '' : session.email);
  late final phone = TextEditingController(text: session.phone);
  late final password = TextEditingController(
    text: session.preview ? 'lezatos123' : '',
  );

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    phone.dispose();
    password.dispose();
    super.dispose();
  }

  void _save() {
    final title = name.text.trim();
    if (title.isEmpty || (!delivery && !email.text.contains('@'))) {
      notice(
        context,
        delivery
            ? 'Enter a delivery location'
            : 'Enter your name and a valid email address',
      );
      return;
    }
    if (delivery) {
      session.location = title;
      if (email.text.trim().isNotEmpty) session.address = email.text.trim();
    } else {
      session.name = title;
      session.email = email.text.trim();
      session.phone = phone.text.trim();
    }
    session.back();
    notice(context, 'Changes saved');
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const SizedBox(height: 3),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: panel(
          color: const Color(0xfffdf0ec),
          radius: 16,
          child: const SizedBox(height: 9, width: double.infinity),
        ),
      ),
      Expanded(
        child: Material(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
          child: Column(
            children: [
              toolbar(
                delivery ? 'Delivery Location' : 'Edit Profile',
                session.back,
                showBack: false,
                trailing: link('Cancel', session.back),
              ),
              Expanded(
                child: verticalBody([
                  const SizedBox(height: 16),
                  if (delivery)
                    InkWell(
                      onTap: () => session.open(Screen.location),
                      child: photo('address_map', height: 223),
                    )
                  else
                    Center(
                      child: SizedBox(
                        width: 88,
                        height: 88,
                        child: Stack(
                          children: [
                            ClipOval(
                              child: art('avatar', width: 88, height: 88),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: InkWell(
                                onTap: () => info(
                                  context,
                                  'Profile photo',
                                  'This demo uses the profile photograph from the design.',
                                ),
                                child: const CircleAvatar(
                                  radius: 16,
                                  backgroundColor: orange,
                                  child: Icon(
                                    Icons.camera_alt_outlined,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 26),
                  FormFieldPill(
                    controller: name,
                    hint: delivery ? 'Search location' : 'Username',
                    icon: delivery
                        ? Icons.location_on_outlined
                        : Icons.person_outline,
                  ),
                  const SizedBox(height: 16),
                  FormFieldPill(
                    controller: email,
                    hint: delivery ? 'Location name' : 'Email',
                    icon: delivery ? null : Icons.mail_outline,
                  ),
                  if (!delivery) ...[
                    const SizedBox(height: 16),
                    FormFieldPill(
                      controller: phone,
                      hint: 'Phone number',
                      icon: Icons.flag_outlined,
                      type: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    if (session.preview)
                      FormFieldPill(
                        controller: password,
                        hint: 'Password',
                        icon: Icons.lock_outline,
                        secret: true,
                      )
                    else
                      OutlinedButton.icon(
                        onPressed: () => session.open(Screen.newPassword),
                        icon: const Icon(
                          Icons.lock_outline,
                          color: muted,
                          size: 20,
                        ),
                        label: label('Change password', color: muted),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(54),
                          side: const BorderSide(color: line),
                        ),
                      ),
                  ],
                ]),
              ),
              footer(action('Save Changes', _save)),
            ],
          ),
        ),
      ),
    ],
  );
}

class PaymentSettings extends StatelessWidget {
  const PaymentSettings(this.session, {super.key});
  final Session session;

  @override
  Widget build(BuildContext context) {
    final list = session.paymentCards;
    final page = Column(
      children: [
        toolbar(
          'Payment',
          session.back,
          trailing: link('Add Card', () => session.open(Screen.addCard)),
        ),
        Expanded(
          child: verticalBody([
            const SizedBox(height: 22),
            heading('Active Card', size: 18),
            const SizedBox(height: 14),
            if (list.isEmpty)
              centerEmpty()
            else
              _bankCard(session.defaultCard, 0),
            const SizedBox(height: 28),
            heading('Payment Methods', size: 18),
            const SizedBox(height: 14),
            for (var i = 0; i < list.length; i++)
              if (i != session.defaultCard)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _bankCard(i, i == 0 ? 1 : 2),
                ),
          ]),
        ),
      ],
    );

    return switch (session.screen) {
      Screen.cardOptions => designSheet(
        body: page,
        title: 'Options',
        cancel: session.back,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: heading('Set as default', size: 15),
            onTap: () {
              session.defaultCard = session.activeCard;
              session.back();
            },
          ),
          const Divider(color: line),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.delete_outline, color: orange, size: 20),
            title: label('Delete Card', color: orange),
            onTap: () {
              final removed = session.activeCard;
              list.removeAt(removed);
              if (session.defaultCard > removed) session.defaultCard--;
              if (session.defaultCard >= list.length) session.defaultCard = 0;
              session.activeCard = 0;
              session.back();
            },
          ),
        ],
      ),
      Screen.addCard => designSheet(
        body: page,
        title: 'Add Card',
        cancel: session.back,
        children: [_AddCard(session)],
      ),
      _ => page,
    };
  }

  Widget centerEmpty() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 18),
    child: Center(
      child: label('Add a demo card to see it here.', color: muted),
    ),
  );

  Widget _bankCard(int index, int palette) {
    final card = session.paymentCards[index];
    final colors = [
      [const Color(0xfffd8750), const Color(0xffe9b91e)],
      [const Color(0xffe85678), const Color(0xff5758d0)],
      [const Color(0xff4387de), const Color(0xff00abd2)],
    ][palette];
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 181,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: -64,
              top: -130,
              child: CircleAvatar(
                radius: 130,
                backgroundColor: Colors.white.withValues(alpha: .08),
              ),
            ),
            Positioned(
              left: -42,
              top: -128,
              child: CircleAvatar(
                radius: 160,
                backgroundColor: Colors.white.withValues(alpha: .08),
              ),
            ),
            Positioned(
              left: 18,
              top: 22,
              child: label(session.name, size: 16, color: Colors.white),
            ),
            Positioned(
              top: 11,
              right: 2,
              child: iconAction(
                Icons.more_vert,
                'Card options',
                () {
                  session.activeCard = index;
                  session.open(Screen.cardOptions);
                },
                color: Colors.white,
                size: 20,
              ),
            ),
            Positioned(
              left: 18,
              top: 100,
              child: label(
                '•••• •••• •••• ${card.$2}',
                size: 22,
                color: Colors.white,
                weight: FontWeight.w700,
              ),
            ),
            Positioned(
              left: 18,
              bottom: 25,
              child: label('VALID THRU   03/24', color: Colors.white, size: 11),
            ),
            Positioned(
              right: 18,
              bottom: 20,
              child: panel(radius: 4, child: cardLogo(card.$1)),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddCard extends StatefulWidget {
  const _AddCard(this.session);
  final Session session;

  @override
  State<_AddCard> createState() => _AddCardState();
}

class _AddCardState extends State<_AddCard> {
  late final number = TextEditingController(
    text: widget.session.preview ? '0192 - 1245 - 0000 - 0000' : '',
  );
  late final expiry = TextEditingController(
    text: widget.session.preview ? '12/22' : '',
  );
  late final code = TextEditingController(
    text: widget.session.preview ? '234' : '',
  );
  bool isDefault = true;

  @override
  void dispose() {
    number.dispose();
    expiry.dispose();
    code.dispose();
    super.dispose();
  }

  void _save() {
    final digits = number.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 13 ||
        digits.length > 19 ||
        !RegExp(r'^(0[1-9]|1[0-2])/\d\d$').hasMatch(expiry.text) ||
        !RegExp(r'^\d{3,4}$').hasMatch(code.text)) {
      notice(
        context,
        'Enter a demo card number, MM/YY expiry, and 3–4 digit code',
      );
      return;
    }
    final session = widget.session;
    final brand = digits.startsWith('4')
        ? 'Visa'
        : digits.startsWith('3')
        ? 'American Express'
        : 'Master Card';
    session.paymentCards.add((brand, digits.substring(digits.length - 4)));
    if (isDefault) session.defaultCard = session.paymentCards.length - 1;
    session.back();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      label(
        'Enter sample card details for this demo.',
        color: muted,
        weight: FontWeight.w400,
        size: 16,
      ),
      const SizedBox(height: 20),
      FormFieldPill(
        controller: number,
        hint: 'Demo card number',
        icon: Icons.credit_card,
        type: TextInputType.number,
      ),
      const SizedBox(height: 14),
      Row(
        children: [
          Expanded(
            child: FormFieldPill(
              controller: expiry,
              hint: 'MM/YY',
              type: TextInputType.datetime,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FormFieldPill(
              controller: code,
              hint: 'Security code',
              type: TextInputType.number,
              action: TextInputAction.done,
              onSubmit: (_) => _save(),
            ),
          ),
        ],
      ),
      Row(
        children: [
          Switch(
            value: isDefault,
            onChanged: (value) => setState(() => isDefault = value),
          ),
          const SizedBox(width: 8),
          label('Set as default', color: muted),
        ],
      ),
      const SizedBox(height: 12),
      action('Save Card', _save),
    ],
  );
}
