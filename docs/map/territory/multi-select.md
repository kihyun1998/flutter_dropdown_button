# Multi-select

## What it is

`FlutterMultiSelectDropdown`, the checklist. It is a `StatelessWidget` over the
shell: `isChosen` is `selected.contains`, a tap toggles into a **fresh** `Set`
passed to `onChanged`, `closeOnTap` is false, and nothing scrolls to a chosen
row. Rows are drawn by `MultiSelectPresentation` with a `FlutterCheckbox` box,
styled by `DropdownCheckboxTheme`. **Cardinality is a type:** `value`,
`scrollToSelectedItem` and `disableWhenSingleItem` do not exist on this widget
([CLAUDE.md](../../../CLAUDE.md#identity--invariants-the-boundary)).

## Governing decisions

- [ADR 0001, rules 2 and 3](../../adr/0001-accessibility-semantics-are-attached-by-hand.md#the-rules).
  The row says `checked`, and the box is excluded so that there is one complete
  node (#64, #81).

Rejecting a `.multiSelect` named constructor is recorded in CLAUDE.md, not in a
record.

## Design model

- **`selected` belongs to the caller.** The widget never edits it. A value no
  longer in `items` still counts toward `labelBuilder` and draws no row, so a
  refresh cannot throw or silently drop a choice.
- **`T` needs `==` and `hashCode`** (a `Set`), where single-select needed only
  `==`.
- **The box is presentational:** `onChanged: null`, `ExcludeSemantics`, and
  `enabled` left at its default because `FlutterCheckbox` dims only on
  `enabled: false`. That differs from Material, where `onChanged: null` greys
  the box out (#81).
- **`CheckboxShape`/`CheckboxStyle` are re-exported,** so `flutter_checkbox`'s
  public types are this package's API. An upstream breaking change at `0.x` is a
  breaking change here.

## Code

- `lib/src/flutter_multi_select_dropdown.dart` — `FlutterMultiSelectDropdown`, `FlutterMultiSelectDropdown._toggle`, `FlutterMultiSelectDropdown.build`
- `lib/src/presentation/item_presentation.dart` — `MultiSelectPresentation`, `MultiSelectPresentation.buildItem`, `MultiSelectPresentation.buildSelected`
- `lib/src/theme/dropdown_checkbox_theme.dart` — `DropdownCheckboxTheme`, `DropdownCheckboxTheme.resolve`
- `lib/flutter_dropdown_button.dart` — `CheckboxShape`, `CheckboxStyle`

Tests: `test/multi_select_test.dart`, `test/presentation/multi_select_presentation_test.dart`.

## Reference behaviour

- `flutter_checkbox` is a **binding** reference, read at the version the lockfile
  pins ([references](../../agents/thegraph.md#references)). Its emitted
  semantics were read from its source for #81.
- `CHB61/multi_select_flutter` is an **example** reference. It has not been
  compared.

## Cross-cutting invariants

- [The overlay does not rebuild with its owner](../invariant/overlay-does-not-rebuild-with-owner.md). With `closeOnTap: false`, the menu stays open across the owner's rebuild, and only `rebuild()` repaints the boxes.
- [The Flutter floor is measured, not read](../invariant/flutter-floor-is-measured.md). `flutter_checkbox`'s own floor is read per pinned version (#80).

## Blast radius

- [Menu shell](menu-shell.md) — every shell parameter is passed through.
- [Semantics](semantics.md) — the box's exclusion and the row's `checked`.
- [Single-open](single-open.md) — `closeAll` forwards to the shared registry.
- [Release surfaces](release-surfaces.md) — bumping `flutter_checkbox` in
  `pubspec.yaml` may be a breaking change through the re-export.

## Known holes / open

**None recorded.**
