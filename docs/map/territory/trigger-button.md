# Trigger button

## What it is

The control that opens the menu. There are two paths. The **chromed** path is a
box with a decoration, padding, ink, the selected face and a rotating trailing
icon, sized by `width`/`minWidth`/`maxWidth`/`expand`. The **bare** path
(`anchorBuilder`) drops the whole box and hangs the overlay off whatever the
caller draws. On either path the shell keeps the measuring key, the toggle
gesture, and the contract the trigger announces.

The trigger takes `enabled` and `showTrailing` as plain booleans and does not
know why either is false. The single-item rule that can make them false is
[single-select](single-select.md) policy.

## Governing decisions

- [ADR 0001, rules 1, 3 and 5](../../adr/0001-accessibility-semantics-are-attached-by-hand.md#the-rules).
  Both anchor paths carry the same role, enabled and expanded state.
  `anchorBuilder` changes what the anchor *looks like*, not what it *is*.

Sizing (`width` as a request that a tight parent overrides, `expand` as
`Expanded` plus a filled row) has no record. It is documented in dartdoc on
`DropdownMenuShell.width`/`expand` and on both public widgets (#143, #145;
commit dfe81d4), and pinned by `test/button_box_contract_test.dart`.

## Design model

Source: the shell's comments, the commits cited, and the tests named. Only the
semantics contract comes from a record.

- **`width` is requested, not guaranteed.** It is `Container(width:)`, and
  `BoxConstraints.enforce` gives an incoming tight constraint the last word (a
  `ListView` child, for example), so the caller needs an `Align` for the width
  to arrive (#145). `minWidth`/`maxWidth` are read only when `width` is null
  (`_applyWidthConstraints`).
- **`expand` does two things.** `_applyWidthConstraints` wraps the button in an
  `Expanded`, which fills the main axis. It also sets `fillsWidth` in
  `_buildButtonContent`, which puts the content row in `MainAxisSize.max` and
  so fills the cross axis. It has three preconditions it cannot check: a `Flex`
  parent, no second `Expanded`, and a bounded `Column` (#143, #145).
- **The bare anchor gets focusability and keyboard activation from
  `FocusableActionDetector`**, binding `ActivateIntent` and
  `ButtonActivateIntent`, the two intents `InkWell` binds (#91, commit 00eae3b).
  `enabled: widget.enabled` on the detector takes a disabled anchor out of the
  traversal.
- **The key rides on the `Semantics` render box** on the bare path, and on the
  `Container` on the chromed path. Either way, unless a `positioningKey` is
  given, it is what `DropdownOverlayController.measurePlacement` reads.
- **`build` writes two controller fields every time it runs:**
  `_menu.positioningKey` and `_menu.triggerEnabled = widget.enabled`. These are
  plain field assignments, not rebuilds. A sibling's dismiss barrier reads
  `triggerEnabled` to decide whether to stand down over this anchor (#95).
- **One `enabled` reaches the trigger.** The decoration, the icon colour
  (`resolveButton(enabled:)`), the `InkWell`/`GestureDetector` tap, the cursor,
  `Semantics.enabled` and `triggerEnabled` all read `widget.enabled`.
- **The chevron and `expanded` read different things.** `Semantics.expanded`
  and the `isOpen` handed to `anchorBuilder` read `_menu.isOpen`, which stays
  true through the close animation. The chromed path's own icon turns by
  `_iconRotation`, a tween over `_menu.animation`, so it turns back *during* the
  reverse.
- **`showTrailing: false` removes the icon on the chromed path only.** The bare
  path never draws one.

## Code

- `lib/src/shell/dropdown_menu_shell.dart` — `_DropdownMenuShellState.build`, `_DropdownMenuShellState._buildBareAnchor`, `_DropdownMenuShellState._buildButtonContent`, `_DropdownMenuShellState._applyWidthConstraints`, `_DropdownMenuShellState._iconRotation`, `_DropdownMenuShellState._toggleDropdown`, `_DropdownMenuShellState._buttonStyle`
- `lib/src/theme/dropdown_button_theme.dart` — `DropdownButtonTheme.resolveButton`

Tests: `test/button_box_contract_test.dart`, `test/trigger_contract_test.dart`, `test/bare_anchor_test.dart`, `test/disabled_state_test.dart`, `test/leading_widget_test.dart`, `test/positioning_key_test.dart`.

## Reference behaviour

- [ADR 0001 — the root](../../adr/0001-accessibility-semantics-are-attached-by-hand.md#the-root)
  pins that `InkWell` contributes only tap and focus, and no role.

The sizing behaviour has **not** been compared against `DropdownButton`'s
`isExpanded`.

## Cross-cutting invariants

- [The entry outlives the open menu](../invariant/entry-outlives-the-open-menu.md). `expanded` and `anchorBuilder`'s `isOpen` read `_menu.isOpen` and stay "open" through the reverse. The chromed chevron follows `animation` and does not.

## Blast radius

- [Semantics](semantics.md) — the trigger's node is built twice, once per path,
  and ADR 0001 rule 5 requires both to carry the same role, enabled and
  expanded state.
- [Dismissal](dismissal.md) — a sibling's barrier trusts `triggerEnabled` to
  say whether this anchor will act on a tap. If `build` stops writing it, the
  barrier stands down over a disabled anchor and nobody claims the tap.
- [Placement](placement.md) — the menu is placed against whichever render box
  carries `buttonKey` (or `positioningKey`). Moving the key changes what the
  menu measures.
- [Theme resolution](theme-resolution.md) — `resolveButton` supplies the box,
  padding, ink colours and the icon, and the `enabled` it is handed picks the
  disabled forms.
- [Single-select](single-select.md) — its single-item rule arrives here only as
  `enabled: false` and `showTrailing: false`. A trigger reading any other
  source of "enabled" would split the control's look from its behaviour, which
  is what 1.6.0 and 2.4.1 fixed.
- [Example gallery](example-gallery.md) — running the recipes exposed the
  `expand` dartdoc as wrong (#143). #145 corrected it and the `width` dartdoc.
  `example/test/recipe_renders_test.dart` pumps every recipe, and the
  Dismissal recipe holds both `expand` shapes.

## Known holes / open

- Keyboard operation beyond activation (arrow keys, Escape, type-ahead) does not
  exist. [ADR 0001](../../adr/0001-accessibility-semantics-are-attached-by-hand.md#what-this-record-does-not-cover)
  excludes it by name.
- `_DropdownMenuShellState._toggleDropdown` picks close or open by
  `_menu.isOpen`, so a trigger tap during the close animation closes again
  instead of reopening (read, not measured; see
  [the entry outlives the open menu](../invariant/entry-outlives-the-open-menu.md)).
- `FlutterDropdownButton.anchorBuilder`'s dartdoc says the overlay keeps
  "keyboard navigation" in bare mode. Only activation exists (see above).
