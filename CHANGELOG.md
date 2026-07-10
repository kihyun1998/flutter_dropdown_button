# Changelog

## 3.1.0

Adds a second widget. Nothing was removed; one field is deprecated and one behaviour changed, both described below.

* **FEAT**: `FlutterMultiSelectDropdown<T>` — a checklist. Several items may be chosen, the menu stays open while they are, and `onChanged` fires with a **new** `Set<T>` the moment a box is ticked. Anchored rather than modal: no scrim, no confirm button, dismissed by an outside tap. It shares every layout, theming and search parameter with `FlutterDropdownButton`. Rows are `[checkbox] [itemLeadingBuilder] [label] [itemTrailingBuilder]`, and only the label gives way when space runs out. Both slots are builders, because the reason to want one is that each value looks different. The `Set` you pass in is never mutated, and `T` must implement `==` **and** `hashCode` — a `Set` needs both, where `value == item` needed only the first
* **FEAT**: `MultiSelectPresentation<T>`, the third `DropdownItemPresentation`. Its rows carry a checkbox that is **excluded from the semantics tree**, with the checked state re-attached to the row. A `Checkbox` with `onChanged: null` inside the row's ink well announces `isEnabled: false` once the tree merges, so a screen reader would have called every row of a working checklist *dimmed*. `IgnorePointer` does not help; it suppresses hit-testing, not semantics. Nothing about this is visible on screen
* **CHANGE**: A `value` that is not in `items` is now **drawn** in custom mode, rather than replaced by `hintWidget`. A list refresh that drops the chosen row's data left `value` naming a row that no longer existed, and the button quietly reverted to its hint — no callback, no error. Text mode never did this, having no `items` to consult, so the two modes disagreed and neither behaviour was documented. **The widget draws what it was handed.** The menu is unchanged: it iterates `items`, and never invented a row
* **DEPRECATED**: `CustomItemPresentation.items`. It fed the audit removed above and is now read by nothing. It is no longer `required`; drop the argument. Removed in 4.0.0. Only code that constructs a presentation by hand is affected
* **REFACTOR**: `DropdownMenuShell` (internal) is the button, the overlay, and everything between — 994 of the widget's 1004 lines, none of which knew what selection is. It takes `isChosen(T)`, `onItemTap(T)` and `closeOnTap`; the two public widgets differ only in what they pass. `value`, `scrollToSelectedItem` and `disableWhenSingleItem` are **absent from the multi-select type** rather than asserted against at runtime
* **TEST**: 256 tests, up from 224, still at 100% line coverage (1037 lines). The shell extraction passed the existing suite with **no test file edited**, the sixth refactor in this package to meet that standard. The coverage floor earned its keep twice: it rejected a `closeOnTap` flag that no caller set, and it caught a test named *merges the disabled style* that never reached the `merge()`

## 3.0.2

Documentation only. No statement in `lib/` changed — every corrected line is a comment. It is released because pub.dev renders the dartdoc of the version it was published from, so a reader of 3.0.1's API page is still told the opposite of what the code does. A downstream app set a `trackColor`, saw no track, and was right to be confused.

* **CHANGE**: `DropdownScrollTheme.interactive`'s dartdoc said `null` meant "display only". It means the opposite: `Scrollbar` resolves a null `interactive` to `!_useAndroidScrollbar`, so the thumb is **draggable on desktop**. Pass `false` when you mean off
* **CHANGE**: `DropdownScrollTheme.trackColor` and `.trackBorderColor` said "if null, no track is displayed", implying a colour draws one. It does not. The track is drawn by `trackVisibility: true` and by nothing else; Flutter resolves a hidden track's colour to transparent. **A colour is not a request**
* **CHANGE**: `DropdownScrollTheme.trackVisibility` said "if true **or null**, shows the track". Null resolves to `false`. There is no track by default
* **CHANGE**: `DropdownScrollTheme.thumbVisibility` said `false` hides the thumb. `false` and `null` behave identically — the thumb fades in while the list scrolls and fades out after. Only `true` pins it. Setting `trackVisibility: true` raises this to `true`, because Flutter cannot draw a track without a thumb
* **CHANGE**: `DropdownScrollTheme.radius`'s "the default scrollbar radius" is `Radius.circular(8)` on desktop and **square on Android**
* **CHANGE**: The class-level example for `DropdownScrollTheme` taught a `trackColor` with no `trackVisibility` — the combination that draws nothing — and used `withOpacity`, which is deprecated. Both fixed, here and in the `gradientColors` example. The playground's `interactive` toggle started at `false`, shipping a demo scrollbar nobody could drag
* **TEST**: 224 tests, up from 222, still at 100% line coverage. Both new ones are guards on the corrected docs: a null `interactive` is draggable, and a track colour alone does not ask for a track. The second fails if anyone makes `trackColor` imply `trackVisibility`

## 3.0.1

* **FIX**: The menu drew **two scrollbars** on desktop. `MaterialScrollBehavior` wraps every scroll view in a `Scrollbar` of its own, and this package added a second on top without suppressing it. The one underneath answered to nothing `DropdownScrollTheme` says. The list is now wrapped in `ScrollConfiguration(scrollbars: false)`
* **FIX**: The scrollbar swelled from 8 to 12 logical pixels while a pointer hovered a visible track. Flutter does that to any `Scrollbar` handed no `thickness` (`material/scrollbar.dart:303`), and this package handed it `null` whenever the caller named neither `thickness` nor `thumbWidth` — `trackVisibility: true` alone was enough. The menu now passes the thickness the bar would have rested at anyway, so it looks the same at rest and no longer swells
* **FIX**: A dropdown given **no `DropdownScrollTheme` at all** never applied a scrollbar of its own; the menu fell through entirely to Flutter's automatic one, unstyleable and swelling. `scroll` now falls back to `DropdownScrollTheme.defaultTheme`, the way `dropdown`, `tooltip` and `search` always have
* **CHANGE**: `DropdownScrollTheme.thickness`'s dartdoc promised a flat `8.0` fallback. Flutter's default is **8 on desktop and 4 on Android**; honouring that doc would have doubled the bar on every Android build. The resting thickness now comes from the ambient `ScrollbarTheme` first, then from Flutter's own platform default. The doc now says what the code does
* **CHANGE**: `ResolvedScrollStyle.hasCustomWidths` is informational. `thickness` carries the answer it used to gate, and nothing in the package branches on it
* **TEST**: 222 tests, up from 207, still at 100% line coverage. Fifteen new ones drive the scrollbar across `windows`, `macOS`, `linux` and `android`

## 3.0.0

Removes everything deprecated during the 2.x line, plus one field that was never deprecated because nobody noticed it did nothing. Nothing was renamed — every removed member already had a replacement that was doing the work. **If you only ever used `FlutterDropdownButton`, what changes for you is that `semanticsLabel` starts working, a visible scrollbar track stops crashing, and the scroll fades point the right way.**

The deprecations landed across 2.3.2, 2.4.0, 2.4.1 and 2.5.0. Upgrading straight from an earlier 2.x skips the versions that warned, so the list below is the warning.

* **BREAKING**: Removed `DropdownMixin<T>`. Hold a `DropdownOverlayController` instead of mixing one in — the twenty-three members the mixin asked you to override collapse into one `DropdownOverlaySpec`. Deprecated in 2.4.0
* **BREAKING**: Removed `DropdownMixin.calculateMenuWidth()` and `DropdownMixin.calculateMenuLeftPosition()`. Use `DropdownPlacement.resolve()`, which returns the menu's full geometry in one call. Deprecated in 2.3.2
* **BREAKING**: Removed `DropdownPositionResult` and `DropdownMixin.calculateDropdownPosition()`. Use `DropdownOverlayController.measurePlacement()`, which returns a `DropdownPlacementResult`
* **BREAKING**: Removed `DropdownTheme.animationDuration`. Nothing ever read it; setting it did nothing. Pass `animationDuration` to `FlutterDropdownButton`. If you were setting it on the theme your menus animated at 200ms and still do — move the value across only if you actually wanted the slower animation. Deprecated in 2.4.1
* **BREAKING**: Removed `DropdownTooltipTheme.borderColor` and `DropdownTooltipTheme.borderWidth`. Use `border`, which takes any `BoxBorder`: `DropdownTooltipTheme(border: Border.all(color: Colors.red, width: 2))`. Deprecated in 2.5.0
* **BREAKING**: Raised the SDK floor to Flutter `>=3.32.0` / Dart `>=3.8.0`. It claimed `>=3.10.0`, but `lib/` uses `WidgetStateProperty` (3.22), `Color.withValues` (3.27) and `Tooltip.constraints` (3.32). `pub` resolved against the promise, so a project on 3.10 installed the package and then failed to compile inside our source. Not a new restriction; an honest statement of an old one — and the floor was found by building against it in CI, not by reading the code
* **BREAKING**: Removed `DropdownScrollTheme.alwaysVisible`. Nothing ever read it — setting it was indistinguishable from leaving it null, while its own class dartdoc recommended it. Use `thumbVisibility: true`, which is what it claimed to mean and what actually works. Removed rather than deprecated: it names exactly what `thumbVisibility` already does, so there is nothing to keep, and anyone who set it has been living with an auto-hiding scrollbar without knowing they asked otherwise
* **FIX**: `TextDropdownConfig.semanticsLabel` now labels the dropdown, as it always claimed to. It was applied to **every menu item** and to nothing else — and `Text`'s semantics label *replaces* the announced string, so a screen reader read `"Fruit picker"` for the Apple row, the Banana row and the Cherry row alike, suppressing every item's name and leaving the menu unnavigable by voice. It now sits on the button, announced alongside the selected value (`"Fruit picker, Banana"`), and items announce their own text
* **FIX**: `DropdownScrollTheme(trackVisibility: true)` no longer crashes the menu on open. Flutter asserts that a scrollbar track is never drawn without a thumb, and the overlay passed `thumbVisibility: false` alongside it — so the documented way to show a track threw `'A scrollbar track cannot be drawn without a scrollbar thumb'` the moment the dropdown was tapped. Present since 1.2.0. A visible track now implies a visible thumb, and the illegal pair is rejected by `DropdownScrollTheme`'s own constructor rather than by Flutter, three frames later
* **FIX**: The scroll-fade indicators are no longer inverted. With `showScrollGradient: true` and no `gradientColors`, both fades were built with the transparent colour first — so instead of the menu's background bleeding over the content at the edge it is hiding, the fade was clear at the edge and opaque next to the content, washing out the middle of the list. Callers who supplied their own `gradientColors` were always drawn correctly; only the default list was in the wrong order
* **FIX**: An unstyled `DropdownScrollTheme` no longer wraps the menu in a `ScrollbarTheme`. It replaces the ambient one rather than merging with it, so wrapping unconditionally would have silenced an app-wide `ScrollbarTheme`
* **BREAKING**: Removed `DropdownScrollTheme.trackWidth`. It was never applied to anything: Flutter's `Scrollbar` and `RawScrollbar` draw the track at the thumb's thickness and expose no separate track width, so the value was read once — to compare itself against `thumbWidth` — and then discarded. Use `thumbWidth`, or `thickness`. Removed rather than deprecated, for the same reason as `alwaysVisible`: the field cannot be made to work, so there is nothing for a deprecation window to buy
* **CHANGE**: `DropdownScrollTheme.resolve()` now returns the scrollbar's colours and radius as well as its measurements, in `ResolvedScrollStyle.scrollbarTheme` and `.overridesScrollbarTheme`. Its `crossAxisMargin`, `mainAxisMargin`, `minThumbLength` and `trackWidth` fields are gone — they live inside `scrollbarTheme` now — and `thumbVisibility` / `trackVisibility` / `interactive` became nullable, because writing Flutter's default into them would override an ambient `ScrollbarTheme`
* **CHANGE**: `lib/src/buttons/dropdown_mixin.dart` is gone
* **FEAT**: Added `DropdownSearchController<T>`, which owns a dropdown's query, its text field, its focus and their lifetime. It knows nothing about the menu or the scroll position; the owner drives those. `visibleItems(items, filter)` derives the filtered list on every call rather than caching it — every past defect in this area was a missed cache invalidation
* **FEAT**: Added `DropdownItemPresentation<T>`, with `TextItemPresentation` and `CustomItemPresentation` behind it. Anyone building a dropdown on `DropdownOverlayController` can reuse `TextItemPresentation` and get overflow handling, the tooltip and the default search filter for free, rather than reimplementing them
* **REFACTOR**: The widget no longer branches on `isTextMode`. Rendering is chosen once, in one factory; eight consult sites became zero, and four private render methods left `flutter_dropdown_button.dart` (1291 → 1166 lines). A third rendering mode is now a third implementation and a third branch in that factory, not another conditional at every render site
* **REFACTOR**: The scroll-fade indicators left the widget's `State` for a `ScrollGradientOverlay` widget that owns its own notifiers and scroll listener. Their 150ms fade duration was written twice; the two must match for the top and bottom to read as one effect, and now they cannot disagree
* **REFACTOR**: The search subsystem left the widget's `State`. The `TextEditingController`, the `FocusNode`, the query and their lifecycle were spread across `initState`, `didUpdateWidget`, `dispose` and five render sites; they now live behind `DropdownSearchController`, and the widget holds one
* **REFACTOR**: The overlay's content area is now sized by `DropdownOverlaySpec.totalChromeHeight` rather than by re-adding the border, padding and search-field heights by hand. `DropdownPlacement` grows the menu by that same getter, so the grow and the shrink can no longer disagree — which is what they did in 2.3.2 and again in 2.5.0
* **CHANGE**: `isTextMode` remains public but is informational — nothing inside the widget reads it
* **CHANGE**: The `label`-or-`String` invariant is now asserted by `TextItemPresentation` rather than in `initState`, so it fires on the first build. Still before anything paints, still an `AssertionError` in debug builds
* **TEST**: 140 tests, up from 107. Four guarded members that no longer exist and were deleted; ten new ones exercise the presentation seam with no widget tree. One deletion is worth naming: "a tooltip `borderWidth` with no `borderColor` draws nothing" is now unrepresentable rather than untested, because a `BoxBorder` cannot carry a width without a colour
* **FEAT**: Added `DropdownTheme.resolvedIconSize` and `DropdownTheme.defaultIconSize`. The arrow's size is the one part of `resolveButton()`'s answer that owes nothing to the ambient palette, so a caller who needs only that number can now read it without resolving a whole `ResolvedButtonStyle`
* **PERF**: Building the item presentation no longer resolves the button's style. It reached for `_buttonStyle.iconSize` to size a leading widget, which lifted the ambient palette out of `Theme.of(context)` and built a `BoxDecoration` — and the presentation is constructed on every access, including once per keystroke while searching. Measured: `resolveButton()` ran twice per build, four times on open and twice per typed character; it now runs once, once, and **not at all**. No behaviour changes: `resolveButton()` is a pure function, so the extra calls returned identical answers
* **REFACTOR**: `_buildOverlayContent` built the presentation twice, once through `_visibleItems` and once for itself. It now builds one and passes it
* **REFACTOR**: `TextItemPresentation` builds its text through one helper. Its two builders passed the same eight `TextDropdownConfig` values to `SmartTooltipText` separately, which is how `semanticsLabel` came to reach the menu rows and not the button. The helper forwards a null style verbatim rather than substituting a default, because a null style is a decision
* **REFACTOR**: Three layout decisions in the button's `Row` asked "does this button fill its width?" three times; they now share one named local. Hand-written `insets.top + insets.bottom` sums replaced with `EdgeInsets.vertical`
* **CHANGE**: Added CI. Until now this repository had no automated checks at all. Two Flutter versions run on every pull request: `stable`, and the **minimum the pubspec declares** — the second is the only one that can catch the package outgrowing its own constraint, which is how the constraint above went wrong for three minor versions
* **DOCS**: `documentation/migration.md` gains a 2.x → 3.0.0 section. `api_reference.md` no longer documents `DropdownMixin`, and its `closeAll()` section no longer claims the call is unanimated or that only one menu can be open process-wide — both stopped being true in 2.4.0

## 2.5.0

* **FIX**: A `SearchFieldTheme.divider` taller than one pixel no longer overflows the item list. The overlay reserved a hardcoded `1.0` for any divider, but Flutter's `Divider()` — the widget almost everyone reaches for — is **16px** tall, so a three-item searchable menu threw `A RenderFlex overflowed by 15 pixels on the bottom`
* **FIX**: A `DropdownTooltipTheme` that sets one visual property no longer blanks the rest of the tooltip's box. Flutter's `Tooltip` treats a non-null `decoration` as a total replacement rather than a merge, so `DropdownTooltipTheme(borderRadius: BorderRadius.circular(8))` produced a **transparent** tooltip — white text on nothing. The same held for `shadow` and `borderColor` alone. Unset slots now fall back to `Tooltip`'s own defaults
* **FEAT**: Added `SearchFieldTheme.dividerHeight` (defaults to `1.0`). The overlay reserves this much space **and constrains the divider to it**, so the height reserved and the height drawn cannot disagree
* **FEAT**: Added `DropdownTooltipTheme.border`, a `BoxBorder` — the same shape `DropdownTheme.border` and `SearchFieldTheme.border` take. It wins over `borderColor` / `borderWidth`
* **CHANGE**: `SearchFieldTheme.divider` is now laid out at exactly `dividerHeight`. A caller passing `Divider()` and relying on its natural 16px must now pass `dividerHeight: 16` to keep it; otherwise the divider draws at 1px instead of overflowing
* **CHANGE**: A `DropdownTooltipTheme` that sets `backgroundColor` and nothing else now keeps Flutter's 4px tooltip corners, where it previously squared them off. Set `borderRadius: BorderRadius.zero` for the old look
* **DEPRECATED**: `DropdownTooltipTheme.borderColor` and `DropdownTooltipTheme.borderWidth` in favour of `border`. They still work. Removed in 3.0.0
* **REFACTOR**: `SearchFieldTheme`, `DropdownScrollTheme` and `DropdownTooltipTheme` resolve themselves, completing the work `DropdownTheme` began in 2.4.1. `resolve()` takes a plain value — a `DropdownAmbientColors` palette, a `Brightness`, or nothing — never a `BuildContext`, so every styling rule is a pure function. The last four `Theme.of(context)` calls and twelve `??` fallback chains left the widget's `build()`
* **CHANGE**: Exported `ResolvedSearchFieldStyle`, `ResolvedScrollStyle` and `ResolvedTooltipStyle`, and added `DropdownAmbientColors.hint`. Additive; existing theme fields are unchanged
* **TEST**: 107 tests, up from 77. Thirty-five exercise theme resolution with no widget tree at all. `DropdownTooltipTheme` had no test coverage of any kind before this release, which is why its bug survived

## 2.4.1

* **FIX**: The trailing arrow now honours the single-item auto-disable. A dropdown disabled by `disableWhenSingleItem` blocked taps, switched its decoration to the disabled form and applied `disabledTextStyle`, while the arrow kept its **enabled** colour. Visible whenever `hideIconWhenSingleItem: false`. The icon asked `widget.enabled`; everything else asked `isEnabled`
* **DEPRECATED**: `DropdownTheme.animationDuration`. Nothing has ever read it — the animation is driven by `FlutterDropdownButton.animationDuration`, and setting it on the theme was silently ignored. It is being removed rather than wired up: honouring it now would slow the animation for everyone who set it and has been living with the widget's 200ms. Pass the duration to the widget. Removed in 3.0.0
* **REFACTOR**: `DropdownTheme` resolves itself. `resolveButton()`, `resolveOverlay()` and `resolveItem()` return styles whose slots are all filled in, and take a plain `DropdownAmbientColors` palette rather than a `BuildContext` — so styling rules are pure functions, testable without mounting a widget. Thirteen inline `??` fallback chains and fourteen `Theme.of(context)` calls left `build()`. `SearchFieldTheme` and `DropdownScrollTheme` are not converted yet
* **CHANGE**: Exported `DropdownAmbientColors`, `ResolvedButtonStyle`, `ResolvedOverlayStyle` and `ResolvedItemStyle`. Additive; existing theme fields are unchanged
* **CHANGE**: `pubspec.yaml`'s description no longer advertises "specialized variants for different content types" — there has been one widget since 2.0.0
* **TEST**: 77 tests, up from 50. Fourteen exercise theme resolution with no widget tree at all
* **DOCS**: `CLAUDE.md` and `documentation/` rewritten around the current architecture. `api_reference.md` documented five classes deleted in 2.0.0 (`BaseDropdownButton`, `BasicDropdownButton`, `TextOnlyDropdownButton`, `DynamicTextBaseDropdownButton`, `DropdownItem`) and never mentioned `FlutterDropdownButton`. Seventeen examples in `theming.md` and `text_configuration.md` called widgets that no longer exist; three passed `theme: DropdownTheme(...)` where a `DropdownStyleTheme` is required

## 2.4.0

* **FEAT**: `FlutterDropdownButton.text()` now accepts a `label` callback, so text mode renders **any** type — not just `String`. Overflow handling, the tooltip and the default search filter all work off the label, so a `List<User>` no longer has to drop to `itemBuilder` and give those up. Omitting `label` for a non-`String` `T` now fails loudly at construction in debug builds instead of throwing a cast error at paint time
* **FEAT**: Added `DropdownOverlayController` and `DropdownOverlaySpec` — hold a controller instead of mixing in `DropdownMixin` to build your own dropdown. It manages the overlay's lifetime, the open/close animation, and the "only one menu open" rule behind nine members rather than twenty-three, and can be tested without a `State`. See `example/lib/pages/domain_type_page.dart`
* **FEAT**: Only-one-menu-open is now scoped to the enclosing `Overlay` rather than to the process, so two dropdowns in two different `Overlay`s no longer close each other
* **FIX**: `FlutterDropdownButton.closeAll()` now accepts `animate`, as `README.md` has documented since 2.2.1. The parameter existed only on `DropdownMixin.closeAll()`; the widget's facade never forwarded it, so the documented call did not compile
* **FIX**: A dropdown menu that is already open now reflects items that change underneath it. Previously an item list arriving asynchronously never appeared until the user closed and reopened the menu
* **FIX**: An open menu now grows when its item list gets longer, and flips above the button when the taller menu no longer fits below. Previously the height was fixed when the menu opened, so new items were pushed below the fold of a scrollbar that appeared for no visible reason
* **DEPRECATED**: `DropdownMixin` is deprecated in favour of `DropdownOverlayController`. It still works — it now delegates to a controller, so mixin-based and controller-based menus share one registry and both answer `closeAll()`. It will be removed in 3.0.0
* **REFACTOR**: `_FlutterDropdownButtonState` holds a controller instead of inheriting from a mixin. Fourteen one-line forwarders and the `static _currentInstance` global are gone
* **REFACTOR**: The filtered item list is derived from the items and the query on read rather than cached in a field, removing four hand-written invalidation sites
* **TEST**: 50 tests, up from 26 — placement geometry, search invalidation, overlay bounds and resizing, label extraction, and the controller itself (unit-tested with no widget tree)

## 2.3.2

* **FIX**: Fixed dropdown menu rendering off-screen when the dropdown lives inside a nested `Overlay` or `Navigator` (side panels, shell routes, embedded views) — the button's position was resolved against the root view while the menu was placed against the enclosing `Overlay`'s origin, shifting the menu by that Overlay's offset. Position and screen-bounds clamping now both use the `Overlay`'s render box
* **FIX**: Fixed `searchable: true` forcing a scrollbar on dropdowns whose items would otherwise fit — the search field's height was subtracted from the item area instead of being added to the overlay height. A 3-item searchable dropdown under default theming no longer scrolls
* **FIX**: Fixed the search query being cleared whenever an ancestor widget rebuilt. `didUpdateWidget` compared `items` by list identity, so any caller passing a derived list (`source.map(...).toList()`, or a non-const literal) reset the query on every rebuild. The filter is now recomputed from the current query, which is correct regardless of the equality semantics of `T`
* **FIX**: Fixed the dropdown overrunning `screenMargin` by `buttonGap` (4px) when opening downward, and reserving a double margin (16px) when shrinking to fit. The menu now keeps exactly one `screenMargin` from the safe-area edge in both cases — a menu constrained for space is ~4px taller than before
* **DEPRECATED**: `DropdownMixin.calculateMenuWidth()` and `DropdownMixin.calculateMenuLeftPosition()` are deprecated in favour of `resolvePlacement()`, which returns the menu's full geometry in one call. They still work and will be removed in 3.0.0
* **REFACTOR**: Extracted all overlay positioning geometry out of `DropdownMixin` into a pure module that takes plain values and returns plain values — no `BuildContext`, no `MediaQuery`, no `State`. `DropdownMixin` remains as the adapter that reads the screen and delegates
* **TEST**: Added the package's first test suite — 26 tests, 17 of which exercise the positioning geometry without mounting a widget

## 2.3.1

* **FIX**: Explicitly set `mouseCursor` on `InkWell` widgets to restore hover cursor behavior on web/desktop after recent Flutter versions changed the default `MaterialStateMouseCursor.clickable` resolution
* **FIX**: Dropdown button now shows `SystemMouseCursors.click` when enabled and `SystemMouseCursors.forbidden` when disabled (matches HTML `<button disabled>` `cursor: not-allowed` convention)
* **FIX**: Dropdown items now consistently show `SystemMouseCursors.click` on hover

## 2.3.0

* **FEAT**: Added `DropdownTheme.disabledBackgroundColor` for the dropdown button background when disabled
* **FEAT**: Added `DropdownTheme.disabledBorder` for the dropdown button border when disabled
* **FEAT**: Added `DropdownTheme.disabledButtonDecoration` for a full custom button decoration when disabled (takes precedence over `disabledBackgroundColor` / `disabledBorder`)
* **FEAT**: Added `TextDropdownConfig.disabledTextStyle` for styling the button text (both value and hint) when disabled — merged over the base `textStyle` / `hintStyle`
* **FEAT**: Added "Disabled Styling" section to the example playground to live-preview the new options (toggle `enabled: false` to see the effect)

## 2.2.1

* **FIX**: Fixed `closeAll()` not resetting trailing icon rotation and internal state — overlay was removed but `_overlayEntry`, animation controller, and `setState` were not handled, leaving the icon in the open (rotated) state
* **FIX**: Fixed `openDropdown()` not closing the previously open dropdown when another dropdown is opened, which could leave orphaned overlays
* **FEAT**: Added `animate` parameter to `closeAll()` — defaults to `true` for animated close with icon rotation, set to `false` for immediate removal before navigation

## 2.2.0

* **FEAT**: Added searchable dropdown support with real-time item filtering
* **FEAT**: Added `searchable` parameter to enable search text field at the top of the dropdown overlay
* **FEAT**: Added `searchFilter` parameter for custom filter logic (required for custom mode, optional for text mode with default case-insensitive contains matching)
* **FEAT**: Added `emptyBuilder` parameter for customizing the empty state when search yields no results
* **FEAT**: Added `SearchFieldTheme` class for comprehensive search field styling (text style, cursor, colors, border, padding, margin, border radius, divider, keyboard type, text input action, and more)
* **FEAT**: Added `search` field to `DropdownStyleTheme` for centralized search field theming
* **FEAT**: Dynamic overlay height — dropdown shrinks to fit filtered results instead of keeping fixed height
* **FEAT**: Auto-reset search query on item selection, outside-tap dismissal, and dropdown reopen
* **FEAT**: Added `rebuildOverlay()` method to `DropdownMixin` for triggering overlay rebuilds
* **CHANGE**: `DropdownMixin` overlay container now uses `BoxConstraints(maxHeight:)` instead of fixed height to support dynamic content sizing

## 2.1.0

* **FEAT**: `TextDropdownConfig.textAlign` now controls item alignment in the dropdown menu and button (previously hardcoded to left-align)
* **FEAT**: Supports `TextAlign.center`, `TextAlign.end`, `TextAlign.right` for both menu items and selected value display

## 2.0.0

* **BREAKING**: Unified all dropdown variants into a single `FlutterDropdownButton<T>` widget
* **BREAKING**: Removed `BasicDropdownButton`, `TextOnlyDropdownButton`, `DynamicTextBaseDropdownButton` (use `FlutterDropdownButton` and `FlutterDropdownButton.text` instead)
* **BREAKING**: Removed `DropdownItem<T>` model class (use `itemBuilder` callback instead)
* **BREAKING**: Removed `BaseDropdownButton` and `BaseDropdownButtonState` (no longer needed as public API)
* **BREAKING**: Removed `TextDropdownRenderMixin` (absorbed into `FlutterDropdownButton`)
* **BREAKING**: Removed deprecated `showSeparator` and `separator` parameters (use `DropdownTheme.itemBorder` instead)
* **FEAT**: `FlutterDropdownButton<T>()` default constructor with `itemBuilder` for custom widget rendering (replaces `BasicDropdownButton`)
* **FEAT**: `FlutterDropdownButton<T>.text()` named constructor for text-only dropdowns (replaces both `TextOnlyDropdownButton` and `DynamicTextBaseDropdownButton`)
* **FEAT**: `width` is now optional in text mode — omit for content-based dynamic width, provide for fixed width
* **FEAT**: All features (leading, disableWhenSingleItem, expand, etc.) available in a single widget
* **FEAT**: `FlutterDropdownButton.closeAll()` static method for manual dropdown cleanup
* **MIGRATION**: `BasicDropdownButton(items: [DropdownItem(value: v, child: w)])` → `FlutterDropdownButton(items: [v], itemBuilder: (item, isSelected) => w)`
* **MIGRATION**: `TextOnlyDropdownButton(items: items, width: 200)` → `FlutterDropdownButton.text(items: items, width: 200)`
* **MIGRATION**: `DynamicTextBaseDropdownButton(items: items)` → `FlutterDropdownButton.text(items: items, disableWhenSingleItem: true)`

## 1.6.1

* **FIX**: Removed disabled opacity override that forced 0.6 opacity on single-item dropdowns, preserving original button styling

## 1.6.0

* **BREAKING**: `TextOnlyDropdownButton.width` is now required (fixed-width dropdown by design)
* **BREAKING**: Removed `minWidth`, `maxWidth`, `expand` from `TextOnlyDropdownButton` (use `DynamicTextBaseDropdownButton` for content-based width)
* **BREAKING**: Removed `width` from `DynamicTextBaseDropdownButton` (content-based width by design, use `minWidth`/`maxWidth` for constraints)
* **FEAT**: Added `disableWhenSingleItem` parameter to `DynamicTextBaseDropdownButton` for toggling single-item non-interactive mode (defaults to true)
* **FEAT**: Added `showTrailing` getter to `BaseDropdownButtonState` allowing subclasses to conditionally hide the trailing icon
* **FEAT**: `DynamicTextBaseDropdownButton` now auto-selects the only item when in single-item disabled mode
* **FIX**: Fixed `DynamicTextBaseDropdownButton` single-item mode not blocking tap interactions (was using `widget.enabled` instead of `isEnabled`)
* **FIX**: Fixed disabled opacity check using `widget.enabled` instead of `isEnabled`, causing incorrect visual state for dynamic dropdowns
* **FIX**: Removed duplicated `build()` and `_applyWidthConstraints()` in `DynamicTextBaseDropdownButton` (was missing `expand` support)
* **REFACTOR**: Extracted common text rendering logic into `TextDropdownRenderMixin` to eliminate duplication between `TextOnlyDropdownButton` and `DynamicTextBaseDropdownButton`
* **REFACTOR**: Replaced example showcase app with interactive Playground for live parameter configuration

## 1.5.5

* **FIX**: Fixed overlay removal crash when dropdown is closed during widget disposal by adding mounted check and error handling to closeDropdown()

## 1.5.4

* **FIX**: Fixed scroll gradient direction - top gradient now properly fades from opaque to transparent downward, bottom gradient fades from transparent to opaque downward

## 1.5.3

* **FIX**: Fixed ScrollbarTheme colors not being applied by correcting widget hierarchy (ScrollbarTheme must wrap Scrollbar, not vice versa)

## 1.5.2

* **PERF**: Improved scroll performance with many items by using ListView.builder (lazy loading) and ClampingScrollPhysics (removes bouncing effect)
* **FIX**: Fixed dropdown height calculation to account for safe areas (status bar, navigation bar, home indicator)

## 1.5.1

* **FIX**: Fixed dropdown overlay remaining visible after screen transitions by immediately removing overlay on dispose without animation
* **FIX**: Added safe error handling for overlay removal to prevent crashes when overlay has already been removed
* **FEAT**: Added DropdownMixin.closeAll() static method for manual dropdown cleanup before navigation or other actions

## 1.5.0

* **BREAKING**: Extracted tooltip styling from TextDropdownConfig into new TooltipTheme class for better separation of concerns
* **BREAKING**: Removed tooltip styling properties from TextDropdownConfig (tooltipBackgroundColor, tooltipTextColor, tooltipTextStyle, tooltipDecoration, tooltipBorderRadius, tooltipBorderColor, tooltipBorderWidth, tooltipShadow, tooltipPadding, tooltipMargin, tooltipConstraints, tooltipTextAlign)
* **FEAT**: Added TooltipTheme class for centralized tooltip visual styling
* **FEAT**: Added tooltip field to DropdownStyleTheme to include TooltipTheme alongside DropdownTheme and DropdownScrollTheme
* **CHANGE**: TextDropdownConfig now only controls tooltip behavior (enableTooltip, tooltipMode, durations, positioning, trigger modes)
* **MIGRATION**: Move tooltip styling properties from TextDropdownConfig to TooltipTheme in DropdownStyleTheme

## 1.4.8

* **FEAT**: Added itemBorder property to DropdownTheme for applying borders to individual dropdown items (commonly used for bottom borders between items)
* **FEAT**: Added excludeLastItemBorder property to DropdownTheme to exclude border from the last item (defaults to true for clean design)
* **DEPRECATED**: showSeparator and separator parameters are now deprecated in favor of itemBorder (will be removed in 2.0.0)

## 1.4.7

* **FEAT**: Added minMenuWidth parameter to set minimum dropdown menu width independently from button width
* **FEAT**: Added maxMenuWidth parameter to set maximum dropdown menu width independently from button width
* **FEAT**: Added menuAlignment parameter (left/center/right) to control menu positioning when menu is wider than button

## 1.4.6

* **FEAT**: Added showSeparator and separator parameters to display customizable dividers between dropdown items (defaults to Divider widget)

## 1.4.4

* **FIX**: Fixed hover color not visible when selectedItemColor is set by changing Container to Ink widget for proper Material effect layering

## 1.4.3

* **FEAT**: Added trailing parameter support to DynamicTextBaseDropdownButton (static display for single-item mode, rotation animation for multi-item mode)

## 1.4.2

* **FEAT**: Added buttonHoverColor, buttonSplashColor, and buttonHighlightColor to DropdownTheme for controlling dropdown button InkWell interaction colors
* **FEAT**: Added buttonHeight property to DropdownTheme for independent button content height control from iconSize, with automatic overflow prevention
* **FEAT**: Added trailing parameter to BaseDropdownButton for customizing the dropdown arrow icon with automatic rotation animation

## 1.4.1

* **FEAT**: Added hover cursor support - dropdown button now shows click cursor on mouse hover using InkWell

## 1.4.0

* **BREAKING**: Changed `leadingBuilder` to `leading` and `selectedLeading` parameters in DynamicTextBaseDropdownButton for better performance and simpler API
* **BREAKING**: Renamed `leadingWidgetPadding` to `leadingPadding` in DynamicTextBaseDropdownButton for consistent naming
* **PERF**: Optimized AnimatedBuilder in DropdownMixin to prevent unnecessary rebuilds of overlay content during animations (60+ rebuilds eliminated per dropdown open/close)
* **PERF**: Changed leading widget API from builder function to direct widget parameters, eliminating redundant widget creation (126+ widget creations reduced to 2 per dropdown)

## 1.3.3

* **FEAT**: Added expand parameter to automatically wrap dropdown in Expanded widget for flex layouts, with spaceBetween alignment when expanded

## 1.3.2

* **FEAT**: Added smart tooltip support with overflow detection, auto-positioning, and extensive customization options (background color, border, shadow, text styling, trigger modes, and timing controls)
* **FIX**: Fixed text and icon vertical alignment issue by adding centerLeft alignment to text and center crossAxisAlignment to Row, and fixed mainAxisAlignment to use spaceBetween when width is fixed

## 1.3.1

* **FEAT**: Added leadingBuilder property to DynamicTextBaseDropdownButton for displaying custom widgets (icons, images) before text
* **FEAT**: Added leadingWidgetPadding property to DynamicTextBaseDropdownButton for controlling leading widget spacing

## 1.3.0

* **FEAT**: Added DynamicTextBaseDropdownButton widget that adapts behavior based on item count (non-interactive when single item, normal dropdown when multiple items)
* **FEAT**: Added hideIconWhenSingleItem property to DynamicTextBaseDropdownButton for controlling icon visibility in single-item mode
* **FEAT**: Added interactive example demo with real-time item add/delete functionality
* **FIX**: Fixed dropdown button height consistency issue by wrapping Text and Icon in SizedBox with fixed height based on iconSize
* **FIX**: Fixed mainAxisAlignment from spaceBetween to start to allow button width to fit content size within maxWidth constraint

## 1.2.3

* **FEAT**: Added scrollToSelectedItem property to automatically scroll to the currently selected item when dropdown opens (defaults to true)
* **FEAT**: Added scrollToSelectedDuration property for controlling scroll animation duration (null for instant jump, duration value for smooth animation)
* **FEAT**: Improved scrollable dropdown UX by automatically positioning selected items in view when there are many items

## 1.2.2

* **FEAT**: Added icon property to DropdownTheme for customizing dropdown arrow icon (supports any IconData)
* **FEAT**: Added iconSize property to DropdownTheme for controlling dropdown icon size
* **FEAT**: Added iconDisabledColor property to DropdownTheme for customizing icon color in disabled state
* **FEAT**: Added iconPadding property to DropdownTheme for controlling spacing between selected value and icon
* **FEAT**: Added overlayPadding property to DropdownTheme for controlling internal spacing of the dropdown menu container

## 1.2.1

* **FIX**: Fixed dropdown overlay border rendering issue by removing Material borderRadius that conflicted with Container border decoration
* **FIX**: Fixed dropdown icon not updating on open/close state change and added rotation animation
* **REFACTOR**: Reorganized theme files into theme/ subdirectory for better code organization

## 1.2.0

* **FEAT**: Added thumbWidth and trackWidth properties to DropdownScrollTheme for independent scrollbar thumb and track width control
* **FEAT**: Added iconColor property to DropdownTheme for customizing dropdown arrow icon color
* **FIX**: Fixed dropdown overlay content clipping issue with border radius by adding clipBehavior to Material widget
* **FIX**: Changed theme parameter type from Object? to DropdownStyleTheme? for better type safety
* **FIX**: Fixed dropdown menu height calculation to properly account for itemMargin and border thickness, preventing unnecessary scrollbars

## 1.1.0

* **FEAT**: Added DropdownScrollTheme for customizing scrollbar appearance
* **FEAT**: Added DropdownStyleTheme as main theme container for dropdown and scroll themes
* **FEAT**: Support for custom scrollbar colors, thickness, radius, and visibility options
* **REFACTOR**: Updated example app with feature-based showcase and style selector

## 1.0.1

* **FEAT**: Added itemMargin property to DropdownTheme for controlling spacing between dropdown items
* **FEAT**: Added itemBorderRadius property to DropdownTheme for individual item border radius styling
* **FEAT**: Added hover effect support to TextOnlyDropdownButton with InkWell integration
* **FIX**: Fixed hover effect positioning to respect itemMargin boundaries for consistent visual feedback
* **REFACTOR**: Added BaseDropdownButton abstract class to reduce code duplication between dropdown variants
* **FEAT**: Exported BaseDropdownButton for creating custom dropdown implementations

## 1.0.0

* **FEAT**: Initial release with BasicDropdownButton and TextOnlyDropdownButton widgets
* **FEAT**: Smart dropdown positioning - automatically opens upward when insufficient space below
* **FEAT**: Dynamic height adjustment to prevent screen overflow
* **FEAT**: OverlayEntry-based dropdown with smooth animations and outside-tap dismissal
* **FEAT**: Dynamic width support (width, maxWidth, minWidth parameters)
* **FEAT**: Shared DropdownTheme system for consistent styling across variants
* **FEAT**: TextDropdownConfig for precise text overflow control (ellipsis, fade, clip, visible)
* **FEAT**: Multi-line text support and custom text styling
* **FEAT**: Generic DropdownItem model supporting any widget content
* **FEAT**: DropdownMixin for shared functionality across dropdown variants
* **FEAT**: Comprehensive example app with multiple dropdown demonstrations