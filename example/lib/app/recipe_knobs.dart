/// The state a knobbed recipe's stage and its knob pane both read.
library;

import 'package:flutter/material.dart';

import '../recipes/multi_select_recipe.dart';
import '../recipes/search_recipe.dart';

/// What the multi-select recipe's knobs hold.
///
/// **Only the knobs.** The recipe's own selection — the `Set` the reader ticks
/// — lives in the recipe's `State`, because a recipe that took its selection
/// from an injected object would not be pasteable, and because a caller holding
/// the set is precisely what this package's API is.
///
/// This half lives outside for a different reason: the stage and the knob pane
/// are two views of one thing, drawn on the same frame, and something has to
/// own the value they both read.
class MultiSelectKnobs extends ChangeNotifier {
  bool _searchable = true;
  bool get searchable => _searchable;
  set searchable(bool value) {
    if (_searchable == value) return;
    _searchable = value;
    notifyListeners();
  }

  bool _solarisDropped = false;
  bool get solarisDropped => _solarisDropped;
  set solarisDropped(bool value) {
    if (_solarisDropped == value) return;
    _solarisDropped = value;
    notifyListeners();
  }
}

/// The stage half — the recipe, and nothing around it.
class MultiSelectStage extends StatelessWidget {
  const MultiSelectStage({super.key, required this.knobs});

  final MultiSelectKnobs knobs;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: knobs,
    builder: (context, _) => MultiSelectRecipe(
      searchable: knobs.searchable,
      solarisDropped: knobs.solarisDropped,
    ),
  );
}

/// The knob half.
class MultiSelectKnobPane extends StatelessWidget {
  const MultiSelectKnobPane({super.key, required this.knobs});

  final MultiSelectKnobs knobs;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: knobs,
    builder: (context, _) => ListView(
      padding: const EdgeInsets.all(12),
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('searchable'),
          value: knobs.searchable,
          onChanged: (v) => knobs.searchable = v,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Drop Solaris from the data'),
          subtitle: const Text(
            'Tick Solaris first, then flip this: the row goes, the choice '
            'stays, the count still includes it.',
          ),
          value: knobs.solarisDropped,
          onChanged: (v) => knobs.solarisDropped = v,
        ),
      ],
    ),
  );
}

/// What the search recipe's knobs hold.
class SearchKnobs extends ChangeNotifier {
  bool _matchCountry = true;
  bool get matchCountry => _matchCountry;
  set matchCountry(bool value) {
    if (_matchCountry == value) return;
    _matchCountry = value;
    notifyListeners();
  }
}

/// The stage half.
class SearchStage extends StatelessWidget {
  const SearchStage({super.key, required this.knobs});

  final SearchKnobs knobs;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: knobs,
    builder: (context, _) => SearchRecipe(matchCountry: knobs.matchCountry),
  );
}

/// The knob half.
class SearchKnobPane extends StatelessWidget {
  const SearchKnobPane({super.key, required this.knobs});

  final SearchKnobs knobs;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: knobs,
    builder: (context, _) => ListView(
      padding: const EdgeInsets.all(12),
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('searchFilter matches the country'),
          subtitle: const Text(
            'Off, the default filter reads only the label. Type "korea" with '
            'it off to reach the empty state.',
          ),
          value: knobs.matchCountry,
          onChanged: (v) => knobs.matchCountry = v,
        ),
      ],
    ),
  );
}
