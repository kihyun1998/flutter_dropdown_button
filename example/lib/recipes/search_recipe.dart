/// Searching a menu — the filter you supply, and the state when it matches none.
library;

import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';

/// One airport, so the filter has something to match on other than the label.
class Airport {
  const Airport(this.iata, this.city, this.country);

  final String iata;
  final String city;
  final String country;
}

const _airports = <Airport>[
  Airport('ICN', 'Seoul', 'South Korea'),
  Airport('GMP', 'Seoul', 'South Korea'),
  Airport('NRT', 'Tokyo', 'Japan'),
  Airport('HND', 'Tokyo', 'Japan'),
  Airport('JFK', 'New York', 'United States'),
  Airport('LAX', 'Los Angeles', 'United States'),
  Airport('CDG', 'Paris', 'France'),
  Airport('FRA', 'Frankfurt', 'Germany'),
  Airport('SYD', 'Sydney', 'Australia'),
  Airport('GRU', 'São Paulo', 'Brazil'),
];

/// `searchable: true` is the whole of the default: the menu grows a field, and
/// the filter matches the **label**, case-insensitively.
///
/// That default is often not what you want. Here the label is
/// `ICN — Seoul`, so a reader typing `korea` finds nothing — the country is
/// never on screen. [FlutterDropdownButton.searchFilter] is the lever: it gets
/// the item itself, not its label, so it can match anything the item knows.
///
/// **And a filter that matches nothing has to say so.** `emptyBuilder` is what
/// draws that, and it is handed the query — which is the difference between
/// *"nothing here"* and *"nothing matching **korea**"*. It also covers the
/// other empty menu, the one with an empty `items` list, which reaches this
/// builder with an empty query.
class SearchRecipe extends StatefulWidget {
  const SearchRecipe({super.key, this.matchCountry = true});

  /// Whether `searchFilter` widens the match past the label.
  ///
  /// Turn it off and type `korea`: the label never contains it, so the default
  /// finds nothing and the empty state appears.
  final bool matchCountry;

  @override
  State<SearchRecipe> createState() => _SearchRecipeState();
}

class _SearchRecipeState extends State<SearchRecipe> {
  Airport? _selected;

  static String _label(Airport a) => '${a.iata} — ${a.city}';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FlutterDropdownButton<Airport>.text(
            width: 300,
            height: 260,
            items: _airports,
            value: _selected,
            label: _label,
            hint: 'Search airports',
            searchable: true,
            // Text mode's default filter reads the label. This one reads the
            // item, so `korea` and `jp` find rows whose text says neither.
            searchFilter: widget.matchCountry
                ? (airport, query) {
                    final q = query.toLowerCase();
                    return _label(airport).toLowerCase().contains(q) ||
                        airport.country.toLowerCase().contains(q);
                  }
                : null,
            // Reached by a search that matches nothing, and by an empty
            // `items` list — which arrives here with an empty query.
            emptyBuilder: (query) => Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.search_off, size: 32),
                  const SizedBox(height: 12),
                  Text(
                    query.isEmpty
                        ? 'No airports loaded'
                        : 'Nothing matching "$query"',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            onChanged: (airport) => setState(() => _selected = airport),
          ),
          const SizedBox(height: 24),
          Text(
            _selected == null
                ? 'Try "korea", "jp", or "zzz"'
                : '${_selected!.iata} · ${_selected!.country}',
          ),
        ],
      ),
    );
  }
}
