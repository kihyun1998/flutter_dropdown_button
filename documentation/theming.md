# Theming Guide

Learn how to customize the appearance of dropdown widgets using the shared theme system.

## DropdownTheme Overview

The `DropdownTheme` class provides a unified way to style all dropdown variants. It ensures visual consistency across your application while allowing fine-grained customization.

## Basic Theming

### Default Theme

```dart
// Uses default Material Design styling
TextOnlyDropdownButton(
  items: ['Option 1', 'Option 2'],
  onChanged: (value) {},
)
```

### Custom Theme

```dart
TextOnlyDropdownButton(
  items: ['Option 1', 'Option 2'],
  onChanged: (value) {},
  theme: DropdownTheme(
    borderRadius: 12.0,
    elevation: 4.0,
    animationDuration: Duration(milliseconds: 300),
  ),
)
```

## Theme Properties

### Animation and Behavior

```dart
DropdownTheme(
  animationDuration: Duration(milliseconds: 250),  // Slower animations
  borderRadius: 16.0,                              // More rounded corners
  elevation: 12.0,                                 // Higher shadow
)
```

### Colors

```dart
DropdownTheme(
  backgroundColor: Colors.grey[50],                // Light background
  selectedItemColor: Colors.blue.withOpacity(0.1), // Blue selected items
  shadowColor: Colors.black38,                     // Custom shadow
)
```

### Borders

```dart
DropdownTheme(
  border: Border.all(
    color: Colors.blue,
    width: 2.0,
  ),
)
```

### Padding

```dart
DropdownTheme(
  itemPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  buttonPadding: EdgeInsets.all(16),
)
```

## Advanced Theming

### Custom Decorations

For complete control over appearance, use custom decorations:

```dart
DropdownTheme(
  overlayDecoration: BoxDecoration(
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
  buttonDecoration: BoxDecoration(
    color: Colors.grey[50],
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.grey[400]!),
  ),
)
```

### Gradient Backgrounds

```dart
DropdownTheme(
  overlayDecoration: BoxDecoration(
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
  static const primaryDropdownTheme = DropdownTheme(
    borderRadius: 12.0,
    elevation: 4.0,
    animationDuration: Duration(milliseconds: 250),
    backgroundColor: Colors.white,
    selectedItemColor: Color(0xFF1976D2),
  );
  
  static const secondaryDropdownTheme = DropdownTheme(
    borderRadius: 8.0,
    elevation: 2.0,
    backgroundColor: Color(0xFFF5F5F5),
  );
}
```

### Usage

```dart
TextOnlyDropdownButton(
  theme: AppThemes.primaryDropdownTheme,
  // ... other properties
)
```

## Theme Variations

### Material 3 Style

```dart
DropdownTheme(
  borderRadius: 4.0,
  elevation: 3.0,
  backgroundColor: Theme.of(context).colorScheme.surface,
  selectedItemColor: Theme.of(context).colorScheme.primaryContainer,
)
```

### iOS Style

```dart
DropdownTheme(
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
DropdownTheme(
  backgroundColor: Colors.grey[800],
  selectedItemColor: Colors.blue[800],
  shadowColor: Colors.black54,
  border: Border.all(color: Colors.grey[600]!),
)
```

## Dynamic Theming

### Theme Based on System

```dart
Widget buildDropdown(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  
  return TextOnlyDropdownButton(
    theme: DropdownTheme(
      backgroundColor: isDark ? Colors.grey[800] : Colors.white,
      selectedItemColor: isDark 
          ? Colors.blue[800] 
          : Colors.blue[50],
      border: Border.all(
        color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
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
  
  return TextOnlyDropdownButton(
    theme: DropdownTheme(
      borderRadius: isTablet ? 12.0 : 8.0,
      elevation: isTablet ? 8.0 : 4.0,
      itemPadding: EdgeInsets.symmetric(
        horizontal: isTablet ? 20 : 16,
        vertical: isTablet ? 16 : 12,
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
DropdownTheme(
  selectedItemColor: Colors.blue[100], // Light enough for dark text
  backgroundColor: Colors.white,       // High contrast with text
)
```

### 3. Performance
Reuse theme instances instead of creating new ones:

```dart
// Good
static const myTheme = DropdownTheme(borderRadius: 12.0);

// Avoid
DropdownTheme(borderRadius: 12.0) // Creates new instance each time
```

### 4. Platform Adaptation
Consider platform-specific design guidelines:

```dart
DropdownTheme get platformTheme {
  if (Platform.isIOS) {
    return const DropdownTheme(
      borderRadius: 10.0,
      elevation: 0.5,
    );
  }
  return const DropdownTheme(
    borderRadius: 4.0,
    elevation: 3.0,
  );
}
```