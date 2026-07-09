import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
import 'package:flutter_test/flutter_test.dart';

/// Reads the text currently sitting in the dropdown's search field.
String searchFieldText(WidgetTester tester) {
  return tester.widget<TextField>(find.byType(TextField)).controller!.text;
}

Future<void> openDropdown(WidgetTester tester, [Finder? button]) async {
  await tester.tap(button ?? find.byType(FlutterDropdownButton<String>));
  await tester.pumpAndSettle();
}

/// A domain type that deliberately does not override `==`, so two instances
/// carrying the same name are never equal.
class Fruit {
  const Fruit(this.name);
  final String name;
}

void main() {
  group('search survives a parent rebuild', () {
    testWidgets('typed query is kept when items arrive as a fresh list',
        (tester) async {
      late StateSetter rebuildParent;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: StatefulBuilder(
                builder: (context, setState) {
                  rebuildParent = setState;
                  // A new List instance on every build — what any caller
                  // writing `source.map(...).toList()` produces.
                  return FlutterDropdownButton<String>.text(
                    items: ['Apple', 'Banana', 'Cherry'],
                    hint: 'Pick a fruit',
                    searchable: true,
                    onChanged: (_) {},
                  );
                },
              ),
            ),
          ),
        ),
      );

      await openDropdown(tester);
      await tester.enterText(find.byType(TextField), 'App');
      await tester.pumpAndSettle();

      expect(searchFieldText(tester), 'App');

      // Anything at all rebuilds the ancestor while the user is mid-search.
      rebuildParent(() {});
      await tester.pumpAndSettle();

      expect(searchFieldText(tester), 'App');
    });

    testWidgets('an item added in place shows up on the next open',
        (tester) async {
      final items = <String>['Apple', 'Banana'];
      late StateSetter rebuildParent;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: StatefulBuilder(
                builder: (context, setState) {
                  rebuildParent = setState;
                  // Same List instance every build; only its contents change.
                  return FlutterDropdownButton<String>.text(
                    items: items,
                    hint: 'Pick a fruit',
                    searchable: true,
                    onChanged: (_) {},
                  );
                },
              ),
            ),
          ),
        ),
      );

      rebuildParent(() => items.add('Cherry'));
      await tester.pumpAndSettle();

      await openDropdown(tester);

      expect(find.text('Cherry'), findsOneWidget);
    });

    testWidgets('the filtered results survive the rebuild too', (tester) async {
      late StateSetter rebuildParent;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: StatefulBuilder(
                builder: (context, setState) {
                  rebuildParent = setState;
                  return FlutterDropdownButton<String>.text(
                    items: ['Apple', 'Banana', 'Cherry'],
                    hint: 'Pick a fruit',
                    searchable: true,
                    onChanged: (_) {},
                  );
                },
              ),
            ),
          ),
        ),
      );

      await openDropdown(tester);
      await tester.enterText(find.byType(TextField), 'App');
      await tester.pumpAndSettle();

      rebuildParent(() {});
      await tester.pumpAndSettle();

      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Banana'), findsNothing);
    });

    testWidgets('holds for a T that does not override ==', (tester) async {
      late StateSetter rebuildParent;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: StatefulBuilder(
                builder: (context, setState) {
                  rebuildParent = setState;
                  // Deliberately not const: const instances are canonicalized,
                  // which would hand the widget the same Fruit objects every
                  // build and defeat the point. These are new objects each
                  // time, so neither list identity nor element equality can
                  // tell that nothing really changed.
                  // ignore: prefer_const_constructors
                  return FlutterDropdownButton<Fruit>(
                    // ignore: prefer_const_constructors
                    items: [Fruit('Apple'), Fruit('Banana')],
                    itemBuilder: (fruit, _) => Text(fruit.name),
                    hintWidget: const Text('Pick a fruit'),
                    searchable: true,
                    searchFilter: (fruit, query) =>
                        fruit.name.toLowerCase().contains(query.toLowerCase()),
                    onChanged: (_) {},
                  );
                },
              ),
            ),
          ),
        ),
      );

      await openDropdown(tester, find.byType(FlutterDropdownButton<Fruit>));
      await tester.enterText(find.byType(TextField), 'App');
      await tester.pumpAndSettle();

      rebuildParent(() {});
      await tester.pumpAndSettle();

      expect(searchFieldText(tester), 'App');
      expect(find.text('Banana'), findsNothing);
    });
  });

  group('search is still cleared where it should be', () {
    testWidgets('reopening the dropdown starts from an empty query',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: FlutterDropdownButton<String>.text(
                items: const ['Apple', 'Banana', 'Cherry'],
                hint: 'Pick a fruit',
                searchable: true,
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      await openDropdown(tester);
      await tester.enterText(find.byType(TextField), 'App');
      await tester.pumpAndSettle();

      // Tap outside to dismiss, then open again.
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      await openDropdown(tester);

      expect(searchFieldText(tester), isEmpty);
      expect(find.text('Banana'), findsOneWidget);
    });
  });
}
