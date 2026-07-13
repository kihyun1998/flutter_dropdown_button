# theflow bindings (flutter_dropdown_button)

Project-specific data for the `theflow` skill (the working discipline for a
substantive change). The skill holds the portable *method*; this file holds this
package's *bindings* — which reference to read, where the boundary falls, how to
prove behavior, which surfaces to sweep, and which gates to run. The method
defers every concrete value here. Per-incident evidence lives in
[`lessons.md`](lessons.md) (the war-story index).

Identity & invariants live in `CLAUDE.md`. `CONTEXT.md` / `docs/adr/` do not
exist yet — created lazily, when a term or decision actually needs resolving.

## Crate / module map

Single Flutter package (no workspace). Public surface is the barrel
`lib/flutter_dropdown_button.dart`.

| Module (`lib/src/`) | Role | Public? |
|---|---|---|
| `flutter_dropdown_button.dart` | single-select widget — ~10 lines of selection, the rest delegated | ✅ |
| `flutter_multi_select_dropdown.dart` | multi-select — a `StatelessWidget` over the same shell | ✅ |
| `shell/dropdown_menu_shell.dart` | the button + the menu. **Knows nothing of selection** (`isChosen`/`onItemTap`/`closeOnTap`) | internal |
| `placement/dropdown_placement.dart` | pure geometry — no `BuildContext`/`MediaQuery`/`State` | internal |
| `overlay/dropdown_overlay_controller.dart` | overlay lifetime, animation, single-open registry; takes a *spec callback* | **✅ exported** |
| `presentation/item_presentation.dart` | text / custom / multi-select behind one interface; mode decided once in `_presentation` | internal |
| `search/dropdown_search_controller.dart` | the query, its field, its lifetime; `visibleItems()` derives each call | internal |
| `theme/` | `dropdown_style_theme` composes 4 (`dropdown_theme`, `dropdown_scroll_theme`, `search_field_theme`, `tooltip_theme`); each **resolves itself** | ✅ |
| `config/`, `buttons/`, `widgets/` | `text_dropdown_config`, `menu_alignment`, `scroll_gradient_overlay`, `smart_tooltip_text` | mixed |

Adding a parameter means adding it to the shell **and** both widgets — nothing
enforces that (the price of "cardinality is a type, not a flag"; see `CLAUDE.md`).

## Step 1 — reference routing table

Read real source with `gh api …/contents/<path> --jq .content | base64 -d`, then
`grep -n` / `sed -n`. Do not trust a summarizing fetch.

| Change type | Real source to read |
|---|---|
| **Flutter widget behavior** (Tooltip, Scrollbar, Text) | Flutter SDK `packages/flutter/lib/src/material/` + `widgets/` — e.g. `scrollbar.dart` (`trackVisibility` returns transparent without `true`), `tooltip.dart` (bg depends on `Brightness`; `constraints` is 3.32+), `Text.semanticsLabel` **replaces** the announced string |
| **Rendering / overlay / placement** | Flutter SDK `rendering/` + `widgets/overlay.dart`; coordinate space is the caller's business (off-screen-in-nested-`Overlay` was a real bug) |
| **API introduced-in version** | the **CI `minimum` job** is the authority (see Step 7); or `cd /d/flutter && git log -S "<sig>"` + `git tag --contains`. Reading source alone gave the wrong floor twice (#47) |
| **Downstream bug claim** | the consumer repo directly (`../just_make_logo`, `../penterm-2`) — verify, don't assume; the report may be the dartdoc's fault, not the code's (#59) |
| **Hidden state** | this repo's own read-sites. Removing a field can unpin behavior held incidentally through it — grep every read site first (`trackWidth` fed `hasCustomWidths` fed a non-null `thickness` branch) |

**Concept ≠ mechanism.** A tooltip/scrollbar/a11y feature may be novel at the
concept layer yet its mechanism (announce semantics, decoration merge, thumb
sizing) lives in Flutter's own material source — read both.

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

## Step 4 — proof method per layer

| Layer | Real proof |
|---|---|
| **pure logic** (placement, theme resolve, overlay controller, search) | unit tests, **no widgets** (107 of the suite mount nothing) |
| **widget behavior** | widget tests at the **public seam** — assert the rendered `BoxDecoration`, the presence of a `ListView`; **never private state** (why the suite survived the controller extraction + theme rewrite with zero edits) |
| **accessibility contract** | assert at the **semantics tree** (`semantics_label_test`) — a render-only test (`find.text`) passes while the announced string is wrong (#37) |
| **coverage** | `flutter test --coverage` + `dart run tool/check_coverage.dart --min 100`. Coverage tells you what you did *not* see, not whether what you saw is right (80% covered with **zero** item-tap tests once) |
| **downstream** | consumers `just_make_logo`, `penterm-2` |

Harness fake evidence to respect: restore `debugDefaultTargetPlatformOverride`
**in the test body** (`tearDown` is too late); do not reuse one `tester` to reopen
a menu (a second tap *closes* it); do not chain gestures in one `testWidgets`
(a prior scroll wakes the autoscrollbar thumb). `const Fruit('Apple')` is
normalized to one instance — `const` proves nothing about "different instances".

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
- **`environment` floor** (`>=3.32.0`) — raised when using a newer API; the CI
  `minimum` job is the only thing that catches a lying floor (#47).
- **Reclaim now-false rationale** — a release headnote saying "removed only
  deprecated" / "no behavior change" was falsified by the same PR (#45 / semantics).
- `dart format` follows the package language version — a floor bump can reformat
  the tree.

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
- Coverage floor is **100, no slack** — real regressions rest just under a
  threshold; raise it when the number rises, never lower it to green a build.
- Run each gate **bare, never piped** (`test … | tail -1 && commit` always
  commits — the exit status is `tail`'s).
- Branch → PR (`Closes #issue`) → **CI green** → merge. Never commit to `main`.
- **Release:** own commit `chore: release X.Y.Z` bumping `pubspec.yaml`, adding
  the `CHANGELOG.md` section, updating `README.md`'s quick-start version.
  `pub publish --dry-run` zero warnings. `flutter pub publish` is irreversible
  (retract only) — **the agent does not run it; the user does.**

**Downstream loop.** Derive, don't guess:
`for d in ../*/; do grep -l 'flutter_dropdown_button:' "$d/pubspec.yaml"; done`.
Current: `just_make_logo` (`^1.6.1`), `penterm-2` (`^1.4.6`) — **both two majors
behind**. A decision here is one they eventually pay. After a release, in each:
raise the constraint, remove workarounds the fix made unnecessary, flip tests
that pinned the old bug.

## Refs

- Deprecated inventory & the "dead field = a documented field `resolve()` never
  mentions" detector: `CLAUDE.md`.
- Consumers two majors back mean SemVer discipline is load-bearing: breaking →
  major; adding or deprecating a member → not.
