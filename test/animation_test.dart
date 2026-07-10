import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
import 'package:flutter_test/flutter_test.dart';

Widget host(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

/// The opacity the menu is drawn at, straight off the widget that applies it.
double menuOpacity(WidgetTester tester) {
  return tester
      .widget<Opacity>(
        find.descendant(
          of: find.byType(Overlay),
          matching: find.byType(Opacity),
        ),
      )
      .opacity;
}

void main() {
  testWidgets('the widget parameter drives the open animation', (tester) async {
    await tester.pumpWidget(
      host(
        FlutterDropdownButton<String>.text(
          items: const ['Apple', 'Banana'],
          hint: 'Pick a fruit',
          animationDuration: const Duration(milliseconds: 1000),
          onChanged: (_) {},
        ),
      ),
    );

    await tester.tap(find.byType(FlutterDropdownButton<String>));
    await tester.pump(); // insert the overlay
    await tester.pump(const Duration(milliseconds: 200));

    expect(
      menuOpacity(tester),
      lessThan(1.0),
      reason: 'a 1000ms animation is only a fifth of the way through',
    );

    await tester.pumpAndSettle();
    expect(menuOpacity(tester), 1.0);
  });
}
