// What this app asks the shell to show, held at the one seam that is ours.
//
// `DropdownDestinations` takes no `BuildContext` and touches no infrastructure,
// which is why it can be tested as a plain object. The shell's own widgets —
// `ShellPage`, the menu, the Code pane — are `flutter_example_template`'s and
// are tested there; re-testing them here would mean maintaining two answers to
// one question.

import 'package:example/app/destinations.dart';
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
        'playground',
        'multi-select',
        'domain-type',
        'bare-anchor',
        'overlay-teardown',
      ]);

      destinations.dispose();
    });

    test('every destination is a route, and none claims a source', () {
      // True only of this slice, and the assertion is here to stop being true
      // quietly. The first recipe makes both halves false, and this test is
      // what says so out loud rather than letting the shell drift into drawing
      // something it was never given.
      final destinations = DropdownDestinations();

      expect(destinations.all, everyElement(isA<RouteDestination>()));
      expect(
        destinations.all.every((d) => d.category == ShellCategory.pages),
        isTrue,
      );

      destinations.dispose();
    });

    test('dispose is safe while every destination is a route', () {
      final destinations = DropdownDestinations();

      expect(destinations.dispose, returnsNormally);
    });
  });
}
