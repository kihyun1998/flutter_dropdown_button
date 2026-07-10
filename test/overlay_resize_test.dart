import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps a dropdown whose items the test can change, positioned [topInset]
/// pixels down the 800x600 test screen.
Future<void Function(List<String>)> pumpDropdown(
  WidgetTester tester, {
  required List<String> initial,
  double topInset = 250,
}) async {
  var items = initial;
  late StateSetter setParentState;

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: EdgeInsets.only(top: topInset, left: 100),
            child: StatefulBuilder(
              builder: (context, setState) {
                setParentState = setState;
                return FlutterDropdownButton<String>.text(
                  width: 200,
                  items: items,
                  hint: 'Pick a fruit',
                  onChanged: (_) {},
                );
              },
            ),
          ),
        ),
      ),
    ),
  );

  return (next) => setParentState(() => items = next);
}

Future<void> openDropdown(WidgetTester tester) async {
  await tester.tap(find.byType(FlutterDropdownButton<String>));
  await tester.pumpAndSettle();
}

/// The menu's box. Items lay out in a Column when they all fit and a ListView
/// when they don't.
Rect menuRect(WidgetTester tester) {
  final listView = find.byType(ListView);
  if (listView.evaluate().isNotEmpty) return tester.getRect(listView);
  return tester.getRect(
    find.ancestor(of: find.text('Apple'), matching: find.byType(Column)).first,
  );
}

Rect buttonRect(WidgetTester tester) =>
    tester.getRect(find.byType(FlutterDropdownButton<String>));

List<String> manyItems(int n) =>
    List<String>.generate(n, (i) => i == 0 ? 'Apple' : 'Item $i');

void main() {
  testWidgets('an open menu grows when an item is added', (tester) async {
    final setItems = await pumpDropdown(tester, initial: ['Apple', 'Banana']);

    await openDropdown(tester);
    final before = menuRect(tester).height;

    setItems(['Apple', 'Banana', 'Cherry']);
    await tester.pumpAndSettle();

    // Three 48px items still fit inside the default 200px budget, so the new
    // item must be visible without a scrollbar.
    expect(find.text('Cherry'), findsOneWidget);
    expect(find.byType(ListView), findsNothing);
    expect(menuRect(tester).height, greaterThan(before));
  });

  testWidgets('an open menu shrinks when items are removed', (tester) async {
    final setItems = await pumpDropdown(tester, initial: manyItems(8));

    await openDropdown(tester);
    expect(find.byType(ListView), findsOneWidget, reason: 'eight items scroll');
    final before = menuRect(tester).height;

    setItems(['Apple', 'Banana']);
    await tester.pumpAndSettle();

    expect(find.byType(ListView), findsNothing);
    expect(menuRect(tester).height, lessThan(before));
  });

  testWidgets('an open menu flips above the button when it no longer fits', (
    tester,
  ) async {
    // Button occupies y 402..450 on a 600px screen. One item (50px) fits in
    // the 138px below it; eight items (202px) do not, and 390px sit above.
    final setItems = await pumpDropdown(
      tester,
      initial: ['Apple'],
      topInset: 402,
    );

    await openDropdown(tester);
    final button = buttonRect(tester);
    expect(
      menuRect(tester).top,
      greaterThan(button.bottom),
      reason: 'one item opens downward',
    );

    setItems(manyItems(8));
    await tester.pumpAndSettle();

    expect(
      menuRect(tester).bottom,
      lessThan(button.top),
      reason: 'eight items no longer fit below, so the menu flips above',
    );
  });
}
