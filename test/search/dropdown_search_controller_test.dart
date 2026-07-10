import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
import 'package:flutter_test/flutter_test.dart';

/// No widget tree, no `pumpWidget`, no typing into a `TextField`.
///
/// **Characterization, not regression.** None of these were ever red: they pin
/// behaviour extracted unchanged from the widget's `State`. What is new is that
/// it is reachable — filtering, reset, and the enable/disable dance used to be
/// observable only by mounting a dropdown and typing into it.
///
/// `test/search_invalidation_test.dart` still exercises the rendered widget,
/// because that is where the bug it guards actually was.

const fruits = ['Apple', 'Banana', 'Cherry'];

bool contains(String item, String query) =>
    item.toLowerCase().contains(query.toLowerCase());

DropdownSearchController<String> searching({bool enabled = true}) {
  final c = DropdownSearchController<String>(enabled: enabled);
  addTearDown(c.dispose);
  return c;
}

void main() {
  test('a disabled controller allocates nothing and hides nothing', () {
    final search = searching(enabled: false);

    expect(search.enabled, isFalse);
    expect(search.textController, isNull);
    expect(search.focusNode, isNull);
    expect(search.visibleItems(fruits, contains), same(fruits),
        reason: 'the caller\'s own list, not a copy');
  });

  test('an enabled controller has a field to type into', () {
    final search = searching();

    expect(search.textController, isNotNull);
    expect(search.focusNode, isNotNull);
    expect(search.query, isEmpty);
  });

  test('an empty query hides nothing, but hands back a copy', () {
    final search = searching();

    final visible = search.visibleItems(fruits, contains);
    expect(visible, fruits);
    expect(visible, isNot(same(fruits)));
  });

  test('a query filters through the supplied predicate', () {
    final search = searching()..onQueryChanged('an');

    expect(search.visibleItems(fruits, contains), ['Banana']);
  });

  test('a null filter hides nothing, however long the query', () {
    // Custom mode: the presentation cannot match a widget against a query.
    final search = searching()..onQueryChanged('zzz');

    expect(search.visibleItems(fruits, null), fruits);
  });

  test('the visible list is derived, never cached', () {
    final search = searching()..onQueryChanged('a');

    expect(search.visibleItems(fruits, contains), ['Apple', 'Banana']);
    expect(search.visibleItems(const ['Avocado'], contains), ['Avocado'],
        reason: 'a different list, filtered by the same live query');
  });

  test('reset clears the query and the field', () {
    final search = searching()..onQueryChanged('ban');
    search.textController!.text = 'ban';

    search.reset();

    expect(search.query, isEmpty);
    expect(search.textController!.text, isEmpty);
    expect(search.visibleItems(fruits, contains), fruits);
  });

  test('enabling at runtime allocates the field', () {
    final search = searching(enabled: false);

    search.enabled = true;

    expect(search.textController, isNotNull);
    expect(search.focusNode, isNotNull);
  });

  test('disabling stops filtering but keeps the field', () {
    final search = searching()..onQueryChanged('ban');
    final field = search.textController;

    search.enabled = false;

    expect(search.visibleItems(fruits, contains), same(fruits));
    expect(search.textController, same(field),
        reason: 'turning search back on must not lose the caret');
  });

  test('re-enabling keeps the query that was already typed', () {
    final search = searching()..onQueryChanged('ban');

    search.enabled = false;
    search.enabled = true;

    expect(search.query, 'ban');
    expect(search.visibleItems(fruits, contains), ['Banana']);
  });

  test('a non-String T filters through its own predicate', () {
    final search = DropdownSearchController<int>(enabled: true);
    addTearDown(search.dispose);
    search.onQueryChanged('2');

    expect(
      search.visibleItems(const [1, 2, 12, 3], (n, q) => '$n'.contains(q)),
      [2, 12],
    );
  });

  test('dispose releases the field, and is safe to call once', () {
    final search = DropdownSearchController<String>(enabled: true);

    search.dispose();

    expect(search.textController, isNull);
    expect(search.focusNode, isNull);
  });
}
