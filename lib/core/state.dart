import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/catalog.dart';

enum Screen {
  splashWhite,
  splashCoral,
  splashBlack,
  introOne,
  introTwo,
  introThree,
  signIn,
  signInActive,
  forgot,
  resetSent,
  register,
  registerActive,
  phone,
  phoneActive,
  verify,
  address,
  addressEntry,
  home,
  homeGrid,
  homeList,
  homeFavorites,
  featuredList,
  featuredGrid,
  restaurant,
  restaurantCompact,
  dish,
  cart,
  addCard,
  filterType,
  filterSort,
  filterPrice,
  filters,
  searchRestaurants,
  search,
  searching,
  resultsList,
  resultsGrid,
  orders,
  orderDetails,
  orderSuccess,
  homeCart,
  account,
  profile,
  password,
  paymentEmpty,
  cards,
  locations,
  socials,
  refer,
  share,
  scan,
  browse,
  nearby,
  reviews,
}

typedef CartLine = ({Dish dish, int count, String options});
typedef DemoOrder = ({
  Restaurant restaurant,
  List<CartLine> lines,
  int deliveryCents,
});

class FilterValues {
  const FilterValues({
    this.category = 'All',
    this.diet = 'Any',
    this.price = 0,
    this.fee = 5,
    this.sort = 'Recommended',
  });

  final String category;
  final String diet;
  final int price;
  final int fee;
  final String sort;

  FilterValues copyWith({
    String? category,
    String? diet,
    int? price,
    int? fee,
    String? sort,
  }) {
    return FilterValues(
      category: category ?? this.category,
      diet: diet ?? this.diet,
      price: price ?? this.price,
      fee: fee ?? this.fee,
      sort: sort ?? this.sort,
    );
  }
}

class GraBiteState extends ChangeNotifier {
  GraBiteState([SharedPreferences? preferences]) : _preferences = preferences {
    location = preferences?.getString('location') ?? cities.first;
    loggedIn = preferences?.getBool('loggedIn') ?? false;
    name = preferences?.getString('name') ?? '';
    email = preferences?.getString('email') ?? '';
    phone = preferences?.getString('phone') ?? '';
    addressOne = preferences?.getString('addressOne') ?? '';
    addressTwo = preferences?.getString('addressTwo') ?? '';
    socialAccounts.addAll(preferences?.getStringList('socials') ?? []);
    notifications = [
      preferences?.getBool('notification0') ?? true,
      preferences?.getBool('notification1') ?? false,
      preferences?.getBool('notification2') ?? true,
    ];
  }

  final SharedPreferences? _preferences;
  late bool loggedIn;
  late String location, name, email, phone, addressOne, addressTwo;
  late final List<bool> notifications;
  String resetEmail = '';
  String pendingPhone = '';
  final List<String> recentAddresses = [...cities];
  final List<String> recentSearches = [...searchExamples];
  final List<String> cards = [];
  final Set<String> socialAccounts = {};
  final List<CartLine> _cart = [];
  final List<DemoOrder> upcoming = [];
  final List<DemoOrder> past = [];
  Restaurant restaurant = bakery;
  Restaurant? cartRestaurant;
  Dish dish = cookie;
  DemoOrder? viewedOrder;
  String search = '';
  FilterValues filters = const FilterValues();
  String promo = '';

  List<CartLine> get cart => List.unmodifiable(_cart);
  int get itemCount => _cart.fold(0, (sum, item) => sum + item.count);
  int get deliveryCents =>
      promo == 'FREEDELIVERY' ? 0 : (cartRestaurant?.fee ?? 0) * 100;

  void signIn(String identity, {String? fullName}) {
    if (identity.contains('@')) {
      email = identity;
    } else if (identity.isNotEmpty) {
      phone = identity;
    }
    if (fullName != null) name = fullName;
    loggedIn = true;
    _preferences?.setBool('loggedIn', true);
    _saveProfile();
    notifyListeners();
  }

  void signOut() {
    loggedIn = false;
    _cart.clear();
    cartRestaurant = null;
    viewedOrder = null;
    upcoming.clear();
    past.clear();
    cards.clear();
    promo = '';
    _preferences?.setBool('loggedIn', false);
    notifyListeners();
  }

  void setLocation(String value) {
    location = value;
    recentAddresses.remove(value);
    recentAddresses.insert(0, value);
    _preferences?.setString('location', value);
    notifyListeners();
  }

  void setProfile(
    String name,
    String email,
    String phone,
    String addressOne,
    String addressTwo,
  ) {
    this.name = name;
    this.email = email;
    this.phone = phone;
    this.addressOne = addressOne;
    this.addressTwo = addressTwo;
    _saveProfile();
    notifyListeners();
  }

  void _saveProfile() {
    _preferences?.setString('name', name);
    _preferences?.setString('email', email);
    _preferences?.setString('phone', phone);
    _preferences?.setString('addressOne', addressOne);
    _preferences?.setString('addressTwo', addressTwo);
  }

  void setNotification(int index, bool value) {
    notifications[index] = value;
    _preferences?.setBool('notification$index', value);
    notifyListeners();
  }

  void toggleSocial(String value) {
    if (!socialAccounts.remove(value)) socialAccounts.add(value);
    _preferences?.setStringList('socials', socialAccounts.toList());
    notifyListeners();
  }

  void changed() => notifyListeners();

  void submitSearch(String query) {
    search = query.trim();
    if (search.isEmpty) return;
    recentSearches.removeWhere(
      (item) => item.toLowerCase() == search.toLowerCase(),
    );
    recentSearches.insert(0, search);
    notifyListeners();
  }

  List<Restaurant> matches({String query = ''}) {
    final words = query
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
        .split(' ');
    final matches = restaurants.where((restaurant) {
      final category = filters.category == 'Brunch'
          ? 'Breakfast'
          : filters.category;
      final haystack = '${restaurant.name} ${restaurant.categories.join(' ')}'
          .toLowerCase();
      return words.every(
            (word) =>
                haystack.contains(word) ||
                (word.endsWith('s') &&
                    haystack.contains(word.substring(0, word.length - 1))),
          ) &&
          (category == 'All' || restaurant.categories.contains(category)) &&
          (filters.diet == 'Any' || restaurant.diet == filters.diet) &&
          (filters.price == 0 || restaurant.price == filters.price) &&
          (filters.fee == 5 || restaurant.fee <= filters.fee);
    }).toList();
    switch (filters.sort) {
      case 'Fastest Delivery':
        matches.sort((a, b) => a.minutes.compareTo(b.minutes));
      case 'Most Popular':
        matches.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return matches;
  }

  void addDish(Dish dish, int count, String options) {
    if (restaurant != cartRestaurant) {
      _cart.clear();
      promo = '';
      cartRestaurant = restaurant;
    }
    final index = _cart.indexWhere(
      (line) => line.dish == dish && line.options == options,
    );
    if (index == -1) {
      _cart.add((dish: dish, count: count, options: options));
    } else {
      _cart[index] = (
        dish: dish,
        count: _cart[index].count + count,
        options: options,
      );
    }
    notifyListeners();
  }

  void removeLine(int index) {
    _cart.removeAt(index);
    if (_cart.isEmpty) {
      cartRestaurant = null;
      promo = '';
    }
    notifyListeners();
  }

  DemoOrder? checkout() {
    if (_cart.isEmpty || cartRestaurant == null) return null;
    final order = (
      restaurant: cartRestaurant!,
      lines: cart,
      deliveryCents: deliveryCents,
    );
    upcoming.insert(0, order);
    viewedOrder = order;
    _cart.clear();
    cartRestaurant = null;
    promo = '';
    notifyListeners();
    return order;
  }
}

class GraBiteScope extends InheritedNotifier<GraBiteState> {
  const GraBiteScope({
    super.key,
    required GraBiteState state,
    required super.child,
  }) : super(notifier: state);
}

extension GraBiteContext on BuildContext {
  GraBiteState get state =>
      dependOnInheritedWidgetOfExactType<GraBiteScope>()!.notifier!;

  Future<T?> open<T>(Screen screen, {bool replace = false}) {
    final nav = Navigator.of(this);
    return replace
        ? nav.pushReplacementNamed<T, Object?>(screen.name)
        : nav.pushNamed<T>(screen.name);
  }

  void reset(Screen screen) =>
      Navigator.of(this).pushNamedAndRemoveUntil(screen.name, (_) => false);

  void close() => Navigator.of(this).maybePop();

  void showMessage(String message) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(content: Text(message)));
  }
}
