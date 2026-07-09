# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Package Overview

`flutter_dropdown_button` is a Flutter package providing a single, highly customizable dropdown widget rendered through an `OverlayEntry` rather than Flutter's built-in menu machinery.

There is **one** widget — `FlutterDropdownButton<T>` — with two constructors:

- `FlutterDropdownButton<T>(...)` — custom mode. `itemBuilder` renders each item as an arbitrary widget.
- `FlutterDropdownButton<T>.text(...)` — text mode. Items render as text through `SmartTooltipText`, gaining overflow handling, an automatic tooltip, and a default search filter. A `label` callback extracts the string, so `T` need not be `String`.

The two are distinguished internally by `isTextMode`, which is `itemBuilder == null`.

## Core Architecture

The widget is a thin shell over four modules, each of which takes plain values rather than a `BuildContext`.

### `DropdownPlacement` — `lib/src/placement/`

Pure geometry. Given a screen size, safe insets, a button rectangle and item metrics, it returns where the menu goes: height, open direction, transform alignment, top, left, width.

No `BuildContext`, no `MediaQuery`, no `State`. It does not know which coordinate space its inputs came from — that is the caller's business, and getting it wrong was the cause of a real bug (menus drawn off-screen inside a nested `Overlay`).

Its `chromeHeight` input covers everything in the overlay that is *not* an item: the search field, the border, the overlay's own padding. Omitting it is a compile error rather than a layout bug.

### `DropdownOverlayController` — `lib/src/overlay/`

Owns the overlay's lifetime, the open/close animation, the widget tree the menu is drawn into, and the rule that only one menu is open at a time within an `Overlay`.

**A `State` holds one; it does not inherit from it.** The controller is exported, so a third party building their own dropdown holds the same object `FlutterDropdownButton` does.

It takes a `DropdownOverlaySpec` **callback**, not a value — the item count, the theme and the search field's height change while the menu is open, and `measurePlacement()` re-reads them on every overlay build. That is why an open menu re-sizes when its items change, and flips above the button when the taller menu no longer fits below.

Single-open coordination lives in a registry keyed by `Overlay`, not in a process-wide static.

### `DropdownItemPresentation` — `lib/src/presentation/`

How items and the button's face are drawn. `TextItemPresentation` renders through a `label` and gains overflow handling, the tooltip and a default search filter; `CustomItemPresentation` calls `itemBuilder`.

The widget decides the mode **once**, in the `_presentation` getter, and every render site asks the result what to draw. It does not ask itself which constructor was used. `isTextMode` survives as a public informational getter that nothing branches on.

A presentation takes plain values and no `BuildContext` — the resolved icon size, not a `ResolvedButtonStyle`; a `DropdownTooltipTheme`, not a `Theme.of`. It holds the invariants of its own mode: `TextItemPresentation` asserts that `label` is present unless `T` is `String`, which is a promise `.text()` makes and the default constructor knows nothing about.

A third mode — grouped items, sections, multi-select — is a third implementation and a third branch in that one getter.

### Theme resolution — `lib/src/theme/`

`DropdownStyleTheme` composes four themes: `DropdownTheme`, `DropdownScrollTheme`, `DropdownTooltipTheme`, `SearchFieldTheme`.

Each **resolves itself**. `DropdownTheme.resolveButton()`, `.resolveOverlay()` and `.resolveItem()`, `SearchFieldTheme.resolve()`, `DropdownScrollTheme.resolve()` and `DropdownTooltipTheme.resolve()` return styles whose slots are all filled in; the widget reads the result rather than deciding. No theme fallback chain is left in `flutter_dropdown_button.dart`.

Resolution never takes a `BuildContext`. It takes whatever plain value it needs — a `DropdownAmbientColors` palette lifted out of `ThemeData`, a `Brightness`, or nothing at all — so every rule is a pure function.

The `Theme.of(context)` calls that remain are the adapters, and each one only *reads*: `DropdownAmbientColors.of()` lifts the palette, `SmartTooltipText` lifts the brightness, and `DropdownOverlayController` lifts the colours for the default menu chrome. None of them chooses anything.

A resolved style is **complete**, and that is load-bearing rather than tidy. `SearchFieldTheme` reserves the height it also constrains its divider to, so the two cannot disagree. `DropdownTooltipTheme` fills the whole `BoxDecoration` once the caller names any part of it, because Flutter's `Tooltip` treats a decoration as a total replacement and would otherwise blank the slots the caller left alone. Both of those were shipped bugs.

`DropdownTooltipTheme.resolve()` returns a **nullable** decoration on purpose: a theme that names no box property must leave the box to the ambient `TooltipTheme`.

### The recurring pattern

Every module here separates **reading from the element tree** from **deciding with what was read**. Pulling `MediaQuery.size` out of a context needs a context; computing a menu's height from it does not. Pulling `Theme.of(context).dividerColor` needs a context; choosing between it and a themed override does not.

The second half is where the bugs are, and it is the half worth testing. When adding a module, keep the split.

## Deprecated

Nothing. 3.0.0 removed the last of it — `DropdownMixin`, `DropdownTheme.animationDuration`, and `DropdownTooltipTheme.borderColor` / `.borderWidth`.

When you deprecate a member, annotate the **field, the constructor parameter and the `copyWith` parameter** separately. `@Deprecated` does not propagate from a field to its initializing formal, so annotating only the field lets `DropdownTheme(animationDuration: ...)` compile silently. Verify from `example/`, which is a separate package — within this package the analyzer stays quiet.

## Development Commands

```bash
flutter pub get              # install dependencies
flutter test                 # run the suite (113 tests)
flutter analyze              # static analysis; must be clean
dart format .                # formatting; must produce no changes
flutter pub publish --dry-run   # validate the package before release

cd example && flutter run    # run the playground app
```

## Testing

113 tests. 66 of them run without mounting a widget at all.

| Suite | What it covers |
| --- | --- |
| `test/placement/` | The geometry module, exhaustively. No widgets. |
| `test/theme/` | Every `resolve()`. No widgets. |
| `test/overlay/` | The controller's lifecycle. No widgets. |
| `test/presentation/` | Alignment, the default filter, label extraction. No widgets. |
| `test/overlay_bounds_test.dart` | Menus near screen edges, and inside a nested `Overlay` |
| `test/overlay_resize_test.dart` | An open menu growing, shrinking, and flipping |
| `test/overlay_lifecycle_test.dart` | Single-open, `closeAll`, dispose |
| `test/search_invalidation_test.dart` | The query surviving rebuilds |
| `test/search_divider_height_test.dart` | The divider's reserved height matching its drawn height |
| `test/text_label_test.dart` | `label` with a non-`String` `T` |
| `test/theme_resolution_test.dart` | Resolution rules, observed at the rendered widget |
| `test/tooltip_decoration_test.dart` | A partial tooltip theme keeping the box it did not name |
| `test/disabled_state_test.dart` | The disabled state, including single-item auto-disable |

**Conventions that matter here:**

- **Test at the public seam.** Widget tests assert on what is rendered — the `BoxDecoration` on the button, the presence of a `ListView` — never on private state. That is why the test suite survived the controller extraction and the theme resolution rewrite without a single edit.
- **Prove a test can fail.** A test written *after* a fix has never been red. Before trusting it, revert the fix (`git stash` the lib change) and confirm the test catches the bug. Two tests in this repo were found to be vacuous this way.
- **Say when a test cannot fail.** Some tests guard behaviour that was never broken, or exercise a capability that did not previously compile. Label them; do not let them masquerade as regression tests.

## Package Structure

```
lib/
├── flutter_dropdown_button.dart          # public exports
└── src/
    ├── flutter_dropdown_button.dart      # the widget
    ├── placement/dropdown_placement.dart # pure geometry
    ├── overlay/
    │   └── dropdown_overlay_controller.dart  # overlay lifetime, animation, spec
    ├── presentation/
    │   └── item_presentation.dart         # text vs custom rendering, behind one interface
    ├── theme/
    │   ├── dropdown_style_theme.dart     # composes the four below
    │   ├── dropdown_theme.dart           # + resolveButton/Overlay/Item
    │   ├── resolved_dropdown_style.dart  # ambient palette + resolved styles
    │   ├── dropdown_scroll_theme.dart
    │   ├── search_field_theme.dart
    │   └── tooltip_theme.dart
    ├── config/text_dropdown_config.dart  # text overflow, alignment, styles
    ├── buttons/menu_alignment.dart
    └── widgets/smart_tooltip_text.dart   # tooltip on overflow
```

## Documentation

- `README.md` — features, quick start, full parameter tables
- `documentation/api_reference.md`
- `documentation/theming.md`
- `documentation/text_configuration.md`
- `documentation/migration.md`
- `documentation/use_cases.md`

`docs/agents/` holds configuration for coding agents (issue tracker, triage labels, domain docs). It is excluded from the published package by `docs/.pubignore`.

When changing a public class name or signature, update `README.md` and `documentation/` in the same change. These files have drifted before, and stale docs sent readers to APIs that had been deleted three major versions earlier.

## Version Management

- Semantic versioning. The version lives in `pubspec.yaml`; do not restate it in prose.
- Breaking changes require a major bump. Adding a member, or deprecating one, does not.
- `CHANGELOG.md` entries take the form `* **TYPE**: Description`, where TYPE is one of `FEAT`, `FIX`, `BREAKING`, `DEPRECATED`, `REFACTOR`, `PERF`, `CHANGE`, `TEST`, `MIGRATION`.
- Record deprecations and behaviour changes even when they are small. A silent deprecation surprises people; a four-pixel layout change that nobody wrote down is a bug report waiting to happen.
- A bug found while refactoring is fixed in the same change, not deferred to a new issue — you have the code loaded, and reloading it later costs more than the tidiness is worth. But it **must** get a `FIX` entry naming the symptom, not just the cause. Six of the ten bugs fixed across 2.3.2–3.0.0 arrived this way and never had an issue of their own.
- Consequently, **`CHANGELOG.md` is the bug inventory, not the issue tracker.** The tracker records work that was planned; the changelog records what actually changed. Do not answer "what has this package fixed?" by listing issues.
- Cut a release in its own commit (`chore: release X.Y.Z`) that bumps `pubspec.yaml`, adds the `CHANGELOG.md` section, and updates the version in `README.md`'s quick start.
- Run `flutter pub publish --dry-run` before releasing; it must report zero warnings.
