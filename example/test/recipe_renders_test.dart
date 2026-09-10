// That a recipe actually draws — which no other test in this directory claims.
//
// `recipe_contract_test.dart` reads recipe files as *text*: that one imports no
// shell, and that every `source:` opens. `destinations_test.dart` holds the
// roster as data. `shell_renders_test.dart` pumps the app, but only reads menu
// labels off it — a menu row is drawn from the roster, not from the recipe
// behind it, so a stage that throws on every build still puts its label there.
//
// #143 is what that gap costs. Two recipes rendered wrongly and one of them
// threw a framework assertion on every build, while `flutter analyze`, eleven
// green tests, both contract tests and the API-coverage gate at 100% all
// passed. `example/README.md` already says the gate counts that an argument was
// passed and never what it looked like. This file is the part that looks.

import 'package:example/app/destinations.dart';
import 'package:example/recipes/dismissal_recipe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
import 'package:flutter_example_template/flutter_example_template.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // The roster, not a list written out here. A recipe added to the app is
  // covered by this file the moment it is registered, and a hand-kept list is
  // exactly the fixture that would have let the twelfth recipe in unwatched.
  late DropdownDestinations destinations;
  late List<StageDestination> stages;

  setUp(() {
    destinations = DropdownDestinations();
    stages = destinations.all.whereType<StageDestination>().toList();
  });

  tearDown(() => destinations.dispose());

  testWidgets('every stage in the roster draws without throwing', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    // A guard on the guard: an empty roster would make every loop below pass
    // by never running.
    expect(stages, isNotEmpty);

    for (final destination in stages) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: Builder(builder: destination.stage)),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.takeException(),
        isNull,
        reason: 'stage ${destination.id} threw while drawing',
      );
    }
  });

  testWidgets('every knob pane in the roster draws without throwing', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    expect(stages, isNotEmpty);

    var controls = 0;
    for (final destination in stages) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: Builder(builder: destination.knobs)),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.takeException(),
        isNull,
        reason: 'knobs for ${destination.id} threw while drawing',
      );
      controls += find.byType(SwitchListTile).evaluate().length;
    }

    // Most destinations hand back `SizedBox.shrink()` — deliberately, so the
    // shell draws no empty knob strip. That makes the loop above mostly a sweep
    // over nothing, and a day when *every* pane is empty is a day this test
    // stops asking anything without changing colour. This is the window.
    expect(
      controls,
      greaterThan(0),
      reason: 'no knob pane drew a control; the sweep proved nothing',
    );
  });

  testWidgets('a dropdown given a width is narrower than one told to expand', (
    tester,
  ) async {
    // The Dismissal recipe is the one that holds both shapes at once: a pair
    // inside a `Row` that fill it, and a third inside the `ListView` itself
    // that asks for a width.
    //
    // Asserted as a relationship rather than against the literal 260, because a
    // test that repeats the recipe's own number proves only that two files
    // agree. What is actually claimed is that the width *reached* the button —
    // and a `ListView` hands its children a tight cross-axis constraint, which
    // `Container(width:)` loses to. Before this was fixed the third one
    // measured 1392 against the pair's 688: wider, not narrower.
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: DismissalRecipe())),
    );
    await tester.pumpAndSettle();

    final dropdowns = find.byType(FlutterDropdownButton<String>);
    expect(dropdowns, findsNWidgets(3));

    final expanded = tester.getSize(dropdowns.at(0)).width;
    final sized = tester.getSize(dropdowns.at(2)).width;

    expect(
      tester.getSize(dropdowns.at(1)).width,
      expanded,
      reason: 'the pair share the row, so they are the same width',
    );
    expect(
      sized,
      lessThan(expanded),
      reason: 'the third asks for a width; it must not fill the ListView',
    );
  });

  testWidgets('no dropdown button in the roster is stretched by its parent', (
    tester,
  ) async {
    // The half of #143 that never threw. `expand: true` inside a `Column` drew
    // a button 260 pixels tall with its label floating in the middle, and
    // nothing objected: it is a legal tree that lays out and paints. Only its
    // size says anything is wrong.
    //
    // A button is one row. Measured across the whole roster it is 40 or 50
    // logical pixels, and the two shapes that go wrong here — an `Expanded` in
    // a `Column`, a `height` that reached the button — produced 260 and more.
    // The bound sits well clear of both so that an ordinary restyle does not
    // trip it.
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    var measured = 0;
    for (final destination in stages) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: Builder(builder: destination.stage)),
        ),
      );
      await tester.pumpAndSettle();

      final buttons = find.byWidgetPredicate(_isDropdownButton);
      for (var i = 0; i < buttons.evaluate().length; i++) {
        measured++;
        expect(
          tester.getSize(buttons.at(i)).height,
          lessThanOrEqualTo(120.0),
          reason: 'a dropdown in ${destination.id} is stretched',
        );
      }
    }

    // Without this the sweep passes by finding nothing — and it nearly did.
    // A `find.byType(FlutterDropdownButton<String>)` misses every recipe whose
    // type argument is its own domain type, which is four of them.
    expect(
      measured,
      greaterThanOrEqualTo(12),
      reason: 'the finder stopped seeing most of the roster',
    );
  });
}

/// Generic-blind on purpose: a recipe's type argument is its own domain type,
/// so a `find.byType` naming one only ever sees a fraction of the roster.
bool _isDropdownButton(Widget widget) {
  final name = widget.runtimeType.toString();
  return name.startsWith('FlutterDropdownButton<') ||
      name.startsWith('FlutterMultiSelectDropdown<');
}
