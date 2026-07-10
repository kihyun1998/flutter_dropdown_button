import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
import 'package:flutter_test/flutter_test.dart';

Widget host(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

Widget dropdown({Widget? divider}) {
  return FlutterDropdownButton<String>.text(
    width: 200,
    items: const ['Apple', 'Banana', 'Cherry'],
    hint: 'Pick a fruit',
    searchable: true,
    theme: DropdownStyleTheme(search: SearchFieldTheme(divider: divider)),
    onChanged: (_) {},
  );
}

Future<void> openMenu(WidgetTester tester) async {
  await tester.tap(find.byType(FlutterDropdownButton<String>));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a one-pixel divider is accounted for', (tester) async {
    await tester.pumpWidget(host(dropdown(divider: const Divider(height: 1))));
    await openMenu(tester);

    expect(tester.takeException(), isNull);
    expect(
      find.byType(ListView),
      findsNothing,
      reason: 'three items still fit in the 200px budget',
    );
  });

  testWidgets('a divider taller than one pixel is accounted for too', (
    tester,
  ) async {
    // `Divider()` is 16px tall by default — the height most callers get when
    // they reach for one. The overlay must reserve the space it actually
    // occupies, not a hardcoded 1.0.
    await tester.pumpWidget(host(dropdown(divider: const Divider())));
    await openMenu(tester);

    expect(
      tester.takeException(),
      isNull,
      reason: 'the item list must not overflow the overlay',
    );
  });
}
