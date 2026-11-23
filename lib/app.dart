import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/state.dart';
import 'core/ui.dart';
import 'features/account.dart';
import 'features/auth.dart';
import 'features/discovery.dart';
import 'features/filters.dart';
import 'features/nearby.dart';
import 'features/ordering.dart';

const graBiteOverlay = SystemUiOverlayStyle(
  statusBarColor: white,
  statusBarIconBrightness: Brightness.dark,
  systemNavigationBarColor: white,
  systemNavigationBarIconBrightness: Brightness.dark,
  systemNavigationBarDividerColor: white,
);

class GraBiteApp extends StatelessWidget {
  const GraBiteApp({
    super.key,
    required this.state,
    this.initial = Screen.splashCoral,
    this.preview = false,
  });

  final GraBiteState state;
  final Screen initial;
  final bool preview;

  @override
  Widget build(BuildContext context) {
    return GraBiteScope(
      state: state,
      child: MaterialApp(
        title: 'GraBite',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Montserrat',
          colorScheme: ColorScheme.fromSeed(
            seedColor: red,
            surface: white,
            primary: red,
          ),
          scaffoldBackgroundColor: white,
          inputDecorationTheme: const InputDecorationTheme(isDense: true),
        ),
        builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
          value: graBiteOverlay,
          child: child!,
        ),
        onGenerateInitialRoutes: (_) => [routeFor(initial)],
        onGenerateRoute: (settings) {
          final screen = Screen.values.asNameMap()[settings.name];
          return screen == null ? null : routeFor(screen);
        },
      ),
    );
  }

  Route<void> routeFor(Screen screen) {
    return MaterialPageRoute<void>(
      settings: RouteSettings(name: screen.name),
      builder: (_) => switch (screen) {
        Screen.splashWhite ||
        Screen.splashCoral ||
        Screen.splashBlack => SplashPage(screen, hold: preview),
        Screen.introOne => const WalkthroughPage(0),
        Screen.introTwo => const WalkthroughPage(1),
        Screen.introThree => const WalkthroughPage(2),
        Screen.signIn => SignInPage(full: false, preview: preview),
        Screen.signInActive => const SignInPage(),
        Screen.forgot => const ResetPasswordPage(),
        Screen.resetSent => const ResetPasswordPage(sent: true),
        Screen.register => const RegisterPage(),
        Screen.registerActive => const RegisterPage(active: true),
        Screen.phone => const PhonePage(),
        Screen.phoneActive => PhonePage(active: true, preview: preview),
        Screen.verify => PhonePage(
          active: true,
          verify: true,
          preview: preview,
        ),
        Screen.address ||
        Screen.addressEntry ||
        Screen.locations => AddressPage(screen),
        Screen.home ||
        Screen.homeGrid ||
        Screen.homeList ||
        Screen.homeFavorites ||
        Screen.homeCart => HomePage(screen),
        Screen.featuredList ||
        Screen.featuredGrid ||
        Screen.browse => FeaturedPage(screen),
        Screen.restaurant => const RestaurantPage(),
        Screen.restaurantCompact => const RestaurantPage(compact: true),
        Screen.dish => const DishPage(),
        Screen.cart ||
        Screen.orderDetails ||
        Screen.orderSuccess => CartPage(screen),
        Screen.addCard => AddCardPage(preview: preview),
        Screen.filterType ||
        Screen.filterSort ||
        Screen.filterPrice ||
        Screen.filters => FilterPage(screen),
        Screen.searchRestaurants ||
        Screen.search ||
        Screen.searching => SearchPage(screen),
        Screen.resultsList => const ResultsPage(),
        Screen.resultsGrid => const ResultsPage(grid: true),
        Screen.orders => const OrdersPage(),
        Screen.account => const AccountPage(),
        Screen.profile => const ProfilePage(),
        Screen.password => const ProfilePage(changePassword: true),
        Screen.paymentEmpty => const PaymentPage(empty: true),
        Screen.cards => const PaymentPage(),
        Screen.socials => const SocialAccountsPage(),
        Screen.refer => const ReferralPage(),
        Screen.share => const ReferralPage(share: true),
        Screen.scan => const ScanPage(),
        Screen.nearby => const NearbyPage(),
        Screen.reviews => const ReviewsPage(),
      },
    );
  }
}
