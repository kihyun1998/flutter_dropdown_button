# Text items

## What it is

Rendering an item as a string: `.text()` and the checklist turn a `T` into text
through `label` (or `T == String`) and draw it with `SmartTooltipText`. That
gives them overflow handling, `maxLines`, text styles for the selected and
disabled states, alignment, and an optional `semanticsLabel`, all configured by
`TextDropdownConfig`. What sets this apart from custom mode is that the package
knows what an item *says*.

## Governing decisions

**None.**

## Design model

- **`label` or `String`, enforced twice:** an assert in the constructor, and an
  unreachable-in-debug throw in `labelOf` for release builds.
- **`TextDropdownConfig` is text-only configuration.** Tooltip behaviour and
  styling live in `DropdownTooltipTheme`, not here.
- **`textAlign` becomes `contentAlignment`,** which positions both the button
  face and every row.
- **`semanticsLabel` describes the control, not the item.** It is attached to
  the button face only, and the merged string is the contract (#37).

## Code

- `lib/src/config/text_dropdown_config.dart` — `TextDropdownConfig`, `TooltipMode`
- `lib/src/widgets/smart_tooltip_text.dart` — `SmartTooltipText`, `SmartTooltipText._buildText`
- `lib/src/presentation/item_presentation.dart` — `TextItemPresentation.labelOf`, `TextItemPresentation._text`, `TextItemPresentation.contentAlignment`, `MultiSelectPresentation.labelOf`

Tests: `test/text_label_test.dart`, `test/semantics_label_test.dart`.

## Reference behaviour

**None.**

## Cross-cutting invariants

- [A resolved style is complete or null](../invariant/resolved-style-complete-or-null.md). `Text.semanticsLabel` replaces what is read, it does not add to it (#32).

## Blast radius

- [Tooltip](tooltip.md) — `SmartTooltipText` is the tooltip's only host.
- [Item presentation](item-presentation.md) — both text presentations route
  every run through `_text`.
- [Semantics](semantics.md) — `semanticsLabel`.

## Known holes / open

**None recorded.**
