import 'package:flutter_test/flutter_test.dart';
import 'package:grabite/app.dart';
import 'package:grabite/core/state.dart';

import 'support/phone_viewport.dart';

void main() {
  testWidgets(
    'card scan preview fills the demo form and keeps a masked label',
    (tester) async {
      phoneViewport(tester);
      final state = GraBiteState();
      await tester.pumpWidget(
        GraBiteApp(state: state, initial: Screen.addCard),
      );
      await tester.tap(find.text('SCAN CARD'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('USE DEMO CARD'));
      await tester.pumpAndSettle();
      expect(find.text('4242 4242 4242 4242'), findsOneWidget);
      await tester.tap(find.text('ADD CARD'));
      await tester.pumpAndSettle();
      expect(state.cards, ['Visa •••• 4242']);
    },
  );
}
