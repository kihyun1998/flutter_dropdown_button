# Migration Guide

## Upgrading to 4.0.0

Breaking in three places: the `DropdownTheme` split, the multi-select checkbox theme, and one field that 3.1.0 deprecated. The **SDK floor is unchanged** (`>=3.32.0`). If you use none of them, nothing changes.

### `DropdownTheme` is split into `button` / `overlay` / `item`

The single `DropdownTheme` is gone. `DropdownStyleTheme`'s `dropdown` slot is replaced by three sibling slots — one per surface — beside `scroll` / `tooltip` / `search` / `checkbox`. Fields keep their meaning; they lose the surface prefix and move onto the matching sub-theme.

```dart
// Before (3.x)
DropdownStyleTheme(
  dropdown: DropdownTheme(
    borderRadius: 12,
    backgroundColor: Colors.white,      // this was the *menu* fill
    buttonHoverColor: Colors.black12,
    selectedItemColor: Colors.teal,
    itemPadding: EdgeInsets.all(12),
  ),
)

// After (4.0.0)
DropdownStyleTheme(
  button: DropdownButtonTheme(borderRadius: 12, hoverColor: Colors.black12),
  overlay: DropdownOverlayTheme(borderRadius: 12, backgroundColor: Colors.white),
  item: DropdownItemTheme(selectedColor: Colors.teal, padding: EdgeInsets.all(12)),
)
```

Field map:

| Old `DropdownTheme` field | New home |
|---|---|
| `borderRadius` | `button.borderRadius` and/or `overlay.borderRadius` (was one knob for both) |
| `backgroundColor` | `overlay.backgroundColor` (it was the menu fill; `button.backgroundColor` is new) |
| `border` | `button.border` and/or `overlay.border` |
| `buttonDecoration` / `buttonPadding` / `buttonHoverColor` / `buttonSplashColor` / `buttonHighlightColor` / `buttonHeight` | `button.decoration` / `.padding` / `.hoverColor` / `.splashColor` / `.highlightColor` / `.height` |
| `icon*`, `disabledBackgroundColor`, `disabledBorder` | `button.*` (same names) |
| `disabledButtonDecoration` | `button.disabledDecoration` |
| `elevation`, `shadowColor` | `overlay.elevation`, `overlay.shadowColor` |
| `overlayDecoration` / `overlayPadding` | `overlay.decoration` / `overlay.padding` |
| `selectedItemColor` | `item.selectedColor` |
| `itemHoverColor` / `itemSplashColor` / `itemHighlightColor` | `item.hoverColor` / `.splashColor` / `.highlightColor` |
| `itemPadding` / `itemMargin` / `itemBorderRadius` / `itemBorder` / `excludeLastItemBorder` | `item.padding` / `.margin` / `.borderRadius` / `.border` / `.excludeLastItemBorder` |

`DropdownButtonTheme` is ignored in bare mode (`anchorBuilder`) — the caller draws the anchor. `DropdownTheme.defaultIconSize` is now `DropdownButtonTheme.defaultIconSize`.

### `DropdownCheckboxTheme` is redesigned around `flutter_checkbox`

The checklist box is now a `FlutterCheckbox` (the `flutter_checkbox` package) rather than Flutter's built-in `Checkbox`, so `DropdownCheckboxTheme` speaks its `CheckboxStyle` vocabulary. Remap the removed Material fields:

| Removed (3.x, Material) | Replacement (4.0.0) |
|---|---|
| `side: BorderSide(color: c, width: w)` | `borderColor: c` + `borderWidth: w` |
| `shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r))` | `shape: CheckboxShape.rectangle` + `borderRadius: r` |
| `shape: CircleBorder()` | `shape: CheckboxShape.circle` |
| `fillColor: WidgetStateProperty...` | `activeColor` (checked) / `inactiveColor` (unchecked) |
| `materialTapTargetSize`, `visualDensity` | *no equivalent* — size the box with `size` |

`activeColor`, `checkColor` and `mouseCursor` are unchanged. `CheckboxShape` is re-exported from the package, so it needs no extra import. `resolve()` now returns a `CheckboxStyle`, and the `ResolvedCheckboxStyle` class is removed — only code building a presentation by hand is affected.

```dart
// Before (3.x)
DropdownCheckboxTheme(
  activeColor: Colors.teal,
  side: BorderSide(color: Colors.grey, width: 2),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
)

// After (4.0.0)
DropdownCheckboxTheme(
  activeColor: Colors.teal,
  borderColor: Colors.grey,
  borderWidth: 2,
  shape: CheckboxShape.rectangle,
  borderRadius: 4,
)
```

A bonus: the `activeColor` → `fillColor` dance 3.2.0 documented is gone. `FlutterCheckbox` is drawn `onChanged: null` but stays `enabled`, so it is presentational without being greyed, and `activeColor` shows on a checked box directly.

### `CustomItemPresentation.items` is removed

Deprecated in 3.1.0 (read by nothing since), now removed. Drop the argument:

```dart
// Before
CustomItemPresentation<T>(itemBuilder: ..., items: items, value: value)

// After
CustomItemPresentation<T>(itemBuilder: ..., value: value)
```

Only code that constructs a presentation by hand — a dropdown built on `DropdownOverlayController` — is affected.

## Upgrading to 3.1.0

A new widget, one behaviour change, one deprecation. Nothing was removed.

**`FlutterMultiSelectDropdown<T>` is new.** A checklist that stays open, emits a `Set<T>` the moment a box is ticked, and needs no confirm button. It shares every layout, theming and search parameter with `FlutterDropdownButton`. Nothing you already wrote changes.

**Custom mode now draws a `value` that is not in `items`.** Previously `FlutterDropdownButton(itemBuilder: ...)` audited `value` against `items` and fell back to `hintWidget` when it was absent — silently, with no callback and no error. Text mode never did this, having no `items` to consult. The two now agree: **the widget draws what it was handed.**

You see a difference only if a `value` outlives its row — the state a list refresh leaves behind. Where the button used to show the hint, it now shows the value. The menu is unchanged; it iterates `items` and never invented a row for it.

If you were relying on the old fallback to detect a stale `value`, do it where the state lives:

```dart
// Before: the button told you, by showing the hint.
// After:
if (value != null && !items.contains(value)) {
  // clear it, or offer the user a way to
}
```

**`CustomItemPresentation.items` is deprecated.** It fed the audit above and is now read by nothing. It is no longer `required`; drop the argument. It will be removed in 4.0.0.

```dart
// Before
CustomItemPresentation<T>(itemBuilder: ..., items: items, value: value)

// After
CustomItemPresentation<T>(itemBuilder: ..., value: value)
```

Only code that constructs a presentation by hand — a dropdown built on `DropdownOverlayController` — is affected. `FlutterDropdownButton` callers see nothing.

## Upgrading to 3.0.1

No API changed. Three bugs did, and two of them are visible.

**Your menu had two scrollbars on desktop.** Flutter's `MaterialScrollBehavior` adds one to every scroll view; this package added a second on top. You now see one. If you were compensating for the extra bar — a transparent thumb, an outsized `crossAxisMargin` — undo it.

**The scrollbar no longer swells on hover.** It grew from 8 to 12 logical pixels when a pointer entered a visible track, because the thickness handed to Flutter was `null`. It now rests at the size it always drew at, and stays there.

**A dropdown with no `DropdownScrollTheme` now gets one.** Previously the menu fell through to Flutter's automatic scrollbar entirely. The default theme draws the same thing, but `DropdownScrollTheme` now governs it — so `thumbColor` and friends take effect where they silently did not before.

Nothing to change in your code.

## Migrating from 2.x to 3.0.0

Version 3.0.0 removes everything deprecated during the 2.x line. Nothing was renamed and no behaviour changed — each removed member already had a replacement that was doing the work.

| Removed (2.x) | Replacement |
|---|---|
| `DropdownMixin<T>` | `DropdownOverlayController` |
| `DropdownMixin.calculateMenuWidth()` / `.calculateMenuLeftPosition()` | `DropdownPlacement.resolve()` |
| `DropdownMixin.calculateDropdownPosition()` / `DropdownPositionResult` | `DropdownOverlayController.measurePlacement()` → `DropdownPlacementResult` |
| `DropdownTheme.animationDuration` | `FlutterDropdownButton.animationDuration` |
| `DropdownTooltipTheme.borderColor` / `.borderWidth` | `DropdownTooltipTheme.border` |
| `DropdownScrollTheme.alwaysVisible` | `DropdownScrollTheme.thumbVisibility` |
| `DropdownScrollTheme.trackWidth` | `DropdownScrollTheme.thumbWidth` |

**If you only ever used `FlutterDropdownButton`, nothing here affects you.** The removals are all on classes you had to reach for deliberately.

### DropdownMixin

Hold a controller instead of mixing one in. The twenty-three members the mixin asked you to override collapse into one `DropdownOverlaySpec`.

**Before (2.x):**
```dart
class _MyDropdownState extends State<MyDropdown>
    with SingleTickerProviderStateMixin, DropdownMixin<MyDropdown> {
  @override
  Widget buildOverlayContent(double height) => ListView(...);
  @override
  int get itemCount => widget.items.length;
  // ...twenty more overrides
}
```

**After (3.0):**
```dart
class _MyDropdownState extends State<MyDropdown>
    with SingleTickerProviderStateMixin {
  late final _menu = DropdownOverlayController(
    vsync: this,
    spec: () => DropdownOverlaySpec(
      itemCount: widget.items.length,
      actualItemHeight: 48,
      maxDropdownHeight: 300,
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
}
```

`spec` is a **callback**, not a value: it is re-read on every overlay build, so an open menu resizes when its items change. See `example/lib/pages/domain_type_page.dart` for a working dropdown built this way.

### DropdownTheme.animationDuration

This field was never read. Setting it did nothing; the animation has always been driven by the widget.

```dart
// Before — silently ignored
theme: DropdownStyleTheme(
  dropdown: DropdownTheme(animationDuration: Duration(milliseconds: 300)),
)

// After
FlutterDropdownButton<String>.text(
  animationDuration: const Duration(milliseconds: 300),
  // ...
)
```

If you were setting it on the theme, your menus were animating at 200ms and still are. Move the value across only if you actually wanted the slower animation.

### DropdownScrollTheme.trackWidth

Never applied. Flutter's scrollbars have one thickness, not two, so the track has always been drawn at the thumb's width.

```dart
// Before — silently ignored
DropdownScrollTheme(thumbWidth: 6, trackWidth: 20)

// After
DropdownScrollTheme(thumbWidth: 6)
```

### DropdownScrollTheme.alwaysVisible

This field was never read. Setting it did nothing; the scrollbar auto-hid regardless.

```dart
// Before — silently ignored
DropdownScrollTheme(alwaysVisible: true)

// After
DropdownScrollTheme(thumbVisibility: true)
```

If you were setting it, your scrollbar has been auto-hiding all along. Move the value across only if you actually want it pinned open.

### DropdownTooltipTheme.borderColor / borderWidth

```dart
// Before
DropdownTooltipTheme(borderColor: Colors.red, borderWidth: 2)

// After
DropdownTooltipTheme(border: Border.all(color: Colors.red, width: 2))
```

`border` takes any `BoxBorder`, so a one-sided border is now expressible, and a width without a colour no longer is.

---

## Migrating from 1.x to 2.0.0

Version 2.0.0 unifies all dropdown variants (`BasicDropdownButton`, `TextOnlyDropdownButton`, `DynamicTextBaseDropdownButton`) into a single `FlutterDropdownButton<T>` widget with two modes.

### What Changed

| Removed (1.x) | Replacement (2.0) |
|---|---|
| `BasicDropdownButton` | `FlutterDropdownButton<T>()` (default constructor with `itemBuilder`) |
| `TextOnlyDropdownButton` | `FlutterDropdownButton<T>.text()` |
| `DynamicTextBaseDropdownButton` | `FlutterDropdownButton<T>.text()` with `disableWhenSingleItem: true` |
| `DropdownItem<T>` model class | `itemBuilder` callback |
| `BaseDropdownButton` / `BaseDropdownButtonState` | Internal only (not public API) |
| `TextDropdownRenderMixin` | Absorbed into `FlutterDropdownButton` |
| `showSeparator` / `separator` | `DropdownTheme.itemBorder` |

### BasicDropdownButton

**Before (1.x):**
```dart
BasicDropdownButton<String>(
  items: [
    DropdownItem(value: 'apple', child: Text('Apple')),
    DropdownItem(value: 'banana', child: Text('Banana')),
    DropdownItem(value: 'orange', child: Text('Orange')),
  ],
  value: selectedValue,
  hint: Text('Select a fruit'),
  width: 200,
  onChanged: (value) => setState(() => selectedValue = value),
)
```

**After (2.0):**
```dart
FlutterDropdownButton<String>(
  items: ['apple', 'banana', 'orange'],
  value: selectedValue,
  hintWidget: Text('Select a fruit'),
  itemBuilder: (item, isSelected) => Text(
    item,
    style: TextStyle(
      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
    ),
  ),
  onChanged: (value) => setState(() => selectedValue = value),
)
```

Key differences:
- `items` is now `List<T>` (values only), not `List<DropdownItem<T>>`
- `hint` (Widget) is now `hintWidget`
- Rendering is handled by `itemBuilder(item, isSelected)` callback
- Use `selectedBuilder` to customize how the selected item looks on the button face
- `DropdownItem.onTap` is removed, handle in `onChanged` instead

### TextOnlyDropdownButton

**Before (1.x):**
```dart
TextOnlyDropdownButton(
  items: ['Apple', 'Banana', 'Cherry'],
  value: selectedValue,
  hint: 'Select a fruit',
  width: 200,
  theme: DropdownStyleTheme(
    dropdown: DropdownTheme(borderRadius: 12.0),
  ),
  config: TextDropdownConfig(overflow: TextOverflow.ellipsis),
  onChanged: (value) => setState(() => selectedValue = value),
)
```

**After (2.0):**
```dart
FlutterDropdownButton<String>.text(
  items: ['Apple', 'Banana', 'Cherry'],
  value: selectedValue,
  hint: 'Select a fruit',
  width: 200,
  theme: DropdownStyleTheme(
    dropdown: DropdownTheme(borderRadius: 12.0),
  ),
  config: TextDropdownConfig(overflow: TextOverflow.ellipsis),
  onChanged: (value) => setState(() => selectedValue = value),
)
```

Almost identical - just change the class name to `FlutterDropdownButton<String>.text()`.

### DynamicTextBaseDropdownButton

**Before (1.x):**
```dart
DynamicTextBaseDropdownButton(
  items: items,
  value: selectedValue,
  disableWhenSingleItem: true,
  hideIconWhenSingleItem: true,
  leading: Icon(Icons.star, size: 16),
  selectedLeading: Icon(Icons.star, size: 16, color: Colors.blue),
  minWidth: 100,
  maxWidth: 250,
  onChanged: (value) => setState(() => selectedValue = value),
)
```

**After (2.0):**
```dart
FlutterDropdownButton<String>.text(
  items: items,
  value: selectedValue,
  disableWhenSingleItem: true,
  hideIconWhenSingleItem: true,
  leading: Icon(Icons.star, size: 16),
  selectedLeading: Icon(Icons.star, size: 16, color: Colors.blue),
  minWidth: 100,
  maxWidth: 250,
  onChanged: (value) => setState(() => selectedValue = value),
)
```

All `DynamicTextBaseDropdownButton` features (`leading`, `disableWhenSingleItem`, `expand`, etc.) are now built into `FlutterDropdownButton.text()`.

> **Important differences from DynamicTextBaseDropdownButton:**
> 1. `disableWhenSingleItem` default changed from **`true`** → **`false`**. If you relied on the old default, you must explicitly set `disableWhenSingleItem: true`.
> 2. `width` is optional. Omit it for content-based dynamic width (same as DynamicTextBaseDropdownButton), or provide it for fixed width (same as TextOnlyDropdownButton).

### Custom Widget with Icons

**Before (1.x):**
```dart
BasicDropdownButton<String>(
  items: [
    DropdownItem(
      value: 'home',
      child: Row(
        children: [
          Icon(Icons.home, size: 20),
          SizedBox(width: 8),
          Text('Home'),
        ],
      ),
    ),
    DropdownItem(
      value: 'settings',
      child: Row(
        children: [
          Icon(Icons.settings, size: 20),
          SizedBox(width: 8),
          Text('Settings'),
        ],
      ),
    ),
  ],
  value: selectedValue,
  onChanged: (value) => setState(() => selectedValue = value),
)
```

**After (2.0):**
```dart
FlutterDropdownButton<String>(
  items: ['home', 'settings'],
  value: selectedValue,
  hintWidget: Text('Choose option'),
  itemBuilder: (item, isSelected) => Row(
    children: [
      Icon(
        item == 'home' ? Icons.home : Icons.settings,
        size: 20,
      ),
      SizedBox(width: 8),
      Text(item),
    ],
  ),
  onChanged: (value) => setState(() => selectedValue = value),
)
```

### Separator → Item Border

**Before (1.x):**
```dart
TextOnlyDropdownButton(
  items: items,
  showSeparator: true,
  separator: Divider(height: 1, color: Colors.grey.shade300),
  // ...
)
```

**After (2.0):**
```dart
FlutterDropdownButton<String>.text(
  items: items,
  theme: DropdownStyleTheme(
    dropdown: DropdownTheme(
      itemBorder: Border(
        bottom: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      excludeLastItemBorder: true,
    ),
  ),
  // ...
)
```

### Width Behavior Changes

In 1.x, `TextOnlyDropdownButton` required a fixed `width`, and `DynamicTextBaseDropdownButton` was content-based. In 2.0, `FlutterDropdownButton.text()` handles both:

```dart
// Fixed width (like TextOnlyDropdownButton)
FlutterDropdownButton<String>.text(
  items: items,
  width: 200,
  // ...
)

// Dynamic width (like DynamicTextBaseDropdownButton)
FlutterDropdownButton<String>.text(
  items: items,
  // width omitted = content-based
  minWidth: 100,
  maxWidth: 300,
  // ...
)
```

### Static closeAll Method

**Before (1.x):**
```dart
DropdownMixin.closeAll();
```

**After (2.0):**
```dart
FlutterDropdownButton.closeAll();
```

`DropdownMixin` was removed in 3.0.0; the public API is `FlutterDropdownButton.closeAll()`.

### Quick Find & Replace Guide

For most projects, these replacements cover the majority of cases:

1. `TextOnlyDropdownButton(` → `FlutterDropdownButton<String>.text(`
2. `DynamicTextBaseDropdownButton(` → `FlutterDropdownButton<String>.text(`
3. `BasicDropdownButton<` → `FlutterDropdownButton<` (then refactor items/itemBuilder)
4. `DropdownMixin.closeAll()` → `FlutterDropdownButton.closeAll()`

---

## Migrating from Flutter's DropdownButton

### Why Migrate?

Flutter's built-in `DropdownButton` has limitations:
- Limited customization options
- Fixed positioning and layout constraints
- No built-in animation control
- Difficulty with text overflow handling
- Platform-specific rendering issues

`flutter_dropdown_button` provides:
- Complete visual customization via `DropdownStyleTheme`
- Overlay-based positioning with smart up/down detection
- Smooth, configurable animations
- Precise text overflow control with tooltip support
- Consistent cross-platform behavior

### Simple Text Dropdown

**Before:**
```dart
DropdownButton<String>(
  value: selectedValue,
  hint: Text('Select a fruit'),
  items: [
    DropdownMenuItem(value: 'apple', child: Text('Apple')),
    DropdownMenuItem(value: 'banana', child: Text('Banana')),
    DropdownMenuItem(value: 'orange', child: Text('Orange')),
  ],
  onChanged: (value) => setState(() => selectedValue = value),
)
```

**After:**
```dart
FlutterDropdownButton<String>.text(
  items: ['Apple', 'Banana', 'Orange'],
  value: selectedValue,
  hint: 'Select a fruit',
  onChanged: (value) => setState(() => selectedValue = value),
)
```

### Custom Widget Dropdown

**Before:**
```dart
DropdownButton<String>(
  value: selectedValue,
  items: options.map((option) =>
    DropdownMenuItem(value: option, child: Text(option))
  ).toList(),
  onChanged: (value) => setState(() => selectedValue = value),
)
```

**After:**
```dart
FlutterDropdownButton<String>(
  items: options,
  value: selectedValue,
  itemBuilder: (item, isSelected) => Text(item),
  onChanged: (value) => setState(() => selectedValue = value),
)
```

### Custom Styling

**Before:**
```dart
DropdownButtonFormField<String>(
  value: selectedValue,
  decoration: InputDecoration(
    border: OutlineInputBorder(),
    labelText: 'Select Option',
  ),
  items: items,
  onChanged: onChanged,
  style: TextStyle(fontSize: 16),
  dropdownColor: Colors.grey[50],
  icon: Icon(Icons.arrow_drop_down, color: Colors.blue),
)
```

**After:**
```dart
FlutterDropdownButton<String>.text(
  items: itemStrings,
  value: selectedValue,
  hint: 'Select Option',
  theme: DropdownStyleTheme(
    dropdown: DropdownTheme(
      backgroundColor: Colors.grey[50],
      border: Border.all(color: Colors.grey),
      borderRadius: 4.0,
      iconColor: Colors.blue,
      icon: Icons.arrow_drop_down,
    ),
  ),
  config: TextDropdownConfig(
    textStyle: TextStyle(fontSize: 16),
  ),
  onChanged: onChanged,
)
```

### Width Control

**Before:**
```dart
SizedBox(
  width: 200,
  child: DropdownButton<String>(
    isExpanded: true,
    value: selectedValue,
    items: items,
    onChanged: onChanged,
  ),
)
```

**After:**
```dart
FlutterDropdownButton<String>.text(
  items: itemStrings,
  value: selectedValue,
  width: 200,
  onChanged: onChanged,
)
```

### Parameter Mapping

| Flutter DropdownButton | FlutterDropdownButton (2.0) |
|---|---|
| `value` | `value` |
| `items` (DropdownMenuItem list) | `items` (value list) + `itemBuilder` |
| `onChanged` | `onChanged` |
| `hint` (Widget) | `hintWidget` (custom) or `hint` (text mode) |
| `disabledHint` | `enabled: false` |
| `elevation` | `theme.dropdown.elevation` |
| `style` | `config.textStyle` |
| `underline` | `theme.dropdown.border` |
| `icon` | `theme.dropdown.icon` |
| `iconSize` | `theme.dropdown.iconSize` |
| `isDense` | `itemHeight` + `theme.dropdown.itemPadding` |
| `isExpanded` | `width` or `expand: true` |
| `itemHeight` | `itemHeight` |
| `focusColor` | `theme.dropdown.selectedItemColor` |
| `dropdownColor` | `theme.dropdown.backgroundColor` |
| `borderRadius` | `theme.dropdown.borderRadius` |

### Form Field Integration

No direct FormField equivalent yet. Use `FormField` wrapper:

```dart
FormField<String>(
  builder: (FormFieldState<String> state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FlutterDropdownButton<String>.text(
          items: items,
          value: state.value,
          hint: 'Select option',
          onChanged: state.didChange,
        ),
        if (state.hasError)
          Text(
            state.errorText!,
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),
      ],
    );
  },
  validator: (value) => value == null ? 'Required' : null,
)
```
