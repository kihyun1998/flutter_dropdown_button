import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
import 'package:flutter_test/flutter_test.dart';

/// Opening a long menu with a value already chosen scrolls that value into
/// view. `scrollToSelectedDuration` decides whether it jumps or glides.

const items = [
  'i0',
  'i1',
  'i2',
  'i3',
  'i4',
  'i5',
  'i6',
  'i7',
  'i8',
  'i9',
  'i10',
  'i11',
];

Widget host(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

Widget dropdown({
  String? value,
  bool scrollToSelectedItem = true,
  Duration? duration,
}) {
  return FlutterDropdownButton<String>.text(
    width: 200,
    height: 150,
    items: items,
    value: value,
    hint: 'Pick one',
    scrollToSelectedItem: scrollToSelectedItem,
    scrollToSelectedDuration: duration,
    onChanged: (_) {},
  );
}

ScrollController menuController(WidgetTester tester) =>
    tester.widget<ListView>(find.byType(ListView)).controller!;

Future<void> open(WidgetTester tester) async {
  await tester.tap(find.byType(FlutterDropdownButton<String>).first);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a menu opened with no value stays at the top', (tester) async {
    await tester.pumpWidget(host(dropdown()));
    await open(tester);

    expect(menuController(tester).offset, 0);
  });

  testWidgets('the chosen item is scrolled into view', (tester) async {
    await tester.pumpWidget(host(dropdown(value: 'i10')));
    await open(tester);

    expect(
      menuController(tester).offset,
      greaterThan(0),
      reason: 'the tenth row is far below the fold',
    );
  });

  testWidgets('scrollToSelectedItem: false leaves the menu at the top', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(dropdown(value: 'i10', scrollToSelectedItem: false)),
    );
    await open(tester);

    expect(menuController(tester).offset, 0);
  });

  testWidgets('a value absent from items scrolls nowhere', (tester) async {
    await tester.pumpWidget(host(dropdown(value: 'not in the list')));
    await open(tester);

    expect(menuController(tester).offset, 0);
  });

  testWidgets('the offset is clamped to the end of the list', (tester) async {
    await tester.pumpWidget(host(dropdown(value: 'i11')));
    await open(tester);

    final controller = menuController(tester);
    expect(
      controller.offset,
      controller.position.maxScrollExtent,
      reason: 'the last row cannot scroll past the bottom',
    );
  });

  /// Opens the menu and stops fifty milliseconds in — before a one-second
  /// scroll animation could have finished, but long after a jump would have.
  Future<double> offsetShortlyAfterOpening(
    WidgetTester tester,
    Duration? duration,
  ) async {
    await tester.pumpWidget(host(dropdown(value: 'i11', duration: duration)));

    await tester.tap(find.byType(FlutterDropdownButton<String>).first);
    await tester.pump(); // insert the overlay
    await tester.pump(); // run the post-frame callback
    await tester.pump(const Duration(milliseconds: 50));

    return menuController(tester).offset;
  }

  testWidgets('with no duration the menu is already where it belongs', (
    tester,
  ) async {
    final offset = await offsetShortlyAfterOpening(tester, null);

    expect(offset, greaterThan(0), reason: 'jumpTo lands in one frame');
    await tester.pumpAndSettle();
  });

  testWidgets('a duration makes it glide, so it is not there yet', (
    tester,
  ) async {
    final partway = await offsetShortlyAfterOpening(
      tester,
      const Duration(seconds: 1),
    );

    await tester.pumpAndSettle();
    final settled = menuController(tester).offset;

    expect(settled, greaterThan(0));
    expect(
      partway,
      lessThan(settled),
      reason: 'fifty milliseconds into a one-second glide',
    );
  });
}
