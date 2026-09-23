# Scroll chrome

## What it is

What an overflowing menu draws around its list: a themed `Scrollbar` (thumb,
track, radius, visibility, interactivity, colours, margins) and optional
fading gradients at the edges (`ScrollGradientOverlay`). This applies only when
the item list actually scrolls.

## Governing decisions

**None.** #45 and #51 decided `alwaysVisible` and `trackWidth` (deprecate
versus remove) in issues, not in a record.

## Design model

- **One scrollbar, not two.** Desktop's `MaterialScrollBehavior` inserts its own
  scrollbar, so the menu turns that off with `ScrollConfiguration`.
- **The theme is never null.** Without one, the menu fell through to the
  behaviour's scrollbar, which answers to nothing this package exposes.
- **Thickness is always named, and named as the value Flutter would have
  used:** the ambient `ScrollbarTheme` at rest first, otherwise 8, and **4 on
  Android**. Naming it pins hover thickness (Flutter swells 8→12). Naming the
  *wrong* value is a silent restyle.
- **A `ScrollbarTheme` is inserted only when the caller set one of its slots**
  (`overridesScrollbarTheme`). Otherwise the ambient theme passes through
  untouched.
- **A track implies a thumb.** Flutter asserts against a track without one, so
  `resolve` cannot build that pair.
- **`trackColor` needs `trackVisibility: true`.** That is Flutter's contract,
  not a defect (#59). The fix was the dartdoc.
- **The gradient owns its listener**, and is torn down before the scroll
  controller is disposed.

## Code

- `lib/src/theme/dropdown_scroll_theme.dart` — `DropdownScrollTheme`, `DropdownScrollTheme.resolve`
- `lib/src/theme/resolved_dropdown_style.dart` — `ResolvedScrollStyle`
- `lib/src/shell/dropdown_menu_shell.dart` — `_DropdownMenuShellState._applyScrollbarTheme`, `_DropdownMenuShellState._restingScrollbarThickness`, `_DropdownMenuShellState.effectiveScrollTheme`
- `lib/src/widgets/scroll_gradient_overlay.dart` — `ScrollGradientOverlay`

Tests: `test/scrollbar_theme_test.dart`, `test/scrollbar_duplication_test.dart`, `test/scroll_gradient_test.dart`.

## Reference behaviour

**None.** There is no stored pin. `material/scrollbar.dart` was read for #59 and for
hover thickness. The pins are in source comments and
[lessons, Step 2](../../agents/lessons.md#step-2--경계-규칙).

## Cross-cutting invariants

- [A resolved style is complete or null](../invariant/resolved-style-complete-or-null.md)

## Blast radius

- [Theme resolution](theme-resolution.md) — its sub-theme.
- [Menu shell](menu-shell.md) — the `ListView` branch is the only host.
- [Release surfaces](release-surfaces.md) — the dartdoc here once taught a dead
  field (#45) and backwards deprecation arrows (#38).

## Known holes / open

**None recorded.**
