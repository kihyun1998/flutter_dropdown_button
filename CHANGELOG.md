# Changelog

## 4.2.0

What is on screen reached everyone except the people who cannot see it. The trigger announced its current value and nothing about being a control; the chosen row was distinguished from its neighbours by `DropdownItemTheme.selectedColor` and by nothing else. The checklist had been doing this correctly since 3.1.0 — `Semantics(checked:)` on the row — and the single-select path simply never got the same treatment.

Two contracts on `DropdownOverlayController` also rested on the same wrong idea — that the overlay entry's lifetime is the same thing as the menu being open. It is not: the entry outlives the close by exactly one animation, and that animation is not guaranteed to run. Both bugs are invisible through `FlutterDropdownButton` and `FlutterMultiSelectDropdown`, because the dismiss barrier keeps the pointer away from the trigger (#95); they surface on the third-party controller path the README advertises as "Build Your Own".

And the empty state kept a smaller half-truth of its own: `emptyBuilder`, documented as the builder for when the menu has nothing to show, was reachable only through a search that matched nothing — the emptiest menu of all, an empty source list, called nothing and opened as a chrome-only sliver (#96).

A menu also turned out to be placed once and then forgotten. Scroll the page behind an open one and the content moved while the menu stayed — floating over whatever had slid underneath it, anchored to nothing, on a finger and a mouse wheel alike. That one *looked* like a barrier problem and was not: the fix touches neither the barrier nor hit-testing, and the obvious barrier-shaped remedy would have stopped the background scrolling altogether (#103).

The dismiss barrier turns out to have been charging for something the package advertises. Putting several dropdowns on a page and having only one open at a time is a documented feature, but swapping between them cost two taps, because the barrier joined the gesture arena ahead of the trigger the user was aiming at. Two of this release's tests had a retry branch written around exactly that (#95).

### `close()` finishes without a running ticker (#106)

* **FIX**: an open menu no longer strands itself over a pushed route. `close()` gated teardown on `_animation.reverse().then(…)`, and `ModalRoute` disables the `TickerMode` of the route below it — so the reverse started and never advanced. Measured: `anim=reverse v=1.00` unchanged after two seconds, the entry still mounted *above the new page*, and `page2Taps=0` on three consecutive taps. The page was dead until the user navigated back. Reproduced with no `Navigator` in the tree at all — a plain `TickerMode(enabled: false)` is the whole condition, so any caller who disables ticking hit it
* **FIX**: `onOpenStateChanged(false)` now arrives in that case. It rode on the same teardown, so an owner drawing its trigger from the callback stayed drawn as open
* **CHANGE**: the close animation is decoration, not the mechanism. A timer settles the teardown at `animationDuration` whichever way the ticker goes, and whichever of the two arrives first wins. Querying the tree instead was not available: `TickerMode.of` is deprecated after 3.35 and this repo's `flutter analyze` gate exits 1 on a single info, while `TickerMode.valuesOf` does not exist at the `>=3.32.0` floor — both CI jobs close that door from opposite sides

### `open()` is no longer dropped mid-close (#107)

* **FIX**: `closeAll()` immediately followed by `open()` shows the menu. `open()`'s guard is `if (isOpen) return`, and `isOpen` is `_entry != null`, which stays true for the whole close animation — so the call was a silent no-op and the close then completed. The caller asked for a menu and got none. A close in flight is now taken back instead
* **TEST**: `overlay_close_contract_test.dart` pins both, including the route case end to end. Discriminating power confirmed by reverting `lib/`: five of six go red, and the one that stays green is the guard against "fixing" this by never closing at all

### The trigger and the chosen row reach the semantics tree (#88)

* **FIX**: the trigger announces `button` and its enabled state. Measured before: `flags=[isFocusable] actions=[tap, focus]` — no role at all, and a *disabled* dropdown emitted `flags=[] actions=[]`, indistinguishable from something decorative. It is one `Semantics` on the node the `InkWell` already annotates, so the merged `semanticsLabel` contract is unchanged. Both widgets get it; they share the shell
* **FIX**: a single-select row announces `selected`. Before, the three rows of an open menu were byte-identical in the semantics tree whichever one was the value. It is attached in the presentation, not the shell — the shell does not know what selection is, so it cannot know whether "chosen" means `selected` or `checked`; that word is the presentation's, one per cardinality
* **FIX**: `anchorBuilder`'s bare anchor was already announcing the role, and the reported direction had it backwards — it was the chromed path that was silent. The dartdoc and `documentation/api_reference.md` both credited the role to the ink well being "restored"; an `InkWell` announces no role in either path (`material/ink_well.dart` declares only `onTap`/`onLongPress`). What it does contribute is focusability, which the bare path lacks
* **CHANGE**: if your `itemBuilder` declares `selected` itself — a hand-rolled workaround for this bug — **delete it**. Two `Semantics` in one merge group cannot both set the same field, so the caller's now becomes a node of its own: measured, the row keeps `selected` and its tap action but loses its *label*, while the labelled node loses its actions. Any other property a caller declares (a label, a hint) merges as before
* **TEST**: asserted at the semantics tree, never the render tree — every assertion here passes under `find.text` while the tree says nothing. `containsSemantics`, matching `multi_select_presentation_test.dart`'s existing choice: an exhaustive matcher pins the host platform, because `Focus` emits its focus action only off-iOS. Discriminating power confirmed by reverting `lib/` — six of eight go red, and the two that stay green are the two labelled guards

### A menu stops accepting taps when the control does (#89)

* **FIX**: a **disabled** dropdown accepted a selection. Measured: disabling while the menu was open left it open, the trigger announced itself disabled, the rows kept their tap action, and tapping one changed the caller's value. Worse for the checklist — `closeOnTap` is false there, so 3 of 3 taps landed and the menu never went away. Rows are now gated on `enabled`, and becoming disabled **closes** the menu: it is part of the control, and one left behind offers options that no longer work. Reachable without touching `enabled` at all, through `disableWhenSingleItem` and a list that shrinks
* **FIX**: the same was true of an **ordinary close**, which is the general case and was found by the completeness pass on the first fix. Dismiss the menu and a tap landing on a row that had not finished animating out still handed you the value you had just cancelled; tapping a second row while the first tap's close played out selected twice. A row now refuses a tap in three situations rather than one — the control is disabled, the menu is animating out (`isOpen` is the entry's existence, so it stays true throughout and cannot answer this), and the menu is already gone but its rows are mounted for one more frame. That last one is reachable from outside the package, through `animationDuration: Duration.zero` and through `DropdownOverlayController.closeAll(animate: false)`, neither of which ever reports a reverse: measured, an instant close let a second row through and selected twice
* **FIX**: a disabled dropdown's **search field** kept focus and accepted typing for the length of the close. The query was discarded on teardown, so nothing escaped, but the soft keyboard sat over a disabled control
* **FIX**: `SearchFieldTheme` never filled `disabledBorder`, which nothing had reached before because the field was never built disabled. An unfilled slot is not "no styling" — Flutter falls through to its own outline default — so a caller who set `border` would have watched their colour be replaced the moment the field went disabled. It now resolves to the same edge as the enabled one
* **CHANGE**: a disabled row now carries `enabled: false` in the semantics tree rather than merely losing its tap action. Dropping the action alone left a node still announcing a chosen state while saying nothing about being unavailable — half a node, which `docs/adr/0001` rule 3 exists to forbid. It stays focusable, unlike the trigger; rule 1's other half, that the row carries no role, is still open
* **TEST**: asserted at `onChanged`, not at the tree — this is a functional contract, and the tree was only where it first became audible. The tests pump a **single frame** after the disable on purpose: the overlay is its own element subtree, so for exactly one frame the rows still hold the callbacks they were built with, and a test that pumped to settle would never see the window it exists for. Discriminating power: reverting `lib/` takes nine of eleven red, and the two that stay green are the two labelled guards

### The dismiss barrier leaves the semantics tree (#90)

* **FIX**: an open menu put a **screen-sized node carrying `tap`** into the semantics tree, with no label and no role, and the menu's own rows hung underneath it as its children. A non-interactive empty state merged into it and named it, so a screen reader's only target became one screen-sized button reading "No results found" whose activation dismissed the menu. Measured on an 800×600 view: `#5 800x600 label="No results found" acts=[tap]`. The barrier is a gesture, not a control, so it now declares nothing — `GestureDetector.excludeFromSemantics`, which drops only the detector's own annotation. Hit-testing is untouched; the menu closes on an outside tap exactly as before
* **CHANGE**: nothing was announced in its place, and nothing needed to be. The trigger stays in the tree while its own menu is open and still carries `tap` — measured, activating it through the semantics API closes the menu — so assistive technology dismisses by activating the control that opened it. Labelling the barrier instead was measured to produce *two* screen-sized nodes, and `ExcludeSemantics` (one word away, opposite blast radius) would have deleted the menu from the tree along with it

### One trigger, one contract (#91)

* **FIX**: the trigger now announces whether its menu is **open**. Both anchor paths carry it. `isOpen` was already handed to `anchorBuilder` as "the one thing a caller cannot read for itself" — a screen-reader user is exactly that caller. It tracks the overlay entry, so it stays true for the close animation, which is deliberate: the menu is still on screen and the chevron a caller draws from the same flag is still turned
* **FIX**: a **bare anchor is now focusable and keyboard-activatable**. It was a plain `GestureDetector` — measured `actions=[tap]`, no `isFocusable`, no focus action — so a keyboard-only user could not open one at all, while the chromed path has had both since forever from the `Focus` inside its `InkWell`. It now wraps a `FocusableActionDetector` binding `ActivateIntent` and `ButtonActivateIntent`, the same pair `InkWell` binds; the second is what Enter dispatches on the web. Measured: Tab reaches it, Enter and Space open it, Enter closes it again, and focus returns to the anchor when the menu closes
* **CHANGE**: consequently **a bare anchor is a tab stop where it was not**. In the embedded-field layout the mode exists for — `[All ▾] │ search…` — that is one more stop inside the field. It is the deliberate trade for the control being reachable at all; a disabled anchor is not a stop, and under `NavigationMode.directional` it stays reachable so a D-pad user can hear that it is unavailable — the same rule `InkWell` follows
* **CHANGE**: the docs claimed "keyboard navigation" for the anchored menu, in bare mode and generally. Narrowed to what exists: the **anchor** is focusable and activatable; the **open menu** is not navigated by arrow keys and Escape does not close it. The 4.0.0 entry that made the same claim is published and is left alone — this supersedes it

### Scrolling behind an open menu dismisses it (#103)

* **FIX**: an open menu no longer strands itself when the content around it scrolls. The menu is placed once and never re-measured, so the page moved while the menu stayed — measured `listScrolledBy=160.0 / menuStillOpen=true / movedBy=0.0`, leaving it open over unrelated content with its anchor gone. It closes as the surrounding content starts moving. **Not a touch-only problem**: a desktop mouse wheel produced the identical three numbers, so a fix that only handled drags would have left desktop and web exactly as they were
* **FIX**: **every** scrollable the anchor sits inside is watched, not just the nearest. With the anchor in an inner list, scrolling the *outer* page carries it just as far while a nearest-only subscription hears nothing — measured 130px of outer scroll with the menu left stale. This is a deliberate step past the reference implementation, which subscribes to one level
* **FIX**: a **programmatic** scroll dismisses too. The first cut watched `isScrollingNotifier`, which reports a scroll *activity* — and `jumpTo` goes idle, forces the pixels, and goes idle again, so the flag never turns. Measured: a 300px jump left the menu open and stranded, exactly the state this fix exists to remove. It watches the position itself now, which `forcePixels` notifies. This covers `ScrollController.jumpTo`, `PageController.jumpToPage`, and `Scrollable.ensureVisible`, whose duration defaults to zero and takes the same branch
* **FIX**: the dismissal survives its scroll position being replaced. A `Scrollable` rebuilds its position from its own `didChangeDependencies` — a theme change, a `devicePixelRatio` change, a window dragged between monitors — and a subscription taken once at open time was left holding the disposed object, with the dismissal silently dead for the rest of that menu's life. `DropdownOverlayController.refreshScrollables` is new and additive; the widgets call it for you
* **CHANGE**: a long menu still scrolls **itself** without closing. The subscription is taken from the anchor's context rather than from inside the overlay, so the menu's own list is not one of the scrollables being watched — the trap this design exists to avoid
* **TEST**: `scroll_dismiss_test.dart` pins the drag, the wheel, the outer-list case, and the three things the dismissal must not touch: the menu's own scrolling, a page with no scrollable at all, and a scroll with nothing open. Discriminating power confirmed by reverting `lib/` — the three dismissal tests go red and the guards stay green

Not addressed, and deliberately: the menu still does not **follow** its anchor. Tracking it means re-measuring every frame or linking layers, the one choice in this package with a real performance cost, and closing is the trade taken instead.

### Swapping dropdowns takes one tap (#95)

* **FIX**: with a menu open, tapping a second dropdown's trigger now opens it. The first tap was spent dismissing and the second did the opening, measured `tapsToOpenB=2`. The dismiss barrier covers the whole `Overlay`, and although it is `translucent` — so the trigger underneath really does receive the pointer — a gesture arena has one winner, and the barrier joins it first. The barrier now recognises a registered sibling trigger and declines to compete for that pointer, leaving the anchor to win on its own. Single-open coordination is untouched: `open()` still closes the neighbour, so the invariant stays owned by the code that already owned it
* **CHANGE**: a long press over another dropdown's trigger opens it, where it dismissed before. The anchor receives the gesture now, and an anchor treats a long press as a press
* **CHANGE**: the exception is not scoped to one `Overlay` — a trigger in a nested `Overlay` is recognised too, so a dropdown in a side panel is reachable in one tap from a menu open in the root. The single-open rule remains per-`Overlay` as before, and the two are independent
* **FIX**: recognition is by the live hit path rather than by the trigger's rectangle. A rectangle cannot see clips, transforms, `IgnorePointer`, `Offstage` or occlusion: measured, a dropdown behind a dialog reports a box byte-identical to its uncovered one, so a geometric test would have sent that tap to the dialog's own barrier and dismissed the dialog. None of those is a sibling trigger now; the barrier keeps the tap and dismisses, as before
* **CHANGE**: `DropdownOverlayController` gains `triggerEnabled`, set by the owning widget from its own `enabled`. A **disabled** anchor is still hit-tested — `InkWell` is unconditionally opaque — so without this the barrier would have stood down over one, leaving the tap claimed by nobody and the menu open where it dismisses today. Additive; third parties driving their own controller get the fix without changing anything, and may set it to keep a disabled anchor of their own honest
* **TEST**: `sibling_trigger_test.dart` pins the one-tap swap (mouse as well as touch — a veto scoped to `PointerDeviceKind.touch` passes every widget test in this suite while doing nothing on desktop), the disabled-sibling guard, the mid-close window, and that everything *else* behind a menu still costs two taps. The two-tap retry branches in `overlay_lifecycle_test.dart` and `multi_select_test.dart` are gone — they were the bug's own alibi. Discriminating power confirmed by reverting `lib/`: both go red

### The empty state reaches an empty list (#96)

* **FIX**: `emptyBuilder` now runs when the source list itself is empty. It was reachable only through the search path — `items.isEmpty && searchable && query.isNotEmpty` — so the emptiest menu of all rendered a chrome-only sliver (measured 200×2 without search, 200×50 with) and called nothing, whichever builder the caller had supplied. The menu now reserves one item's height for the state, so it opens onto a readable card
* **CHANGE**: a supplied `emptyBuilder` fires in states it could not reach before, with the query `""` when the list itself is empty — a builder written against the old "search yields no results" doc wording sees a new argument value. Interpolating the query unconditionally (the pattern this package's own docs used to teach) renders with an empty string there; branch on `query.isEmpty` for a dedicated message
* **FIX**: without a builder, the default text now matches the situation: "No results found" only while a query stands, "No items" when the list is empty — the old text claimed a search had happened when none had
* **FIX**: the builder no longer sees a query the user cannot see or edit. The query deliberately survives `searchable` flipping off (so flipping it back on keeps the caret), but the empty state reported it even while the field was gone; it now reports `""` unless the field is shown
* **FIX**: on the 3.32.0 floor, the empty-state message merged into the **search field's** semantics node — a screen reader read the input itself as "No results found" (measured: one 200×146 node carrying `setText`/`setSelection`/`focus`). The state is now its own semantics container on every supported version, and the claim "the message is a message, not an input" is pinned at both ends of the CI matrix
* **TEST**: the four-row reachability table from #96 (searchable × query × empty list), the stale-query guard, the checklist pass-through, and the placement rule that an empty menu reserves its empty-state height — none of it covered before. Discriminating power confirmed by reverting `lib/`: all six behavior tests go red



* **CHANGE**: the test suite is no longer in the published archive — `test/.pubignore`, the same treatment `docs/` and `tool/` already had. It is how the package is developed, not how it is used, and no consumer runs it. Archive: 526 KB → 475 KB compressed. `CLAUDE.md` deliberately stays: excluding a root file needs a root `.pubignore`, which disables `.gitignore`-based listing for the root directory, and this repo has already shipped `coverage/lcov.info` once with zero dry-run warnings

## 4.1.0

The second half of the embedded-field pattern 4.0.0's bare anchor opened. `anchorBuilder` decoupled what the anchor *renders*; a menu embedded inside a wider field still positioned and sized against the compact anchor's own box, so it dropped from mid-field and left-aligned to the little `[All ▾]` segment. `positioningKey` decouples what the menu *positions against*.

* **FEAT**: `positioningKey` — an optional `GlobalKey` on `FlutterDropdownButton` (both constructors) and `FlutterMultiSelectDropdown`. Wrap the whole field in a widget carrying the key and pass it here; the menu then measures *that* box instead of the anchor — dropping below it, left-aligning to it, and defaulting to its width — while the anchor keeps drawing and toggling where it sits. `menuAlignment`, `minMenuWidth` and `maxMenuWidth` measure against the box too
* **FEAT**: additive and orthogonal. It is a parameter on the shared `DropdownMenuShell`, not a new constructor, so it composes with text mode, custom mode, the checklist and the bare anchor alike — and with a normal chromed button, unrestricted (no assert). The placement engine is untouched: only which `RenderBox` is measured changes, and the existing width/alignment/flip logic yields the field-relative result for free
* **CHANGE**: the box is measured on every menu build, not tracked per frame — a box that moves *while the menu is open* is not followed, the same contract the anchor already held. It must live in the same `Overlay` coordinate space as the anchor
* **TEST**: placement is asserted at the overlay's `Positioned` — the menu's width, left and top measure the outer field, not the compact anchor — with control tests pinning the anchor-relative default, a runtime-toggle test proving the key is honoured mutably, and the checklist composition. Discriminating power confirmed by reverting the measure-key swap (the field-relative tests go red, the controls stay green)

## 4.0.0

Breaking on two axes, plus one long-promised removal. The multi-select checklist now draws its boxes with the [`flutter_checkbox`](https://pub.dev/packages/flutter_checkbox) package instead of Flutter's built-in `Checkbox` (`DropdownCheckboxTheme` redesigned around it), and the monolithic `DropdownTheme` is split into three surface sub-themes. The **SDK floor is unchanged** (`>=3.32.0`): `flutter_checkbox` `0.3.1` needs only Flutter 3.27. This release also folds in the bare-anchor feature, which was never published on its own.

### `DropdownTheme` → `button` / `overlay` / `item` sub-themes

* **BREAKING**: the single `DropdownTheme` (~28 fields covering the button face, the menu container and the rows at once) is removed. `DropdownStyleTheme`'s `dropdown` slot is replaced by three sibling slots — `button` (`DropdownButtonTheme`), `overlay` (`DropdownOverlayTheme`), `item` (`DropdownItemTheme`) — beside the `scroll` / `tooltip` / `search` / `checkbox` slots that were always separate. Each sub-theme resolves itself. Fields keep their meaning but drop the surface prefix (`buttonHoverColor` → `button`'s `hoverColor`, `itemPadding` → `item`'s `padding`, `overlayPadding` → `overlay`'s `padding`, `selectedItemColor` → `item`'s `selectedColor`, `itemBorderRadius` → `item`'s `borderRadius`, and so on). Full map in `documentation/migration.md`
* **CHANGE**: the shared `borderRadius`, `backgroundColor` and `border` — one field each, formerly driving two surfaces at once — are now owned per surface. `overlay.backgroundColor` colours the menu; `button.backgroundColor` (**new**) colours the button; neither reaches across. This is the coupling #75's bare mode exposed (a `backgroundColor` that painted the menu, not the button), resolved by construction
* **CHANGE**: `DropdownButtonTheme` is **inert in bare mode** (`anchorBuilder`) — the caller draws the anchor, so the button box it styles does not exist. Overlay, item, scroll, search and tooltip theming still apply. The type now makes that boundary explicit
* **TEST**: every field moves 1:1, the resolve logic is preserved verbatim, and the existing widget tests (which assert the rendered button/item `BoxDecoration`s) pass with the same assertions — the split is behaviour-preserving

### Multi-select checkbox → `flutter_checkbox`

* **BREAKING**: `DropdownCheckboxTheme` is rebuilt around `flutter_checkbox`'s `CheckboxStyle`. **Removed** — the Material-`Checkbox` concepts the new box has no equivalent for: `fillColor` (`WidgetStateProperty`), `side` (`BorderSide`), `shape` (`OutlinedBorder`), `materialTapTargetSize`, `visualDensity`. **Kept**: `activeColor`, `checkColor`, `mouseCursor`. **Added**: `inactiveColor`, `borderColor`, `borderWidth`, `borderRadius`, `size`, `checkStrokeWidth`, `checkScale`, and `shape` now typed `CheckboxShape` (an enum: `rectangle` / `circle`). `resolve()` now returns a `CheckboxStyle`, and the `ResolvedCheckboxStyle` class is removed. Migration map in `documentation/migration.md`
* **FEAT**: the box is a `FlutterCheckbox`, drawn `onChanged: null` but left `enabled: true` — presentational (a tap falls through to the row) **without** being greyed. This deletes the `activeColor` → `fillColor` workaround 3.2.0 needed: Material forced an `onChanged: null` box into its disabled state and dropped a plain `activeColor`; `FlutterCheckbox` does not, so the accent is read straight (`CheckboxStyle.activeColor`)
* **FEAT**: `CheckboxShape` and `CheckboxStyle` are re-exported from the package barrel, so `DropdownCheckboxTheme(shape: CheckboxShape.circle)` needs no extra import
* **CHANGE**: the box's semantics are still excluded and the row still carries `checked`. Unlike Material, `FlutterCheckbox(onChanged: null)` announces `enabled: true` — so the row no longer risks a *dimmed* announcement leaking from the box — but the box still emits its own `checked` node, which the exclusion drops to keep the row the single source of the checked state
* **MIGRATION**: `side` → `borderColor` + `borderWidth`; `shape: RoundedRectangleBorder(borderRadius: …)` → `shape: CheckboxShape.rectangle` + `borderRadius`; `fillColor` → `activeColor` (checked) / `inactiveColor` (unchecked). `materialTapTargetSize` and `visualDensity` have no equivalent — the box sizes via `size`
* **TEST**: 285 tests at 100% line coverage (1102 lines) across the whole release. The box is asserted presentational-but-not-greyed (`onChanged` null, `enabled` true), the accent reaches `style.activeColor` directly, and the semantics contract (row `checked`, never *disabled*) is held at the semantics tree

### Bare anchor (folds in the unreleased 3.3.0)

* **FEAT**: `anchorBuilder` — a **bare anchor** mode on `FlutterDropdownButton` (both constructors) and `FlutterMultiSelectDropdown`. Supplying `Widget Function(BuildContext, bool isOpen)` drops the entire button box — background, border, fixed width, padding, ink and trailing icon — and hangs the same anchored overlay off the widget you return. The point is to embed the dropdown *inside* another field, `[All ▾] │ search…`, where a button's own chrome nests a box inside a box; the only clean alternative was a hand-rolled `PopupMenuButton` that threw away this package's theming, keyboard navigation and searchable menu. Only the button face becomes the caller's — the menu is untouched
* **FEAT**: the builder is handed `isOpen`, **not a label**. `isOpen` is the one thing a caller cannot read for itself, and drives an inline chevron (`AnimatedRotation(turns: isOpen ? 0.5 : 0.0, …)`); a label the caller already holds, in the `value` or `selected` it drew the anchor from. Passing one would leak a text-mode notion into `DropdownMenuShell`, which does not know what an item says — the invariant that lets one shell back both widgets. The dropped ink well's button role is restored with `Semantics(button: true)`
* **FEAT**: the field lives on the shell and both public widgets read it, so bare mode composes with text mode, custom mode and the checklist alike — it is orthogonal to what an item renders as, and is a parameter rather than a `.bare()` constructor for exactly that reason. A constructor would have had to pick `itemBuilder` or `label`, leaving the other settable-but-dead — the shape 3.0.0 spent a major version deleting
* **FEAT**: the button-box params `anchorBuilder` replaces — `width`, `minWidth`, `maxWidth`, `expand`, `trailing` — **assert** when combined with it, rather than being silently ignored. A bare anchor is compact by design and the menu takes its width from it, so set `minMenuWidth` (a *menu* width, still allowed) to give the menu a usable width

### Also removed

* **BREAKING**: `CustomItemPresentation.items` — deprecated in 3.1.0 (read by nothing since), removed now as its dartdoc promised. Only code building a presentation by hand is affected: drop the argument. See `documentation/migration.md`

## 3.2.0

Additive. One new optional field; nothing removed, nothing else changed.

* **FEAT**: `DropdownCheckboxTheme` — styles the checkbox on each row of a `FlutterMultiSelectDropdown`, reached through the new `checkbox` slot on `DropdownStyleTheme`. It carries the eight fields that actually render on the row's box: `activeColor`, `fillColor`, `checkColor`, `side`, `shape`, `materialTapTargetSize`, `visualDensity`, `mouseCursor`. The box is drawn `onChanged: null` with its semantics excluded, so an interactive checkbox's focus/hover/splash fields are absent by construction rather than settable-but-dead. `mouseCursor` is kept because its `MouseRegion` is installed regardless of interactivity — so it lets you match the box's cursor to the row's
* **FEAT**: `activeColor` — the fill of a **checked** box — is the common case. The box is non-interactive, which puts it in Flutter's `disabled` state, where a raw `Checkbox.activeColor` is dropped before it is read. The theme resolves `activeColor` into `fillColor`, which `Checkbox` consults first, so it survives. Set `fillColor` yourself for per-state control; it wins over `activeColor`
* **FIX**: `documentation/theming.md` taught a checkbox `Theme(...)` wrapped around the dropdown. It silently did nothing: the menu is drawn in the root `Overlay`, out of a local `Theme`'s subtree, so `CheckboxTheme.of` at the box resolved to the app theme, not the local one (pinned with a probe — the box's resolved fill came back null). Only an app-wide `CheckboxThemeData` reached it, and now `DropdownCheckboxTheme` reaches just this dropdown
* **TEST**: line coverage stays at 100%, with the checked box's fill asserted against the `{disabled, selected}` state it is actually in — the state a naive `activeColor` test would miss

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