# Theme resolution

## What it is

Turning the caller's sparse theme objects into complete, drawable values.
`DropdownStyleTheme` composes one sub-theme per surface (button, overlay, item,
scroll, tooltip, search, checkbox). Each has a pure `resolve…()` that takes plain
ambient values (`DropdownAmbientColors`, a `Brightness`, or nothing) and returns
a `Resolved…Style`. The shell reads the ambient values out of the tree and
decides nothing with them itself.

## Governing decisions

**None.** Both rules this area lives by are stated in
[CLAUDE.md](../../../CLAUDE.md#identity--invariants-the-boundary), not in a
record: *a resolved style is complete, or it is null*, and the *dead-field
detector*. #9 (closed `wontfix`) is the recorded negative result:
`backgroundColor` on three classes is duplicated in name, not in concept.

## Design model

- **Reading is separate from deciding.** `DropdownAmbientColors.of(context)` is
  the only tree read, and every `resolve` is pure and unit-tested.
- **A slot Flutter *replaces* rather than merges is filled completely or left
  null.** The instances are the tooltip `decoration`, the `ScrollbarTheme`
  override, and the thickness. See the invariant.
- **Unset scrollbar slots stay null** so that an app-wide `ScrollbarTheme` keeps
  its say. Writing Flutter's default in would silence it.
- **The dead-field detector:** a documented, settable field that no `resolve()`
  mentions is read by nothing. `trackWidth` and `alwaysVisible` were two such
  fields (#38, #45). Deleting a field means grepping *every* read site first,
  including ones that only compute a boolean, because `trackWidth` was secretly
  pinning hover thickness through `hasCustomWidths`
  ([lessons, Step 1](../../agents/lessons.md#step-1--이슈-먼저-근거기각-대안부정-결과)).

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

Tests: `test/theme_resolution_test.dart`.

## Reference behaviour

**None.** Not compared as a set. Individual slots were checked against Flutter's source when
they broke (`Tooltip` #32, `Scrollbar` #59). Those pins sit in the source
comments and in [lessons](../../agents/lessons.md), not in a store this map can
anchor to.

## Cross-cutting invariants

- [A resolved style is complete or null](../invariant/resolved-style-complete-or-null.md)
- [Chrome height has one source](../invariant/chrome-height-one-source.md). `ResolvedSearchFieldStyle.totalHeight` is one of the chrome terms.

## Blast radius

- [Tooltip](tooltip.md), [scroll chrome](scroll-chrome.md), [search](search.md),
  [multi-select](multi-select.md) — each is the consumer of one sub-theme's
  resolved style.
- [Placement](placement.md) — the overlay theme's padding and border thickness
  and the search field's total height are chrome terms.
- [Example gallery](example-gallery.md) — `tool/check_api_coverage.dart`
  requires every theme constructor parameter to be demonstrated, so a new field
  turns CI red until a recipe passes it.
- [Release surfaces](release-surfaces.md) — `documentation/theming.md`.

## Known holes / open

**None recorded.**
