# Example gallery

## What it is

`example/`, a runnable gallery of recipes, one per feature area. It is built on
the `flutter_example_template` shell (its `ShellDestinations` port and
stage/route destinations), and it is also a CI input. Its tests pump every
recipe, and `tool/check_api_coverage.dart` counts the named arguments its recipes
pass against the public constructors.

## Governing decisions

**None.** `flutter_example_template` is a **binding** reference in
[the references table](../../agents/thegraph.md#references): its undocumented
contracts bind whether or not they are written down.

## Design model

- **A recipe is claimed to render only if a test pumps it.** Before
  `recipe_renders_test.dart`, every gate was green while one recipe threw
  `Competing ParentDataWidgets` on every build and two had broken sizes (#143).
- **A recipe written against a comment is a test of the comment.** The #143
  recipes surfaced two false dartdoc claims about `width` and `expand` (4.2.1).
- **The roster is the destinations list**, and the shell's menu labels come from
  it, not from the stages. That is why a label test cannot detect a throwing
  stage.
- **The API-coverage gate can be satisfied by a recipe that shows nothing.**
  #155 passed `wheelMotion` once, inside Menu theming, with a custom value:
  the gate went to 100% while the default could be seen nowhere. The Wheel
  scrolling recipe (#159) is what shows it.
- **Knob panes use no `Radio`.** `Radio.groupValue` is deprecated above the
  floor, and `RadioGroup`, which replaces it, does not exist at the floor, so
  one of the two CI jobs fails `flutter analyze` either way. A pick-one knob is
  a `ListTile` with a radio icon.
- **The roster has to hold a `StageDestination`, and only a test enforces it.**
  `ShellPage` opens the first one, and a roster with none draws the menu alone.
  Under template 0.1.0 that roster threw `Bad state: No element` on the first
  build. Since 0.2.0 it is a legal page (template#10), so nothing fails loudly
  any more. `destinations_test.dart`'s "the shell opens on a recipe" is what
  catches it. The assertion did not change when the crash went away; its reason
  did.
- **Room is the only viewport mode where the menu opens in the app's own
  overlay** (template 0.3.0, #163). The framed and wall modes each hold a
  contained `Overlay`, so there the single-open registry and placement see one
  frame, scaled. In Room they see the root overlay at 1:1, as a consumer's app
  does.

## Code

- `example/lib/app/destinations.dart` — `DropdownDestinations`
- `example/lib/app/recipe_knobs.dart` — `MultiSelectKnobs`, `SearchKnobs`, `WheelKnobs`, `MultiSelectStage`, `SearchStage`, `WheelScrollStage`, `WheelScrollKnobPane`
- `example/lib/main.dart` — `MyApp`

Recipes: `ls example/lib/recipes/` (the folder is the roster). Tests: `example/test/`.

## Reference behaviour

- `flutter_example_template`, read at the version `example/pubspec.lock` pins,
  from the pub cache
  ([references](../../agents/thegraph.md#references)). Two contracts found in
  0.1.0 were upstreamed as template#10 and template#11.

## Cross-cutting invariants

**None.**

## Blast radius

- [Release surfaces](release-surfaces.md) — CI runs `example` analyze and tests,
  and the API-coverage floor depends on the recipes.
- [Theme resolution](theme-resolution.md) and [trigger button](trigger-button.md)
  — a new public parameter on either is red in CI until a recipe demonstrates it.

## Known holes / open

**None recorded.**
