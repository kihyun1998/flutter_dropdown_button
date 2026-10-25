# Multi-select

## What it is

`FlutterMultiSelectDropdown<T>`, the checklist, and the selection policy it
hands the shell. It is a `StatelessWidget` over `DropdownMenuShell`. `isChosen`
is `selected.contains`, a tap toggles into a **fresh** `Set` passed to
`onChanged` (`_toggle`), `closeOnTap` is false, and `scrollToItem` is null, so
nothing scrolls to a chosen row. Rows are drawn by `MultiSelectPresentation`
with a `FlutterCheckbox`, styled by `DropdownCheckboxTheme`. It is the twin of
[single-select](single-select.md): the same shell parameters, a different
policy. **Cardinality is a type:** `value`, `scrollToSelectedItem` and
`disableWhenSingleItem` do not exist on this widget
([CLAUDE.md](../../../CLAUDE.md#identity--invariants-the-boundary)).

## Governing decisions

- [ADR 0001, rules 2 and 3](../../adr/0001-accessibility-semantics-are-attached-by-hand.md#the-rules).
  The row says `checked`, and the box is excluded so that the row is one
  complete node (#64, #81). The code follows it:
  `MultiSelectPresentation.buildItem` wraps the row in `Semantics(checked:)` and
  the box in `ExcludeSemantics`.

The rejection of a `.multiSelect` named constructor is recorded in CLAUDE.md,
not in a record.

## Design model

From the source and the widget's dartdoc unless a source is given.

- **`selected` belongs to the caller.** The widget never edits it: `_toggle`
  copies it, and the copy goes to `onChanged`. A value no longer in `items`
  still counts toward `labelBuilder` and draws no row, so a refresh cannot throw
  or silently drop a choice (`test/multi_select_test.dart`, "a chosen value
  absent from items counts, but draws no row").
- **`T` needs `==` and `hashCode`** because a `Set` uses both. Single-select
  needs only `==`. Nothing checks this.
- **The menu stays open across ticks.** `closeOnTap: false` makes the shell's
  row tap call `_menu.rebuild()` instead of closing, and the owner's rebuild
  reaches the open overlay through the shell's `didUpdateWidget`
  (`test/multi_select_test.dart`, "the boxes repaint when the owner rebuilds").
  The search query survives a tick for the same reason.
- **The box is presentational.** It has `onChanged: null` (so a tap falls
  through to the row), it is inside `ExcludeSemantics`, and `enabled` is left at
  its default. `FlutterCheckbox` dims only on `enabled: false`, unlike Material,
  where `onChanged: null` greys the box out ([lessons, #81](../../agents/lessons.md);
  `test/presentation/multi_select_presentation_test.dart`, "the box is
  presentational but not greyed").
- **`CheckboxShape`/`CheckboxStyle` are re-exported** from the barrel, so
  `flutter_checkbox`'s public types are this package's API. An upstream breaking
  change at `0.x` is a breaking change here.
- **The checkbox theme reaches the overlay only through `DropdownCheckboxTheme`.**
  The menu is drawn in the root `Overlay`, outside a local `Theme`
  (CHANGELOG 3.2.0, FIX; `test/multi_select_test.dart`, "a checkbox theme reaches
  the boxes in the overlay").
- **Input bound:** nothing bounds `items` or `selected`. Each tap copies the
  whole set.

## Code

- `lib/src/flutter_multi_select_dropdown.dart` — `FlutterMultiSelectDropdown`, `FlutterMultiSelectDropdown._toggle`, `FlutterMultiSelectDropdown.build`, `FlutterMultiSelectDropdown.closeAll`
- `lib/src/presentation/item_presentation.dart` — `MultiSelectPresentation`, `MultiSelectPresentation.buildItem`, `MultiSelectPresentation.buildSelected`
- `lib/src/theme/dropdown_checkbox_theme.dart` — `DropdownCheckboxTheme`, `DropdownCheckboxTheme.resolve`
- `lib/flutter_dropdown_button.dart` — the `export 'package:flutter_checkbox/…' show CheckboxShape, CheckboxStyle` line

Tests: `test/multi_select_test.dart`, `test/presentation/multi_select_presentation_test.dart`, `test/theme/dropdown_checkbox_theme_test.dart`.

## Reference behaviour

- `flutter_checkbox` is a **binding** reference
  ([references](../../agents/thegraph.md#references)). Its emitted semantics
  (`enabled: true` under `onChanged: null`) were read from its source,
  `checkbox_interaction.dart`, for #81 ([lessons](../../agents/lessons.md)).
  `pubspec.yaml` asks for `^0.3.1`.
- `CHB61/multi_select_flutter` is an **example** reference. It has not been
  compared.

## Cross-cutting invariants

- [The overlay does not rebuild with its owner](../invariant/overlay-does-not-rebuild-with-owner.md).
  With `closeOnTap: false` the menu stays open across the owner's rebuild, and
  only `rebuild()` repaints the boxes.
- [The Flutter floor is measured, not read](../invariant/flutter-floor-is-measured.md).
  `flutter_checkbox`'s own floor is read at the version pinned: 0.3.0 declared
  `>=3.35.0`, 0.3.1 `>=3.27.0`, so the floor stayed at 3.32
  ([lessons, #80/#81](../../agents/lessons.md); CHANGELOG 4.0.0).
- [The text presentations render a config alike](../invariant/text-presentations-render-config-alike.md). `MultiSelectPresentation` is the checklist copy of the five
  config-rendering concerns.

## Blast radius

- [Single-select](single-select.md) — the twin policy over the same shell. A
  shell parameter added for one widget is either passed by the other or left at
  a default that must be right for it. Cardinality-only parameters must not
  cross over.
- [Menu shell](menu-shell.md) — every shell parameter is passed through, and
  the checklist is the only caller with `closeOnTap: false`. A shell change that
  assumes a tap closes the menu breaks it.
- [Semantics](semantics.md) — the row's `checked` depends on the box staying
  excluded. Upgrading `flutter_checkbox` can change what the box emits, and ADR
  0001 rule 4 says to re-derive what each test checks.
- [Single-open](single-open.md) — `closeAll` forwards to the shared registry,
  so it closes dropdowns of either kind.
- [Release surfaces](release-surfaces.md) — bumping `flutter_checkbox` in
  `pubspec.yaml` may be a breaking change through the re-export.

## Known holes / open

- `pubspec.lock` is gitignored (`/pubspec.lock`, per Dart's library guidance),
  so "the version the lockfile pins" in the references table has no committed
  pin. The only committed constraint is `^0.3.1`, which lets a consumer
  resolve any later `0.3.x`.
- A `T` with a hand-written `==` and the default `hashCode` lets the `Set` hold
  duplicates that look identical. This is documented
  (`documentation/api_reference.md`), not checked.
