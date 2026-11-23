import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'core/session.dart';
import 'core/ui.dart';
import 'data/design.dart';
import 'features/auth.dart';
import 'features/discovery.dart';
import 'features/food_details.dart';
import 'features/location.dart';
import 'features/orders.dart';
import 'features/profile.dart';

class LezatosApp extends StatefulWidget {
  const LezatosApp({
    super.key,
    this.initialScreen = Screen.splash,
    this.preview = false,
  });

  final Screen initialScreen;
  final bool preview;

  @override
  State<LezatosApp> createState() => _LezatosAppState();
}

class _LezatosAppState extends State<LezatosApp> {
  late final session = Session(widget.initialScreen, preview: widget.preview);

  @override
  void dispose() {
    session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Lezatos',
    theme: ThemeData(
      useMaterial3: true,
      fontFamily: 'Urbanist',
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.fromSeed(
        seedColor: orange,
        primary: orange,
        surface: Colors.white,
      ),
      dividerColor: line,
      inputDecorationTheme: const InputDecorationTheme(isDense: true),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? orange : line,
        ),
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
    ),
    home: ListenableBuilder(
      listenable: session,
      builder: (context, _) => _Page(session),
    ),
  );
}

class _Page extends StatelessWidget {
  const _Page(this.session);
  final Session session;

  Screen get screen => session.screen;

  bool get home =>
      screen == Screen.homeOne ||
      screen == Screen.homeTwo ||
      screen == Screen.homeThree;
  bool get favourites =>
      screen == Screen.favouriteList || screen == Screen.favouriteGrid;
  bool get showNav =>
      home || favourites || screen == Screen.promos || screen == Screen.profile;
  bool get photoHeader =>
      screen == Screen.foodThree || screen == Screen.foodExpanded;
  bool get topOrange =>
      screen == Screen.onboardingOne ||
      screen == Screen.homeThree ||
      screen == Screen.editProfile ||
      screen == Screen.deliveryLocation;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final keyboard = media.viewInsets.bottom > 0;
    final top = math.max(media.padding.top, 44.0);
    final bottom = keyboard ? 0.0 : math.max(media.padding.bottom, 21.0);
    return PopScope(
      canPop: !session.canBack && screen != Screen.tracking,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (session.canBack) {
          session.back();
        } else if (screen == Screen.tracking) {
          session.open(session.home, reset: true);
        }
      },
      child: systemStyle(
        Scaffold(
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: SizedBox.expand(
                child: Stack(
                  children: [
                    if (screen == Screen.homeOne)
                      const Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 255,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xffffe7ca), Colors.white],
                            ),
                          ),
                        ),
                      ),
                    if (topOrange)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: switch (screen) {
                          Screen.homeThree => 192,
                          Screen.onboardingOne => top + 2,
                          _ => top + 38,
                        },
                        child: const DecoratedBox(
                          decoration: BoxDecoration(gradient: flame),
                        ),
                      ),
                    if (home && screen != Screen.homeTwo)
                      Positioned(
                        left: 0,
                        right: 0,
                        top: -72,
                        height: 164,
                        child: Opacity(
                          opacity: screen == Screen.homeThree ? .32 : .7,
                          child: art('pattern', fit: BoxFit.cover),
                        ),
                      ),
                    if (photoHeader)
                      Align(
                        alignment: Alignment.topCenter,
                        child: FractionallySizedBox(
                          widthFactor: 1,
                          heightFactor: .768,
                          child: DecoratedBox(
                            position: DecorationPosition.foreground,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.black54, Colors.transparent],
                                stops: [0, .28],
                              ),
                            ),
                            child: art(session.food.image),
                          ),
                        ),
                      ),
                    if (screen == Screen.tracking)
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        height: top + 2,
                        child: art(
                          'tracking_map',
                          alignment: Alignment.topCenter,
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.only(top: top, bottom: bottom),
                      child: Column(
                        children: [
                          Expanded(
                            child: KeyedSubtree(
                              key: ValueKey(screen),
                              child: _body(),
                            ),
                          ),
                          if (showNav && !keyboard) _navigation(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        light: topOrange || photoHeader,
      ),
    );
  }

  Widget _body() => switch (screen) {
    Screen.splash ||
    Screen.onboardingOne ||
    Screen.onboardingTwo ||
    Screen.onboardingThree ||
    Screen.login ||
    Screen.loginActive ||
    Screen.signUp ||
    Screen.signUpActive ||
    Screen.verifyEmail ||
    Screen.forgot ||
    Screen.resetEmail ||
    Screen.resetPhone ||
    Screen.verifyPhone ||
    Screen.newPassword ||
    Screen.passwordChanged => AuthFlow(session),
    Screen.homeOne ||
    Screen.homeTwo ||
    Screen.homeThree ||
    Screen.favouriteList ||
    Screen.favouriteGrid ||
    Screen.promos ||
    Screen.notification ||
    Screen.search ||
    Screen.searchEmpty => Discovery(session),
    Screen.foodOne ||
    Screen.foodTwo ||
    Screen.foodThree ||
    Screen.foodExpanded => FoodDetails(session),
    Screen.location || Screen.locationTyping => LocationPicker(session),
    Screen.cart ||
    Screen.payment ||
    Screen.voucher ||
    Screen.selectPayment ||
    Screen.tracking => Orders(session),
    Screen.profile => Profile(session),
    Screen.editProfile || Screen.deliveryLocation => ProfileEditor(session),
    Screen.paymentSettings ||
    Screen.cardOptions ||
    Screen.addCard => PaymentSettings(session),
  };

  Widget _navigation() => ColoredBox(
    color: Colors.white,
    child: SizedBox(
      height: 59,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _tab(
            home ? Icons.home_rounded : Icons.home_outlined,
            'Home',
            session.home,
            home,
          ),
          _tab(
            favourites ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            'Favourite',
            session.favourites,
            favourites,
          ),
          Badge(
            isLabelVisible: session.count > 0,
            label: Text('${session.count}'),
            backgroundColor: orange,
            alignment: const AlignmentDirectional(.86, -.94),
            child: iconAction(
              Icons.shopping_bag_outlined,
              'Cart',
              () => session.open(Screen.cart),
              color: Colors.white,
              background: ink,
            ),
          ),
          _tab(
            screen == Screen.promos
                ? Icons.discount_rounded
                : Icons.discount_outlined,
            'Promos',
            Screen.promos,
            screen == Screen.promos,
          ),
          _tab(
            screen == Screen.profile
                ? Icons.person_rounded
                : Icons.person_outline_rounded,
            'Profile',
            Screen.profile,
            screen == Screen.profile,
          ),
        ],
      ),
    ),
  );

  Widget _tab(IconData icon, String label, Screen destination, bool active) =>
      iconAction(
        icon,
        label,
        () => session.open(destination, reset: true),
        color: active ? orange : muted,
      );
}
