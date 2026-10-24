# Tooltip

## What it is

The tooltip that shows an item's full text. `TooltipMode` sets when it appears:
only on overflow (the default), always, or never. `SmartTooltipText` measures
overflow with a `TextPainter` inside a `LayoutBuilder` and wraps the text in a
`Tooltip`. `DropdownTooltipTheme` styles it, and `DropdownTooltipTheme.resolve`
turns the box into a `ResolvedTooltipStyle`.

## Governing decisions

**None.** The rule it keeps (complete or null) is stated in
[CLAUDE.md](../../../CLAUDE.md#identity--invariants-the-boundary) and the
invariant note, not in a decision record.

## Design model

From the source unless a source is given.

- **The box is complete or null.** `Tooltip.decoration` replaces Flutter's
  default outright. If the theme sets no box field (`backgroundColor`,
  `borderRadius`, `border`, `shadow`) and no `decoration`, `_resolveDecoration`
  returns null and the ambient `TooltipTheme` keeps control. Otherwise every
  slot is filled, the default background and 4px radius included. An explicit
  `decoration` wins over all of them. #32 was a transparent tooltip caused by
  exactly that half-built value (CHANGELOG 2.5.0, FIX).
- **Resolution takes `Brightness`, not the ambient palette,** because Flutter's
  own tooltip background switches on brightness alone. An earlier claim that
  `resolve()` needed no ambient value was corrected for this
  ([lessons, #32](../../agents/lessons.md)).
- **Reading and deciding are split for the box only.** `_buildWithTooltip` reads
  `Theme.of(context).brightness` and hands it to `resolve`. The text style
  (`textStyle`, else `textColor`) and `preferBelow` are still decided inside the
  widget.
- **Overflow is measured, not guessed, on every layout,** but only in
  `onlyWhenOverflow` mode. `_checkTextOverflow` returns false for an unbounded
  width. It reports overflow when `maxLines` is exceeded, or, with no `maxLines`
  and `softWrap: false`, when the single line is wider than the box. `always`
  skips the measurement. `disabled` or `enabled: false` returns plain text.
- **`preferBelow` defaults to whichever side has more room**
  (`_calculatePreferBelow`), and falls back to below when it cannot measure.

## Code

- `lib/src/theme/tooltip_theme.dart` — `DropdownTooltipTheme`, `DropdownTooltipTheme.resolve`, `DropdownTooltipTheme._resolveDecoration`, `DropdownTooltipTheme._defaultBackground`, `DropdownTooltipTheme._defaultRadius`
- `lib/src/theme/resolved_dropdown_style.dart` — `ResolvedTooltipStyle`
- `lib/src/widgets/smart_tooltip_text.dart` — `SmartTooltipText.build`, `SmartTooltipText._buildWithTooltip`, `SmartTooltipText._checkTextOverflow`, `SmartTooltipText._calculatePreferBelow`
- `lib/src/config/text_dropdown_config.dart` — `TooltipMode`

Tests: `test/tooltip_decoration_test.dart`, `test/theme/tooltip_resolve_test.dart`, `test/text_label_test.dart` ("an overflowing label gets a tooltip"), `test/remaining_behaviours_test.dart` (modes).

## Reference behaviour

**None.** There is no stored pin. The default background
(`_defaultBackground`: grey 700 or white, both at 0.9 alpha) was read from
Flutter's `Tooltip` source for #32. The floor finding, that `Tooltip.constraints`
does not exist on 3.27 or 3.29, came from CI (#47). Both are recorded only in
[lessons](../../agents/lessons.md) and in the `minimum` entry's comment in
`.github/workflows/ci.yml`.

## Cross-cutting invariants

- [A resolved style is complete or null](../invariant/resolved-style-complete-or-null.md)
- [The Flutter floor is measured, not read](../invariant/flutter-floor-is-measured.md).
  `Tooltip.constraints`, passed by `_buildWithTooltip`, is what set the 3.32
  floor.

## Blast radius

- [Text items](text-items.md) — the host widget. Overflow is measured with the
  text's own `style`, `maxLines` and `softWrap`, so a change to how text is
  drawn changes when the tooltip appears.
- [Theme resolution](theme-resolution.md) — `DropdownTooltipTheme` is a slot of
  `DropdownStyleTheme`. A change to the complete-or-null rule there must reach
  `_resolveDecoration` too, which resolves on `Brightness` and not on the shared
  ambient palette.

## Known holes / open

- `Tooltip.textStyle` is handed `theme.textStyle`, or a colour-only
  `TextStyle(color: textColor)`, with no fill from the default. Whether
  `Tooltip.textStyle` replaces or merges with Flutter's default was not checked.
  If it replaces, a caller who sets only `fontSize` gets text with no tooltip
  colour, which would break the complete-or-null rule. Not compared, because no
  Flutter checkout is reachable from this repo.
- `_calculatePreferBelow` calls `context.findRenderObject()` during build, so it
  reads the previous frame's geometry. On the first build it has no size and
  answers "below".
- `textStyle`/`textColor` and `preferBelow` are decided in the widget, not in
  `resolve`. That is the one place in this theme where the reading/deciding
  split is not kept.
