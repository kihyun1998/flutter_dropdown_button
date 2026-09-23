# Search

## What it is

The optional search field at the top of the menu and the query it holds.
`DropdownSearchController` owns the text controller, the focus node and the
query, and derives the visible items. The shell hosts the field, and
`SearchFieldTheme` styles it. The controller is exported, and it knows nothing
about the menu or the scroll position.

## Governing decisions

**None.**

## Design model

- **The query is state; the filtered list is not.** `visibleItems` derives the
  list on every call. The cache it replaced (`_filteredItems`, removed in
  2.4.0) had four invalidation sites and was wrong at three.
- **The query is reset by opening and closing, never by a tap and never by an
  ancestor rebuild.** The reset rides on `onOpenStateChanged`, because the
  barrier closes the menu without going through the shell. 2.3.2 fixed a query
  cleared by identity-compared `items`.
- **Turning `searchable` off keeps the controllers,** so turning it back on
  keeps the caret. The empty state then reports `""`, not the hidden query
  (#96).
- **The caller's `searchFilter` wins; otherwise the presentation's default is
  used.** A null filter hides nothing.
- **`visibleItems` returns a copy while search is enabled,** so the menu does
  not hand the caller's list to a `ListView` that outlives the build.
- **The field is disabled with the control** (#89), and `SearchFieldTheme` fills
  `disabledBorder`, because an unfilled slot falls through to Flutter's outline.

## Code

- `lib/src/search/dropdown_search_controller.dart` — `DropdownSearchController`, `DropdownSearchController.visibleItems`, `DropdownSearchController.reset`, `DropdownSearchController.enabled`, `DropdownSearchController.onQueryChanged`
- `lib/src/shell/dropdown_menu_shell.dart` — `_DropdownMenuShellState._visibleItems`, `_DropdownMenuShellState._onSearchChanged`, `_DropdownMenuShellState._buildSearchField`, `_DropdownMenuShellState._resetSearch`, `_DropdownMenuShellState._searchFieldHeight`
- `lib/src/theme/search_field_theme.dart` — `SearchFieldTheme`, `SearchFieldTheme.resolve`, `SearchFieldTheme._defaultDecoration`

Tests: `test/search/`, `test/search_invalidation_test.dart`, `test/search_divider_height_test.dart`.

## Reference behaviour

**None.** Material's `DropdownMenu` has a filter, and the peers in
[the references table](../../agents/thegraph.md#references) have search, but
nothing has been compared against them.

## Cross-cutting invariants

- [No cached derived state](../invariant/no-cached-derived-state.md)
- [Chrome height has one source](../invariant/chrome-height-one-source.md). The field's `totalHeight` is chrome, and the divider is drawn at exactly `dividerHeight` (2.5.0).
- [The overlay does not rebuild with its owner](../invariant/overlay-does-not-rebuild-with-owner.md). A keystroke must call `rebuild()`.

## Blast radius

- [Menu shell](menu-shell.md) — the empty state and scroll-to-item both read the
  query.
- [Placement](placement.md) — turning search on grows the menu by the field's
  height.
- [Item presentation](item-presentation.md) — the default filter.
- [Semantics](semantics.md) — on the floor, the empty-state text merged into the
  field's node (#96).

## Known holes / open

**None recorded.**
