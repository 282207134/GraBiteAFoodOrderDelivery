import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/state.dart';
import '../core/ui.dart';
import '../data/catalog.dart';
import 'discovery.dart';

class RestaurantPage extends StatefulWidget {
  const RestaurantPage({super.key, this.compact = false});
  final bool compact;

  @override
  State<RestaurantPage> createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> {
  bool seafood = false;
  bool pickup = false;

  void openDish(Dish dish) {
    context.state.dish = dish;
    context.open(Screen.dish);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.state;
    final restaurant = state.restaurant;
    final compact = widget.compact;
    final photo = restaurant == bakery ? 'restaurant-hero' : restaurant.photo;
    final menu = seafood
        ? const [oyster, oysterIce, friedRice]
        : const [cookie, combo, chow];
    return PageFrame(
      topInset: compact ? 40 : 0,
      tab: compact ? null : 0,
      footer: state.itemCount == 0 ? null : Foot(ViewCartButton(state)),
      header: compact
          ? ScreenHeader(
              '',
              trailing: IconButton(
                onPressed: () => context.open(Screen.searching),
                tooltip: 'Search',
                icon: const Icon(Icons.search, color: red, size: 20),
              ),
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.only(bottom: 30),
        children: [
          if (!compact)
            Stack(
              children: [
                Photo(photo, height: 244, width: double.infinity, radius: 0),
                Positioned(
                  left: gutter,
                  right: gutter,
                  top: 13,
                  child: Row(
                    children: [
                      heroButton(Icons.chevron_left, 'Back', context.close),
                      const Spacer(),
                      heroButton(Icons.reply, 'Copy restaurant name', () async {
                        await Clipboard.setData(
                          ClipboardData(text: restaurant.name),
                        );
                        if (context.mounted) {
                          context.showMessage('Restaurant name copied.');
                        }
                      }),
                      const SizedBox(width: 6),
                      heroButton(
                        Icons.search,
                        'Search',
                        () => context.open(Screen.searching),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(gutter, compact ? 7 : 21, gutter, 17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        restaurant.name,
                        style: type(20, weight: FontWeight.w700),
                      ),
                    ),
                    IconButton(
                      tooltip: compact ? 'Show cover' : 'Compact menu',
                      onPressed: () => context.open(
                        compact ? Screen.restaurant : Screen.restaurantCompact,
                        replace: true,
                      ),
                      icon: Icon(
                        compact
                            ? Icons.photo_outlined
                            : Icons.view_agenda_outlined,
                        size: 19,
                        color: coral,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${'\$' * restaurant.price} · ${restaurant.categories.join(' · ')}',
                  style: type(13, color: coral),
                ),
                space(10),
                InkWell(
                  onTap: () => context.open(Screen.reviews),
                  child: Row(
                    children: [
                      Text(
                        restaurant.rating.toStringAsFixed(1),
                        style: type(12),
                      ),
                      const SizedBox(width: 7),
                      const Icon(Icons.star, color: red, size: 16),
                      const SizedBox(width: 7),
                      Text('200+ Ratings', style: type(12)),
                    ],
                  ),
                ),
                space(16),
                Row(
                  children: [
                    const Icon(Icons.monetization_on, color: red, size: 19),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        pickup
                            ? 'Pickup'
                            : restaurant.fee == 0
                            ? 'Free delivery'
                            : money(restaurant.fee * 100),
                        style: type(12, weight: FontWeight.w600),
                      ),
                    ),
                    const Icon(Icons.schedule, color: red, size: 19),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${restaurant.minutes} min',
                        style: type(12, weight: FontWeight.w600),
                      ),
                    ),
                    MiniAction(
                      pickup ? 'DELIVERY' : 'TAKE AWAY',
                      () => setState(() => pickup = !pickup),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(gutter, 5, gutter, 0),
            child: const SectionTitle('Featured Items', size: 18),
          ),
          SizedBox(
            height: 187,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: gutter),
              itemCount: 3,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final item = const [cookie, chow, dimSum][index];
                return InkWell(
                  onTap: () => openDish(item),
                  child: SizedBox(
                    width: 138,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Photo(item.photo, height: 135, width: 138),
                        space(8),
                        Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: type(12, weight: FontWeight.w600),
                        ),
                        Text(money(item.cents), style: type(12, color: coral)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: gutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 9,
                  runSpacing: 7,
                  children: [
                    ChoicePill(
                      'Popular',
                      !seafood,
                      () => setState(() => seafood = false),
                    ),
                    ChoicePill(
                      'Seafood',
                      seafood,
                      () => setState(() => seafood = true),
                    ),
                    ChoicePill('Appetizers', false, () => openDish(dimSum)),
                  ],
                ),
                space(17),
                SectionTitle(seafood ? 'Sea Foods' : 'Most Populars', size: 19),
                for (final item in menu) DishRow(item, () => openDish(item)),
                if (!seafood) ...[
                  const SectionTitle('Sea Foods', size: 19),
                  for (final item in [oyster, oysterIce, friedRice])
                    DishRow(item, () => openDish(item)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget heroButton(IconData icon, String label, VoidCallback tap) =>
      IconButton.filledTonal(
        tooltip: label,
        onPressed: tap,
        icon: Icon(icon, size: 21),
        style: IconButton.styleFrom(
          backgroundColor: tint,
          foregroundColor: red,
        ),
      );
}

class DishRow extends StatelessWidget {
  const DishRow(this.item, this.onTap, {super.key});
  final Dish item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Photo(item.photo, width: 104, height: 101, radius: 8),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: type(14, weight: FontWeight.w600)),
                  space(4),
                  Text(
                    item.description,
                    style: type(12, color: muted, height: 1.55),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  space(5),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      money(item.cents),
                      style: type(12, color: red, weight: FontWeight.w600),
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

class DishPage extends StatefulWidget {
  const DishPage({super.key});

  @override
  State<DishPage> createState() => _DishPageState();
}

class _DishPageState extends State<DishPage> {
  int count = 1;
  String top = cookieOptions[1];
  String bottom = cookieOptions[4];
  String note = '';

  Future<void> add(Dish dish) async {
    final state = context.state;
    if (state.itemCount > 0 && state.cartRestaurant != state.restaurant) {
      final replace = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Start a new cart?'),
          content: Text(
            'Your cart contains items from ${state.cartRestaurant!.name}.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('KEEP CART'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('REPLACE CART'),
            ),
          ],
        ),
      );
      if (replace != true || !mounted) return;
    }
    final options = [
      if (dish == cookie) '$top · $bottom',
      if (note.isNotEmpty) note,
    ];
    state.addDish(dish, count, options.join(' · '));
    context.close();
  }

  Future<void> editNote() async {
    final edited = await promptText(
      context,
      'Special instructions',
      'Note for the restaurant',
      note,
    );
    if (edited != null && mounted) setState(() => note = edited);
  }

  @override
  Widget build(BuildContext context) {
    final item = context.state.dish;
    return PageFrame(
      topInset: 0,
      footer: Foot(
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filledTonal(
                  tooltip: 'Decrease quantity',
                  onPressed: count > 1 ? () => setState(() => count--) : null,
                  icon: const Icon(Icons.remove, color: red),
                  style: IconButton.styleFrom(backgroundColor: tint),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 13),
                  child: Text(
                    '$count'.padLeft(2, '0'),
                    style: type(16, color: red, weight: FontWeight.w600),
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: 'Increase quantity',
                  onPressed: count < 30 ? () => setState(() => count++) : null,
                  icon: const Icon(Icons.add, color: red),
                  style: IconButton.styleFrom(backgroundColor: tint),
                ),
              ],
            ),
            space(8),
            ActionButton(
              'ADD TO ORDER (${money(item.cents * count)})',
              () => add(item),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Stack(
            children: [
              Photo(item.photo, width: double.infinity, height: 255, radius: 0),
              const Positioned(
                top: 8,
                left: 0,
                right: 0,
                child: ScreenHeader('', dismiss: true),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(gutter, 18, gutter, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: type(25, weight: FontWeight.w600)),
                space(9),
                Text(
                  item.description,
                  style: type(13, color: muted, height: 1.6),
                ),
                space(10),
                Text(
                  '${'\$' * context.state.restaurant.price} · ${context.state.restaurant.categories.join(' · ')}',
                  style: type(14, color: coral),
                ),
                space(18),
                const Divider(),
                space(11),
                if (item == cookie) ...[
                  cookieChoices(
                    'Choice of top Cookie',
                    top,
                    (choice) => setState(() => top = choice),
                  ),
                  space(12),
                  cookieChoices(
                    'Bottom Cookie',
                    bottom,
                    (choice) => setState(() => bottom = choice),
                  ),
                ],
                TintRow(
                  'Add Special Instructions',
                  subtitle: note.isEmpty ? null : note,
                  icon: Icons.edit_note,
                  onTap: editNote,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget cookieChoices(
    String label,
    String selected,
    ValueChanged<String> choose,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label, style: type(16, weight: FontWeight.w600)),
            ),
            Text(
              'REQUIRED',
              style: type(11, color: red, weight: FontWeight.w600),
            ),
          ],
        ),
        space(12),
        for (final item in cookieOptions)
          TintRow(
            item,
            strong: item != selected,
            leading: Icon(
              item == selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: coral,
              size: 18,
            ),
            trailing: const SizedBox.shrink(),
            onTap: () => choose(item),
          ),
      ],
    );
  }
}

Future<String?> promptText(
  BuildContext context,
  String title,
  String label, [
  String initial = '',
]) {
  var value = initial;
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title, style: type(19, weight: FontWeight.w600)),
      content: TextFormField(
        initialValue: initial,
        autofocus: true,
        decoration: InputDecoration(labelText: label),
        onChanged: (text) => value = text,
        onFieldSubmitted: (_) => Navigator.pop(context, value.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, value.trim()),
          child: const Text('SAVE'),
        ),
      ],
    ),
  );
}

class CartPage extends StatelessWidget {
  const CartPage(this.screen, {super.key});
  final Screen screen;

  @override
  Widget build(BuildContext context) {
    final state = context.state;
    final cart = screen == Screen.cart;
    final receipt = cart ? null : state.viewedOrder;
    final restaurant =
        receipt?.restaurant ?? state.cartRestaurant ?? state.restaurant;
    final lines = receipt?.lines ?? state.cart;
    final subtotal = lines.fold<int>(
      0,
      (sum, line) => sum + line.count * line.dish.cents,
    );
    final fee = receipt?.deliveryCents ?? state.deliveryCents;
    final total = subtotal + fee;
    final button = cart ? 'CONTINUE' : 'CHECKOUT';
    final content = PageFrame(
      header: ScreenHeader(
        cart ? 'Your Orders' : restaurant.name,
        dismiss: cart,
      ),
      footer: lines.isEmpty
          ? null
          : Foot(
              ActionButton(
                receipt == null
                    ? '$button (${money(total)})'
                    : 'BACK TO ORDERS',
                () {
                  if (receipt != null) {
                    context.reset(Screen.orders);
                  } else if (cart) {
                    state.viewedOrder = null;
                    context.open(Screen.orderDetails);
                  } else if (state.checkout() != null) {
                    context.open(Screen.orderSuccess, replace: true);
                  }
                },
              ),
            ),
      body: ContentList([
        if (lines.isEmpty) ...[
          space(55),
          const Icon(Icons.shopping_basket_outlined, size: 58, color: coral),
          space(16),
          Center(
            child: Text(
              'Your cart is empty',
              style: type(20, weight: FontWeight.w600),
            ),
          ),
          space(21),
          ActionButton('BROWSE RESTAURANTS', () => context.reset(Screen.home)),
        ] else ...[
          for (final (index, line) in lines.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: tint,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Text('${line.count}', style: type(13, color: red)),
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          line.dish.name,
                          style: type(16, weight: FontWeight.w600),
                        ),
                        space(5),
                        Text(
                          line.options.isEmpty
                              ? line.dish.description
                              : line.options,
                          style: type(12, color: muted, height: 1.6),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    children: [
                      Text(
                        money(line.dish.cents * line.count),
                        style: type(13, color: red, weight: FontWeight.w600),
                      ),
                      if (cart)
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minHeight: 33,
                            minWidth: 34,
                          ),
                          tooltip: 'Remove ${line.dish.name}',
                          onPressed: () => state.removeLine(index),
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            size: 16,
                            color: coral,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          space(5),
          const SectionTitle('Your Bill', size: 16),
          DecoratedBox(
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(17),
              child: Column(
                children: [
                  TotalRow('Subtotal', subtotal),
                  space(8),
                  TotalRow('Delivery', fee),
                  const Divider(height: 23, color: Color(0xffffcec4)),
                  TotalRow('Total (incl. VAT)', total, bold: true),
                ],
              ),
            ),
          ),
          if (receipt == null) ...[
            space(12),
            billLink(
              'Add more items',
              () => openRestaurant(context, restaurant),
            ),
            billLink(
              state.promo.isEmpty ? 'Promo code' : 'Promo: ${state.promo}',
              () async {
                final value = await promptText(
                  context,
                  'Promo code',
                  'Try FREEDELIVERY',
                  state.promo,
                );
                if (value == null || !context.mounted) return;
                final code = value.toUpperCase();
                if (code.isNotEmpty && code != 'FREEDELIVERY') {
                  context.showMessage('Promo code was not recognized.');
                  return;
                }
                state.promo = code;
                state.changed();
              },
            ),
            billLink(
              state.cards.isEmpty
                  ? 'Add payment method'
                  : 'Payment method · ${state.cards.first}',
              () => context.open(Screen.addCard),
            ),
          ],
        ],
      ]),
    );
    if (screen != Screen.orderSuccess) return content;
    return Stack(
      children: [
        IgnorePointer(child: content),
        Positioned.fill(
          child: ColoredBox(
            color: const Color(0x99000000),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 325),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Material(
                    color: white,
                    borderRadius: BorderRadius.circular(18),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 19, 18, 17),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircleAvatar(
                            radius: 28,
                            backgroundColor: red,
                            child: Icon(Icons.check, color: white, size: 30),
                          ),
                          space(15),
                          Text(
                            'You’ve placed your\norder successfully!',
                            textAlign: TextAlign.center,
                            style: type(19, weight: FontWeight.w600),
                          ),
                          space(12),
                          Text(
                            'Your demo order has been added to Your Orders.',
                            textAlign: TextAlign.center,
                            style: type(13, color: muted, height: 1.6),
                          ),
                          space(19),
                          ActionButton(
                            'KEEP BROWSING',
                            () => context.reset(Screen.home),
                            light: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget billLink(String title, VoidCallback action) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 9),
    dense: true,
    title: Text(title, style: type(13, weight: FontWeight.w600)),
    trailing: const Icon(Icons.chevron_right, color: red),
    onTap: action,
  );
}

class TotalRow extends StatelessWidget {
  const TotalRow(this.label, this.cents, {super.key, this.bold = false});
  final String label;
  final int cents;
  final bool bold;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          label,
          style: type(13, weight: bold ? FontWeight.w700 : FontWeight.w500),
        ),
      ),
      Text(
        money(cents),
        style: type(
          15,
          color: red,
          weight: bold ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    ],
  );
}

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.state;
    return PageFrame(
      header: ScreenHeader(
        'Your Orders',
        onBack: () => context.reset(Screen.home),
      ),
      tab: 2,
      body: ContentList([
        orderSection(context, 'UPCOMING ORDERS', state.upcoming),
        space(18),
        orderSection(context, 'PAST ORDERS', state.past),
      ]),
    );
  }

  Widget orderSection(
    BuildContext context,
    String title,
    List<DemoOrder> orders,
  ) {
    final state = context.state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title,
          size: 15,
          action: orders.isEmpty ? null : 'CLEAR ALL',
          onTap: () {
            orders.clear();
            state.changed();
          },
        ),
        if (orders.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Text('No orders to display.', style: type(13, color: muted)),
          ),
        for (final order in orders)
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: DishRow(
              Dish(
                order.restaurant.name,
                order.restaurant.photo,
                order.lines.fold(
                  0,
                  (sum, line) => sum + line.count * line.dish.cents,
                ),
                order.lines.map((line) => line.dish.name).join(' · '),
              ),
              () {
                state.viewedOrder = order;
                context.open(Screen.orderDetails);
              },
            ),
          ),
      ],
    );
  }
}
