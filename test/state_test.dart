import 'package:flutter_test/flutter_test.dart';
import 'package:grabite/core/state.dart';
import 'package:grabite/data/catalog.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('search, filters and local preferences preserve demo choices', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final state = GraBiteState(preferences);
    state.signIn('demo@example.com', fullName: 'Demo User');
    state.setLocation('Chicago');
    state.setNotification(1, true);
    state.toggleSocial('Google');
    state.submitSearch('Burgers');
    expect(state.matches(query: state.search), contains(mcdonalds));
    state.filters = const FilterValues(category: 'Salads', diet: 'Vegan');
    expect(state.matches(), [mixt, petitCrenn]);

    final reopened = GraBiteState(preferences);
    expect(reopened.loggedIn, isTrue);
    expect(reopened.name, 'Demo User');
    expect(reopened.location, 'Chicago');
    expect(reopened.notifications[1], isTrue);
    expect(reopened.socialAccounts, contains('Google'));
  });
}
