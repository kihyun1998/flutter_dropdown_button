import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
import 'package:flutter_test/flutter_test.dart';

/// Width constraints, `expand`, the overlay's padding, and the empty state —
/// what the menu shows when a query matches nothing or the source list itself
/// is empty (#96), with or without a caller's `emptyBuilder`.
///
/// All reachable from the public API; none of them covered until #56.

Widget host(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

double buttonWidth(WidgetTester tester) =>
    tester.getSize(find.byType(FlutterDropdownButton<String>)).width;

void main() {
  group('width', () {
    testWidgets('a fixed width wins outright', (tester) async {
      await tester.pumpWidget(
        host(
          FlutterDropdownButton<String>.text(
            width: 180,
            minWidth: 10,
            maxWidth: 20,
            items: const ['Apple'],
            hint: 'Pick a fruit',
            disableWhenSingleItem: false,
            onChanged: (_) {},
          ),
        ),
      );

      expect(
        buttonWidth(tester),
        180,
        reason: 'min/max only apply when width is null',
      );
    });

    testWidgets('minWidth floors a narrow button', (tester) async {
      await tester.pumpWidget(
        host(
          FlutterDropdownButton<String>.text(
            minWidth: 300,
            items: const ['a'],
            hint: 'x',
            disableWhenSingleItem: false,
            onChanged: (_) {},
          ),
        ),
      );

      expect(buttonWidth(tester), 300);
    });

    testWidgets('maxWidth caps a button whose content overruns it', (
      tester,
    ) async {
      const long = 'A preposterously long label indeed';

      await tester.pumpWidget(
        host(
          FlutterDropdownButton<String>.text(
            maxWidth: 120,
            items: const [long],
            value: long,
            hint: 'x',
            disableWhenSingleItem: false,
            onChanged: (_) {},
          ),
        ),
      );

      expect(buttonWidth(tester), 120);
    });

    testWidgets('maxWidth is a ceiling, not a width', (tester) async {
      // The label must be *on the button* to push against the ceiling, so the
      // value is what matters, not the item list. A short face stays short.
      await tester.pumpWidget(
        host(
          FlutterDropdownButton<String>.text(
            maxWidth: 400,
            items: const ['x'],
            value: 'x',
            hint: 'x',
            disableWhenSingleItem: false,
            onChanged: (_) {},
          ),
        ),
      );

      expect(buttonWidth(tester), lessThan(400));
    });

    testWidgets('expand fills the row it sits in', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              child: Row(
                children: [
                  FlutterDropdownButton<String>.text(
                    expand: true,
                    items: const ['Apple'],
                    hint: 'Pick a fruit',
                    disableWhenSingleItem: false,
                    onChanged: (_) {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(buttonWidth(tester), 400);
    });
  });

  group('the empty search state', () {
    Widget searchable({Widget Function(String)? emptyBuilder}) =>
        FlutterDropdownButton<String>.text(
          width: 200,
          items: const ['Apple', 'Banana'],
          hint: 'Pick a fruit',
          searchable: true,
          emptyBuilder: emptyBuilder,
          onChanged: (_) {},
        );

    Future<void> searchFor(WidgetTester tester, String query) async {
      await tester.tap(find.byType(FlutterDropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), query);
      await tester.pumpAndSettle();
    }

    testWidgets('with no emptyBuilder, the package says so itself', (
      tester,
    ) async {
      await tester.pumpWidget(host(searchable()));

      await searchFor(tester, 'zzz');

      expect(find.text('No results found'), findsOneWidget);
      expect(find.text('Apple'), findsNothing);
    });

    testWidgets('a query that matches again hides the empty state', (
      tester,
    ) async {
      await tester.pumpWidget(host(searchable()));

      await searchFor(tester, 'zzz');
      expect(find.text('No results found'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'app');
      await tester.pumpAndSettle();

      expect(find.text('No results found'), findsNothing);
      expect(find.text('Apple'), findsOneWidget);
    });
  });

  group('the empty list state', () {
    // #96 — the builder was reachable only through the search path, so a menu
    // whose *source list* was empty rendered a bare card and called nothing.
    Widget empty({
      bool searchable = false,
      Widget Function(String)? emptyBuilder,
    }) => FlutterDropdownButton<String>.text(
      width: 200,
      items: const [],
      hint: 'Pick',
      searchable: searchable,
      disableWhenSingleItem: false,
      emptyBuilder: emptyBuilder,
      onChanged: (_) {},
    );

    Future<void> open(WidgetTester tester) async {
      await tester.tap(find.byType(FlutterDropdownButton<String>));
      await tester.pumpAndSettle();
    }

    testWidgets('with no builder, the package says "No items"', (tester) async {
      await tester.pumpWidget(host(empty()));

      await open(tester);

      expect(find.text('No items'), findsOneWidget);
      expect(
        tester.getSize(find.text('No items')).height,
        greaterThan(0),
        reason:
            'the menu reserved room for the empty state, '
            'not a chrome-only sliver',
      );
    });

    testWidgets('the builder runs, with an empty query', (tester) async {
      final queries = <String>[];
      await tester.pumpWidget(
        host(
          empty(
            emptyBuilder: (q) {
              queries.add(q);
              return const Text('nothing here');
            },
          ),
        ),
      );

      await open(tester);

      expect(find.text('nothing here'), findsOneWidget);
      expect(queries, isNotEmpty);
      expect(queries.every((q) => q.isEmpty), isTrue);
      expect(find.text('No items'), findsNothing);
    });

    testWidgets('searchable but untyped, the empty list still reaches the '
        'builder', (tester) async {
      final queries = <String>[];
      await tester.pumpWidget(
        host(
          empty(
            searchable: true,
            emptyBuilder: (q) {
              queries.add(q);
              return const Text('nothing here');
            },
          ),
        ),
      );

      await open(tester);

      expect(find.text('nothing here'), findsOneWidget);
      expect(queries.every((q) => q.isEmpty), isTrue);
    });

    testWidgets('a query typed over an empty list keeps the search wording', (
      tester,
    ) async {
      await tester.pumpWidget(host(empty(searchable: true)));

      await open(tester);
      expect(find.text('No items'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pumpAndSettle();

      expect(find.text('No results found'), findsOneWidget);
      expect(find.text('No items'), findsNothing);
    });

    testWidgets('disabling search while open drops the stale query', (
      tester,
    ) async {
      // The query survives `searchable` flipping off (the controller keeps
      // the field's text so re-enabling does not lose the caret), but a
      // builder must not see a query the user can no longer see or edit.
      final queries = <String>[];
      Widget at({required bool searchable}) => host(
        empty(
          searchable: searchable,
          emptyBuilder: (q) {
            queries.add(q);
            return Text('empty[$q]');
          },
        ),
      );

      await tester.pumpWidget(at(searchable: true));
      await open(tester);
      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pumpAndSettle();
      expect(queries.last, 'zzz');

      await tester.pumpWidget(at(searchable: false));
      await tester.pumpAndSettle();

      expect(queries.last, '');
      expect(find.text('empty[]'), findsOneWidget);
    });

    testWidgets('the multi-select checklist shows the same empty state', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          FlutterMultiSelectDropdown<String>(
            width: 200,
            items: const [],
            labelBuilder: (selected) =>
                selected.isEmpty ? 'Pick' : selected.join(', '),
            selected: const {},
            onChanged: (_) {},
          ),
        ),
      );

      await tester.tap(find.byType(FlutterMultiSelectDropdown<String>));
      await tester.pumpAndSettle();

      expect(find.text('No items'), findsOneWidget);
    });
  });

  testWidgets('overlayPadding wraps the menu content', (tester) async {
    await tester.pumpWidget(
      host(
        FlutterDropdownButton<String>.text(
          width: 200,
          items: const ['Apple', 'Banana'],
          hint: 'Pick a fruit',
          theme: const DropdownStyleTheme(
            overlay: DropdownOverlayTheme(padding: EdgeInsets.all(12)),
          ),
          onChanged: (_) {},
        ),
      ),
    );

    await tester.tap(find.byType(FlutterDropdownButton<String>));
    await tester.pumpAndSettle();

    final padding = tester.widgetList<Padding>(
      find.descendant(of: find.byType(Overlay), matching: find.byType(Padding)),
    );

    expect(
      padding.any((p) => p.padding == const EdgeInsets.all(12)),
      isTrue,
      reason: 'the menu content sits inside the themed padding',
    );
  });

  group('constructor asserts', () {
    test('minMenuWidth may not exceed maxMenuWidth in text mode', () {
      expect(
        () => FlutterDropdownButton<String>.text(
          items: const ['a'],
          minMenuWidth: 300,
          maxMenuWidth: 200,
          onChanged: (_) {},
        ),
        throwsAssertionError,
      );
    });

    test('minMenuWidth may not exceed maxMenuWidth in custom mode', () {
      expect(
        () => FlutterDropdownButton<String>(
          items: const ['a'],
          itemBuilder: (item, isSelected) => Text(item),
          minMenuWidth: 300,
          maxMenuWidth: 200,
          onChanged: (_) {},
        ),
        throwsAssertionError,
      );
    });
  });
}
