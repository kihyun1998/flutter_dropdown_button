# The overlay does not rebuild with its owner

## The fact

The `OverlayEntry` is its own element subtree under the `Overlay`, not a
descendant of the widget that opened it. When the owner rebuilds, the open
menu keeps showing what it was built with: the old items, the old selection,
the old enabled callbacks. It changes only when something calls
`DropdownOverlayController.rebuild()` (`markNeedsBuild`). That call is not legal
during a build, so an owner reacting in `didUpdateWidget` defers it to a
post-frame callback.

## Why it is cross-cutting

Every input the menu draws from arrives through the owner, and each input has
its own trigger: new items, a keystroke, a checklist tap, becoming disabled.
The sites do not call one another. Each needs its own `rebuild()`, and forgetting
one looks like "works until you close and reopen".

## Territories it holds in

- [Overlay lifetime](../territory/overlay-lifetime.md) — `rebuild()` is the
  mechanism, and the entry is marked dirty, never replaced.
- [Menu shell](../territory/menu-shell.md) — `didUpdateWidget` schedules a
  post-frame `rebuild()`. The row tap calls it when `closeOnTap` is false.
- [Search](../territory/search.md) — `_onSearchChanged` calls it on every
  keystroke.
- [Multi-select](../territory/multi-select.md) — the checklist stays open
  across the owner's `setState`, and only `rebuild()` repaints the boxes.
- [Dismissal](../territory/dismissal.md) — becoming disabled while open must
  rebuild *before* it closes, or the fading rows keep enabled callbacks.

## What a violation looks like

The open menu is stale while the rest of the screen is current:
asynchronously loaded items appear only after a reopen, a checkbox does not tick
until the menu is closed, or a disabled control's rows still accept a tap. It
does not show at all if the test closes and reopens the menu between steps,
which is the usual test shape.

## Discovery history

1. **2.2.0**: `rebuildOverlay()` was added to `DropdownMixin` for search.
2. **2.4.0**: an already-open menu did not reflect items that changed
   underneath it (async load).
3. **#89**: disabling while open left rows that accepted a tap. The fix
   rebuilds, then closes, and adds a one-frame guard for the window before the
   rebuild lands.

Three occurrences, each fixed at its own site.

## Where it will recur

Any new input that the overlay content reads from `widget.*` or from owner state
is subject to this. Check: when that input changes while the menu is open, what
calls `rebuild()`? If the answer is "the owner's rebuild", nothing does.
