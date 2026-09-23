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
  example analyze/test, format, and publish dry-run.

These surfaces never fail locally. A wrong claim here appears only to a consumer.

## Governing decisions

**None.** No record. The policy (branch → PR → CI green → merge; the user runs
`flutter pub publish`) is stated in
[CLAUDE.md](../../../CLAUDE.md#working-discipline--thegraph), and the gate
reasons are stated in `ci.yml`'s own comments.

## Design model

- **The next version comes from the registry, not the repo.** `pubspec.yaml` is
  what will ship next, and pub.dev is what actually shipped. That also decides
  whether a CHANGELOG section is still editable (#106).
- **CHANGELOG is a bug inventory.** A dartdoc-only change touches `lib/` and
  adds no entry.
- **Documenting a behaviour turns it into a contract.** Test before writing it
  down: *would fixing this later be breaking?* (#95/#102).
- **Re-read README, CHANGELOG, pubspec and `documentation/` as one set** at
  release time. Each issue edited only the files it touched, and the
  cross-file contradictions survived (#88–#91).
- **Coverage floors have no slack.** A deleted test file landed at 99.57%, and
  real regressions come to rest just under a threshold.
- **Formatter drift:** if local `dart format` disagrees with CI stable on an
  untouched `main`, the drift is not your change. Format only the files you
  touched (#103).

## Code

- `tool/check_coverage.dart` — `main`, `_parse`
- `tool/check_api_coverage.dart` — `main`, `readDeclarations`, `readCallSites`, `_declSources`
- `lib/flutter_dropdown_button.dart` — `CheckboxShape`, `CheckboxStyle`

Not Dart, so they cannot be symbol-checked: `pubspec.yaml`, `CHANGELOG.md`, `README.md`, `documentation/*.md`, `.github/workflows/ci.yml`.

## Reference behaviour

**None.**

## Cross-cutting invariants

- [The Flutter floor is measured, not read](../invariant/flutter-floor-is-measured.md)

## Blast radius

- [Multi-select](multi-select.md) — a `flutter_checkbox` bump is an API change
  through the barrel.
- [Example gallery](example-gallery.md) — CI runs the example's analyze and
  tests, and the API floor counts its call sites.
- Every territory, through its dartdoc. The notes whose dartdoc has already
  been wrong once point back here.

## Known holes / open

- **`.pubignore` does not exist, and never has** (`git log --all -- .pubignore`
  is empty). [lessons, Step 7](../../agents/lessons.md#step-7--게이트--릴리스)
  (#103) says `test/` is excluded by `.pubignore`. Whether the archive carries
  `test/`, `docs/` and `example/` has not been checked against a `--dry-run`
  listing. The map records the conflict and edits neither file.
