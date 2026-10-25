# Menu shell

## What it is

The unexported `DropdownMenuShell` that both public widgets are thin callers of.
It wires a `DropdownOverlayController`, a `DropdownSearchController` and a
`DropdownItemPresentation` together, then draws the menu's content: the list or
column of rows, the empty state, the search field and the scrollbar wrap. It
also scrolls to a named row on open. **It does not know what selection is.** It
takes `isChosen`, `onItemTap` and `closeOnTap`, and that is the seam
[CLAUDE.md](../../../CLAUDE.md#identity--invariants-the-boundary) draws. What a
caller passes for those three is the [single-select](single-select.md) or
[multi-select](multi-select.md) policy.

`dropdown_menu_shell.dart` is the largest file in `lib/` (`find lib -name '*.dart' | xargs wc -l | sort -n`),
and this map splits it. The anchor it draws is [trigger button](trigger-button.md),
the scrollbar wrap is [scroll chrome](scroll-chrome.md), and the query is
[search](search.md). This note keeps the content body, the row wrapper, the
reaction to the owner's rebuild, and scroll-to-item.

## Governing decisions

- [ADR 0001, rule 2](../../adr/0001-accessibility-semantics-are-attached-by-hand.md#the-rules).
  The shell must not choose between `selected` and `checked`, so that
  announcement lives in the presentation's `buildItem`, not in
  `_buildItemWrapper`. At HEAD the wrapper's `Semantics` sets only `enabled`.

The selection seam itself (`isChosen`/`onItemTap`/`closeOnTap`) is stated in
CLAUDE.md and in the class dartdoc of `DropdownMenuShell`, not in a record. It
shipped as a refactor in 3.1.0 (CHANGELOG 3.1.0).

## Design model

Source of these rules: the shell's own comments, CHANGELOG entries and the tests
named; none is a record except rule 2 above.

- **The shell takes no selection state.** `isChosen` is asked once per row per
  overlay build, in both the `ListView` and the `Column` branch, and the answer
  is handed to `presentation.buildItem` and to `resolveItem(selected:)`.
  `scrollToItem` is a plain `T?`. Null means "do not scroll", and the
  multi-select caller passes null.
- **Rows refuse a tap for three reasons, and only one is known at build time**
  (`_buildItemWrapper`). *Disabled* is `onTap: null`, the semantic gate, plus an
  in-callback `if (!widget.enabled) return` for the one frame before the overlay
  rebuilds. *Gone* is `!_menu.isOpen`. *Going* is
  `_menu.animation.status == AnimationStatus.reverse`. The last two are
  deliberately not build-time gates, because neither changes with a rebuild
  behind it (#89; `test/disabled_open_menu_test.dart`).
- **`closeOnTap: false` repaints instead of closing.** After `onItemTap`, the row
  calls `_menu.rebuild()`, because the overlay will not hear the owner's rebuild.
  `closeOnTap: true` calls `_menu.close()`.
- **The owner's rebuild reaches an open menu only through `didUpdateWidget`**,
  which schedules a post-frame `_menu.rebuild()`. It is post-frame because the
  overlay's element is not a descendant of the shell's. Becoming disabled
  (`oldWidget.enabled && !widget.enabled`) rebuilds *then* closes, in that
  order, so the fading rows are the disabled ones (#89, CHANGELOG 4.2.0). This
  path is also how an async item list appears in an open menu
  (`test/open_menu_refresh_test.dart`, CHANGELOG 2.4.0).
- **The empty state has its own semantics container**, sized to one row via
  `DropdownOverlaySpec.emptyStateHeight = actualItemHeight`. It reports the
  query only while the field is shown, and `""` otherwise (#96, CHANGELOG 4.2.0;
  `test/layout_and_empty_state_test.dart`). Its default text is "No results
  found" while a query stands and "No items" otherwise.
- **The list becomes a `ListView` only when it overflows**
  (`items.length * actualItemHeight > availableContentHeight`); otherwise it is a
  `Column`. The scrollbar, the gradient, the `SmoothScrollController` and
  scroll-to-item exist only on the `ListView` path.
- **Scroll-to-item indexes `widget.items`, not the filtered list,** so it is
  skipped while a query stands (`_buildOverlayContent`'s
  `_search.query.isEmpty` guard, and `widget.items.indexOf` in
  `_scheduleScrollToItem`). A target absent from `items` (`indexOf == -1`)
  scrolls nowhere. The offset is `index * actualItemHeight` clamped to
  `maxScrollExtent`, and `scrollToItemDuration` picks `animateTo` over `jumpTo`.
- **Scroll-to-item happens once per open** (#157, commit af43db5, CHANGELOG
  4.3.1). `onOpenStateChanged(true)` arms `_scrollToItemPending`, and the first
  build of the `ListView` branch spends it, whether or not it then scrolls. It
  used to be scheduled on every overlay build, so every owner rebuild, which
  reaches the overlay through `didUpdateWidget` → `rebuild()`, took an open menu
  back to the chosen row. A cleared query went back there too. It now stays at
  the top, which was the maintainer's call on #157. The first build that
  *overflows* spends it, not the first build: a list that arrives after open is
  still scrolled to, and before it arrives there is nothing the user could have
  scrolled. Taking back a close in flight (`DropdownOverlayController.open` →
  `_cancelClose`) does not call `onOpenStateChanged`, so it counts as the same
  open and is not scrolled again (`test/scroll_to_selected_test.dart`, group
  "the scroll to the chosen row happens once per open").
- **Outside input:** `items` is the caller's list, and nothing bounds its
  length. The `Column` branch builds every row, but it is taken only when every
  row fits in `height`. The `ListView.builder` branch builds lazily.

## Code

- `lib/src/shell/dropdown_menu_shell.dart` — `DropdownMenuShell`, `_DropdownMenuShellState._menu` (its `onOpenStateChanged` closure), `_DropdownMenuShellState._scrollToItemPending`, `_DropdownMenuShellState._buildSpec`, `_DropdownMenuShellState.actualItemHeight`, `_DropdownMenuShellState.didUpdateWidget`, `_DropdownMenuShellState.dispose`, `_DropdownMenuShellState._openDropdown`, `_DropdownMenuShellState._buildOverlayContent`, `_DropdownMenuShellState._buildItemWrapper`, `_DropdownMenuShellState._scheduleScrollToItem`

Tests: `test/selection_test.dart`, `test/scroll_to_selected_test.dart`, `test/layout_and_empty_state_test.dart`, `test/open_menu_refresh_test.dart`, `test/disabled_open_menu_test.dart`.

## Reference behaviour

- `material/dropdown.dart`, for scroll-to-item only (#157). It computes the
  offset once per route, in `_DropdownRoutePageState.initState`, as the
  `ScrollController`'s `initialScrollOffset`. That matches once per open. The
  mechanism is not copied, because this controller is created once
  (`_scrollController ??=`) and outlives every open, so an initial offset would
  hold only for the first. This comparison is attributed to #157; the Flutter
  source is an **example** reference
  ([references](../../agents/thegraph.md#references)) and was not re-read for
  this note.

## Cross-cutting invariants

- [Chrome height has one source](../invariant/chrome-height-one-source.md). `_buildOverlayContent` subtracts `_buildSpec().totalChromeHeight`, the quantity placement grew the menu by.
- [No cached derived state](../invariant/no-cached-derived-state.md). `_visibleItems()` asks the search controller on every overlay build.
- [The overlay does not rebuild with its owner](../invariant/overlay-does-not-rebuild-with-owner.md). `didUpdateWidget` and the `closeOnTap: false` row tap both call `rebuild()`.
- [The entry outlives the open menu](../invariant/entry-outlives-the-open-menu.md). The row tap's *gone* and *going* guards are two different questions.

## Blast radius

- [Placement](placement.md) — placement grows the menu by the chrome in
  `_buildSpec`, and `_buildOverlayContent` must subtract exactly that, or the
  rows overflow the menu.
- [Item presentation](item-presentation.md) — every row and the button face are
  the presentation's widgets, and the row's announced state is the
  presentation's word. The shell adds only the wrapper's `enabled`.
- [Search](search.md) — the visible list, the empty state's query and the
  scroll-to-item guard all read the query, and its reset rides on
  `onOpenStateChanged`.
- [Scroll chrome](scroll-chrome.md) — only the `ListView` branch gets a
  scrollbar and a gradient, so moving the overflow test changes when either
  appears.
- [Single-select](single-select.md) and [multi-select](multi-select.md) — each
  public widget passes the shell's whole parameter list through, so a parameter
  added or renamed here is a public API change in both. Multi-select omits only
  `scrollToItemDuration`.
- [Semantics](semantics.md) — the row wrapper's `Semantics(enabled:)` and the
  empty state's `Semantics(container: true)` are two of the hand-attached
  nodes.
- [Dismissal](dismissal.md) — becoming disabled while open closes the menu from
  `didUpdateWidget`, a close that the barrier and scroll dismissal never see.

## Known holes / open

- A menu row has no role. [ADR 0001](../../adr/0001-accessibility-semantics-are-attached-by-hand.md#what-these-contradict)
  ("Rule 1 vs. the menu row") records this as an open conformance item.
- `_scrollToItemPending` is spent by the first overflowing build even when a
  query stands at that moment, which happens when items arrive after the user
  has typed. That open then never scrolls to the row. The rule was written for
  #157 without this case in view, and no test covers it.
