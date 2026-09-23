# Trigger button

## What it is

The control that opens the menu. There are two paths. The **chromed** path is a
box with a decoration, padding, ink, the selected face and a rotating trailing
icon, sized by `width`/`minWidth`/`maxWidth`/`expand`. The **bare** path
(`anchorBuilder`) drops the whole box and hangs the overlay off whatever the
caller draws. On either path the shell keeps the measuring key, the toggle
gesture, and the contract the trigger announces.

Single-select adds one piece of policy here: a single-item list can disable the
trigger, hide the icon, and auto-select that item.

## Governing decisions

- [ADR 0001, rules 1, 3 and 5](../../adr/0001-accessibility-semantics-are-attached-by-hand.md#the-rules).
  Both anchor paths carry the same role, enabled and expanded state.
  `anchorBuilder` changes what the anchor *looks like*, not what it *is*.

Sizing (`width` as a request that a tight parent overrides, `expand` as
`Expanded` plus a filled row) has no record. It is documented in dartdoc (#143,
#145).

## Design model

- **`width` is requested, not guaranteed.** `BoxConstraints.enforce` gives an
  incoming tight constraint the last word (a `ListView` child, for example), so
  the caller needs an `Align` for the width to arrive.
- **`expand` does two things:** it is an `Expanded` on the main axis, and it
  also sets `fillsWidth`, which fills the cross axis. It has three
  preconditions it cannot check: a `Flex` parent, no second `Expanded`, and a
  bounded `Column`.
- **The bare anchor gets focusability and keyboard activation from
  `FocusableActionDetector`**, binding the same two intents `InkWell` binds (#91).
- **The key rides on the `Semantics` render box** on the bare path, and on the
  `Container` on the chromed path. Either way it is what `measurePlacement`
  reads.
- **Single-item auto-select is caller-side policy, applied after the frame.**
  The shell is simply handed `enabled: false`.

## Code

- `lib/src/shell/dropdown_menu_shell.dart` — `_DropdownMenuShellState.build`, `_DropdownMenuShellState._buildBareAnchor`, `_DropdownMenuShellState._buildButtonContent`, `_DropdownMenuShellState._applyWidthConstraints`, `_DropdownMenuShellState._iconRotation`, `_DropdownMenuShellState._toggleDropdown`
- `lib/src/flutter_dropdown_button.dart` — `FlutterDropdownButton`, `_FlutterDropdownButtonState._isSingleItemDisabled`, `_FlutterDropdownButtonState._autoSelectSingleItem`, `_FlutterDropdownButtonState.isEnabled`
- `lib/src/theme/dropdown_button_theme.dart` — `DropdownButtonTheme.resolveButton`

Tests: `test/button_box_contract_test.dart`, `test/trigger_contract_test.dart`, `test/bare_anchor_test.dart`, `test/disabled_state_test.dart`, `test/leading_widget_test.dart`, `test/positioning_key_test.dart`.

## Reference behaviour

- [ADR 0001 — the root](../../adr/0001-accessibility-semantics-are-attached-by-hand.md#the-root)
  pins that `InkWell` contributes only tap and focus, and no role.

The sizing behaviour has **not** been compared against `DropdownButton`'s
`isExpanded`.

## Cross-cutting invariants

- [The entry outlives the open menu](../invariant/entry-outlives-the-open-menu.md). `expanded` and the chevron both read `isOpen`, so both stay "open" through the reverse animation.

## Blast radius

- [Semantics](semantics.md) — the trigger's node lives here, on two paths that
  must stay in step.
- [Dismissal](dismissal.md) — `triggerEnabled` is written in `build`, and a
  sibling barrier trusts it.
- [Placement](placement.md) — whichever render box carries `buttonKey` (or
  `positioningKey`) is what the menu is placed against.
- [Theme resolution](theme-resolution.md) — `resolveButton` supplies the box and
  the icon.
- [Example gallery](example-gallery.md) — the sizing recipe (#143) caught two
  dartdoc claims that were wrong. `recipe_renders_test.dart` pumps it.

## Known holes / open

- Keyboard operation beyond activation (arrow keys, Escape, type-ahead) does not
  exist. [ADR 0001](../../adr/0001-accessibility-semantics-are-attached-by-hand.md#what-this-record-does-not-cover)
  excludes it by name.
