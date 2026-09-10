/// What text mode does when the text does not fit.
library;

import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';

const _longItems = <String>[
  'Windows Active Directory — corporate realm',
  'Lightweight Directory Access Protocol',
  'Kerberos v5',
  'SAML 2.0 identity provider',
  'OpenID Connect',
];

/// [TextDropdownConfig] decides what happens to text too long for its box, and
/// it ships three presets so the common answers need no fields spelled out.
///
/// * [TextDropdownConfig.defaultConfig] ellipsises on one line, and the full
///   string arrives in a tooltip because it overflowed.
/// * [TextDropdownConfig.fadeOverflow] fades the tail instead of cutting it
///   with a marker — quieter, and it never promises the text ends where the
///   ellipsis is.
/// * [TextDropdownConfig.multiLine] stops truncating: `maxLines: null`,
///   `softWrap: true`, `overflow: visible`. Rows grow, so `itemHeight` has to
///   be big enough for them.
/// * [TextDropdownConfig.centered] changes alignment rather than overflow, and
///   is here because it is the third preset and would otherwise be the one
///   nobody knows exists.
///
/// `leading` and `leadingPadding` ride along on the same widget: the padding is
/// the space between the leading widget and the text, and it is one of the two
/// fields the playground never wires because it has no reason to move.
class TextConfigRecipe extends StatefulWidget {
  const TextConfigRecipe({super.key});

  @override
  State<TextConfigRecipe> createState() => _TextConfigRecipeState();
}

class _TextConfigRecipeState extends State<TextConfigRecipe> {
  String? _ellipsis;
  String? _fade;
  String? _wrap;
  String? _centre;

  @override
  Widget build(BuildContext context) {
    final label = Theme.of(context).textTheme.labelLarge;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('defaultConfig — ellipsis, with a tooltip', style: label),
          const SizedBox(height: 8),
          FlutterDropdownButton<String>.text(
            width: 240,
            items: _longItems,
            value: _ellipsis,
            hint: 'One line, cut',
            config: TextDropdownConfig.defaultConfig,
            leading: const Icon(Icons.vpn_key, size: 16),
            // The gap between the icon and the text. Defaults to 8 on the
            // right; here it is wider so the seam is visible at all.
            leadingPadding: const EdgeInsets.only(right: 14),
            onChanged: (v) => setState(() => _ellipsis = v),
          ),

          const SizedBox(height: 28),
          Text('fadeOverflow — the tail fades out', style: label),
          const SizedBox(height: 8),
          FlutterDropdownButton<String>.text(
            width: 240,
            items: _longItems,
            value: _fade,
            hint: 'One line, faded',
            config: TextDropdownConfig.fadeOverflow,
            onChanged: (v) => setState(() => _fade = v),
          ),

          const SizedBox(height: 28),
          Text('multiLine — rows wrap instead of truncating', style: label),
          const SizedBox(height: 8),
          FlutterDropdownButton<String>.text(
            width: 240,
            // Wrapped rows are taller than one line, and nothing infers that
            // for you: a row that wraps inside a 48-pixel slot is clipped.
            itemHeight: 72,
            items: _longItems,
            value: _wrap,
            hint: 'Wraps',
            config: TextDropdownConfig.multiLine,
            onChanged: (v) => setState(() => _wrap = v),
          ),

          const SizedBox(height: 28),
          Text('centered — alignment, not overflow', style: label),
          const SizedBox(height: 8),
          FlutterDropdownButton<String>.text(
            width: 240,
            items: const ['Left', 'Middle', 'Right'],
            value: _centre,
            hint: 'Centred',
            config: TextDropdownConfig.centered,
            // Scrolling the chosen row into view when the menu opens, and how
            // long that takes. The duration is meaningless without the flag.
            scrollToSelectedItem: true,
            scrollToSelectedDuration: const Duration(milliseconds: 400),
            onChanged: (v) => setState(() => _centre = v),
          ),
        ],
      ),
    );
  }
}
