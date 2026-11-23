import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grabite/app.dart';
import 'package:grabite/core/state.dart';
import 'package:grabite/data/catalog.dart';

import 'support/phone_viewport.dart';

void main() {
  testWidgets('sign-in validates inputs, then selects a delivery address', (
    tester,
  ) async {
    phoneViewport(tester);
    final state = GraBiteState();
    await tester.pumpWidget(
      GraBiteApp(state: state, initial: Screen.signInActive),
    );
    await tester.tap(find.text('SIGN IN'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid phone number'), findsOneWidget);
    expect(find.text('Use at least 6 characters'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'demo@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'demo123');
    await tester.tap(find.text('SIGN IN'));
    await tester.pumpAndSettle();
    expect(state.loggedIn, isTrue);
    await tester.tap(find.text('Use current location'));
    await tester.pumpAndSettle();
    expect(find.text('Featured Partners'), findsOneWidget);
    expect(state.location, cities.first);
  });
}
