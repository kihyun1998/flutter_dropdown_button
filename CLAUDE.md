# CLAUDE.md

## Working discipline — thegraph

Substantive changes (bug fix / feature / behavior change) follow the **`thegraph`**
skill — run `/thegraph` at the start. This repo's references (which outside sources
it is read against, and whether each binds) live in **`docs/agents/thegraph.md`**;
the per-incident evidence in **`docs/agents/lessons.md`**. Read both before starting; add new war-stories to
lessons.

This is a **published package with consumers**, so downstream verification and
post-release migration both apply (derive the consumer list on the spot — do not
store it here).

**Branch → PR (`Closes #issue`) → CI green → merge. Never commit to `main`.**
`ci.yml` defines the gates, not this policy, so it is stated here or nowhere.
The release rides in the change's own commit, not a separate `chore:`
one. Before a release, run `pub-ready`.

## Identity & invariants (the boundary)

`flutter_dropdown_button` renders a dropdown through an `OverlayEntry`, not
Flutter's built-in menu machinery. There are **two** widgets, both thin callers
of `DropdownMenuShell`:

- `FlutterDropdownButton<T>` — custom (`itemBuilder`) or `.text()` (items through
  `SmartTooltipText`, gaining overflow handling, a tooltip, a default filter).
- `FlutterMultiSelectDropdown<T>` — a checklist `StatelessWidget`; the shell holds
  the state and `selected` belongs to the caller.

- **The shell does not know what selection is.** It takes `isChosen(T)`,
  `onItemTap(T)`, `closeOnTap` — what a caller supplies for those is what makes a
  dropdown single- or multi-select.
- **Cardinality is a type, not a flag.** `value` / `scrollToSelectedItem` /
  `disableWhenSingleItem` do not exist on the multi-select widget, so no assert
  forbids them. The rejected `.multiSelect` named constructor would have put
  settable-but-dead fields on the API — the exact shape 3.0.0 spent a major
  version deleting.
- **The recurring pattern:** every module separates *reading from the element
  tree* (needs a `BuildContext`) from *deciding with what was read* (pure). The
  second half is where the bugs are, and the half worth testing. Keep the split.
- **A resolved style is complete, or it is null.** Where a Flutter slot
  *replaces* the ambient theme rather than merging, fill every slot the ambient
  default would, or hand Flutter nothing. Never a half-built value. The slots
  that replace are listed in `docs/map/invariant/resolved-style-complete-or-null.md`.
- **Auditing the API:** start with the dead-field detector in
  `docs/map/territory/theme-resolution.md`.
- **Mechanism is core; policy crosses the seam.** Core: geometry (`placement`),
  theme resolution, overlay lifetime + single-open, search-query derivation,
  presentation — each takes plain values and no `BuildContext`. The consumer owns
  selection semantics (`isChosen`/`onItemTap`/`closeOnTap`), `itemBuilder`, theme
  values.
- **Contract ≠ defect.** A consumer report may be against behavior the core
  deliberately holds. Fix the surface that is actually wrong, even when that is
  only a dartdoc.
- **A leaked `OverlayEntry` is the consumer's whole app, not this widget.** It
  stays as a dead layer swallowing taps, and once the widget is gone there is
  nothing left to recover it with — which is why overlay lifetime and the
  single-open registry get the completeness pass regardless of how cheap the
  change looks.
- **Every package the barrel re-exports is part of this package's API**
  (`grep '^export .package:' lib/flutter_dropdown_button.dart`). At `0.x` an
  upstream breaking change is a **breaking change here** — and its `environment`
  floor and emitted semantics are read at the exact version pinned, never carried
  across versions.

## Agent skills

**Issue tracker.** Before reading or filing an issue, read
`docs/agents/issue-tracker.md`.

**Triage labels.** Before applying a label, read `docs/agents/triage-labels.md`.

**Domain docs.** Before touching semantics emission or the dismiss barrier, read
the matching record in `docs/adr/` and file the work as a conformance item under
it, not as a fresh decision. The reading rules are in `docs/agents/domain.md`.

**Map.** `docs/map/README.md` is the territory map: one note per area of what
the package does, one per cross-cutting invariant. Open the territory note
before the design is fixed; update its `## Code` and `## Blast radius` after the
change. At the first fix, ask *does this hold at every site that shares the same
assumption?* — if yes, the fix lands with an invariant note.

**Comments.** A comment says what the code is. Why it is this way, what it
deliberately leaves out, the trap and the measured value go to the territory
note under `docs/map/`. Where none seems to hold it, search the folder and the
code symbol first; only then start a new note, named for what the system does
there, not for the file. History goes to the commit message. Comments written
before this rule still carry the rest: never delete one whose content the map
does not yet hold — move it there first.
