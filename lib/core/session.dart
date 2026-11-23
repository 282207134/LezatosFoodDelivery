import 'package:flutter/foundation.dart';

import '../data/catalog.dart';
import '../data/design.dart';

class Session extends ChangeNotifier {
  Session(Screen initial, {this.preview = false}) : screen = initial {
    if (!preview) return;
    cart.addAll({steak: 1, salad: 1, chicken: 1});
    saved.addAll(menu);
    if (initial == Screen.foodTwo) food = padThai;
    if (initial == Screen.foodThree || initial == Screen.foodExpanded) {
      food = slicedSteak;
    }
  }

  final bool preview;
  Screen screen;
  Screen home = Screen.homeOne;
  Screen favourites = Screen.favouriteList;
  int detailLayout = 0;
  final _history = <Screen>[];
  final cart = <Food, int>{};
  final saved = <Food>{...menu};
  final paymentCards = [...cards];
  final orders = <int>[];
  Food food = steak;
  int quantity = 1;
  int defaultCard = 1;
  int activeCard = 0;
  int voucherPercent = 0;
  String name = 'Beby Azalea';
  String email = 'bebyjovanca@gmail.com';
  String phone = '+6282332877994';
  String location = 'Bancangan, Sambit';
  String address = 'Jl. Ponorogo-Trenggalek, Sambit, Ponorogo';
  bool notifications = true;
  bool promotions = false;
  bool signingUp = false;
  String searchCategory = 'All';

  bool get canBack => _history.isNotEmpty;
  int get count => cart.values.fold(0, (total, value) => total + value);
  int get subtotal =>
      cart.entries.fold(0, (sum, item) => sum + item.key.price * item.value);
  int get shipping => cart.isEmpty ? 0 : 100;
  int get discount => subtotal * voucherPercent ~/ 100;
  int get total => subtotal + shipping - discount;

  void open(Screen next, {bool replace = false, bool reset = false}) {
    if (screen == next) return;
    if (reset) {
      _history.clear();
    } else if (!replace) {
      _history.add(screen);
    }
    screen = next;
    notifyListeners();
  }

  void back() {
    if (!canBack) return;
    screen = _history.removeLast();
    notifyListeners();
  }

  void change(VoidCallback update) {
    update();
    notifyListeners();
  }

  void selectFood(Food item) {
    food = item;
    quantity = 1;
    open([Screen.foodOne, Screen.foodTwo, Screen.foodThree][detailLayout]);
  }

  void openSearch([String category = 'All']) {
    searchCategory = category;
    open(Screen.search);
  }

  void toggleSaved(Food item) => change(() {
    if (!saved.remove(item)) saved.add(item);
  });

  void setQuantity(int value) => change(() => quantity = value.clamp(1, 99));

  void updateCart(Food item, int amount) => change(() {
    if (amount <= 0) {
      cart.remove(item);
    } else {
      cart[item] = amount.clamp(1, 99);
    }
  });

  void addFood() => updateCart(food, (cart[food] ?? 0) + quantity);

  void placeOrder() {
    if (cart.isEmpty || paymentCards.isEmpty) return;
    orders.add(total);
    cart.clear();
    voucherPercent = 0;
    open(Screen.tracking, reset: true);
  }
}
