# Tooltip

## What it is

The tooltip that shows an item's full text. It appears only on overflow, always,
or never (`TooltipMode`). `SmartTooltipText` measures overflow with a
`TextPainter` inside a `LayoutBuilder` and wraps the text in a `Tooltip`.
`DropdownTooltipTheme` styles it and resolves the box.

## Governing decisions

**None.**

## Design model

- **The box is complete or null.** `Tooltip.decoration` replaces Flutter's
  default outright. If the theme touches no box slot, `resolve` returns null and
  the ambient `TooltipTheme` keeps control; otherwise every slot is filled,
  including the default background. #32 was a transparent tooltip, from
  exactly that half-built value.
- **Resolution takes `Brightness`, not the ambient palette,** because Flutter's
  own tooltip default switches on brightness alone (#32 corrected an
  "ambient-free" `resolve`).
- **Overflow is measured, not guessed,** per layout.

## Code

- `lib/src/theme/tooltip_theme.dart` — `DropdownTooltipTheme`, `DropdownTooltipTheme.resolve`, `DropdownTooltipTheme._resolveDecoration`, `DropdownTooltipTheme._defaultBackground`
- `lib/src/widgets/smart_tooltip_text.dart` — `SmartTooltipText._buildWithTooltip`, `SmartTooltipText._checkTextOverflow`, `SmartTooltipText._calculatePreferBelow`
- `lib/src/config/text_dropdown_config.dart` — `TooltipMode`

Tests: `test/tooltip_decoration_test.dart`.

## Reference behaviour

**None.** There is no stored pin. The default background was read from Flutter's
`Tooltip` source for #32, and the floor finding that `Tooltip.constraints` is absent
on 3.27 and 3.29 came from CI (#47). Both are recorded in
[lessons](../../agents/lessons.md) only.

## Cross-cutting invariants

- [A resolved style is complete or null](../invariant/resolved-style-complete-or-null.md)
- [The Flutter floor is measured, not read](../invariant/flutter-floor-is-measured.md). `Tooltip.constraints` set the floor.

## Blast radius

- [Text items](text-items.md) — the host widget.
- [Theme resolution](theme-resolution.md) — its sub-theme.

## Known holes / open

**None recorded.**
