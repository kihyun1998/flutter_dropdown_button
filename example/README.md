# flutter_dropdown_button — example

A gallery of `flutter_dropdown_button`, built on
[`flutter_example_template`](https://pub.dev/packages/flutter_example_template).

```sh
cd example
flutter run
```

## What is in it

**Recipes** — one pasteable, self-contained file each. The Code pane beside them
reads the running file out of the asset bundle, so what is on screen and what
executes cannot disagree. Every one of them imports the package and nothing else
from this app, which `test/recipe_contract_test.dart` holds.

| Recipe | What it shows |
|---|---|
| Basic | `.text()` at its minimum: a list, a callback, and the value you hold |
| Domain type | `label` over a non-`String` type, single **and** multi in one file |
| Multi-select | the checklist: `labelBuilder`, checkbox theming, row slots — and a ticked value surviving the disappearance of its rows |
| Search | `searchFilter` reading the item rather than its label, and `emptyBuilder` for when it matches nothing |
| Custom items | `itemBuilder`, `selectedBuilder`, `hintWidget` — a button face that need not be a row |
| Text overflow | the three `TextDropdownConfig` presets, and the `itemHeight` trap that comes with wrapping |
| Dismissal | switching between two adjacent dropdowns in **one** tap, a menu following its button as the page scrolls, keyboard navigation |
| Bare anchor | `anchorBuilder` + `positioningKey`, in all three cardinalities |
| Build your own | `DropdownOverlayController` + `TextItemPresentation`, without `FlutterDropdownButton` at all |
| Overlay lifetime | `closeAll()` and `closeAll(animate: false)` across a route change |

**Every setting** — a page rather than a recipe, because it is the one surface
that holds all ~200 knobs at once: three modes, every theme class, and the
`Advanced` section for the slots that replace the ambient value rather than
merging into it.

## The claim this example holds itself to

**Every named parameter the package declares is passed somewhere under
`example/lib`.** All three widget constructors and all nine theme classes,
203 of 203 — and `tool/check_api_coverage.dart` holds it at 100% in CI rather
than anybody remembering to check.

What that gate does **not** see, recorded so a green build is not read as
promising more than it does:

- the Dismissal recipe's subjects are named by no constructor argument;
- whether `resolve()` ever ran with `Brightness.dark` — flip the theme toggle;
- whether a value passed to a replacing slot was *complete*. It counts that the
  argument was passed, never that what was passed was whole.

**Something does look at the drawing now**, because the gap above turned out to
be expensive. `test/recipe_renders_test.dart` pumps every stage in the roster
and every knob pane behind it, and fails on a thrown exception, on a dropdown
stretched by its parent, and on a `width` that never reached the button. It
found three defects the moment it existed — one of them a framework assertion
throwing on every build of a recipe, while all eleven tests, `flutter analyze`,
both contract tests and the coverage gate at 100% were green (#143).

It is a smoke test and not a golden: it asks whether a recipe drew and roughly
what size, never what it looked like. Colour, spacing and anything inside the
menu are still seen by nobody but a person opening the app.
