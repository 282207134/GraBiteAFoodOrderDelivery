import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/state.dart';
import '../core/ui.dart';
import '../data/catalog.dart';
import 'discovery.dart';

class NearbyPage extends StatefulWidget {
  const NearbyPage({super.key});

  @override
  State<NearbyPage> createState() => _NearbyPageState();
}

class _NearbyPageState extends State<NearbyPage> {
  String selection = 'All';

  @override
  Widget build(BuildContext context) {
    final items = switch (selection) {
      'Burgers' => [mcdonalds, tacos, cafe],
      'Brunch' => [lazyBear, cafe, daylight],
      'Breakfast' => [daylight, bakery, lazyBear],
      _ => nearby,
    };
    return PageFrame(
      topInset: 0,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 330,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const Photo('map', radius: 0),
                Positioned(
                  top: 11,
                  left: 18,
                  child: mapIcon('Back', Icons.chevron_left, () {
                    if (Navigator.of(context).canPop()) {
                      context.close();
                    } else {
                      context.reset(Screen.home);
                    }
                  }),
                ),
                Positioned(
                  top: 11,
                  right: 18,
                  child: mapIcon(
                    'Search',
                    Icons.search,
                    () => context.open(Screen.searching),
                  ),
                ),
                Positioned(
                  bottom: 18,
                  right: 36,
                  child: mapIcon(
                    'Rich Table',
                    Icons.restaurant,
                    () => openRestaurant(
                      context,
                      richTable,
                      screen: Screen.reviews,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(gutter, 13, gutter, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: SizedBox(
                    width: 42,
                    height: 3,
                    child: ColoredBox(color: red),
                  ),
                ),
                space(14),
                const SectionTitle('Top Pick Restaurants', size: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final label in ['Burgers', 'Brunch', 'Breakfast'])
                      ChoicePill(
                        label.toUpperCase(),
                        selection == label,
                        () => setState(
                          () => selection = selection == label ? 'All' : label,
                        ),
                      ),
                  ],
                ),
                space(17),
                RestaurantGrid(
                  items,
                  photos: const {nethai: 'nethai-grid'},
                  onTap: (item) =>
                      openRestaurant(context, item, screen: Screen.reviews),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget mapIcon(String label, IconData icon, VoidCallback action) =>
      IconButton.filled(
        onPressed: action,
        tooltip: label,
        icon: Icon(icon, size: 20),
        style: IconButton.styleFrom(
          backgroundColor: red,
          foregroundColor: white,
        ),
      );
}

class ReviewsPage extends StatelessWidget {
  const ReviewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final restaurant = context.state.restaurant;
    return PageFrame(
      topInset: 0,
      header: const SizedBox(
        width: double.infinity,
        height: 36,
        child: Photo('map', radius: 0, alignment: Alignment.topCenter),
      ),
      footer: Foot(
        Row(
          children: [
            Expanded(
              child: ActionButton(
                'BROWSE FOOD',
                () => context.open(Screen.browse),
              ),
            ),
            const SizedBox(width: 10),
            IconButton.filledTonal(
              tooltip: 'Copy restaurant name',
              icon: const Icon(Icons.reply, color: red),
              style: IconButton.styleFrom(backgroundColor: tint),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: restaurant.name));
                if (context.mounted) {
                  context.showMessage('Restaurant name copied.');
                }
              },
            ),
          ],
        ),
      ),
      body: ContentList([
        Row(
          children: [
            Expanded(
              child: Text(
                restaurant.name,
                style: type(24, weight: FontWeight.w700),
              ),
            ),
            IconButton(
              tooltip: 'Close',
              onPressed: context.close,
              icon: const Icon(Icons.close, color: coral, size: 19),
            ),
          ],
        ),
        Row(
          children: [
            RatingPill(restaurant.rating),
            const SizedBox(width: 9),
            Text('${restaurant.minutes}min · Delivery', style: type(12)),
          ],
        ),
        space(13),
        Row(
          children: [
            const Icon(Icons.location_on, size: 20, color: red),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${context.state.location}, California',
                style: type(13),
              ),
            ),
          ],
        ),
        space(24),
        const Divider(),
        space(13),
        const SectionTitle('Ratings & Reviews', size: 20),
        const ReviewCard(
          'Alan Jones',
          5,
          'Great food. One of my favorite places to eat with friends.',
        ),
        const ReviewCard(
          'Ellen Roads',
          4.8,
          'One of the best food spots. Try the burger and a lemonade.',
        ),
        const ReviewCard(
          'Barry Wayne',
          5,
          'Fresh food, friendly service and a relaxed atmosphere.',
        ),
      ]),
    );
  }
}

class ReviewCard extends StatelessWidget {
  const ReviewCard(this.author, this.rating, this.description, {super.key});
  final String author, description;
  final double rating;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 21),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 13,
                backgroundColor: tint,
                child: Text(
                  author[0],
                  style: type(12, color: red, weight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 9),
              Text(author, style: type(13, weight: FontWeight.w600)),
              const SizedBox(width: 12),
              RatingPill(rating),
            ],
          ),
          space(10),
          Text(description, style: type(13, color: muted, height: 1.5)),
          if (author == 'Alan Jones') ...[
            space(12),
            Row(
              children: [
                for (final photo in [
                  'rich-table',
                  'burger-fries',
                  'halal-table',
                  'salad',
                ])
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: Photo(photo, height: 61, radius: 6),
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
