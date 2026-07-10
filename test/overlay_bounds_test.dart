import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
import 'package:flutter_test/flutter_test.dart';

/// Ten items overflow the default 200px budget, so the list renders inside a
/// ListView whose box spans the menu's full width. That box is the menu.
Widget dropdown() {
  return FlutterDropdownButton<String>.text(
    width: 200,
    items: List<String>.generate(10, (i) => 'Item $i'),
    hint: 'Pick an item',
    onChanged: (_) {},
  );
}

Future<Rect> openAndMeasureMenu(WidgetTester tester) async {
  await tester.tap(find.byType(FlutterDropdownButton<String>));
  await tester.pumpAndSettle();
  return tester.getRect(find.byType(ListView));
}

void main() {
  const screenWidth = 800.0;

  // Issue #1 names two layouts: a Row aligned to the end, and an AppBar.
  // Both are covered here. Neither reproduces the reported overflow — the
  // clamp has handled them since 1.4.7. The nested-Overlay case below is the
  // one that was actually broken.

  testWidgets('menu in AppBar actions stays on screen', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Title'), actions: [dropdown()]),
          body: const SizedBox.expand(),
        ),
      ),
    );

    final menu = await openAndMeasureMenu(tester);

    expect(menu.right, lessThanOrEqualTo(screenWidth));
    expect(menu.left, greaterThanOrEqualTo(0));
  });

  testWidgets('menu pinned to the right edge stays on screen', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [dropdown()],
          ),
        ),
      ),
    );

    final menu = await openAndMeasureMenu(tester);

    expect(menu.right, lessThanOrEqualTo(screenWidth));
    expect(menu.left, greaterThanOrEqualTo(0));
  });

  testWidgets('menu inside an offset Overlay stays on screen', (tester) async {
    // The button's position is read against the root view, but the menu is
    // placed against the enclosing Overlay's origin. A panel that owns its
    // own Overlay and starts at x = 400 makes the two disagree.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              Positioned(
                left: 400,
                top: 0,
                width: 400,
                height: 600,
                child: Overlay(
                  initialEntries: [
                    OverlayEntry(
                      builder: (_) => Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [dropdown()],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final menu = await openAndMeasureMenu(tester);

    expect(
      menu.right,
      lessThanOrEqualTo(screenWidth),
      reason: 'menu must not run off the right of the screen',
    );
    expect(menu.left, greaterThanOrEqualTo(0));
  });
}
