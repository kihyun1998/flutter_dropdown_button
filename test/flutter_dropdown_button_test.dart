import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wraps the dropdown in just enough app to give it an [Overlay].
Widget host(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: Center(child: child),
    ),
  );
}

Future<void> openDropdown(WidgetTester tester) async {
  await tester.tap(find.byType(FlutterDropdownButton<String>));
  await tester.pumpAndSettle();
}

void main() {
  group('searchable overlay sizing', () {
    // The overlay lays its items out in a Column when they all fit, and in a
    // ListView when they do not. The presence of a ListView is therefore an
    // observable stand-in for "this dropdown scrolls".

    testWidgets('a short list does not scroll just because search is on',
        (tester) async {
      await tester.pumpWidget(
        host(
          FlutterDropdownButton<String>.text(
            items: const ['Apple', 'Banana', 'Cherry'],
            hint: 'Pick a fruit',
            searchable: true,
            onChanged: (_) {},
          ),
        ),
      );

      await openDropdown(tester);

      expect(find.byType(TextField), findsOneWidget, reason: 'search is on');
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('a long list still scrolls', (tester) async {
      await tester.pumpWidget(
        host(
          FlutterDropdownButton<String>.text(
            items: List<String>.generate(10, (i) => 'Item $i'),
            hint: 'Pick an item',
            searchable: true,
            onChanged: (_) {},
          ),
        ),
      );

      await openDropdown(tester);

      expect(find.byType(ListView), findsOneWidget);
    });
  });
}
