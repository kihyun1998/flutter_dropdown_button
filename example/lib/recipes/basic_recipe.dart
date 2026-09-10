/// A text dropdown at its minimum — the whole thing, in one file you can paste.
library;

import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';

/// Three parameters and nothing else: [FlutterDropdownButton.text] with a list,
/// a callback, and the value you are holding.
///
/// **The dropdown does not hold the selection; you do.** `value` is a field on
/// this widget's own `State`, and the package only draws it. That is the
/// package's identity rather than an omission, and it is why `onChanged` has to
/// write it back — a dropdown that ignored `onChanged` would open, let you pick,
/// and show the old answer.
///
/// Everything else this package can do is off here on purpose: no theme, no
/// search, no leading widget, no overflow handling beyond the default. Each of
/// those has a recipe of its own, and stacking them into the first one would
/// mean the smallest example is the one nobody can read.
class BasicRecipe extends StatefulWidget {
  const BasicRecipe({super.key});

  @override
  State<BasicRecipe> createState() => _BasicRecipeState();
}

class _BasicRecipeState extends State<BasicRecipe> {
  static const _fruits = [
    'Apple',
    'Banana',
    'Cherry',
    'Dragonfruit',
    'Elderberry',
  ];

  String? _selected;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FlutterDropdownButton<String>.text(
            items: _fruits,
            value: _selected,
            hint: 'Pick a fruit',
            onChanged: (value) => setState(() => _selected = value),
          ),
          const SizedBox(height: 24),
          Text(
            _selected == null ? 'Nothing chosen yet' : 'You chose $_selected',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
