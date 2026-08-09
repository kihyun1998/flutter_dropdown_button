# theflow bindings (flutter_dropdown_button)

Project-specific data for the `theflow` skill (the working discipline for a
substantive change). The skill holds the portable *method*; this file holds this
package's *bindings* — which reference to read, where the boundary falls, how to
prove behavior, which surfaces to sweep, and which gates to run. The method
defers every concrete value here. Per-incident evidence lives in
[`lessons.md`](lessons.md) (the war-story index).

Identity & invariants live in `CLAUDE.md`. `CONTEXT.md` / `docs/adr/` do not
exist yet — created lazily, when a term or decision actually needs resolving.

## Reasoning bindings (project-wide)

These govern every step, so they sit above them.

**The prior art.** The **Flutter SDK source** (`packages/flutter/lib/src/material/`
and `widgets/`) — read at the version the CI matrix pins, not from memory. Since
4.0.0 there is a second one: **`flutter_checkbox`**, the package's only runtime
dependency, whose `CheckboxShape` / `CheckboxStyle` this package **re-exports from
its own barrel** — so upstream's public types are part of *our* public API, and at
`0.x` an upstream breaking change is our breaking change.

**The tie-breaker — it splits by layer, not by source.**

```
runtime facts   : measurement (CI `minimum` job / a probe) > Flutter source > memory
design shape    : CLAUDE.md identity > (Material has no vote here)
```

- **Runtime facts** — does a slot merge or replace, what semantics does a widget
  emit, which release introduced an API. Flutter's source is the final authority;
  we execute inside that runtime, so there is nothing to tie-break. But
  *measurement outranks reading it*: source-reading gave the wrong SDK floor twice
  and the CI `minimum` job corrected it (#47), and an upstream `environment` floor
  must be opened **at the exact version being pinned** — 0.3.0 and 0.3.1 of
  `flutter_checkbox` declared different floors and reusing one number for the other
  invented a whole slice (#80/#81).
- **Design shape** — what the public surface looks like. Material carries no
  authority here; `CLAUDE.md`'s identity decides.

**Consequence for Step 5.** A lens finding whose entire content is *"Material does
it another way"* on the design layer comes back **`DELIBERATE` with a citation**,
never `CONFIRMED` with a proposal. The list below is what that citation points at.

### Deliberate divergences — arguments that are already over

Ordered by the only thing this list is for: **how likely a lens is to re-propose
reverting it.**

| Divergence | Decided by | Why a lens keeps finding it |
|---|---|---|
| **Cardinality is a type, not a flag** — two widgets (`FlutterDropdownButton` / `FlutterMultiSelectDropdown`), and the `.multiSelect` named constructor was **rejected** (it would put settable-but-dead fields on the API — the exact shape 3.0.0 spent a major deleting) | 3.0.0 · #63 · #65 · `CLAUDE.md` | The divergence has a **visible ongoing cost**: a new parameter must be added to the shell *and* both widgets and nothing enforces it. A lens reads that duplication and writes "Material does this with one flag." |
| **Overlay-based rendering** — no `DropdownButton` / `PopupMenuButton` / `MenuAnchor`; an `OverlayEntry` drawn directly, with our own placement geometry | `CLAUDE.md` (the package's reason to exist) | Any lens reading Material's source will find `MenuAnchor` already doing placement and report the reimplementation. |
| **Checkbox semantics** — `flutter_checkbox` under `ExcludeSemantics`, with `Semantics(checked:)` **re-attached on the row**. Material's `CheckboxListTile` lets the box emit its own node; here that would duplicate the row's and make a screen reader repeat itself per row | #64 · #81 | Already re-defended once (#81). And semantics is an unconditional trigger (Step 5), so this surface gets **two** lenses — double the exposure. |
| **The theme resolves itself** — each theme class returns a complete `Resolved*Style`; `build()` holds no `Theme.of(context)` fallback chain | #5 · #26 · `CLAUDE.md` | Low re-proposal risk (nobody argues *for* inlining). Kept because it is a true divergence and one line; the substance is in the Step 2 boundary rule below, not repeated here. |

A finding that survives **restating it without naming the reference** is a defect
regardless of this table. The table only catches the ones that cannot.

## Crate / module map

Single Flutter package (no workspace). Public surface is the barrel
`lib/flutter_dropdown_button.dart`. One runtime dependency: `flutter_checkbox: ^0.3.1`.

| Module (`lib/src/`) | Role | Public? |
|---|---|---|
| `flutter_dropdown_button.dart` | single-select widget — ~10 lines of selection, the rest delegated | ✅ |
| `flutter_multi_select_dropdown.dart` | multi-select — a `StatelessWidget` over the same shell | ✅ |
| `shell/dropdown_menu_shell.dart` | the button + the menu. **Knows nothing of selection** (`isChosen`/`onItemTap`/`closeOnTap`) | internal |
| `placement/dropdown_placement.dart` | pure geometry — no `BuildContext`/`MediaQuery`/`State` | internal |
| `overlay/dropdown_overlay_controller.dart` | overlay lifetime, animation, single-open registry; takes a *spec callback* | **✅ exported** |
| `presentation/item_presentation.dart` | text / custom / multi-select behind one interface; mode decided once in `_presentation` | ✅ |
| `search/dropdown_search_controller.dart` | the query, its field, its lifetime; `visibleItems()` derives each call | ✅ |
| `theme/` | `dropdown_style_theme` composes **7** sub-themes — `button`/`overlay`/`item` (4.0.0, from the monolithic `DropdownTheme`, #82) beside `scroll`/`tooltip`/`search`/`checkbox` (#81). Each **resolves itself** into a `Resolved*Style` in `resolved_dropdown_style.dart` | ✅ |
| `config/`, `buttons/`, `widgets/` | `text_dropdown_config`, `menu_alignment`, `scroll_gradient_overlay`, `smart_tooltip_text` | mixed |

Adding a parameter means adding it to the shell **and** both widgets — nothing
enforces that (the price of "cardinality is a type, not a flag"; see the
divergence table).

## Step 1 — reference routing table

Read real source with `gh api …/contents/<path> --jq .content | base64 -d`, then
`grep -n` / `sed -n`. Do not trust a summarizing fetch.

| Change type | Real source to read |
|---|---|
| **Flutter widget behavior** (Tooltip, Scrollbar, Text) | Flutter SDK `packages/flutter/lib/src/material/` + `widgets/` — e.g. `scrollbar.dart` (`trackVisibility` returns transparent without `true`), `tooltip.dart` (bg depends on `Brightness`; `constraints` is 3.32+), `Text.semanticsLabel` **replaces** the announced string |
| **Rendering / overlay / placement** | Flutter SDK `rendering/` + `widgets/overlay.dart`; coordinate space is the caller's business (off-screen-in-nested-`Overlay` was a real bug) |
| **Upstream package dependency** (`flutter_checkbox`) | the source **of the exact version pinned** — its `environment` floor and its emitted semantics both differ per version. `FlutterCheckbox(onChanged: null)` emits `enabled: true` where Material's emits `false` (#81); 0.3.0 and 0.3.1 declared different SDK floors (#80). Never carry a number from one version to another |
| **API introduced-in version** | the **CI `minimum` job** is the authority (see Step 7); or `cd /d/flutter && git log -S "<sig>"` + `git tag --contains`. Reading source alone gave the wrong floor twice (#47) |
| **Downstream bug claim** | the reporting consumer's repo directly (a sibling under `../`, derived on the spot) — verify, don't assume; the report may be the dartdoc's fault, not the code's (#59) |
| **Hidden state** | this repo's own read-sites. Removing a field can unpin behavior held incidentally through it — grep every read site first (`trackWidth` fed `hasCustomWidths` fed a non-null `thickness` branch) |

**Concept ≠ mechanism.** A tooltip/scrollbar/a11y feature may be novel at the
concept layer yet its mechanism (announce semantics, decoration merge, thumb
sizing) lives in Flutter's own material source — read both.

## Step 1 — the project's own map

**This project keeps none.** There is no dependency/territory graph, no
`CONTEXT.md`, and no `docs/adr/` — the absence is deliberate (they are created
lazily; see `docs/agents/domain.md`). The nearest substitutes are the module map
above and `CLAUDE.md`'s invariants, and neither carries cross-cutting invariants
promoted out of earlier work, because nothing has been promoted yet (see Step 6).

Recorded so the answer is *"asked and no"* rather than an unfilled section. This
does not oblige anyone to build one.

## Step 2 — boundary rule

The recurring split: **separate reading from the element tree from deciding with
what was read.** Pulling `MediaQuery.size` / `Theme.of(context).dividerColor`
needs a `BuildContext`; computing a menu's height or choosing a themed override
does not. **The second half is where the bugs are, and the half worth testing.**

- **Mechanism / core:** geometry (`placement`, pure), theme resolution (pure
  functions returning complete styles), overlay lifetime + single-open, search
  query derivation, presentation. Each takes plain values, no `BuildContext`.
- **Policy / consumer:** selection semantics (`isChosen`/`onItemTap`/`closeOnTap`
  — the shell does not know what selection is), `itemBuilder`, theme values.

**Replace-don't-merge is a boundary rule here.** Several Flutter slots *replace*
the ambient theme rather than merging (`Tooltip.decoration`, `ScrollbarTheme`,
`Text.semanticsLabel`, `Scrollbar.thickness`). The rule that falls out: **a
resolved style is complete, or it is null** — fill every slot the ambient default
would have, or hand Flutter nothing. And when you pin a value, pin the one it
would have rested at (`Scrollbar` thickness is 8 desktop / **4 Android**).

**Contract ≠ defect.** #59: a consumer set `trackColor`, no track appeared.
Neither Flutter (`material/scrollbar.dart:274` correctly returns transparent
without `trackVisibility: true`) nor our code was wrong — the broken invariant
was **our dartdoc**, teaching the consumer exactly that wrong combination.
Nothing in `lib/` changed but a comment.

**This package publishes, so the cross-repo rules are live** — the SDK-floor
constraint that carries a raised floor down to every consumer, the
two-consumers-one-workaround signal, and the duty to report a local guard
upstream. None of them is N/A here.

## Step 4 — proof method per layer

| Layer | Real proof |
|---|---|
| **pure logic** (placement, theme resolve, overlay controller, search) | unit tests, **no widgets** (107 of the suite mount nothing) |
| **widget behavior** | widget tests at the **public seam** — assert the rendered `BoxDecoration`, the presence of a `ListView`; **never private state** (why the suite survived the controller extraction + theme rewrite with zero edits) |
| **accessibility contract** | assert at the **semantics tree** (`semantics_label_test`) — a render-only test (`find.text`) passes while the announced string is wrong (#37) |
| **coverage** | `flutter test --coverage` + `dart run tool/check_coverage.dart --min 100`. Coverage tells you what you did *not* see, not whether what you saw is right (80% covered with **zero** item-tap tests once) |
| **downstream** | link into a consumer's suite (derive the consumer on the spot at Step 7) |

Harness fake evidence to respect: restore `debugDefaultTargetPlatformOverride`
**in the test body** (`tearDown` is too late); do not reuse one `tester` to reopen
a menu (a second tap *closes* it); do not chain gestures in one `testWidgets`
(a prior scroll wakes the autoscrollbar thumb). `const Fruit('Apple')` is
normalized to one instance — `const` proves nothing about "different instances".

**The tautological proof to watch for: a discriminating-power check that goes
green for the wrong reason after an upstream swap.** Removing `ExcludeSemantics`
left the "the row does not announce disabled" test green — not because the guard
was pointless, but because `flutter_checkbox` emits `enabled: true` where Material
emits `false`, so the test had silently lost its power against the new
implementation (#81). When the widget underneath changes, re-derive what the test
discriminates; do not reuse the old red as evidence.

## Step 5 — unconditional completeness triggers

These two paths run the completeness pass **regardless** of the enumeration-risk
judgement, and they are the only paths where the second, *refuting* lens is worth
its cost.

| Sacred path | Why the judgement is not allowed to skip it |
|---|---|
| **Semantics emission** — `presentation/item_presentation.dart`, plus every `Semantics` / `ExcludeSemantics` / `semanticsLabel` in `shell/` and `widgets/` | **Invisible to every other gate.** `find.text` passes while the announced string is wrong (#37); the screen is correct, coverage is 100, the analyzer is quiet, and only the semantics tree disagrees. A discriminating-power check can go green after an upstream swap without anyone noticing (#81). The currently-open #88 is the same surface again. |
| **Overlay lifetime / single-open registry** — `overlay/dropdown_overlay_controller.dart` | **The blast radius is the consumer's whole app, not this widget.** A leaked `OverlayEntry` stays as a dead layer swallowing taps, and once the widget is gone there is nothing left to recover it with. That is the "costs more than a wrong number" case. |

Everything else — including `theme/*.resolve()` completeness and
`placement/` geometry — is governed by the ordinary enumeration-risk judgement.
Both were considered and deliberately left off: a half-built style or a
mispositioned menu is *visible*, so it is found cheaply. **Record the skip
explicitly** when the judgement says no; a silent skip is itself a gap.

**The brief owes the lens four things, not two:** both corpora (this repo's
siblings + the Flutter/`flutter_checkbox` source), **the tie-breaker row for the
layer the change sits on**, and **the deliberate-divergence table** — both at the
top of this file. Without the last two, every reference-shaped finding arrives
ungraded and the whole grade table's saving is spent back on the main thread. And
require the disposition grade (`CONFIRMED` / `UNADJUDICATED` / `INERT` /
`DELIBERATE`) on every finding.

## Step 6 — behavior-describing surfaces

- **public dartdoc** → ships verbatim as pub.dev API docs. Most likely to still
  teach the old behavior (#38 arrow backwards; #45 class examples using dead fields).
- **`CHANGELOG.md` = the bug inventory** (not the tracker). Entry form
  `* **TYPE**: Description`, TYPE ∈ FEAT/FIX/BREAKING/DEPRECATED/REFACTOR/PERF/
  CHANGE/TEST/MIGRATION. pub.dev snapshots it at publish — open a new version,
  never rewrite a published entry. A bug found while refactoring is fixed in the
  same change but **must** get a `FIX` entry naming the symptom.
- **`README.md` + `documentation/`** (`api_reference`, `theming`,
  `text_configuration`, `migration`, `use_cases`) — update on any public
  signature change; these have drifted to APIs deleted three majors earlier.
- **`example/`** — a separate package; deprecation warnings surface **only here**
  (the analyzer stays quiet in-package). Annotate the field, the constructor
  param, and the `copyWith` param separately — `@Deprecated` does not propagate.
- **`.pubignore`** — `docs/.pubignore` + `tool/.pubignore` only. A **root**
  `.pubignore` disables git-based file listing (`.gitignore` goes dead). The
  pub.dev archive cannot be un-published. Check archive contents with `├──`, not
  `|--` (a grep that returns empty either way is not a check).
- **`environment` floor** (`sdk >=3.8.0`, `flutter >=3.32.0`) — raised when using
  a newer API; the CI `minimum` job is the only thing that catches a lying floor
  (#47). An upstream dependency's floor is read per-version, never carried across
  versions (#80).
- **Reclaim now-false rationale** — a release headnote saying "removed only
  deprecated" / "no behavior change" was falsified by the same PR (#45 / semantics).
- `dart format` follows the package language version — a floor bump can reformat
  the tree.

### Decision records — destination, format, and what exists

- **Destination:** `docs/adr/NNNN-slug.md`, created lazily (`docs/agents/domain.md`).
  A promotion is what creates the directory; the first one writes `0001`.
- **Inventory — one record, accepted:**
  **[0001 — accessibility semantics are attached by hand, and the word for a
  state is the presentation's](../adr/0001-accessibility-semantics-are-attached-by-hand.md)**
  (promoted out of #88). Anything that emits `Semantics` files as a
  **conformance item under 0001**, never as a fresh decision and never as a new
  spine. Every other area still answers **no**, so a sibling pair there opens a
  spine. Keep this line current: an area that gains a record must be listed here
  with its number, or the next filing re-derives it.
- **The standing promotion candidate**, if a pass ever hands over two triggers:
  **deprecate-vs-remove across a major**. It has already been decided pairwise and
  *inconsistently* — asked for `alwaysVisible` (#45), not asked for `trackWidth`
  (#51), and the user caught the inconsistency in review rather than a rule
  catching it. That is the exact shape an issue structurally cannot hold.
- **Tracker parent/child: available, no exception.** GitHub sub-issues are
  enabled here (verified: `gh api repos/kihyun1998/flutter_dropdown_button/issues/88/sub_issues`
  → `[]`). Attach a child with
  `gh api --method POST repos/<owner>/<repo>/issues/<parent>/sub_issues -F sub_issue_id=<child-db-id>`,
  where the db id is `gh api repos/<owner>/<repo>/issues/<n> --jq .id` (**not** the
  `#number`). So a spine's roster and a follow-up tree are both **derived from the
  tracker** — never hand-kept prose in a body, and no reconciliation step.

## Step 7 — gate matrix + release + downstream loop

`.github/workflows/ci.yml` is the real source. Two jobs:

**`test` — matrix `minimum` (Flutter 3.32.0) × `stable`:**
```
flutter pub get
flutter analyze                                    # exits 1 on a single `info`
flutter test --coverage
dart run tool/check_coverage.dart --min 100 --report
cd example && flutter pub get && flutter analyze   # deprecation warnings surface here
```
**`package` (version-independent, one run):**
```
dart format --output=none --set-exit-if-changed .   # whole repo
flutter pub publish --dry-run                        # metadata only; does not compile
```

- **The `minimum` job is the point.** `stable`-only stays green forever while the
  pubspec promises `>=3.10` and calls a 3.32 API. It also catches version-specific
  analyzer rules (a dartdoc `[link]` to a deprecated member = a `use`, exit 1).
- **`example/` is the blind spot the top-level command does not reach** — its
  `flutter analyze` is a separate `pub get` in a separate package, and it is the
  only place a deprecation warning appears at all.
- Coverage floor is **100, no slack** — real regressions rest just under a
  threshold; raise it when the number rises, never lower it to green a build.
- Run each gate **bare, never piped** (`test … | tail -1 && commit` always
  commits — the exit status is `tail`'s).
- Branch → PR (`Closes #issue`) → **CI green** → merge. Never commit to `main`.
- **Release rides in the change's own commit, not a separate `chore:` one** —
  checked against the history rather than assumed: `f2bb82b` (#87) bumped
  `pubspec.yaml` and added the `CHANGELOG.md` section in the same commit as the
  feature. So the PR that fixes a thing also picks its version and writes its
  entry, and updates `README.md`'s quick-start constraint.
  `pub publish --dry-run` zero warnings. `flutter pub publish` is irreversible
  (retract only) — **the agent does not run it; the user does.**

**Linking a local build into a consumer** (the Step 4 full-suite round-trip) —
`dependency_overrides` in the consumer's `pubspec.yaml`:
```yaml
dependency_overrides:
  flutter_dropdown_button:
    path: ../flutter_dropdown_button
```
then `flutter pub get && flutter test` in the consumer. Remove the override
afterwards — a committed path override breaks that consumer's own CI.

**Downstream loop.** Derive, don't guess — and **do not stop at the sibling's own
manifest.** A repo can consume this package from a nested one, and the real
consumer does: `mobile_init_project` declares it in `template/pubspec.yaml`.
Grepping only `../*/pubspec.yaml` returns exactly one hit, `just_make_logo`,
pinned `^1.6.1` — a consumer that can never receive a 4.x fix — so the one-liner
that looks like it works is the one that misses everybody who matters:

```
grep -rl 'flutter_dropdown_button:' ../*/pubspec.yaml ../*/*/pubspec.yaml 2>/dev/null
```

The list is not stored here — derive it on the spot. A decision here is one the
consumers eventually pay. After a release, in each: raise the constraint, remove
workarounds the fix made unnecessary, flip tests that pinned the old bug. A purely
additive release obliges consumers to do nothing — say so explicitly.

## War-story index

[`lessons.md`](lessons.md) — keyed by the same step numbers as the skill, with the
issue number on each entry (#2, #9, #32, #37, #38, #40, #45, #47, #50, #51, #59,
#80, #81 …). Read it beside this file: when a rule here reads as an abstraction,
the incident that put it here is under the matching step heading. **New evidence
goes there, not into this file** — bindings hold the rule, lessons hold the
proof that it caught something.

## Refs

- Deprecated inventory & the "dead field = a documented field `resolve()` never
  mentions" detector: `CLAUDE.md`.
- SemVer discipline is load-bearing (consumers pin with `^`): breaking → major;
  adding or deprecating a member → not. `flutter_checkbox` types are re-exported,
  so an upstream `0.x` break is a **breaking change here**.
- Issue tracker conventions (labels, `gh` invocations, sub-issues):
  `docs/agents/issue-tracker.md`, `docs/agents/triage-labels.md`.
