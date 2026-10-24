# Scroll chrome

## What it is

What an overflowing menu draws around its list: a themed `Scrollbar` (thumb,
track, radius, visibility, interactivity, colours, margins) and optional
fading gradients at the edges (`ScrollGradientOverlay`), plus how the list
moves on a scroll-wheel notch (`wheelMotion`). This applies only when the item
list actually scrolls — the `needsScroll` branch of the shell's
`_buildOverlayContent`.

## Governing decisions

**None.** No record. The decisions were made in issues: #45 and #51 decided
`alwaysVisible` and `trackWidth` (deprecate versus remove; both removed in
3.0.0, CHANGELOG). #156 decided not to narrow `wheelMotion`, the maintainer's
call on a measurement (f61872d): in a 200 px menu the three kinds differ by
15–36 px, along two axes a single `Duration` would drop — how front-loaded the
motion is, and overshoot. Four findings went into it: the upstream coupling is
the one already accepted for `flutter_checkbox`, and both upstreams are the same
maintainer's; a deprecation window would collide with the API-coverage gate and
with `flutter analyze --fatal-infos`; `flutter_table_plus` exposes the same
`WheelMotion?`; nothing here switches over the sealed type. #156 records what
would reopen it.

## Design model

From reading the source and the issues above; nothing is in a record.

- **One scrollbar, not two.** Desktop's `MaterialScrollBehavior` inserts its own
  scrollbar, so `_applyScrollbarTheme` turns that off with
  `ScrollConfiguration(… scrollbars: false)` (`test/scrollbar_duplication_test.dart`).
- **The theme is never null.** `effectiveScrollTheme` falls back to
  `DropdownScrollTheme.defaultTheme`. Without one, the menu fell through to the
  behaviour's scrollbar, which answers to nothing this package exposes.
- **Thickness is always named, and named as the value Flutter would have
  used:** the ambient `ScrollbarTheme` at rest first, otherwise 8, and **4 on
  Android** (`_restingScrollbarThickness`). Naming it pins hover thickness
  (Flutter swells 8→12). Naming the *wrong* value is a silent restyle.
- **A `ScrollbarTheme` is inserted only when the caller set one of its slots**
  (`overridesScrollbarTheme`: thumb, track or track-border colour, either
  margin, `minThumbLength`). Otherwise the ambient theme passes through
  untouched. When one is inserted, it carries only the caller's slots — see
  Known holes.
- **A track implies a thumb.** Flutter asserts against a track without one, so
  `resolve` raises `thumbVisibility` when `trackVisibility` is true.
- **`trackColor` needs `trackVisibility: true`.** That is Flutter's contract,
  not a defect (#59). The fix was the dartdoc.
- **The gradient owns its listener**, and is torn down before the scroll
  controller is disposed: the shell's `dispose` disposes `_menu` first, which
  unmounts `ScrollGradientOverlay`, then `_scrollController`
  (`test/scroll_gradient_test.dart`, "disposing the dropdown while the menu is
  open does not throw").
- **A wheel notch glides; everything else is untouched** (#155). The controller
  is `flutter_smooth_wheel_scroll`'s `SmoothScrollController`, which overrides
  only `pointerScroll` (eb67b58). `jumpTo(0)` on a query and `animateTo` for
  `scrollToItem` behave as with `ScrollController`.
- **The motion is reassigned on every overlay build**, not only at creation.
  `_scrollController ??=` survives open/close and theme changes, so a motion
  handed only to the constructor would stay the first one forever
  (`test/wheel_scroll_test.dart`, both "a motion changed while…" cases).
- **The scrollbar is smoothed too, because it shares the controller.**
  `RawScrollbar` calls `position.pointerScroll` on its controller
  (`widgets/scrollbar.dart`, `_handlePointerScroll`); upstream's "scrollbar is
  not smoothed" limitation is for a scrollbar with its own controller. Read for
  #155; not re-read here.
- **Only a mouse glides.** The web engine delivers trackpad scrolling as
  `PointerSignalKind.scroll` with kind `trackpad`
  (`web_ui/.../pointer_binding.dart`), the same path as a wheel, and
  `ScrollPosition.pointerScroll` receives only a delta. Upstream 0.1.2 therefore
  animated web trackpads too; 0.1.3 records the kind from a global
  `PointerRouter` route and animates only `PointerDeviceKind.mouse`, which is
  why the floor is `^0.1.3` (#161, 88e089c; test "a trackpad scroll signal
  jumps"). Firefox reports a trackpad as a mouse, so there it still glides. A
  mouse on Android glides. Native-desktop trackpads arrive as `PanZoom` and
  never reach this path.
- **A notch past the end during a glide goes to the page around the menu**,
  as with `ScrollController` — which scrolls it, and scroll dismissal closes the
  menu. That needs the menu inside a nested `Overlay` under a scroll view
  (test "a notch past the end of a gliding menu scrolls the page around it");
  in the root overlay there is no ancestor and the notch is dropped either way
  (#155).
- **Default: a 250 ms spring**, not upstream's 400 ms — a menu is a few rows
  tall (`_defaultWheelMotion`; test "the default motion has settled by
  300 ms"). `Duration.zero` is the exact old jump (upstream `_isInstant` →
  `super.pointerScroll`, per #155; test "a zero duration jumps").
- **`WheelMotion` is re-exported** from the barrel, so like `flutter_checkbox`
  an upstream break at `0.x` is a break here.

The only outside input is the pointer stream; a notch's delta is bounded by the
list's scroll extent, like any scroll.

## Code

- `lib/src/theme/dropdown_scroll_theme.dart` — `DropdownScrollTheme`, `DropdownScrollTheme.resolve`, `DropdownScrollTheme._all`
- `lib/src/theme/resolved_dropdown_style.dart` — `ResolvedScrollStyle`, `_defaultWheelMotion`
- `lib/src/shell/dropdown_menu_shell.dart` — `_DropdownMenuShellState.effectiveScrollTheme`, `_DropdownMenuShellState._applyScrollbarTheme`, `_DropdownMenuShellState._restingScrollbarThickness`, `_DropdownMenuShellState._buildOverlayContent` (the `SmoothScrollController`, its `motion`, the gradient), `_DropdownMenuShellState.dispose`
- `lib/src/widgets/scroll_gradient_overlay.dart` — `ScrollGradientOverlay`
- `lib/flutter_dropdown_button.dart` — the re-export of `WheelMotion`, `SpringWheelMotion`, `CurveWheelMotion`, `LerpWheelMotion`

Tests: `test/scrollbar_theme_test.dart`, `test/scrollbar_duplication_test.dart`, `test/scroll_gradient_test.dart`, `test/wheel_scroll_test.dart`, `test/theme/search_scroll_resolve_test.dart` (the `scrollbar` group).

Demonstrated by `example/lib/recipes/wheel_scroll_recipe.dart` (#159).

## Reference behaviour

- `flutter_smooth_wheel_scroll`, read raw in the pub cache
  ([references](../../agents/thegraph.md#references)) — binding for the wheel.
  The root `pubspec.lock` is gitignored, so the committed pin is
  `example/pubspec.lock` (0.1.3 at HEAD).

For the scrollbar there is no stored pin. `material/scrollbar.dart` was read for #59 and for
hover thickness. The pins are in source comments and
[lessons, Step 2](../../agents/lessons.md#step-2--경계-규칙).

## Cross-cutting invariants

- [A resolved style is complete or null](../invariant/resolved-style-complete-or-null.md)
- [The Flutter floor is measured, not read](../invariant/flutter-floor-is-measured.md) — `SpringDescription.withDurationAndBounce`, used upstream, must exist at the floor

## Blast radius

- [Theme resolution](theme-resolution.md) — `DropdownScrollTheme` is one of its
  sub-themes; the null-means-ambient rule is shared, and a slot this area starts
  filling with a default silences an app-wide theme.
- [Menu shell](menu-shell.md) — the `ListView` branch is the only host, and it
  decides `needsScroll`; a change to when the list scrolls changes when any of
  this is drawn.
- [Single-select](single-select.md) — `scrollToSelectedItem` drives `animateTo`
  on the same controller; a controller that changed `animateTo` would move the
  selected-row scroll with it.
- [Dismissal](dismissal.md) — a notch past the end goes to the page, and a page
  scroll closes the menu; a controller that swallowed or forwarded notches
  differently would change when the menu closes.
- [Release surfaces](release-surfaces.md) — the dartdoc here once taught a dead
  field (#45) and backwards deprecation arrows (#38). The re-exported
  `WheelMotion` types tie this package's API to an upstream at `0.x`.

## Known holes / open

- **An inserted `ScrollbarTheme` carries only the caller's slots.** When any
  slot in `overridesScrollbarTheme` is set, `_applyScrollbarTheme` inserts
  `ScrollbarTheme(data: style.scrollbarTheme)`, built from this theme's fields
  alone. `ScrollbarTheme` replaces the ambient data rather than merging, so an
  app-wide slot the caller did not restate (an app thumb colour, under a caller
  who set only `crossAxisMargin`) stops applying, and the field dartdoc's "if
  null, the ambient `ScrollbarTheme` decides" is then false. No test sets one
  slot over an ambient theme that sets another; `scrollbar_theme_test.dart`
  covers only the unstyled pass-through. Raised by this reading (2026-10-24)
  on the premise that `ScrollbarTheme.of` returns the nearest data without
  merging; that premise was not read at the CI-pinned Flutter here, and the
  symptom was not measured.
