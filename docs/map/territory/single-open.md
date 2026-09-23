# Single-open

## What it is

The rule that at most one menu is open at a time **within one `Overlay`**:
opening a menu closes its neighbour, and `closeAll()` closes every open menu in
every Overlay. There are two static registries on the controller, and they
answer different questions. Keep them apart.

## Governing decisions

**None.** [ADR 0002](../../adr/0002-the-dismiss-barrier-stays-its-arena-participation-is-conditional.md#what-this-record-does-not-cover)
explicitly leaves "the registered-trigger registry's shape — lifetime, scoping,
and what `triggerEnabled` means" to #95, and records it there, not in a record.

## Design model

- **Scoped per `Overlay`, on purpose.** `_openPerOverlay` is keyed by
  `OverlayState`: a side panel's menu and a root menu do not contend. A lens once
  reported "two Overlays, two open menus" as a contract violation, and a re-read
  of the dartdoc overturned it
  ([lessons, Step 5](../../agents/lessons.md#step-5--적대적-검증-서로-다른-렌즈)).
- **Two registries, two lifetimes.**
  - `_openPerOverlay` holds only the menu that is open *now*. `open` writes it
    and `_teardown` prunes it.
  - `_instances` holds every live controller, registered in the constructor and
    removed in `dispose`. It exists because the barrier needs to recognise a
    *closed* sibling's trigger, which `_openPerOverlay` cannot hold.
- **`triggerEnabled` is published, not inferred.** A disabled anchor still
  hit-tests opaque (`InkWell`, and the bare path's `GestureDetector`), so the
  barrier cannot tell by looking. The shell writes it in `build`.
- **`closeAll` on both public widgets forwards here.** They are one registry,
  not two.

## Code

- `lib/src/overlay/dropdown_overlay_controller.dart` — `DropdownOverlayController._openPerOverlay`, `DropdownOverlayController._instances`, `DropdownOverlayController.closeAll`, `DropdownOverlayController.triggerEnabled`, `DropdownOverlayController._siblingTriggersFor`
- `lib/src/flutter_dropdown_button.dart` — `FlutterDropdownButton.closeAll`
- `lib/src/flutter_multi_select_dropdown.dart` — `FlutterMultiSelectDropdown.closeAll`
- `lib/src/shell/dropdown_menu_shell.dart` — `_DropdownMenuShellState.build` (writes `triggerEnabled`, `positioningKey`)

Tests: `test/sibling_trigger_test.dart`, `test/overlay_lifecycle_test.dart`.

## Reference behaviour

**None.** Material gets mutual exclusion for free from its modal `PopupRoute`,
which is a different mechanism, and nothing here has been compared against it.

## Cross-cutting invariants

**None.**

## Blast radius

- [Overlay lifetime](overlay-lifetime.md) — both registries are written on the
  lifetime's edges (`open`, `_teardown`, constructor, `dispose`).
- [Dismissal](dismissal.md) — the sibling-trigger veto reads `_instances` and
  `triggerEnabled` on every primary pointer-down.
- [Release surfaces](release-surfaces.md) — `closeAll`'s scope ("every Overlay",
  "animate defaults to true") is claimed in `documentation/api_reference.md`,
  and that section has been wrong twice before
  ([lessons, Step 6](../../agents/lessons.md#step-6--정합성-스윕)).

## Known holes / open

- `_instances` grows without bound for a third-party controller that is never
  disposed. Reads filter to mounted, attached anchors, so the cost is memory,
  not behaviour. The source records this as accepted; no issue tracks it.
