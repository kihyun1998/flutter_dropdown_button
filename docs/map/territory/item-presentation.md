# Item presentation

## What it is

How the menu rows and the button face are drawn. There is one implementation
per rendering mode: `TextItemPresentation` (for `.text()`),
`CustomItemPresentation` (for `itemBuilder`) and `MultiSelectPresentation` (the
checklist). The shell asks a presentation what to draw (`buildItem`,
`buildSelected`, `contentAlignment`, `defaultSearchFilter`) and never asks which
constructor was used, so a new mode is a new implementation, not a branch at
every render site. The interface is exported from the barrel
(`lib/flutter_dropdown_button.dart`), so a third-party implementation is bound
by its contract (CHANGELOG 3.0.0, "FEAT: Added `DropdownItemPresentation<T>`").

## Governing decisions

- [ADR 0001, rule 2](../../adr/0001-accessibility-semantics-are-attached-by-hand.md#the-rules).
  The word for a chosen row belongs to the presentation: `selected` for single
  select, `checked` for multi-select. It is announced in `buildItem`, not in the
  shell's row wrapper. The code follows it: `TextItemPresentation.buildItem` and
  `CustomItemPresentation.buildItem` wrap in `Semantics(selected:)`, and
  `MultiSelectPresentation.buildItem` wraps in `Semantics(checked:)`.

Which presentation a widget uses is not recorded anywhere. It is read from the
source: see `## Design model`.

## Design model

From the source and the interface dartdoc unless a source is given.

- **Built fresh on every build, holding plain values only.** No `State` and no
  `BuildContext`. The widget reads what it needs from the element tree and hands
  it over (the `DropdownItemPresentation` dartdoc). Caching it per build scope
  was rejected, because this repo's most expensive bugs were all stale caches
  ([lessons, #50](../../agents/lessons.md)).
- **Each widget picks its presentation in one place.** For
  `FlutterDropdownButton` that place is `_FlutterDropdownButtonState._presentation`:
  `itemBuilder` present means custom, otherwise text.
  `FlutterMultiSelectDropdown.build` always builds `MultiSelectPresentation`.
- **Only a presentation that knows what an item says supplies
  `defaultSearchFilter`.** `TextItemPresentation` and `MultiSelectPresentation`
  both return a case-insensitive `contains` over `labelOf`.
  `CustomItemPresentation` returns null, because it cannot match an arbitrary
  widget against a query. The shell uses this only when the caller gives no
  `searchFilter` (`_DropdownMenuShellState._visibleItems`).
- **`labelOf` has a release-mode throw that debug never reaches.** The
  presentation constructor's assert covers debug, and the throw covers release
  builds, where asserts are compiled out. Both text-rendering presentations have
  it, marked `coverage:ignore`.
- **Every text run goes through one `_text` helper per presentation.** The
  helper forwards a null style unchanged. It exists because two builders each
  passing the same `TextDropdownConfig` values is how `semanticsLabel` reached
  the rows and not the button (CHANGELOG 3.0.0, REFACTOR; #37).
- **The button face is drawn from `value`, not from `items`.**
  `TextItemPresentation.buildSelected` and `CustomItemPresentation.buildSelected`
  never look `value` up in `items`. That is what lets the single-select ghost
  value draw. `MultiSelectPresentation.buildSelected` hands the whole `selected`
  set to `labelBuilder` in the same way.
- **Input bound:** a presentation is built once per build and holds no
  collection of its own. Row count is the shell's concern.

## Code

- `lib/src/presentation/item_presentation.dart` — `DropdownItemPresentation`, `DropdownSearchFilter`, `TextItemPresentation`, `TextItemPresentation.labelOf`, `TextItemPresentation._text`, `TextItemPresentation.buildItem`, `TextItemPresentation.buildSelected`, `TextItemPresentation._withLeading`, `CustomItemPresentation`, `CustomItemPresentation.buildItem`, `CustomItemPresentation.buildSelected`, `MultiSelectPresentation`, `MultiSelectPresentation.buildItem`, `MultiSelectPresentation.buildSelected`, `_alignmentOf`
- `lib/src/flutter_dropdown_button.dart` — `_FlutterDropdownButtonState._presentation`
- `lib/src/flutter_multi_select_dropdown.dart` — `FlutterMultiSelectDropdown.build`
- `lib/src/shell/dropdown_menu_shell.dart` — `_DropdownMenuShellState._visibleItems`, `_DropdownMenuShellState._buildButtonContent`, `_DropdownMenuShellState._buildOverlayContent` (the call sites)

Tests: `test/presentation/item_presentation_test.dart`, `test/presentation/multi_select_presentation_test.dart`, `test/text_label_test.dart`, `test/semantics_label_test.dart`, `test/ghost_value_test.dart`.

## Reference behaviour

**None.** The peers named in [the references table](../../agents/thegraph.md#references)
(dropdown_button2, custom-dropdown) have not been compared on how they split
custom rendering from text rendering.

## Cross-cutting invariants

- [No cached derived state](../invariant/no-cached-derived-state.md). The
  presentation is rebuilt on every build and never cached.

## Blast radius

- [Semantics](semantics.md) — the shell cannot announce a chosen row, so a
  presentation that leaves out its `selected`/`checked` leaves the row silent.
  A new implementation must supply one.
- [Text items](text-items.md) — both text presentations copy the same
  `TextDropdownConfig` pass-throughs into their own `_text`. Changing one copy
  and not the other makes the two widgets render the same config differently.
- [Tooltip](tooltip.md) — every text run is a `SmartTooltipText`, so a change to
  what `_text` passes changes when the tooltip appears and what it measures.
- [Search](search.md) — `defaultSearchFilter` is the fallback filter. A
  presentation that returns null makes `searchable` filter nothing unless the
  caller supplies a filter.
- [Single-select](single-select.md) — the ghost value relies on `buildSelected`
  drawing `value` without checking it against `items`. A lookup added there
  would bring back the hint in its place.
- [Multi-select](multi-select.md) — `MultiSelectPresentation` is that widget's
  only rendering, so the checklist row's layout and its box exclusion live here.
- [Release surfaces](release-surfaces.md) — `documentation/api_reference.md`
  states the interface contract, rule 2 included, for third-party
  implementations.

## Known holes / open

- A caller who declares `selected` inside `itemBuilder` collides with the row's
  own `selected` and splits the node in two. This is documented on
  `CustomItemPresentation.buildItem`, not governed
  ([ADR 0001 non-scope](../../adr/0001-accessibility-semantics-are-attached-by-hand.md#what-this-record-does-not-cover)).
- `TextItemPresentation` and `MultiSelectPresentation` repeat the same
  `labelOf`, `_text`, `defaultSearchFilter` and disabled-style merge. Nothing
  shares them, so the #37 failure mode (one copy drifts) can come back between
  the two classes.
- The comment on `_DropdownMenuShellState._visibleItems` says "text mode is the
  only one that can" supply a default filter. `MultiSelectPresentation` supplies
  one too. The comment is stale; the behaviour is fine.
