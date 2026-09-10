/// What this example asks the shell to show.
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_example_template/flutter_example_template.dart';

import '../pages/playground_page.dart';
import '../recipes/bare_anchor_recipe.dart';
import '../recipes/basic_recipe.dart';
import '../recipes/build_your_own_recipe.dart';
import '../recipes/domain_type_recipe.dart';
import '../recipes/overlay_lifetime_recipe.dart';
import 'recipe_knobs.dart';

/// The destinations of *this* app, and whatever state sits behind them.
///
/// The split is the point: [ShellPage] draws a menu, a stage and a knob region
/// and knows nothing about dropdowns, and this file knows nothing about layout.
///
/// **What lives here and what does not.** A recipe's *knobs* live here, because
/// the stage and the knob pane are two views of one value drawn on the same
/// frame. A recipe's *selection* does not: it lives in the recipe's own
/// `State`, because a file that took its selection from an injected object
/// would not be pasteable — and because a caller holding the selection is
/// exactly what this package's API is.
class DropdownDestinations implements ShellDestinations {
  DropdownDestinations();

  final _multiSelectKnobs = MultiSelectKnobs();

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
    StageDestination(
      id: 'basic',
      label: 'Basic',
      category: ShellCategory.recipes,
      source: 'lib/recipes/basic_recipe.dart',
      stage: (context) => const BasicRecipe(),
      // Nothing to vary: this recipe is three parameters. The shell draws no
      // knob region rather than an empty strip announcing controls that are
      // not there.
      knobs: (context) => const SizedBox.shrink(),
    ),
    StageDestination(
      id: 'domain-type',
      label: 'Domain type',
      category: ShellCategory.recipes,
      source: 'lib/recipes/domain_type_recipe.dart',
      stage: (context) => const DomainTypeRecipe(),
      knobs: (context) => const SizedBox.shrink(),
    ),
    StageDestination(
      id: 'multi-select',
      label: 'Multi-select',
      category: ShellCategory.recipes,
      source: 'lib/recipes/multi_select_recipe.dart',
      stage: (context) => MultiSelectStage(knobs: _multiSelectKnobs),
      knobs: (context) => MultiSelectKnobPane(knobs: _multiSelectKnobs),
    ),
    StageDestination(
      id: 'bare-anchor',
      label: 'Bare anchor',
      category: ShellCategory.recipes,
      source: 'lib/recipes/bare_anchor_recipe.dart',
      stage: (context) => const BareAnchorRecipe(),
      knobs: (context) => const SizedBox.shrink(),
    ),
    StageDestination(
      id: 'build-your-own',
      label: 'Build your own',
      category: ShellCategory.recipes,
      source: 'lib/recipes/build_your_own_recipe.dart',
      stage: (context) => const BuildYourOwnRecipe(),
      knobs: (context) => const SizedBox.shrink(),
    ),
    StageDestination(
      id: 'overlay-lifetime',
      label: 'Overlay lifetime',
      category: ShellCategory.recipes,
      source: 'lib/recipes/overlay_lifetime_recipe.dart',
      stage: (context) => const OverlayLifetimeRecipe(),
      knobs: (context) => const SizedBox.shrink(),
    ),
    RouteDestination(
      id: 'playground',
      label: 'Every setting',
      category: ShellCategory.pages,
      open: (context) => const PlaygroundPage(),
    ),
  ];

  /// Releases whatever the destinations hold.
  ///
  /// The knob notifier, and nothing else. Every recipe's own state is in its
  /// own `State`, which Flutter disposes — including the
  /// `DropdownOverlayController` the Build Your Own recipe holds, which is
  /// disposed in that recipe rather than here because the recipe has to be
  /// pasteable with its lifetime intact. A leaked `OverlayEntry` is the
  /// consumer's whole app, and it throws nothing and fails no test.
  @override
  void dispose() {
    _multiSelectKnobs.dispose();
  }
}
