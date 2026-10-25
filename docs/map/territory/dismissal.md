# Dismissal

## What it is

Everything that closes an open menu other than choosing a row:

- an outside tap, caught by the barrier in the overlay entry — "outside" meaning
  outside the menu but inside the hosting `Overlay`;
- a tap on a *sibling* trigger, which the barrier stands down for so the swap
  takes one tap;
- scrolling any `Scrollable` the anchor sits inside;
- the control becoming disabled while open.

## Governing decisions

- [ADR 0002 — the dismiss barrier stays; its arena participation is conditional](../../adr/0002-the-dismiss-barrier-stays-its-arena-participation-is-conditional.md#the-rules).
  Rules 1–4 govern the barrier and the sibling veto; rule 5 is why scroll
  dismissal is filed here without being a barrier question. Its
  [non-scope](../../adr/0002-the-dismiss-barrier-stays-its-arena-participation-is-conditional.md#what-this-record-does-not-cover)
  leaves "whether the menu should follow its anchor" to #103, so scroll
  dismissal has no governing record — its decision is #103's (commit e09e290).
- [ADR 0001](../../adr/0001-accessibility-semantics-are-attached-by-hand.md#what-these-contradict)
  governs the barrier's absence from the semantics tree (settled in #90).

## Design model

The barrier rules are ADR 0002's; the scroll and disable rules are from the
source and CHANGELOG 4.2.0 only.

- **The dismissing tap is consumed.** A contract, not a defect (#102, ADR 0002
  "What these derive"): Material's `DropdownButton` measured the same tap counts
  ([lessons, Step 1](../../agents/lessons.md#step-1--이슈-먼저-근거기각-대안부정-결과)).
  The barrier is a `RawGestureDetector` with `HitTestBehavior.translucent`, so
  what is behind it still *receives* the pointer; it loses in the gesture arena,
  which the barrier joins first.
- **The barrier is the size of the hosting `Overlay`, not the screen**
  (`SizedBox.expand` inside the entry). A tap beyond a nested `Overlay`'s region
  does not dismiss; `closeAll` does ([single-open](single-open.md),
  `test/overlay_bounds_test.dart`).
- **The sibling veto is decided at dispatch, by hit-path membership.**
  `_RenderSiblingTriggerVeto.hitTest` only records which result its entry went
  into; `handleEvent` decides, once the path is complete, by whether any
  sibling's `buttonKey` render object is in it — never by rectangle (ADR 0002
  rules 3–4). It covers `PointerDownEvent` with `kPrimaryButton` only and is
  deliberately not filtered by `PointerDeviceKind`. Its own trigger is excluded
  (`_siblingTriggersFor`): that tap already dismisses through the barrier. Over
  the menu's own area no veto can fire, because `RenderTheatre` stops before the
  entries below once the menu absorbs the hit.
- **Declining is not the same as losing.** `_VetoableTapRecognizer` never calls
  `super.addAllowedPointer` for a vetoed pointer, so it never joins the arena.
  The veto travels from the render object to the recognizer through
  `_BarrierVeto`, keyed by pointer id so two simultaneous fingers each get their
  own answer.
- **Scroll dismissal listens to every ancestor `ScrollPosition`, taken from the
  anchor's context.** `_watchScrollables` walks `visitAncestorElements` from the
  context `open()` was handed (the shell's own). The menu's context would close
  the menu on its own list scroll. It listens to the position, not
  `isScrollingNotifier`, which misses `jumpTo` (measured: a 300px jump left the
  menu open, #103). Every ancestor, not the nearest: measured 130px of outer
  scroll with a nearest-only subscription left stale (#103). It fires per frame
  during a drag; `_closing` makes all but the first a no-op.
- **The subscription is re-read in the owner's `didChangeDependencies`**
  (`refreshScrollables`), because a `Scrollable` replaces its position from its
  own `didChangeDependencies` — theme or DPR changes — and the old subscription
  dies silently (#103, "it survives the scroll position being replaced"). A
  third-party owner must call it; the class dartdoc names it as one of the two
  members that fail silently if skipped.
- **Disabling while open closes the menu,** after a post-frame `rebuild()` so
  the rows stop holding enabled callbacks before the close animates them out
  (#89, `_DropdownMenuShellState.didUpdateWidget`). Reached without touching
  `enabled` too, through `disableWhenSingleItem` and a list that shrinks to one
  (`test/disabled_open_menu_test.dart`).

## Code

- `lib/src/overlay/dropdown_overlay_controller.dart` — `_BarrierVeto`, `_VetoableTapRecognizer.addAllowedPointer`, `_SiblingTriggerVeto`, `_RenderSiblingTriggerVeto.hitTest`, `_RenderSiblingTriggerVeto.handleEvent`, `DropdownOverlayController._veto`, `DropdownOverlayController._siblingTriggersFor`, `DropdownOverlayController._watchScrollables`, `DropdownOverlayController._unwatchScrollables`, `DropdownOverlayController._watchedScrollables`, `DropdownOverlayController.refreshScrollables`, `DropdownOverlayController._handleScroll`, `DropdownOverlayController._buildEntry` (the barrier: `RawGestureDetector`, `excludeFromSemantics: true`, `onTap = close`)
- `lib/src/shell/dropdown_menu_shell.dart` — `_DropdownMenuShellState.didChangeDependencies`, `_DropdownMenuShellState.didUpdateWidget`, `_DropdownMenuShellState.build` (publishes `triggerEnabled`)

Tests: `test/sibling_trigger_test.dart`, `test/scroll_dismiss_test.dart`, `test/dismiss_barrier_semantics_test.dart`, `test/disabled_open_menu_test.dart`, `test/overlay_bounds_test.dart` ("'outside' is scoped to the hosting Overlay").

## Reference behaviour

- [ADR 0002 — the root](../../adr/0002-the-dismiss-barrier-stays-its-arena-participation-is-conditional.md#the-root)
  pins `translucent` against Material's `ModalBarrier`, which is `opaque`, and
  pins the arena's first-member-wins ordering.
- [ADR 0002 — what these contradict](../../adr/0002-the-dismiss-barrier-stays-its-arena-participation-is-conditional.md#what-these-contradict)
  pins why `TapRegion` and `Listener` are one option, not two.
- The consumed tap was measured against Material's `DropdownButton`
  (`_DropdownRoute`, a `PopupRoute`): identical tap counts
  ([lessons, Step 1](../../agents/lessons.md#step-1--이슈-먼저-근거기각-대안부정-결과), #95/#102).
- Scroll dismissal was compared in #103 (commit e09e290): the surveyed
  conventions are lock the background (MUI, Radix), follow the anchor
  (Floating UI), or close; closing is "what Flutter's own newest menu does", and
  watching every ancestor is "a deliberate step past the reference, which
  subscribes to one level". The reference's source was not pinned in the repo.

## Cross-cutting invariants

- [The entry outlives the open menu](../invariant/entry-outlives-the-open-menu.md) — `_handleScroll` relies on `_closing` so per-frame notifications close only once; the barrier stays in the hit path through the close animation, which is why a sibling tap mid-close still needs the veto.
- [The overlay does not rebuild with its owner](../invariant/overlay-does-not-rebuild-with-owner.md) — disabling while open must rebuild before it closes.

## Blast radius

- [Single-open](single-open.md) — the veto reads `_instances` and
  `triggerEnabled`. Both are assumed current: a stale controller or an
  unpublished disabled state makes the barrier stand down over an anchor that
  will not take the tap, leaving the tap claimed by nobody and the menu open.
- [Overlay lifetime](overlay-lifetime.md) — `_handleScroll` calls `close()` from
  a scroll notification that can run during layout; that is safe only while
  `close(animate: true)` defers teardown.
- [Placement](placement.md) — scroll dismissal exists because placement does not
  track the anchor (`measurePlacement` runs once per overlay build). Dropping
  the close leaves a scrolled menu at coordinates that no longer point at the
  anchor; making placement follow the anchor reopens whether scrolling should
  still close.
- [Semantics](semantics.md) — the barrier's `excludeFromSemantics`. The rows are
  descendants of the barrier, so replacing it with `ExcludeSemantics` prunes the
  whole menu from the tree.
- [Trigger button](trigger-button.md) — both anchor paths hit-test opaque even
  when disabled, so the veto is honest only while the shell publishes
  `triggerEnabled` for both.
- [Single-select](single-select.md) — single-item mode disables the control by
  shrinking the list; it relies on disable-closes-the-menu to take away a menu
  whose one row no longer does anything.
- [Release surfaces](release-surfaces.md) — both widgets' class dartdoc
  advertise the consumed tap, the sibling-swap exception and scroll dismissal,
  and `documentation/api_reference.md` restates all three plus the
  `Overlay`-scoped "outside".

## Known holes / open

- **The menu does not follow its anchor; it closes on scroll instead.** #103
  chose this, and ADR 0002 leaves it there: following is "an order of magnitude
  more expensive" (e09e290) and stays out of scope. Documented rather than fixed
  in the same commit, all measured there: an anchor pinned so a scroll does not
  move it still has its menu dismissed (the rule is "the surroundings
  scrolled", not "the anchor moved"); the scroll rule is scoped to the widget
  ancestry while the outside-tap rule is scoped to the hosting `Overlay`, so
  the two sets differ; and a `positioningKey` box is not watched, only the
  anchor ([placement](placement.md)).
- **`refreshScrollables` is only as complete as the owner's dependencies.** It
  runs when the shell's `didChangeDependencies` does, and an ancestor
  `Scrollable` replaces its position on *its* dependencies. The test covers a
  theme change, which reaches both; a change only the `Scrollable` depends on
  would leave the subscription on a disposed position. Read, not measured.
