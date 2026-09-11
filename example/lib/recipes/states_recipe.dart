/// The states a dropdown is put into: one choice, no choice, and nothing found.
library;

import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';

/// Three states that are not about what the control *looks* like.
///
/// **One item is not a choice.** [FlutterDropdownButton.disableWhenSingleItem]
/// turns a one-item list into a label: it auto-selects the only value and stops
/// taking taps. [FlutterDropdownButton.hideIconWhenSingleItem] then decides
/// whether a chevron still says "this opens" about something that no longer
/// does.
///
/// **`hideIconWhenSingleItem` is read only when `disableWhenSingleItem` is
/// true.** The third button below sets it with the other one off, where it does
/// nothing at all — which is the same shape as a scrollbar `trackColor` with no
/// `trackVisibility`, or a `minWidth` beside a `width`. Nothing warns.
///
/// **Off is not the same as empty.** `enabled: false` keeps the value on screen
/// and refuses the tap; an empty `items` list opens a menu with nothing in it.
/// Those are different states and a reader meets both here.
///
/// **A search that matches nothing has to say so**, and `emptyBuilder` is
/// handed the query — which is the difference between *"nothing here"* and
/// *"nothing matching **xyz**"*. It also covers the other empty menu, the one
/// with an empty `items` list, which arrives with an empty query.
class StatesRecipe extends StatefulWidget {
  const StatesRecipe({super.key});

  @override
  State<StatesRecipe> createState() => _StatesRecipeState();
}

class Region {
  const Region(this.code, this.name);
  final String code;
  final String name;
}

const _only = <Region>[Region('ap-northeast-2', 'Seoul')];

const _regions = <Region>[
  Region('ap-northeast-2', 'Seoul'),
  Region('ap-northeast-1', 'Tokyo'),
  Region('us-east-1', 'N. Virginia'),
  Region('eu-west-1', 'Ireland'),
  Region('sa-east-1', 'Sao Paulo'),
];

class _StatesRecipeState extends State<StatesRecipe> {
  Region? _single;
  Region? _singleText;
  Region? _inert;
  Region? _searched;
  Set<Region> _searchedMulti = {};
  Region? _slow;
  Set<Region> _fast = {};

  static String _label(Region r) => '${r.code} · ${r.name}';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _caption(
          context,
          'One item is not a choice',
          'All three have exactly one region. The first two are disabled by it '
              'and differ only in whether a chevron is still drawn. The third '
              'sets hideIconWhenSingleItem with disableWhenSingleItem off, '
              'where it is read by nothing.',
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FlutterDropdownButton<Region>(
              width: 240,
              items: _only,
              value: _single,
              itemBuilder: (r, isSelected) => Text(_label(r)),
              hintWidget: const Text('Region'),
              selectedBuilder: (r) => Text(_label(r)),
              // Auto-selects the only value and stops taking taps.
              disableWhenSingleItem: true,
              // No chevron, because there is nothing to open.
              hideIconWhenSingleItem: true,
              onChanged: (v) => setState(() => _single = v),
            ),
            const SizedBox(width: 12),
            FlutterDropdownButton<Region>.text(
              width: 240,
              items: _only,
              value: _singleText,
              label: _label,
              hint: 'Region',
              disableWhenSingleItem: true,
              // Kept, so the control still looks like a dropdown even though
              // it no longer behaves as one. A deliberate choice, not a default.
              hideIconWhenSingleItem: false,
              onChanged: (v) => setState(() => _singleText = v),
            ),
            const SizedBox(width: 12),
            FlutterDropdownButton<Region>.text(
              width: 240,
              items: _only,
              value: _inert,
              label: _label,
              hint: 'Still opens',
              // Off — so the line below is read by nothing, and the chevron
              // stays. This pair is the whole point of the third button.
              disableWhenSingleItem: false,
              hideIconWhenSingleItem: true,
              onChanged: (v) => setState(() => _inert = v),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _caption(
          context,
          'Switched off',
          'enabled: false keeps the value on screen and refuses the tap. That '
              'is not the same as an empty list, which opens a menu with '
              'nothing in it.',
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FlutterDropdownButton<Region>(
              width: 240,
              items: _regions,
              value: _regions.first,
              itemBuilder: (r, isSelected) => Text(_label(r)),
              selectedBuilder: (r) => Text(_label(r)),
              hintWidget: const Text('Region'),
              enabled: false,
              onChanged: (_) {},
            ),
            const SizedBox(width: 12),
            FlutterMultiSelectDropdown<Region>(
              width: 240,
              items: _regions,
              selected: {_regions.first},
              label: _label,
              labelBuilder: (chosen) => '${chosen.length} region',
              enabled: false,
              onChanged: (_) {},
            ),
          ],
        ),
        const SizedBox(height: 32),
        _caption(
          context,
          'Nothing matched',
          'Both search on the region code as well as the name, so "seoul" and '
              '"ap-north" both find rows. Type "xyz" for the empty state, '
              'which is handed the query rather than a fixed string.',
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FlutterDropdownButton<Region>(
              width: 260,
              height: 240,
              items: _regions,
              value: _searched,
              itemBuilder: (r, isSelected) => Text(_label(r)),
              selectedBuilder: (r) => Text(_label(r)),
              hintWidget: const Text('Search regions'),
              searchable: true,
              searchFilter: _matches,
              emptyBuilder: _empty,
              // Slower than the 200ms default, so the open is watchable.
              animationDuration: const Duration(milliseconds: 320),
              onChanged: (v) => setState(() => _searched = v),
            ),
            const SizedBox(width: 12),
            FlutterMultiSelectDropdown<Region>(
              width: 260,
              height: 240,
              items: _regions,
              selected: _searchedMulti,
              label: _label,
              labelBuilder: (chosen) =>
                  chosen.isEmpty ? 'Search regions' : '${chosen.length} on',
              searchable: true,
              searchFilter: _matches,
              emptyBuilder: _empty,
              onChanged: (next) => setState(() => _searchedMulti = next),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _caption(
          context,
          'How long the open takes',
          'The default is 200 milliseconds. These two are 600 and 80 — open '
              'them one after the other; it is the only difference between '
              'them.',
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FlutterDropdownButton<Region>.text(
              width: 240,
              items: _regions,
              value: _slow,
              label: _label,
              hint: 'Slow (600ms)',
              animationDuration: const Duration(milliseconds: 600),
              onChanged: (v) => setState(() => _slow = v),
            ),
            const SizedBox(width: 12),
            FlutterMultiSelectDropdown<Region>(
              width: 240,
              items: _regions,
              selected: _fast,
              label: _label,
              labelBuilder: (chosen) =>
                  chosen.isEmpty ? 'Fast (80ms)' : '${chosen.length} on',
              animationDuration: const Duration(milliseconds: 80),
              onChanged: (next) => setState(() => _fast = next),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  /// Reads the item, so a query the label never shows can still match.
  static bool _matches(Region region, String query) {
    final q = query.toLowerCase();
    return region.code.toLowerCase().contains(q) ||
        region.name.toLowerCase().contains(q);
  }

  static Widget _empty(String query) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.search_off, size: 28),
        const SizedBox(height: 8),
        Text(
          query.isEmpty ? 'No regions loaded' : 'Nothing matching "$query"',
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );

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
