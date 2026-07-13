# CLAUDE.md

## Working discipline — theflow

Substantive changes (bug fix / feature / behavior change) follow the **`theflow`**
skill — run `/theflow` at the start. This repo's bindings (module map, reference
routing, boundary rule, proof methods, behavior-describing surfaces, gate matrix,
consumers) live in **`docs/agents/theflow.md`**; the per-incident evidence
(#2, #9, #32, #37, #38, #40, #45, #47, #50, #51, #59 …) in
**`docs/agents/lessons.md`**. Read both before starting; add new war-stories to
lessons.

This is a **published package with consumers**, so theflow's downstream
verification and post-release migration both apply (derive the consumer list on
the spot at Step 10 — do not store it here).

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
- **A resolved style is complete, or it is null.** Several Flutter slots
  *replace* the ambient theme rather than merge (`Tooltip.decoration`,
  `ScrollbarTheme`, `Text.semanticsLabel`, `Scrollbar.thickness`) — fill every
  slot the ambient default would, or hand Flutter nothing. Never a half-built value.
- **Dead-field detector:** a documented, settable field that `resolve()` never
  mentions is read by nothing. Making the themes resolve themselves turned the
  architecture into the detector — check that first when auditing the API.

## Agent skills

**Issue tracker.** GitHub issues in `kihyun1998/flutter_dropdown_button`, via the
`gh` CLI. Pull requests are not a triage surface. See `docs/agents/issue-tracker.md`.

**Triage labels.** `needs-triage`, `needs-info`, `ready-for-agent`,
`ready-for-human`, `wontfix`. Create a label with `gh label create` the first
time it is used. See `docs/agents/triage-labels.md`.

**Domain docs.** Single-context. `CONTEXT.md` and `docs/adr/` do not exist yet
and their absence is expected — they are created lazily, when a term or a
decision actually needs resolving. See `docs/agents/domain.md`.
