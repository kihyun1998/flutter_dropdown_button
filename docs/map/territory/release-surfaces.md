# Release surfaces

## What it is

Everything that ships to a stranger or gates whether it ships:

- the pub.dev package itself (`pubspec.yaml`: version, SDK/Flutter floor,
  dependencies) and its archive;
- `CHANGELOG.md`;
- `README.md`;
- `documentation/`;
- the public dartdoc;
- the CI gates in `.github/workflows/ci.yml`: a `minimum` + `stable` matrix,
  analyze, tests, a line-coverage floor, an API-demonstration floor,
  example pub get/analyze/test, format, and publish dry-run;
- `.github/dependabot.yml`, which decides when a dependency bump is proposed.

The prose surfaces fail no gate: a wrong claim in them appears only to a
consumer.

## Governing decisions

**None.** No record. The policy (branch → PR → CI green → merge; the user runs
`flutter pub publish`) is stated in
[CLAUDE.md](../../../CLAUDE.md#working-discipline--thegraph), and the gate
reasons are stated in `ci.yml`'s own comments.

## Design model

From CLAUDE.md, `ci.yml`'s comments and the incidents cited; nothing is in a
record.

- **The next version comes from the registry, not the repo.** `pubspec.yaml` is
  what will ship next, and pub.dev is what actually shipped. That also decides
  whether a CHANGELOG section is still editable (#106,
  [lessons, Step 7](../../agents/lessons.md#step-7--게이트--릴리스)).
- **CHANGELOG is a bug inventory.** A dartdoc-only change touches `lib/` and
  adds no entry — unless it is released on its own because pub.dev renders the
  dartdoc of the published version, as 4.2.1 was (#95/#102, dfe81d4).
- **Documenting a behaviour turns it into a contract.** Test before writing it
  down: *would fixing this later be breaking?* (#95/#102).
- **Re-read README, CHANGELOG, pubspec and `documentation/` as one set** at
  release time. Each issue edited only the files it touched, and the
  cross-file contradictions survived (#88–#91).
- **Coverage floors have no slack.** Both floors are 100 (`ci.yml`,
  `--min 100`). Deleting `test/selection_test.dart` measured 99.57%, and real
  regressions come to rest just under a threshold (lessons, Step 7).
- **The archive is built from `.gitignore` plus per-directory `.pubignore`
  files; there is no root `.pubignore`.** `docs/`, `test/` and `tool/` each
  hold a `.pubignore` of `*` (`docs/` and `tool/` since f2bb82b, `test/` since
  20fac79, #100). `CLAUDE.md` ships on purpose: excluding a root file needs a
  root `.pubignore`, which disables `.gitignore`-based listing for the root and
  would have to restate every pattern (`test/.pubignore`'s comment). So
  `coverage/` must stay in `.gitignore` (its comment says why), because
  `coverage/lcov.info` once shipped with zero dry-run warnings (lessons, Step 7).
- **A dirty tree fails the publish dry-run.** A local macOS run of the example
  rewrote its Xcode deployment target and `flutter pub publish --dry-run`
  exited 65 (#165). CI never builds macOS, so it shows only to whoever
  publishes by hand: check `git status` after a real-run verification.
- **A Dependabot PR on the root is a release decision.** The root entry is
  `increase-if-necessary` with no root lockfile (`/pubspec.lock` is
  gitignored), so it opens a PR only when a release leaves the caret. At `0.x`
  that is every `flutter_checkbox` minor, and through the barrel each one is an
  API change here, so the root gets one PR per dependency, never a group. The
  `minimum` job is what answers whether the raised floor still holds.
  The example's and the actions' PRs are grouped, because nothing ships from
  there (`dependabot.yml`; #169).
- **Formatter drift:** if local `dart format` disagrees with CI stable on an
  untouched `main`, the drift is not your change. Format only the files you
  touched (#103).

## Code

- `tool/check_coverage.dart` — `main`, `_parse`
- `tool/check_api_coverage.dart` — `main`, `readDeclarations`, `readCallSites`, `_declSources`, `_exempt`
- `lib/flutter_dropdown_button.dart` — the re-export of `CheckboxShape`, `CheckboxStyle`, `WheelMotion`, `SpringWheelMotion`, `CurveWheelMotion`, `LerpWheelMotion` (`grep '^export .package:' lib/flutter_dropdown_button.dart`)

Not Dart, so they cannot be symbol-checked: `pubspec.yaml`, `CHANGELOG.md`, `README.md`, `documentation/*.md`, `.github/workflows/ci.yml`, `.github/dependabot.yml`, `.gitignore`, `docs/.pubignore`, `test/.pubignore`, `tool/.pubignore`.

## Reference behaviour

**None.** The registry is consulted per release (#106), not stored.

## Cross-cutting invariants

- [The Flutter floor is measured, not read](../invariant/flutter-floor-is-measured.md)

## Blast radius

- [Multi-select](multi-select.md) — a `flutter_checkbox` bump is an API change
  through the barrel, and its declared floor may differ from the last one read.
- [Scroll chrome](scroll-chrome.md) — so is a `flutter_smooth_wheel_scroll` bump.
- [Example gallery](example-gallery.md) — CI runs the example's analyze and
  tests, and the API floor counts its call sites: a parameter added or removed
  here without a recipe is red.
- Every territory, through its dartdoc: a behaviour changed without its dartdoc
  leaves pub.dev teaching the old one. The notes whose dartdoc has already been
  wrong once point back here.

## Known holes / open

- **The archive listing is measured only at #100.** 20fac79 recorded a
  dry-run with 0 warnings, `test` no longer a top-level entry, and 526 KB →
  475 KB compressed. The archive still carries all of `example/` (platform
  folders included) and `screenshot/`; whether that is wanted has not been
  asked. Not re-run for this note (no Flutter SDK in the session).
