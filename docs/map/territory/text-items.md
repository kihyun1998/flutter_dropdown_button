# Text items

## What it is

Rendering an item as a string. `.text()` and the checklist turn a `T` into text
through `label` (or `T == String`) and draw each run with `SmartTooltipText`.
That gives them overflow handling, `maxLines`, text styles for the selected and
disabled states, and alignment, all configured by `TextDropdownConfig`. The same
config's `semanticsLabel` is attached to the button face by the presentation,
not by `SmartTooltipText`. What sets this apart from custom mode is that the
package knows what an item *says*, which is also what makes a default search
filter possible.

## Governing decisions

**None.** [ADR 0001](../../adr/0001-accessibility-semantics-are-attached-by-hand.md#what-these-derive)
derives #37's `semanticsLabel` placement from its rule 4, but it governs
semantics emission, not how text is rendered.

## Design model

From the source and dartdoc unless a source is given.

- **`label` or `String`, enforced twice.** An assert in the *presentation's*
  constructor (`TextItemPresentation`, `MultiSelectPresentation`), which runs on
  the widget's first build, not in the widget's own `const` constructor. A throw
  in `labelOf` covers release builds, where the assert is compiled out
  (`test/text_label_test.dart`, "omitting label for a non-String T fails
  immediately"; `test/presentation/multi_select_presentation_test.dart`,
  "a non-String T without a label fails at construction").
- **`TextDropdownConfig` is text-only configuration.** Tooltip behaviour and
  styling live in `DropdownTooltipTheme`, not here (the `TextDropdownConfig`
  dartdoc; CHANGELOG 1.5.0 moved the styling out).
- **`textAlign` does two jobs.** It is passed to every `Text`, and `_alignmentOf`
  turns it into `contentAlignment`, which the shell uses to place both the
  button face (`_buildButtonContent`) and every row (`_buildOverlayContent`).
- **Styles by state:** a row takes `selectedTextStyle ?? textStyle` when chosen,
  otherwise `textStyle`. The face takes `hintStyle` for the hint and `textStyle`
  for a value, with `disabledTextStyle` merged over either when the button is
  disabled. A null style is passed through as null.
- **`semanticsLabel` describes the control, not the item.** Both
  `buildSelected`s wrap the face in `Semantics(label:)`, which merges, so the
  selected value is still read. The rows never get it. The merged string
  (`"Fruit picker\nBanana"`) is the contract ([lessons, #37](../../agents/lessons.md);
  `test/semantics_label_test.dart`). `Text.semanticsLabel` is not used for it,
  because that *replaces* what is read ([lessons, #32 probe](../../agents/lessons.md)).
- **Input bound:** nothing bounds a label's length. `maxLines` (default 1) and
  `overflow` bound what is drawn, and the tooltip shows the rest.

## Code

- `lib/src/config/text_dropdown_config.dart` — `TextDropdownConfig`, `TooltipMode`
- `lib/src/widgets/smart_tooltip_text.dart` — `SmartTooltipText`, `SmartTooltipText._buildText`
- `lib/src/presentation/item_presentation.dart` — `TextItemPresentation.labelOf`, `TextItemPresentation._text`, `TextItemPresentation.contentAlignment`, `TextItemPresentation.buildSelected`, `MultiSelectPresentation.labelOf`, `MultiSelectPresentation._text`, `MultiSelectPresentation.buildSelected`, `_alignmentOf`

Tests: `test/text_label_test.dart`, `test/semantics_label_test.dart`, `test/disabled_state_test.dart`, `test/presentation/item_presentation_test.dart`.

## Reference behaviour

**None.**

## Cross-cutting invariants

- [A resolved style is complete or null](../invariant/resolved-style-complete-or-null.md).
  `Text.semanticsLabel` replaces what is read. The package always hands it null
  and puts the label on a merging `Semantics` wrapper instead (#32, #37).

## Blast radius

- [Tooltip](tooltip.md) — `SmartTooltipText` is the tooltip's only host, and it
  measures overflow with the same `style`, `maxLines` and `softWrap` it draws
  with. A config change that reaches `Text` but not the measurement shows the
  tooltip at the wrong time.
- [Item presentation](item-presentation.md) — both text presentations copy the
  config pass-throughs into their own `_text`. A new config field added to one
  copy is missing from the other widget.
- [Semantics](semantics.md) — `semanticsLabel` must stay on the face only. Put
  on a row, it replaces every item's name with the same phrase.

## Known holes / open

- `_alignmentOf` maps `TextAlign.start` to `Alignment.centerLeft` and
  `TextAlign.end` to `Alignment.centerRight` whatever the text direction. Under
  RTL a `start`-aligned face and its rows sit on the left. Nothing tests RTL.
- `TextDropdownConfig.selectedTextStyle`'s dartdoc says it applies "in both the
  button and the dropdown overlay". `buildSelected` never reads it: only rows
  do.
- `TextDropdownConfig.hintStyle`'s dartdoc says a null hint style "uses a muted
  version of the regular text style". Nothing mutes it; null is passed through.
- `SmartTooltipText.semanticsLabel` is a parameter nothing in `lib/` passes. It
  is left over from before #37. `SmartTooltipText` is not exported from the
  barrel, so removing it would not be a breaking change.
