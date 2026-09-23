# Semantics

## What it is

What the package announces to assistive technology. Every interactive surface
is built by hand from `InkWell`, `GestureDetector` or `FlutterCheckbox`, and
none of those contributes a role or an enabled state, so every announcement is
attached here by hand. The surfaces are the trigger (both paths), the rows, the
checklist box, the empty state and the dismiss barrier.

## Governing decisions

- [ADR 0001 — accessibility semantics are attached by hand](../../adr/0001-accessibility-semantics-are-attached-by-hand.md#the-rules).
  Rules 1–5. Work in this area is filed as a conformance item under it, not as a
  fresh decision ([CLAUDE.md](../../../CLAUDE.md#agent-skills)).
- [ADR 0002](../../adr/0002-the-dismiss-barrier-stays-its-arena-participation-is-conditional.md#what-these-derive)
  covers the barrier half of #90 only.

## Design model

The rules live in ADR 0001 and are not restated here. What this territory adds
is **where each rule is satisfied**, because the sites are spread across four
files:

| Surface | Announces | Site |
|---|---|---|
| trigger, chromed | `button`, `enabled`, `expanded` | shell `build` |
| trigger, bare | the same, plus focus and activation | shell `_buildBareAnchor` |
| single-select row | `selected` | `TextItemPresentation.buildItem` / `CustomItemPresentation.buildItem` |
| checklist row | `checked`; the box is excluded | `MultiSelectPresentation.buildItem` |
| any row | `enabled` | shell `_buildItemWrapper` |
| empty state | its own container | shell `_buildOverlayContent` |
| barrier | nothing: `excludeFromSemantics` | controller `_buildEntry` |

This table is hand-written. No grep for `Semantics(` finds the barrier row, which
is satisfied by the *absence* of a node.

## Code

- `lib/src/shell/dropdown_menu_shell.dart` — `_DropdownMenuShellState.build`, `_DropdownMenuShellState._buildBareAnchor`, `_DropdownMenuShellState._buildItemWrapper`, `_DropdownMenuShellState._buildOverlayContent`
- `lib/src/presentation/item_presentation.dart` — `TextItemPresentation.buildItem`, `CustomItemPresentation.buildItem`, `MultiSelectPresentation.buildItem`, `MultiSelectPresentation.buildSelected`
- `lib/src/overlay/dropdown_overlay_controller.dart` — `DropdownOverlayController._buildEntry`
- `lib/src/widgets/smart_tooltip_text.dart` — `SmartTooltipText.semanticsLabel`

Tests: `test/semantics_role_state_test.dart`, `test/semantics_label_test.dart`, `test/dismiss_barrier_semantics_test.dart`, `test/presentation/multi_select_presentation_test.dart`.

## Reference behaviour

- [ADR 0001 — why a record](../../adr/0001-accessibility-semantics-are-attached-by-hand.md#why-a-record-rather-than-another-issue)
  pins that Material contradicts itself: `dropdown.dart` uses `menuItem`, while
  `list_tile.dart` uses `selected`.
- `flutter_checkbox`'s emitted semantics (`enabled: true` where Material emits
  `false`) are read at the pinned version
  ([references](../../agents/thegraph.md#references), #81).

## Cross-cutting invariants

- [A resolved style is complete or null](../invariant/resolved-style-complete-or-null.md).
  ADR 0001 rule 3 is the same rule for semantics nodes, and `Text.semanticsLabel`
  *replaces* what is read (#32, #37).
- [The Flutter floor is measured, not read](../invariant/flutter-floor-is-measured.md).
  On the floor, the empty state merged into the search field's node (#96).
- [The entry outlives the open menu](../invariant/entry-outlives-the-open-menu.md).
  `expanded` stays true through the close, deliberately.

## Blast radius

- [Trigger button](trigger-button.md), [menu shell](menu-shell.md),
  [item presentation](item-presentation.md) — the sites in the table above.
- [Multi-select](multi-select.md) — upgrading `flutter_checkbox` can change what
  the excluded box emits, and ADR 0001 rule 4 says to re-derive what each test
  discriminates.
- [Dismissal](dismissal.md) — the barrier's annotation.

## Known holes / open

- A row has no role ([ADR 0001, "Rule 1 vs. the menu row"](../../adr/0001-accessibility-semantics-are-attached-by-hand.md#what-these-contradict)).
- Structural roles, keyboard operation and announcement timing are all excluded
  by name ([non-scope](../../adr/0001-accessibility-semantics-are-attached-by-hand.md#what-this-record-does-not-cover)).
