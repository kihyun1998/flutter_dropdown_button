# Overlay lifetime

## What it is

The `OverlayEntry`'s lifetime: inserting it on open, the scale/fade animation,
tearing it down on close or dispose, and telling the owner through
`onOpenStateChanged`. It is exported as `DropdownOverlayController` (barrel:
`export 'src/overlay/dropdown_overlay_controller.dart'`), so a third party
builds a dropdown by *holding* one, exactly as the package's own shell does
(`_DropdownMenuShellState._menu`). [CLAUDE.md](../../../CLAUDE.md#identity--invariants-the-boundary)
explains why this gets a completeness pass whatever the change: a leaked entry
is a dead layer that swallows taps across the consumer's whole app, and once the
widget is gone nothing is left to remove it.

## Governing decisions

**None.** No record is about the lifetime. [ADR 0002](../../adr/0002-the-dismiss-barrier-stays-its-arena-participation-is-conditional.md)
governs the barrier that the entry *contains*, not when the entry exists. The
lifetime's decisions live in the issues that made them — #106 (close completes
without a ticker), #107 (open mid-close takes the close back) — and in
CHANGELOG 4.2.0. The controller itself, and the move from `DropdownMixin` to
holding one, date from CHANGELOG 2.4.0.

## Design model

From the source and CHANGELOG 4.2.0; no record states these.

- **`isOpen` means the entry exists, not that the menu is open.**
  `isOpen => _entry != null`, which stays true for the whole close animation.
  `_closing` is the separate flag for "on its way out". This territory is where
  the invariant below originates.
- **Teardown is always reached.** The animation is decoration, not the
  mechanism: `close()` starts `_animation.reverse()` *and* a `Timer` of
  `animationDuration` (`_closeFallback`); whichever arrives first calls
  `_teardown`, and `_cancelClose` makes the other a no-op. A pushed route mutes
  `TickerMode` below it, and before this the entry stayed mounted over the new
  page, swallowing taps — measured `page2Taps=0` three taps running (#106,
  `test/overlay_close_contract_test.dart`).
- **`open()` during a close takes the close back** instead of being dropped:
  `if (!_closing) return;`, then `_cancelClose`, `forward`, `rebuild` (#107,
  `closeAll()` followed by `open()`). It takes the existing entry back; it does
  not re-insert, re-register in the per-`Overlay` registry, or notify the owner
  (the owner was never told it closed).
- **`close(animate: false)` and `dispose` tear down synchronously.** `dispose`
  does so silently (`_teardown(notify: false)`), because the owner must not be
  asked to rebuild while it is being torn down
  (`test/overlay/dropdown_overlay_controller_test.dart`, "disposing does not
  notify the owner").
- **`_teardown` survives a missing `Overlay`** (a route transition): it cancels
  the close and drops the scroll subscriptions first, removes the entry in a
  `try`, then clears `_entry`, prunes the per-`Overlay` registry and notifies the
  owner in `finally`.
- **The entry is rebuilt, never replaced**, by `rebuild()`, which is
  `_entry?.markNeedsBuild()` and so a no-op while closed. Not legal during a
  build; callers defer it to a post-frame callback.
- **The shell disposes the menu before the scroll controller**
  (`_DropdownMenuShellState.dispose`): tearing the entry down unmounts the
  scroll gradient that listens to that controller.

## Code

- `lib/src/overlay/dropdown_overlay_controller.dart` — `DropdownOverlayController.open`, `DropdownOverlayController.close`, `DropdownOverlayController.toggle`, `DropdownOverlayController._cancelClose`, `DropdownOverlayController._teardown`, `DropdownOverlayController.dispose`, `DropdownOverlayController.rebuild`, `DropdownOverlayController.isOpen`, `DropdownOverlayController.animation`, `DropdownOverlayController._closing`, `DropdownOverlayController._closeFallback`, `DropdownOverlayController._disposed`, `DropdownOverlayController._scale`, `DropdownOverlayController._opacity`, `DropdownOverlayController._buildEntry`, `DropdownOverlayController.onOpenStateChanged`, `DropdownOverlaySpec`, `DropdownOverlaySpecBuilder`
- `lib/src/shell/dropdown_menu_shell.dart` — `_DropdownMenuShellState._menu` (the held controller and its `onOpenStateChanged`), `_DropdownMenuShellState.dispose`, `_DropdownMenuShellState._openDropdown`, `_DropdownMenuShellState._toggleDropdown`

Tests: `test/overlay_close_contract_test.dart` (#106, #107), `test/overlay_lifecycle_test.dart`, `test/overlay_controller_widget_test.dart`, `test/overlay/dropdown_overlay_controller_test.dart`, `test/animation_test.dart`.

## Reference behaviour

**None.** `material/dropdown.dart` manages its menu as a `PopupRoute`
(`_DropdownRoute`, [lessons, Step 1](../../agents/lessons.md#step-1--이슈-먼저-근거기각-대안부정-결과)),
so its lifetime belongs to the `Navigator`. No lifetime rule here has been
compared against it, and the comparison may not transfer, since this package
deliberately does not use a route.

## Cross-cutting invariants

- [The entry outlives the open menu](../invariant/entry-outlives-the-open-menu.md) — `isOpen`/`_closing`, the reopen branch of `open()`, the `_closeFallback` race.
- [The overlay does not rebuild with its owner](../invariant/overlay-does-not-rebuild-with-owner.md) — `rebuild()` is the mechanism.
- [The Flutter floor is measured, not read](../invariant/flutter-floor-is-measured.md) — the `_closeFallback` timer exists because `TickerMode.valuesOf` is missing at the 3.32 floor and `TickerMode.of` is deprecated above 3.35 (comment in `close`, #106).

## Blast radius

- [Single-open](single-open.md) — the per-`Overlay` registry is written on this
  territory's edges (`open` registers, `_teardown` prunes) and `_instances` on
  the constructor and `dispose`. A teardown path that skips `_teardown` leaves
  a closed menu registered as its `Overlay`'s open one; a reopen path that skips
  registration leaves an open menu the next `open()` will not close.
- [Dismissal](dismissal.md) — scroll subscriptions are taken in `open` and
  dropped in `_teardown`, and `_handleScroll` calls `close()` from a scroll
  notification that can run during layout. That is safe only while
  `close(animate: true)` defers teardown; a synchronous close there unmounts the
  entry mid-layout.
- [Menu shell](menu-shell.md) — the row tap guard reads `isOpen` (gone) and
  `animation.status` (going); a change to when either flips reopens the window
  in which a cancelled menu still selects (#89). `onOpenStateChanged` is also
  what resets the search and arms the scroll-to-item.
- [Semantics](semantics.md) — the trigger's `expanded` reads `isOpen`, so it
  announces "open" exactly as long as the entry exists.
- [Trigger button](trigger-button.md) — the chevron's `_iconRotation` follows
  `animation`, and the anchor's tap goes through `_toggleDropdown`, which
  chooses close or open by `isOpen`.

## Known holes / open

- **`toggle` during a close closes again rather than reopening.**
  `DropdownOverlayController.toggle` and the shell's `_toggleDropdown` are both
  `isOpen ? close() : open(…)`, so mid-close they pick `close()` — the #107
  shape, on the member `isOpen`'s own dartdoc says a caller need not account
  for. Read, not measured. Through the package's widgets the dismiss barrier
  usually takes the tap first; see [single-open](single-open.md) for the case
  where it does not.
- **Nothing ties the entry to the owner but `dispose()`.** A third-party owner
  that is disposed without calling `DropdownOverlayController.dispose` leaves
  the entry inserted; `measurePlacement` then returns null and the entry draws
  `SizedBox.shrink` on its next build, but nothing removes it. Read, not
  measured. The `_instances` half of the same skip is in
  [single-open](single-open.md).
