# Single-select

## What it is

`FlutterDropdownButton<T>`'s selection policy, the twin of
[multi-select](multi-select.md). It is a `StatefulWidget` over the
[menu shell](menu-shell.md), and its `build` says what single selection means
once: `isChosen` is `widget.value == item`, a tap hands the item straight to
`onChanged` (`onItemTap: widget.onChanged`), and `closeOnTap` is true. On open,
`scrollToSelectedItem`/`scrollToSelectedDuration` become the shell's
`scrollToItem`/`scrollToItemDuration`. Two more pieces of policy live here and
nowhere else. A **ghost value**, a `value` that is not in `items`, is drawn
rather than replaced by the hint. **Single-item mode** (`disableWhenSingleItem`,
`hideIconWhenSingleItem`) disables a one-item dropdown and chooses that item for
the caller. **Cardinality is a type:** these fields exist on this widget and
not on the checklist
([CLAUDE.md](../../../CLAUDE.md#identity--invariants-the-boundary)).

## Governing decisions

- [ADR 0001, rule 2](../../adr/0001-accessibility-semantics-are-attached-by-hand.md#the-rules).
  A single-select row is `selected`. The word is said by the presentations this
  widget builds (`CustomItemPresentation.buildItem`,
  `TextItemPresentation.buildItem`), not by the shell.

The selection seam and "cardinality is a type" are stated in CLAUDE.md, not in a
record. The ghost-value rule is a CHANGELOG decision (3.1.0: "The widget draws
what it was handed"). Single-item mode predates every record (1.3.0, 1.6.0).

## Design model

Source: the widget's code and dartdoc, CHANGELOG entries, and the tests named.
Only rule 2 above comes from a record.

- **`value` belongs to the caller.** The widget never stores a selection. It
  reads `widget.value` in `isChosen`, in `scrollToItem` and in the presentation.
  A tap reports the item and closes the menu. `T` needs only `==`
  (`isChosen` and `List.indexOf`), where multi-select also needs `hashCode`.
- **A ghost value is drawn, not audited.** `CustomItemPresentation.buildSelected`
  and `TextItemPresentation.buildSelected` render any non-null `value`, and fall
  back to the hint only on null. The menu iterates `items`, so a ghost is never
  a row, and scroll-to-item finds no index for it (`indexOf == -1`) and stays
  put. Custom mode used to show `hintWidget` for a ghost while text mode drew
  it. 3.1.0 made both draw it (CHANGELOG 3.1.0; `test/ghost_value_test.dart`,
  where the text-mode case is a guard so the two cannot drift apart again). The
  checklist's twin rule is that a value no longer in `items` still counts toward
  `labelBuilder`.
- **Single-item mode is caller-side policy.** `_isSingleItemDisabled` is
  `disableWhenSingleItem && items.length == 1`. The shell receives the result
  only as `enabled: isEnabled` (`!_isSingleItemDisabled && widget.enabled`) and
  `showTrailing: _showTrailing` (false only when single-item-disabled *and*
  `hideIconWhenSingleItem`). The dartdoc's "only applies when
  `disableWhenSingleItem` is true" is that conjunction.
- **There is one `enabled` below this widget.** The shell is handed the combined
  value and has no second source. Twice a site read `widget.enabled` instead of
  `isEnabled`: taps in 1.6.0, and the arrow's colour in 2.4.1 (CHANGELOG 1.6.0,
  2.4.1; `test/disabled_state_test.dart`, "a single-item dropdown disabled by
  policy draws the disabled icon colour too").
- **The only item is chosen after the frame.** `_autoSelectSingleItem` runs from
  `initState` and from every `didUpdateWidget`. When single-item-disabled and
  `value != items.first`, it schedules a post-frame `onChanged(items.first)`,
  guarded by `mounted`. In single-item mode this replaces a ghost value: policy
  wins over the ghost rule.
- **A list that shrinks to one item closes an open menu.** No code here closes
  it. `isEnabled` turns false, and the shell's `didUpdateWidget` rebuilds and
  then closes. The one-frame row guard keeps a tap in that frame from adding a
  second `onChanged` (#89, CHANGELOG 4.2.0; `test/disabled_open_menu_test.dart`,
  group "disableWhenSingleItem — reached without touching `enabled`").
- **Scroll-to-selected is once per open,** not once per rebuild (#157, CHANGELOG
  4.3.1). The mechanism and its rules are the shell's. This widget only chooses
  whether to pass `value` or null (`scrollToSelectedItem`, default `true`).
- **Outside input:** `items` and `value` come from the caller. Nothing bounds
  the list's length, and nothing requires `value` to be in it.

## Code

- `lib/src/flutter_dropdown_button.dart` — `FlutterDropdownButton`, `FlutterDropdownButton.value`, `FlutterDropdownButton.disableWhenSingleItem`, `FlutterDropdownButton.hideIconWhenSingleItem`, `FlutterDropdownButton.scrollToSelectedItem`, `FlutterDropdownButton.scrollToSelectedDuration`, `_FlutterDropdownButtonState._isSingleItemDisabled`, `_FlutterDropdownButtonState.isEnabled`, `_FlutterDropdownButtonState._showTrailing`, `_FlutterDropdownButtonState._autoSelectSingleItem`, `_FlutterDropdownButtonState.build`
- `lib/src/presentation/item_presentation.dart` — `CustomItemPresentation.buildSelected`, `TextItemPresentation.buildSelected` (where the ghost value is drawn)

Tests: `test/ghost_value_test.dart`, `test/scroll_to_selected_test.dart`, `test/selection_test.dart`, `test/disabled_state_test.dart`, `test/disabled_open_menu_test.dart`.

## Reference behaviour

- `material/dropdown.dart` scrolls to the selected item once per route, in
  `_DropdownRoutePageState.initState` (attributed to #157). The comparison is
  recorded in [menu shell](menu-shell.md#reference-behaviour).

Material's handling of a `value` absent from `items`, and of single-item lists,
has **not** been compared.

## Cross-cutting invariants

- [The overlay does not rebuild with its owner](../invariant/overlay-does-not-rebuild-with-owner.md). A new `value`, or a single-item `enabled: false`, reaches an open menu only through the shell's post-frame `rebuild()`.
- [The entry outlives the open menu](../invariant/entry-outlives-the-open-menu.md). `closeOnTap: true` starts a close, and the menu's rows stay mounted through the reverse. A tap there must not hand back the selection the user dismissed (`test/disabled_open_menu_test.dart`, `SingleHost`).
- [No cached derived state](../invariant/no-cached-derived-state.md). `_isSingleItemDisabled`, `isEnabled`, `_showTrailing` and `_presentation` are getters, re-derived on every read.

## Blast radius

- [Menu shell](menu-shell.md) — every shell parameter is passed through, and
  `scrollToItem` assumes the shell indexes the unfiltered `items` with `==`.
- [Multi-select](multi-select.md) — the twin. A policy added here (a field, a
  rule about values not in `items`) is either added there or deliberately
  absent from that type, never asserted against.
- [Trigger button](trigger-button.md) — single-item mode reaches the trigger as
  `enabled`/`showTrailing` only. A trigger site that reads anything else drifts
  from the control's behaviour.
- [Item presentation](item-presentation.md) — the ghost rule lives in
  `buildSelected` of both single-select presentations, so a third presentation
  must draw a non-null `value` too.
- [Semantics](semantics.md) — the row says `selected`, the word for this
  cardinality.
- [Single-open](single-open.md) — `FlutterDropdownButton.closeAll` forwards to
  the shared registry.

## Known holes / open

- `_autoSelectSingleItem` re-arms on every `didUpdateWidget` while
  `value != items.first`. A caller whose `onChanged` does not write `value` back
  gets `onChanged` once per rebuild, indefinitely. The comment in
  `test/disabled_open_menu_test.dart`'s host notes this ("a host that never
  writes it back re-arms that callback forever"). Nothing guards it, and no
  dartdoc warns about it.
- `onChanged` is typed `ValueChanged<T?>`, but the widget never calls it with
  null. Nothing in the API can clear a selection.
