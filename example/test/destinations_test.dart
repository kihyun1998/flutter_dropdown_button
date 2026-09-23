// What this app asks the shell to show, held at the one seam that is ours.
//
// `DropdownDestinations` takes no `BuildContext` and touches no infrastructure,
// which is why it can be tested as a plain object. The shell's own widgets —
// `ShellPage`, the menu, the Code pane — are `flutter_example_template`'s and
// are tested there; re-testing them here would mean maintaining two answers to
// one question.

import 'package:example/app/destinations.dart';
import 'package:example/app/recipe_knobs.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_example_template/flutter_example_template.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DropdownDestinations', () {
    test('all is the same list on every read', () {
      final destinations = DropdownDestinations();

      // `identical`, not `equals`. A getter returning a fresh list each call
      // would satisfy `equals` forever while breaking the contract entirely:
      // `ShellMenu` and the stage walk this on the same frame, and a list
      // rebuilt per call rebuilds every destination's builder with it.
      //
      // Nothing else can catch this. A getter is legal Dart that compiles,
      // runs, and looks right at the call site.
      expect(identical(destinations.all, destinations.all), isTrue);

      destinations.dispose();
    });

    test('two instances do not share one list', () {
      // The other half of the contract above: the list is per-instance,
      // because the state behind it will be.
      //
      // `static` is *not* the shape this guards against — measured, it does not
      // compile at all: "Can't declare a member that conflicts with an
      // inherited one." What it guards against is the shape the compiler does
      // allow, and which satisfies the identity test above while being wrong —
      // one shared list assigned to the instance field.
      final first = DropdownDestinations();
      final second = DropdownDestinations();

      expect(identical(first.all, second.all), isFalse);

      first.dispose();
      second.dispose();
    });

    test('the menu shows exactly the roster this slice declares', () {
      final destinations = DropdownDestinations();

      expect(destinations.all.map((d) => d.id).toList(), [
        'basic',
        'domain-type',
        'multi-select',
        'search',
        'custom-items',
        'text-config',
        'button-theme',
        'menu-theme',
        'wheel-scroll',
        'geometry',
        'states',
        'dismissal',
        'bare-anchor',
        'build-your-own',
        'overlay-lifetime',
      ]);

      destinations.dispose();
    });

    test('a source is claimed by recipes and by nothing else', () {
      // `ShellPage` reads the Code pane's file out of the asset bundle, and the
      // pane is the affordance of the pasteable claim rather than a general
      // source viewer. A page that carried a `source:` would be offering to be
      // pasted, which none of them can be.
      final destinations = DropdownDestinations();

      for (final destination in destinations.all) {
        final source = destination is StageDestination
            ? destination.source
            : null;
        if (destination.category == ShellCategory.recipes) {
          expect(source, isNotNull, reason: '${destination.id} claims none');
          expect(source, startsWith('lib/recipes/'));
        } else {
          expect(source, isNull, reason: '${destination.id} claims one');
        }
      }

      destinations.dispose();
    });

    test('the shell opens on a recipe, not on a bare menu', () {
      // `ShellPage` opens the first `StageDestination` in the roster, and one
      // with none draws the menu alone — no stage, no knob region, no Code
      // pane. Since `flutter_example_template` 0.2.0 that is a legal page
      // rather than a crash (template#10, `firstOrNull` in the initialiser of
      // `ShellPage`'s `_selectedId`), which is exactly why this assertion is
      // kept: nothing fails loudly any more, and a reader landing on a menu
      // with nothing beside it is this example failing at its one job.
      //
      // Under 0.1.0 the same roster threw `Bad state: No element` on the first
      // build. The assertion did not change when that stopped being true; its
      // reason did.
      final destinations = DropdownDestinations();

      expect(destinations.all.whereType<StageDestination>(), isNotEmpty);

      destinations.dispose();
    });

    testWidgets('dispose releases what this host owns', (tester) async {
      // `returnsNormally` alone was a proxy condition: it measures that
      // `dispose` did not throw, which a `dispose` that releases nothing
      // satisfies perfectly. Measured — emptying the body left every test in
      // this file green.
      //
      // So reach the notifier through the surface that hands it out, and ask
      // it directly. A `ChangeNotifier` used after disposal throws in debug;
      // one that was never disposed does not.
      final destinations = DropdownDestinations();

      late MultiSelectKnobPane pane;
      late WheelScrollKnobPane wheelPane;
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            Widget knobsOf(String id) => destinations.all
                .whereType<StageDestination>()
                .firstWhere((d) => d.id == id)
                .knobs(context);
            pane = knobsOf('multi-select') as MultiSelectKnobPane;
            wheelPane = knobsOf('wheel-scroll') as WheelScrollKnobPane;
            return const SizedBox.shrink();
          },
        ),
      );

      expect(() => pane.knobs.addListener(() {}), returnsNormally);
      expect(() => wheelPane.knobs.addListener(() {}), returnsNormally);

      destinations.dispose();

      expect(() => pane.knobs.addListener(() {}), throwsFlutterError);
      expect(() => wheelPane.knobs.addListener(() {}), throwsFlutterError);
    });

    test('the recipes are one unbroken run at the front', () {
      // `ShellPage` selects `whereType<StageDestination>().first`, and the menu
      // walks `all` in order. Anything drifting above or into the recipes would
      // change what the reader lands on without changing a single test that
      // only checks membership.
      //
      // Written as "one unbroken run" rather than as "recipes before pages",
      // which is what it used to say. #147 deleted the only page, and that
      // phrasing then compared an index of -1 against a real one. This version
      // asserts something in both worlds: it holds now, with the run covering
      // the whole roster, and it starts constraining a page the day one is
      // added rather than passing because there is nothing to order.
      final destinations = DropdownDestinations();
      final categories = destinations.all.map((d) => d.category).toList();
      final recipes = categories
          .where((c) => c == ShellCategory.recipes)
          .length;

      expect(categories.first, ShellCategory.recipes);
      expect(recipes, greaterThan(0));
      expect(
        categories.lastIndexOf(ShellCategory.recipes),
        recipes - 1,
        reason: 'something non-recipe sits inside the run of recipes',
      );

      destinations.dispose();
    });
  });
}
