# Text Configuration Guide

Comprehensive guide for configuring text behavior in TextOnlyDropdown widgets.

## TextDropdownConfig Overview

The `TextDropdownConfig` class provides precise control over text rendering, overflow behavior, and styling in `TextOnlyDropdown` widgets.

## Basic Configuration

### Default Configuration

```dart
TextOnlyDropdown(
  items: ['Short', 'Medium text', 'Very long text that might overflow'],
  onChanged: (value) {},
  // Uses TextDropdownConfig.defaultConfig by default
)
```

### Custom Configuration

```dart
TextOnlyDropdown(
  items: ['Option 1', 'Option 2'],
  onChanged: (value) {},
  config: TextDropdownConfig(
    overflow: TextOverflow.ellipsis,
    maxLines: 1,
    textStyle: TextStyle(fontSize: 16),
  ),
)
```

## Text Overflow Control

### Ellipsis (Default)

Shows "..." when text is too long:

```dart
TextDropdownConfig(
  overflow: TextOverflow.ellipsis,
  maxLines: 1,
)
```

Result: `"This is a very long text t..."`

### Fade

Gradually fades out overflowing text:

```dart
TextDropdownConfig(
  overflow: TextOverflow.fade,
  maxLines: 1,
)
```

### Clip

Cuts off text abruptly:

```dart
TextDropdownConfig(
  overflow: TextOverflow.clip,
  maxLines: 1,
)
```

Result: `"This is a very long text t"`

### Visible

Allows text to overflow (may cause layout issues):

```dart
TextDropdownConfig(
  overflow: TextOverflow.visible,
  maxLines: 1,
)
```

## Multi-line Text

### Basic Multi-line

```dart
TextDropdownConfig(
  maxLines: 3,
  overflow: TextOverflow.ellipsis,
  softWrap: true,
)
```

### Unlimited Lines

```dart
TextDropdownConfig(
  maxLines: null,  // No limit
  overflow: TextOverflow.visible,
  softWrap: true,
)
```

### Explicit Line Breaks

Handle `\n` characters in text:

```dart
TextOnlyDropdown(
  items: [
    'Single line',
    'Multi-line text\nwith explicit\nbreaks',
  ],
  config: TextDropdownConfig(
    maxLines: 3,
    softWrap: true,
  ),
  itemHeight: 60, // Increase height for multi-line
  onChanged: (value) {},
)
```

## Text Styling

### Basic Styling

```dart
TextDropdownConfig(
  textStyle: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
  ),
  hintStyle: TextStyle(
    fontSize: 16,
    color: Colors.grey[500],
    fontStyle: FontStyle.italic,
  ),
)
```

### Selected Item Styling

```dart
TextDropdownConfig(
  textStyle: TextStyle(fontSize: 16),
  selectedTextStyle: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.blue[700],
  ),
)
```

### Custom Font

```dart
TextDropdownConfig(
  textStyle: TextStyle(
    fontFamily: 'Roboto',
    fontSize: 14,
    letterSpacing: 0.5,
  ),
)
```

## Text Alignment

### Left Align (Default)

```dart
TextDropdownConfig(
  textAlign: TextAlign.start,
)
```

### Center Align

```dart
TextDropdownConfig(
  textAlign: TextAlign.center,
)
```

### Right Align

```dart
TextDropdownConfig(
  textAlign: TextAlign.end,
)
```

### Justify

```dart
TextDropdownConfig(
  textAlign: TextAlign.justify,
  maxLines: null,
  softWrap: true,
)
```

## Predefined Configurations

### Default Single-line

```dart
TextOnlyDropdown(
  config: TextDropdownConfig.defaultConfig,
  // Equivalent to:
  // TextDropdownConfig(
  //   overflow: TextOverflow.ellipsis,
  //   maxLines: 1,
  // )
)
```

### Multi-line Display

```dart
TextOnlyDropdown(
  config: TextDropdownConfig.multiLine,
  itemHeight: 80, // Increase height for multi-line
  // Equivalent to:
  // TextDropdownConfig(
  //   maxLines: null,
  //   overflow: TextOverflow.visible,
  //   softWrap: true,
  // )
)
```

### Center Aligned

```dart
TextOnlyDropdown(
  config: TextDropdownConfig.centered,
  // Equivalent to:
  // TextDropdownConfig(
  //   textAlign: TextAlign.center,
  // )
)
```

### Fade Overflow

```dart
TextOnlyDropdown(
  config: TextDropdownConfig.fadeOverflow,
  // Equivalent to:
  // TextDropdownConfig(
  //   overflow: TextOverflow.fade,
  // )
)
```

## Advanced Configuration

### RTL Support

```dart
TextDropdownConfig(
  textDirection: TextDirection.rtl,
  textAlign: TextAlign.start, // Will align to right in RTL
)
```

### Accessibility

```dart
TextDropdownConfig(
  semanticsLabel: 'Fruit selection dropdown',
  textScaleFactor: 1.2, // Larger text for accessibility
)
```

### Locale-specific Rendering

```dart
TextDropdownConfig(
  locale: Locale('ar'), // Arabic locale
  textDirection: TextDirection.rtl,
)
```

## Dynamic Configuration

### Responsive Text Size

```dart
TextDropdownConfig buildConfig(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final isTablet = screenWidth > 600;
  
  return TextDropdownConfig(
    textStyle: TextStyle(
      fontSize: isTablet ? 18 : 14,
    ),
    maxLines: isTablet ? 2 : 1,
  );
}
```

### Theme-based Configuration

```dart
TextDropdownConfig buildThemedConfig(BuildContext context) {
  final theme = Theme.of(context);
  
  return TextDropdownConfig(
    textStyle: theme.textTheme.bodyMedium,
    hintStyle: theme.textTheme.bodyMedium?.copyWith(
      color: theme.hintColor,
    ),
    selectedTextStyle: theme.textTheme.bodyMedium?.copyWith(
      color: theme.primaryColor,
      fontWeight: FontWeight.w600,
    ),
  );
}
```

## Common Use Cases

### Search Dropdown with Long Options

```dart
TextOnlyDropdown(
  items: [
    'Apple Inc. (AAPL)',
    'Microsoft Corporation (MSFT)',
    'Alphabet Inc. Class A (GOOGL)',
  ],
  maxWidth: 200,
  config: TextDropdownConfig(
    overflow: TextOverflow.ellipsis,
    textStyle: TextStyle(fontSize: 14),
  ),
  onChanged: (value) {},
)
```

### Multi-line Description Dropdown

```dart
TextOnlyDropdown(
  items: [
    'Option 1\nShort description',
    'Option 2\nA longer description that explains the purpose of this option',
  ],
  itemHeight: 60,
  config: TextDropdownConfig(
    maxLines: 2,
    textStyle: TextStyle(fontSize: 14, height: 1.3),
    overflow: TextOverflow.ellipsis,
  ),
  onChanged: (value) {},
)
```

### Language Selector

```dart
TextOnlyDropdown(
  items: ['English', '中文', 'العربية', 'עברית'],
  config: TextDropdownConfig(
    textAlign: TextAlign.center,
    textStyle: TextStyle(fontSize: 16),
  ),
  onChanged: (value) {},
)
```

## Best Practices

### 1. Match Item Height to Content
```dart
// For single-line text
itemHeight: 48

// For two-line text
itemHeight: 64

// For three-line text  
itemHeight: 80
```

### 2. Consistent Text Scaling
```dart
TextDropdownConfig(
  textScaleFactor: MediaQuery.of(context).textScaleFactor,
)
```

### 3. Readable Text Contrast
Ensure text is readable against the background:
```dart
TextDropdownConfig(
  textStyle: TextStyle(
    color: Theme.of(context).textTheme.bodyMedium?.color,
  ),
)
```

### 4. Overflow Handling
Choose appropriate overflow behavior for your content:
- **Ellipsis**: Best for single-line critical text
- **Fade**: Good for less important overflow text
- **Multi-line**: For descriptive or detailed content