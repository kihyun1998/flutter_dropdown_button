# Dismissal

## What it is

Everything that closes an open menu other than choosing a row:

- an outside tap, caught by the screen-sized barrier in the overlay entry;
- a tap on a *sibling* trigger, which the barrier stands down for so the swap
  takes one tap;
- scrolling any `Scrollable` the anchor sits inside;
- the control becoming disabled while open.

## Governing decisions

- [ADR 0002 — the dismiss barrier stays; its arena participation is conditional](../../adr/0002-the-dismiss-barrier-stays-its-arena-participation-is-conditional.md#the-rules).
  Rules 1–4 govern the barrier and the sibling veto. Its
  [non-scope](../../adr/0002-the-dismiss-barrier-stays-its-arena-participation-is-conditional.md#what-this-record-does-not-cover)
  says scroll dismissal (#103) is **not** a barrier question, so scroll
  dismissal has no governing record.
- [ADR 0001](../../adr/0001-accessibility-semantics-are-attached-by-hand.md#what-these-contradict)
  governs the barrier's absence from the semantics tree (#90).

## Design model

- **The dismissing tap is consumed.** That is a contract, not a defect (#102):
  Material's `DropdownButton` measured the same. The barrier is `translucent`, so
  what is behind it still *receives* the pointer. It loses in the gesture arena.
- **The sibling veto is decided at dispatch, by hit-path membership.** It is
  decided in `handleEvent`, never in `hitTest` and never by rectangle. It covers
  the primary button only and is deliberately not filtered by
  `PointerDeviceKind`. Its own trigger is excluded: that tap already dismisses
  through the barrier.
- **Declining is not the same as losing.** `_VetoableTapRecognizer` never calls
  `super.addAllowedPointer` for a vetoed pointer, so it never joins the arena.
- **Scroll dismissal listens to every ancestor `ScrollPosition`, taken from the
  anchor's context.** Using the menu's own context would close the menu on its
  own list scroll. It listens to the position, not `isScrollingNotifier`, which
  misses `jumpTo`. It is re-read in the owner's `didChangeDependencies`
  (`refreshScrollables`), because a `Scrollable` replaces its position on theme
  or DPR changes and the old subscription dies silently.
- **Disabling while open closes the menu,** after a rebuild so that the rows stop
  holding enabled callbacks (#89).

## Code

- `lib/src/overlay/dropdown_overlay_controller.dart` — `_BarrierVeto`, `_VetoableTapRecognizer`, `_SiblingTriggerVeto`, `_RenderSiblingTriggerVeto.hitTest`, `_RenderSiblingTriggerVeto.handleEvent`, `DropdownOverlayController._watchScrollables`, `DropdownOverlayController._unwatchScrollables`, `DropdownOverlayController.refreshScrollables`, `DropdownOverlayController._handleScroll`, `DropdownOverlayController._buildEntry`
- `lib/src/shell/dropdown_menu_shell.dart` — `_DropdownMenuShellState.didChangeDependencies`, `_DropdownMenuShellState.didUpdateWidget`

Tests: `test/sibling_trigger_test.dart`, `test/scroll_dismiss_test.dart`, `test/dismiss_barrier_semantics_test.dart`, `test/disabled_open_menu_test.dart`.

## Reference behaviour

- [ADR 0002 — the root](../../adr/0002-the-dismiss-barrier-stays-its-arena-participation-is-conditional.md#the-root)
  pins `translucent` against Material's `ModalBarrier`, which is `opaque`, and
  pins the arena's first-member-wins ordering.
- [ADR 0002 — what these contradict](../../adr/0002-the-dismiss-barrier-stays-its-arena-participation-is-conditional.md#what-these-contradict)
  pins why `TapRegion` and `Listener` are one option, not two.

Scroll dismissal has **not** been compared against any reference.

## Cross-cutting invariants

- [The entry outlives the open menu](../invariant/entry-outlives-the-open-menu.md). `_handleScroll` relies on `_closing` so that per-frame notifications do not cause repeated closes.
- [The overlay does not rebuild with its owner](../invariant/overlay-does-not-rebuild-with-owner.md). Disabling while open must rebuild before it closes.

## Blast radius

- [Single-open](single-open.md) — the veto reads the `_instances` registry and
  `triggerEnabled`.
- [Overlay lifetime](overlay-lifetime.md) — calling `close` from a scroll
  notification is safe only while `close(animate: true)` defers teardown.
- [Semantics](semantics.md) — the barrier's `excludeFromSemantics`. Replacing it
  with `ExcludeSemantics` prunes the whole menu.
- [Trigger button](trigger-button.md) — both anchor paths must publish
  `triggerEnabled` for the veto to be honest.
- [Release surfaces](release-surfaces.md) — both widgets' class dartdoc advertise
  the consumed tap, the sibling-swap exception and scroll dismissal.

## Known holes / open

- Two symptoms from #95 were deliberately left as issues rather than written up
  as contract, because documenting them would lock in undecided designs
  ([lessons, Step 6](../../agents/lessons.md#step-6--정합성-스윕), #95/#102).
