import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
import 'package:flutter_test/flutter_test.dart';

/// Bare anchor mode (#75): the caller draws the anchor, the shell drops the
/// button box and hangs the overlay off the caller's widget instead.

Widget host(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

void main() {
  group('single-select bare anchor', () {
    testWidgets('draws the caller widget and opens the menu on tap', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          FlutterDropdownButton<String>.text(
            items: const ['Apple', 'Banana', 'Cherry'],
            value: 'Apple',
            onChanged: (_) {},
            anchorBuilder: (context, isOpen) => const Text('BARE-ANCHOR'),
          ),
        ),
      );

      // The caller's widget is the anchor.
      expect(find.text('BARE-ANCHOR'), findsOneWidget);
      // The menu is closed, and with no button box there is no ink well yet.
      expect(find.byType(InkWell), findsNothing);

      await tester.tap(find.text('BARE-ANCHOR'));
      await tester.pumpAndSettle();

      // Tapping the bare anchor opened the same anchored menu.
      expect(find.text('Banana'), findsOneWidget);
    });

    testWidgets('no button chrome: the anchor has no decorated box', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          FlutterDropdownButton<String>.text(
            items: const ['Apple', 'Banana'],
            value: 'Apple',
            onChanged: (_) {},
            anchorBuilder: (context, isOpen) => const Text('BARE-ANCHOR'),
          ),
        ),
      );

      // The normal button wraps its face in a Container carrying a
      // BoxDecoration; the bare anchor must not. Nothing between the anchor's
      // text and the app scaffold paints a decoration of its own.
      final decorated = find.ancestor(
        of: find.text('BARE-ANCHOR'),
        matching: find.byWidgetPredicate(
          (w) => w is Container && w.decoration != null,
        ),
      );
      expect(decorated, findsNothing);
    });

    testWidgets('hands the builder whether the menu is open', (tester) async {
      final seen = <bool>[];
      await tester.pumpWidget(
        host(
          FlutterDropdownButton<String>.text(
            items: const ['Apple', 'Banana'],
            value: 'Apple',
            onChanged: (_) {},
            anchorBuilder: (context, isOpen) {
              seen.add(isOpen);
              return const Text('BARE-ANCHOR');
            },
          ),
        ),
      );

      expect(seen.last, isFalse, reason: 'starts closed');

      await tester.tap(find.text('BARE-ANCHOR'));
      await tester.pumpAndSettle();
      expect(seen.last, isTrue, reason: 'open flips it true');

      await tester.tap(find.text('Banana'));
      await tester.pumpAndSettle();
      expect(seen.last, isFalse, reason: 'a selection closes it again');
    });

    testWidgets('minMenuWidth widens the menu past the compact anchor', (
      tester,
    ) async {
      // The menu takes its width from the anchor, and a bare anchor is tiny by
      // design; minMenuWidth is a menu width (allowed in bare mode) that gives
      // the menu a usable width of its own. This is the lever that keeps a
      // checklist's rows from overflowing under an `[All ▾]`-wide anchor.
      await tester.pumpWidget(
        host(
          FlutterDropdownButton<String>.text(
            items: List<String>.generate(12, (i) => 'Item $i'),
            value: 'Item 0',
            onChanged: (_) {},
            minMenuWidth: 200,
            anchorBuilder: (context, isOpen) => const Text('All'),
          ),
        ),
      );

      final anchorWidth = tester.getSize(find.text('All')).width;
      expect(anchorWidth, lessThan(120), reason: 'the anchor is compact');

      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      // A long list lays out in a ListView, whose width is the menu's.
      final menuWidth = tester.getSize(find.byType(ListView)).width;
      expect(menuWidth, greaterThan(150));
      expect(
        menuWidth,
        lessThan(205),
        reason: 'driven by minMenuWidth, not the screen',
      );
    });

    testWidgets('a disabled bare anchor does not open', (tester) async {
      await tester.pumpWidget(
        host(
          FlutterDropdownButton<String>.text(
            items: const ['Apple', 'Banana'],
            value: 'Apple',
            enabled: false,
            onChanged: (_) {},
            anchorBuilder: (context, isOpen) => const Text('BARE-ANCHOR'),
          ),
        ),
      );

      await tester.tap(find.text('BARE-ANCHOR'));
      await tester.pumpAndSettle();

      expect(find.text('Banana'), findsNothing);
    });

    testWidgets('the anchor is announced as a button', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(
          FlutterDropdownButton<String>.text(
            items: const ['Apple', 'Banana'],
            value: 'Apple',
            onChanged: (_) {},
            anchorBuilder: (context, isOpen) => const Text('BARE-ANCHOR'),
          ),
        ),
      );

      expect(
        tester.getSemantics(find.text('BARE-ANCHOR')),
        matchesSemantics(
          label: 'BARE-ANCHOR',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('combining a button-box param with anchorBuilder asserts', (
      tester,
    ) async {
      expect(
        () => FlutterDropdownButton<String>.text(
          items: const ['Apple'],
          onChanged: (_) {},
          width: 200,
          anchorBuilder: (context, isOpen) => const Text('BARE-ANCHOR'),
        ),
        throwsAssertionError,
      );
    });

    testWidgets('bare mode composes with the default (custom) constructor', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          FlutterDropdownButton<String>(
            items: const ['Apple', 'Banana'],
            value: 'Apple',
            itemBuilder: (item, isSelected) => Text(item),
            onChanged: (_) {},
            anchorBuilder: (context, isOpen) => const Text('BARE-ANCHOR'),
          ),
        ),
      );

      await tester.tap(find.text('BARE-ANCHOR'));
      await tester.pumpAndSettle();

      expect(find.text('Banana'), findsOneWidget);
    });
  });

  group('multi-select bare anchor', () {
    testWidgets('draws the caller widget and opens the checklist on tap', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          FlutterMultiSelectDropdown<String>(
            items: const ['Apple', 'Banana', 'Cherry'],
            selected: const {'Apple'},
            onChanged: (_) {},
            labelBuilder: (s) => s.isEmpty ? 'All' : '${s.length}',
            anchorBuilder: (context, isOpen) => const Text('BARE-ANCHOR'),
          ),
        ),
      );

      expect(find.byType(Checkbox), findsNothing);

      await tester.tap(find.text('BARE-ANCHOR'));
      await tester.pumpAndSettle();

      // The checklist opened: a box per row.
      expect(find.byType(Checkbox), findsNWidgets(3));
    });

    testWidgets('combining a button-box param with anchorBuilder asserts', (
      tester,
    ) async {
      expect(
        () => FlutterMultiSelectDropdown<String>(
          items: const ['Apple'],
          selected: const {},
          onChanged: (_) {},
          labelBuilder: (s) => 'All',
          expand: true,
          anchorBuilder: (context, isOpen) => const Text('BARE-ANCHOR'),
        ),
        throwsAssertionError,
      );
    });
  });
}
