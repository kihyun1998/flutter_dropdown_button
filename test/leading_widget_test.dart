import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
import 'package:flutter_test/flutter_test.dart';

/// `leading` and `selectedLeading` are reachable from the public API and were
/// covered by nothing. #50 changed where their height comes from — a fully
/// resolved `ResolvedButtonStyle` became `DropdownButtonTheme.resolvedIconSize` —
/// with no test watching.

Widget host(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

/// The `SizedBox` the leading widget is centred in.
SizedBox boxAround(WidgetTester tester, Finder leading) =>
    tester.widget<SizedBox>(
      find.ancestor(of: leading, matching: find.byType(SizedBox)).first,
    );

/// The `Padding` that separates the leading widget from the text.
Padding padAround(WidgetTester tester, Finder leading) =>
    tester.widget<Padding>(
      find.ancestor(of: leading, matching: find.byType(Padding)).first,
    );

Widget dropdown({
  Widget? leading,
  Widget? selectedLeading,
  EdgeInsets? leadingPadding,
  String? value,
  double? iconSize,
}) {
  return FlutterDropdownButton<String>.text(
    width: 240,
    items: const ['Apple', 'Banana'],
    value: value,
    hint: 'Pick a fruit',
    leading: leading,
    selectedLeading: selectedLeading,
    leadingPadding: leadingPadding,
    theme: DropdownStyleTheme(button: DropdownButtonTheme(iconSize: iconSize)),
    onChanged: (_) {},
  );
}

void main() {
  testWidgets("a leading widget is sized to the theme's icon size", (
    tester,
  ) async {
    await tester.pumpWidget(
      host(dropdown(leading: const Icon(Icons.eco), value: 'Apple')),
    );

    expect(
      boxAround(tester, find.byIcon(Icons.eco)).height,
      DropdownButtonTheme.defaultIconSize,
    );
  });

  testWidgets('a custom icon size resizes the leading widget too', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        dropdown(leading: const Icon(Icons.eco), value: 'Apple', iconSize: 40),
      ),
    );

    expect(boxAround(tester, find.byIcon(Icons.eco)).height, 40);
  });

  testWidgets('every item row gets the leading widget', (tester) async {
    await tester.pumpWidget(host(dropdown(leading: const Icon(Icons.eco))));

    await tester.tap(find.byType(FlutterDropdownButton<String>));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.eco), findsNWidgets(2), reason: 'Apple, Banana');
  });

  testWidgets('the hint never takes a leading widget', (tester) async {
    await tester.pumpWidget(host(dropdown(leading: const Icon(Icons.eco))));

    expect(
      find.byIcon(Icons.eco),
      findsNothing,
      reason: 'nothing is selected, so the button shows only its hint',
    );
  });

  testWidgets('selectedLeading wins on the button face', (tester) async {
    await tester.pumpWidget(
      host(
        dropdown(
          leading: const Icon(Icons.eco),
          selectedLeading: const Icon(Icons.star),
          value: 'Apple',
        ),
      ),
    );

    expect(find.byIcon(Icons.star), findsOneWidget);
    expect(find.byIcon(Icons.eco), findsNothing);
  });

  testWidgets('selectedLeading does not reach the item rows', (tester) async {
    await tester.pumpWidget(
      host(
        dropdown(
          leading: const Icon(Icons.eco),
          selectedLeading: const Icon(Icons.star),
          value: 'Apple',
        ),
      ),
    );

    await tester.tap(find.byType(FlutterDropdownButton<String>));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.star), findsOneWidget, reason: 'the button only');
    expect(find.byIcon(Icons.eco), findsNWidgets(2), reason: 'both rows');
  });

  testWidgets('leadingPadding defaults to eight pixels on the right', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(dropdown(leading: const Icon(Icons.eco), value: 'Apple')),
    );

    expect(
      padAround(tester, find.byIcon(Icons.eco)).padding,
      const EdgeInsets.only(right: 8.0),
    );
  });

  testWidgets('a themed leadingPadding replaces the default', (tester) async {
    await tester.pumpWidget(
      host(
        dropdown(
          leading: const Icon(Icons.eco),
          leadingPadding: const EdgeInsets.all(4),
          value: 'Apple',
        ),
      ),
    );

    expect(
      padAround(tester, find.byIcon(Icons.eco)).padding,
      const EdgeInsets.all(4),
    );
  });
}
