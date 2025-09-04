# Migration Guide

Learn how to migrate from Flutter's built-in DropdownButton to flutter_dropdown_button widgets.

## Why Migrate?

### Limitations of Flutter's DropdownButton

- Limited customization options
- Fixed positioning and layout constraints  
- No built-in animation control
- Difficulty with text overflow handling
- Platform-specific rendering issues
- No overlay-based positioning

### Benefits of flutter_dropdown_button

- ✅ Complete visual customization
- ✅ Smooth, configurable animations
- ✅ Precise text overflow control
- ✅ Overlay-based positioning
- ✅ Multiple specialized variants
- ✅ Consistent cross-platform behavior

## Basic Migration

### From DropdownButton to CustomDropdown

**Before (DropdownButton):**
```dart
DropdownButton<String>(
  value: selectedValue,
  hint: Text('Select an option'),
  items: [
    DropdownMenuItem(value: 'apple', child: Text('Apple')),
    DropdownMenuItem(value: 'banana', child: Text('Banana')),
    DropdownMenuItem(value: 'orange', child: Text('Orange')),
  ],
  onChanged: (value) {
    setState(() {
      selectedValue = value;
    });
  },
)
```

**After (CustomDropdown):**
```dart
CustomDropdown<String>(
  value: selectedValue,
  hint: Text('Select an option'),
  items: [
    DropdownItem(value: 'apple', child: Text('Apple')),
    DropdownItem(value: 'banana', child: Text('Banana')),
    DropdownItem(value: 'orange', child: Text('Orange')),
  ],
  onChanged: (value) {
    setState(() {
      selectedValue = value;
    });
  },
)
```

### From DropdownButton to TextOnlyDropdown

**Before (DropdownButton):**
```dart
DropdownButton<String>(
  value: selectedValue,
  hint: Text('Select fruit'),
  items: [
    DropdownMenuItem(value: 'apple', child: Text('Apple')),
    DropdownMenuItem(value: 'banana', child: Text('Banana')),
  ],
  onChanged: (value) {
    setState(() {
      selectedValue = value;
    });
  },
)
```

**After (TextOnlyDropdown):**
```dart
TextOnlyDropdown(
  value: selectedValue,
  hint: 'Select fruit',
  items: ['Apple', 'Banana'],
  onChanged: (value) {
    setState(() {
      selectedValue = value;
    });
  },
)
```

## Migration Mapping

### Constructor Parameters

| DropdownButton | CustomDropdown | TextOnlyDropdown |
|---------------|----------------|------------------|
| `value` | `value` | `value` |
| `items` | `items` | `items` |
| `onChanged` | `onChanged` | `onChanged` |
| `hint` | `hint` | `hint` |
| `disabledHint` | N/A | N/A (use `enabled: false`) |
| `elevation` | `decoration` | `theme.elevation` |
| `style` | N/A | `config.textStyle` |
| `underline` | N/A | `theme.border` |
| `icon` | N/A | N/A (always arrow) |
| `iconSize` | N/A | N/A |
| `isDense` | `itemHeight` | `itemHeight` |
| `isExpanded` | `width` | `width` |
| `itemHeight` | `itemHeight` | `itemHeight` |
| `focusColor` | `theme.selectedItemColor` | `theme.selectedItemColor` |
| `autofocus` | N/A | N/A |
| `dropdownColor` | `decoration` | `theme.backgroundColor` |
| `borderRadius` | `borderRadius` | `theme.borderRadius` |
| `enableFeedback` | N/A | N/A |

### DropdownMenuItem vs DropdownItem

**Before:**
```dart
DropdownMenuItem<String>(
  value: 'apple',
  child: Row(
    children: [
      Icon(Icons.apple),
      SizedBox(width: 8),
      Text('Apple'),
    ],
  ),
  onTap: () => print('Apple tapped'),
)
```

**After:**
```dart
DropdownItem<String>(
  value: 'apple',
  child: Row(
    children: [
      Icon(Icons.apple),
      SizedBox(width: 8),
      Text('Apple'),
    ],
  ),
  onTap: () => print('Apple tapped'),
)
```

## Advanced Migration Examples

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
TextOnlyDropdown(
  value: selectedValue,
  hint: 'Select Option',
  items: itemStrings,
  onChanged: onChanged,
  theme: DropdownTheme(
    backgroundColor: Colors.grey[50],
    border: Border.all(color: Colors.grey),
    borderRadius: 4.0,
  ),
  config: TextDropdownConfig(
    textStyle: TextStyle(fontSize: 16),
  ),
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
CustomDropdown<String>(
  width: 200,
  value: selectedValue,
  items: items,
  onChanged: onChanged,
)
```

### Dense Dropdown

**Before:**
```dart
DropdownButton<String>(
  isDense: true,
  itemHeight: 40,
  value: selectedValue,
  items: items,
  onChanged: onChanged,
)
```

**After:**
```dart
TextOnlyDropdown(
  itemHeight: 40,
  value: selectedValue,
  items: itemStrings,
  onChanged: onChanged,
  theme: DropdownTheme(
    itemPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  ),
)
```

## Handling Breaking Changes

### 1. No Direct Style Inheritance

DropdownButton inherits text style from parent. Our dropdowns don't.

**Solution:**
```dart
TextOnlyDropdown(
  config: TextDropdownConfig(
    textStyle: DefaultTextStyle.of(context).style,
  ),
  // ... other properties
)
```

### 2. Different Animation Behavior

DropdownButton has platform-specific animations. Our dropdowns have consistent animations.

**Solution:**
```dart
TextOnlyDropdown(
  theme: DropdownTheme(
    animationDuration: Duration(milliseconds: 150), // Adjust as needed
  ),
  // ... other properties
)
```

### 3. Form Field Integration

No direct FormField equivalent yet.

**Workaround:**
```dart
FormField<String>(
  builder: (FormFieldState<String> state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextOnlyDropdown(
          value: state.value,
          items: items,
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

## Step-by-Step Migration

### 1. Install Package
```yaml
dependencies:
  flutter_dropdown_button: ^1.1.0
```

### 2. Replace Imports
```dart
// Remove
import 'package:flutter/material.dart';

// Add
import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
```

### 3. Update Widget Declarations

For simple text dropdowns, replace `DropdownButton` with `TextOnlyDropdown`:
```dart
// Before
DropdownButton<String>

// After  
TextOnlyDropdown
```

For complex dropdowns with custom widgets, use `CustomDropdown`:
```dart
// Before
DropdownButton<String>

// After
CustomDropdown<String>
```

### 4. Update Items

For TextOnlyDropdown:
```dart
// Before
items: options.map((option) => 
  DropdownMenuItem(value: option, child: Text(option))
).toList(),

// After
items: options,
```

For CustomDropdown:
```dart
// Before
items: options.map((option) => 
  DropdownMenuItem(value: option.value, child: option.widget)
).toList(),

// After
items: options.map((option) => 
  DropdownItem(value: option.value, child: option.widget)
).toList(),
```

### 5. Test and Customize

After migration, test your dropdowns and add customizations:
```dart
TextOnlyDropdown(
  // ... migrated properties
  theme: DropdownTheme(
    borderRadius: 8.0,
    animationDuration: Duration(milliseconds: 200),
  ),
  config: TextDropdownConfig(
    overflow: TextOverflow.ellipsis,
  ),
)
```

## Common Issues and Solutions

### Issue: Text Overflow
**Problem:** Long text gets cut off awkwardly.
**Solution:** Use TextOnlyDropdown with proper overflow configuration.

### Issue: Inconsistent Styling
**Problem:** Dropdowns look different across platforms.
**Solution:** Use DropdownTheme for consistent styling.

### Issue: Animation Feels Wrong
**Problem:** Animation doesn't match app's feel.
**Solution:** Customize animationDuration in DropdownTheme.

### Issue: Width Problems
**Problem:** Dropdown width doesn't behave as expected.
**Solution:** Use width, maxWidth, or minWidth parameters for precise control.

## Performance Considerations

The new dropdowns are generally more performant due to:
- Efficient overlay rendering
- Proper animation disposal
- Minimal rebuilds

However, ensure you:
1. Reuse theme instances
2. Don't create new configurations unnecessarily
3. Use const constructors where possible