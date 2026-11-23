import 'package:flutter/material.dart';

import '../core/state.dart';
import '../core/ui.dart';
import '../data/catalog.dart';

void openRestaurant(
  BuildContext context,
  Restaurant restaurant, {
  Screen screen = Screen.restaurant,
}) {
  context.state.restaurant = restaurant;
  context.open(screen);
}

class RestaurantCard extends StatelessWidget {
  const RestaurantCard(
    this.restaurant, {
    super.key,
    this.layout = CardLayout.wide,
    this.photo,
    this.onTap,
  });

  final Restaurant restaurant;
  final CardLayout layout;
  final String? photo;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final wide = layout == CardLayout.wide;
    final tall = layout == CardLayout.tall;
    final tiles = layout == CardLayout.tile;
    final showDelivery = !tiles || tall;
    final name = restaurant.name;
    final fees = restaurant.fee == 0
        ? 'Free delivery'
        : '\$${restaurant.fee} delivery';
    final details = restaurant.categories.take(wide ? 3 : 2).join(' · ');
    return InkWell(
      onTap: onTap ?? () => openRestaurant(context, restaurant),
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Photo(
                photo ?? restaurant.photo,
                height: wide
                    ? 185
                    : tall
                    ? 210
                    : tiles
                    ? 139
                    : 160,
                width: double.infinity,
                radius: wide ? 13 : 9,
              ),
              if (tall)
                Positioned(
                  bottom: 8,
                  right: 7,
                  left: 8,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          '${restaurant.minutes}min\n${restaurant.fee == 0 ? 'Free' : '\$${restaurant.fee}'}',
                          style: type(10, color: white, weight: FontWeight.w700)
                              .copyWith(
                                shadows: const [
                                  Shadow(color: Colors.black, blurRadius: 5),
                                ],
                              ),
                        ),
                      ),
                      RatingPill(restaurant.rating),
                    ],
                  ),
                ),
            ],
          ),
          space(wide ? 12 : 9),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: type(
              wide || layout == CardLayout.horizontal ? 20 : 15,
              weight: FontWeight.w600,
            ),
          ),
          space(4),
          Text(
            layout == CardLayout.horizontal
                ? 'Colorado, San Francisco'
                : '${wide || tiles ? r'$' * restaurant.price + ' · ' : ''}$details',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: type(wide ? 14 : 12, color: coral),
          ),
          if (showDelivery && !tall) ...[
            space(9),
            if (wide)
              Wrap(
                spacing: 8,
                runSpacing: 5,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(restaurant.rating.toStringAsFixed(1), style: type(11)),
                  const Icon(Icons.star, color: red, size: 14),
                  Text('200+ Ratings', style: type(11)),
                  const Icon(Icons.schedule, color: red, size: 14),
                  Text('${restaurant.minutes} Min', style: type(11)),
                  const Icon(Icons.monetization_on, color: red, size: 14),
                  Text(
                    restaurant.fee == 0 ? 'Free' : '\$${restaurant.fee}',
                    style: type(11),
                  ),
                ],
              )
            else
              Row(
                children: [
                  RatingPill(restaurant.rating),
                  const SizedBox(width: 9),
                  Flexible(
                    child: Text(
                      '${restaurant.minutes}min · $fees',
                      style: type(11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }
}

enum CardLayout { wide, tall, horizontal, tile }

class RestaurantGrid extends StatelessWidget {
  const RestaurantGrid(
    this.items, {
    super.key,
    this.tall = true,
    this.onTap,
    this.photos = const {},
  });

  final List<Restaurant> items;
  final bool tall;
  final ValueChanged<Restaurant>? onTap;
  final Map<Restaurant, String> photos;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < items.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: buildCard(i)),
                const SizedBox(width: 14),
                Expanded(
                  child: i + 1 < items.length
                      ? buildCard(i + 1)
                      : const SizedBox(),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget buildCard(int index) {
    final item = items[index];
    return RestaurantCard(
      item,
      layout: tall ? CardLayout.tall : CardLayout.tile,
      photo: photos[item],
      onTap: onTap == null ? null : () => onTap!(item),
    );
  }
}

class HorizontalCards extends StatelessWidget {
  const HorizontalCards(this.restaurants, {super.key, this.photos = const {}});
  final List<Restaurant> restaurants;
  final Map<Restaurant, String> photos;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 265,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: gutter),
        itemCount: restaurants.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final restaurant = restaurants[index];
          return SizedBox(
            width: 200,
            child: RestaurantCard(
              restaurant,
              layout: CardLayout.horizontal,
              photo: photos[restaurant],
            ),
          );
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage(this.screen, {super.key});
  final Screen screen;

  static const grid = [
    mcdonalds,
    tacos,
    halal,
    cafe,
    splitBread,
    mario,
    daylight,
    kfc,
    bakery,
    popeyes,
  ];
  static const gridPhotos = {
    mcdonalds: 'burgers',
    cafe: 'waffle',
    halal: 'fries',
  };

  Widget padded(Widget child) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: gutter),
    child: child,
  );

  @override
  Widget build(BuildContext context) {
    final state = context.state;
    final gridHome = screen == Screen.homeGrid;
    final listHome = screen == Screen.homeList;
    final national = screen == Screen.homeFavorites;
    final showsCart = screen == Screen.homeCart;
    final restaurantCards =
        state.filters.category == 'All' &&
            state.filters.diet == 'Any' &&
            state.filters.price == 0 &&
            state.filters.fee == 5 &&
            state.filters.sort == 'Recommended'
        ? [mcdonalds, cafe, bakery, tacos]
        : state.matches();
    return PageFrame(
      tab: 0,
      header: SizedBox(
        height: 91,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: gutter),
          child: Row(
            children: [
              PopupMenuButton<Screen>(
                icon: const Icon(
                  Icons.dashboard_outlined,
                  size: 21,
                  color: coral,
                ),
                tooltip: 'Home layouts',
                onSelected: (screen) => context.open(screen, replace: true),
                itemBuilder: (context) => const [
                  PopupMenuItem(value: Screen.home, child: Text('Featured')),
                  PopupMenuItem(
                    value: Screen.homeGrid,
                    child: Text('Restaurant grid'),
                  ),
                  PopupMenuItem(
                    value: Screen.homeList,
                    child: Text('Restaurant list'),
                  ),
                  PopupMenuItem(
                    value: Screen.homeFavorites,
                    child: Text('National favorites'),
                  ),
                  PopupMenuItem(
                    value: Screen.nearby,
                    child: Text('Nearby map'),
                  ),
                ],
              ),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => context.open(Screen.address),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'DELIVERY TO',
                          style: type(11, color: red, weight: FontWeight.w600),
                        ),
                        space(3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                state.location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: type(19, weight: FontWeight.w600),
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down, size: 18),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              MiniAction('Filter', () => context.open(Screen.filterType)),
            ],
          ),
        ),
      ),
      footer: state.itemCount == 0 ? null : Foot(ViewCartButton(state)),
      body: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 22),
        children: [
          if (gridHome || national) ...[
            if (national) ...[
              padded(
                const HeroCarousel([
                  'hero-dessert',
                  'hero-soup',
                  'hero-orange',
                ]),
              ),
              space(25),
              padded(
                SectionTitle(
                  'National Favorites',
                  action: 'See all',
                  onTap: () => context.open(Screen.featuredGrid),
                ),
              ),
            ],
            padded(RestaurantGrid(grid, photos: gridPhotos)),
          ] else if (listHome) ...[
            padded(RestaurantCard(mcdonalds, photo: 'burgers')),
            space(22),
            padded(const RestaurantCard(cafe)),
            space(22),
            padded(const RestaurantCard(cafe, photo: 'cake')),
            space(22),
            padded(const SectionTitle('Type of Foods')),
            const HorizontalCards([kfc, mario, nethai]),
            padded(
              SectionTitle(
                'New Restaurants',
                action: 'See all',
                onTap: () => context.open(Screen.featuredList),
              ),
            ),
            const HorizontalCards([daylight, mario, bakery]),
          ] else ...[
            padded(
              HeroCarousel(
                showsCart
                    ? ['hero-orange', 'hero-soup', 'hero-dessert']
                    : ['hero-soup', 'hero-orange', 'hero-dessert'],
              ),
            ),
            space(24),
            padded(
              SectionTitle(
                'Featured Partners',
                action: 'See all',
                onTap: () => context.open(Screen.featuredList),
              ),
            ),
            const HorizontalCards([daylight, mario, bakery]),
            space(11),
            padded(const PromoBanner()),
            space(26),
            padded(
              SectionTitle(
                'Best Picks\nRestaurants by team',
                action: 'See all',
                onTap: () => context.open(Screen.featuredGrid),
              ),
            ),
            const HorizontalCards(
              [mcdonalds, halal, tacos],
              photos: {mcdonalds: 'fries', halal: 'halal'},
            ),
            space(16),
            padded(
              SectionTitle(
                'All Restaurants',
                action: 'See all',
                onTap: () => context.open(Screen.homeList),
              ),
            ),
            if (restaurantCards.isEmpty) padded(const EmptyResults()),
            for (final restaurant in restaurantCards) ...[
              padded(RestaurantCard(restaurant)),
              space(22),
            ],
          ],
        ],
      ),
    );
  }
}

class HeroCarousel extends StatefulWidget {
  const HeroCarousel(this.photos, {super.key});
  final List<String> photos;

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  final controller = PageController();
  int active = 0;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 185,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Stack(
          children: [
            PageView.builder(
              controller: controller,
              itemCount: widget.photos.length,
              onPageChanged: (value) => setState(() => active = value),
              itemBuilder: (_, index) => GestureDetector(
                onTap: () =>
                    openRestaurant(context, [bakery, richTable, cafe][index]),
                child: Photo(widget.photos[index], radius: 0),
              ),
            ),
            Positioned(
              right: 13,
              bottom: 8,
              child: Row(
                children: [
                  for (var index = 0; index < widget.photos.length; index++)
                    InkWell(
                      onTap: () => controller.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOut,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Container(
                          width: 8,
                          height: 5,
                          decoration: BoxDecoration(
                            color: index == active
                                ? red
                                : const Color(0xccf6ab9d),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PromoBanner extends StatelessWidget {
  const PromoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(13),
      child: ColoredBox(
        color: tint,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(19),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Free Delivery for\n1 Month!',
                      style: type(23, weight: FontWeight.w700),
                    ),
                    space(10),
                    Text(
                      'You’ve to order at least \$10 for using free delivery for 1 month.',
                      style: type(13, color: red, height: 1.55),
                    ),
                  ],
                ),
              ),
            ),
            const Photo('promo-art', height: 168, width: 65, radius: 0),
          ],
        ),
      ),
    );
  }
}

class ViewCartButton extends StatelessWidget {
  const ViewCartButton(this.state, {super.key});
  final GraBiteState state;

  @override
  Widget build(BuildContext context) {
    return TintRow(
      state.cartRestaurant!.name,
      subtitle: '${state.itemCount} item(s) · View cart',
      icon: Icons.shopping_basket,
      onTap: () => context.open(Screen.cart),
    );
  }
}

class FeaturedPage extends StatelessWidget {
  const FeaturedPage(this.screen, {super.key});
  final Screen screen;

  @override
  Widget build(BuildContext context) {
    final grid = screen == Screen.featuredGrid;
    final browse = screen == Screen.browse;
    final list = browse ? [richTable, nethai, bakery, mario] : featured;
    return PageFrame(
      header: ScreenHeader(
        browse ? 'Browse Foods' : 'Featured Partners',
        trailing: browse
            ? null
            : IconButton(
                tooltip: grid ? 'List layout' : 'Grid layout',
                onPressed: () => context.open(
                  grid ? Screen.featuredList : Screen.featuredGrid,
                  replace: true,
                ),
                icon: Icon(
                  grid ? Icons.view_agenda_outlined : Icons.grid_view,
                  color: coral,
                  size: 19,
                ),
              ),
      ),
      tab: browse ? null : 0,
      body: ContentList([
        if (grid)
          const RestaurantGrid(
            [tacos, mcdonalds, kfc, cafe, daylight, mario],
            photos: {mcdonalds: 'burger-fries', cafe: 'waffle'},
          )
        else
          for (final restaurant in list) ...[
            RestaurantCard(restaurant),
            space(24),
          ],
      ]),
    );
  }
}

class EmptyResults extends StatelessWidget {
  const EmptyResults({super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 36),
    child: Center(
      child: Text(
        'No restaurants match. Try another search or filter.',
        textAlign: TextAlign.center,
        style: type(14, color: muted),
      ),
    ),
  );
}

class SearchPage extends StatefulWidget {
  const SearchPage(this.screen, {super.key});
  final Screen screen;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final input = TextEditingController();

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  void submit(String value) {
    if (value.trim().isEmpty) return;
    context.state.submitSearch(value);
    FocusScope.of(context).unfocus();
    context.open(Screen.resultsList);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.state;
    final active = widget.screen == Screen.searching;
    final restaurantMode = widget.screen == Screen.searchRestaurants;
    if (active) {
      final query = input.text.trim();
      final suggestions = state.recentSearches.where(
        (value) => value.toLowerCase().contains(query.toLowerCase()),
      );
      return PageFrame(
        header: Padding(
          padding: const EdgeInsets.fromLTRB(gutter, 12, gutter, 0),
          child: Row(
            children: [
              Expanded(
                child: Field(
                  'Search',
                  input,
                  icon: Icons.search,
                  autofocus: true,
                  highlight: true,
                  action: TextInputAction.search,
                  onChanged: (_) => setState(() {}),
                  onSubmitted: submit,
                ),
              ),
              const SizedBox(width: 9),
              MiniAction('Cancel', context.close),
            ],
          ),
        ),
        body: ContentList([
          SectionTitle(
            'RECENT SEARCHES',
            size: 14,
            action: 'CLEAR ALL',
            onTap: () {
              state.recentSearches.clear();
              state.changed();
            },
          ),
          if (query.isNotEmpty)
            TintRow(query, icon: Icons.search, onTap: () => submit(query)),
          for (final value in suggestions)
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: const Icon(Icons.search, color: coral, size: 17),
              title: Text(value, style: type(13, color: coral)),
              onTap: () => submit(value),
            ),
        ]),
      );
    }
    return PageFrame(
      tab: 1,
      body: ContentList([
        if (restaurantMode)
          SectionTitle(
            'Search',
            action: 'Food',
            onTap: () => context.open(Screen.search, replace: true),
          ),
        TintRow(
          restaurantMode ? 'Search on foodor' : 'Search',
          icon: Icons.search,
          onTap: () => context.open(Screen.searching),
          trailing: const SizedBox.shrink(),
        ),
        space(11),
        SectionTitle(
          restaurantMode ? 'Top Restaurants' : 'Top Categories',
          size: 15,
          action: restaurantMode ? null : 'Restaurants',
          onTap: () => context.open(Screen.searchRestaurants),
        ),
        if (restaurantMode)
          const RestaurantGrid(topRestaurants, tall: false)
        else
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 13,
            crossAxisSpacing: 13,
            children: [
              for (final entry in categories)
                Material(
                  color: tint,
                  borderRadius: BorderRadius.circular(10),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => submit(
                      entry.label == 'Breakfast & Brunch'
                          ? 'Breakfast'
                          : entry.label,
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Photo(entry.photo, radius: 0),
                        const ColoredBox(color: Color(0x55000000)),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              entry.label,
                              textAlign: TextAlign.center,
                              style: type(
                                16,
                                color: Colors.white,
                                weight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
      ]),
    );
  }
}

class ResultsPage extends StatelessWidget {
  const ResultsPage({super.key, this.grid = false});
  final bool grid;

  @override
  Widget build(BuildContext context) {
    final state = context.state;
    final results = state.matches(query: state.search);
    return PageFrame(
      header: ScreenHeader(
        state.search.isEmpty ? 'Restaurants' : state.search,
        trailing: MiniAction('Filter', () => context.open(Screen.filters)),
      ),
      body: ContentList([
        SectionTitle(
          '${results.length} results found',
          size: 15,
          action: grid ? 'List' : 'Grid',
          onTap: () => context.open(
            grid ? Screen.resultsList : Screen.resultsGrid,
            replace: true,
          ),
        ),
        if (grid) ...[
          Align(
            alignment: Alignment.centerRight,
            child: MiniAction(
              'Search Again',
              () => context.open(Screen.searching),
            ),
          ),
          space(10),
        ],
        if (results.isEmpty)
          const EmptyResults()
        else if (grid)
          RestaurantGrid(results)
        else
          for (final item in results) ...[
            RestaurantCard(
              item,
              photo: item == mcdonalds ? 'burger-results' : null,
            ),
            space(23),
          ],
      ]),
    );
  }
}
