import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
// `ScrollGradientOverlay` is internal. The dropdown never swaps its
// `ScrollController`, so `didUpdateWidget`'s swap branch cannot be reached
// through the public API — but it is a real guard, and it is tested here
// rather than deleted or ignored.
import 'package:flutter_dropdown_button/src/widgets/scroll_gradient_overlay.dart';
import 'package:flutter_test/flutter_test.dart';

/// The last two behaviours #56 left uncovered.
///
/// Neither is unreachable. The issue guessed one of them was a `catch` that
/// only fires in production; reading the source rather than trusting the line
/// number showed it is the unwrapped-overflow branch instead.

Widget host(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

void main() {
  group('overflow detection without maxLines', () {
    // `maxLines: null` means `didExceedMaxLines` can never be true, so the
    // widget measures the unconstrained width instead. `softWrap: false` is
    // what makes that measurement meaningful: wrapped text never overruns.
    const unwrapped = TextDropdownConfig(
      maxLines: null,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
    );

    Widget dropdown(String label, {double width = 120}) =>
        FlutterDropdownButton<String>.text(
          width: width,
          items: [label],
          value: label,
          disableWhenSingleItem: false,
          config: unwrapped,
          onChanged: (_) {},
        );

    testWidgets('text wider than the button gets a tooltip', (tester) async {
      await tester.pumpWidget(
        host(dropdown('A preposterously long label that will not fit')),
      );

      expect(find.byType(Tooltip), findsWidgets);
    });

    testWidgets('text that fits gets none', (tester) async {
      await tester.pumpWidget(host(dropdown('Ok', width: 300)));

      expect(find.byType(Tooltip), findsNothing);
    });
  });

  testWidgets('the scroll gradient follows a new ScrollController', (
    tester,
  ) async {
    final first = ScrollController();
    final second = ScrollController();
    addTearDown(first.dispose);
    addTearDown(second.dispose);

    Widget overlay(ScrollController controller) => host(
      SizedBox(
        height: 100,
        width: 200,
        child: ScrollGradientOverlay(
          controller: controller,
          fadeInto: const Color(0xFFFFFFFF),
          height: 20,
          borderRadius: 8,
          child: ListView(
            controller: controller,
            children: List.generate(
              20,
              (i) => SizedBox(height: 40, child: Text('row$i')),
            ),
          ),
        ),
      ),
    );

    await tester.pumpWidget(overlay(first));
    await tester.pumpAndSettle();

    await tester.pumpWidget(overlay(second));
    await tester.pumpAndSettle();

    // The overlay must now listen to `second`. Scrolling it has to light the
    // top fade; were the listener still on `first`, nothing would change.
    second.jumpTo(50);
    await tester.pumpAndSettle();

    final opacities = tester
        .widgetList<AnimatedOpacity>(find.byType(AnimatedOpacity))
        .map((o) => o.opacity)
        .toList();

    expect(opacities.first, 1.0, reason: 'content is hidden above');
  });
}
