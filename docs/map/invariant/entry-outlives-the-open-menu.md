# The entry outlives the open menu

## The fact

`DropdownOverlayController.isOpen` is `_entry != null` (the `isOpen` getter). The entry survives the
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

- [Overlay lifetime](../territory/overlay-lifetime.md) — `open()` reverses a
  close in flight (`if (!_closing) return;`, then `_cancelClose` and `forward`)
  rather than treating it as open, and `close()` races the reverse with
  `_closeFallback`, a `Timer` that is not ticker-gated.
- [Menu shell](../territory/menu-shell.md) — `_buildItemWrapper`'s `onTap`
  refuses a row tap both when `!isOpen` (gone) and when
  `animation.status == AnimationStatus.reverse` (going).
- [Dismissal](../territory/dismissal.md) — `_handleScroll` guards on `_closing`,
  so that per-frame scroll notifications close only once.
- [Trigger button](../territory/trigger-button.md) — two readers on one
  trigger: `anchorBuilder(context, isOpen)` hands the bare path's caller the
  flag, while the chromed path's own chevron (`_iconRotation`) follows
  `animation`, not `isOpen`, and so turns back during the reverse.
- [Semantics](../territory/semantics.md) — `expanded` reads `isOpen` and stays
  true through the reverse. That is deliberate: [ADR 0001](../../adr/0001-accessibility-semantics-are-attached-by-hand.md#what-these-contradict)
  clears it "as long as both keep reading `isOpen`", meaning the node and the
  chevron a caller draws from the same flag.
- [Single-select](../territory/single-select.md) — `closeOnTap: true` starts a
  close on every row tap, so a second tap lands in the reverse and must not
  select (`test/disabled_open_menu_test.dart`, `SingleHost`).
- [Single-open](../territory/single-open.md) — `_openPerOverlay` keeps a
  closing menu until `_teardown`, and `open()`'s reopen branch returns before it
  re-claims the registry.
- Toggling, in two places that do not call each other:
  `DropdownOverlayController.toggle` and `_DropdownMenuShellState._toggleDropdown`
  both choose close-or-open by `isOpen`, so a toggle mid-close closes again
  ([overlay lifetime](../territory/overlay-lifetime.md),
  [trigger button](../territory/trigger-button.md)).

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
