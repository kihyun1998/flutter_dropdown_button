# The text presentations render a config alike

## The fact

`TextItemPresentation` and `MultiSelectPresentation` turn the same
`TextDropdownConfig` into text the same way, and each holds its own copy of how:

| Concern | `TextItemPresentation` | `MultiSelectPresentation` |
|---|---|---|
| the eight config pass-throughs into `SmartTooltipText` | `_text` | `_text` |
| item → string, with the `String` fallback | `labelOf` | `labelOf` |
| the default search filter (case-folded `contains` on `labelOf`) | `defaultSearchFilter` | `defaultSearchFilter` |
| the disabled style (`textStyle.merge(disabledTextStyle)`) | `buildSelected` | `buildSelected` |
| `config.semanticsLabel` on the face only, by a merging `Semantics(label:)` | `buildSelected` | `buildSelected` |

A `TextDropdownConfig` field wired into one column and not the other is a bug.

## Why it is cross-cutting

The two classes share no code: neither calls the other, and there is no shared
helper (`lib/src/presentation/item_presentation.dart`, read at HEAD). What they
share is a promise to the caller, that one `config` means the same thing on the
single-select `.text()` widget and on the checklist. Each class is locally
complete, so a change to one passes every test of the other.

## Territories it holds in

- [Text items](../territory/text-items.md) — `TextItemPresentation`, the
  single-select column.
- [Multi-select](../territory/multi-select.md) — `MultiSelectPresentation`, the
  checklist column.
- [Item presentation](../territory/item-presentation.md) — the interface both
  implement; `defaultSearchFilter` is the slot where only `CustomItemPresentation`
  differs (null).

## What a violation looks like

A config field that works on one widget and silently does nothing on the other:
a style, a tooltip mode or a label that the `.text()` button honours and the
checklist ignores, or the reverse. It shows only to a caller who uses both
widgets with the same config, which no single widget test does.

## Discovery history

1. **#37**: inside `TextItemPresentation`, the config pass-throughs were written
   out twice, and `semanticsLabel` reached the rows and not the button. `_text`
   was introduced so there is one copy per class; its dartdoc records this.
2. **Map rewrite (2026-10-24)**: the reading found the same drift risk across
   the two classes — the five concerns above are duplicated, not shared. Promoted
   by the maintainer (maintainer, 2026-10-24).

## Where it will recur

Any new `TextDropdownConfig` field, and any change to how text is labelled,
filtered, styled or announced, is subject to this. Check: is it applied in both
presentations, and does a test set it on both widgets? Merging the two copies
into one shared helper would retire this note into a design-model line.
