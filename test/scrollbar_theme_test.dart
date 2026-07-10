import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> openMenu(WidgetTester tester, DropdownScrollTheme scroll) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: FlutterDropdownButton<String>.text(
            width: 200,
            height: 100,
            items: const ['a', 'b', 'c', 'd', 'e', 'f'],
            hint: 'pick',
            theme: DropdownStyleTheme(scroll: scroll),
            onChanged: (_) {},
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.byType(FlutterDropdownButton<String>));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a visible track does not crash the menu', (tester) async {
    // Flutter asserts that a track cannot be drawn without a thumb. Asking for
    // a visible track and a custom thumb width is the documented way to use
    // this theme, and it threw on open.
    await openMenu(
      tester,
      const DropdownScrollTheme(thumbWidth: 6, trackVisibility: true),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('a'), findsOneWidget, reason: 'the menu opened');
  });

  testWidgets('an unstyled scroll theme leaves the ambient ScrollbarTheme alone', (
    tester,
  ) async {
    // Guard, not a regression test: this passed before the rewrite too. It pins
    // the reason `overridesScrollbarTheme` exists — `ScrollbarTheme` replaces
    // the ambient one rather than merging with it, so wrapping unconditionally
    // would silence an app-wide theme.
    await openMenu(tester, const DropdownScrollTheme());

    expect(find.byType(ScrollbarTheme), findsNothing);
    expect(tester.takeException(), isNull);
  });

  // Guard. Passed before the rewrite; pins that moving colour resolution into
  // `DropdownScrollTheme.resolve()` did not drop it on the floor.
  testWidgets('a themed colour reaches the scrollbar', (tester) async {
    await openMenu(tester, const DropdownScrollTheme(thumbColor: Colors.red));

    final data = tester
        .widget<ScrollbarTheme>(find.byType(ScrollbarTheme))
        .data;
    expect(data.thumbColor!.resolve({}), Colors.red);
    expect(tester.takeException(), isNull);
  });

  // Guard. `thumbWidth` works and always did; only `trackWidth` never did.
  testWidgets('a custom thumb width reaches the scrollbar', (tester) async {
    await openMenu(tester, const DropdownScrollTheme(thumbWidth: 6));

    expect(tester.widget<Scrollbar>(find.byType(Scrollbar)).thickness, 6);
    expect(tester.takeException(), isNull);
  });
}
