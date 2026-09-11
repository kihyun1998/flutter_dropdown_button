/// The button's face: its box, the text on it, and the tooltip for what did not fit.
library;

import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';

/// Three classes describe the closed control, and they hand off to each other.
///
/// [DropdownButtonTheme] draws the box and the chevron. [TextDropdownConfig]
/// decides what the text does when it is too long for that box. And
/// [DropdownTooltipTheme] is what shows the part that got cut — so the three
/// are one story read in order, not three settings pages.
///
/// **`decoration` replaces its neighbours.** The second pair below sets
/// [DropdownButtonTheme.decoration] and [DropdownButtonTheme.disabledDecoration],
/// and from that moment `backgroundColor`, `border`, `borderRadius` and the
/// disabled colours on the same object are not read. The last tooltip does the
/// same thing to its own. Fill every slot the ambient default would, or hand it
/// nothing.
///
/// **Disabled is a second full set, not a tint.** `disabledBackgroundColor`,
/// `disabledBorder`, `iconDisabledColor` and
/// [TextDropdownConfig.disabledTextStyle] are separate values, and a control
/// that sets only some of them goes half-grey.
///
/// **`semanticsLabel` describes the control, not the string.** It is merged
/// into the trigger's announcement rather than replacing the visible text
/// (ADR-0001, #37), so it reads as "what is this" and not as a second copy of
/// the value.
class ButtonThemeRecipe extends StatefulWidget {
  const ButtonThemeRecipe({super.key});

  @override
  State<ButtonThemeRecipe> createState() => _ButtonThemeRecipeState();
}

const _envs = ['Production', 'Staging', 'Development'];

/// Long enough that the box cannot hold it, which is what the tooltip is for.
const _pipelines = [
  'release/2026.03 · web · canary · eu-central-1',
  'release/2026.03 · web · stable · us-east-1',
  'hotfix/session-leak · api · canary · ap-northeast-2',
];

class _ButtonThemeRecipeState extends State<ButtonThemeRecipe> {
  String? _themed;
  String? _decorated;
  String? _pipeline;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _caption(
          context,
          'Themed field by field',
          'Every field DropdownButtonTheme declares, plus the whole of '
              'TextDropdownConfig. The same two are drawn twice — enabled, and '
              'disabled — because the disabled look is its own set of values.',
        ),
        Row(
          children: [
            SizedBox(
              width: 300,
              child: FlutterDropdownButton<String>.text(
                items: _envs,
                value: _themed,
                hint: 'Environment',
                onChanged: (v) => setState(() => _themed = v),
                // A chevron of our own. The theme's `icon` below is the
                // default one; this replaces the widget outright.
                trailing: const Icon(Icons.unfold_more, size: 18),
                theme: _faceTheme,
                config: _textConfig,
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 300,
              child: FlutterDropdownButton<String>.text(
                items: _envs,
                value: 'Production',
                hint: 'Environment',
                // The whole point of this one.
                enabled: false,
                onChanged: (_) {},
                theme: _faceTheme,
                config: _textConfig,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _caption(
          context,
          'Themed with a decoration',
          'decoration and disabledDecoration replace backgroundColor, border, '
              'borderRadius and the disabled colours rather than merging with '
              'them. Neither button below sets one of those, and both are '
              'complete.',
        ),
        Row(
          children: [
            SizedBox(
              width: 300,
              child: FlutterDropdownButton<String>.text(
                items: _envs,
                value: _decorated,
                hint: 'Environment',
                onChanged: (v) => setState(() => _decorated = v),
                theme: _decoratedFaceTheme,
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 300,
              child: FlutterDropdownButton<String>.text(
                items: _envs,
                value: 'Staging',
                hint: 'Environment',
                enabled: false,
                onChanged: (_) {},
                theme: _decoratedFaceTheme,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _caption(
          context,
          'The tooltip for what did not fit',
          'These values are wider than the box. The text ellipsises and the '
              'tooltip carries the rest — every field DropdownTooltipTheme '
              'declares, including the durations that decide how long a reader '
              'has to see it.',
        ),
        Row(
          children: [
            SizedBox(
              width: 300,
              child: FlutterDropdownButton<String>.text(
                items: _pipelines,
                value: _pipeline ?? _pipelines.first,
                hint: 'Pipeline',
                onChanged: (v) => setState(() => _pipeline = v),
                theme: _tooltipTheme,
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 300,
              child: FlutterDropdownButton<String>.text(
                items: _pipelines,
                value: _pipelines.last,
                hint: 'Pipeline',
                onChanged: (_) {},
                theme: _decoratedTooltipTheme,
              ),
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

/// The box and the chevron, named field by field.
const _faceTheme = DropdownStyleTheme(
  button: DropdownButtonTheme(
    backgroundColor: Color(0xFF1B1F27),
    border: Border.fromBorderSide(BorderSide(color: Color(0xFF39404E))),
    borderRadius: 10,
    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    hoverColor: Color(0xFF232936),
    splashColor: Color(0xFF2F3949),
    highlightColor: Color(0xFF262D3A),
    height: 22,
    icon: Icons.keyboard_arrow_down_rounded,
    iconColor: Color(0xFF9AA6BF),
    iconSize: 20,
    iconPadding: EdgeInsets.only(left: 8),
    // Disabled is its own complete set, not a tint of the above.
    disabledBackgroundColor: Color(0xFF141821),
    disabledBorder: Border.fromBorderSide(BorderSide(color: Color(0xFF262B35))),
    iconDisabledColor: Color(0xFF4A5367),
  ),
);

/// The same box as one decoration each for the two states.
final _decoratedFaceTheme = DropdownStyleTheme(
  button: DropdownButtonTheme(
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF2B3448), Color(0xFF1C2230)],
      ),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFF44506B)),
    ),
    disabledDecoration: BoxDecoration(
      color: const Color(0xFF141821),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFF262B35)),
    ),
  ),
);

/// What the text on the button does, in every state it has one.
const _textConfig = TextDropdownConfig(
  overflow: TextOverflow.ellipsis,
  maxLines: 1,
  softWrap: false,
  textAlign: TextAlign.start,
  textStyle: TextStyle(fontSize: 14, color: Color(0xFFD7DEEC)),
  hintStyle: TextStyle(fontSize: 14, color: Color(0xFF7A8296)),
  selectedTextStyle: TextStyle(
    fontSize: 14,
    color: Colors.white,
    fontWeight: FontWeight.w600,
  ),
  disabledTextStyle: TextStyle(fontSize: 14, color: Color(0xFF5A6377)),
  // The three below are passed straight to the `Text` that draws the value.
  textDirection: TextDirection.ltr,
  locale: Locale('en', 'US'),
  textScaler: TextScaler.noScaling,
  // Merged into the trigger's announcement, not a second copy of the value.
  semanticsLabel: 'Deployment environment',
);

/// Every field the tooltip declares.
final _tooltipTheme = DropdownStyleTheme(
  button: const DropdownButtonTheme(
    backgroundColor: Color(0xFF1B1F27),
    border: Border.fromBorderSide(BorderSide(color: Color(0xFF39404E))),
  ),
  tooltip: DropdownTooltipTheme(
    // `always` so it is visible without hovering a value that happens to
    // overflow. `onlyWhenOverflow` is the default and the better choice in an
    // app: it measures the text and stays quiet when nothing was cut.
    mode: TooltipMode.always,
    enabled: true,
    backgroundColor: const Color(0xFF0E1218),
    textColor: const Color(0xFFE6ECF7),
    textStyle: const TextStyle(fontSize: 12, height: 1.35),
    textAlign: TextAlign.start,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: const Color(0xFF39404E)),
    shadow: const [
      BoxShadow(color: Color(0x88000000), blurRadius: 12, offset: Offset(0, 4)),
    ],
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    margin: const EdgeInsets.all(8),
    constraints: const BoxConstraints(maxWidth: 320),
    verticalOffset: 22,
    preferBelow: true,
    enableTapToDismiss: true,
    triggerMode: TooltipTriggerMode.tap,
    waitDuration: const Duration(milliseconds: 300),
    showDuration: const Duration(seconds: 4),
    exitDuration: const Duration(milliseconds: 120),
  ),
);

/// The same tooltip described as one decoration.
///
/// `Tooltip.decoration` is one of the Flutter slots that **replace** the
/// ambient value rather than merging into it, which is why this object names no
/// `backgroundColor`, `border`, `borderRadius` or `shadow`: they would not be
/// read. Every visual property the tooltip has is inside the decoration, or it
/// is gone — and that is the rule `CLAUDE.md` states for this whole package.
final _decoratedTooltipTheme = DropdownStyleTheme(
  button: const DropdownButtonTheme(
    backgroundColor: Color(0xFF1B1F27),
    border: Border.fromBorderSide(BorderSide(color: Color(0xFF39404E))),
  ),
  tooltip: DropdownTooltipTheme(
    mode: TooltipMode.always,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF1A2233), Color(0xFF0C1017)],
      ),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFF44506B)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x99000000),
          blurRadius: 14,
          offset: Offset(0, 5),
        ),
      ],
    ),
    textColor: const Color(0xFFE6ECF7),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
    constraints: const BoxConstraints(maxWidth: 320),
  ),
);
