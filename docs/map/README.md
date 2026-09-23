# Map — flutter_dropdown_button

<!-- grill-map build stamp: 1831304 -->

A dependency graph over what this package *does*. It answers two questions that
no ADR, issue or CHANGELOG entry is indexed by:

1. **If I touch this, what else moves?** Open the territory you are about to
   change and treat its `## Blast radius` as a checklist. Then open every note
   under its `## Cross-cutting invariants` and read `## Where it will recur`.
2. **What is this code derived from?** Read `## Governing decisions` (the ADR),
   then `## Reference behaviour` (the outside source). `**None.**` under
   either is the answer, not a gap in the note.

## Reading protocol

- **Read before the design is fixed, write after the change.** Before writing
  code, open the territory note(s) for what the change touches. Once it is done,
  update `## Code` and `## Blast radius` if they moved.
- **Promotion test, asked at the first fix:** *does the fact this fix revealed
  hold at another site that shares the same assumption?* Examples are the same
  Flutter slot semantics, the same overlay subtree, or the same chrome term. If
  yes, the fix lands with an invariant note, not after the third rediscovery.
- An invariant a territory omits is invisible at the moment it is needed, so
  every invariant ↔ territory edge is kept in both directions.

## Why this layer exists

Six facts in this repo were each discovered three or four times at different
sites before anyone wrote them down once. Every invariant note's
`## Discovery history` carries the citations. The worst was chrome height: it
broke in 2.3.2 and again in 2.5.0, and was refactored onto one getter in 3.0.0.
A lens then found it being re-added by hand, and #96 hit it from the
empty-state side. No ADR could have held it, because nobody ever *decided* it.

## Measured at build time

- **M1:** the barrel exports 34 public types. Two areas have a governing
  record: semantics ([ADR 0001](../adr/0001-accessibility-semantics-are-attached-by-hand.md))
  and the dismiss barrier ([ADR 0002](../adr/0002-the-dismiss-barrier-stays-its-arena-participation-is-conditional.md)).
  Placement, overlay lifetime, single-open, theme resolution, search, tooltip,
  scroll chrome and multi-select are governed by none. Their rules live in
  CLAUDE.md, source comments, and closed issues.
- **M2:** "overlay" is *mentioned* in both ADRs and is the *subject* of neither.
- **M3:** `dropdown_menu_shell.dart` is 16% of `lib/`, and this map splits it
  across five territories. `dropdown_overlay_controller.dart` holds two
  registries with different lifetimes, and they get separate treatment.
- **M4/M5:** no forward-looking promise in `lib/`, `documentation/` or the ADRs
  points at an open issue, and there were zero open issues. Every open item in
  this map is either an ADR's named conformance gap or an observation recorded
  under `## Known holes / open`.

## Conventions

- Territories overlap on purpose. One file can sit under several territories
  (the shell does), and one territory can span several files.
- `## Code` names symbols, never line numbers. Tests are listed by file.
- Empty sections stay. `**None.**` is the sentinel, and the query must name its
  heading (below).
- A list that a tool can derive is given as the command. A list no tool can see
  (the semantics site table) is labelled as hand-written.
- Plain relative links only, so the map works on GitHub and as an Obsidian vault.
- The map never edits an ADR, spec or source file. A conflict it finds is
  recorded under `## Known holes / open` and raised with a person.

## Queries

```sh
# territories with no governing record / never compared to a reference
rg -lU '## Governing decisions\r?\n\r?\n\*\*None\.\*\*' docs/map/territory/
rg -lU '## Reference behaviour\r?\n\r?\n\*\*None\.\*\*'  docs/map/territory/
# what exists — the folders are the roster
ls docs/map/territory/ docs/map/invariant/
```

## What the map cannot answer

- **Issues and source files are not nodes.** They appear only as text inside
  notes, so the graph view shows no edge to #95, even though it shaped three
  territories.
- **Consumers are not in the map.** A change's reach into downstream apps is
  derived per change, per [CLAUDE.md](../../CLAUDE.md#working-discipline--thegraph).
- **Blast edges are judgement, not a call graph.** The first real change is the
  test: before starting, write down from the map alone which territories you
  expect to touch, and compare afterwards. A miss is a missing edge.

## Coverage

**Complete for `lib/`, `example/` and the release surfaces as of the build
stamp.** Every file under `lib/src/` appears under some territory's `## Code`.
A missing note therefore means a new area. **A territory is owed** when a
change adds a public type that no existing territory's `## Code` names. **An
invariant is owed** when the promotion test above says yes.

## Nodes

Territories: [placement](territory/placement.md) ·
[overlay lifetime](territory/overlay-lifetime.md) ·
[single-open](territory/single-open.md) · [dismissal](territory/dismissal.md) ·
[menu shell](territory/menu-shell.md) · [trigger button](territory/trigger-button.md) ·
[item presentation](territory/item-presentation.md) · [semantics](territory/semantics.md) ·
[theme resolution](territory/theme-resolution.md) · [search](territory/search.md) ·
[text items](territory/text-items.md) · [tooltip](territory/tooltip.md) ·
[scroll chrome](territory/scroll-chrome.md) · [multi-select](territory/multi-select.md) ·
[release surfaces](territory/release-surfaces.md) · [example gallery](territory/example-gallery.md)

Invariants: [chrome height has one source](invariant/chrome-height-one-source.md) ·
[no cached derived state](invariant/no-cached-derived-state.md) ·
[the overlay does not rebuild with its owner](invariant/overlay-does-not-rebuild-with-owner.md) ·
[the entry outlives the open menu](invariant/entry-outlives-the-open-menu.md) ·
[a resolved style is complete or null](invariant/resolved-style-complete-or-null.md) ·
[the Flutter floor is measured, not read](invariant/flutter-floor-is-measured.md)
