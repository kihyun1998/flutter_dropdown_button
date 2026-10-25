# Single-open

## What it is

The rule that at most one menu is open at a time **within one `Overlay`**:
opening a menu closes its neighbour, and `closeAll()` closes every open menu in
every `Overlay`. There are two static registries on the controller, and they
answer different questions — keep them apart. The second one, `_instances`,
exists for the dismiss barrier's sibling veto, whose rule lives in
[dismissal](dismissal.md); this note owns the registry, not the veto.

## Governing decisions

**None.** [ADR 0002](../../adr/0002-the-dismiss-barrier-stays-its-arena-participation-is-conditional.md#what-this-record-does-not-cover)
explicitly leaves "the registered-trigger registry's shape — lifetime, scoping,
and what `triggerEnabled` means" to #95, and records it there, not in a record.
The per-`Overlay` scoping dates from CHANGELOG 2.4.0, also without a record.

## Design model

From the source, CHANGELOG 2.4.0 and 4.2.0 (#95); no record states these.

- **Scoped per `Overlay`, on purpose.** `_openPerOverlay` is keyed by
  `OverlayState`: a side panel's menu and a root menu do not contend (CHANGELOG
  2.4.0; `test/overlay_bounds_test.dart`). A lens once reported "two Overlays,
  two open menus" as a contract violation, and a re-read of the dartdoc
  overturned it
  ([lessons, Step 5](../../agents/lessons.md#step-5--적대적-검증-서로-다른-렌즈)).
- **Two registries, two lifetimes.**
  - `_openPerOverlay` holds the menu that is open *or still closing* in each
    `Overlay`. `open` writes it after closing the current holder, and
    `_teardown` prunes it — so a closing menu stays registered until its entry
    is gone.
  - `_instances` holds every live controller, added in the constructor and
    removed in `dispose`. It exists because the barrier needs to recognise a
    *closed* sibling's trigger, which `_openPerOverlay` cannot hold. It is
    process-wide, not per `Overlay`: a trigger in a nested `Overlay` is a
    sibling too, and the two scopes are independent (CHANGELOG 4.2.0, #95).
- **`triggerEnabled` is published, not inferred.** A disabled anchor still
  hit-tests opaque (`InkWell`, and the bare path's
  `GestureDetector(behavior: HitTestBehavior.opaque)`), so the barrier cannot
  tell by looking. The shell writes it in `_DropdownMenuShellState.build`, before
  choosing the anchor path, so both paths publish it.
  `_siblingTriggersFor` skips a controller whose `triggerEnabled` is false, and
  its own controller.
- **`closeAll` on both public widgets forwards here.** One registry, not two:
  `FlutterDropdownButton.closeAll` and `FlutterMultiSelectDropdown.closeAll` are
  one-line calls to `DropdownOverlayController.closeAll`, which closes every
  value of `_openPerOverlay` — the way to dismiss a menu that an outside tap in
  another `Overlay`'s region cannot reach (`test/overlay_bounds_test.dart`,
  "closeAll reaches a menu the outside tap cannot").

## Code

- `lib/src/overlay/dropdown_overlay_controller.dart` — `DropdownOverlayController._openPerOverlay`, `DropdownOverlayController._instances`, `DropdownOverlayController.closeAll`, `DropdownOverlayController.triggerEnabled`, `DropdownOverlayController.buttonKey`, `DropdownOverlayController._siblingTriggersFor`, `DropdownOverlayController.open` (closes the holder, registers), `DropdownOverlayController._teardown` (prunes), `DropdownOverlayController.dispose` (deregisters)
- `lib/src/flutter_dropdown_button.dart` — `FlutterDropdownButton.closeAll`
- `lib/src/flutter_multi_select_dropdown.dart` — `FlutterMultiSelectDropdown.closeAll`
- `lib/src/shell/dropdown_menu_shell.dart` — `_DropdownMenuShellState.build` (writes `triggerEnabled` and `positioningKey`)

Tests: `test/overlay_lifecycle_test.dart` ("only one menu is open at a time", the `closeAll` cases), `test/overlay_bounds_test.dart`, `test/sibling_trigger_test.dart` ("a disposed controller is no longer a sibling").

## Reference behaviour

**None.** Material gets mutual exclusion from its modal `PopupRoute`, a
different mechanism, and nothing here has been compared against it.

## Cross-cutting invariants

- [The entry outlives the open menu](../invariant/entry-outlives-the-open-menu.md) — `_openPerOverlay` holds a closing menu until `_teardown`, and `open()`'s reopen branch returns before the registry is touched.

## Blast radius

- [Overlay lifetime](overlay-lifetime.md) — both registries are written on the
  lifetime's edges (`open`, `_teardown`, constructor, `dispose`). The registry
  assumes every exit from "open" goes through `_teardown` and every entry
  through the registering half of `open`.
- [Dismissal](dismissal.md) — the sibling veto reads `_instances` and
  `triggerEnabled` on every primary pointer-down. A stale or wrongly scoped
  `_instances` punches a hole in the barrier over an anchor that will do
  nothing with the tap.
- [Release surfaces](release-surfaces.md) — `closeAll`'s scope ("every
  `Overlay`", "`animate` defaults to true") is claimed in
  `documentation/api_reference.md`, and that section has been wrong twice before
  ([lessons, Step 6](../../agents/lessons.md#step-6--정합성-스윕)).

## Known holes / open

- **A reopened menu does not reclaim its `Overlay`.** If menu B opens while A
  is closing (the one-tap swap, `test/sibling_trigger_test.dart` "while the
  first menu is still closing"), the registry holds B. A later `A.open()` before
  A's teardown takes A's close back without closing B or re-registering A, so
  two menus are open in one `Overlay` and the next `open()` there closes only B.
  Read, not measured; reachable from a third-party controller, since the
  shell's own trigger calls `_toggleDropdown`, which closes mid-close instead
  ([overlay lifetime](overlay-lifetime.md#known-holes--open)). The UI-reachable
  neighbour: with B open, a tap on A's trigger mid-close passes B's barrier (A
  is a sibling) and reaches A's still-mounted barrier or A's toggle — both call
  `A.close()` — so the user's swap back does nothing visible. Also read, not
  measured.
- `_instances` grows without bound for a third-party controller that is never
  disposed. Reads filter to a mounted, attached anchor, so the cost is memory,
  not behaviour. The source records this as accepted (dartdoc on `_instances`);
  no issue tracks it.
