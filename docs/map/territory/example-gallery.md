# Example gallery

## What it is

`example/`, a runnable gallery of recipes, one per feature area. It is built on
the `flutter_example_template` shell (its `ShellDestinations` port and
stage/route destinations), and it is also a CI input. Its tests pump every
recipe, and `tool/check_api_coverage.dart` counts the named arguments its recipes
pass against the public constructors of the two widgets, the eight theme
classes and `TextDropdownConfig` (`_declSources`). `example/` is a separate
package (`publish_to: 'none'`), so its dependencies reach no consumer, but it
ships inside this package's archive.

## Governing decisions

**None.** `flutter_example_template` is a **binding** reference in
[the references table](../../agents/thegraph.md#references): its undocumented
contracts bind whether or not they are written down. That binds how the shell is
used, not what the gallery shows.

## Design model

From the example's own tests and README and the issues cited; nothing is in a
record.

- **A recipe is claimed to render only if a test pumps it.** Before
  `recipe_renders_test.dart`, every gate was green while the Dismissal recipe
  threw `Competing ParentDataWidgets` on every build and two dropdowns had
  broken sizes (#143, lessons).
- **A recipe written against a comment is a test of the comment.** The #143
  recipes surfaced two false dartdoc claims about `width` and `expand`,
  corrected in 4.2.1 (#145, dfe81d4).
- **A recipe is pasteable: it imports the package and nothing from the
  shell** (`recipe_contract_test.dart`, "a recipe imports no shell"), and every
  `source:` a destination claims opens from the asset bundle.
- **The roster is the destinations list** (`DropdownDestinations.all`, a
  `late final` field, not a getter), and the shell's menu labels come from it,
  not from the stages. That is why a label test cannot detect a throwing stage.
- **The API-coverage gate can be satisfied by a recipe that shows nothing.**
  #155 passed `wheelMotion` once, inside Menu theming, with a custom value:
  the gate went to 100% while the default could be seen nowhere. The Wheel
  scrolling recipe (#159) is what shows it. `example/README.md` lists what the
  gate does not see.
- **Knob panes use no `Radio`.** `Radio.groupValue` is deprecated above the
  floor, and `RadioGroup`, which replaces it, does not exist at the floor, so
  one of the two CI jobs fails `flutter analyze` either way. A pick-one knob is
  a `ListTile` with a radio icon (`recipe_knobs.dart`).
- **The roster has to hold a `StageDestination`, and only a test enforces it.**
  `ShellPage` opens the first one, and a roster with none draws the menu alone.
  Under template 0.1.0 that roster threw `Bad state: No element` on the first
  build. Since 0.2.0 it is a legal page (template#10, 4cfadac), so nothing
  fails loudly any more. `destinations_test.dart`'s "the shell opens on a
  recipe, not on a bare menu" is what catches it. The assertion did not change
  when the crash went away; its reason did.
- **Room is the only viewport mode where the menu opens in the app's own
  overlay** (template 0.3.0, #163, efc4eab). The framed and wall modes each
  hold a contained `Overlay`, so there the single-open registry and placement
  see one frame, scaled. In Room they see the root overlay at 1:1, as a
  consumer's app does.
- **Running the example can dirty the tree.** A macOS run under Flutter 3.47
  rewrote the Xcode deployment target, and that broke the publish dry-run
  (#165; see [release surfaces](release-surfaces.md)).

## Code

- `example/lib/app/destinations.dart` — `DropdownDestinations`, `DropdownDestinations.all`
- `example/lib/app/recipe_knobs.dart` — `MultiSelectKnobs`, `MultiSelectStage`, `MultiSelectKnobPane`, `SearchKnobs`, `SearchStage`, `SearchKnobPane`, `WheelKnobs`, `WheelScrollStage`, `WheelScrollKnobPane`
- `example/lib/main.dart` — `MyApp`
- `tool/check_api_coverage.dart` — `readCallSites` (reads `example/lib`), `_declSources`

Recipes: `ls example/lib/recipes/` (15 at HEAD, each claimed by one
destination's `source:`; no test asserts that a file in the folder is
registered). Tests: `example/test/`.

## Reference behaviour

- `flutter_example_template`, read at the version `example/pubspec.lock` pins
  (0.3.0 at HEAD), from the pub cache
  ([references](../../agents/thegraph.md#references)). Two contracts found in
  0.1.0 were upstreamed as template#10 and template#11 (4cfadac).

## Cross-cutting invariants

**None.**

## Blast radius

- [Release surfaces](release-surfaces.md) — CI runs `example` analyze and tests,
  and the API-coverage floor counts only `example/lib`: a recipe that stops
  passing an argument drops the floor below 100 and CI goes red.
- [Theme resolution](theme-resolution.md), [trigger button](trigger-button.md),
  [text items](text-items.md), [multi-select](multi-select.md) — their public
  constructors are what the gate counts; a recipe removed or rewritten can leave
  one of their parameters demonstrated nowhere.
- [Placement](placement.md), [single-open](single-open.md) — in every viewport
  mode but Room the menu opens in a contained, scaled `Overlay`, so a recipe
  judged in another mode says nothing about the root-overlay behaviour a
  consumer gets.

## Known holes / open

- **The recipes folder and the roster are not checked against each other.**
  `recipe_contract_test.dart` walks the folder and `recipe_renders_test.dart`
  walks the roster; a recipe file added but not registered is pasteable-checked
  and never pumped, nor shown.
