# Overlay lifetime

## What it is

The `OverlayEntry`'s lifetime: inserting it on open, the scale/fade animation,
tearing it down on close or dispose, and telling the owner through
`onOpenStateChanged`. It is exported as `DropdownOverlayController`, so a third
party builds a dropdown by *holding* one, exactly as the package's own shell does.
[CLAUDE.md](../../../CLAUDE.md#identity--invariants-the-boundary) explains why
this gets a completeness pass whatever the change: a leaked entry is a dead layer
that swallows taps across the consumer's whole app, and once the widget is gone
nothing is left to remove it.

## Governing decisions

**None.** No record is about the lifetime. [ADR 0002](../../adr/0002-the-dismiss-barrier-stays-its-arena-participation-is-conditional.md)
governs the barrier that the entry *contains*, not when the entry exists.
Lifetime decisions live in the issues that made them (#106, #107) and in
CHANGELOG 4.2.0.

## Design model

- **`isOpen` means the entry exists, not that the menu is open.** It stays true
  for the whole close animation. `_closing` is the separate flag for "on its way
  out". See the invariant below; this territory is where it originates.
- **Teardown is always reached.** The animation is decoration, not the
  mechanism: a `Timer` of `animationDuration` races the reverse, and whichever
  arrives first tears down while `_cancelClose` makes the other a no-op. A pushed
  route mutes `TickerMode` below it, and before this the entry stayed mounted
  over the new page, swallowing taps (#106).
- **`open()` during a close takes the close back** instead of being dropped
  (`closeAll()` followed by `open()`, #107).
- **`close(animate: false)` and `dispose` tear down synchronously.** `dispose`
  does so silently (`notify: false`), because the owner must not be asked to
  rebuild while it is being torn down.
- **`_teardown` survives a missing `Overlay`** (a route transition): it removes
  the entry in a `try`, then clears the entry and the registry in `finally`.
- **The entry is rebuilt, never replaced**, by `rebuild()`, which marks it dirty.
  See the invariant on the overlay not rebuilding with its owner.

## Code

- `lib/src/overlay/dropdown_overlay_controller.dart` — `DropdownOverlayController.open`, `DropdownOverlayController.close`, `DropdownOverlayController._cancelClose`, `DropdownOverlayController._teardown`, `DropdownOverlayController.dispose`, `DropdownOverlayController.rebuild`, `DropdownOverlayController.isOpen`, `DropdownOverlayController.animation`, `DropdownOverlayController._closing`, `DropdownOverlayController._closeFallback`, `DropdownOverlayController._buildEntry`, `DropdownOverlaySpec`, `DropdownOverlaySpecBuilder`
- `lib/src/shell/dropdown_menu_shell.dart` — `_DropdownMenuShellState.dispose` (the menu is disposed before the scroll controller, because the gradient listens to it)

Tests: `test/overlay_lifecycle_test.dart`, `test/overlay_close_contract_test.dart`, `test/overlay_controller_widget_test.dart`, `test/overlay/`.

## Reference behaviour

**None.** `material/dropdown.dart` manages its menu as a `PopupRoute`, so its
lifetime belongs to the `Navigator`. Nothing here has been compared against it,
and the comparison may not transfer, since this package deliberately does not use
a route.

## Cross-cutting invariants

- [The entry outlives the open menu](../invariant/entry-outlives-the-open-menu.md)
- [The overlay does not rebuild with its owner](../invariant/overlay-does-not-rebuild-with-owner.md)
- [The Flutter floor is measured, not read](../invariant/flutter-floor-is-measured.md). The ticker fallback exists because the API that would have asked the tree does not exist at the floor.

## Blast radius

- [Single-open](single-open.md) — `open` and `_teardown` write the per-`Overlay`
  registry. A teardown path that skips `_teardown` leaves a stale registry entry.
- [Dismissal](dismissal.md) — the scroll subscription is taken in `open` and
  dropped in `_teardown`. `_handleScroll` is safe only *because* `close` defers
  its teardown.
- [Menu shell](menu-shell.md) — the row tap guard reads `isOpen` and the
  animation status, and `onOpenStateChanged` resets the search.
- [Semantics](semantics.md) — the trigger's `expanded` reads `isOpen`.
- [Trigger button](trigger-button.md) — the trailing-icon rotation is driven off
  `animation`.

## Known holes / open

- `_instances` (see [single-open](single-open.md)) is not pruned by teardown. It
  relies on `dispose` being called, which a third-party owner may skip.
