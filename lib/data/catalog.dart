class Food {
  const Food(this.name, this.restaurant, this.price, this.image);

  final String name;
  final String restaurant;
  final int price;
  final String image;
}

String money(int cents) => '\$${(cents / 100).toStringAsFixed(2)}';

const restaurant = 'Resto Parmato Bapo';
const steak = Food(
  'Grilled Beef Steak with Sauce ABC',
  restaurant,
  967,
  'steak',
);
const salad = Food('Salad Sayur Mantep', restaurant, 967, 'salad');
const chicken = Food('Ayam Panggang Ciamik', restaurant, 967, 'chicken');
const korean = Food('Korean Spicy Noodles', restaurant, 800, 'korean');
const padThai = Food(
  'Shrimp Pad Thai Sauce ABC Barbeque',
  restaurant,
  967,
  'padthai',
);
const slicedSteak = Food(
  'Sliced Grilled Beef Steak with Green Salad',
  restaurant,
  967,
  'steak_scene',
);

const menu = [
  Food('Pasta spaghetti with shrimps', 'Dapur Umami', 910, 'pasta'),
  Food('Baked chicken wings with sauce', 'Eco Kitchen', 690, 'wings'),
  Food('Chicken steak with salad', 'Joglo Manis', 840, 'chicken_steak'),
  Food('Tom yum kung or river prawn', 'RM Citra Alam', 800, 'tom_yum'),
  Food('Bakso Malang Ciamik', 'Mbok Mangap', 690, 'bakso'),
];

const nearby = [
  Food('Spaghetti with Spicy Mixed Seafood', restaurant, 800, 'nearby_pasta'),
  Food(
    'Delicious Pad Thai Fresh Shrimp Yahut',
    restaurant,
    1100,
    'nearby_shrimp',
  ),
];

const cards = [
  ('Visa', '9812'),
  ('Master Card', '8329'),
  ('American Express', '9812'),
];

const promos = [
  'Buy 1 drink and get 20% off on second drink',
  'Flat 10% off on total bill of \$10 or above',
  'Get 20% off for 12 months!',
];
