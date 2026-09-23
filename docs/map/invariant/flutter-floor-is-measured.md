# The Flutter floor is measured, not read

## The fact

Whether an API, an analyzer rule or an emitted behaviour exists at the floor
`pubspec.yaml` promises is answered by running the CI `minimum` job, or the
floor SDK, never by reading source. The same holds for a dependency's floor: it
is read from **that exact pinned version's** `pubspec`, never carried across
versions. The floor's number lives in `pubspec.yaml` and `ci.yml`, and this note
deliberately does not repeat it.

## Why it is cross-cutting

The floor constrains every file in `lib/` at once, and also `flutter_checkbox`'s
declared `environment` and the framework's own behaviour (semantics merging,
analyzer strictness). The places that meet it share no code. They share only
the SDK they are compiled against.

## Territories it holds in

- [Tooltip](../territory/tooltip.md) — `Tooltip.constraints` is what set the floor.
- [Overlay lifetime](../territory/overlay-lifetime.md) — the ticker fallback
  exists because `TickerMode.valuesOf` is missing at the floor and `TickerMode.of`
  is deprecated above it.
- [Semantics](../territory/semantics.md) — at the floor, the empty-state text
  merges into the search field's node.
- [Multi-select](../territory/multi-select.md) — `flutter_checkbox`'s declared
  floor is read per pinned version.
- [Release surfaces](../territory/release-surfaces.md) — the `minimum` CI job
  enforces all of the above.

## What a violation looks like

The build is green on `stable` and red only in the `minimum` job, or green in
both while the pubspec promises an SDK the code cannot build on, if the matrix
does not include the floor. The other form is an unnecessary floor raise, taken
from a number a dependency declared in a different version.

## Discovery history

1. **#47**: the floor was read from code as 3.27, and CI refuted it twice. It
   was measured instead.
2. **#80**: a floor raise was planned from `flutter_checkbox` 0.3.0's
   `pubspec`, but the pinned 0.3.1 had lowered it. The issue was closed as not
   needed.
3. **#90**: a test was red only at the floor. The failure message was widened
   rather than the assertion loosened, which exposed the empty state merging
   into the field's node at the floor.
4. **#106**: the design was fixed by asking `flutter analyze` while the probe
   still used `TickerMode.of`.

Four occurrences
([lessons](../../agents/lessons.md#step-7--게이트--릴리스)).

## Where it will recur

Any use of a Flutter API not already in `lib/`, any analyzer-sensitive
construct, and any `flutter_checkbox` bump is subject to this. Run the floor
before the design is fixed, not after.
