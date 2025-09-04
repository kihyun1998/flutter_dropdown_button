# API Reference

Complete reference for all classes and widgets in the flutter_dropdown_button package.

## BasicDropdownButton<T>

A highly customizable dropdown widget using OverlayEntry for better control.

### Constructor

```dart
BasicDropdownButton<T>({
  Key? key,
  required List<DropdownItem<T>> items,
  required ValueChanged<T?> onChanged,
  T? value,
  Widget? hint,
  double height = 200.0,
  double itemHeight = 48.0,
  double borderRadius = 8.0,
  Duration animationDuration = const Duration(milliseconds: 200),
  BoxDecoration? decoration,
  double? width,
  double? maxWidth,
  double? minWidth,
})
```

### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `items` | `List<DropdownItem<T>>` | required | List of dropdown items |
| `onChanged` | `ValueChanged<T?>` | required | Callback when selection changes |
| `value` | `T?` | null | Currently selected value |
| `hint` | `Widget?` | null | Widget to show when no item selected |
| `height` | `double` | 200.0 | Maximum height of dropdown overlay |
| `itemHeight` | `double` | 48.0 | Height of each dropdown item |
| `borderRadius` | `double` | 8.0 | Border radius for button and overlay |
| `animationDuration` | `Duration` | 200ms | Animation duration for show/hide |
| `decoration` | `BoxDecoration?` | null | Custom decoration for overlay |
| `width` | `double?` | null | Fixed width for dropdown |
| `maxWidth` | `double?` | null | Maximum width constraint |
| `minWidth` | `double?` | null | Minimum width constraint |

## TextOnlyDropdownButton

A dropdown widget specifically designed for text-only content with precise text control.

### Constructor

```dart
TextOnlyDropdownButton({
  Key? key,
  required List<String> items,
  required ValueChanged<String?> onChanged,
  String? value,
  String? hint,
  DropdownTheme? theme,
  TextDropdownConfig? config,
  double? width,
  double? maxWidth,
  double? minWidth,
  double height = 200.0,
  double itemHeight = 48.0,
  bool enabled = true,
})
```

### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `items` | `List<String>` | required | List of text options |
| `onChanged` | `ValueChanged<String?>` | required | Callback when selection changes |
| `value` | `String?` | null | Currently selected value |
| `hint` | `String?` | null | Hint text when no item selected |
| `theme` | `DropdownTheme?` | null | Visual theme configuration |
| `config` | `TextDropdownConfig?` | null | Text-specific configuration |
| `width` | `double?` | null | Fixed width for dropdown |
| `maxWidth` | `double?` | null | Maximum width constraint |
| `minWidth` | `double?` | null | Minimum width constraint |
| `height` | `double` | 200.0 | Maximum height of dropdown overlay |
| `itemHeight` | `double` | 48.0 | Height of each dropdown item |
| `enabled` | `bool` | true | Whether dropdown is interactive |

## DropdownPositionResult

Position calculation result for dropdown overlay positioning.

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `height` | `double` | The calculated height for the dropdown overlay |
| `openDown` | `bool` | Whether the dropdown should open downward (true) or upward (false) |
| `transformAlignment` | `Alignment` | The transform alignment for animations |
| `topPosition` | `double` | The calculated top position for the overlay |

## DropdownItem<T>

Represents an item in a BasicDropdownButton.

### Constructor

```dart
DropdownItem<T>({
  required T value,
  required Widget child,
  VoidCallback? onTap,
})
```

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `value` | `T` | The value associated with this item |
| `child` | `Widget` | The widget to display for this item |
| `onTap` | `VoidCallback?` | Optional callback when item is tapped |

## DropdownTheme

Shared theme configuration for all dropdown widgets.

### Constructor

```dart
DropdownTheme({
  Duration animationDuration = const Duration(milliseconds: 200),
  double borderRadius = 8.0,
  double elevation = 8.0,
  Color? backgroundColor,
  Border? border,
  Color? selectedItemColor,
  Color? itemHoverColor,
  Color? shadowColor,
  BoxDecoration? overlayDecoration,
  BoxDecoration? buttonDecoration,
  EdgeInsets itemPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  EdgeInsets buttonPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
})
```

### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `animationDuration` | `Duration` | 200ms | Duration of show/hide animation |
| `borderRadius` | `double` | 8.0 | Border radius for components |
| `elevation` | `double` | 8.0 | Shadow elevation of overlay |
| `backgroundColor` | `Color?` | null | Background color of overlay |
| `border` | `Border?` | null | Border style for components |
| `selectedItemColor` | `Color?` | null | Background color of selected item |
| `itemHoverColor` | `Color?` | null | Background color on hover |
| `shadowColor` | `Color?` | null | Shadow color for overlay |
| `overlayDecoration` | `BoxDecoration?` | null | Custom decoration for overlay |
| `buttonDecoration` | `BoxDecoration?` | null | Custom decoration for button |
| `itemPadding` | `EdgeInsets` | 16h, 12v | Padding for dropdown items |
| `buttonPadding` | `EdgeInsets` | 16h, 12v | Padding for dropdown button |

## DropdownMixin<T>

A mixin that provides common dropdown functionality including positioning, animations, and overlay management.

This mixin eliminates code duplication between different dropdown variants by providing shared functionality for smart positioning, animation setup, overlay management, and common state management.

### Key Features

- **Smart Positioning**: Automatically opens upward when insufficient space below
- **Dynamic Height Adjustment**: Prevents screen overflow with adaptive height
- **Animation Management**: Consistent scale and opacity animations
- **Overlay Lifecycle**: Proper creation, insertion, and disposal
- **Outside-tap Dismissal**: Automatic closure when tapping outside

### Usage

```dart
class _MyDropdownState extends State<MyDropdown> 
    with SingleTickerProviderStateMixin, DropdownMixin<MyDropdown> {
  
  @override
  Widget buildOverlayContent(double height) {
    return Container(height: height, child: ListView(...));
  }
  
  @override
  Duration get animationDuration => Duration(milliseconds: 200);
  // ... other required implementations
}
```

### Abstract Properties

| Property | Type | Description |
|----------|------|-------------|
| `animationDuration` | `Duration` | Duration of show/hide animations |
| `itemHeight` | `double` | Height of each dropdown item |
| `maxDropdownHeight` | `double` | Maximum height of dropdown overlay |
| `itemCount` | `int` | Number of items in the dropdown |
| `isEnabled` | `bool` | Whether dropdown is interactive (default: true) |
| `screenMargin` | `double` | Safety margin from screen edges (default: 8.0) |
| `buttonGap` | `double` | Gap between button and overlay (default: 4.0) |
| `minVisibleItems` | `int` | Minimum visible items when constrained (default: 2) |
| `overlayElevation` | `double` | Elevation of overlay Material (default: 8.0) |
| `overlayBorderRadius` | `double` | Border radius for overlay (default: 8.0) |
| `overlayShadowColor` | `Color?` | Shadow color for overlay (default: null) |

### Abstract Methods

| Method | Return Type | Description |
|--------|-------------|-------------|
| `buildOverlayContent(double height)` | `Widget` | Builds the scrollable content for the overlay |
| `buildOverlayDecoration()` | `BoxDecoration?` | Builds custom decoration (null for default) |
| `onDropdownItemSelected()` | `void` | Called when an item is selected |

### Available Methods

| Method | Description |
|--------|-------------|
| `initializeDropdown()` | Initialize animations and controllers |
| `disposeDropdown()` | Dispose of dropdown resources |
| `toggleDropdown()` | Toggle between open/closed states |
| `openDropdown()` | Open the dropdown overlay |
| `closeDropdown()` | Close the dropdown overlay |
| `calculateDropdownPosition()` | Calculate optimal position and height |

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
| `semanticsLabel` | `String?` | null | Semantic label for accessibility |

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