import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grabite/app.dart';
import 'package:grabite/core/state.dart';
import 'package:grabite/data/catalog.dart';

void main() {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(graBiteOverlay);
  final route = binding.platformDispatcher.defaultRouteName.replaceFirst(
    '/',
    '',
  );
  final screen = Screen.values.asNameMap()[route] ?? Screen.home;
  final state = GraBiteState()
    ..signIn('naseem@example.com', fullName: 'Naseem Waheed')
    ..phone = '+92 321 3453 147'
    ..resetEmail = 'naseem@example.com'
    ..pendingPhone = '+1 501 333 2982'
    ..search = 'Burgers';

  switch (screen) {
    case Screen.homeCart:
      state.restaurant = const Restaurant('Uncle Pizza', 'pasta', ['Pizza']);
      state.addDish(cookie, 1, '');
    case Screen.cart || Screen.orderDetails || Screen.orderSuccess:
      state.restaurant = mcdonalds;
      state.addDish(cookie, 1, '');
      state.addDish(combo, 1, '');
      state.addDish(oyster, 2, '');
      if (screen == Screen.orderSuccess) state.checkout();
    case Screen.orders:
      state.upcoming.addAll([
        (
          restaurant: mcdonalds,
          lines: [(dish: combo, count: 1, options: '')],
          deliveryCents: 0,
        ),
        (
          restaurant: tacos,
          lines: [(dish: chow, count: 1, options: '')],
          deliveryCents: 100,
        ),
        (
          restaurant: halal,
          lines: [(dish: dimSum, count: 1, options: '')],
          deliveryCents: 300,
        ),
      ]);
      state.past.add((
        restaurant: cafe,
        lines: [(dish: cookie, count: 1, options: '')],
        deliveryCents: 0,
      ));
    case Screen.cards:
      state.cards.addAll(['PayPal', 'MasterCard', 'Visa']);
    case Screen.reviews:
      state.restaurant = richTable;
    case Screen.filterPrice:
      state.filters = const FilterValues(price: 2);
    case Screen.filters:
      state.filters = const FilterValues(category: 'Burgers', price: 2);
    default:
      break;
  }
  runApp(GraBiteApp(state: state, initial: screen, preview: true));
}
