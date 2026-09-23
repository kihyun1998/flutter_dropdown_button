# Chrome height has one source

## The fact

The height the menu grows by for non-item furniture (search field with margin
and divider, overlay border, overlay padding) and the height the content area
subtracts for it are **the same getter**: `DropdownOverlaySpec.totalChromeHeight`,
asked of the same spec. Whatever a chrome piece reserves, it must also be
*drawn* at exactly that height. The divider is constrained to `dividerHeight`
for this reason.

## Why it is cross-cutting

Three places touch the number, and none of them calls another to agree on it.
The resolved search-field style *produces* one term, placement *adds* the total,
and the shell *subtracts* it. They share an assumption about what counts as
chrome, not a call path. So no territory-to-territory edge could carry it: each
site is locally correct against its own idea of the sum.

## Territories it holds in

- [Placement](../territory/placement.md) — `DropdownPlacement.resolve` adds
  `chromeHeight` on top of the capped item height.
- [Menu shell](../territory/menu-shell.md) — `_buildOverlayContent` computes
  `availableContentHeight` from `_buildSpec().totalChromeHeight`.
- [Theme resolution](../territory/theme-resolution.md) —
  `ResolvedSearchFieldStyle.totalHeight` and `ResolvedOverlayStyle.borderThickness`
  are the terms.
- [Search](../territory/search.md) — the field and its divider are the tallest
  term, and the divider is drawn at the height reserved for it.

## What a violation looks like

`A RenderFlex overflowed by N pixels on the bottom` inside the menu. The other
form is the opposite: a short list that scrolls for no visible reason. It shows
only when chrome is non-zero, which means search on, a thick border or divider,
or overlay padding. A default-themed, non-searchable menu cannot show it, which
is why it passed twice.

## Discovery history

1. **2.3.2**: `searchable: true` subtracted the field from the item area instead
   of adding it to the overlay, so a 3-item menu scrolled.
2. **2.5.0**: a hardcoded `1.0` divider reservation against Flutter's 16px
   `Divider()` overflowed by 15px.
3. **3.0.0** refactor: the content area moved onto `totalChromeHeight`, because
   "the grow and the shrink … disagreed in 2.3.2 and again in 2.5.0"
   (CHANGELOG), and a lens found the widget re-adding it by hand
   ([lessons, Step 5](../../agents/lessons.md#step-5--적대적-검증-서로-다른-렌즈)).
4. **#96**: an empty menu opened chrome-only (200×2), because the item term was
   zero. That fix went down into placement (`emptyStateHeight`).

Four occurrences.

## Where it will recur

Any new furniture in the overlay (a header, a footer, a "select all" row, a
status line) is subject to this. Check: does it add a term to
`totalChromeHeight`, and is it drawn at exactly that term? A new chrome widget
whose natural height is not pinned is a new instance of the 2.5.0 bug.
