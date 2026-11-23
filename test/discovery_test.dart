import 'package:flutter_test/flutter_test.dart';
import 'package:grabite/app.dart';
import 'package:grabite/core/state.dart';

import 'support/phone_viewport.dart';

void main() {
  testWidgets('home filters open matching results and switch layout', (
    tester,
  ) async {
    phoneViewport(tester);
    final state = GraBiteState();
    await tester.pumpWidget(GraBiteApp(state: state, initial: Screen.home));
    await tester.tap(find.text('Filter'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sort by'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fastest Delivery'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('COMPLETE'));
    await tester.pumpAndSettle();
    expect(state.filters.sort, 'Fastest Delivery');
    expect(find.text('Restaurants'), findsOneWidget);
    await tester.tap(find.text('Grid'));
    await tester.pumpAndSettle();
    expect(find.text('Search Again'), findsOneWidget);
  });
}
