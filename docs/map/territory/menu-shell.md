# Menu shell

## What it is

The unexported `DropdownMenuShell` that both public widgets are thin callers of:
it wires a controller, a search controller and a presentation together, then
draws the menu's content (the list or column of rows, the empty state, the
search field, the scrollbar wrap) and scrolls to a named row on open. **It does
not know what selection is.** It takes `isChosen`, `onItemTap` and `closeOnTap`,
and that is the seam
[CLAUDE.md](../../../CLAUDE.md#identity--invariants-the-boundary) draws.

At 975 lines it is the largest file in `lib/`. This map deliberately splits it:
the anchor it draws is [trigger button](trigger-button.md), the scrollbar wrap is
[scroll chrome](scroll-chrome.md), and the query is [search](search.md). This
note keeps the content body, row wrapping and scroll-to-item.

## Governing decisions

- [ADR 0001, rule 2](../../adr/0001-accessibility-semantics-are-attached-by-hand.md#the-rules).
  The shell must not choose between `selected` and `checked`, so that
  announcement lives in the presentation, not in `_buildItemWrapper`.

The selection seam itself (`isChosen`/`onItemTap`/`closeOnTap`) is stated in
CLAUDE.md, not in a record.

## Design model

- **Rows refuse a tap for three reasons, and only one is known at build time.**
  *Disabled* is `onTap: null`, the semantic gate, plus a guard for the one frame
  before the overlay rebuilds. *Gone* is `!isOpen`. *Going* is the animation in
  `reverse`. The last two are deliberately not build-time gates (#89).
- **`closeOnTap: false` repaints instead of closing.** The row calls
  `_menu.rebuild()`, because the overlay will not hear the owner's rebuild.
- **The empty state has its own semantics container**, sized to one row via
  `emptyStateHeight`. It reports the query only while the field is shown (#96).
- **Scroll-to-item indexes `widget.items`, not the filtered list,** so it is
  skipped while a query stands.
- **The list becomes a `ListView` only when it overflows**; otherwise it is a
  `Column`, and the scrollbar and gradient apply only on the `ListView` path.

## Code

- `lib/src/shell/dropdown_menu_shell.dart` — `DropdownMenuShell`, `_DropdownMenuShellState._buildSpec`, `_DropdownMenuShellState._buildOverlayContent`, `_DropdownMenuShellState._buildItemWrapper`, `_DropdownMenuShellState._scheduleScrollToItem`, `_DropdownMenuShellState.didUpdateWidget`, `_DropdownMenuShellState._openDropdown`, `_DropdownMenuShellState.actualItemHeight`

Tests: `test/selection_test.dart`, `test/scroll_to_selected_test.dart`, `test/layout_and_empty_state_test.dart`, `test/open_menu_refresh_test.dart`, `test/disabled_open_menu_test.dart`, `test/ghost_value_test.dart`.

## Reference behaviour

**None.** `material/dropdown.dart` scrolls its menu to the selected item too, but
nothing here has been compared against how it does it.

## Cross-cutting invariants

- [Chrome height has one source](../invariant/chrome-height-one-source.md)
- [No cached derived state](../invariant/no-cached-derived-state.md)
- [The overlay does not rebuild with its owner](../invariant/overlay-does-not-rebuild-with-owner.md)
- [The entry outlives the open menu](../invariant/entry-outlives-the-open-menu.md)

## Blast radius

- [Placement](placement.md) — `_buildSpec` feeds placement, and
  `_buildOverlayContent` must subtract the same chrome.
- [Item presentation](item-presentation.md) — every row and the button face come
  from the presentation. The shell adds only the wrapper and its `enabled`.
- [Search](search.md) — the visible list, the field, and the reset on
  open/close all run through the search controller.
- [Scroll chrome](scroll-chrome.md) — the `ListView` branch is the only one that
  gets a scrollbar and a gradient.
- [Multi-select](multi-select.md) and [trigger button](trigger-button.md) — a
  change to the shell's parameter list reaches both public widgets, which pass
  every parameter through.
- [Semantics](semantics.md) — the row wrapper's `Semantics(enabled:)` and the
  empty state's container.

## Known holes / open

- A menu row has no role. [ADR 0001](../../adr/0001-accessibility-semantics-are-attached-by-hand.md#what-these-contradict)
  ("Rule 1 vs. the menu row") records this as an open conformance item.
