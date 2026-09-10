import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
import 'package:flutter_test/flutter_test.dart';

/// What the button box actually promises — and what it does not.
///
/// Nothing here is a regression: `expand` and `width` behave the way any
/// Flutter widget does, and no statement in `lib/` changed to make these pass.
/// They exist because the **dartdoc** was wrong (#145), and a corrected comment
/// with nothing holding it drifts back the first time somebody reads the field
/// name and guesses.
///
/// Each test fails if the old wording is ever made true again: if `expand` is
/// changed to fill the cross axis, or if `width` is changed to win against the
/// parent that contains it.

const items = ['Alpha', 'Bravo', 'Charlie'];

Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

Finder get button => find.byType(FlutterDropdownButton<String>);

/// The `Container` carrying the decoration and the requested width.
Finder get decoratedBox => find.descendant(
  of: button,
  matching: find.byWidgetPredicate(
    (w) => w is Container && w.decoration != null,
  ),
);

void main() {
  group('expand fills the main axis, and the width on offer', () {
    testWidgets('in a Row it takes the width and stays one row tall', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const Row(
            children: [
              FlutterDropdownButton<String>.text(
                items: items,
                expand: true,
                hint: 'Pick',
                onChanged: _ignore,
              ),
            ],
          ),
        ),
      );

      final size = tester.getSize(button);
      expect(size.width, 800.0, reason: 'the Row is the whole surface');
      expect(
        size.height,
        lessThan(120.0),
        reason: 'the cross axis of a Row is the height, and it is not filled',
      );
    });

    testWidgets('in a bounded Column it takes the height', (tester) async {
      // This is the assertion the old wording contradicted. A button that
      // filled its parent's *cross*-axis space would be 400 wide and one row
      // tall here; it is the other way round, and that is the whole of #143.
      await tester.pumpWidget(
        wrap(
          const SizedBox(
            width: 400,
            height: 600,
            child: Column(
              children: [
                FlutterDropdownButton<String>.text(
                  items: items,
                  expand: true,
                  hint: 'Pick',
                  onChanged: _ignore,
                ),
              ],
            ),
          ),
        ),
      );

      final size = tester.getSize(button);
      expect(
        size.height,
        600.0,
        reason: 'a Column\'s main axis is vertical, and expand fills it',
      );
      // And the width too, which is the half that is easy to miss: `expand`
      // also puts the button's content row in `MainAxisSize.max`, so it takes
      // the cross axis on offer as well. In a Column the result is a box
      // filling both directions — "far taller *and wider* than asked for",
      // which is exactly how #143 was first described.
      expect(
        size.width,
        400.0,
        reason: 'expand fills the offered width as well as the main axis',
      );
    });
  });

  group('width is requested, not fixed', () {
    testWidgets('a tight parent overrules it', (tester) async {
      // A `ListView` hands its children a tight cross-axis constraint, and
      // `BoxConstraints.enforce` gives a tight parent the last word. The old
      // wording — "a fixed button width" — promised the opposite.
      await tester.pumpWidget(
        wrap(
          ListView(
            children: const [
              FlutterDropdownButton<String>.text(
                items: items,
                width: 260,
                hint: 'Pick',
                onChanged: _ignore,
              ),
            ],
          ),
        ),
      );

      // Measured on the **decorated box** — the `Container` that carries the
      // width and the border — not on the outer widget. The outer one cannot
      // be anything but 800: a render box must satisfy a tight incoming
      // constraint, so asserting on it would be a claim about Flutter that no
      // implementation of this widget could falsify.
      //
      // The box that is painted can differ, and that is the real question: a
      // widget that loosened its own constraints internally would draw a
      // 260-wide button inside a full-width slot, and the advice below would
      // be unnecessary. It does not, so the value is ignored outright.
      expect(
        tester.getSize(decoratedBox).width,
        800.0,
        reason: 'the width never reaches the painted button either',
      );
    });

    testWidgets('inside an Align it arrives', (tester) async {
      // The remedy the corrected dartdoc names. Asserted so that the advice
      // cannot go stale separately from the claim above it.
      await tester.pumpWidget(
        wrap(
          ListView(
            children: const [
              Align(
                alignment: Alignment.centerLeft,
                child: FlutterDropdownButton<String>.text(
                  items: items,
                  width: 260,
                  hint: 'Pick',
                  onChanged: _ignore,
                ),
              ),
            ],
          ),
        ),
      );

      expect(
        tester.getSize(button).width,
        260.0,
        reason: 'Align lays its child out under constraints.loosen()',
      );
    });

    testWidgets('a loose parent lets the multi-select keep it too', (
      tester,
    ) async {
      // The same claim is documented on the other widget, so it is held on the
      // other widget. A fix applied to one dartdoc and not the other is the
      // ordinary way half a correction ships.
      await tester.pumpWidget(
        wrap(
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FlutterMultiSelectDropdown<String>(
                items: items,
                selected: <String>{},
                labelBuilder: _label,
                width: 318,
                onChanged: _ignoreSet,
              ),
            ],
          ),
        ),
      );

      expect(
        tester.getSize(find.byType(FlutterMultiSelectDropdown<String>)).width,
        318.0,
      );
    });
  });
}

void _ignore(String? _) {}

void _ignoreSet(Set<String> _) {}

String _label(Set<String> chosen) => 'Pick';
