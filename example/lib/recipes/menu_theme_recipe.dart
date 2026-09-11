/// Everything inside the popup: the container, the rows, the scrollbar, the box.
library;

import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';

/// The four themes that describe the menu rather than the button.
///
/// A dropdown's *face* is one surface and its *menu* is another, and different
/// classes theme them. This file is the second one, end to end:
/// [DropdownOverlayTheme] for the container, [DropdownItemTheme] for the rows,
/// [DropdownScrollTheme] for the scrollbar and its fade, and
/// [DropdownCheckboxTheme] for the box a checklist draws.
///
/// Two things here are worth more than the colours.
///
/// **A colour is not a request.** Naming [DropdownScrollTheme.trackColor] and
/// leaving [DropdownScrollTheme.trackVisibility] null paints no track at all —
/// the colour says what the track looks like *once drawn*, and the flag is what
/// draws it. A downstream app set the colour, saw nothing, and was right to be
/// confused (#59).
///
/// **`decoration` replaces, it does not merge.** The second menu below sets
/// [DropdownOverlayTheme.decoration], and the moment it does,
/// `backgroundColor`, `border`, `borderRadius` and `shadowColor` on the same
/// object stop being read. That shape recurs across this package: several slots
/// replace the ambient value rather than merging into it, so a half-filled one
/// loses whatever it did not name.
class MenuThemeRecipe extends StatefulWidget {
  const MenuThemeRecipe({super.key});

  @override
  State<MenuThemeRecipe> createState() => _MenuThemeRecipeState();
}

const _regions = [
  'ap-northeast-2 · Seoul',
  'ap-northeast-1 · Tokyo',
  'us-east-1 · N. Virginia',
  'us-west-2 · Oregon',
  'eu-west-1 · Ireland',
  'eu-central-1 · Frankfurt',
  'sa-east-1 · Sao Paulo',
];

/// Long enough to need the scrollbar this file is partly about.
const _tiers = [
  'nano',
  'micro',
  'small',
  'medium',
  'large',
  'xlarge',
  '2xlarge',
  '4xlarge',
  '8xlarge',
  '12xlarge',
];

class _MenuThemeRecipeState extends State<MenuThemeRecipe> {
  String? _region;
  Set<String> _tiers0 = {};

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Themed field by field',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 4),
        const Text(
          'Container, rows, scrollbar and checkbox — every field each class '
          'declares. Open it and drag: the track is drawn because '
          'trackVisibility asks for it, not because it was given a colour.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: FlutterMultiSelectDropdown<String>(
            width: 320,
            height: 240,
            items: _tiers,
            selected: _tiers0,
            labelBuilder: (chosen) =>
                chosen.isEmpty ? 'Instance tiers' : '${chosen.length} tiers',
            onChanged: (next) => setState(() => _tiers0 = next),
            theme: DropdownStyleTheme(
              // The menu's container.
              overlay: DropdownOverlayTheme(
                backgroundColor: const Color(0xFF1B1F27),
                border: Border.all(color: const Color(0xFF39404E)),
                borderRadius: 12,
                elevation: 14,
                shadowColor: Colors.black.withValues(alpha: 0.55),
                padding: const EdgeInsets.symmetric(vertical: 6),
              ),
              // The rows inside it.
              item: DropdownItemTheme(
                selectedColor: const Color(0xFF2A3550),
                hoverColor: const Color(0xFF232936),
                splashColor: const Color(0xFF2F3949),
                highlightColor: const Color(0xFF262D3A),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                borderRadius: 8,
                border: Border.all(color: const Color(0xFF2C323D)),
                // The last row's border would sit on the container's own.
                excludeLastItemBorder: true,
              ),
              // The scrollbar, and the fade that says there is more below.
              scroll: const DropdownScrollTheme(
                thickness: 8,
                thumbWidth: 6,
                radius: Radius.circular(4),
                thumbColor: Color(0xFF6B7891),
                // This is the field that draws the track. Without it the two
                // colours below paint nothing at all.
                trackVisibility: true,
                trackColor: Color(0xFF20252E),
                trackBorderColor: Color(0xFF2C323D),
                thumbVisibility: true,
                interactive: true,
                crossAxisMargin: 2,
                mainAxisMargin: 6,
                minThumbLength: 32,
                showScrollGradient: true,
                gradientHeight: 18,
                gradientColors: [Color(0xFF1B1F27), Color(0x001B1F27)],
              ),
              // The box on each row is drawn in the root overlay, which is why
              // it is themed here rather than by an ambient `CheckboxThemeData`
              // that would restyle every checkbox in the app.
              checkbox: const DropdownCheckboxTheme(
                activeColor: Color(0xFF6E8BFF),
                checkColor: Colors.white,
                inactiveColor: Color(0xFF161A21),
                borderColor: Color(0xFF4A5367),
                borderWidth: 1.5,
                // A circle, so `borderRadius` is deliberately absent: the shape
                // ignores it, and naming it here would be the dead combination
                // #59 was about. `multi_select_recipe.dart` is the rectangle.
                shape: CheckboxShape.circle,
                size: 18,
                checkStrokeWidth: 2,
                checkScale: 0.8,
                mouseCursor: SystemMouseCursors.click,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Themed with a decoration',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 4),
        const Text(
          'The same container described as one BoxDecoration. It replaces '
          'backgroundColor, border, borderRadius and shadowColor rather than '
          'merging with them, so whatever it does not name is gone.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: FlutterDropdownButton<String>.text(
            width: 320,
            items: _regions,
            value: _region,
            hint: 'Region',
            onChanged: (v) => setState(() => _region = v),
            theme: DropdownStyleTheme(
              overlay: DropdownOverlayTheme(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF232A3B), Color(0xFF171B24)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF3B455C)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x66000000),
                      blurRadius: 18,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
              ),
              item: const DropdownItemTheme(
                selectedColor: Color(0xFF33405C),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
