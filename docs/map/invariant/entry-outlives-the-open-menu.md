# The entry outlives the open menu

## The fact

`DropdownOverlayController.isOpen` is `_entry != null`. The entry survives the
whole close animation, so `isOpen` is true while the menu is on its way out.
"Is the menu open?" and "is the menu closing?" are two questions: `_closing`
(or `animation.status == reverse`) answers the second. And the close animation
itself is not guaranteed to run, because it needs an enabled `TickerMode`.

## Why it is cross-cutting

CHANGELOG 4.2.0 says it directly: "two contracts on `DropdownOverlayController`
also rested on the same wrong idea — that the overlay entry's lifetime is the
same thing as the menu being open." Readers of `isOpen` are spread across the
controller, the shell's row taps and the trigger's semantics. They read the same
flag for different purposes and do not know about one another.

## Territories it holds in

- [Overlay lifetime](../territory/overlay-lifetime.md) — `open()` must not treat
  "open while closing" as open, and teardown must not depend on the ticker.
- [Menu shell](../territory/menu-shell.md) — a row tap is refused both when
  `!isOpen` (gone) and when the status is `reverse` (going).
- [Dismissal](../territory/dismissal.md) — `_handleScroll` guards on `_closing`,
  so that per-frame scroll notifications close only once.
- [Trigger button](../territory/trigger-button.md) — the chevron rotation
  follows the animation.
- [Semantics](../territory/semantics.md) — `expanded` reads `isOpen` and stays
  true through the reverse. That is deliberate, and it holds as long as the
  chevron reads the same flag.

## What a violation looks like

- A call that should reopen the menu is silently dropped (#107).
- A tap on a fading row hands over a selection the user just dismissed (#89).
- An entry stays mounted over a pushed route and swallows every tap, because the
  reverse never ticked (#106).

All three reproduce only inside the close window, and the last only under a
muted `TickerMode`, which is why each was found separately.

## Discovery history

1. **#89**: tapping a row during an ordinary close delivered a value. It was
   found by the completeness pass on the disabled-menu fix.
2. **#91**: `expanded` was chosen to track `isOpen` through the close, with the
   clearance condition written down
   ([ADR 0001](../../adr/0001-accessibility-semantics-are-attached-by-hand.md#what-these-contradict)).
3. **#106**: `close()` never finished without a running ticker. A `Timer` now
   races the reverse.
4. **#107**: `closeAll()` followed by `open()` was a no-op.

Four occurrences.

## Where it will recur

Any code that reads `isOpen` to decide *whether to act* is subject to this.
Ask what should happen if the menu is mid-close. Anything that waits on the
animation to finish is subject to the ticker half: ask what happens under
`TickerMode(enabled: false)`. #106's discriminating probe removed the
`Navigator` and kept only the muted ticker.
