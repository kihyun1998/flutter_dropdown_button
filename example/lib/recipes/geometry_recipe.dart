/// How wide the button gets, how wide the menu gets, and where the menu sits.
library;

import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';

/// The button's box and the menu's box are sized **separately**, on purpose.
///
/// A dropdown whose menu had to be the width of its trigger would force every
/// caller to pick between a trigger that fits the layout and a menu that fits
/// the content. So there are two pairs — [FlutterDropdownButton.minWidth] /
/// [FlutterDropdownButton.maxWidth] for the button, and `minMenuWidth` /
/// `maxMenuWidth` for the menu — and [MenuAlignment] decides which edge they
/// line up on when they differ.
///
/// **`minWidth` and `maxWidth` are read only when `width` is null.** A fixed
/// width answers the question they were asked, so setting all three is setting
/// two values nothing reads. Nothing warns; the bounds simply do not appear.
/// None of the buttons below names a `width`.
///
/// **`expand` needs a `Flex`.** It is an `Expanded`, so it belongs in a [Row]
/// here — the last section is one. Put it in a [Column] and it fills the
/// vertical axis instead; put it in a [ListView] and there is no
/// `FlexParentData` to write at all (#143).
class GeometryRecipe extends StatefulWidget {
  const GeometryRecipe({super.key});

  @override
  State<GeometryRecipe> createState() => _GeometryRecipeState();
}

/// Deliberately uneven, so a bound has something to bind.
const _teams = ['SRE', 'Platform', 'Developer Experience and Tooling', 'Data'];

const _services = [
  'auth',
  'billing',
  'notification-dispatch-worker',
  'search-index',
  'media-transcode',
  'audit-log',
];

class _GeometryRecipeState extends State<GeometryRecipe> {
  String? _bounded;
  String? _boundedText;
  Set<String> _boundedMulti = {};
  String? _wide;
  String? _wideText;
  Set<String> _wideMulti = {};
  String? _expanded;
  String? _expandedText;
  Set<String> _expandedMulti = {};

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _caption(
          context,
          'The button sizes to its content, between bounds',
          'No width on any of these. Each one hugs the value it is showing '
              'and stops at 260 — pick the long team to watch the bound hold.',
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FlutterDropdownButton<String>(
              minWidth: 150,
              maxWidth: 260,
              items: _teams,
              value: _bounded,
              itemBuilder: (team, isSelected) => Text(team),
              hintWidget: const Text('Team (custom)'),
              onChanged: (v) => setState(() => _bounded = v),
            ),
            const SizedBox(width: 12),
            FlutterDropdownButton<String>.text(
              minWidth: 150,
              maxWidth: 260,
              items: _teams,
              value: _boundedText,
              hint: 'Team (text)',
              // Drawn only once something is chosen, which is the difference
              // from `leading`.
              selectedLeading: const Icon(Icons.group, size: 16),
              onChanged: (v) => setState(() => _boundedText = v),
            ),
            const SizedBox(width: 12),
            FlutterMultiSelectDropdown<String>(
              minWidth: 150,
              maxWidth: 260,
              items: _teams,
              selected: _boundedMulti,
              labelBuilder: (chosen) =>
                  chosen.isEmpty ? 'Teams' : '${chosen.length} teams',
              onChanged: (next) => setState(() => _boundedMulti = next),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _caption(
          context,
          'The menu is not the button',
          'Same narrow buttons, a menu forced between 320 and 420 — and the '
              'three alignments deciding which edge they share. Open them: '
              'left, centre, right.',
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FlutterDropdownButton<String>(
              maxWidth: 180,
              minMenuWidth: 320,
              maxMenuWidth: 420,
              menuAlignment: MenuAlignment.left,
              height: 240,
              items: _services,
              value: _wide,
              itemBuilder: (s, isSelected) => Text(s),
              hintWidget: const Text('left'),
              // The menu opens scrolled to what is chosen, over this long.
              scrollToSelectedItem: true,
              scrollToSelectedDuration: const Duration(milliseconds: 250),
              trailing: const Icon(Icons.expand_more, size: 18),
              theme: const DropdownStyleTheme(
                overlay: DropdownOverlayTheme(borderRadius: 12),
              ),
              onChanged: (v) => setState(() => _wide = v),
            ),
            const SizedBox(width: 12),
            FlutterDropdownButton<String>.text(
              maxWidth: 180,
              minMenuWidth: 320,
              maxMenuWidth: 420,
              menuAlignment: MenuAlignment.center,
              items: _services,
              value: _wideText,
              hint: 'centre',
              onChanged: (v) => setState(() => _wideText = v),
            ),
            const SizedBox(width: 12),
            FlutterMultiSelectDropdown<String>(
              maxWidth: 180,
              minMenuWidth: 320,
              maxMenuWidth: 420,
              menuAlignment: MenuAlignment.right,
              // Taller rows than the default 48.
              itemHeight: 56,
              items: _services,
              selected: _wideMulti,
              labelBuilder: (chosen) =>
                  chosen.isEmpty ? 'right' : '${chosen.length} on',
              trailing: const Icon(Icons.filter_list, size: 18),
              // The checklist takes the same text config the text constructor
              // does, for the label it draws on the button.
              config: const TextDropdownConfig(
                overflow: TextOverflow.ellipsis,
                textStyle: TextStyle(fontSize: 13),
              ),
              onChanged: (next) => setState(() => _wideMulti = next),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _caption(
          context,
          'expand, in the only place it belongs',
          'A Row. expand is an Expanded, so it fills the main axis of the Flex '
              'it is in — which here is the width, and is what a reader '
              'expects. In a Column it would fill the height instead.',
        ),
        Row(
          children: [
            Expanded(
              // No `expand:` on this one — the `Expanded` is here instead.
              // **Never both.** Two of them writing `FlexParentData` to the
              // same render object is `Competing ParentDataWidgets`, thrown on
              // every build, and that is exactly what #143 was.
              child: FlutterDropdownButton<String>.text(
                items: _services,
                value: _expandedText,
                hint: 'Expanded by its parent',
                onChanged: (v) => setState(() => _expandedText = v),
              ),
            ),
            const SizedBox(width: 12),
            // These two ask for it themselves. Same result, one widget fewer.
            FlutterDropdownButton<String>(
              expand: true,
              items: _services,
              value: _expanded,
              itemBuilder: (s, isSelected) => Text(s),
              hintWidget: const Text('expand: true'),
              onChanged: (v) => setState(() => _expanded = v),
            ),
            const SizedBox(width: 12),
            FlutterMultiSelectDropdown<String>(
              expand: true,
              items: _services,
              selected: _expandedMulti,
              labelBuilder: (chosen) =>
                  chosen.isEmpty ? 'expand: true' : '${chosen.length} selected',
              onChanged: (next) => setState(() => _expandedMulti = next),
            ),
          ],
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
