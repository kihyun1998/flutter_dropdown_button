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
  Airport? _themed;
  Airport? _decorated;

  static String _label(Airport a) => '${a.iata} — ${a.city}';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _caption(
          context,
          'The filter, and the state when it matches none',
          'Type "korea" or "jp": the label says neither, and searchFilter is '
              'what finds them anyway. Type "zzz" for the empty state, which '
              'is handed the query.',
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: FlutterDropdownButton<Airport>.text(
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
        ),
        const SizedBox(height: 12),
        Text(
          _selected == null
              ? 'Try "korea", "jp", or "zzz"'
              : '${_selected!.iata} · ${_selected!.country}',
        ),
        const SizedBox(height: 32),
        _caption(
          context,
          'The field itself, themed',
          'Every field SearchFieldTheme declares. The divider is the one worth '
              'reading about: Flutter\'s Divider is 16 pixels tall, not one, '
              'and the height reserved for it has to say so.',
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: FlutterDropdownButton<Airport>.text(
            width: 300,
            height: 280,
            items: _airports,
            value: _themed,
            label: _label,
            hint: 'Themed search',
            searchable: true,
            onChanged: (airport) => setState(() => _themed = airport),
            theme: _searchTheme,
          ),
        ),
        const SizedBox(height: 32),
        _caption(
          context,
          'The field, described as an InputDecoration',
          'decoration takes precedence over the individual properties it '
              'covers — contentPadding among them — so this one names what it '
              'wants there and nothing that would be ignored.',
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: FlutterDropdownButton<Airport>.text(
            width: 300,
            height: 280,
            items: _airports,
            value: _decorated,
            label: _label,
            hint: 'Decorated search',
            searchable: true,
            onChanged: (airport) => setState(() => _decorated = airport),
            theme: _decoratedSearchTheme,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _caption(BuildContext context, String title, String body) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 4),
        Text(body, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    ),
  );
}

/// Every field the search field declares, named one at a time.
final _searchTheme = DropdownStyleTheme(
  overlay: const DropdownOverlayTheme(backgroundColor: Color(0xFF1B1F27)),
  search: SearchFieldTheme(
    backgroundColor: const Color(0xFF141821),
    textStyle: const TextStyle(fontSize: 14, color: Color(0xFFD7DEEC)),
    cursorColor: const Color(0xFF6E8BFF),
    cursorWidth: 2,
    cursorHeight: 16,
    cursorRadius: const Radius.circular(1),
    height: 40,
    margin: const EdgeInsets.fromLTRB(8, 8, 8, 4),
    padding: const EdgeInsets.symmetric(horizontal: 4),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: const Color(0xFF39404E)),
    focusedBorder: Border.all(color: const Color(0xFF6E8BFF), width: 1.5),
    // The pair. Flutter's `Divider` is **16** logical pixels tall by default,
    // not one — the overlay reserves `dividerHeight` and constrains the widget
    // to it, so a reservation of 1.0 under a real `Divider` used to overflow
    // the item list by fifteen pixels. Name both, or neither.
    divider: const Divider(height: 16, thickness: 1, color: Color(0xFF2C323D)),
    dividerHeight: 16,
    // The default is true, which is right for a menu opened to be typed into.
    // Turn it off when the menu is opened to be read.
    autofocus: false,
    keyboardType: TextInputType.text,
    textInputAction: TextInputAction.search,
    textAlign: TextAlign.start,
  ),
);

/// The same field, handed an [InputDecoration] instead.
final _decoratedSearchTheme = DropdownStyleTheme(
  overlay: const DropdownOverlayTheme(backgroundColor: Color(0xFF1B1F27)),
  search: SearchFieldTheme(
    backgroundColor: const Color(0xFF141821),
    textStyle: const TextStyle(fontSize: 14, color: Color(0xFFD7DEEC)),
    height: 44,
    borderRadius: BorderRadius.circular(10),
    // `contentPadding` is deliberately absent: this takes precedence over it,
    // so naming it here would be a value nothing reads.
    decoration: const InputDecoration(
      border: InputBorder.none,
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      prefixIcon: Icon(Icons.travel_explore, size: 18),
      hintText: 'City, code or country',
      hintStyle: TextStyle(fontSize: 13, color: Color(0xFF7A8296)),
    ),
    divider: const Divider(height: 16, thickness: 1, color: Color(0xFF2C323D)),
    dividerHeight: 16,
    autofocus: false,
  ),
);
