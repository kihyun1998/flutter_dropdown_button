# Placement

## What it is

Where the open menu goes and how big it is: above or below the anchor, its
height once space runs out, its width against `minMenuWidth`/`maxMenuWidth`,
and its left edge under `menuAlignment`, slid back inside the screen margin.
The deciding half, `DropdownPlacement.resolve`, is a pure function of plain
values with no `BuildContext`. The reading half,
`DropdownOverlayController.measurePlacement`, measures the anchor (or the
`positioningKey` box), the `Overlay` and the `MediaQuery`, then hands the
numbers in. `DropdownPlacement` is not exported; consumers meet its result only
as `measurePlacement`'s return type.

## Governing decisions

**None.** [ADR 0002](../../adr/0002-the-dismiss-barrier-stays-its-arena-participation-is-conditional.md#what-this-record-does-not-cover)
says outright that placement geometry is outside its scope ("pure and
unrelated"), and leaves "whether the menu should follow its anchor" to #103.
The pure/impure split this module follows is stated in
[CLAUDE.md](../../../CLAUDE.md#identity--invariants-the-boundary) as *the recurring
pattern*, not in a decision record.

## Design model

From the source (the dartdoc on `DropdownPlacement` states the invariant) and
CHANGELOG 2.4.0 / 4.1.0 / 4.2.0; no record states these.

- **Invariant (stated in the source):** the menu keeps `screenMargin` from the
  edge and `buttonGap` from the anchor. Vertically the edge is the safe area —
  `spaceBelow`/`spaceAbove` subtract `safeInsetBottom`/`safeInsetTop`, the margin
  and the gap, so a menu that fits in either span satisfies the invariant.
  Horizontally the edge is the `Overlay`'s own width: `_resolveLeft` clamps to
  `screenMargin` with no inset term (it is not handed `padding.left/right`).
- **Below first, then above, then the larger side.** `resolve` opens down if the
  preferred height fits below, else up if it fits above.
- **The one deliberate exception:** when neither side fits, the menu takes the
  larger side and is floored at `minVisibleItems` rows plus chrome, even if that
  crosses the margin. A menu too short to show anything is worse than one that
  crowds the edge (dartdoc on `DropdownPlacementInput.minVisibleItems`).
- **`maxDropdownHeight` caps the items, not the overlay.** Chrome (search field,
  border, overlay padding) is added on top, so turning on search never makes a
  short list scroll (`test/placement/dropdown_placement_test.dart`, "three items
  with a search field still do not scroll").
- **An empty menu reserves `emptyStateHeight`**, because the item term is zero;
  `maxDropdownHeight` caps it like items. The field defaults to 0 so that a
  third-party spec written before it existed keeps its meaning. The shell passes
  one row's height (`_DropdownMenuShellState._buildSpec`, #96).
- **Width:** the measured box's width, floored by `minMenuWidth` then capped by
  `maxMenuWidth` (`_resolveWidth`). `menuAlignment` applies only when the menu
  is wider than the box; the right edge is clamped before the left, so a menu
  wider than the screen ends flush with the left margin.
- **Measured on every overlay build, never tracked per frame.** `_buildEntry`
  calls `measurePlacement` each time the entry builds, so a menu whose items
  change re-sizes and can flip sides (CHANGELOG 2.4.0,
  `test/overlay_resize_test.dart`). An anchor that *moves* while the menu is
  open is not followed — it is re-read only when something rebuilds the entry —
  and scrolling closes the menu instead (see [dismissal](dismissal.md)). The
  same holds for the `positioningKey` box (CHANGELOG 4.1.0).
- **The coordinate origin is the `Overlay`, not the root view.**
  `localToGlobal(…, ancestor: overlayBox)` and `screenSize` from the `Overlay`'s
  box; otherwise the menu would shift by the `Overlay`'s own offset
  (`test/overlay_bounds_test.dart`, "menu inside an offset Overlay stays on
  screen"). A `positioningKey` box must live in the same `Overlay` coordinate
  space.
- **Only the measured box changes with `positioningKey`.** `measurePlacement`
  reads `positioningKey ?? buttonKey`; `resolve` is untouched (CHANGELOG 4.1.0,
  `test/positioning_key_test.dart`).
- **Bounded inputs:** none come from outside the process; `screenMargin`,
  `buttonGap` and `minVisibleItems` are reachable only through a third-party
  `DropdownOverlaySpec` — the package's widgets never set them, so they always
  get the spec's defaults (8, 4, 2).

## Code

- `lib/src/placement/dropdown_placement.dart` — `DropdownPlacementInput`, `DropdownPlacementInput.buttonBottom`, `DropdownPlacementResult`, `DropdownPlacement.resolve`, `DropdownPlacement._resolveWidth`, `DropdownPlacement._resolveLeft`
- `lib/src/overlay/dropdown_overlay_controller.dart` — `DropdownOverlayController.measurePlacement`, `DropdownOverlayController.positioningKey`, `DropdownOverlayController.buttonKey`, `DropdownOverlaySpec` (the placement fields and their defaults), `DropdownOverlaySpec.totalChromeHeight`, `DropdownOverlayController._buildEntry` (the `Positioned` and `transformAlignment`)
- `lib/src/buttons/menu_alignment.dart` — `MenuAlignment`
- `lib/src/shell/dropdown_menu_shell.dart` — `_DropdownMenuShellState._buildSpec`

Tests: `test/placement/dropdown_placement_test.dart` holds the pure half, with no widget tree; `test/overlay_bounds_test.dart`, `test/overlay_resize_test.dart`, `test/positioning_key_test.dart` hold the measured half.

## Reference behaviour

- [The references table](../../agents/thegraph.md#references) records not using
  Flutter's `MenuAnchor`, which already places menus, as a settled divergence.
  No geometry rule here has been checked against `MenuAnchor` or
  `dropdown.dart`'s `_DropdownMenuRouteLayout`.
- Whether the menu follows its anchor was compared in #103 (commit e09e290):
  Floating UI follows, MUI and Radix lock the background, and Flutter's newest
  menu closes — the convention taken here (see [dismissal](dismissal.md)).

## Cross-cutting invariants

- [Chrome height has one source](../invariant/chrome-height-one-source.md) —
  `resolve` adds `chromeHeight` on top of the capped items (and of the
  `minVisibleItems` floor); `measurePlacement` fills it from
  `spec().totalChromeHeight`, which the overlay content subtracts again.

## Blast radius

- [Menu shell](menu-shell.md) — `_buildOverlayContent` sizes the list from the
  `height` this module returns minus `_buildSpec().totalChromeHeight`. A piece
  of chrome the content draws but the spec does not declare overflows the list.
- [Overlay lifetime](overlay-lifetime.md) — the entry draws only what
  `measurePlacement` returns, and a `null` result (unmounted owner, unattached
  box) draws `SizedBox.shrink` — no menu and no barrier.
- [Dismissal](dismissal.md) — the menu is placed once per overlay build and
  never follows a moving anchor; closing on an ancestor scroll
  (`_handleScroll`) is what keeps it from being left stranded. Making placement
  follow the anchor reopens whether scrolling still closes.
- [Theme resolution](theme-resolution.md) — `SearchFieldTheme` and
  `DropdownOverlayTheme` supply the chrome terms (search `totalHeight`, overlay
  `padding`, `borderThickness`); a term that changes size without reaching the
  spec mis-sizes the menu.

## Known holes / open

- **An anchor that moves without scrolling** (a layout change, an animation)
  leaves the menu where it was placed until something rebuilds the entry — a
  `rebuild()` from the owner's `didUpdateWidget`, a search keystroke, a
  checklist tap — at which point it jumps. #103 chose closing on scroll over
  per-frame re-measurement (ADR 0002 non-scope; CHANGELOG 4.2.0 "Not
  addressed"), and this remains the uncovered case.
- **Nothing tells the entry that the `MediaQuery` changed.** `measurePlacement`
  reads `MediaQuery.of` and `Overlay.of` through the owner's context, so a
  rotation, window resize or inset change marks the owner, whose `build` does
  not call `rebuild()`. Read, not measured: the open menu may keep its old
  coordinates until the entry rebuilds for another reason.
- **The soft keyboard is not subtracted.** Only `padding.top`/`padding.bottom`
  are read, never `viewInsets`, so a searchable menu opening downward on mobile
  can sit under the keyboard its own search field raised. Read, not measured.
- **No horizontal safe area.** `_resolveLeft` clamps to `screenMargin` from the
  `Overlay`'s edges; a landscape notch (`padding.left/right`) is not considered.
- **The `minVisibleItems` floor ignores the item count and the cap.** When
  neither side fits, `height = max(available, minVisibleItems × row + chrome)`,
  even for a one-item or empty menu and even above `maxDropdownHeight`; opening
  upward, `top` is computed from that height, which can leave a gap between a
  shorter menu and its anchor. Read, not measured; no test covers fewer items
  than `minVisibleItems`.
- **Two sets of defaults.** `DropdownOverlaySpec` and `DropdownPlacementInput`
  both default `screenMargin` 8, `buttonGap` 4, `minVisibleItems` 2,
  `menuAlignment` left. `measurePlacement` always forwards the spec's, so the
  input's defaults govern only `test/placement/`.
- **A `positioningKey` box is not watched for scroll** — only the anchor's
  ancestors are (e09e290, measured there). By reading, a box outside the
  anchor's ancestry that scrolls therefore leaves the menu stale.
