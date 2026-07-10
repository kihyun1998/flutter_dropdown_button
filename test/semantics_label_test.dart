import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
import 'package:flutter_test/flutter_test.dart';

/// Observed at the seam that matters for this field: the semantics tree, which
/// is what a screen reader actually reads. Not the widget tree.

class Fruit {
  const Fruit(this.name);
  final String name;
}

const apple = Fruit('Apple');
const banana = Fruit('Banana');
const cherry = Fruit('Cherry');

Future<void> pumpDropdown(WidgetTester tester, {Fruit? value}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: FlutterDropdownButton<Fruit>.text(
            width: 200,
            items: const [apple, banana, cherry],
            value: value,
            label: (fruit) => fruit.name,
            hint: 'Pick a fruit',
            config: const TextDropdownConfig(semanticsLabel: 'Fruit picker'),
            onChanged: (_) {},
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('each item announces its own name, not the dropdown\'s label', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpDropdown(tester);

    await tester.tap(find.byType(FlutterDropdownButton<Fruit>));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Apple'), findsOneWidget);
    expect(find.bySemanticsLabel('Banana'), findsOneWidget);
    expect(find.bySemanticsLabel('Cherry'), findsOneWidget);

    semantics.dispose();
  });

  testWidgets('the button announces the dropdown\'s purpose and its value', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpDropdown(tester, value: banana);

    // The button's descendants merge into one node, so a screen reader reads
    // "Fruit picker, Banana" — what the control is for, then what it holds.
    expect(find.bySemanticsLabel(RegExp('Fruit picker')), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('Banana')),
      findsOneWidget,
      reason: 'the label must not replace the selected value',
    );

    semantics.dispose();
  });

  testWidgets('an unlabelled dropdown announces only its value', (
    tester,
  ) async {
    // Guard, not a regression test: this passed before the fix too. It pins the
    // other half of the fix — wrapping in `Semantics` only when asked to.
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: FlutterDropdownButton<Fruit>.text(
              width: 200,
              items: const [apple, banana],
              value: banana,
              label: (fruit) => fruit.name,
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel('Banana'),
      findsOneWidget,
      reason: 'exactly "Banana" — no stray Semantics node is added',
    );

    semantics.dispose();
  });
}
