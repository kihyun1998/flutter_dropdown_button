# API Reference

Complete reference for all classes and widgets in the flutter_dropdown_button package.

> Classes removed in 2.0.0 — `BaseDropdownButton`, `BasicDropdownButton`, `TextOnlyDropdownButton`, `DynamicTextBaseDropdownButton`, `DropdownItem` — were documented here long after they ceased to exist. See `documentation/migration.md`.

## FlutterDropdownButton<T>

The one dropdown widget. Two constructors.

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

### Statics

| Member | Description |
|--------|-------------|
| `closeAll({bool animate = true})` | Closes every open menu. Pass `animate: false` right before navigation, when the widget may be disposed before an animation could finish |

## DropdownPositionResult

Position calculation result, returned by the deprecated `DropdownMixin.calculateDropdownPosition()`. New code reads a `DropdownPlacementResult` from `DropdownOverlayController.measurePlacement()` instead. Removed alongside the mixin in 3.0.0.

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `height` | `double` | The calculated height for the dropdown overlay |
| `openDown` | `bool` | Whether the dropdown should open downward (true) or upward (false) |
| `transformAlignment` | `Alignment` | The transform alignment for animations |
| `topPosition` | `double` | The calculated top position for the overlay |

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

## Theme resolution

`DropdownTheme` fills in its own gaps. The widget reads a resolved style rather than deciding between a themed value and a framework default at each call site — so the rule for "what colour is the arrow when disabled?" exists in exactly one place.

Resolution takes a **plain palette**, not a `BuildContext`. Reading values out of a `ThemeData` needs an element tree; deciding with them does not, and only the second half is worth testing.

```dart
final ambient = DropdownAmbientColors.of(context);   // once, in build
final style = theme.resolveButton(ambient, enabled: isEnabled);

Container(decoration: style.decoration, ...);
```

### Methods on DropdownTheme

| Method | Returns | Description |
|--------|---------|-------------|
| `resolveButton(ambient, {required bool enabled})` | `ResolvedButtonStyle` | The button's box, ink colours, content height, and arrow. `enabled` must be the *effective* state — a single-item dropdown disabled by policy is disabled here too |
| `resolveOverlay(ambient)` | `ResolvedOverlayStyle` | The menu container, plus the border thickness the placement module reserves |
| `resolveItem(ambient, {required bool selected, required bool isFirst, required bool isLast})` | `ResolvedItemStyle` | One item row. The end rows are rounded to meet the menu's corners unless `itemBorderRadius` overrides |

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