import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
import 'package:flutter_test/flutter_test.dart';

/// A checklist row must announce that it is checked, and must not announce
/// that it is disabled.
///
/// A presentational `Checkbox` — one with `onChanged: null`, so the row's own
/// `InkWell` owns the gesture — carries `isEnabled: false` into the semantics
/// tree. `IgnorePointer` does not strip it; it suppresses hit-testing only.
/// Nothing on screen differs, so this is invisible to a render test.
///
/// `containsSemantics` is deprecated after Flutter 3.40 in favour of
/// `isSemantics`, which does not exist on the 3.32 floor this package declares.
/// `SemanticsData.flagsCollection` has the mirror problem, and `hasFlag` the
/// mirror of that. `matchesSemantics` survives both but insists on describing
/// every flag on the node, so an `InkWell` gaining one would break it.
///
/// So: `containsSemantics`, ignored deliberately. Drop the ignores when the
/// floor moves past `isSemantics`.

MultiSelectPresentation<T> multi<T>({
  required Set<T> selected,
  String Function(T)? label,
  String Function(Set<T>)? labelBuilder,
  Widget Function(T)? itemLeadingBuilder,
  Widget Function(T)? itemTrailingBuilder,
  bool enabled = true,
  TextDropdownConfig config = TextDropdownConfig.defaultConfig,
  DropdownCheckboxTheme checkboxTheme = DropdownCheckboxTheme.defaultTheme,
}) {
  return MultiSelectPresentation<T>(
    selected: selected,
    label: label,
    labelBuilder: labelBuilder ?? (s) => '${s.length} selected',
    config: config,
    tooltipTheme: DropdownTooltipTheme.defaultTheme,
    enabled: enabled,
    checkboxTheme: checkboxTheme,
    itemLeadingBuilder: itemLeadingBuilder,
    itemTrailingBuilder: itemTrailingBuilder,
  );
}

/// The `Checkbox` a row was actually rendered with.
Checkbox renderedBox(WidgetTester tester) =>
    tester.widget<Checkbox>(find.byType(Checkbox).first);

/// The style the face was actually rendered with.
TextStyle? faceStyle(WidgetTester tester) =>
    tester.widget<Text>(find.byType(Text).first).style;

/// Renders [child] the way `DropdownMenuShell` does: inside the row's InkWell,
/// which merges its descendants' semantics into one node.
Future<SemanticsNode> rowNode(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Material(
          child: InkWell(onTap: () {}, child: child),
        ),
      ),
    ),
  );
  return tester.getSemantics(find.byType(InkWell).first);
}

void main() {
  group('semantics', () {
    testWidgets('a chosen row announces that it is checked', (tester) async {
      final handle = tester.ensureSemantics();
      final presentation = multi<String>(selected: {'a'});

      final node = await rowNode(tester, presentation.buildItem('a', true));

      // ignore: deprecated_member_use
      expect(node, containsSemantics(hasCheckedState: true, isChecked: true));
      handle.dispose();
    });

    testWidgets('an unchosen row announces that it is not checked', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final presentation = multi<String>(selected: {'a'});

      final node = await rowNode(tester, presentation.buildItem('b', false));

      // ignore: deprecated_member_use
      expect(node, containsSemantics(hasCheckedState: true, isChecked: false));
      handle.dispose();
    });

    testWidgets('a row never announces that it is disabled', (tester) async {
      // The regression test. A bare `Checkbox(onChanged: null)` — and one
      // wrapped in `IgnorePointer` — both put `isEnabled: false` on the merged
      // row, so a screen reader calls every row of the checklist dimmed.
      final handle = tester.ensureSemantics();
      final presentation = multi<String>(selected: {'a'});

      final node = await rowNode(tester, presentation.buildItem('a', true));

      expect(
        node,
        // ignore: deprecated_member_use
        containsSemantics(hasEnabledState: false),
        reason: 'the box is presentational; the row is what is interactive',
      );
      handle.dispose();
    });
  });

  group('hit testing', () {
    // Guard, not a regression test. It pins the measurement that removed an
    // `IgnorePointer` around the box: a `Checkbox` with `onChanged: null` has
    // no gesture recognizer, so the tap reaches the row beneath it.
    testWidgets('a tap on the box is a tap on the row', (tester) async {
      var taps = 0;
      final presentation = multi<String>(selected: const {});

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Material(
              child: InkWell(
                onTap: () => taps++,
                child: SizedBox(
                  width: 200,
                  height: 48,
                  child: presentation.buildItem('a', false),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      expect(taps, 1);
    });
  });

  group('rows', () {
    testWidgets('the box follows the chosen state', (tester) async {
      final presentation = multi<String>(selected: {'a'});

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                presentation.buildItem('a', true),
                presentation.buildItem('b', false),
              ],
            ),
          ),
        ),
      );

      final boxes = tester.widgetList<Checkbox>(find.byType(Checkbox)).toList();
      expect(boxes.map((b) => b.value), [true, false]);
    });

    testWidgets('a trailing widget is drawn after the label', (tester) async {
      final presentation = multi<String>(
        selected: const {},
        itemTrailingBuilder: (item) => Text('#$item'),
      );

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: presentation.buildItem('a', false))),
      );

      expect(find.text('#a'), findsOneWidget);
    });

    testWidgets('without an itemTrailingBuilder nothing trails', (
      tester,
    ) async {
      final presentation = multi<String>(selected: const {});

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: presentation.buildItem('a', false))),
      );

      expect(find.byType(Checkbox), findsOneWidget);
      expect(find.text('a'), findsOneWidget);
    });

    testWidgets('a leading widget sits between the box and the label', (
      tester,
    ) async {
      // Asserted in screen coordinates rather than by walking the Row's
      // children: where it lands is the contract, the tree is a detail.
      final presentation = multi<String>(
        selected: const {},
        itemLeadingBuilder: (item) => const Icon(Icons.star),
        itemTrailingBuilder: (item) => const Text('12'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              child: presentation.buildItem('a', false),
            ),
          ),
        ),
      );

      final box = tester.getTopLeft(find.byType(Checkbox)).dx;
      final icon = tester.getTopLeft(find.byType(Icon)).dx;
      final label = tester.getTopLeft(find.text('a')).dx;
      final count = tester.getTopLeft(find.text('12')).dx;

      expect(box, lessThan(icon));
      expect(icon, lessThan(label));
      expect(label, lessThan(count));
    });

    testWidgets('without an itemLeadingBuilder nothing leads', (tester) async {
      final presentation = multi<String>(selected: const {});

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: presentation.buildItem('a', false))),
      );

      expect(find.byType(Icon), findsNothing);
    });
  });

  group('checkbox theme', () {
    // Pump a row and read the Checkbox it built. The box is `onChanged: null`,
    // so Flutter resolves its colours in the `disabled` state — asserting the
    // widget's own `fillColor` against `{disabled, selected}` is what proves the
    // accent survives, since a raw `activeColor` would be dropped there.
    Future<void> pumpRow(WidgetTester tester, MultiSelectPresentation p) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: p.buildItem('a', true))),
      );
    }

    testWidgets('an unthemed row leaves every checkbox slot null', (
      tester,
    ) async {
      await pumpRow(tester, multi<String>(selected: {'a'}));

      final box = renderedBox(tester);
      expect(box.fillColor, isNull, reason: 'defer to ambient CheckboxTheme');
      expect(box.checkColor, isNull);
      expect(box.side, isNull);
      expect(box.shape, isNull);
      expect(box.materialTapTargetSize, isNull);
      expect(box.visualDensity, isNull);
      expect(box.mouseCursor, isNull);
    });

    testWidgets('activeColor reaches the box and holds in the disabled state', (
      tester,
    ) async {
      await pumpRow(
        tester,
        multi<String>(
          selected: {'a'},
          checkboxTheme: const DropdownCheckboxTheme(
            activeColor: Color(0xFF00AA88),
          ),
        ),
      );

      final fill = renderedBox(tester).fillColor;
      expect(fill, isNotNull);
      expect(
        fill!.resolve({WidgetState.disabled, WidgetState.selected}),
        const Color(0xFF00AA88),
        reason: 'the state the presentational box is actually in',
      );
    });

    testWidgets('checkColor, side and shape are handed to the box', (
      tester,
    ) async {
      const side = BorderSide(color: Color(0xFFDDDDDD), width: 2);
      const shape = RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(6)),
      );
      await pumpRow(
        tester,
        multi<String>(
          selected: {'a'},
          checkboxTheme: const DropdownCheckboxTheme(
            checkColor: Color(0xFFFFFFFF),
            side: side,
            shape: shape,
          ),
        ),
      );

      final box = renderedBox(tester);
      expect(box.checkColor, const Color(0xFFFFFFFF));
      expect(box.side, side);
      expect(box.shape, shape);
    });
  });

  group('the button face', () {
    testWidgets('is whatever labelBuilder makes of the chosen set', (
      tester,
    ) async {
      final presentation = multi<String>(
        selected: {'a', 'b'},
        labelBuilder: (s) => '${s.length} chosen',
      );

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: presentation.buildSelected())),
      );

      expect(find.text('2 chosen'), findsOneWidget);
    });

    testWidgets('a semanticsLabel describes the control', (tester) async {
      final handle = tester.ensureSemantics();
      final presentation = MultiSelectPresentation<String>(
        selected: const {},
        labelBuilder: (s) => 'All',
        label: null,
        config: const TextDropdownConfig(semanticsLabel: 'OS filter'),
        tooltipTheme: DropdownTooltipTheme.defaultTheme,
        enabled: true,
      );

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: presentation.buildSelected())),
      );

      expect(find.bySemanticsLabel(RegExp('OS filter')), findsOneWidget);
      handle.dispose();
    });

    testWidgets('a disabled face merges the disabled style into the base', (
      tester,
    ) async {
      final presentation = multi<String>(
        selected: const {},
        enabled: false,
        config: const TextDropdownConfig(
          textStyle: TextStyle(fontSize: 20, color: Colors.black),
          disabledTextStyle: TextStyle(color: Colors.grey),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: presentation.buildSelected())),
      );

      final style = faceStyle(tester)!;
      expect(style.color, Colors.grey, reason: 'the disabled style wins');
      expect(style.fontSize, 20, reason: 'and the base style survives it');
    });

    testWidgets('a disabled face with no base style takes the disabled one', (
      tester,
    ) async {
      final presentation = multi<String>(
        selected: const {},
        enabled: false,
        config: const TextDropdownConfig(
          disabledTextStyle: TextStyle(color: Colors.grey),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: presentation.buildSelected())),
      );

      expect(faceStyle(tester)!.color, Colors.grey);
    });

    testWidgets('an enabled face ignores the disabled style', (tester) async {
      final presentation = multi<String>(
        selected: const {},
        config: const TextDropdownConfig(
          textStyle: TextStyle(color: Colors.black),
          disabledTextStyle: TextStyle(color: Colors.grey),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: presentation.buildSelected())),
      );

      expect(faceStyle(tester)!.color, Colors.black);
    });
  });

  group('pure', () {
    test('contentAlignment follows the configured textAlign', () {
      expect(
        multi<String>(selected: const {}).contentAlignment,
        Alignment.centerLeft,
      );
    });

    test('the default filter matches the label, case-insensitively', () {
      final filter = multi<String>(selected: const {}).defaultSearchFilter!;

      expect(filter('Banana', 'NAN'), isTrue);
      expect(filter('Apple', 'ban'), isFalse);
    });

    test('a String is its own label', () {
      expect(multi<String>(selected: const {}).labelOf('Apple'), 'Apple');
    });

    test('any other T goes through the callback', () {
      final presentation = multi<_Fruit>(
        selected: const {},
        label: (f) => f.name,
      );

      // ignore: prefer_const_constructors
      expect(presentation.labelOf(_Fruit('Kiwi')), 'Kiwi');
    });

    test('a non-String T without a label fails at construction', () {
      expect(
        () => multi<_Fruit>(selected: const {}),
        throwsAssertionError,
        reason: 'rows render as text, so it must know how to make one',
      );
    });
  });
}

class _Fruit {
  const _Fruit(this.name);
  final String name;
}
