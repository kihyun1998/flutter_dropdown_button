import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
import 'package:flutter_test/flutter_test.dart';

/// Scrolling the content behind an open menu dismisses it (#103).
///
/// The menu is placed once, when it opens, and never re-measured — so an anchor
/// that scrolls away leaves the menu floating at coordinates that no longer
/// point at anything. Rather than track the anchor every frame (an order of
/// magnitude more expensive, and out of this issue's scope), the menu closes.
///
/// Most of what is pinned here is what the dismissal must *not* touch: the
/// menu's own scrolling, and a page with no scrollable in it at all.

Widget page({
  required ScrollController scroll,
  int items = 2,
  bool enabled = true,
  bool dark = false,
}) => MaterialApp(
  theme: dark ? ThemeData.dark() : ThemeData.light(),
  home: Scaffold(
    body: ListView(
      controller: scroll,
      children: [
        const SizedBox(height: 40),
        FlutterDropdownButton<String>.text(
          width: 150,
          items: List.generate(items, (i) => 'item $i'),
          hint: 'anchor',
          enabled: enabled,
          onChanged: (_) {},
        ),
        ...List.generate(40, (i) => SizedBox(height: 50, child: Text('bg$i'))),
      ],
    ),
  ),
);

bool menuOpen() => find.text('item 1').evaluate().isNotEmpty;
Finder anchor() => find.byType(FlutterDropdownButton<String>);

void main() {
  group('the content behind an open menu scrolls', () {
    testWidgets('a drag dismisses it', (tester) async {
      final scroll = ScrollController();
      await tester.pumpWidget(page(scroll: scroll));
      await tester.tap(anchor());
      await tester.pumpAndSettle();
      expect(menuOpen(), isTrue);

      // Well below the menu, on the background.
      await tester.dragFrom(const Offset(400, 500), const Offset(0, -180));
      await tester.pumpAndSettle();

      expect(menuOpen(), isFalse);
      expect(
        scroll.offset,
        greaterThan(0),
        reason: 'the background still scrolled — dismissal does not eat it',
      );
    });

    testWidgets('a mouse wheel dismisses it too', (tester) async {
      // Measured before this: the wheel produced the identical detachment on
      // desktop, so a touch-only fix would have left half the platforms broken.
      final scroll = ScrollController();
      await tester.pumpWidget(page(scroll: scroll));
      await tester.tap(anchor());
      await tester.pumpAndSettle();
      expect(menuOpen(), isTrue);

      final pointer = TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(pointer.hover(const Offset(400, 500)));
      await tester.sendEventToBinding(pointer.scroll(const Offset(0, 160)));
      await tester.pumpAndSettle();

      expect(menuOpen(), isFalse);
    });

    testWidgets('an outer list dismisses it, not only the nearest one', (
      tester,
    ) async {
      // The anchor sits in an inner list; the user scrolls the outer one.
      // Subscribing only to the nearest scrollable leaves the menu stale here.
      final outer = ScrollController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              controller: outer,
              children: [
                const SizedBox(height: 40),
                SizedBox(
                  height: 220,
                  child: ListView(
                    children: [
                      FlutterDropdownButton<String>.text(
                        width: 150,
                        items: const ['item 0', 'item 1'],
                        hint: 'anchor',
                        onChanged: (_) {},
                      ),
                      ...List.generate(
                        6,
                        (i) => SizedBox(height: 40, child: Text('in$i')),
                      ),
                    ],
                  ),
                ),
                ...List.generate(
                  40,
                  (i) => SizedBox(height: 50, child: Text('out$i')),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.tap(anchor());
      await tester.pumpAndSettle();
      expect(menuOpen(), isTrue);

      await tester.dragFrom(const Offset(400, 500), const Offset(0, -150));
      await tester.pumpAndSettle();

      expect(menuOpen(), isFalse);
      expect(outer.offset, greaterThan(0));
    });

    testWidgets('a programmatic jump dismisses it', (tester) async {
      // `jumpTo` moves the content without ever reporting a scroll *activity*:
      // it goes idle, forces the pixels, and goes idle again. Watching activity
      // instead of position therefore misses the most ordinary programmatic
      // scroll there is — including `Scrollable.ensureVisible`, whose duration
      // defaults to zero and which takes this same branch.
      final scroll = ScrollController();
      await tester.pumpWidget(page(scroll: scroll));
      await tester.tap(anchor());
      await tester.pumpAndSettle();
      expect(menuOpen(), isTrue);

      scroll.jumpTo(300);
      await tester.pumpAndSettle();

      expect(menuOpen(), isFalse);
    });

    testWidgets('it survives the scroll position being replaced', (
      tester,
    ) async {
      // A Scrollable rebuilds its position from `didChangeDependencies` — a
      // theme change, a devicePixelRatio change, dragging a window between
      // monitors. The old position is disposed and a new one installed, so a
      // subscription taken once at open time is left holding a dead object and
      // the dismissal silently stops working for the rest of the menu's life.
      final scroll = ScrollController();
      await tester.pumpWidget(page(scroll: scroll));
      await tester.tap(anchor());
      await tester.pumpAndSettle();
      expect(menuOpen(), isTrue);

      await tester.pumpWidget(page(scroll: scroll, dark: true));
      await tester.pumpAndSettle();
      expect(
        menuOpen(),
        isTrue,
        reason: 'the theme change alone closes nothing',
      );

      await tester.dragFrom(const Offset(400, 500), const Offset(0, -180));
      await tester.pumpAndSettle();

      expect(menuOpen(), isFalse, reason: 'and the dismissal is still alive');
    });
  });

  group('what the dismissal must not touch', () {
    testWidgets('the menu scrolls itself without closing', (tester) async {
      // The trap this design exists to avoid: subscribe from the wrong context
      // and a long menu closes the moment the user scrolls it.
      final scroll = ScrollController();
      await tester.pumpWidget(page(scroll: scroll, items: 30));
      await tester.tap(anchor());
      await tester.pumpAndSettle();
      expect(menuOpen(), isTrue);

      // The page's own ListView is *also* a descendant of the Overlay — a
      // MaterialApp nests the whole app in one — so reach the menu's list
      // through a row that only exists inside it. Only the visible rows are
      // built, so anchor on one that is on screen before the drag.
      final list = find.ancestor(
        of: find.text('item 1'),
        matching: find.byType(Scrollable),
      );
      await tester.drag(list.first, const Offset(0, -80));
      await tester.pumpAndSettle();

      // Not `menuOpen()`: the drag carries 'item 1' out of view, so that marker
      // would go false while the menu is still up. Any row will do.
      expect(
        find.textContaining('item ').evaluate(),
        isNotEmpty,
        reason: 'its own scroll is not an outside one',
      );
      expect(scroll.offset, 0, reason: 'and it did not leak to the page');
    });

    testWidgets('a page with no scrollable still opens and dismisses', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: FlutterDropdownButton<String>.text(
                width: 150,
                items: const ['item 0', 'item 1'],
                hint: 'anchor',
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.tap(anchor());
      await tester.pumpAndSettle();
      expect(menuOpen(), isTrue);

      await tester.tapAt(const Offset(20, 560));
      await tester.pumpAndSettle();
      expect(menuOpen(), isFalse, reason: 'the outside tap still works');
    });

    testWidgets('scrolling with no menu open changes nothing', (tester) async {
      final scroll = ScrollController();
      await tester.pumpWidget(page(scroll: scroll));

      await tester.dragFrom(const Offset(400, 500), const Offset(0, -180));
      await tester.pumpAndSettle();

      expect(scroll.offset, greaterThan(0));
      expect(menuOpen(), isFalse);

      // And the anchor still works afterwards. Put it back on screen first —
      // the drag above carried it off the top.
      scroll.jumpTo(0);
      await tester.pumpAndSettle();
      await tester.tap(anchor());
      await tester.pumpAndSettle();
      expect(menuOpen(), isTrue);
    });
  });
}
