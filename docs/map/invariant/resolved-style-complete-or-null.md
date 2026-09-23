# A resolved style is complete or null

## The fact

Several Flutter slots **replace** the ambient default instead of merging with
it: `Tooltip.decoration`, a `ScrollbarTheme` inserted over the ambient one,
`Scrollbar.thickness`, and `Text.semanticsLabel` (which replaces what is read).
Anything this package hands to such a slot either fills every part the ambient
default would have filled, or is `null` so that Flutter keeps control. A half-built
value is never passed. [ADR 0001, rule 3](../../adr/0001-accessibility-semantics-are-attached-by-hand.md#the-rules)
states the same rule for semantics nodes. The rule itself is stated in
[CLAUDE.md](../../../CLAUDE.md#identity--invariants-the-boundary).

## Why it is cross-cutting

The slots belong to unrelated Flutter widgets, and the package reaches them from
unrelated themes. What they share is a property of the *consumer* (replace, not
merge), which no call graph shows. Each theme looks locally reasonable when it
passes through "just the field the caller set".

## Territories it holds in

- [Theme resolution](../territory/theme-resolution.md) — every `resolve()` is
  where the rule is satisfied or broken.
- [Tooltip](../territory/tooltip.md) — `_resolveDecoration` returns null, or a
  box with the default background and radius filled in.
- [Scroll chrome](../territory/scroll-chrome.md) — `ScrollbarTheme` is inserted
  only when one of its slots is set. Thickness is named as the value Flutter
  would have used.
- [Text items](../territory/text-items.md) — `semanticsLabel` replaces the
  read-out, so it describes the whole control.
- [Semantics](../territory/semantics.md) — rule 3: a node with a role and no
  enabled state reads as unbreakable.

## What a violation looks like

The caller sets one property and loses several others: a transparent tooltip,
a square-cornered tooltip, an app-wide scrollbar theme that stops applying, a
scrollbar twice as thick on Android, or a screen reader that reads the label and
not the item. It shows only for a caller who sets *some* slots of a group; both
the all-default path and the fully-specified path look fine.

## Discovery history

1. **#32** (2.5.0): `DropdownTooltipTheme(borderRadius: …)` alone produced a
   transparent tooltip.
2. **#37**: `semanticsLabel` reached the rows but not the button, and the probe
   showed `Text.semanticsLabel` replaces the read string.
3. **#59**: `trackColor` without `trackVisibility`. This is the *contract* side
   of the same rule, and the fix was the dartdoc.
4. **Scrollbar thickness**: a flat `8.0` would have doubled the bar on Android,
   so the resting value is read from the ambient theme first.

Four occurrences.

## Where it will recur

Any new theme field that feeds a Flutter parameter is subject to this. Before
wiring it, read that parameter's source and ask: does non-null replace the
ambient default, or merge with it? If it replaces, the resolved value must be
complete or null, and a test must set exactly *one* slot of the group.
