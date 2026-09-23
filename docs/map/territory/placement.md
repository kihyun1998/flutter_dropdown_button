# Placement

## What it is

Where the open menu goes and how big it is: above or below the anchor, its
height once space runs out, its width against `minMenuWidth`/`maxMenuWidth`,
and its left edge under `menuAlignment`, slid back inside the screen margin.
A pure function of plain values. The overlay controller measures the anchor
(or the `positioningKey` box) and the `Overlay`, then hands the numbers in.

## Governing decisions

**None.** [ADR 0002](../../adr/0002-the-dismiss-barrier-stays-its-arena-participation-is-conditional.md#what-this-record-does-not-cover)
says outright that placement geometry is outside its scope ("pure and unrelated").
The pure/impure split this module follows is stated in
[CLAUDE.md](../../../CLAUDE.md#identity--invariants-the-boundary) as *the recurring
pattern*, not in a decision record.

## Design model

- **Invariant (stated in the source):** the menu keeps `screenMargin` from the
  safe-area edge and `buttonGap` from the anchor. `spaceBelow`/`spaceAbove`
  already exclude both, so a menu that fits in either span satisfies the
  invariant.
- **The one deliberate exception:** when neither side fits, the menu takes the
  larger side and is floored at `minVisibleItems` rows plus chrome, even if that
  crosses the margin. A menu too short to show anything is worse than one that
  crowds the edge.
- **`maxDropdownHeight` caps the items, not the overlay.** Chrome (search field,
  border, overlay padding) is added on top, so turning on search never makes a
  short list scroll.
- **An empty menu reserves `emptyStateHeight`**, because the item term is zero.
  The field defaults to 0 so that a third-party spec written before it existed
  keeps its meaning. The shell passes one row's height (#96).
- **Measured on every overlay build, never tracked per frame.** A menu whose
  items change re-sizes and can flip sides. An anchor that *moves* while the
  menu is open is not followed; scrolling closes the menu instead (see
  [dismissal](dismissal.md)).
- **The coordinate origin is the `Overlay`, not the root view.** Otherwise the
  menu would shift by the Overlay's own offset whenever that offset is not zero.

## Code

- `lib/src/placement/dropdown_placement.dart` — `DropdownPlacementInput`, `DropdownPlacementResult`, `DropdownPlacement.resolve`, `DropdownPlacement._resolveWidth`, `DropdownPlacement._resolveLeft`
- `lib/src/overlay/dropdown_overlay_controller.dart` — `DropdownOverlayController.measurePlacement`, `DropdownOverlayController.positioningKey`, `DropdownOverlaySpec.totalChromeHeight`
- `lib/src/buttons/menu_alignment.dart` — `MenuAlignment`

Tests: `test/placement/` holds the pure half, with no widget tree.

## Reference behaviour

**None.** Flutter's `MenuAnchor` already places menus, and
[the references table](../../agents/thegraph.md#references) records not using
it as a settled divergence. No placement rule here has been checked against
`MenuAnchor` or `dropdown.dart`'s `_DropdownMenuRouteLayout`.

## Cross-cutting invariants

- [Chrome height has one source](../invariant/chrome-height-one-source.md). The
  overlay content has to subtract exactly what this module added.

## Blast radius

- [Menu shell](menu-shell.md) — `_buildOverlayContent` sizes the list from the
  `height` this module returns. Any change to what counts as chrome must land in
  both places at once.
- [Overlay lifetime](overlay-lifetime.md) — `measurePlacement` is the only
  caller, and a `null` result draws nothing (`SizedBox.shrink`).
- [Theme resolution](theme-resolution.md) — `SearchFieldTheme` and
  `DropdownOverlayTheme` supply chrome heights (search `totalHeight`, overlay
  `padding`, `borderThickness`).

## Known holes / open

- An anchor that moves without scrolling (a layout change, an animation) leaves
  the menu where it was placed. #103 chose closing on scroll over per-frame
  re-measurement, and this remains the uncovered case.
