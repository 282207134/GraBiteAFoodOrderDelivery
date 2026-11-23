import 'package:flutter_test/flutter_test.dart';
import 'package:grabite/app.dart';
import 'package:grabite/core/state.dart';

import 'support/phone_viewport.dart';

void main() {
  testWidgets(
    'restaurant dish quantity flows through cart, checkout and orders',
    (tester) async {
      phoneViewport(tester);
      final state = GraBiteState();
      await tester.pumpWidget(
        GraBiteApp(state: state, initial: Screen.restaurant),
      );
      await tester.tap(find.text('Cookie Sandwich').first);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Increase quantity'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ADD TO ORDER (\$14.80)'));
      await tester.pumpAndSettle();
      expect(state.itemCount, 2);
      await tester.tap(find.text('2 item(s) · View cart'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('CONTINUE (\$14.80)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('CHECKOUT (\$14.80)'));
      await tester.pumpAndSettle();
      expect(
        find.text('You’ve placed your\norder successfully!'),
        findsOneWidget,
      );
      expect(state.itemCount, 0);
      expect(state.upcoming.single.lines.single.count, 2);
      await tester.tap(find.text('KEEP BROWSING'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Orders'));
      await tester.pumpAndSettle();
      expect(find.text('Mayfield Bakery & Cafe'), findsOneWidget);
    },
  );
}
