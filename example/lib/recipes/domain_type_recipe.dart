/// A dropdown over your own type — one callback, both cardinalities.
library;

import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';

/// A domain type. Not a `String`, and it does not override `==`.
///
/// Both of those matter. Text mode has to be told how to read it, and identity
/// rather than equality is what decides whether a value is "the selected one" —
/// which is why the constants below are `const` and reused rather than rebuilt.
class Country {
  const Country(this.code, this.name, this.flag);

  final String code;
  final String name;
  final String flag;
}

const _countries = <Country>[
  Country('KR', 'South Korea', '🇰🇷'),
  Country('JP', 'Japan', '🇯🇵'),
  Country('US', 'United States', '🇺🇸'),
  Country('DE', 'Germany', '🇩🇪'),
  Country('FR', 'France', '🇫🇷'),
  Country('BR', 'Brazil', '🇧🇷'),
  Country('ZA', 'South Africa', '🇿🇦'),
  Country('AU', 'Australia', '🇦🇺'),
];

/// `label:` is all text mode needs to render a type it has never heard of.
///
/// Overflow handling, the automatic tooltip and the default search filter all
/// follow the label — `searchable: true` below passes no `searchFilter`, and
/// searching "kor" still finds South Korea.
///
/// **Both cardinalities are here on purpose.** Single-select and multi-select
/// are different types in this package rather than one widget with a flag, and
/// putting them side by side is the only way that is visible: they take the
/// same `label` callback, and they differ in what they hold — `value` is one
/// item, `selected` is a `Set` you own.
class DomainTypeRecipe extends StatefulWidget {
  const DomainTypeRecipe({super.key});

  @override
  State<DomainTypeRecipe> createState() => _DomainTypeRecipeState();
}

class _DomainTypeRecipeState extends State<DomainTypeRecipe> {
  Country? _one;
  final Set<Country> _many = {};

  static String _label(Country c) => '${c.flag}  ${c.name}';

  @override
  Widget build(BuildContext context) {
    final small = Theme.of(context).textTheme.bodySmall;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Single — value is one Country', style: small),
          const SizedBox(height: 8),
          FlutterDropdownButton<Country>.text(
            width: 280,
            items: _countries,
            value: _one,
            label: _label,
            hint: 'Select a country',
            searchable: true,
            onChanged: (country) => setState(() => _one = country),
          ),
          const SizedBox(height: 8),
          Text(_one == null ? 'Nothing selected' : 'Selected ${_one!.code}'),

          const SizedBox(height: 32),
          Text('Multi — selected is a Set you own', style: small),
          const SizedBox(height: 8),
          FlutterMultiSelectDropdown<Country>(
            width: 280,
            items: _countries,
            selected: _many,
            label: _label,
            searchable: true,
            labelBuilder: (chosen) => switch (chosen.length) {
              0 => 'Select countries',
              1 => _label(chosen.first),
              final n => '$n countries',
            },
            // The set is yours: the package hands back what changed and draws
            // whatever you decide to hold.
            onChanged: (chosen) => setState(() {
              _many
                ..clear()
                ..addAll(chosen);
            }),
          ),
          const SizedBox(height: 8),
          Text(
            _many.isEmpty
                ? 'Nothing selected'
                : _many.map((c) => c.code).join(', '),
          ),
        ],
      ),
    );
  }
}
