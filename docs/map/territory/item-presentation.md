# Item presentation

## What it is

How rows and the button face are drawn, one implementation per rendering mode:
`TextItemPresentation` (for `.text()`), `CustomItemPresentation` (for
`itemBuilder`) and `MultiSelectPresentation` (the checklist). The widget asks a
presentation what to draw instead of asking which constructor was used, so a new
mode is a new implementation, not a branch at every render site. The interface
is exported, and a third-party implementation is bound by its contract.

## Governing decisions

- [ADR 0001, rule 2](../../adr/0001-accessibility-semantics-are-attached-by-hand.md#the-rules).
  The word for a chosen row belongs to the presentation: `selected` for single
  select, `checked` for multi-select. It is announced in `buildItem`.

## Design model

- **Built fresh on every build, holding plain values only.** No `State` and no
  `BuildContext`. Caching it was rejected (#50), because every expensive bug in
  this repo was a stale cache.
- **Only text mode can supply `defaultSearchFilter`.** A custom mode cannot know
  what an arbitrary widget "says", so it returns null and nothing is filtered.
- **`labelOf` has a release-mode throw that is unreachable in debug.** The
  assert covers debug and the throw covers release, and it is excluded from
  coverage on purpose.
- **Every text run goes through one `_text` helper** per presentation, because
  writing the pass-throughs twice is how `semanticsLabel` reached the rows and
  not the button (#37).
- **The mode is decided in exactly one place:** the single-select widget's
  `_presentation` getter.

## Code

- `lib/src/presentation/item_presentation.dart` — `DropdownItemPresentation`, `DropdownSearchFilter`, `TextItemPresentation`, `TextItemPresentation.labelOf`, `TextItemPresentation._text`, `TextItemPresentation.buildItem`, `TextItemPresentation.buildSelected`, `CustomItemPresentation`, `CustomItemPresentation.buildItem`, `MultiSelectPresentation`, `MultiSelectPresentation.buildItem`, `MultiSelectPresentation.buildSelected`
- `lib/src/flutter_dropdown_button.dart` — `_FlutterDropdownButtonState._presentation`

Tests: `test/presentation/`, `test/text_label_test.dart`, `test/semantics_label_test.dart`.

## Reference behaviour

**None.** The peers named in [the references table](../../agents/thegraph.md#references)
(dropdown_button2, custom-dropdown) have not been compared on how they split
custom from text rendering.

## Cross-cutting invariants

- [No cached derived state](../invariant/no-cached-derived-state.md). The
  presentation is rebuilt, never cached.

## Blast radius

- [Semantics](semantics.md) — each implementation owns its row's state
  announcement. A new implementation must supply one.
- [Text items](text-items.md) and [tooltip](tooltip.md) — both text
  presentations draw through `SmartTooltipText`.
- [Search](search.md) — `defaultSearchFilter` is the fallback filter.
- [Multi-select](multi-select.md) — `MultiSelectPresentation` is that widget's
  only rendering.
- [Release surfaces](release-surfaces.md) — `documentation/api_reference.md`
  states the interface contract, including rule 2.

## Known holes / open

- A caller who declares `selected` inside `itemBuilder` collides with the row's
  own `selected` and splits the node in two. This is documented on `buildItem`,
  not governed ([ADR 0001 non-scope](../../adr/0001-accessibility-semantics-are-attached-by-hand.md#what-this-record-does-not-cover)).
