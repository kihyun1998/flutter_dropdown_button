# Theming Guide

Learn how to customize the appearance of dropdown widgets using the shared theme system.

## Theme Overview

The button face, the menu container, and the item rows are styled by three sibling
themes — `DropdownButtonTheme`, `DropdownOverlayTheme`, and `DropdownItemTheme` —
carried in the `button`, `overlay`, and `item` slots of `DropdownStyleTheme`. Together
they ensure visual consistency across your application while allowing fine-grained
customization.

## Basic Theming

### Default Theme

```dart
// Uses default Material Design styling
FlutterDropdownButton<String>.text(
  items: ['Option 1', 'Option 2'],
  onChanged: (value) {},
)
```

### Custom Theme

```dart
FlutterDropdownButton<String>.text(
  items: ['Option 1', 'Option 2'],
  onChanged: (value) {},
  animationDuration: const Duration(milliseconds: 300),
  theme: DropdownStyleTheme(
    overlay: DropdownOverlayTheme(
      borderRadius: 12.0,
      elevation: 4.0,
    ),
  ),
)
```

## Theme Properties

### Animation and Behavior

```dart
DropdownOverlayTheme(
  borderRadius: 16.0,   // More rounded corners
  elevation: 12.0,      // Higher shadow
)

// Animation timing is a widget parameter, not a theme field.
// The style themes describe appearance; the widget owns behaviour.
FlutterDropdownButton<String>.text(
  items: items,
  animationDuration: const Duration(milliseconds: 250),
  onChanged: (_) {},
)
```

### Colors

```dart
DropdownStyleTheme(
  overlay: DropdownOverlayTheme(
    backgroundColor: Colors.grey[50],   // Light background
    shadowColor: Colors.black38,        // Custom shadow
  ),
  item: DropdownItemTheme(
    selectedColor: Colors.blue.withOpacity(0.1), // Blue selected items
  ),
)
```

### Borders

```dart
DropdownStyleTheme(
  button: DropdownButtonTheme(
    border: Border.all(color: Colors.blue, width: 2.0),
  ),
  overlay: DropdownOverlayTheme(
    border: Border.all(color: Colors.blue, width: 2.0),
  ),
)
```

### Padding and Spacing

```dart
DropdownStyleTheme(
  button: DropdownButtonTheme(
    padding: EdgeInsets.all(16),
  ),
  item: DropdownItemTheme(
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Space between items
  ),
)
```

### Item Styling

```dart
DropdownItemTheme(
  borderRadius: 8.0,                    // Individual item border radius
  margin: EdgeInsets.all(4),            // Margin around each item
  hoverColor: Colors.grey[100],         // Hover effect color
  splashColor: Colors.blue[50],         // Touch splash color
  highlightColor: Colors.blue[25],      // Highlight color
)
```

### The checkbox in a multi-select row

The box is a `FlutterCheckbox` (the `flutter_checkbox` package). Style it with
`DropdownCheckboxTheme`, the `checkbox` slot on `DropdownStyleTheme`:

```dart
FlutterMultiSelectDropdown<String>(
  theme: DropdownStyleTheme(
    checkbox: DropdownCheckboxTheme(
      activeColor: Colors.teal,        // fill of a checked box
      checkColor: Colors.white,        // the checkmark
      borderColor: Colors.grey,        // an unchecked box's outline
      borderWidth: 2,
      shape: CheckboxShape.rectangle,  // or CheckboxShape.circle
      borderRadius: 4,
    ),
  ),
  ...
)
```

Only the fields that render on the presentational box are here — `activeColor`,
`checkColor`, `inactiveColor`, `borderColor`, `borderWidth`, `shape`,
`borderRadius`, `size`, `checkStrokeWidth`, `checkScale`, `mouseCursor`. The box
is drawn `onChanged: null` (a tap falls through to the row) with its semantics
excluded, so `flutter_checkbox`'s hover/focus/splash ring and disabled-opacity
never appear. `mouseCursor` is the exception — its `MouseRegion` is installed
either way, so set it to `SystemMouseCursors.click` to match the row's cursor.

`activeColor` fills a **checked** box. Unlike Material, no workaround is needed:
`FlutterCheckbox` is drawn `onChanged: null` but stays `enabled`, so it is
presentational without being greyed and the accent is read straight.
`inactiveColor` fills an unchecked box (transparent by default) and `borderColor`
outlines it; `CheckboxShape` is exported from this package.

**A `Theme` wrapped around the dropdown does not reach the box.** The menu is
drawn in the root `Overlay`, out of a local `Theme`'s subtree.
`DropdownCheckboxTheme` is how you reach just this dropdown's boxes — a null
field defers to the ambient `ThemeData`. Everything *around* the box — the row's
hover, splash, margin, radius, and the selected row's background — stays
`DropdownItemTheme`'s, exactly as for a single-select menu.

The widgets `itemLeadingBuilder` and `itemTrailingBuilder` return are **yours**.
The package places them and styles nothing about them; colour and size are
whatever you build:

```dart
itemLeadingBuilder: (v) => Icon(osIcon[v], size: 18, color: theme.iconColor),
itemTrailingBuilder: (v) => Text('${counts[v]}',
    style: TextStyle(color: Colors.grey.shade600)),
```

`itemHeight` must leave room for the box. A `FlutterCheckbox` is `size` logical
pixels square — **24×24** by default — with no Material tap-target padding to
account for. Shrink the box with `size` for a shorter row:

```dart
FlutterMultiSelectDropdown<String>(
  itemHeight: 40,
  theme: DropdownStyleTheme(
    checkbox: DropdownCheckboxTheme(size: 18),
  ),
  ...
)
```

## Advanced Theming

### Custom Decorations

For complete control over appearance, use custom decorations:

```dart
DropdownStyleTheme(
  overlay: DropdownOverlayTheme(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
      border: Border.all(color: Colors.grey[300]!),
    ),
  ),
  button: DropdownButtonTheme(
    decoration: BoxDecoration(
      color: Colors.grey[50],
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey[400]!),
    ),
  ),
)
```

### Gradient Backgrounds

```dart
DropdownOverlayTheme(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Colors.blue[50]!, Colors.white],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    borderRadius: BorderRadius.circular(12),
  ),
)
```

## Theme Sharing

### Global Theme

Create a shared theme for consistency:

```dart
class AppThemes {
  static const primaryDropdownStyle = DropdownStyleTheme(
    overlay: DropdownOverlayTheme(
      borderRadius: 12.0,
      elevation: 4.0,
      backgroundColor: Colors.white,
    ),
    item: DropdownItemTheme(
      selectedColor: Color(0xFF1976D2),
    ),
  );

  static const secondaryDropdownStyle = DropdownStyleTheme(
    overlay: DropdownOverlayTheme(
      borderRadius: 8.0,
      elevation: 2.0,
      backgroundColor: Color(0xFFF5F5F5),
    ),
  );
}
```

### Usage

```dart
FlutterDropdownButton<String>.text(
  theme: AppThemes.primaryDropdownStyle,
  // ... other properties
)
```

## Theme Variations

### Material 3 Style

```dart
DropdownStyleTheme(
  overlay: DropdownOverlayTheme(
    borderRadius: 4.0,
    elevation: 3.0,
    backgroundColor: Theme.of(context).colorScheme.surface,
  ),
  item: DropdownItemTheme(
    selectedColor: Theme.of(context).colorScheme.primaryContainer,
    borderRadius: 12.0,
    margin: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
  ),
)
```

### Modern Card Style

```dart
DropdownStyleTheme(
  overlay: DropdownOverlayTheme(
    borderRadius: 12.0,
    elevation: 2.0,
    backgroundColor: Colors.white,
  ),
  item: DropdownItemTheme(
    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    borderRadius: 8.0,
    hoverColor: Color(0xFFF5F5F5),
    selectedColor: Color(0xFFE3F2FD),
  ),
)
```

### iOS Style

```dart
DropdownOverlayTheme(
  borderRadius: 10.0,
  elevation: 0.5,
  border: Border.all(
    color: CupertinoColors.systemGrey4,
    width: 1.0,
  ),
  backgroundColor: CupertinoColors.systemBackground,
)
```

### Dark Theme

```dart
DropdownStyleTheme(
  overlay: DropdownOverlayTheme(
    backgroundColor: Colors.grey[800],
    shadowColor: Colors.black54,
    border: Border.all(color: Colors.grey[600]!),
  ),
  item: DropdownItemTheme(
    selectedColor: Colors.blue[800],
  ),
)
```

## Dynamic Theming

### Theme Based on System

```dart
Widget buildDropdown(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  
  return FlutterDropdownButton<String>.text(
    theme: DropdownStyleTheme(
      overlay: DropdownOverlayTheme(
        backgroundColor: isDark ? Colors.grey[800] : Colors.white,
        border: Border.all(
          color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
        ),
      ),
      item: DropdownItemTheme(
        selectedColor: isDark 
            ? Colors.blue[800] 
            : Colors.blue[50],
      ),
    ),
    // ... other properties
  );
}
```

### Responsive Theming

```dart
Widget buildResponsiveDropdown(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final isTablet = screenWidth > 600;
  
  return FlutterDropdownButton<String>.text(
    theme: DropdownStyleTheme(
      overlay: DropdownOverlayTheme(
        borderRadius: isTablet ? 12.0 : 8.0,
        elevation: isTablet ? 8.0 : 4.0,
      ),
      item: DropdownItemTheme(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 20 : 16,
          vertical: isTablet ? 16 : 12,
        ),
      ),
    ),
    // ... other properties
  );
}
```

## Best Practices

### 1. Consistency
Use the same theme across similar dropdown instances in your app.

### 2. Accessibility
Ensure sufficient contrast between text and background colors.

```dart
DropdownStyleTheme(
  overlay: DropdownOverlayTheme(
    backgroundColor: Colors.white,       // High contrast with text
  ),
  item: DropdownItemTheme(
    selectedColor: Colors.blue[100],     // Light enough for dark text
  ),
)
```

### 3. Performance
Reuse theme instances instead of creating new ones:

```dart
// Good
static const myTheme = DropdownOverlayTheme(borderRadius: 12.0);

// Avoid
DropdownOverlayTheme(borderRadius: 12.0) // Creates new instance each time
```

### 4. Platform Adaptation
Consider platform-specific design guidelines:

```dart
DropdownOverlayTheme get platformTheme {
  if (Platform.isIOS) {
    return const DropdownOverlayTheme(
      borderRadius: 10.0,
      elevation: 0.5,
    );
  }
  return const DropdownOverlayTheme(
    borderRadius: 4.0,
    elevation: 3.0,
  );
}
```