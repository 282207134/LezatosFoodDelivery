import 'package:flutter/material.dart';

import '../core/session.dart';
import '../core/ui.dart';
import '../data/catalog.dart';
import '../data/design.dart';

const _categoryNames = ['Main', 'Appetizer', 'Drinks', 'Dessert'];
const _categoryImages = ['taco', 'sundae', 'coffee', 'burrito'];
const _courseNames = ['Salad', 'Steak', 'Chicken', 'Korean'];
const _courses = [salad, steak, chicken, korean];
const _courseColors = [
  Color(0xffe9f6e3),
  Color(0xfffce6ea),
  Color(0xffe5ecfa),
  Color(0xffffefba),
];

class Discovery extends StatelessWidget {
  const Discovery(this.session, {super.key});
  final Session session;

  void _search() => session.openSearch();

  @override
  Widget build(BuildContext context) => switch (session.screen) {
    Screen.homeOne => _home(one: true),
    Screen.homeTwo => _nearby(),
    Screen.homeThree => _home(one: false),
    Screen.favouriteList || Screen.favouriteGrid => _favourites(),
    Screen.promos => _promos(context),
    Screen.notification => _notifications(context),
    Screen.search || Screen.searchEmpty => _Search(session),
    _ => const SizedBox.shrink(),
  };

  Widget _home({required bool one}) => ListView(
    padding: EdgeInsets.zero,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          children: [
            _delivery(white: !one),
            const SizedBox(height: 16),
            _searchBar(plain: one),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
        child: section('Choose Category'),
      ),
      _categories(all: !one),
      const SizedBox(height: 26),
      Padding(
        padding: gutter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            section('Main Course', actionText: 'See All', onTap: _search),
            const SizedBox(height: 10),
            if (one)
              GridView.count(
                primary: false,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 15,
                childAspectRatio: .89,
                children: [
                  for (var i = 0; i < _courses.length; i++)
                    _courseTile(i, _courseNames[i], height: 180),
                ],
              )
            else ...[
              _wideCourse(salad, 'Healthy Salad for Lunch', 0, image: 'steak'),
              const SizedBox(height: 16),
              _wideCourse(steak, steak.name, 2, image: 'salad'),
              const SizedBox(height: 16),
              _wideCourse(chicken, chicken.name, 3),
            ],
            const SizedBox(height: 18),
          ],
        ),
      ),
    ],
  );

  Widget _delivery({required bool white}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      InkWell(
        onTap: () => session.open(Screen.location),
        borderRadius: BorderRadius.circular(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            label(
              'Delivery',
              color: white ? Colors.white : ink,
              weight: FontWeight.w700,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                label(
                  session.location,
                  color: white ? Colors.white : ink,
                  weight: FontWeight.w400,
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: white ? Colors.white : ink,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
      GestureDetector(
        onTap: () => session.open(Screen.profile),
        child: ClipOval(child: art('avatar', width: 48, height: 48)),
      ),
    ],
  );

  Widget _searchBar({required bool plain}) => Semantics(
    button: true,
    label: 'Search food',
    child: InkWell(
      onTap: _search,
      borderRadius: BorderRadius.circular(30),
      child: panel(
        color: plain ? Colors.transparent : Colors.white,
        radius: 30,
        padding: EdgeInsets.symmetric(horizontal: plain ? 0 : 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.search, size: 25),
            const SizedBox(width: 12),
            Container(
              width: 1,
              height: 24,
              color: plain ? const Color(0xfff6cbb0) : line,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: label(
                'What would you like to eat?',
                size: 14,
                color: muted,
                weight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _categories({required bool all}) {
    final names = all
        ? ['All', 'Main', 'Dessert', 'Drinks', 'Appetizer']
        : _categoryNames;
    final images = all
        ? ['taco', 'meat', 'burrito', 'coffee', 'sundae']
        : _categoryImages;
    Widget item(int i) => InkWell(
      onTap: () =>
          session.openSearch(names[i] == 'Main' ? 'Main Course' : names[i]),
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: all ? 75 : 67,
        child: Column(
          children: [
            panel(
              radius: 40,
              color: all
                  ? Colors.white
                  : i == 0
                  ? const Color(0xffffe1b6)
                  : Colors.white,
              border: all ? line : null,
              child: SizedBox(
                width: 56,
                height: 56,
                child: Center(
                  child: art(
                    images[i],
                    width: 42,
                    height: 42,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            label(
              names[i],
              size: 12,
              color: all && i == 1 ? orange : ink,
              weight: FontWeight.w400,
            ),
          ],
        ),
      ),
    );
    if (!all) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [for (var i = 0; i < names.length; i++) item(i)],
        ),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(children: [for (var i = 0; i < names.length; i++) item(i)]),
    );
  }

  Widget _courseTile(int index, String title, {required double height}) =>
      SizedBox(
        height: height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Material(
            color: _courseColors[index],
            child: InkWell(
              onTap: () => session.selectFood(_courses[index]),
              child: LayoutBuilder(
                builder: (context, constraints) => Stack(
                  children: [
                    Positioned(
                      right: -12,
                      bottom: -14,
                      child: art(
                        _courses[index].image,
                        width: constraints.maxWidth * .89,
                        height: constraints.maxHeight * .78,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Positioned(
                      left: 16,
                      top: 15,
                      child: heading(title, size: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  Widget _wideCourse(Food item, String title, int color, {String? image}) =>
      SizedBox(
        height: 200,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Material(
            color: _courseColors[color],
            child: InkWell(
              onTap: () => session.selectFood(item),
              child: Stack(
                children: [
                  Positioned(
                    right: -43,
                    bottom: -44,
                    child: art(
                      image ?? item.image,
                      width: 218,
                      height: 220,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Positioned(
                    left: 18,
                    top: 24,
                    width: 188,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        heading(title, size: 18),
                        const SizedBox(height: 8),
                        heading(money(item.price), size: 14),
                      ],
                    ),
                  ),
                  Positioned(left: 8, bottom: 8, child: heart(session, item)),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _nearby() => ListView(
    padding: const EdgeInsets.only(top: 20, bottom: 16),
    children: [
      Padding(
        padding: gutter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                heading('Hello ${session.name.split(' ').last} 👋'),
                label('it’s lunch time!', weight: FontWeight.w400),
              ],
            ),
            iconAction(Icons.search, 'Search food', _search),
          ],
        ),
      ),
      const SizedBox(height: 24),
      Padding(
        padding: gutter,
        child: InkWell(
          onTap: () => session.open(Screen.location),
          borderRadius: BorderRadius.circular(16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 80,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  art('home_map'),
                  ColoredBox(
                    color: const Color(0x38ffffff),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Color(0xffffb950),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                label(
                                  'Your delivery address',
                                  size: 12,
                                  color: muted,
                                ),
                                label(session.address, size: 12, maxLines: 1),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: muted),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 18),
      Padding(
        padding: gutter,
        child: section('Category', actionText: 'See All', onTap: _search),
      ),
      const SizedBox(height: 8),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: gutter,
        child: Row(
          children: [
            for (var i = 0; i < 3; i++)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: SizedBox(
                  width: 120,
                  child: _courseTile(i, _courseNames[i], height: 80),
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: 18),
      Padding(
        padding: gutter,
        child: section('Nearby Food', actionText: 'See All', onTap: _search),
      ),
      Padding(
        padding: gutter,
        child: Row(
          children: [
            const Icon(Icons.location_on_outlined, color: muted, size: 15),
            const SizedBox(width: 5),
            label(session.location, size: 12, color: muted),
          ],
        ),
      ),
      const SizedBox(height: 15),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: gutter,
        child: Row(
          children: [
            for (final item in nearby)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 200,
                  child: _foodCard(item, imageHeight: 200),
                ),
              ),
          ],
        ),
      ),
    ],
  );

  Widget _pageTitle(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 11, 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        heading(title, size: 32),
        iconAction(Icons.search, 'Search food', _search),
      ],
    ),
  );

  Widget _favourites() {
    final grid = session.screen == Screen.favouriteGrid;
    return Column(
      children: [
        _pageTitle('Favourite'),
        Padding(padding: gutter, child: _FavouriteTabs(session)),
        const SizedBox(height: 20),
        Expanded(
          child: session.saved.isEmpty
              ? Center(
                  child: label(
                    'Your saved dishes will appear here.',
                    color: muted,
                  ),
                )
              : grid
              ? GridView.count(
                  padding: gutter,
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 16,
                  mainAxisExtent: 240,
                  children: [
                    for (final item in session.saved)
                      _foodCard(item, imageHeight: 150, showRating: true),
                  ],
                )
              : ListView.separated(
                  padding: gutter,
                  itemCount: session.saved.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 40, color: line),
                  itemBuilder: (context, index) => foodRow(
                    session,
                    session.saved.elementAt(index),
                    favourite: true,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _foodCard(
    Food item, {
    required double imageHeight,
    bool showRating = false,
  }) => InkWell(
    onTap: () => session.selectFood(item),
    borderRadius: BorderRadius.circular(14),
    child: panel(
      border: line,
      radius: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: imageHeight,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  art(item.image),
                  if (showRating)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: panel(
                        color: const Color(0xb3191b27),
                        radius: 18,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 15,
                              color: Color(0xffffb950),
                            ),
                            const SizedBox(width: 4),
                            label('4.9', size: 12, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 9, 8, 0),
            child: label(item.name, weight: FontWeight.w700, maxLines: 2),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                heading(money(item.price), size: 14),
                SizedBox(
                  height: 40,
                  child: heart(session, item, compact: true),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _promos(BuildContext context) => Column(
    children: [
      _pageTitle('Promos'),
      Expanded(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
          itemCount: promos.length,
          separatorBuilder: (_, _) => const SizedBox(height: 28),
          itemBuilder: (context, index) => InkWell(
            onTap: () => info(context, 'Promos', promos[index]),
            borderRadius: BorderRadius.circular(16),
            child: panel(
              border: line,
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  photo('promo_${index + 1}', width: 68, height: 68),
                  SizedBox(
                    height: 68,
                    width: 28,
                    child: CustomPaint(painter: _TicketDivider()),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        heading(promos[index], size: 14),
                        const SizedBox(height: 6),
                        label(
                          'Valid till 30 May 2020',
                          size: 13,
                          color: muted,
                          weight: FontWeight.w400,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  );

  Widget _notifications(BuildContext context) {
    final texts = [
      'Buy 1 get 1 free',
      'Sale 50% today',
      'ONLY TODAY 20%',
      'Sale 50% today',
      'ONLY TODAY 20%',
      'Sale 50% today',
    ];
    return Column(
      children: [
        toolbar('Notification', session.back, showBack: false),
        Expanded(
          child: verticalBody([
            const SizedBox(height: 28),
            for (var i = 0; i < texts.length; i++) ...[
              if (i == 0 || i == 2)
                Padding(
                  padding: EdgeInsets.only(top: i == 0 ? 0 : 16, bottom: 6),
                  child: label(
                    i == 0 ? 'New Notification' : 'This week',
                    size: 18,
                    color: muted,
                  ),
                ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: photo(
                  'notification_${i + 1}',
                  width: 52,
                  height: 52,
                  fit: BoxFit.contain,
                ),
                title: heading(texts[i], size: 14),
                subtitle: label(
                  'Valid till 20 May',
                  color: muted,
                  weight: FontWeight.w400,
                ),
                onTap: () => info(context, 'Notification', texts[i]),
              ),
              const Divider(color: line, height: 22),
            ],
          ]),
        ),
      ],
    );
  }
}

Widget heart(
  Session session,
  Food item, {
  bool compact = false,
  Color inactive = ink,
}) {
  final saved = session.saved.contains(item);
  return iconAction(
    saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
    saved ? 'Remove favourite' : 'Save favourite',
    () => session.toggleSaved(item),
    color: saved ? orange : inactive,
    size: compact ? 21 : 24,
  );
}

Widget foodRow(Session session, Food item, {bool favourite = false}) => InkWell(
  onTap: () => session.selectFood(item),
  borderRadius: BorderRadius.circular(12),
  child: Row(
    children: [
      photo(item.image, width: 80, height: 80),
      const SizedBox(width: 16),
      Expanded(
        child: SizedBox(
          height: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              heading(item.name, size: 14),
              label(money(item.price), size: 13, weight: FontWeight.w700),
              Row(
                children: [
                  Expanded(
                    child: label(
                      'by ${item.restaurant}',
                      size: 12,
                      color: muted,
                      weight: FontWeight.w400,
                      maxLines: 1,
                    ),
                  ),
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xffffb950),
                    size: 18,
                  ),
                  label('4.9', size: 13),
                ],
              ),
            ],
          ),
        ),
      ),
      if (favourite) heart(session, item, compact: true),
    ],
  ),
);

class _Search extends StatefulWidget {
  const _Search(this.session);
  final Session session;

  @override
  State<_Search> createState() => _SearchState();
}

class _SearchState extends State<_Search> {
  static const dessert = Food('Chocolate Sundae', 'Dapur Umami', 350, 'sundae');
  static const drink = Food('Iced Coffee', 'Dapur Umami', 400, 'coffee');
  late final controller = TextEditingController(
    text: widget.session.screen == Screen.searchEmpty ? 'pecel' : '',
  );
  late String category = widget.session.searchCategory;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = controller.text.trim();
    final key = query.toLowerCase();
    final all = {...menu, ..._courses, ...nearby, padThai, slicedSteak};
    final pool = switch (category) {
      'Nearby' || 'Near Me' || 'Ponorogo' => nearby,
      'Raja Ampat' || 'Bandung' || 'Bali' => const <Food>[],
      'Main Course' => all,
      'Appetizer' => [menu[1]],
      'Dessert' => const [dessert],
      'Drinks' => const [drink],
      _ => key.isEmpty ? menu : {...all, dessert, drink},
    };
    final results = pool.where(
      (item) => '${item.name} ${item.restaurant}'.toLowerCase().contains(key),
    );
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 16, 8),
          child: Row(
            children: [
              const Icon(Icons.search, size: 24),
              const SizedBox(width: 7),
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: (_) => setState(() {}),
                  textInputAction: TextInputAction.search,
                  style: type(14),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'What would you like to eat?',
                    hintStyle: type(14, color: muted, weight: FontWeight.w400),
                  ),
                ),
              ),
              link('Cancel', widget.session.back),
            ],
          ),
        ),
        SizedBox(
          height: 35,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: gutter,
            children: [
              for (final value
                  in query.isEmpty
                      ? [
                          'Nearby',
                          'All',
                          'Main Course',
                          'Dessert',
                          'Drinks',
                          'Appetizer',
                        ]
                      : [
                          'Near Me',
                          'All',
                          'Raja Ampat',
                          'Bandung',
                          'Bali',
                          'Ponorogo',
                        ])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(value),
                    selected: category == value,
                    showCheckmark: false,
                    selectedColor: orange,
                    labelStyle: type(
                      12,
                      color: category == value ? Colors.white : muted,
                    ),
                    side: const BorderSide(color: line),
                    shape: const StadiumBorder(),
                    onSelected: (_) => setState(() => category = value),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: verticalBody([
            const SizedBox(height: 26),
            heading(
              query.isNotEmpty
                  ? 'Result “$query”'
                  : category == 'All'
                  ? 'Top Searches'
                  : category,
              size: 18,
            ),
            const SizedBox(height: 14),
            if (results.isEmpty) ...[
              const SizedBox(height: 120),
              art('search_empty', width: 165, height: 145, fit: BoxFit.contain),
              const SizedBox(height: 25),
              heading(
                'No result for “$query”',
                size: 18,
                align: TextAlign.center,
              ),
              const SizedBox(height: 12),
              label(
                'Try to enter another keyword that related',
                color: muted,
                weight: FontWeight.w400,
                align: TextAlign.center,
              ),
            ] else
              for (final item in results) ...[
                foodRow(widget.session, item),
                const Divider(height: 40, color: line),
              ],
          ]),
        ),
      ],
    );
  }
}

class _FavouriteTabs extends StatelessWidget {
  const _FavouriteTabs(this.session);
  final Session session;

  @override
  Widget build(BuildContext context) => panel(
    color: soft,
    radius: 30,
    padding: const EdgeInsets.all(3),
    child: Row(
      children: [
        Expanded(
          child: panel(
            radius: 28,
            child: TextButton(
              onPressed: () {
                session.favourites = session.screen == Screen.favouriteList
                    ? Screen.favouriteGrid
                    : Screen.favouriteList;
                session.open(session.favourites, replace: true);
              },
              child: label('Favourite'),
            ),
          ),
        ),
        Expanded(
          child: TextButton(
            onPressed: () => info(
              context,
              'My Order',
              session.orders.isEmpty
                  ? 'Your orders will appear after a demo checkout.'
                  : session.orders.reversed
                        .map((total) => 'Order total  ${money(total)}')
                        .join('\n'),
            ),
            child: label('My Order'),
          ),
        ),
      ],
    ),
  );
}

class _TicketDivider extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = line
      ..strokeWidth = 1;
    for (var y = 0.0; y < size.height; y += 5) {
      canvas.drawLine(
        Offset(size.width / 2, y),
        Offset(size.width / 2, y + 2.5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
