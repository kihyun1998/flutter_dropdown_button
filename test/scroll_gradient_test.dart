import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
import 'package:flutter_test/flutter_test.dart';

/// Observed at the rendered `LinearGradient`.
///
/// A fade hints at content hidden past an edge. It is opaque **at** that edge,
/// washing the content out into the menu's background, and clears as it moves
/// away. `DropdownScrollTheme.gradientColors` says as much: "the first color
/// appears at the edge, and the last color appears towards the content".

const menuBackground = Color(0xFFFFFFFF);

Future<void> openScrollableMenu(
  WidgetTester tester, {
  List<Color>? gradientColors,
}) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: Center(
        child: FlutterDropdownButton<String>.text(
          width: 200,
          height: 100,
          items: const ['a', 'b', 'c', 'd', 'e', 'f'],
          hint: 'pick',
          theme: DropdownStyleTheme(
            dropdown: const DropdownTheme(backgroundColor: menuBackground),
            scroll: DropdownScrollTheme(
              showScrollGradient: true,
              gradientColors: gradientColors,
            ),
          ),
          onChanged: (_) {},
        ),
      ),
    ),
  ));
  await tester.tap(find.byType(FlutterDropdownButton<String>));
  await tester.pumpAndSettle();
}

/// The two fades, top first, read off the widgets that paint them.
List<LinearGradient> fades(WidgetTester tester) {
  final painted = find.descendant(
    of: find.byType(AnimatedOpacity),
    matching: find.byType(Container),
  );

  final gradients = tester
      .widgetList<Container>(painted)
      .map((c) => c.decoration)
      .whereType<BoxDecoration>()
      .map((d) => d.gradient)
      .whereType<LinearGradient>()
      .toList();

  expect(gradients, hasLength(2), reason: 'a fade at each edge');
  return gradients;
}

void main() {
  testWidgets('the top fade is opaque at the top edge', (tester) async {
    await openScrollableMenu(tester);

    final top = fades(tester).first;
    expect(top.begin, Alignment.topCenter);
    expect(top.colors.first, menuBackground,
        reason: 'the edge the content disappears under');
    expect(top.colors.last.a, 0.0, reason: 'clear over the content');
  });

  testWidgets('the bottom fade is opaque at the bottom edge', (tester) async {
    await openScrollableMenu(tester);

    final bottom = fades(tester).last;
    expect(bottom.begin, Alignment.topCenter);
    expect(bottom.colors.first.a, 0.0, reason: 'clear over the content');
    expect(bottom.colors.last, menuBackground, reason: 'the bottom edge');
  });

  // Guard, not a regression test: this passed before the fix too, and that is
  // the diagnosis — colours the caller supplied were always drawn correctly.
  // Only the default list was built in the wrong order.
  testWidgets('themed colours are taken edge-first, and reversed at the bottom',
      (tester) async {
    const edge = Color(0xFF112233);
    const clear = Color(0x00112233);
    await openScrollableMenu(tester, gradientColors: const [edge, clear]);

    expect(fades(tester).first.colors, const [edge, clear]);
    expect(fades(tester).last.colors, const [clear, edge]);
  });

  // Guard. The notifiers moved into ScrollGradientOverlay; this pins that they
  // still start from the scroll position rather than from `false`.
  testWidgets('only the bottom fade shows before the user scrolls',
      (tester) async {
    await openScrollableMenu(tester);
    await tester.pumpAndSettle();

    final opacities = tester
        .widgetList<AnimatedOpacity>(find.byType(AnimatedOpacity))
        .map((o) => o.opacity)
        .toList();

    expect(opacities, [0.0, 1.0],
        reason: 'nothing is hidden above yet; six items are hidden below');
  });

  testWidgets('disposing the dropdown while the menu is open does not throw',
      (tester) async {
    // The overlay listens to a ScrollController the State owns. Tearing the
    // menu down must happen before that controller is disposed.
    await openScrollableMenu(tester);
    await tester
        .pumpWidget(const MaterialApp(home: Scaffold(body: SizedBox())));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
