/// What this example asks the shell to show.
library;

import 'package:flutter_example_template/flutter_example_template.dart';

import '../pages/bare_anchor_page.dart';
import '../pages/bug_test_page.dart';
import '../pages/domain_type_page.dart';
import '../pages/multi_select_page.dart';
import '../pages/playground_page.dart';

/// The destinations of *this* app, and whatever state sits behind them.
///
/// The split is the point: [ShellPage] draws a menu, a stage and a knob region
/// and knows nothing about dropdowns, and this file knows nothing about layout.
///
/// **Every entry here is a [RouteDestination], and every one of them is
/// temporary.** They are the pages this example had before the shell arrived —
/// each a full page with its own `Scaffold`, which is exactly what
/// [ShellCategory.pages] means: a hosting kind rather than a subject. They are
/// listed rather than deleted so this slice can land with no recipe existing,
/// and they are replaced one at a time as the recipes arrive.
///
/// Nothing here carries a `source:` yet. The Code pane is the affordance of the
/// pasteable claim, and none of these pages makes it.
class DropdownDestinations implements ShellDestinations {
  DropdownDestinations();

  /// Every destination, in menu order.
  ///
  /// **A field, not a getter**, and that is a contract rather than a style
  /// choice: `ShellMenu` and the stage both walk this on the same frame, so a
  /// list rebuilt per call would rebuild every destination's builder with it.
  /// `test/destinations_test.dart` holds it, because nothing else can — a
  /// getter returning a fresh list is legal Dart that compiles, runs, and looks
  /// right.
  @override
  late final List<ShellDestination> all = [
    RouteDestination(
      id: 'playground',
      label: 'Every setting',
      category: ShellCategory.pages,
      open: (context) => const PlaygroundPage(),
    ),
    RouteDestination(
      id: 'multi-select',
      label: 'Multi-select',
      category: ShellCategory.pages,
      open: (context) => const MultiSelectPage(),
    ),
    RouteDestination(
      id: 'domain-type',
      label: 'Domain type',
      category: ShellCategory.pages,
      open: (context) => const DomainTypePage(),
    ),
    RouteDestination(
      id: 'bare-anchor',
      label: 'Bare anchor',
      category: ShellCategory.pages,
      open: (context) => const BareAnchorPage(),
    ),
    RouteDestination(
      id: 'overlay-teardown',
      label: 'Overlay teardown',
      category: ShellCategory.pages,
      open: (context) => const DropdownBugTestPage(),
    ),
  ];

  /// Releases whatever the destinations hold.
  ///
  /// **Empty, and only for as long as every destination is a route.** A
  /// [RouteDestination] is pointed at rather than absorbed, so its page owns
  /// its own `State` and Flutter disposes it. The first `StageDestination` to
  /// arrive changes that: a recipe's knob notifier, and the
  /// `DropdownOverlayController` the Build Your Own recipe holds, are both
  /// owned here and both have to be released here. A leaked `OverlayEntry` is
  /// the consumer's whole app — a dead layer swallowing taps — and it throws
  /// nothing and fails no test.
  @override
  void dispose() {}
}
