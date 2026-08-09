# 0001 — Accessibility semantics are attached by hand, and the word for a state is the presentation's

**Status:** Accepted — 2026-08-09. Promoted out of the adversarial completeness
pass on [#88](https://github.com/kihyun1998/flutter_dropdown_button/issues/88).
This is the first decision record in this repository; `docs/adr/` did not exist
before it.

## Why a record rather than another issue

Four issues have now been filed against the same mechanism — #37, #64, #81, #88
— and each was found the way the last one was: someone opened a semantics tree
and looked. An issue holds one decision. It cannot hold a rule that spans
decisions, which is why the fifth of these would have been decided from scratch
too.

Two of theflow's promotion triggers fired in #88's pass, which is the bar:

- **The reference cannot arbitrate — it contradicts itself across its own call
  sites.** `material/dropdown.dart:246` wraps a dropdown row in
  `Semantics(role: SemanticsRole.menuItem)` and never emits `selected` at all;
  `material/list_tile.dart:997` emits `Semantics(selected: selected)` for the
  same kind of row. Asking "what does Material do for a selected row" has two
  answers.
- **Two artifacts inside this repo required opposite things.**
  `test/presentation/multi_select_presentation_test.dart` reasoned its way to
  `containsSemantics` because an exhaustive matcher breaks when an `InkWell`
  gains a flag; `test/semantics_role_state_test.dart` reasoned its way to
  `matchesSemantics` for the opposite reason, on the same surface, and was
  measurably wrong — see rule 4. Neither file knew the other had decided.

## The root

**This package builds its interactive surfaces itself, and they announce
nothing.** `material/ink_well.dart:1401` declares only `onTap` and
`onLongPress`: an `InkWell` contributes a tap action and — through its `Focus` —
focusability, and no role, no enabled state, no relation. A bare
`GestureDetector` contributes less still. That is a direct consequence of
[the overlay-rendering identity](../../CLAUDE.md): a package that used Flutter's
menu machinery would inherit its semantics, and this one does not use it.

So nothing arrives for free, and **nothing reports the absence.** A missing flag
compiles, analyzes clean, renders correctly, passes `find.text`, and holds a 100%
coverage floor. Measured on 4.1.0: the trigger of a *disabled* dropdown emitted
`flags=[] actions=[]` — a screen reader could not distinguish it from decoration
— while every gate in this repo was green.

## The rules

1. **An interactive surface declares its role and its enabled state.** Absence
   is not a default; it is a defect. This covers widget-level identity
   (`button`, `textField`), not structural relations — see the exclusions.
2. **A stateful surface declares its state, and the word is the presentation's
   — one per cardinality.** A single-select row is `selected`; a checklist row
   is `checked`. The shell must not choose between them: it knows what
   `isChosen` answered, never what it *means*. This is "cardinality is a type,
   not a flag" reaching the semantics tree, and it is why the announcement lives
   in `DropdownItemPresentation.buildItem` and not in the shell's row wrapper.
3. **A semantics node is complete or it is absent** — the same rule the themes
   hold for resolved styles. Half a node is worse than none: a role with no
   enabled state reads as a control that cannot be broken, and a state with no
   role reads as decoration.
4. **Assertions are made at the semantics tree, and assert *this package's*
   contract — not Flutter's contributions to the node.** Every claim in this
   record was found by dumping the tree and none of them by reading the render
   tree. Exhaustive matchers are forbidden here: they pin the host platform,
   because `widgets/focus_scope.dart:723` emits the focus action only off-iOS,
   so a node matched flag-for-flag on the test host goes red under
   `TargetPlatform.iOS`. Partial matching, with the negative assertions carrying
   the weight — an unchosen row states `selected: false` rather than staying
   silent.
5. **Both anchor paths carry the same contract.** `anchorBuilder` changes what
   the anchor *looks like*, not what it *is*. A caller who draws their own
   anchor is not asking for a different control.

## What these derive

The rules were written to reproduce decisions already taken, not to list them.
Each of these was decided separately and falls out of the rules above:

| Already decided | Now derived from |
|---|---|
| #37 — `semanticsLabel` describes the control, so it goes on the control, and the merged string is the contract | rule 4 (the tree is the seam; the render tree passed while the announcement was wrong) |
| #64 / #81 — the checklist box is excluded and `checked` is re-attached to the row | rules 2 and 3 (one complete node per interactive surface, in the checklist's vocabulary) |
| #88 — the trigger announces `button`/`enabled`, the single-select row announces `selected` | rules 1, 2, 3 |
| #88 — the reported direction was backwards: the *bare* path already announced the role | rule 5 |

## What these contradict

Adjudicated, not quietly flipped. Each is a conformance gap under this record
and is filed as such rather than fixed inside the change that found it:

- **Rule 5 vs. the bare anchor's focusability.** The bare path is a plain
  `GestureDetector`: measured `actions=[tap]` with no `isFocusable` and no focus
  action, where the chromed path has both from its `InkWell`. It is also not
  keyboard-operable, while `documentation/api_reference.md:60`,
  `documentation/use_cases.md:525` and `CHANGELOG.md:34` all advertise "keyboard
  navigation".
- **Rules 1 and 3 vs. the dismiss barrier.** Measured with a query matching
  nothing: one node, `Rect(0, 0, 800, 600)` on an 800×600 screen,
  `label="No results found" actions=[tap]`. The overlay's barrier declares a tap
  and no role, and the empty state merges into it, so the whole screen becomes a
  single target named after the empty state whose activation dismisses the menu.
- **Rule 3 vs. the trigger's open state.** Neither anchor path announces
  expanded or collapsed, so a node that now correctly says "button, enabled" is
  still not a complete description of a control whose whole job is to toggle.

## What this record does not cover

Named so the next pass does not read them as decided:

- **Structural roles** (`SemanticsRole.menu`, `SemanticsRole.menuItem`). Rule 1
  is deliberately about widget-level identity. Adopting Flutter's menu
  *vocabulary* while deliberately not using its menu *machinery* is a design
  question this record does not settle — and neither `matchesSemantics` nor
  `containsSemantics` has a `role` parameter at the 3.32 floor or at 3.44, so it
  would be a rule with no way to assert it.
- **Keyboard operation** — arrow keys, Escape, type-ahead. This record governs
  what is *declared*, not the interaction model. `lib/` currently contains no
  `Shortcuts`, `Actions`, `LogicalKeyboardKey` or `FocusTraversal` at all.
- **Announcement timing** — live regions, whether opening the menu moves
  accessibility focus, whether anything is spoken on open.
- **Anything a caller's own `Semantics` does.** Rule 2 puts a `selected` on the
  row; a caller who declares `selected` inside `itemBuilder` collides with it
  and splits the row in two (measured: the row keeps the state and the action,
  the caller's node keeps the label). Documented on `buildItem`, not governed
  here.

## Consequences

- `documentation/api_reference.md`'s `DropdownItemPresentation` table now states
  rule 2 as part of the interface contract, because the interface is exported
  and a third-party implementation is bound by it.
- The three contradictions above are filed as conformance items under this
  record.
- A future presentation — a third cardinality, a grouped menu — inherits rules
  1-5 by construction instead of rediscovering them with a semantics dump.
