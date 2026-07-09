# API Reference

Complete reference for all classes and widgets in the flutter_dropdown_button package.

## BaseDropdownButton<T>

Abstract base class for all dropdown button variants. Provides common properties and structure while allowing each variant to customize their specific rendering and behavior.

### Constructor

```dart
BaseDropdownButton<T>({
  Key? key,
  required ValueChanged<T?> onChanged,
  T? value,
  double height = 200.0,
  double itemHeight = 48.0,
  Duration animationDuration = const Duration(milliseconds: 200),
  double? width,
  double? maxWidth,
  double? minWidth,
  DropdownTheme? theme,
  bool enabled = true,
})
```

### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `onChanged` | `ValueChanged<T?>` | required | Callback when selection changes |
| `value` | `T?` | null | Currently selected value |
| `height` | `double` | 200.0 | Maximum height of dropdown overlay |
| `itemHeight` | `double` | 48.0 | Height of each dropdown item |
| `animationDuration` | `Duration` | 200ms | Animation duration for show/hide |
| `width` | `double?` | null | Fixed width for dropdown |
| `maxWidth` | `double?` | null | Maximum width constraint |
| `minWidth` | `double?` | null | Minimum width constraint |
| `theme` | `DropdownTheme?` | null | Custom theme configuration |
| `enabled` | `bool` | true | Whether dropdown is interactive |

### Creating Custom Dropdowns

To create a custom dropdown widget, extend `BaseDropdownButton` and implement the required abstract methods:

```dart
class MyCustomDropdown extends BaseDropdownButton<MyItemType> {
  // Your custom properties
}

class _MyCustomDropdownState extends BaseDropdownButtonState<MyCustomDropdown, MyItemType> {
  @override
  Widget buildSelectedWidget() {
    // Return widget for selected value display
  }
  
  @override
  Widget buildItemWidget(MyItemType item, bool isSelected) {
    // Return widget for individual dropdown items
  }
  
  @override
  List<MyItemType> getItems() {
    // Return list of available items
  }
}
```

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
| `items` | `List<T>` | required | List of options |
| `onChanged` | `ValueChanged<T?>` | required | Callback when selection changes |
| `value` | `T?` | null | Currently selected value |
| `hint` | `String?` | null | Hint text when no item selected |
| `label` | `String Function(T)?` | null | Extracts the text to display for an item. Required unless `T` is `String` |
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
| `itemMargin` | `EdgeInsets?` | null | Margin around each dropdown item |
| `itemBorderRadius` | `double?` | null | Individual border radius for items |
| `itemSplashColor` | `Color?` | null | Splash color for item interactions |
| `itemHighlightColor` | `Color?` | null | Highlight color for item touch |

## DropdownOverlayController

Drives a dropdown menu: its overlay's lifetime, its open/close animation, the widget tree the menu is drawn into, and the rule that only one menu is open at a time within an `Overlay`.

**Hold one; do not inherit from it.** This package's own `FlutterDropdownButton` holds the same controller, so a custom dropdown built on it behaves identically.

Replaces `DropdownMixin`, which is deprecated and will be removed in 3.0.0.

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
| `isOpen` | Whether the menu is showing |
| `animation` | Runs forward as the menu opens. Drive your own transitions from it — a rotating trailing icon, say |
| `open(context)` | Shows the menu, closing whichever menu is open in the same `Overlay` |
| `close({animate = true})` | Hides the menu. Pass `animate: false` to tear it down at once |
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

## DropdownMixin<T>

**Deprecated since 2.4.0. Removed in 3.0.0.** Hold a `DropdownOverlayController` instead.

The mixin still works — it now delegates to a controller — so mixin-based and controller-based menus share one "only one menu open" registry and both answer `closeAll()`.

Migration: the twenty-three members the mixin asked you to implement collapse into a single `DropdownOverlaySpec`.

```dart
// Before
class _MyDropdownState extends State<MyDropdown>
    with SingleTickerProviderStateMixin, DropdownMixin<MyDropdown> {
  @override
  Widget buildOverlayContent(double height) => ListView(...);
  @override
  int get itemCount => widget.items.length;
  @override
  Duration get animationDuration => Duration(milliseconds: 200);
  // ...twenty more
}

// After — see DropdownOverlayController above
```

### Manual Dropdown Cleanup

The `closeAll()` static method provides a way to manually close any open dropdown overlay. This is useful when you need to ensure all dropdowns are closed before navigation or other actions.

#### Features
- **Static Method**: Can be called without a dropdown instance
- **Immediate Cleanup**: Removes overlay instantly without animation
- **Safe Execution**: Handles already-removed overlays gracefully
- **Single Overlay**: Only one dropdown can be open at a time

#### Example Usage

```dart
// Close any open dropdown before navigation
void navigateAway() {
  DropdownMixin.closeAll();
  Navigator.pushNamedAndRemoveUntil(
    context,
    '/home',
    (route) => false,
  );
}

// Close dropdown before showing dialog
void showConfirmDialog() {
  DropdownMixin.closeAll();
  showDialog(
    context: context,
    builder: (context) => AlertDialog(...),
  );
}
```

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