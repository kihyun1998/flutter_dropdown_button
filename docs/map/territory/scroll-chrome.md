# Scroll chrome

## What it is

What an overflowing menu draws around its list: a themed `Scrollbar` (thumb,
track, radius, visibility, interactivity, colours, margins) and optional
fading gradients at the edges (`ScrollGradientOverlay`), plus how the list
moves on a scroll-wheel notch (`wheelMotion`). This applies only when the item
list actually scrolls.

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
- **A wheel notch glides; everything else is untouched** (#155). The controller
  is `flutter_smooth_wheel_scroll`'s `SmoothScrollController`, which overrides
  only `pointerScroll`. `jumpTo(0)` on a query and `animateTo` for
  `scrollToItem` behave as with `ScrollController`.
- **The motion is reassigned on every overlay build**, not only at creation.
  `_scrollController ??=` survives open/close and theme changes, so a motion
  handed only to the constructor would stay the first one forever.
- **The scrollbar is smoothed too, because it shares the controller.**
  `RawScrollbar` calls `position.pointerScroll` on its controller
  (`widgets/scrollbar.dart`, `_handlePointerScroll`); upstream's "scrollbar is
  not smoothed" limitation is for a scrollbar with its own controller.
- **Only a mouse glides.** The web engine delivers trackpad scrolling as
  `PointerSignalKind.scroll` with kind `trackpad`
  (`web_ui/.../pointer_binding.dart`), the same path as a wheel, and
  `ScrollPosition.pointerScroll` receives only a delta. Upstream 0.1.2 therefore
  animated web trackpads too; 0.1.3 records the kind from a global
  `PointerRouter` route and animates only `PointerDeviceKind.mouse`, which is
  why the floor is `^0.1.3` (#161). Firefox reports a trackpad as a mouse, so
  there it still glides. A mouse on Android glides. Native-desktop trackpads
  arrive as `PanZoom` and never reach this path.
- **A notch past the end during a glide goes to the page around the menu**,
  as with `ScrollController` — which scrolls it, and scroll dismissal closes the
  menu. That needs the menu inside a nested `Overlay` under a scroll view; in
  the root overlay there is no ancestor and the notch is dropped either way.
- **Default: a 250 ms spring**, not upstream's 400 ms — a menu is a few rows
  tall. `Duration.zero` is the exact old jump (`_isInstant` → `super.pointerScroll`).
- **`WheelMotion` is re-exported**, so like `flutter_checkbox` an upstream break
  at `0.x` is a break here.

## Code

- `lib/src/theme/dropdown_scroll_theme.dart` — `DropdownScrollTheme`, `DropdownScrollTheme.resolve`
- `lib/src/theme/resolved_dropdown_style.dart` — `ResolvedScrollStyle`
- `lib/src/shell/dropdown_menu_shell.dart` — `_DropdownMenuShellState._applyScrollbarTheme`, `_DropdownMenuShellState._restingScrollbarThickness`, `_DropdownMenuShellState.effectiveScrollTheme`
- `lib/src/widgets/scroll_gradient_overlay.dart` — `ScrollGradientOverlay`
- `lib/src/shell/dropdown_menu_shell.dart` — `_DropdownMenuShellState._buildOverlayContent` (the `SmoothScrollController` and its `motion`)
- `lib/flutter_dropdown_button.dart` — `WheelMotion`, `SpringWheelMotion`, `CurveWheelMotion`, `LerpWheelMotion`

Tests: `test/scrollbar_theme_test.dart`, `test/scrollbar_duplication_test.dart`, `test/scroll_gradient_test.dart`, `test/wheel_scroll_test.dart`.

Demonstrated by `example/lib/recipes/wheel_scroll_recipe.dart` (#159).

## Reference behaviour

- `flutter_smooth_wheel_scroll`, read raw at the version `pubspec.lock` pins
  ([references](../../agents/thegraph.md#references)) — binding for the wheel.

For the scrollbar there is no stored pin. `material/scrollbar.dart` was read for #59 and for
hover thickness. The pins are in source comments and
[lessons, Step 2](../../agents/lessons.md#step-2--경계-규칙).

## Cross-cutting invariants

- [A resolved style is complete or null](../invariant/resolved-style-complete-or-null.md)
- [The Flutter floor is measured, not read](../invariant/flutter-floor-is-measured.md) — `SpringDescription.withDurationAndBounce`, used upstream, must exist at the floor

## Blast radius

- [Theme resolution](theme-resolution.md) — its sub-theme.
- [Menu shell](menu-shell.md) — the `ListView` branch is the only host.
- [Release surfaces](release-surfaces.md) — the dartdoc here once taught a dead
  field (#45) and backwards deprecation arrows (#38). The re-exported
  `WheelMotion` types tie this package's API to an upstream at `0.x`.

## Known holes / open

- **`wheelMotion` exposes every upstream option on purpose, to be narrowed
  later** (#155, the maintainer's call). Narrowing removes public API, which is
  a major version. Held by #156 until real use shows which options matter.
