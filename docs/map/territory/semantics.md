# Semantics

## What it is

What the package announces to assistive technology. Every interactive surface
is built by hand: an `InkWell` (the chromed trigger, the rows) or a
`GestureDetector` with a `FocusableActionDetector` (the bare trigger). None of
these contributes a role or an enabled state, so every announcement is attached
here by hand. The surfaces are the trigger (both paths), the rows, the empty
state and the dismiss barrier. The checklist's `FlutterCheckbox` is not an
interactive surface: it is presentational and excluded.

## Governing decisions

- [ADR 0001 — accessibility semantics are attached by hand](../../adr/0001-accessibility-semantics-are-attached-by-hand.md#the-rules).
  Rules 1–5. Work in this area is filed as a conformance item under it, not as a
  fresh decision ([CLAUDE.md](../../../CLAUDE.md#agent-skills)).
- [ADR 0002](../../adr/0002-the-dismiss-barrier-stays-its-arena-participation-is-conditional.md#what-these-derive)
  covers only the barrier half of #90.

## Design model

The rules live in ADR 0001 and are not restated here. What this territory adds
is **where each rule is satisfied**, because the sites are spread across three
files:

| Surface | Announces | Site |
|---|---|---|
| trigger, chromed | `button`, `enabled`, `expanded` | shell `build` |
| trigger, bare | the same; focus and activation come from `FocusableActionDetector` | shell `_buildBareAnchor` |
| single-select row | `selected` | `TextItemPresentation.buildItem` / `CustomItemPresentation.buildItem` |
| checklist row | `checked`; the box is excluded | `MultiSelectPresentation.buildItem` |
| any row | `enabled` | shell `_buildItemWrapper` |
| button face (text modes) | `semanticsLabel`, merged with the value | `TextItemPresentation.buildSelected` / `MultiSelectPresentation.buildSelected` |
| empty state | its own container | shell `_buildOverlayContent` |
| barrier | nothing: `excludeFromSemantics` | controller `_buildEntry` |

This table is written by hand. Part of it can be listed by a tool:

```sh
rg -n 'Semantics\(|ExcludeSemantics|excludeFromSemantics' lib/
```

That finds every row except the meaning of the barrier row, which is kept by the
*absence* of a node, and the bare trigger's focus, which comes from a detector
and not from a `Semantics`.

- **`expanded` reads `isOpen`**, so it stays true through the close animation.
  This is deliberate (ADR 0001, "Rule 3 vs. the trigger's open state"; the
  comment in `_DropdownMenuShellState.build`).
- **A disabled row keeps focus.** `Semantics(enabled:)` in `_buildItemWrapper`
  sits under the row's `InkWell`, so the row stays focusable and says it is
  disabled (the comment there, measured).
- **Input bound:** not applicable. This territory only declares flags.

## Code

- `lib/src/shell/dropdown_menu_shell.dart` — `_DropdownMenuShellState.build`, `_DropdownMenuShellState._buildBareAnchor`, `_DropdownMenuShellState._buildItemWrapper`, `_DropdownMenuShellState._buildOverlayContent`
- `lib/src/presentation/item_presentation.dart` — `TextItemPresentation.buildItem`, `TextItemPresentation.buildSelected`, `CustomItemPresentation.buildItem`, `MultiSelectPresentation.buildItem`, `MultiSelectPresentation.buildSelected`
- `lib/src/overlay/dropdown_overlay_controller.dart` — `DropdownOverlayController._buildEntry`

Tests: `test/semantics_role_state_test.dart`, `test/semantics_label_test.dart`, `test/dismiss_barrier_semantics_test.dart`, `test/presentation/multi_select_presentation_test.dart`, `test/bare_anchor_test.dart`.

## Reference behaviour

- [ADR 0001 — why a record](../../adr/0001-accessibility-semantics-are-attached-by-hand.md#why-a-record-rather-than-another-issue)
  pins that Material contradicts itself: `material/dropdown.dart` uses
  `menuItem` and never emits `selected`, while `material/list_tile.dart` emits
  `selected`.
- `flutter_checkbox`'s emitted semantics (`enabled: true` where Material emits
  `false`) were read from its source for #81
  ([references](../../agents/thegraph.md#references),
  [lessons](../../agents/lessons.md)).

## Cross-cutting invariants

- [A resolved style is complete or null](../invariant/resolved-style-complete-or-null.md).
  ADR 0001 rule 3 is the same rule for semantics nodes. `Text.semanticsLabel`
  *replaces* what is read, so the face's label goes on a merging `Semantics`
  instead (#32, #37).
- [The Flutter floor is measured, not read](../invariant/flutter-floor-is-measured.md).
  At the 3.32 floor the empty-state text merged into the search field's node
  (#96; ADR 0001, "What these derive").
- [The entry outlives the open menu](../invariant/entry-outlives-the-open-menu.md).
  `expanded` stays true through the close, deliberately.

## Blast radius

- [Trigger button](trigger-button.md) — ADR 0001 rule 5: both anchor paths
  must announce the same thing. A change to one path's `Semantics` that is not
  made on the other splits the contract.
- [Menu shell](menu-shell.md) — the row's `enabled` and the empty state's
  container are set there. A wrapper added above the row's `InkWell` changes
  what merges into the row.
- [Item presentation](item-presentation.md) — the row's state word is the
  presentation's (rule 2). A new presentation that leaves it out leaves its rows
  silent.
- [Single-select](single-select.md) — `selected` is what a single-select row
  announces. A change to what counts as chosen there changes what is announced.
- [Multi-select](multi-select.md) — upgrading `flutter_checkbox` can change what
  the excluded box emits, and ADR 0001 rule 4 says to re-derive what each test
  checks.
- [Dismissal](dismissal.md) — the barrier must not annotate the tree. A
  barrier that annotates again, or `ExcludeSemantics` in place of
  `excludeFromSemantics`, either names the screen after the empty state or
  removes the menu from the tree.

## Known holes / open

- A row has no role ([ADR 0001, "Rule 1 vs. the menu row"](../../adr/0001-accessibility-semantics-are-attached-by-hand.md#what-these-contradict)).
- Structural roles, keyboard operation and announcement timing are all excluded
  by name ([non-scope](../../adr/0001-accessibility-semantics-are-attached-by-hand.md#what-this-record-does-not-cover)).
- `SmartTooltipText.semanticsLabel` still exists, and nothing passes it. A
  future caller that passed one would bring back the #37 replacement bug. See
  [text items](text-items.md).
