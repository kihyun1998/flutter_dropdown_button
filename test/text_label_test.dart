import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
import 'package:flutter_test/flutter_test.dart';

/// A domain type. Not a String, and it does not override `==`.
class Fruit {
  const Fruit(this.name);
  final String name;
}

const apple = Fruit('Apple');
const banana = Fruit('Banana');
const cherry = Fruit('Cherry');

Widget host(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

Future<void> openDropdown(WidgetTester tester) async {
  await tester.tap(find.byType(FlutterDropdownButton<Fruit>));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('text mode renders any T through its label', (tester) async {
    await tester.pumpWidget(
      host(
        FlutterDropdownButton<Fruit>.text(
          items: const [apple, banana, cherry],
          label: (fruit) => fruit.name,
          hint: 'Pick a fruit',
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.text('Pick a fruit'), findsOneWidget);

    await openDropdown(tester);

    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('Banana'), findsOneWidget);
    expect(find.text('Cherry'), findsOneWidget);
  });

  testWidgets('the selected item shows its label on the button', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        FlutterDropdownButton<Fruit>.text(
          items: const [apple, banana, cherry],
          value: banana,
          label: (fruit) => fruit.name,
          hint: 'Pick a fruit',
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.text('Banana'), findsOneWidget);
    expect(find.text('Pick a fruit'), findsNothing);
  });

  testWidgets('search filters by label with no searchFilter supplied', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        FlutterDropdownButton<Fruit>.text(
          items: const [apple, banana, cherry],
          label: (fruit) => fruit.name,
          hint: 'Pick a fruit',
          searchable: true,
          onChanged: (_) {},
        ),
      ),
    );

    await openDropdown(tester);
    await tester.enterText(find.byType(TextField), 'ban');
    await tester.pumpAndSettle();

    expect(find.text('Banana'), findsOneWidget);
    expect(find.text('Apple'), findsNothing);
    expect(find.text('Cherry'), findsNothing);
  });

  testWidgets('omitting label for a non-String T fails immediately', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        FlutterDropdownButton<int>.text(
          items: const [1, 2],
          hint: 'Pick a number',
          onChanged: (_) {},
        ),
      ),
    );

    // Fails when the widget mounts, not later when an item happens to paint.
    expect(tester.takeException(), isAssertionError);
  });

  testWidgets('an overflowing label gets a tooltip', (tester) async {
    const longName = 'A fruit with a preposterously long name';

    await tester.pumpWidget(
      host(
        FlutterDropdownButton<Fruit>.text(
          width: 100,
          items: const [Fruit(longName)],
          label: (fruit) => fruit.name,
          hint: 'Pick a fruit',
          onChanged: (_) {},
        ),
      ),
    );

    await openDropdown(tester);
    expect(find.text(longName), findsOneWidget);

    await tester.longPress(find.text(longName));
    await tester.pumpAndSettle();

    // The item, plus the tooltip that appeared over it.
    expect(find.text(longName), findsNWidgets(2));
  });
}
