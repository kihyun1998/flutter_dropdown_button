# 0002 — The dismiss barrier stays; what is conditional is its arena participation

**Status:** Accepted — 2026-08-16. Promoted out of the spine
[#105](https://github.com/kihyun1998/flutter_dropdown_button/issues/105), whose
own root hypothesis this record falsifies.

## Why a record rather than another issue

The same question has now been decided four times, and three of those decisions
were the same decision arrived at from scratch:

- **Remove the barrier, use `TapRegion`** — proposed twice, rejected twice.
- **Remove the barrier, use `Listener`** — proposed twice, rejected twice.
- **Keep the barrier, punch geometric holes in it** — proposed once, approved by
  the owner, and refuted by measurement before a line was written.

Each round re-derived the same facts about hit-testing and the gesture arena
from cold, and each round cost a completeness pass. An issue records one
decision with its rejected alternatives; it cannot hold the rule that makes the
next combination resolvable without a fifth investigation.

The spine that collected them proposed a root — *"the barrier is a screen-sized
front widget, and its **existence** is the root"* — and that root is now
measured false. Both symptoms it was opened for were fixed with the front widget
left exactly where it was. This record replaces it with the narrower thing that
survived.

## The root

The barrier is a screen-filling `translucent` widget wrapped around the open
menu. `translucent` does **not** block hit-testing: it adds itself to the hit
path and returns `false` (`rendering/proxy_box.dart:183-192`), so
`RenderTheatre` keeps testing the entries below it
(`widgets/overlay.dart:1136-1153`) and the widget underneath really does receive
the pointer — measured `listenerDowns=1 listenerUps=1 taps=0`.

What it takes is the **gesture arena**. Members join in hit-path order and only
the first wins (`gestures/arena.dart:157-178`). Measured on a 41-entry path: the
barrier enters at index 0, the sibling trigger the user was aiming at at index
10.

**So the root is ordering, not existence.** Material's `ModalBarrier` is
`HitTestBehavior.opaque` (`widgets/modal_barrier.dart:441`) and genuinely blocks
hit-testing; ours never did. The two produce the same tap counts by different
mechanisms, and the difference is observable.

## The rules

1. **The barrier stays.** Every proposal to remove it has been rejected on
   measurement, not on taste. It is the only screen-sized hit target in the
   overlay entry, and in a bare `Overlay` host with no `WidgetsApp` it is the
   only reason outside-tap dismissal works at all.

2. **What varies is the barrier's participation in the arena, never its
   existence.** A symptom that looks like "the barrier is in the way" is fixed
   by making it *stand down* for a specific pointer, not by deleting it.

3. **"Who should get this pointer" is decided at dispatch, never in `hitTest`.**
   At `hitTest` the barrier is at index 0 and the answer does not exist yet — the
   path below it has not been built. `handleEvent` runs when the path is
   complete, and a child is reached before its parent, which is the window in
   which the question is answerable. This is the shape `RenderTapRegionSurface`
   uses (`widgets/tap_region.dart`), for this reason.

4. **Geometry cannot answer "is this pointer on that widget".** A rectangle
   cannot see clips, transforms, `IgnorePointer`, `Offstage`, or occlusion.
   Measured worst case: a dropdown behind a dialog reports a box byte-identical
   to its uncovered one, `Rect.fromLTRB(40, 90, 190, 140)` either way — so a
   geometric test would have sent that tap to the dialog's own barrier and
   dismissed the dialog. Membership of the live hit path is the only honest
   test.

5. **Not every symptom near the barrier is a barrier symptom.** The rule that
   the spine got wrong. Check whether the fix has to touch the barrier at all
   before filing the symptom under this record.

## What these derive

- **#95 — swapping dropdowns cost two taps.** Rule 2 keeps the barrier; rule 3
  puts the decision in `handleEvent`; rule 4 rules out the approved geometric
  design. The fix declines to join the arena for a pointer over a registered
  sibling trigger. Nothing about the barrier's existence changed.
- **#102 — the dismissing tap is consumed.** A contract, not a defect, and rule
  1 is why: the consumption is the barrier doing its job.
- **#90 — the barrier polluted the semantics tree.** `excludeFromSemantics`
  rather than `ExcludeSemantics`: drop the annotation, keep the widget. Rule 2
  in a different register.
- **#89 — a menu stops accepting taps when the control does.** Decided on the
  barrier staying and gating behaviour, not on removing it.

## What these contradict

- **The spine's stated root.** #105 held that removing the front widget would
  make the symptoms vanish at once. Two symptoms were fixed with it in place,
  and one of them (#103) turned out not to involve the barrier at all. Recorded
  in that issue rather than quietly dropped, because the falsification is the
  more useful half.
- **"`TapRegion` cannot be worked around" (retracted).** The probe behind that
  claim was misbuilt — the surface was planted below a screen-sized `Material`,
  so nothing in its subtree was hit (`docs/agents/lessons.md`). The workaround
  does succeed. The standing rejection is the *circularity*: making it work
  requires restoring the full-screen front hit target, which is the thing
  `TapRegion` was supposed to remove.
- **"`TapRegion` and `Listener` are different options."** They are one option.
  `onTapOutside` is a `PointerDownEvent` callback filtered only by event type
  (`widgets/tap_region.dart:257`, `:294`), so it fires for right-click, stylus
  and a second finger exactly as a raw `Listener` would — which is the owner's
  stated reason for rejecting `Listener`. Rejecting one rejects both.

## What this record does not cover

- **Whether the menu should follow its anchor.** #103 chose closing, and the
  per-frame-measurement alternative remains out of scope. That decision lives in
  #103, not here — it is not a barrier question.
- **Placement geometry.** `DropdownPlacement` is pure and unrelated.
- **Semantics emission**, which is [0001](0001-accessibility-semantics-are-attached-by-hand.md)'s
  territory. #90 appears above for its barrier half only.
- **The registered-trigger registry's shape** — lifetime, scoping, and what
  `triggerEnabled` means are #95's decisions, recorded there.

## Consequences

A future proposal to delete the barrier is not a fresh design question; it is a
proposal to reverse rule 1, and it owes a measurement against a bare `Overlay`
host. A future proposal to decide pointer ownership from rectangles owes a
measurement against an occluded anchor. Both have been run, and both are in
here so the next one starts from the number rather than from the idea.
