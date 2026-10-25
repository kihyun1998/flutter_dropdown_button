# Search

## What it is

The optional search field at the top of the menu and the query it holds.
`DropdownSearchController` owns the text controller, the focus node and the
query, and derives the visible items. The shell hosts the field and drives the
controller's lifetime, and `SearchFieldTheme` styles it. The controller is
exported, and it knows nothing about the menu or the scroll position: its class
dartdoc says so, and it imports only `flutter/widgets.dart` and the presentation
typedef.

## Governing decisions

**None.** No ADR covers search. ADR 0001 governs the empty state's semantics
node, which sits in [menu shell](menu-shell.md) and [semantics](semantics.md),
not the query.

## Design model

Source: the controller's and shell's comments, CHANGELOG entries, and the tests
named. Nothing here comes from a record.

- **The query is state; the filtered list is not.** `visibleItems` derives the
  list on every call. It replaced a cached `_filteredItems` with four
  hand-written invalidation sites (CHANGELOG 2.4.0). The defect history is in
  the [invariant](../invariant/no-cached-derived-state.md).
- **The query is reset by opening and closing, never by a tap and never by an
  ancestor rebuild.** `_resetSearch` runs from the controller's
  `onOpenStateChanged`, which fires at `open()` and at the entry's teardown,
  the end of the close animation. It does not fire on a close taken back or on
  `dispose`. It rides there because the barrier closes the menu without going
  through the shell. 2.3.2 fixed a query that was cleared because
  `didUpdateWidget` compared `items` by identity (CHANGELOG 2.3.2;
  `test/search_invalidation_test.dart`).
- **A keystroke jumps the list to the top and rebuilds the overlay.**
  `_onSearchChanged` calls `onQueryChanged`, then `jumpTo(0)` on the scroll
  controller if it has clients, then `_menu.rebuild()`.
- **Controllers are allocated lazily and kept.** The constructor allocates the
  `TextEditingController` and `FocusNode` only when `enabled`. The `enabled`
  setter allocates on `true` and never frees on `false`, so turning `searchable`
  off and on keeps the caret. While the field is off, the empty state reports
  `""`, not the hidden query (#96).
- **The caller's `searchFilter` wins; otherwise the presentation's
  `defaultSearchFilter` is used.** Text and multi-select presentations default
  to a case-insensitive `contains` on the label. `CustomItemPresentation`
  returns null, and a null filter hides nothing.
- **`visibleItems` returns `items` itself when search is off, and a copy when it
  is on,** so the menu does not hand the caller's list to a `ListView` that
  outlives the build.
- **The field follows `enabled`, not the item count** (#89 for the gate; the
  item-count half is from the `searchable` dartdoc, #112). `SearchFieldTheme`'s
  default decoration fills `disabledBorder` with the same edge as
  `enabledBorder`, because an unfilled slot falls through to Flutter's outline
  default.
- **Autofocus is post-frame.** `_openDropdown` calls `requestFocus` after the
  frame that inserts the entry, when `searchable` and
  `SearchFieldTheme.autofocus` (default `true`) are both set.
- **The field's height is chrome.** `ResolvedSearchFieldStyle.totalHeight` is
  field height + vertical margin + `dividerHeight` (0 without a divider), and
  `_buildSearchField` draws the divider inside `SizedBox(height: dividerHeight)`
  (CHANGELOG 2.5.0; `test/search_divider_height_test.dart`).
- **Outside input:** the query is user text, and nothing bounds its length. The
  filter runs over every item on every overlay build while a query stands, and
  the copy is made on every build while search is on. Item count is the
  caller's, and nothing bounds it either.

## Code

- `lib/src/search/dropdown_search_controller.dart` — `DropdownSearchController`, `DropdownSearchController.visibleItems`, `DropdownSearchController.reset`, `DropdownSearchController.enabled`, `DropdownSearchController.onQueryChanged`, `DropdownSearchController.requestFocus`, `DropdownSearchController.dispose`
- `lib/src/shell/dropdown_menu_shell.dart` — `_DropdownMenuShellState._search`, `_DropdownMenuShellState._visibleItems`, `_DropdownMenuShellState._onSearchChanged`, `_DropdownMenuShellState._buildSearchField`, `_DropdownMenuShellState._resetSearch`, `_DropdownMenuShellState._searchFieldHeight`, `_DropdownMenuShellState._openDropdown`
- `lib/src/theme/search_field_theme.dart` — `SearchFieldTheme`, `SearchFieldTheme.resolve`, `SearchFieldTheme._defaultDecoration`
- `lib/src/presentation/item_presentation.dart` — `DropdownItemPresentation.defaultSearchFilter` (and its three overrides)

Tests: `test/search/dropdown_search_controller_test.dart`, `test/search_invalidation_test.dart`, `test/search_divider_height_test.dart`, `test/selection_test.dart` (filtered selection, reset on reopen).

## Reference behaviour

**None.** Material's `DropdownMenu` has a filter, and the peers in
[the references table](../../agents/thegraph.md#references) have search, but
nothing has been compared against them.

## Cross-cutting invariants

- [No cached derived state](../invariant/no-cached-derived-state.md). `visibleItems` derives on each call.
- [Chrome height has one source](../invariant/chrome-height-one-source.md). The field's `totalHeight` is chrome, and the divider is drawn at exactly `dividerHeight` (2.5.0).
- [The overlay does not rebuild with its owner](../invariant/overlay-does-not-rebuild-with-owner.md). A keystroke must call `rebuild()`.
- [A resolved style is complete or null](../invariant/resolved-style-complete-or-null.md). `_defaultDecoration` fills `disabledBorder`, a slot that replaces Flutter's default rather than merging with it (#89).

## Blast radius

- [Menu shell](menu-shell.md) — the empty state reports the query, and
  scroll-to-item skips while one stands, because its index is taken against the
  unfiltered list.
- [Placement](placement.md) — turning search on grows the menu by `totalHeight`.
  A drawn height that differs from the reserved one overflows the rows.
- [Item presentation](item-presentation.md) — the default filter is the
  presentation's, so a new presentation decides whether search filters at all.
- [Semantics](semantics.md) — at the Flutter floor, the empty-state text merged
  into the field's node (measured in #90, commit da7aeb7; fixed in #96, commit
  2a77280), so the field and the empty state must stay
  separate nodes.
- [Theme resolution](theme-resolution.md) — `SearchFieldTheme.resolve` is one of
  the resolvers. A new `InputDecoration` slot that replaces rather than merges
  must be filled there.

## Known holes / open

- In custom mode, `searchFilter` is documented as "required" when `searchable`
  is true, but nothing asserts it. A custom-mode `searchable: true` with no
  filter draws a field that filters nothing (`CustomItemPresentation.defaultSearchFilter`
  is null).
- `DropdownSearchController.reset`'s dartdoc says it is "called on select,
  dismiss and reopen". The shell calls it only from `onOpenStateChanged`. A
  select resets the query only because a single-select tap closes the menu; a
  checklist tap does not reset it.
- No bound on query length, and no measurement of the per-build filter and copy
  on a large list (see `## Design model`).
