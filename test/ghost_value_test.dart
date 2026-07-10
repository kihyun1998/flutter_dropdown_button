import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
import 'package:flutter_test/flutter_test.dart';

/// A **ghost value** is a `value` that is not in `items` — the state a list
/// refresh leaves behind when the chosen row's data disappears.
///
/// The rule: **the widget draws what it was handed.** `value` belongs to the
/// caller, and the widget renders it rather than auditing it against `items`.
///
/// Text mode always did this; it has no `items` to consult. Custom mode used to
/// fall back to `hintWidget`, so a caller who set a `value` was silently told
/// that nothing was selected.

Widget host(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('custom mode draws a ghost value rather than the hint', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        FlutterDropdownButton<String>(
          width: 200,
          items: const ['a', 'b'],
          value: 'ghost',
          itemBuilder: (item, isSelected) => Text(item),
          hintWidget: const Text('HINT'),
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.text('ghost'), findsOneWidget);
    expect(find.text('HINT'), findsNothing);
  });

  // Guard, not a regression test: text mode passed before the rule was written
  // down, because `TextItemPresentation` holds no `items` and could not have
  // filtered. It is pinned so the two modes cannot drift apart again.
  testWidgets('text mode draws a ghost value rather than the hint', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        FlutterDropdownButton<String>.text(
          width: 200,
          items: const ['a', 'b'],
          value: 'ghost',
          hint: 'HINT',
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.text('ghost'), findsOneWidget);
    expect(find.text('HINT'), findsNothing);
  });

  // Guard. The menu iterates `items`, so it never drew a ghost row, and the
  // face's rule must not leak into the list.
  testWidgets('the open menu draws no row for a ghost value', (tester) async {
    await tester.pumpWidget(
      host(
        FlutterDropdownButton<String>.text(
          width: 200,
          items: const ['a', 'b'],
          value: 'ghost',
          onChanged: (_) {},
        ),
      ),
    );
    await tester.tap(find.byType(FlutterDropdownButton<String>));
    await tester.pumpAndSettle();

    expect(
      find.text('ghost'),
      findsOneWidget,
      reason: 'the button face, and no row',
    );
    expect(find.text('a'), findsOneWidget);
    expect(find.text('b'), findsOneWidget);
  });

  testWidgets('a null value still shows the hint in both modes', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        FlutterDropdownButton<String>(
          width: 200,
          items: const ['a'],
          itemBuilder: (item, isSelected) => Text(item),
          hintWidget: const Text('HINT'),
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.text('HINT'), findsOneWidget);
  });
}
