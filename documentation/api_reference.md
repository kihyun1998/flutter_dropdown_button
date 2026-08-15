# API Reference

Complete reference for all classes and widgets in the flutter_dropdown_button package.

> Classes removed in 2.0.0 — `BaseDropdownButton`, `BasicDropdownButton`, `TextOnlyDropdownButton`, `DynamicTextBaseDropdownButton`, `DropdownItem` — were documented here long after they ceased to exist. See `documentation/migration.md`.

## FlutterDropdownButton<T>

Chooses one item. Two constructors.

```dart
// Custom mode — render each item as any widget
FlutterDropdownButton<T>({
  required List<T> items,
  required ValueChanged<T?> onChanged,
  required Widget Function(T item, bool isSelected) itemBuilder,
  Widget Function(T item)? selectedBuilder,
  Widget? hintWidget,
  ...
})

// Text mode — items render as text, with tooltips and search for free
FlutterDropdownButton<T>.text({
  required List<T> items,
  required ValueChanged<T?> onChanged,
  String? hint,
  String Function(T item)? label,   // required unless T is String
  TextDropdownConfig? config,
  Widget? leading,
  Widget? selectedLeading,
  EdgeInsets? leadingPadding,
  ...
})
```

Full parameter tables live in `README.md`. The two constructors share every layout, theming and search parameter; only the rendering parameters differ.

### Outside-tap dismissal

A tap outside an open menu closes it. **That tap is consumed by the dismissal and does not reach what is behind the menu** — activating a widget behind an open menu takes a second tap. Material's own `DropdownButton` produces the same tap count, through a `PopupRoute` whose `ModalBarrier` is dismissible and fully transparent.

The two are not the same mechanism, and the difference is observable. Material's barrier is `HitTestBehavior.opaque`, so nothing behind it is hit-tested at all. This package's is `translucent` and simply wins the gesture arena, so a widget behind an open menu **does** still receive the pointer — a `Listener` behind one fires its `onPointerDown` and `onPointerUp`; what it does not get is the tap.

**Another dropdown's trigger is the one exception.** With a menu open, tapping a second dropdown's anchor opens that one and closes this one, in a single tap — the barrier recognises a registered sibling trigger and declines to compete for the pointer. Everything else behind the menu still needs the second tap. The recognition is by the live hit path, not by where the trigger's box happens to be, so a trigger that is clipped, transformed, covered by a modal route or wrapped in an `IgnorePointer` is *not* one: the barrier keeps the tap and dismisses, as before. A **disabled** anchor is not one either, for the same reason it would be wrong — nothing would claim the tap and the menu would simply stay open.

Two consequences worth naming. A long press over another dropdown's trigger now opens it, where it used to dismiss — the anchor gets the gesture, and an anchor treats a long press as a press. And the exception is not scoped to one `Overlay`: a trigger in a nested `Overlay` is recognised too, which is what makes a dropdown inside a side panel reachable in one tap from a menu open in the root.

**"Outside" means outside the menu but inside its `Overlay`.** The dismissing region is the size of the `Overlay` the menu was inserted into, not the size of the screen — so in a layout that nests an `Overlay` inside part of the screen (a side panel that owns its own), a tap landing *beyond that panel* does not dismiss. Measured on a 400×600 panel offset to `left: 400`: a tap at (100, 300) leaves the menu open, one at (600, 300) closes it. Everywhere the menu itself can be seen, an outside tap dismisses; the gap is only the region the hosting `Overlay` never covered. `DropdownOverlayController.closeAll()` is the way to dismiss from outside that region — it reaches every `Overlay`.

### Statics

| Member | Description |
|--------|-------------|
| `closeAll({bool animate = true})` | Closes every open menu. Pass `animate: false` right before navigation, when the widget may be disposed before an animation could finish |

### What a screen reader hears

On screen a dropdown says which item is chosen with a colour. None of that
reaches anyone using a screen reader, so it is said in the semantics tree as
well — by hand, because this package draws its own overlay and inherits none of
Flutter's menu semantics.

- **The trigger is a control.** It announces the button role, whether it is
  enabled, and whether the menu is open — in both chromed and bare mode. The
  last one is the state the widget exists to toggle, and the only one a caller
  cannot see for themselves.
- **A chosen row says so.** Single-select rows carry `selected`; the checklist's
  carry `checked`. Which word is used follows from the cardinality, not from a
  setting.
- **A disabled control announces it, and stops accepting input** — including the
  menu, which closes rather than being left open with rows that do nothing.
- **Dismissing is done from the trigger.** The outside-tap barrier is a gesture,
  not a control: it declares nothing to assistive technology, and the trigger
  stays reachable while its own menu is open.

> **If your `itemBuilder` declares `selected` itself, delete it.** That was a
> reasonable workaround before the row carried the flag; now the two collide.
> Two `Semantics` in one merge group cannot both set the same field, so the
> caller's becomes a node of its own — measured, the row keeps `selected` and
> its tap action but loses its **label**, while the labelled node loses its
> actions. Any *other* property you declare (a label, a hint) merges as before.

What is **not** here: the open menu is not navigated by arrow keys, Escape does
not close it, and there is no type-ahead. The anchor is keyboard-activatable;
the menu is not keyboard-driven.

### The search field

`searchable: true` puts a text field at the top of the menu. **Its enabled state follows the control's, never the item count.** It goes dead when `enabled` is false — the field is part of the control, and before that it stayed focused and accepted typing for the whole close animation, leaving a soft keyboard over a disabled dropdown. It stays live on an empty list.

So a menu opened over `items: []` shows a working search field above "No items", and one whose query matches nothing keeps the field that got it there. Both are deliberate. Emptiness is not a reason to disable, for two reasons:

- **A list can be empty in transit.** A caller loading items asynchronously has `items: []` for the first frames. A field that disabled itself there would drop the focus mid-keystroke and dismiss the soft keyboard, and nothing would give either back when the items arrived — the field is focused on open, and an open menu never re-focuses it.
- **The empty state already says it.** "There is nothing to search" is the job of `emptyBuilder`, or of the default "No items", which carries a semantics node of its own so a screen reader announces it apart from the field. A disabled field would say only that search is unavailable, and not why.

### A value that is not in `items`

The button draws `value` whether or not `items` still offers it. A list refresh can drop the chosen row's data while `value` still names it; the button keeps showing it, the menu draws no row for it, and nothing throws.

**The widget draws what it was handed.** `value` belongs to the caller, and a button that silently reverted to its hint would disagree with the state its owner holds — with no callback and no error to explain why.

Before 3.1.0, custom mode audited `value` against `items` and fell back to `hintWidget`; text mode never did, having no `items` to consult. The two now agree.

### Bare anchor

```dart
Widget Function(BuildContext context, bool isOpen)? anchorBuilder
```

Supplying `anchorBuilder` puts the dropdown in **bare** mode: the button box is dropped — its background, border, fixed width, padding, ink and trailing icon — and the overlay hangs off the widget you return instead. The point is to embed the dropdown inside another field, `[All ▾] │ search…`, where a button's own chrome would nest a box inside a box.

Only the button *face* becomes yours. The anchored menu — its theming, `searchable`, `itemBuilder`, the checklist — is unchanged, and so is what the anchor *is*: a focusable button that announces its role, its enabled state and whether the menu is open, and that Enter or Space activates. `FlutterMultiSelectDropdown` takes the same parameter.

That is the whole of the keyboard story today. The **anchor** is a tab stop and can be activated from the keyboard; the **open menu** is not navigated by arrow keys, and Escape does not close it.

- **The builder is handed `isOpen`, not a label.** `isOpen` is the one thing you cannot read for yourself; a label you can, from the `value` (or `selected`) you already hold. Passing a label would leak a text-mode notion into a shell that does not know what an item says. Turn an inline chevron with `AnimatedRotation(turns: isOpen ? 0.5 : 0.0, …)`.
- **`isOpen` flips true the moment the menu opens and false once it has finished closing** — the close animation runs while it is still true, so a chevron animated off it settles back after the menu is gone.
- **The button-box params it replaces must be left unset.** `width`, `minWidth`, `maxWidth`, `expand` and `trailing` describe the box you no longer have; combining any with `anchorBuilder` asserts in debug.
- **Set `minMenuWidth` — the menu inherits the anchor's width.** A bare anchor is compact by design, and the menu takes its width from it, so an `[All ▾]` anchor yields an `[All ▾]`-wide menu its rows overflow. `minMenuWidth` (and `maxMenuWidth`) are *menu* widths, not the button-box `width`/`minWidth`/`maxWidth`, so they are allowed in bare mode and are the way to give the menu a usable width of its own.
- **The anchor is still the control it was.** It announces the button role, whether it is enabled and whether the menu is open, it is a tab stop, and Enter or Space activates it — the same contract the chromed path carries. (None of that is the ink well's doing: an `InkWell` announces no role at all. What it *does* contribute is focusability, which is why the bare path had none until it grew a focus detector of its own.)
- **It is therefore a tab stop.** In the embedded-field layout this mode exists for, that is one more stop inside the field. It is the deliberate trade for the control being reachable by keyboard at all; a disabled anchor is not a stop.

### Positioning against an outer box

```dart
GlobalKey? positioningKey
```

By default the menu measures the anchor: it drops below it, left-aligns to it, and defaults to its width. An embedded `[All ▾]` anchor is therefore a trap — the menu drops from the middle of the field and left-aligns to the little segment, not to the field around it.

Wrap the whole field in a widget carrying a `GlobalKey`, pass that key as `positioningKey`, and the menu measures **that box** instead. It drops below the whole field, left-aligns to it, and defaults to its width — while the anchor keeps drawing and toggling where it sits. This is the second half of the embedded-field pattern `anchorBuilder` opens: `anchorBuilder` decouples what the anchor *renders*, `positioningKey` decouples what the menu *positions against*. `FlutterMultiSelectDropdown` takes the same parameter.

```dart
final fieldKey = GlobalKey();

Container(
  key: fieldKey, // the whole search box
  child: Row(children: [
    FlutterDropdownButton<String>.text(
      items: fields,
      value: field,
      onChanged: onField,
      anchorBuilder: (context, isOpen) => const Text('All ▾'),
      positioningKey: fieldKey, // menu drops below the whole box
    ),
    const Expanded(child: TextField(/* search… */)),
  ]),
)
```

- **`menuAlignment`, `minMenuWidth` and `maxMenuWidth` all measure against the box too.** When `positioningKey` is set, "the button" every width-and-alignment rule refers to is the outer box, not the anchor. With the menu already defaulting to the field's width, `minMenuWidth` is usually unnecessary here — the reverse of bare mode without a `positioningKey`.
- **The box is measured on every menu build, not tracked per frame.** A box that moves *while the menu is open* is not followed — the same as the anchor. It must live in the same `Overlay` coordinate space the anchor does.
- **Not restricted to bare mode.** It composes with a normal chromed button too, if you want the menu to align to a container the button sits inside; there is no assert against it.

## FlutterMultiSelectDropdown\<T\>

A checklist. Several items may be chosen, the menu stays open while they are, and `onChanged` fires the moment a box is ticked — no confirm button. Anchored rather than modal: no scrim, dismissed by an outside tap — a tap the dismissal consumes, so it does not also reach what is behind the menu. Another dropdown's trigger is the one exception; see [Outside-tap dismissal](#outside-tap-dismissal).

```dart
FlutterMultiSelectDropdown<T>({
  required List<T> items,
  required Set<T> selected,
  required ValueChanged<Set<T>> onChanged,
  required String Function(Set<T> selected) labelBuilder,
  String Function(T item)? label,          // required unless T is String
  Widget Function(T item)? itemLeadingBuilder,
  Widget Function(T item)? itemTrailingBuilder,
  TextDropdownConfig? config,
  ...
})
```

It shares every layout, theming and search parameter with `FlutterDropdownButton`. It does **not** have `value`, `scrollToSelectedItem`, `scrollToSelectedDuration`, `disableWhenSingleItem` or `hideIconWhenSingleItem`: those mean nothing to a checklist, so they are absent from the type rather than asserted against at runtime.

Text mode only. An item that needs more than text — an avatar, two lines — is a fourth `DropdownItemPresentation` and does not exist yet.

### Contracts

- **`selected` is yours.** `onChanged` receives a fresh `Set`; the one you pass in is never mutated and may be unmodifiable.
- **`T` needs `==` and `hashCode`.** `selected.contains(item)` uses both, where single-select's `value == item` used only the first. A `T` with a hand-written `==` and the default `hashCode` will let a `Set` hold duplicates that look identical.
- **A chosen value absent from `items`** still counts towards `labelBuilder`, and draws no row. `'3 selected'` can appear beside two ticked boxes after a refresh drops the third. Offer a way to clear it.
- **The query survives a tick.** Only opening and closing the menu reset it.
- **Rows announce their checked state.** The box (a `FlutterCheckbox`) is drawn but excluded from the semantics tree; the row carries `checked` instead, so the row is the single interactive node a screen reader sees. Everything under [What a screen reader hears](#what-a-screen-reader-hears) applies here too — the trigger's role, enabled and open state are the shell's, not the widget's.
- **Disabling closes the checklist.** It matters more here than for single-select: `closeOnTap` is false, so before this an open checklist stayed fully operable for as long as it was on screen, disabled or not.
- **A trailing widget's text is merged into the row's announced label.** The ink well merges its descendants, so `itemTrailingBuilder: (v) => Text('42')` makes a screen reader read `"Apple\n42"`. `itemLeadingBuilder` is the same; an `Icon` carries no label and stays silent.
- **The row is `[checkbox] [leading] [label] [trailing]`.** Only the label gives way when space runs out, so it ellipsises and neither slot is squeezed. Material has no such arrangement — `CheckboxListTile`'s `secondary` sits on the *opposite* side of the box (`checkbox_list_tile.dart:590`), which is the layout `itemTrailingBuilder` alone gives you.

### Statics

| Member | Description |
|--------|-------------|
| `closeAll({bool animate = true})` | The same registry as `FlutterDropdownButton.closeAll`. Either closes both kinds |

## DropdownButtonTheme

Styles the button face — its box, ink colours, content height, and the arrow icon. In **bare** mode (`anchorBuilder`) the button box is dropped, so this theme is inert.

### Constructor

```dart
DropdownButtonTheme({
  double borderRadius = 8.0,
  Border? border,
  Color? backgroundColor,
  BoxDecoration? decoration,
  EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  double? height,
  Color? hoverColor,
  Color? splashColor,
  Color? highlightColor,
  IconData? icon,
  Color? iconColor,
  Color? iconDisabledColor,
  double? iconSize,
  EdgeInsets? iconPadding,
  BoxDecoration? disabledDecoration,
  Color? disabledBackgroundColor,
  Border? disabledBorder,
})
```

### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `borderRadius` | `double` | 8.0 | Border radius of the button |
| `border` | `Border?` | null | Border of the button |
| `backgroundColor` | `Color?` | null | Button fill color |
| `decoration` | `BoxDecoration?` | null | Custom decoration for button (overrides the fields above) |
| `padding` | `EdgeInsets` | 16h, 12v | Padding for the button |
| `height` | `double?` | null | Height of the button content area |
| `hoverColor` | `Color?` | null | Button hover background color |
| `splashColor` | `Color?` | null | Button tap ripple color |
| `highlightColor` | `Color?` | null | Button focus highlight color |
| `icon` | `IconData?` | `keyboard_arrow_down` | Dropdown arrow icon |
| `iconColor` | `Color?` | null | Icon color when enabled |
| `iconDisabledColor` | `Color?` | null | Icon color when disabled |
| `iconSize` | `double?` | null (24.0) | Size of the dropdown icon |
| `iconPadding` | `EdgeInsets?` | `left: 8.0` | Padding around the icon |
| `disabledDecoration` | `BoxDecoration?` | null | Full custom decoration for the disabled button |
| `disabledBackgroundColor` | `Color?` | null | Background color of the button when disabled |
| `disabledBorder` | `Border?` | null | Border of the button when disabled |

## DropdownOverlayTheme

Styles the menu container — its background, border, corner radius, and shadow.

### Constructor

```dart
DropdownOverlayTheme({
  double borderRadius = 8.0,
  double elevation = 8.0,
  Color? backgroundColor,
  Border? border,
  Color? shadowColor,
  BoxDecoration? decoration,
  EdgeInsets? padding,
})
```

### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `borderRadius` | `double` | 8.0 | Border radius of the overlay |
| `elevation` | `double` | 8.0 | Shadow elevation of overlay |
| `backgroundColor` | `Color?` | null | Background color of overlay |
| `border` | `Border?` | null | Border of the overlay |
| `shadowColor` | `Color?` | null | Shadow color for overlay |
| `decoration` | `BoxDecoration?` | null | Custom decoration for overlay |
| `padding` | `EdgeInsets?` | null | Padding inside the overlay container |

## DropdownItemTheme

Styles the rows inside the menu.

### Constructor

```dart
DropdownItemTheme({
  Color? selectedColor,
  Color? hoverColor,
  Color? splashColor,
  Color? highlightColor,
  EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  EdgeInsets? margin,
  double? borderRadius,
  Border? border,
  bool excludeLastItemBorder = true,
})
```

### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `selectedColor` | `Color?` | null | Background color of selected item |
| `hoverColor` | `Color?` | null | Background color on hover |
| `splashColor` | `Color?` | null | Splash color for item interactions |
| `highlightColor` | `Color?` | null | Highlight color for item touch |
| `padding` | `EdgeInsets` | 16h, 12v | Padding for dropdown items |
| `margin` | `EdgeInsets?` | null | Margin around each dropdown item |
| `borderRadius` | `double?` | null | Individual border radius for items |
| `border` | `Border?` | null | Border for each item (e.g., bottom divider) |
| `excludeLastItemBorder` | `bool` | true | Skip `border` on the last item |

## Theme resolution

The button, overlay, and item themes each fill in their own gaps. The widget reads a resolved style rather than deciding between a themed value and a framework default at each call site — so the rule for "what colour is the arrow when disabled?" exists in exactly one place.

Resolution takes a **plain palette**, not a `BuildContext`. Reading values out of a `ThemeData` needs an element tree; deciding with them does not, and only the second half is worth testing.

```dart
final ambient = DropdownAmbientColors.of(context);   // once, in build
final style = buttonTheme.resolveButton(ambient, enabled: isEnabled);

Container(decoration: style.decoration, ...);
```

Not everything a theme knows needs a palette. `DropdownButtonTheme.resolvedIconSize` — the arrow's size, or `DropdownButtonTheme.defaultIconSize` when unset — is a pure read, and reading it is how a caller avoids building a whole `ResolvedButtonStyle` for one number.

### Resolve methods

| Method | On | Returns | Description |
|--------|----|---------|-------------|
| `resolveButton(ambient, {required bool enabled})` | `DropdownButtonTheme` | `ResolvedButtonStyle` | The button's box, ink colours, content height, and arrow. `enabled` must be the *effective* state — a single-item dropdown disabled by policy is disabled here too |
| `resolveOverlay(ambient)` | `DropdownOverlayTheme` | `ResolvedOverlayStyle` | The menu container, plus the border thickness the placement module reserves |
| `resolveItem(ambient, {required bool selected, required bool isFirst, required bool isLast, required double menuBorderRadius})` | `DropdownItemTheme` | `ResolvedItemStyle` | One item row. `menuBorderRadius` is the enclosing menu's corner radius, so the end rows round to meet the menu's corners unless `borderRadius` overrides |

### DropdownAmbientColors

The ambient palette, lifted out of `ThemeData`. Construct it with `.of(context)`, or by hand in a test.

| Property | Description |
|----------|-------------|
| `card` | Background of surfaces above the page — the menu |
| `divider` | Hairline borders |
| `splash` / `highlight` / `hover` | Ink states |
| `primary` | Accent, tinting the selected item at 10% opacity |
| `disabled` | Foreground of anything switched off |
| `icon` | Default icon colour; null when the ambient theme leaves it unset |

`SearchFieldTheme` and `DropdownScrollTheme` do not resolve themselves yet — see issue #26.

## DropdownOverlayController

Drives a dropdown menu: its overlay's lifetime, its open/close animation, the widget tree the menu is drawn into, and the rule that only one menu is open at a time within an `Overlay`.

**Hold one; do not inherit from it.** This package's own `FlutterDropdownButton` holds the same controller, so a custom dropdown built on it behaves identically.

Replaces `DropdownMixin`, which was removed in 3.0.0.

### Usage

```dart
class _MyDropdownState extends State<MyDropdown>
    with SingleTickerProviderStateMixin {
  late final _menu = DropdownOverlayController(
    vsync: this,
    spec: () => DropdownOverlaySpec(
      itemCount: widget.items.length,
      actualItemHeight: 48,
      maxDropdownHeight: 200,
    ),
    contentBuilder: (height) => ListView(...),
    decorationBuilder: () => null,
    onOpenStateChanged: (_) => setState(() {}),
  );

  @override
  void dispose() {
    _menu.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => InkWell(
        key: _menu.buttonKey,
        onTap: () => _menu.toggle(context),
        child: ...,
      );
}
```

A working example lives in `example/lib/pages/domain_type_page.dart`.

### Constructor

| Parameter | Type | Description |
|-----------|------|-------------|
| **`vsync`** | `TickerProvider` | Drives the open/close animation |
| **`spec`** | `DropdownOverlaySpec Function()` | Called on every overlay build. A callback, not a value: the item count and theme change while the menu is open |
| **`contentBuilder`** | `Widget Function(double height)` | Builds the menu's content, given the height available to it |
| **`decorationBuilder`** | `BoxDecoration? Function()` | Decorates the overlay container. Return null for a themed default |
| `animationDuration` | `Duration` | Defaults to 200ms |
| `onOpenStateChanged` | `ValueChanged<bool>?` | Called after the menu opens or closes, so the owner can rebuild |

### Members

| Member | Description |
|--------|-------------|
| `buttonKey` | Attach to the button so the controller can measure it |
| `positioningKey` | A `GlobalKey` on an outer box to measure the menu against instead of `buttonKey`. Mutable; null measures the button. See [Positioning against an outer box](#positioning-against-an-outer-box) |
| `isOpen` | Whether the menu is showing — true for the whole close animation too, since the entry is still mounted. `open()` accounts for that itself |
| `animation` | Runs forward as the menu opens. Drive your own transitions from it — a rotating trailing icon, say |
| `open(context)` | Shows the menu, closing whichever menu is open in the same `Overlay`. Called while this menu is closing it takes the close back, so `closeAll()` then `open()` shows the menu |
| `close({animate = true})` | Hides the menu. Pass `animate: false` to tear it down at once. The menu goes away either way — the animation is decoration, not the mechanism, so a disabled `TickerMode` (anything under a pushed route) cannot strand the entry |
| `toggle(context)` | Opens if closed, closes if open |
| `rebuild()` | Rebuilds and re-measures the menu in place. Not legal during a build — defer to a post-frame callback |
| `dispose()` | Releases the animation and removes the overlay |
| `closeAll({animate = true})` (static) | Closes every open menu, in every `Overlay` |

### DropdownOverlaySpec

Describes one rendering of the menu. Everything that is not an item — the search field, the border, the overlay's padding — is summed into the space the menu reserves for chrome, so a short list never acquires a scrollbar just because search is enabled.

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| **`itemCount`** | `int` | required | How many items the menu holds |
| **`actualItemHeight`** | `double` | required | Vertical space one item occupies, including its margin |
| **`maxDropdownHeight`** | `double` | required | The tallest the item list may grow |
| `chromeHeight` | `double` | `0.0` | Space taken by furniture that is not an item — a search field |
| `borderThickness` | `double` | `0.0` | Total thickness of the overlay's top and bottom borders |
| `overlayPadding` | `EdgeInsets?` | `null` | Padding inside the overlay container |
| `screenMargin` | `double` | `8.0` | Gap kept between the menu and the safe-area edge |
| `buttonGap` | `double` | `4.0` | Gap kept between the button and the menu |
| `minVisibleItems` | `int` | `2` | Items kept visible when space runs out, even at the cost of the margin |
| `minMenuWidth` | `double?` | `null` | Narrowest the menu may be |
| `maxMenuWidth` | `double?` | `null` | Widest the menu may be |
| `menuAlignment` | `MenuAlignment` | `.left` | How the menu lines up with a narrower button |
| `elevation` | `double` | `8.0` | Shadow depth |
| `borderRadius` | `double` | `8.0` | Corner radius |
| `shadowColor` | `Color?` | `null` | Shadow colour |

The overlay's total non-item furniture is `spec.totalChromeHeight` — `chromeHeight + borderThickness + overlayPadding.vertical`. `DropdownPlacement` grows the menu by it. Anything laying out content inside the menu should shrink by *that same getter* rather than re-adding the parts; disagreeing about it is what made a searchable menu scroll for no reason in 2.3.2, and a `Divider()` overflow the item list in 2.5.0.

## DropdownItemPresentation\<T\>

How items and the button's face are drawn. One implementation per rendering mode.

`FlutterDropdownButton` picks one and every render site asks it what to draw, rather than asking which constructor was used. If you are building your own dropdown on `DropdownOverlayController`, reach for `TextItemPresentation` rather than reimplementing overflow handling, the tooltip and the search filter.

### Interface

| Member | Type | Description |
|--------|------|-------------|
| `contentAlignment` | `Alignment` | Where the button's face and each item row sit horizontally |
| `defaultSearchFilter` | `DropdownSearchFilter<T>?` | The filter used when the caller supplies none. Null means this mode has none to offer |
| `buildItem(item, isSelected)` | `Widget` | One row of the open menu. An implementation must also **announce** `isSelected` on the row, in its cardinality's vocabulary — `selected` for a single-select row, `checked` for a checklist one. The shell cannot do it for you: it does not know what selection is, only what `isChosen` answered |
| `buildSelected()` | `Widget` | The button's face: the selected item, or the hint. Deliberately *not* routed through `buildItem` — the face is not a selected row |

### TextItemPresentation\<T\>

Renders items as text through a `label` extractor, and so can offer overflow handling, an automatic tooltip, and a case-insensitive `contains` filter over the label.

Asserts that `label` is present unless `T` is `String` — a string is its own label.

```dart
final presentation = TextItemPresentation<User>(
  label: (user) => user.name,
  value: selectedUser,
  hintText: 'Select a user',
  config: TextDropdownConfig.defaultConfig,
  tooltipTheme: DropdownTooltipTheme.defaultTheme,
  enabled: true,
  leadingHeight: 24,
);

presentation.buildItem(users.first, false);   // a menu row
presentation.buildSelected();                 // the button's face
presentation.defaultSearchFilter!(user, 'ann');
```

### CustomItemPresentation\<T\>

Renders each item as whatever `itemBuilder` returns. `defaultSearchFilter` is null: it cannot match an arbitrary widget against a query, so a caller who wants search must supply `searchFilter`.

`buildSelected()` falls back to `hintWidget` only when `value` is **null**.

A `value` that is not among `items` — the state a list refresh leaves behind when the chosen row's data disappears — is still drawn. **The widget draws what it was handed**: `value` belongs to the caller, and auditing it against `items` would make the button disagree with the state its owner holds. Text mode never audited it, having no `items` to consult; since 3.1.0 custom mode does not either.

The menu is a separate matter. It iterates `items`, so an absent value is never a row.

`items` is therefore read by nothing and is **deprecated**; it will be removed in 4.0.0.

### MultiSelectPresentation\<T\>

Renders items as a checklist: a box, a label, and an optional trailing widget. The button's face is whatever `labelBuilder` makes of the chosen set. `FlutterMultiSelectDropdown` uses it; nothing stops you from driving it yourself.

```dart
final presentation = MultiSelectPresentation<String>(
  selected: chosen,
  labelBuilder: (s) => '${s.length} selected',
  label: null,                                 // required unless T is String
  config: TextDropdownConfig.defaultConfig,
  tooltipTheme: DropdownTooltipTheme.defaultTheme,
  enabled: true,
  itemLeadingBuilder: (item) => Icon(osIcon[item]),
  itemTrailingBuilder: (item) => Text('${counts[item]}'),
);
```

An optional `checkboxTheme` (a `DropdownCheckboxTheme`, default `defaultTheme`) styles the row's box, which is a `FlutterCheckbox` (the `flutter_checkbox` package). It resolves into a `CheckboxStyle`; see [theming](theming.md).

The interface is unchanged. `buildSelected()` still takes no argument: `TextItemPresentation` swallows a `value` as a field, and this one swallows a `Set` and a `labelBuilder` the same way.

Two things it does that are not visible on screen:

- The `FlutterCheckbox` is **presentational** and **excluded from the semantics tree**, and the row carries `Semantics(checked:)` instead. `onChanged: null` gives the box no gesture recognizer — a tap on it falls through to the row — while leaving it `enabled`, so (unlike Material) it does not stamp `isEnabled: false` onto the merged row. It still emits its own `checked` node, which the exclusion drops so the row is the single source of the checked state. `IgnorePointer` does not help; it suppresses hit-testing, not semantics.
- The row's ink well **merges** its descendants' semantics, so `itemTrailingBuilder`'s text becomes part of the announced label: `"Apple\n42"`.

## DropdownSearchController\<T\>

Owns a dropdown's search query: its text field, its focus, and their lifetime. Hold one; `FlutterDropdownButton` does.

It knows nothing about the menu or the scroll position — a query change that also scrolled and rebuilt an overlay would make it a second copy of the widget. The owner does those.

### Members

| Member | Description |
|--------|-------------|
| `DropdownSearchController({required bool enabled})` | Allocates the field's controllers only when `enabled` |
| `enabled` | Whether search filters. Settable; turning it off keeps the field, so turning it back on does not lose the caret |
| `query` | What the user has typed |
| `textController` / `focusNode` | Attach to your search field. Null until search is first enabled |
| `onQueryChanged(String)` | Records the query. You decide what to redraw |
| `visibleItems(items, filter)` | The items the query leaves visible. A null `filter` hides nothing |
| `reset()` | Clears the query and the field |
| `requestFocus()` | Puts the caret in the field |
| `dispose()` | Call from the owner's `dispose` |

`visibleItems` derives the list on every call rather than caching it. Pass `TextItemPresentation.defaultSearchFilter`, or your own predicate.

## Manual Dropdown Cleanup

`FlutterDropdownButton.closeAll()` closes every open menu without needing a reference to the widget that opened it. Use it before navigating away, or before showing a dialog, when a menu may still be on screen.

`DropdownOverlayController.closeAll()` is the same call one layer down, and closes menus opened by either.

Pass `animate: false` when the widget may be disposed before the closing animation could finish — navigation is the usual case. It defaults to `true`.

```dart
// Close any open dropdown before navigation
void navigateAway() {
  FlutterDropdownButton.closeAll(animate: false);
  Navigator.pushNamedAndRemoveUntil(
    context,
    '/home',
    (route) => false,
  );
}

// Close dropdown before showing dialog
void showConfirmDialog() {
  FlutterDropdownButton.closeAll();
  showDialog(
    context: context,
    builder: (context) => AlertDialog(...),
  );
}
```

Only one menu is open at a time **within an `Overlay`**. Two dropdowns living in two different `Overlay`s — a side panel and the root route, say — do not close each other, and `closeAll()` closes both.

#### Automatic vs Manual Cleanup

- **Automatic**: The dropdown overlay is automatically removed when the widget is disposed (e.g., during navigation). This is the default behavior and requires no additional code.
- **Manual**: Use `closeAll()` when you want explicit control over when the dropdown closes, such as before triggering navigation programmatically.

### Position Calculation

The mixin automatically calculates the optimal position based on:
- Available space above and below the button
- Screen boundaries and safety margins
- Content height requirements
- Minimum visibility constraints

Returns a `DropdownPositionResult` with:
- `height`: Calculated overlay height
- `openDown`: Whether to open downward
- `transformAlignment`: Animation alignment
- `topPosition`: Calculated top position

## TextDropdownConfig

Configuration specific to text-only dropdown widgets.

### Constructor

```dart
TextDropdownConfig({
  TextOverflow overflow = TextOverflow.ellipsis,
  int? maxLines = 1,
  TextStyle? textStyle,
  TextStyle? hintStyle,
  TextStyle? selectedTextStyle,
  TextAlign textAlign = TextAlign.start,
  bool softWrap = true,
  TextDirection? textDirection,
  Locale? locale,
  double? textScaleFactor,
  String? semanticsLabel,
})
```

### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `overflow` | `TextOverflow` | ellipsis | How to handle text overflow |
| `maxLines` | `int?` | 1 | Maximum number of lines |
| `textStyle` | `TextStyle?` | null | Style for dropdown item text |
| `hintStyle` | `TextStyle?` | null | Style for hint text |
| `selectedTextStyle` | `TextStyle?` | null | Style for selected item text |
| `textAlign` | `TextAlign` | start | Text alignment |
| `softWrap` | `bool` | true | Whether text should wrap |
| `textDirection` | `TextDirection?` | null | Text direction |
| `locale` | `Locale?` | null | Locale for text rendering |
| `textScaler` | `TextScaler?` | null | Text scaler for accessibility |
| `semanticsLabel` | `String?` | null | Accessibility label for the **button**, announced alongside the selected value. Items announce their own text |

### Predefined Configurations

```dart
// Default single-line with ellipsis
TextDropdownConfig.defaultConfig

// Multi-line text display
TextDropdownConfig.multiLine

// Center-aligned text
TextDropdownConfig.centered

// Fade overflow instead of ellipsis
TextDropdownConfig.fadeOverflow
```