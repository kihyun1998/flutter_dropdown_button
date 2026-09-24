# No cached derived state

## The fact

Anything computable from the widget's current inputs is computed on read, not
stored in a field. That covers the visible (filtered) items, the item
presentation, and the resolved styles. State is kept only for what the inputs
cannot reproduce: the query, the open entry, the scroll controller, and whether
this open has scrolled to the chosen row yet (#157). The last is an event, like
the query, and no input can say whether it has happened.

## Why it is cross-cutting

A cache in any of these places would need invalidating from several unrelated
events: `didUpdateWidget`, a keystroke, open, close, select. Those events live
in different methods and do not call one another. The rule holds in each
territory for the same reason, but each one discovered it separately.

## Territories it holds in

- [Search](../territory/search.md) —
  `DropdownSearchController.visibleItems` derives on each call.
- [Menu shell](../territory/menu-shell.md) — `_visibleItems()` asks the
  controller on each build. There is no `_filteredItems`.
- [Item presentation](../territory/item-presentation.md) — the presentation
  is rebuilt per build, and caching it was rejected (#50).

## What a violation looks like

A menu that shows yesterday's list: items that arrived asynchronously do not
appear, a query is cleared by an unrelated ancestor rebuild, or a filter
survives a new item list. It usually shows only when the caller passes a
*derived* list (`source.map(...).toList()`), whose identity changes on every
build.

## Discovery history

1. **2.3.2**: the query was cleared whenever an ancestor rebuilt, because
   `didUpdateWidget` compared `items` by identity.
2. **2.4.0**: `_filteredItems` was removed. It had four hand-written
   invalidation sites and was wrong at three
   ([lessons, Step 1](../../agents/lessons.md#step-1--이슈-먼저-근거기각-대안부정-결과), #50).
3. **#2**: an issue claimed mutating the list in place goes stale. A
   characterization test showed it did not, because `openDropdown` re-derives.
   The rule held somewhere nobody had checked.
4. **#50**: caching `_presentation` per build was proposed and rejected on this
   ground. The rejection is recorded so that it is not proposed a second time.

## Where it will recur

A new field on a `State` whose value is a function of `widget.*` plus other
state is subject to this. Ask whether a rebuild with the same inputs gives the
same value. If yes, it is derived. Derive it, and if it is expensive, measure
before caching (#50 measured `resolveButton()` 2·4·2 → 1·1·0 without a cache).
