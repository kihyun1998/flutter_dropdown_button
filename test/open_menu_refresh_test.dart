import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> openDropdown(WidgetTester tester) async {
  await tester.tap(find.byType(FlutterDropdownButton<String>));
  await tester.pumpAndSettle();
}

/// Pumps a dropdown whose items come from a parent the test can update,
/// mimicking a list that arrives asynchronously.
Future<void Function(List<String>)> pumpWithMutableItems(
  WidgetTester tester, {
  required List<String> initial,
  bool searchable = false,
}) async {
  var items = initial;
  late StateSetter setParentState;

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: StatefulBuilder(
            builder: (context, setState) {
              setParentState = setState;
              return FlutterDropdownButton<String>.text(
                items: items,
                hint: 'Pick a fruit',
                searchable: searchable,
                onChanged: (_) {},
              );
            },
          ),
        ),
      ),
    ),
  );

  return (next) => setParentState(() => items = next);
}

void main() {
  testWidgets('an open menu reflects items that change underneath it',
      (tester) async {
    // The item count is held constant so this measures only whether the open
    // overlay picks up new items — not whether it can grow. The overlay's
    // height is fixed when it opens, so a longer list would scroll the new
    // item out of view and confound the two.
    final setItems = await pumpWithMutableItems(
      tester,
      initial: ['Apple', 'Banana', 'Cherry'],
    );

    await openDropdown(tester);
    expect(find.text('Blueberry'), findsNothing);

    // The network came back while the user was looking at the menu.
    setItems(['Apple', 'Blueberry', 'Cherry']);
    await tester.pumpAndSettle();

    expect(find.text('Blueberry'), findsOneWidget);
    expect(find.text('Banana'), findsNothing);
  });

  testWidgets('items arriving while searching are filtered by the query',
      (tester) async {
    final setItems = await pumpWithMutableItems(
      tester,
      initial: ['Apple', 'Banana'],
      searchable: true,
    );

    await openDropdown(tester);
    await tester.enterText(find.byType(TextField), 'an');
    await tester.pumpAndSettle();

    expect(find.text('Banana'), findsOneWidget);
    expect(find.text('Apple'), findsNothing);

    setItems(['Apple', 'Banana', 'Mango', 'Cherry']);
    await tester.pumpAndSettle();

    // 'Mango' matches 'an' and must appear; 'Cherry' does not.
    expect(find.text('Mango'), findsOneWidget);
    expect(find.text('Banana'), findsOneWidget);
    expect(find.text('Cherry'), findsNothing);
  });
}
