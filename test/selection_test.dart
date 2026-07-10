import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
import 'package:flutter_test/flutter_test.dart';

/// The reason this widget exists: tap an item, get the item.
///
/// Untested until coverage said so. 155 tests covered placement, theming,
/// overlay lifetime and search; not one of them tapped a row.

Widget host(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('tapping an item reports it and closes the menu', (tester) async {
    final chosen = <String?>[];

    await tester.pumpWidget(
      host(
        FlutterDropdownButton<String>.text(
          width: 200,
          items: const ['Apple', 'Banana', 'Cherry'],
          hint: 'Pick a fruit',
          onChanged: chosen.add,
        ),
      ),
    );

    await tester.tap(find.byType(FlutterDropdownButton<String>));
    await tester.pumpAndSettle();
    expect(find.text('Banana'), findsOneWidget, reason: 'the menu is open');

    await tester.tap(find.text('Banana'));
    await tester.pumpAndSettle();

    expect(chosen, ['Banana']);
    expect(
      find.text('Banana'),
      findsNothing,
      reason: 'the menu closed; the button still shows its hint',
    );
    expect(
      find.text('Pick a fruit'),
      findsOneWidget,
      reason: 'the widget is uncontrolled — the caller owns `value`',
    );
  });

  testWidgets('a custom-mode item reports the value, not the widget', (
    tester,
  ) async {
    final chosen = <int?>[];

    await tester.pumpWidget(
      host(
        FlutterDropdownButton<int>(
          width: 200,
          items: const [1, 2, 3],
          hintWidget: const Text('Pick a number'),
          itemBuilder: (item, isSelected) => Text('#$item'),
          onChanged: chosen.add,
        ),
      ),
    );

    await tester.tap(find.byType(FlutterDropdownButton<int>));
    await tester.pumpAndSettle();

    await tester.tap(find.text('#3'));
    await tester.pumpAndSettle();

    expect(chosen, [3]);
  });

  testWidgets('selecting from a filtered menu reports the filtered item', (
    tester,
  ) async {
    final chosen = <String?>[];

    await tester.pumpWidget(
      host(
        FlutterDropdownButton<String>.text(
          width: 200,
          items: const ['Apple', 'Banana', 'Cherry'],
          hint: 'Pick a fruit',
          searchable: true,
          onChanged: chosen.add,
        ),
      ),
    );

    await tester.tap(find.byType(FlutterDropdownButton<String>));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'err');
    await tester.pumpAndSettle();
    expect(find.text('Apple'), findsNothing);

    await tester.tap(find.text('Cherry'));
    await tester.pumpAndSettle();

    expect(chosen, ['Cherry']);
  });

  testWidgets('reopening a searched menu shows every item again', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        FlutterDropdownButton<String>.text(
          width: 200,
          items: const ['Apple', 'Banana', 'Cherry'],
          hint: 'Pick a fruit',
          searchable: true,
          onChanged: (_) {},
        ),
      ),
    );

    await tester.tap(find.byType(FlutterDropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'err');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cherry'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FlutterDropdownButton<String>));
    await tester.pumpAndSettle();

    expect(
      find.text('Apple'),
      findsOneWidget,
      reason: 'selecting resets the query',
    );
  });

  testWidgets('an empty search shows emptyBuilder', (tester) async {
    await tester.pumpWidget(
      host(
        FlutterDropdownButton<String>.text(
          width: 200,
          items: const ['Apple', 'Banana'],
          hint: 'Pick a fruit',
          searchable: true,
          emptyBuilder: (query) => Text('nothing matches "$query"'),
          onChanged: (_) {},
        ),
      ),
    );

    await tester.tap(find.byType(FlutterDropdownButton<String>));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pumpAndSettle();

    expect(find.text('nothing matches "zzz"'), findsOneWidget);
  });
}
