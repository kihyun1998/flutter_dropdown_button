# Theme resolution

## What it is

Turning the caller's sparse theme objects into complete, drawable values.
`DropdownStyleTheme` composes one sub-theme per surface (button, overlay, item,
scroll, tooltip, search, checkbox). Each has a pure `resolve…()` that takes plain
values — a `DropdownAmbientColors` (button, overlay, item, search), a
`Brightness` (tooltip), or nothing (scroll, checkbox) — and returns a
`Resolved…Style`, except the checkbox, whose `resolve()` returns
`flutter_checkbox`'s `CheckboxStyle`, re-exported from the barrel. The caller
reads the ambient values out of the tree and hands them in.

## Governing decisions

**None.** Neither rule this area lives by is in a record: *a resolved style is
complete, or it is null* is stated in
[CLAUDE.md](../../../CLAUDE.md#identity--invariants-the-boundary), and the
*dead-field detector* is held below, under the design model, which is where
CLAUDE.md points for it (c0e5b95). [ADR 0001, rule 3](../../adr/0001-accessibility-semantics-are-attached-by-hand.md#the-rules)
states the complete-or-null rule for semantics nodes; it decides semantics, not
these themes. #9 (closed `wontfix`) is the recorded negative result:
`backgroundColor` on three classes is duplicated in name, not in concept.

## Design model

From CLAUDE.md and from reading the source; nothing here is in a record.

- **Reading is separate from deciding.** Every `resolve…()` is pure and has
  plain `test()` cases under `test/theme/`. `DropdownAmbientColors.of(context)`
  is the one read the palette-taking resolvers depend on, but it is not the only
  tree read feeding a theme decision: `SmartTooltipText` reads
  `Theme.of(context).brightness` for `DropdownTooltipTheme.resolve`, and the
  shell's `_restingScrollbarThickness` reads `ScrollbarTheme.of` and
  `Theme.of(context).platform` (see [scroll chrome](scroll-chrome.md)). Each
  read sits in the widget, and the deciding stays out of it.
- **A slot Flutter *replaces* rather than merges is filled completely or left
  null.** Here the instances are the tooltip `decoration` and the scrollbar's
  `ScrollbarTheme` override and thickness. See the invariant, which lists the
  slots.
- **Unset scrollbar slots stay null** so that an app-wide `ScrollbarTheme` keeps
  its say. Writing Flutter's default in would silence it
  (`ResolvedScrollStyle` class dartdoc).
- **Not every theme field goes through `resolve()`.** Some are read raw off the
  sub-theme by the widget that uses them: `DropdownOverlayTheme.elevation`,
  `.shadowColor`, `.borderRadius`, `.padding` (shell `_buildSpec`,
  `_buildOverlayContent`); `DropdownScrollTheme.showScrollGradient`,
  `.gradientColors` (shell `_buildOverlayContent`); `SearchFieldTheme.autofocus`
  (shell); the tooltip timing fields (`waitDuration`, `showDuration`,
  `exitDuration`, `verticalOffset`, `triggerMode`, read by `SmartTooltipText`);
  `DropdownCheckboxTheme.mouseCursor` (`MultiSelectPresentation`).
- **The dead-field detector:** a documented, settable field that nothing reads
  is dead, and making the themes resolve themselves is what made that
  searchable (c0e5b95). Start at the `resolve()` bodies, but the search set is
  *every* read site — the raw reads above are live fields a `resolve()`-only
  grep would flag. `trackWidth` and `alwaysVisible` were two dead fields
  (#38, #45; both removed in 3.0.0, CHANGELOG). Deleting a field means grepping
  every read site first, including ones that only compute a boolean, because
  `trackWidth` was secretly pinning hover thickness through `hasCustomWidths`
  ([lessons, Step 1](../../agents/lessons.md#step-1--이슈-먼저-근거기각-대안부정-결과)).
  The detector reads fields a caller sets; the API-coverage gate cannot find
  a dead one, because it counts that an argument was passed (`example/README.md`).

## Code

- `lib/src/theme/resolved_dropdown_style.dart` — `DropdownAmbientColors`, `DropdownAmbientColors.of`, `ResolvedButtonStyle`, `ResolvedOverlayStyle`, `ResolvedItemStyle`, `ResolvedScrollStyle`, `ResolvedSearchFieldStyle`, `ResolvedTooltipStyle`
- `lib/src/theme/dropdown_style_theme.dart` — `DropdownStyleTheme`
- `lib/src/theme/dropdown_button_theme.dart` — `DropdownButtonTheme.resolveButton`
- `lib/src/theme/dropdown_overlay_theme.dart` — `DropdownOverlayTheme.resolveOverlay`
- `lib/src/theme/dropdown_item_theme.dart` — `DropdownItemTheme.resolveItem`
- `lib/src/theme/dropdown_scroll_theme.dart` — `DropdownScrollTheme.resolve`
- `lib/src/theme/search_field_theme.dart` — `SearchFieldTheme.resolve`
- `lib/src/theme/tooltip_theme.dart` — `DropdownTooltipTheme.resolve`
- `lib/src/theme/dropdown_checkbox_theme.dart` — `DropdownCheckboxTheme.resolve`
- `lib/src/shell/dropdown_menu_shell.dart` — `_DropdownMenuShellState._ambient`, `_DropdownMenuShellState._buttonStyle`, `_DropdownMenuShellState._overlayStyle`, `_DropdownMenuShellState._searchStyle`, `_DropdownMenuShellState.effectiveButtonTheme`, `_DropdownMenuShellState.effectiveOverlayTheme`, `_DropdownMenuShellState.effectiveItemTheme`, `_DropdownMenuShellState.effectiveSearchTheme` (the callers)

Tests: `test/theme/dropdown_theme_resolve_test.dart`, `test/theme/search_scroll_resolve_test.dart`, `test/theme/tooltip_resolve_test.dart`, `test/theme/dropdown_checkbox_theme_test.dart`, `test/theme/copy_with_test.dart` (pure); `test/theme_resolution_test.dart` (the fallback chains, pinned at the rendered widget).

## Reference behaviour

**None.** Not compared as a set. Individual slots were checked against Flutter's
source when they broke (`Tooltip` #32, `Scrollbar` #59). Those pins sit in the
source comments and in [lessons](../../agents/lessons.md), not in a store this
map can anchor to.

## Cross-cutting invariants

- [A resolved style is complete or null](../invariant/resolved-style-complete-or-null.md)
- [Chrome height has one source](../invariant/chrome-height-one-source.md). `ResolvedSearchFieldStyle.totalHeight` and `ResolvedOverlayStyle.borderThickness` are chrome terms.

## Blast radius

- [Tooltip](tooltip.md), [scroll chrome](scroll-chrome.md), [search](search.md),
  [multi-select](multi-select.md), [trigger button](trigger-button.md),
  [menu shell](menu-shell.md) — each draws one sub-theme's resolved style
  without re-checking it, so a slot a resolver stops filling arrives there as a
  blank or as Flutter's default.
- [Placement](placement.md) — the overlay border thickness and padding and the
  search field's total height are chrome terms: one that changes here without
  being drawn at the same height overflows the list.
- [Example gallery](example-gallery.md) — `tool/check_api_coverage.dart`
  requires every theme constructor parameter to be passed under `example/lib`,
  so a new field turns CI red until a recipe passes it.
- [Release surfaces](release-surfaces.md) — `documentation/theming.md` and the
  theme dartdoc state each fallback; a changed fallback leaves them stating the
  old one. The `Resolved…Style` classes are exported, so their constructors are
  public API too (CHANGELOG 4.3.0 kept `wheelMotion` optional for that reason).

## Known holes / open

- **Resolved fields that nothing in the package reads.**
  `ResolvedOverlayStyle.elevation`, `.shadowColor`, `.padding`,
  `ResolvedSearchFieldStyle.autofocus`, `ResolvedScrollStyle.thumbWidth` and
  `.hasCustomWidths` are filled by their resolver and read by no site in `lib/`;
  the shell reads the raw theme field instead (or, for the last two, nothing:
  `hasCustomWidths` calls itself "informational"). Today the values agree,
  because the resolvers pass them through. A fallback added to one of those
  resolvers would not reach the drawing. Found by this reading (2026-10-24);
  nobody has decided whether the raw reads or the outputs should go.
