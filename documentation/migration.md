# Migration Guide

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

`DropdownMixin.closeAll()` still works internally, but the public API is now `FlutterDropdownButton.closeAll()`.

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
